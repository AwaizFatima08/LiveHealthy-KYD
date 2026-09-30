#!/usr/bin/env python3
"""Validate, version and publish LiveHealthy: Know Your Disease content (design §7).

    python3 scripts/publish_content.py                 # dry run: validate + report
    python3 scripts/publish_content.py --write         # also bump versions, write app/assets/content/
    python3 scripts/publish_content.py --publish       # also upload to Firestore (livehealthy-kyd)
    FIRESTORE_EMULATOR_HOST=127.0.0.1:8085 python3 scripts/publish_content.py --publish   # to the emulator

Source of truth: content/*.json (one file per disease, edited by hand),
content/references.json (shared reference library) and
content/manifest_source.json (groups, tool-link switches, minAppVersion).

Rules enforced (a failure blocks --write and --publish):
  * both languages on every text field;
  * the five sections, in order, each citing at least one reference
    ("no reference, no publish", §4.1), every citation resolvable;
  * every graphic exists in app/assets/graphics/;
  * key numbers match LiveHealthy: Vitals' reference_ranges.dart exactly,
    in both languages (skipped for gestational content, §3);
  * review dates: next review not overdue (warning; --strict makes it an error).

Uploading needs secrets/firebase-admin-service-account.json (a key for the
livehealthy-kyd project ONLY, never the shared patient-data project, §6).
"""
from __future__ import annotations

import argparse
import copy
import datetime as dt
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / 'content'
ASSETS_CONTENT = ROOT / 'app/assets/content'
GRAPHICS = ROOT / 'app/assets/graphics'
VITALS_RANGES = ROOT.parent / 'live_healthy_vitals/app/lib/core/vitals/reference_ranges.dart'
SERVICE_ACCOUNT = ROOT / 'secrets/firebase-admin-service-account.json'
PROJECT_ID = 'livehealthy-kyd'

LANGS = ('en', 'ur')
SECTION_IDS = ['whatIs', 'causes', 'complications', 'lifestyle', 'whenToSeeDoctor']
BLOCK_TYPES = {'paragraph', 'bullets', 'image', 'keyNumber', 'alert', 'refMarker'}
TOOLS = {'vitals', 'medicineReminder'}
TOOL_STATUS = {'live', 'comingSoon', 'hidden'}
NON_DISEASE_FILES = {'references.json', 'manifest_source.json'}


class Report:
    def __init__(self):
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, msg):
        self.errors.append(msg)

    def warn(self, msg):
        self.warnings.append(msg)


# ------------------------------------------------------------ Vitals ranges

def load_vitals_bands(path: Path = VITALS_RANGES) -> dict[str, set[float]]:
    """Reads the thresholds straight out of Vitals' Dart code and returns, for
    each band, the set of numbers a correct description of it must contain."""
    src = path.read_text()

    def num(pattern):
        m = re.search(pattern, src)
        if not m:
            raise ValueError(f'reference_ranges.dart: pattern not found: {pattern}')
        return [float(g) for g in m.groups()]

    vh_s, vh_d = num(r'systolic > (\d+) \|\| diastolic > (\d+)')
    s2_s, s2_d = num(r'systolic >= (\d+) \|\| diastolic >= (\d+)\) \{\s*return const RangeResult\(RangeCategory\.bpStage2')
    s1_s, s1_d = num(r'systolic >= (\d+) \|\| diastolic >= (\d+)\) \{\s*return const RangeResult\(RangeCategory\.bpStage1')
    (el_s,) = num(r'systolic >= (\d+)\) \{\s*return const RangeResult\(RangeCategory\.bpElevated')
    (g_low,) = num(r'mgDl < (\d+)\) return const RangeResult\(RangeCategory\.glucoseLow')
    f_norm, a_norm = num(r'normalBelow = context\.usesFastingRange \? (\d+) : (\d+)')
    f_pre, a_pre = num(r'prediabeticBelow = context\.usesFastingRange \? (\d+) : (\d+)')
    (b_under,) = num(r'bmi < ([\d.]+)\) return const RangeResult\(RangeCategory\.bmiUnderweight')
    (b_norm,) = num(r'bmi < ([\d.]+)\) return const RangeResult\(RangeCategory\.bmiNormal')
    (b_over,) = num(r'bmi < ([\d.]+)\) return const RangeResult\(RangeCategory\.bmiOverweight')

    return {
        'bp.normal': {el_s, s1_d},
        'bp.elevated': {el_s, s1_s - 1, s1_d},
        'bp.stage1': {s1_s, s2_s - 1, s1_d, s2_d - 1},
        'bp.stage2': {s2_s, s2_d},
        'bp.veryHigh': {vh_s, vh_d},
        'glucose.low': {g_low},
        'glucose.fasting.normal': {g_low, f_norm - 1},
        'glucose.fasting.prediabetes': {f_norm, f_pre - 1},
        'glucose.fasting.diabetes': {f_pre},
        'glucose.afterMeal.normal': {a_norm},
        'glucose.afterMeal.prediabetes': {a_norm, a_pre - 1},
        'glucose.afterMeal.diabetes': {a_pre},
        'bmi.underweight': {b_under},
        'bmi.normal': {b_under, round(b_norm - 0.1, 1)},
        'bmi.overweight': {b_norm, round(b_over - 0.1, 1)},
        'bmi.obese': {b_over},
    }


_URDU_DIGITS = str.maketrans('۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩', '01234567890123456789')


def numbers_in(text: str) -> set[float]:
    return {float(n) for n in re.findall(r'\d+(?:\.\d+)?', text.translate(_URDU_DIGITS))}


# --------------------------------------------------------------- validation

def check_localized(value, where, rep: Report, required=True):
    if value is None:
        if required:
            rep.error(f'{where}: missing')
        return
    if not isinstance(value, dict):
        rep.error(f'{where}: expected {{"en": ..., "ur": ...}}')
        return
    for lang in LANGS:
        v = value.get(lang)
        if not isinstance(v, str) or not v.strip():
            rep.error(f'{where}.{lang}: missing or empty')


def validate_disease(d: dict, library: dict, groups: dict, bands: dict | None, rep: Report,
                     today: dt.date, strict: bool):
    did = d.get('id', '?')
    w = f'[{did}]'
    for key in ('id', 'version', 'order', 'status', 'headerAsset', 'reviewedOn', 'nextReviewDue'):
        if key not in d:
            rep.error(f'{w} missing "{key}"')
    if d.get('status') != 'published':
        rep.warn(f'{w} status is "{d.get("status")}", not published: it will be skipped by the app')
    for key in ('title', 'summary', 'reviewedBy'):
        check_localized(d.get(key), f'{w}.{key}', rep)
    group = d.get('group')
    if group is not None and group not in groups:
        rep.error(f'{w}.group "{group}" is not defined in manifest_source.json')
    asset(d.get('headerAsset'), f'{w}.headerAsset', rep)

    # Review dates (§4.4): 12-month cycle, warn when overdue.
    try:
        reviewed = dt.date.fromisoformat(d.get('reviewedOn', ''))
        due = dt.date.fromisoformat(d.get('nextReviewDue', ''))
        if reviewed > today:
            rep.error(f'{w} reviewedOn {reviewed} is in the future')
        if due < today:
            (rep.error if strict else rep.warn)(f'{w} medical review overdue since {due}')
        if (due - reviewed).days > 370:
            rep.warn(f'{w} next review is more than 12 months after the last one')
    except ValueError:
        rep.error(f'{w} reviewedOn / nextReviewDue must be ISO dates (YYYY-MM-DD)')

    refs = d.get('references') or []
    if not isinstance(refs, list) or not refs:
        rep.error(f'{w}.references: empty')
        refs = []
    for r in refs:
        if r not in library:
            rep.error(f'{w}.references: "{r}" is not in references.json')
    if len(set(refs)) != len(refs):
        rep.error(f'{w}.references: duplicates')

    for i, t in enumerate(d.get('relatedTools') or []):
        if t.get('tool') not in TOOLS:
            rep.error(f'{w}.relatedTools[{i}]: unknown tool "{t.get("tool")}"')
        check_localized(t.get('label'), f'{w}.relatedTools[{i}].label', rep)

    sections = d.get('sections') or []
    ids = [s.get('id') for s in sections]
    if ids != SECTION_IDS:
        rep.error(f'{w}.sections: expected {SECTION_IDS}, got {ids}')
    cited_all = set()
    skip_vitals = bool(d.get('skipVitalsCheck'))
    for s in sections:
        sw = f'{w}.{s.get("id")}'
        check_localized(s.get('title'), f'{sw}.title', rep)
        blocks = s.get('blocks') or []
        if not blocks:
            rep.error(f'{sw}: no blocks')
        cited = set()
        for j, b in enumerate(blocks):
            validate_block(b, f'{sw}.blocks[{j}]', rep, bands, skip_vitals)
            for r in b.get('refs') or []:
                cited.add(r)
                if r not in refs:
                    rep.error(f'{sw}.blocks[{j}]: cites "{r}", which is not in this disease\'s references')
        if not cited:
            rep.error(f'{sw}: cites no reference (no reference, no publish)')
        cited_all |= cited
    for r in refs:
        if r not in cited_all:
            rep.warn(f'{w}.references: "{r}" is listed but never cited')


def asset(name, where, rep: Report):
    if not isinstance(name, str) or not name:
        rep.error(f'{where}: missing')
    elif not (GRAPHICS / name).is_file():
        rep.error(f'{where}: app/assets/graphics/{name} does not exist')


def validate_block(b: dict, where: str, rep: Report, bands, skip_vitals: bool):
    t = b.get('type')
    if t not in BLOCK_TYPES:
        rep.error(f'{where}: unknown block type "{t}"')
        return
    if t == 'paragraph':
        check_localized(b.get('text'), f'{where}.text', rep)
    elif t == 'bullets':
        check_localized(b.get('title'), f'{where}.title', rep, required=False)
        items = b.get('items') or []
        if not items:
            rep.error(f'{where}.items: empty')
        for k, it in enumerate(items):
            check_localized(it, f'{where}.items[{k}]', rep)
    elif t == 'image':
        asset(b.get('assetKey'), f'{where}.assetKey', rep)
        check_localized(b.get('caption'), f'{where}.caption', rep)
    elif t == 'alert':
        if b.get('level') not in ('urgent', 'soon'):
            rep.error(f'{where}.level must be "urgent" or "soon"')
        check_localized(b.get('title'), f'{where}.title', rep)
        check_localized(b.get('text'), f'{where}.text', rep, required=False)
        for k, it in enumerate(b.get('items') or []):
            check_localized(it, f'{where}.items[{k}]', rep)
        if not b.get('text') and not b.get('items'):
            rep.error(f'{where}: an alert needs text or items')
    elif t == 'refMarker':
        if not b.get('refs'):
            rep.error(f'{where}.refs: empty')
    elif t == 'keyNumber':
        check_localized(b.get('label'), f'{where}.label', rep)
        check_localized(b.get('value'), f'{where}.value', rep)
        check_localized(b.get('note'), f'{where}.note', rep, required=False)
        if b.get('level', 'neutral') not in ('normal', 'caution', 'alert', 'neutral'):
            rep.error(f'{where}.level: unknown')
        value = b.get('value') or {}
        en, ur = value.get('en', ''), value.get('ur', '')
        if numbers_in(en) != numbers_in(ur):
            rep.error(f'{where}.value: numbers differ between languages: en {sorted(numbers_in(en))} vs ur {sorted(numbers_in(ur))}')
        check = b.get('check')
        if not isinstance(check, dict) or 'metric' not in check:
            rep.error(f'{where}: keyNumber needs "check": {{"metric": "bp|glucose|bmi", "band": ...}} or {{"metric": "none"}}')
            return
        metric = check['metric']
        if metric == 'none' or skip_vitals or bands is None:
            return
        key = f'{metric}.{check.get("band")}'
        if key not in bands:
            rep.error(f'{where}.check: unknown band "{key}"')
            return
        got = numbers_in(en)
        if got != bands[key]:
            rep.error(f'{where}.value "{en}": numbers {sorted(got)} do not match Vitals {key} {sorted(bands[key])}')


def validate_manifest_source(m: dict, rep: Report):
    if not isinstance(m.get('minAppVersion'), int):
        rep.error('manifest_source.minAppVersion: expected an integer')
    for tool, status in (m.get('toolLinks') or {}).items():
        if tool not in TOOLS or status not in TOOL_STATUS:
            rep.error(f'manifest_source.toolLinks: bad entry {tool}: {status}')
    for gid, g in (m.get('groups') or {}).items():
        gw = f'manifest_source.groups.{gid}'
        for key in ('title', 'summary'):
            check_localized(g.get(key), f'{gw}.{key}', rep)
        check_localized(g.get('note'), f'{gw}.note', rep, required=False)
        asset(g.get('headerAsset'), f'{gw}.headerAsset', rep)
        if not isinstance(g.get('order'), int):
            rep.error(f'{gw}.order: expected an integer')
        if not g.get('members'):
            rep.error(f'{gw}.members: empty')


def validate_library(library: dict, rep: Report):
    for rid, r in library.items():
        for key in ('org', 'title', 'year', 'url', 'checkedOn'):
            if not r.get(key):
                rep.error(f'references.{rid}.{key}: missing')
        if not str(r.get('url', '')).startswith('https://'):
            rep.error(f'references.{rid}.url: must be https')


# ------------------------------------------------------------------ build

def load_sources():
    library = json.loads((CONTENT / 'references.json').read_text())
    manifest_src = json.loads((CONTENT / 'manifest_source.json').read_text())
    diseases = {}
    for p in sorted(CONTENT.glob('*.json')):
        if p.name in NON_DISEASE_FILES:
            continue
        d = json.loads(p.read_text())
        diseases[d.get('id', p.stem)] = (p, d)
    return library, manifest_src, diseases


def expand(d: dict, library: dict) -> dict:
    """The app/Firestore form: full reference objects, no authoring-only keys."""
    out = copy.deepcopy(d)
    out.pop('skipVitalsCheck', None)
    out['references'] = [dict(id=r, **library[r]) for r in d['references']]
    for s in out['sections']:
        for b in s['blocks']:
            b.pop('check', None)
    return out


def without_version(d: dict) -> dict:
    x = copy.deepcopy(d)
    x.pop('version', None)
    return x


def run(argv=None, today: dt.date | None = None, vitals_path: Path = VITALS_RANGES) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='bump versions and write app/assets/content/')
    ap.add_argument('--publish', action='store_true', help='also upload to Firestore (implies --write)')
    ap.add_argument('--strict', action='store_true', help='overdue reviews are errors')
    args = ap.parse_args(argv)
    if args.publish:
        args.write = True
    today = today or dt.date.today()
    rep = Report()

    library, manifest_src, diseases = load_sources()
    try:
        bands = load_vitals_bands(vitals_path)
    except (OSError, ValueError) as e:
        rep.error(f'Cannot read Vitals reference ranges ({vitals_path}): {e}')
        bands = None
    validate_library(library, rep)
    validate_manifest_source(manifest_src, rep)
    groups = manifest_src.get('groups') or {}
    for did, (path, d) in diseases.items():
        if path.stem != did:
            rep.error(f'{path.name}: file name must match id "{did}"')
        validate_disease(d, library, groups, bands, rep, today, args.strict)
    for gid, g in groups.items():
        for m in g.get('members') or []:
            if m not in diseases:
                rep.error(f'manifest_source.groups.{gid}: member "{m}" has no content file')
            elif diseases[m][1].get('group') != gid:
                rep.error(f'{m}: listed in group "{gid}" but its "group" field is {diseases[m][1].get("group")!r}')

    for msg in rep.warnings:
        print(f'WARNING  {msg}')
    for msg in rep.errors:
        print(f'ERROR    {msg}')
    if rep.errors:
        print(f'\n{len(rep.errors)} error(s). Nothing written or published.')
        return 1
    print(f'OK: {len(diseases)} topics, {len(library)} references, all checks passed.')
    if not args.write:
        print('(dry run: use --write to update app/assets/content/, --publish to upload)')
        return 0

    # ---- versions: a disease's version goes up whenever its content changes.
    ASSETS_CONTENT.mkdir(parents=True, exist_ok=True)
    old_manifest_path = ASSETS_CONTENT / 'manifest.json'
    old_manifest = json.loads(old_manifest_path.read_text()) if old_manifest_path.exists() else None
    changed = []
    built = {}
    for did, (path, d) in diseases.items():
        if d.get('status') != 'published':
            continue
        new = expand(d, library)
        old_path = ASSETS_CONTENT / f'{did}.json'
        old = json.loads(old_path.read_text()) if old_path.exists() else None
        if old is None:
            new['version'] = max(int(d.get('version', 1)), 1)
            changed.append(did)
        elif without_version(old) != without_version(new):
            new['version'] = int(old['version']) + 1
            changed.append(did)
        else:
            new['version'] = int(old['version'])
        if d.get('version') != new['version']:
            d['version'] = new['version']
            path.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n')
        built[did] = new

    manifest = {
        'contentVersion': 1,
        'minAppVersion': manifest_src['minAppVersion'],
        'diseases': {did: b['version'] for did, b in sorted(built.items())},
        'groups': groups,
        'toolLinks': manifest_src.get('toolLinks') or {},
        'updatedAt': dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat(),
    }
    if old_manifest:
        same = all(old_manifest.get(k) == manifest[k] for k in ('minAppVersion', 'diseases', 'groups', 'toolLinks'))
        manifest['contentVersion'] = old_manifest['contentVersion'] + (0 if same else 1)
        if same:
            manifest['updatedAt'] = old_manifest.get('updatedAt', manifest['updatedAt'])
    for did, b in built.items():
        (ASSETS_CONTENT / f'{did}.json').write_text(json.dumps(b, ensure_ascii=False, indent=1) + '\n')
    for stale in ASSETS_CONTENT.glob('*.json'):
        if stale.stem not in built and stale.name != 'manifest.json':
            stale.unlink()
    old_manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=1) + '\n')
    print(f'Wrote app/assets/content/: contentVersion {manifest["contentVersion"]}, '
          f'changed: {", ".join(changed) or "none"}')

    if args.publish:
        return upload(manifest, built)
    return 0


def upload(manifest: dict, built: dict) -> int:
    emulator = os.environ.get('FIRESTORE_EMULATOR_HOST')
    try:
        if emulator:
            from google.auth.credentials import AnonymousCredentials
            from google.cloud import firestore
            db = firestore.Client(project=PROJECT_ID, credentials=AnonymousCredentials())
        else:
            if not SERVICE_ACCOUNT.exists():
                print(f'Cannot publish: {SERVICE_ACCOUNT.relative_to(ROOT)} not found.\n'
                      'Create it in Firebase console → livehealthy-kyd → Project settings → '
                      'Service accounts → Generate new private key.')
                return 2
            import firebase_admin
            from firebase_admin import credentials, firestore as admin_fs
            key = json.loads(SERVICE_ACCOUNT.read_text())
            if key.get('project_id') != PROJECT_ID:
                print(f'Refusing: the service account is for "{key.get("project_id")}", not {PROJECT_ID}.')
                return 2
            app = firebase_admin.initialize_app(credentials.Certificate(str(SERVICE_ACCOUNT)))
            db = admin_fs.client(app)
    except ImportError:
        print('Cannot publish: run  python3 -m venv scripts/.venv && scripts/.venv/bin/pip install firebase-admin\n'
              'then use scripts/.venv/bin/python3.')
        return 2

    remote = db.document('kyd_manifest/current').get()
    if remote.exists and remote.to_dict().get('contentVersion', 0) > manifest['contentVersion']:
        print('Refusing: Firestore has a newer contentVersion than this checkout. Pull first.')
        return 3
    remote_versions = (remote.to_dict() or {}).get('diseases', {}) if remote.exists else {}
    # Diseases first, manifest last, so the manifest never points at a
    # document that isn't there yet.
    uploaded = []
    for did, b in built.items():
        if remote_versions.get(did) == b['version']:
            continue
        db.collection('kyd_diseases').document(did).set(b)
        uploaded.append(did)
    db.document('kyd_manifest/current').set(manifest)
    target = f'emulator {emulator}' if emulator else f'Firestore project {PROJECT_ID}'
    print(f'Published to {target}: manifest v{manifest["contentVersion"]}, '
          f'diseases uploaded: {", ".join(uploaded) or "none (already current)"}')
    return 0


if __name__ == '__main__':
    sys.exit(run())
