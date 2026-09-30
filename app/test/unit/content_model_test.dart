import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/content/models.dart';
import 'package:livehealthy_kyd/widgets/content_text.dart';

import '../helpers.dart';

Map<String, dynamic> copyOf(Map<String, dynamic> m) => jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

void main() {
  group('bundled content', () {
    for (final id in allTopicIds) {
      test('$id parses and follows the seven-part structure', () {
        final d = Disease.fromJson(bundledJson(id));
        expect(d.id, id);
        expect(d.sections.map((s) => s.id), kSectionIds);
        for (final s in d.sections) {
          expect(s.citedRefs, isNotEmpty, reason: '${s.id} cites nothing');
          for (final r in s.citedRefs) {
            expect(d.refById(r), isNotNull, reason: 'unresolved $r');
          }
        }
        expect(d.references.every((r) => r.url.startsWith('https://')), isTrue);
        expect(d.title.of('ur'), isNot(d.title.of('en')));
      });
    }

    test('manifest lists every topic and the diabetes group', () {
      final m = ContentManifest.fromJson(bundledJson('manifest'));
      expect(m.diseases.keys.toSet(), allTopicIds.toSet());
      expect(m.groups['diabetes']!.members, ['prediabetes', 'type2_diabetes', 'gestational_diabetes']);
      expect(m.groups['diabetes']!.note!.of('en'), contains('Type 1'));
      expect(m.toolLinks.keys.toSet(), ToolApp.values.toSet());
    });

    test('gestational content says Vitals flags are for non-pregnant adults (§3)', () {
      final text = jsonEncode(bundledJson('gestational_diabetes'));
      expect(text, contains('not pregnant'));
    });
  });

  group('validation rejects unsafe content', () {
    late Map<String, dynamic> base;
    setUp(() => base = copyOf(bundledJson('hypertension')));

    test('missing Urdu', () {
      (base['summary'] as Map).remove('ur');
      expect(() => Disease.fromJson(base), throwsA(isA<ContentFormatException>()));
    });

    test('a section with no reference', () {
      final blocks = (base['sections'] as List)[1]['blocks'] as List;
      for (final b in blocks) {
        (b as Map).remove('refs');
      }
      expect(
        () => Disease.fromJson(base),
        throwsA(isA<ContentFormatException>().having((e) => e.message, 'message', contains('cites no reference'))),
      );
    });

    test('an unresolvable reference', () {
      ((base['sections'] as List)[0]['blocks'] as List)[0]['refs'] = ['nope'];
      expect(() => Disease.fromJson(base), throwsA(isA<ContentFormatException>()));
    });

    test('sections out of order', () {
      final s = base['sections'] as List;
      final first = s.removeAt(0);
      s.add(first);
      expect(() => Disease.fromJson(base), throwsA(isA<ContentFormatException>()));
    });

    test('a non-https reference link', () {
      ((base['references'] as List)[0] as Map)['url'] = 'http://example.com';
      expect(() => Disease.fromJson(base), throwsA(isA<ContentFormatException>()));
    });

    test('an unpublished document', () {
      base['status'] = 'draft';
      expect(() => Disease.fromJson(base), throwsA(isA<ContentFormatException>()));
    });

    test('path-like ids and graphic names (downloaded ids become file names)', () {
      final evil = copyOf(base)..['id'] = '../../shared_prefs/x';
      expect(() => Disease.fromJson(evil), throwsA(isA<ContentFormatException>()));
      final evilAsset = copyOf(base)..['headerAsset'] = '../images/app_icon.png';
      expect(() => Disease.fromJson(evilAsset), throwsA(isA<ContentFormatException>()));
      final man = copyOf(bundledJson('manifest'));
      (man['diseases'] as Map)['../x'] = 1;
      expect(() => ContentManifest.fromJson(man), throwsA(isA<ContentFormatException>()));
    });

    test('garbage instead of a document', () {
      expect(() => Disease.fromJson('hello'), throwsA(isA<ContentFormatException>()));
      expect(() => Disease.fromJson(null), throwsA(isA<ContentFormatException>()));
      expect(() => ContentManifest.fromJson([1, 2]), throwsA(isA<ContentFormatException>()));
    });
  });

  group('forward compatibility (§12)', () {
    test('unknown block types are skipped, not fatal', () {
      final m = copyOf(bundledJson('hypertension'));
      final blocks = (m['sections'] as List)[0]['blocks'] as List;
      final before = blocks.length;
      blocks.insert(0, {'type': 'video', 'url': 'https://example.com'});
      final d = Disease.fromJson(m);
      expect(d.sections[0].blocks.length, before);
    });

    test('unknown tools are ignored and unknown tool statuses hide the button', () {
      final m = copyOf(bundledJson('hypertension'));
      (m['relatedTools'] as List).add({
        'tool': 'doctorDirectory',
        'label': {'en': 'x', 'ur': 'y'},
      });
      expect(Disease.fromJson(m).relatedTools.length, 2);
      final man = copyOf(bundledJson('manifest'));
      man['toolLinks'] = {'vitals': 'somethingNew'};
      final parsed = ContentManifest.fromJson(man);
      expect(parsed.toolLinks[ToolApp.vitals], ToolLinkStatus.hidden);
      expect(parsed.toolLinks[ToolApp.medicineReminder], ToolLinkStatus.hidden);
    });

    test('a missing language falls back to English when read', () {
      const t = LocalizedText({'en': 'Hello', 'ur': 'سلام'});
      expect(t.of('fr'), 'Hello');
    });
  });

  group('bidiSafe', () {
    test('isolates number runs in Urdu only', () {
      String plain(String s) => s.replaceAll('\u2060', '');
      expect(plain(bidiSafe('Top 130–139', 'en')), 'Top 130–139');
      expect(plain(bidiSafe('اوپر والا 130–139 یا', 'ur')), 'اوپر والا \u2066130–139\u2069 یا');
      expect(plain(bidiSafe('120/80 mmHg سے کم', 'ur')), '\u2066120/80 mmHg\u2069 سے کم');
      expect(plain(bidiSafe('5.7%–6.4%', 'ur')), '\u20665.7%–6.4%\u2069');
      expect(plain(bidiSafe('126 mg/dL یا زیادہ', 'ur')), '\u2066126 mg/dL\u2069 یا زیادہ');
    });

    test('number runs never break at their dash or slash (seen on the Galaxy A12)', () {
      expect(bidiSafe('Top 120–129, bottom', 'en'), 'Top 120\u2060–\u2060129, bottom');
      expect(bidiSafe('Below 120/80 mmHg', 'en'), 'Below 120\u2060/\u206080 mmHg');
      expect(bidiSafe('7% to 10%', 'en'), '7% to 10%');
    });

    test('leaves Urdu text without numbers alone', () {
      expect(bidiSafe('ہائی بلڈ پریشر', 'ur'), 'ہائی بلڈ پریشر');
    });
  });
}
