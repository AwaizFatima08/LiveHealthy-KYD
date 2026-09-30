# Prelaunch Review — LiveHealthy: Know Your Disease v1.0.0

Date: 2026-09-30

## ⚠ Owner actions before publishing (blocking)
1. **Medical review of all five topics (§4.4).** The content was written by Claude from the cited
   sources, and every number and claim was checked against the source page. But the app shows
   "Medically reviewed by Dr. Humayun Shahzad, MBBS · Reviewed on 30 Sep 2026". **Read every topic
   before release.** Edit `content/*.json` as needed, run `python3 scripts/publish_content.py
   --write`, and rebuild. Check the exact title wording in `reviewedBy` too.
2. **Urdu review by a second reader (§4.5).** In particular, check the medical terms (سسٹولک،
   ڈائسٹولک، پری ایکلیمپسیا، ڈایابیٹک ریٹینوپیتھی) and gendered forms (e.g. "میں سمجھ گیا/گئی").
3. **Upload the website** (Hostinger, site root): `live_healthy/website/privacy-policy.html`,
   `terms-and-conditions.html` and `index.html` (committed in the Medicine Reminder repo). The
   policy now discloses Crashlytics. Its old line "no crash-reporting SDKs" would have been false.
4. **Seed production content** (needed for over-the-air updates, not for the app to work):
   Firebase console → livehealthy-kyd → Project settings → Service accounts → Generate new private
   key → save as `secrets/firebase-admin-service-account.json`, then
   `scripts/.venv/bin/python scripts/publish_content.py --publish`. The script refuses a key for
   any other project.
5. **Play Console:** create the app, enrol in Play App Signing, upload
   `app/build/app/outputs/bundle/release/app-release.aab`, and fill in the listing and forms
   exactly as written in `store/listing/store_listing.md` (the Data safety answers depend on the
   Crashlytics disclosure).
6. When Vitals and Medicine Reminder are live on Play, set `toolLinks` to `live` in
   `content/manifest_source.json` and publish. No app update is needed. Until then an installed
   app shows **Open** and a missing one shows "coming soon".

## Test results
| Suite | Result |
|---|---|
| `flutter analyze` | no issues |
| Dart unit tests: content model and validation, forward compatibility, path-safety, bidi | pass |
| Service tests: repository merge/fallback/corruption, update service on fake Firestore (daily limit, rejects bad docs, version mismatch, minAppVersion, tool switches, clock skew) | pass |
| Widget tests: onboarding, Home, group, full reader journey, reference panel, Track it, Urdu RTL + font, settings, every section in both languages, 320×640 at 1.3× font × Extra large in both languages, contrast | pass (50 Dart tests total) |
| Content validator tests (`scripts/test_publish_content.py`), incl. "rejects a section with no reference" and "detects a change in Vitals' ranges" | 15/15 pass |
| Firestore rules tests on the emulator | 8/8 pass |
| On-device end-to-end, Galaxy A12 at 1.3× font, real fonts, against the local emulator: all 5 topics × 6 screens, Track it detects installed Vitals, reference panel, update check, Urdu leg | pass |
| Over-the-air update round trip on the A12 (§13 step 4): sentence changed → published → appeared on the phone with no reinstall → still there on a cold start in airplane mode | pass |
| Release AAB/APK build, R8 + resource shrinking, signature check | pass |

## Real-device run (Samsung Galaxy A12 SM-A125F, Android 12, 720×1600, density 340)
Issues found only on the device, all fixed:
1. Reference markers `[1]` stretched to full width (Container alignment inside a Wrap).
2. Number ranges wrapped at the dash ("120–" / "129"). Runs are now joined with U+2060.
3. Tall Nastaliq letters in key-number values overlapped the box below, and the Urdu app-bar
   title was clipped. Urdu now uses even leading at 1.9–2.0 line height and a taller toolbar.
4. The Urdu date included the weekday.
5. The launch screen was black in dark mode (the app is light-only).
6. The English app-bar title was truncated at 1.3× ("Know Your Dise…").
7. In "When to see a doctor", the action ("go to hospital now…") came before the list of signs.
8. Topic cards stacked too eagerly at the phone's 1.3× setting.
Measured on the A12 with the release build: cold start ≈ 0.8 s (3.6 s on the very first launch),
about 88 MB PSS. The offline "Check for updates" fails in about 1 s with a clear message.

## Real bugs found by testing (all fixed)
1. **A downloaded file carrying the wrong id made a topic disappear** instead of falling back to
   the bundled copy.
2. **RTL isolation split "5.7%–6.4%"**, so Urdu would have shown the range reversed.
3. **Path traversal (security):** downloaded manifest keys and ids become file names. Ids and
   graphic names are now whitelisted (`[a-z0-9_-]`) in the app and the validator.
4. **Contrast:** white text on the suite amber `#B26A00` is 4.2:1, below WCAG AA. Amber text and
   the amber alert header now use `#8A5300` (6.3:1). The flag colour itself is unchanged.
5. **Crashlytics hid errors from tests:** its `FlutterError.onError` hook replaced the test
   handler, so a failure hung the e2e run. The handlers are now installed in release builds only
   (collection was already off in debug).
6. Port clash: the Vitals / Medicine Reminder emulator already uses 8085, so this project's
   Firestore emulator is on **8086**.

## Security review
- **No user data at all:** no login, no personal or health input, no analytics. On-device state is
  language, text size, disclaimer flag and downloaded public articles.
- **Separate Firebase project (D3)**, so the publishing key can never reach patient data. The
  publish script refuses a service-account key for any other project.
- **Firestore rules:** `get` only on `kyd_manifest/*` and `kyd_diseases/*`. No listing, no client
  writes, and everything else is denied. Tested on the emulator.
- **Downloaded content is untrusted input:** strict schema validation, https-only reference
  links, whitelisted ids and graphic names (see bug 3), the version must match the manifest, and
  anything invalid is rejected with the old copy kept. Writes are atomic (temp file, then rename).
  Firestore's own cache is disabled.
- **Release APK:** not debuggable, `usesCleartextTraffic=false` (the debug build allows it only
  for the local emulator), R8 on. Exported components are the launcher activity and AndroidX's
  ProfileInstallReceiver (guarded by the system DUMP permission).
- **Permissions:** INTERNET, ACCESS_NETWORK_STATE (Firebase), and AndroidX's
  DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION. Nothing else.
- **"Track it" channel:** the native side only answers for the two allow-listed sibling packages.
- **Secrets:** keystore, key.properties, google-services.json and the admin key are gitignored and
  excluded from Drive. A git scan found no secrets in tracked files.

## Design decisions made during the build (V1)
- **Rename to Know Your Disease:** see the build note at the top of design-v1.md. The Medicine
  Reminder button label uses the owner's later colon naming ("LiveHealthy: Medicine Reminder")
  rather than D11's older wording.
- **Shared reference library** (`content/references.json`): topics list reference ids, and the
  publish script expands them into full citations for the app and Firestore. One source is
  checked once and cited consistently.
- **Vitals number check:** every `keyNumber` must declare `check`. The validator reads the
  thresholds straight from Vitals' `reference_ranges.dart` and requires the exact numbers in both
  languages. HbA1c, NICE pregnancy targets and the Asian BMI points are marked
  `{"metric": "none"}`, because Vitals doesn't track them. Gestational content has
  `skipVitalsCheck` (§3).
- **Section count:** the reader shows n/6 (5 written sections plus References). "Track it" (7) is
  the card on the topic page.
- **Graphics** are generated reproducibly by `scripts/make_graphics.py` (homidev's pipeline isn't
  ready yet, and Inkscape on Hadi's PC is D6's long-term plan). They are plain SVGs and editable
  in Inkscape.
- **Emergency number:** alerts say "Rescue 1122 in Pakistan".
- **Firestore location** is `nam5` (created automatically at first deploy). This is fine for
  public articles read at most once a day; it can't be moved later.
- **Crash reports:** Crashlytics collection is off in debug builds.

## Open / later (not V1)
- Low-BP content together with a Vitals low-BP band (§3); read aloud (D5, V1.1); a shared theme
  package; Vitals and Medicine Reminder linking back to this app.
- Vitals flags BMI on the standard bands only, while this app shows the WHO Asian action points
  as a labelled note (D1). Revisit the Vitals flags separately.
