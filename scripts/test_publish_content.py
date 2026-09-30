"""Tests for the content validator.   python3 -m unittest scripts/test_publish_content.py"""
import copy
import datetime as dt
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import publish_content as pc  # noqa: E402

TODAY = dt.date(2026, 10, 1)


class ValidatorTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.library, cls.manifest_src, diseases = pc.load_sources()
        cls.groups = cls.manifest_src['groups']
        cls.diseases = {k: d for k, (_, d) in diseases.items()}
        cls.bands = pc.load_vitals_bands()

    def check(self, d, strict=False, today=TODAY):
        rep = pc.Report()
        pc.validate_disease(d, self.library, self.groups, self.bands, rep, today, strict)
        return rep

    def htn(self):
        return copy.deepcopy(self.diseases['hypertension'])

    def block(self, d, type_, **match):
        for s in d['sections']:
            for b in s['blocks']:
                if b['type'] == type_ and all(b.get(k) == v for k, v in match.items()):
                    return b
        raise AssertionError(f'no {type_} block {match}')

    def test_all_real_content_is_valid(self):
        for did, d in self.diseases.items():
            rep = self.check(d)
            self.assertEqual(rep.errors, [], did)

    def test_rejects_section_with_no_reference(self):
        d = self.htn()
        for b in d['sections'][1]['blocks']:
            b.pop('refs', None)
        rep = self.check(d)
        self.assertTrue(any('causes: cites no reference' in e for e in rep.errors), rep.errors)

    def test_rejects_unknown_reference(self):
        d = self.htn()
        d['sections'][0]['blocks'][0]['refs'] = ['made-up']
        self.assertTrue(any('"made-up"' in e for e in self.check(d).errors))

    def test_rejects_missing_urdu(self):
        d = self.htn()
        d['sections'][2]['blocks'][0]['text']['ur'] = ''
        self.assertTrue(any('.ur: missing or empty' in e for e in self.check(d).errors))

    def test_rejects_sections_out_of_order(self):
        d = self.htn()
        d['sections'][0], d['sections'][1] = d['sections'][1], d['sections'][0]
        self.assertTrue(any('expected' in e and 'sections' in e for e in self.check(d).errors))

    def test_rejects_bp_number_that_disagrees_with_vitals(self):
        d = self.htn()
        b = self.block(d, 'keyNumber', check={'metric': 'bp', 'band': 'stage1'})
        b['value'] = {'en': 'Top 130–140 or bottom 80–90', 'ur': 'اوپر والا 130–140 یا نیچے والا 80–90'}
        self.assertTrue(any('do not match Vitals bp.stage1' in e for e in self.check(d).errors))

    def test_rejects_numbers_that_differ_between_languages(self):
        d = self.htn()
        b = self.block(d, 'keyNumber', check={'metric': 'bp', 'band': 'normal'})
        b['value']['ur'] = '130/80 mmHg سے کم'
        self.assertTrue(any('numbers differ between languages' in e for e in self.check(d).errors))

    def test_gestational_content_skips_vitals_check(self):
        d = copy.deepcopy(self.diseases['gestational_diabetes'])
        self.assertTrue(d['skipVitalsCheck'])
        b = self.block(d, 'keyNumber')
        b['check'] = {'metric': 'glucose', 'band': 'fasting.normal'}  # would fail if checked
        self.assertEqual(self.check(d).errors, [])

    def test_key_number_needs_a_check(self):
        d = self.htn()
        self.block(d, 'keyNumber', check={'metric': 'bp', 'band': 'normal'}).pop('check')
        self.assertTrue(any('keyNumber needs "check"' in e for e in self.check(d).errors))

    def test_missing_graphic(self):
        d = self.htn()
        self.block(d, 'image', assetKey='bp_organs.svg')['assetKey'] = 'nope.svg'
        self.assertTrue(any('nope.svg does not exist' in e for e in self.check(d).errors))

    def test_overdue_review_warns_or_fails_when_strict(self):
        later = dt.date(2027, 10, 1)
        rep = self.check(self.htn(), today=later)
        self.assertEqual(rep.errors, [])
        self.assertTrue(any('review overdue' in w for w in rep.warnings))
        self.assertTrue(any('review overdue' in e for e in self.check(self.htn(), strict=True, today=later).errors))

    def test_vitals_parser_matches_design_numbers(self):
        b = self.bands
        self.assertEqual(b['bp.stage1'], {130, 139, 80, 89})
        self.assertEqual(b['bp.veryHigh'], {180, 120})
        self.assertEqual(b['glucose.fasting.prediabetes'], {100, 125})
        self.assertEqual(b['glucose.afterMeal.diabetes'], {200})
        self.assertEqual(b['bmi.normal'], {18.5, 24.9})

    def test_vitals_change_is_detected(self):
        # If Vitals ever changes a threshold, Know Your Disease content must fail.
        src = pc.VITALS_RANGES.read_text().replace('systolic >= 130', 'systolic >= 135')
        tmp = Path(self.id().replace('.', '_') + '.dart')
        try:
            tmp.write_text(src)
            bands = pc.load_vitals_bands(tmp)
        finally:
            tmp.unlink()
        rep = pc.Report()
        pc.validate_disease(self.htn(), self.library, self.groups, bands, rep, TODAY, False)
        self.assertTrue(any('bp.stage1' in e or 'bp.elevated' in e for e in rep.errors))

    def test_expanded_form_parses_like_the_app_expects(self):
        out = pc.expand(self.diseases['obesity'], self.library)
        self.assertTrue(all(isinstance(r, dict) and r['url'].startswith('https://') for r in out['references']))
        self.assertFalse(any('check' in b for s in out['sections'] for b in s['blocks']))
        self.assertNotIn('skipVitalsCheck', out)


if __name__ == '__main__':
    unittest.main()
