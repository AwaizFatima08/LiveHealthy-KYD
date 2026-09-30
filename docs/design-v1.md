# LiveHealthy Learn — Design Document (V1 Scope)

> **Build note (2026-09-30):** built as **LiveHealthy: Know Your Disease** (renamed from "Learn" by the
> owner). Following the rename and the suite's colon naming, `learn` became `kyd` throughout:
> package `com.homilabs.livehealthy_kyd`, Firebase project `livehealthy-kyd`, collections
> `kyd_manifest` / `kyd_diseases`, key `livehealthy-kyd-release.jks`, launcher label "Know Your
> Disease". Per the owner's 2026-09-28 decision, the website uses the shared family policy pages
> (with a Know Your Disease section) instead of separate `learn-*.html` pages. Everything else is
> as locked below. See docs/prelaunch_review.md for build-time decisions.


**Status:** LOCKED (all decisions D1–D13 recorded in §15). This document is the build reference. Any later change is a new decision, discussed and confirmed before code changes.

**Revision 3:** Decisions D1–D12 recorded (§15). Revision 2 filled in values from the actual code in `live_healthy/` (Medicine Reminder) and `live_healthy_vitals/`.

**App name:** LiveHealthy Learn — **LOCKED** (suite naming scheme "LiveHealthy + function").

**Part of:** The LiveHealthy family: Medicine Reminder (`live_healthy/`), Vitals (`live_healthy_vitals/`), Learn (this), and later the Doctor Directory. Separate, focused apps under one brand.

---

## 1. Purpose & Target User

A bilingual (Urdu / English) Android app that teaches the general public the basic facts about common chronic diseases. It uses static graphics and plain language, and a trusted reference sits behind every fact.

- **Target user:** the general population, including older and less tech-comfortable users.
- **What it is:** health *education*, facts only.
- **What it is not:** a diagnosis tool, a symptom checker or a treatment adviser. The app never tells a user what *they* have or which medicine to take.
- **Commercial intent:** a Play Store product in the LiveHealthy suite.

---

## 2. V1 Scope — LOCKED

| Item | Decision |
|---|---|
| App structure | One app, with each disease as a module |
| V1 diseases | Hypertension, Diabetes, Obesity |
| Media | Static graphics only. No videos. |
| Myths section | Dropped. Facts only. |
| References | Required on every page (NICE, WHO, AHA, ADA, Mayo Clinic, Cleveland Clinic, FDA, other valid sources) |
| "When to see a doctor" | Included as a section in every disease |
| Languages | Urdu and English, user selects |
| Content delivery | Bundled inside the app (works fully offline). Corrections and new content download from Firestore. |
| Numbers (BP etc.) | Must match LiveHealthy Vitals §6 / `reference_ranges.dart` exactly |
| Doctor directory | Separate future app, cross-linked. Not part of Learn. |
| Cross-linking | Learn links to the related LiveHealthy tool apps |
| More diseases | Added in later versions |

---

## 3. Content Structure (per disease) — LOCKED

Every disease has the same seven sections, in this order:

1. **What it is.** A plain definition and how common it is.
2. **Causes & risk factors.** What raises the risk, split into what you can and can't change.
3. **Complications of poor control.** What happens to the heart, kidneys, eyes, brain and so on.
4. **Lifestyle changes.** Diet, activity, weight, smoking, sleep and stress, as concrete, measurable actions.
5. **When to see a doctor.** Warning signs, in two visual levels:
   - 🔴 **Urgent: go to hospital now** (e.g., BP above 180/120 with chest pain or severe headache)
   - 🟠 **See your doctor soon** (e.g., repeated readings in the high range)
6. **References.** The full list of sources for this disease.
7. **Track it.** A link to the matching LiveHealthy tool app (see §9).

### Each section is made of "blocks"
| Block type | What it shows |
|---|---|
| `paragraph` | A short piece of text |
| `bullets` | A bullet list |
| `image` | A language-free graphic with a caption in the selected language |
| `keyNumber` | A highlighted number box (e.g., "Normal BP: below 120/80") |
| `alert` | A coloured warning box (red = urgent, amber = soon), in the same colours as Vitals flags |
| `refMarker` | A small [1] linked to the reference list |

Every text field is stored in both languages: `{ "en": "...", "ur": "..." }`.

### Numbers used in content (from Vitals `reference_ranges.dart`)
- **BP (AHA/ACC):** Normal <120/<80 · Elevated 120–129/<80 · Stage 1 130–139 or 80–89 · Stage 2 ≥140 or ≥90 · Very high >180 or >120 (seek urgent care). The higher of systolic/diastolic decides the category, as in Vitals.
- **Glucose, fasting / before meal (mg/dL):** Low <70 · Normal 70–99 · Prediabetic 100–125 · Diabetic ≥126
- **Glucose, after meal / random:** Low <70 · Normal <140 · Prediabetic 140–199 · Diabetic ≥200
- **BMI:** Underweight <18.5 · Normal 18.5–24.9 · Overweight 25–29.9 · Obese ≥30 (see D1)

**Rule:** if `reference_ranges.dart` in Vitals ever changes, Learn's content changes in the same week. The Python validator (§7) can compare the numbers automatically.

### Scope notes for V1 diseases (LOCKED, D8 variants pending)
- **Diabetes:** covers **prediabetes, Type 2 diabetes and gestational diabetes** (D8). It opens with one line saying Type 1 and other rare types are not covered and should be discussed with a doctor.
- **Gestational diabetes numbers differ.** Pregnancy glucose targets are stricter than the general adult ranges Vitals uses, and Vitals has no pregnancy profile. So the gestational content must state plainly that Vitals' colour flags are for non-pregnant adults and that a pregnant woman should follow her doctor's targets. The number check in the validator (§7) must skip gestational content.
- **Hypertension:** the content deliberately does *not* cover low blood pressure. Vitals also has no low-BP band yet (its prelaunch review flags this as open). Both apps should add it together, later.

---

## 4. Content Governance — LOCKED

1. **No reference, no publish.** Every section must cite at least one source. The publishing script refuses to publish a section with none.
2. **Guideline bodies first:** WHO, NICE, AHA/ACC, ADA. Mayo Clinic and Cleveland Clinic are secondary sources for plain-language explanations. FDA is used only where relevant.
3. **Each reference stores:** organisation, title, year, URL and the date it was checked. The citation still shows offline or if a link dies.
4. **Every disease shows:** "Medically reviewed by Dr. Humayun Shahzad, MBBS (exact title wording is your call) · Reviewed on [date] · Next review [date]". The review cycle is 12 months, and the script warns when a date has passed.
5. **Urdu review:** a second person checks the Urdu for plain-language clarity.
6. **Disclaimer** on first launch and in About: "This app provides general health information only. It does not diagnose or treat. Always consult a qualified doctor."

---

## 5. Tool Set — LOCKED (matched to the Vitals codebase)

### App
| Tool / package | Why | Same as Vitals? |
|---|---|---|
| Flutter 3.41 / Dart 3.11 | Suite standard | ✔ |
| `provider` | App state (language, text size) | ✔ |
| `flutter_localizations` + gen-l10n ARB (`app_en.arb`, `app_ur.arb`) | UI labels in Urdu/English from day one | ✔ |
| `intl` | Dates and numbers per language | ✔ |
| `url_launcher` | Reference links, Play Store links | ✔ |
| `package_info_plus` | Shows the app version in About | ✔ |
| `firebase_core`, `cloud_firestore` | Content updates | ✔ (versions matched) |
| `shared_preferences` | Remembers language, text size, disclaimer accepted | ✔ (Medicine Reminder) |
| `path_provider` | Stores downloaded content on the phone | ✔ (Medicine Reminder) |
| `flutter_svg` | Language-free graphics as SVG | **New to suite** |
| `firebase_crashlytics` | Crash reports only (D4) | **New to suite** |
| `flutter_launcher_icons` | Icon from one image | ✔ |
| Noto Nastaliq Urdu (bundled font, D10) | Urdu reading text, with extra line spacing | **New to suite** |
| Tests: `flutter_test`, `fake_cloud_firestore`, `integration_test` | Same testing approach as Vitals | ✔ |

**Not used:** `firebase_auth` (no login), notifications, camera, TTS.

### Content authoring (on homi-nas)
| Tool | Why |
|---|---|
| VS Code | Writing content files (JSON) |
| Git | Content history |
| Python 3 + `firebase-admin` | Validate + publish script |
| Inkscape (D6), on Hadi's PC | Drawing language-free SVGs; exported SVGs are committed into `app/assets/graphics/` |

### Build settings (copied from Vitals `build.gradle.kts`)
- `applicationId` / `namespace`: **`com.homilabs.livehealthy_learn`**, following the Vitals pattern `com.homilabs.livehealthy_vitals`
- `key.properties` + `secrets/livehealthy-learn-release.jks`: its own key, as Vitals already does (`livehealthy-vitals-release.jks`)
- R8 + resource shrinking, AAB for Play
- Launcher label: **"LiveHealthy Learn"**
- Adaptive icon background `#0B6E4F`, the same as Vitals

### Permissions
Only `INTERNET`.

---

## 6. Project Layout & Frontend / Backend — LOCKED

### Folder: `/mnt/storage/projects/live_healthy_learn/` (mirrors `live_healthy_vitals/`)
```
app/                 Flutter app
  lib/core/content/  content model: disease, section, block, reference (pure Dart)
  lib/services/      content_repository (bundled + downloaded), update_service
  lib/screens/       onboarding, home, disease, section, references, settings
  assets/content/    bundled JSON (generated by the script, not hand-edited)
  assets/graphics/   SVGs
  test/              unit + widget tests
  integration_test/  on-device journey + Play screenshots
content/             ★ SOURCE OF TRUTH: one JSON file per disease, edited by hand
firebase/            firestore.rules for the Learn project + rules tests
website/             learn-privacy-policy.html, learn-terms-and-conditions.html
store/               Play listing text + graphics
scripts/             publish_content.py, make_icons.py, build_website.py, backup.sh, run_e2e.sh
secrets/             release keystore + Firebase admin key (gitignored, never committed)
docs/                design-v1.md (this file), prelaunch_review.md
```

### The simple picture
```
  content/*.json  (you edit these, in Git)
          │
          │  scripts/publish_content.py  →  validate → copy → (optional) upload
          ▼                                         ▼
  app/assets/content/  (ships in app)      Firestore: livehealthy-learn project
          │                                         │ checked at most once a day
          ▼                                         ▼ when online
        ┌──────────────── LiveHealthy Learn app ───────────────┐
        │ Shows the newest valid copy: downloaded if present,   │
        │ otherwise bundled. Always works offline.              │
        └───────────────────────────────────────────────────────┘
```

- **Frontend:** the Flutter app.
- **Backend:** Firestore only. No custom server, no login, no user data.

### Firebase project (D3): separate project `livehealthy-learn`
Medicine Reminder and Vitals share `live-healthy-medreminder` because they share a login. Learn has no login, so it doesn't need that project. Three reasons it shouldn't use it:

1. **Patient data safety.** The publish script needs an admin key. An admin key for the shared project can read every patient's medicines and vitals. A Learn-only key can read only public health text.
2. **The shared rules file is already fragile.** The Vitals README warns that `firestore.rules` must be kept identical in two repos, or a deploy from one wipes the other's rules. Adding a third repo triples that risk.
3. **Nothing is lost.** Cross-linking uses Android package names, not Firebase.

---

## 7. Firestore Integration — LOCKED

### Structure
```
learn_manifest/current
    contentVersion: 7
    minAppVersion: 1
    diseases: { hypertension: 3, prediabetes: 1, type2_diabetes: 2, gestational_diabetes: 1, obesity: 2 }
    groups: { diabetes: { order, title{en,ur}, members: [prediabetes, type2_diabetes, gestational_diabetes] } }
    toolLinks: { vitals: "live" | "comingSoon" | "hidden",
                 medicineReminder: "live" | "comingSoon" | "hidden" }
    updatedAt

learn_diseases/{diseaseId}      hypertension, obesity, prediabetes, type2_diabetes, gestational_diabetes
    group: "diabetes" | null        ← topics sharing a Home card
    version, order, status: "published"
    title {en, ur}, summary {en, ur}, iconAsset
    reviewedBy, reviewedOn, nextReviewDue
    sections: [ {id, type, title{en,ur}, blocks:[...]} ... ]
    references: [ {id, org, title, year, url, checkedOn} ... ]
    relatedTools: ["vitals", "medicineReminder"]
```
There's one document per disease, roughly 30–80 KB against Firestore's 1 MB limit.

### How the app updates (once a day at most, online only)
1. Read `learn_manifest/current` (1 read).
2. Compare each disease's version with the copy on the phone.
3. Download only the changed diseases.
4. Validate each one. If anything is wrong, keep the old copy.
5. Save the new copy on the phone and use it from then on, including offline.

**Cost:** about 1–4 reads per user per day, against a free tier of 50,000 reads a day.

**Graphics ship inside the app.** Text, numbers and references update over the air. A new graphic needs an app update, which avoids needing Firebase Storage.

### Security rules
```
match /learn_manifest/{doc}  { allow read: if true;  allow write: if false; }
match /learn_diseases/{doc}  { allow read: if true;  allow write: if false; }
match /{everything=**}       { allow read, write: if false; }
```
Only the publish script (admin key in `secrets/`) can write. Rules tests run on the emulator, as in Vitals.

### Publish script (`scripts/publish_content.py`)
1. **Validate:** both languages present; every section has at least one reference; every `refMarker` resolves; review date not expired; key numbers match Vitals' `reference_ranges.dart`.
2. **Bump versions** of changed diseases and the manifest.
3. **Copy** to `app/assets/content/`.
4. **Upload** only with `--publish`. A dry run is the default.

---

## 8. Design Continuity with LiveHealthy — LOCKED (values taken from the code)

**Base:** copy **Vitals' `core/theme/app_theme.dart`**, not Medicine Reminder's. Vitals' version contains the fixes for two real bugs from its prelaunch review: the Material 3 text-scaling crash and invisible white-on-white text.

| Element | Value (from Vitals code) |
|---|---|
| Primary colour | `#0B6E4F` (calm green, whole suite) |
| Background | `#F7F9F8` |
| Cards | white, 16 radius, border `#E2E8E5`, no shadow |
| Buttons | 56 high, 14 radius, 18pt semibold |
| Text scale | ×1.1 of Material 3 defaults |
| Green / amber / red (normal / caution / alert) | `#1B7F3B` / `#B26A00` / `#C62828`, always with a text label, never colour alone |
| Language | Same switch and `Locale` handling as Vitals `main.dart`; Urdu = right-to-left |
| Wording | "Above typical range" style. Describes, never diagnoses. |
| Website | Pages on `livehealthy.homilabs.org`, flat at the site root (as Vitals learned). Add a Learn card to the shared `index.html`. |
| Backup | Same `scripts/backup.sh` pattern (local + Google Drive, secrets excluded from Drive) |

**Later (hook):** move the theme into one shared `livehealthy_theme` package so the three apps can't drift apart.

---

## 9. Cross-Linking — LOCKED

| Disease | "Track it" links to |
|---|---|
| Hypertension | Vitals (BP) · Medicine Reminder |
| Diabetes | Vitals (glucose) · Medicine Reminder |
| Obesity | Vitals (weight + BMI) |

| App | Package ID (from code) |
|---|---|
| Medicine Reminder | `com.homilabs.medicine_reminder` |
| Vitals | `com.homilabs.livehealthy_vitals` |

**How it works:**
- If the app is installed, the button opens it. If not, it opens its Play Store page.
- If it isn't on Play yet, the Firestore `toolLinks` switch shows "Coming soon" or hides the button. Flip the switch when it launches, with no Learn update needed.
- Both package names go in Learn's `<queries>` manifest block, which Android 11+ requires. Both existing apps already use a `<queries>` block, so this follows the same pattern.

**Not in V1 (flagged scope):** Medicine Reminder and Vitals linking *back* to Learn. That would change those apps, so it's a separate decision.

---

## 10. Screens — LOCKED

### Screen map
```
First launch ─► S1 Language + Disclaimer ─► S2 Home ─► (S2b Topic group, for Diabetes)
                                              │
                          ┌───────────────────┼──────────────┐
                          ▼                                  ▼
                   S3 Disease page                    S7 Settings/About
                          │
            ┌─────────────┼──────────────┐
            ▼             ▼              ▼
     S4 Section reader  S5 References  "Track it" (opens other app)
```

### S1 — Language & Disclaimer (first launch only)
```
┌──────────────────────────┐
│      LiveHealthy Learn   │
│  [   اردو   ] [ English ] │
│                          │
│  This app gives general  │
│  health information. It  │
│  does not diagnose...    │
│   [   I understand   ]   │
└──────────────────────────┘
```

### S2 — Home
```
┌──────────────────────────┐
│ LiveHealthy Learn     ⚙  │
│──────────────────────────│
│ ┌──────────────────────┐ │
│ │ High Blood Pressure   │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │ Diabetes              │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │ Obesity               │ │
│ └──────────────────────┘ │
│  More topics coming soon │
└──────────────────────────┘
```

### S2b — Topic group (e.g. Diabetes)
```
┌──────────────────────────┐
│ ←  Diabetes              │
│──────────────────────────│
│ ┌──────────────────────┐ │
│ │ Prediabetes           │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │ Type 2 Diabetes       │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │ Diabetes in Pregnancy │ │
│ │ (Gestational)         │ │
│ └──────────────────────┘ │
│ Type 1 and rare types    │
│ are not covered here.    │
└──────────────────────────┘
```
Each card opens the normal S3 disease page. Home keeps three cards: Hypertension, Diabetes, Obesity.

### S3 — Disease page
```
┌──────────────────────────┐
│ ←  High Blood Pressure   │
│ [ header graphic ]       │
│ One-line summary         │
│──────────────────────────│
│ 1  What it is          › │
│ 2  Causes & risks      › │
│ 3  Complications       › │
│ 4  Lifestyle changes   › │
│ 5  When to see doctor  › │  ← red/amber accent
│ 6  References          › │
│──────────────────────────│
│ [ Track your BP  → ]     │
│ Reviewed by … on …       │
└──────────────────────────┘
```

### S4 — Section reader
```
┌──────────────────────────┐
│ ←  Complications     3/6 │
│ [ graphic ]              │
│ Heart — text ...  [1]    │
│ ┌ Key number ──────────┐ │
│ │ Normal: below 120/80  │ │
│ └──────────────────────┘ │
│ [ ‹ Previous ] [ Next › ]│
└──────────────────────────┘
```
Tapping [1] opens a small panel with the reference and an "Open source" button.

### S5 — References
Organisation, title, year and "Open" for each. Offline: "Link needs internet", with the citation still visible.

### S7 — Settings / About
Language · Text size (Normal / Large / Extra large) · Disclaimer · Content version + last updated · How sources are chosen · Privacy policy · Terms · Report an error (email) · App version.

---

## 11. Privacy & Data — LOCKED

- **No login, no account, no personal data.** So there's no delete-account page (unlike Vitals).
- **No usage analytics.** Which disease pages someone reads is itself sensitive.
- **Crash reports only** (D4), declared in Play's Data Safety form.
- **Play:** Health apps declaration (health education). Privacy policy and terms at `livehealthy.homilabs.org/learn-privacy-policy.html` and `…/learn-terms-and-conditions.html`, generated by `build_website.py` as for Vitals.

---

## 12. Hooks for Future Development — LOCKED

The structure supports these. **None of them are built in V1.**

| Future feature | Hook in V1 |
|---|---|
| Grouped diseases (arthritis types, cancers, thyroid) | The same `groups` mechanism built for Diabetes; no new screen needed. |
| More diseases | Diseases are data. New disease = JSON + graphics + release; no screen code changes. |
| New content types | Unknown block types are skipped safely; `minAppVersion` protects old versions. |
| Third language | Text stored as `{en, ur}` maps; adding a key adds a language. |
| Read aloud (TTS) | The reader walks blocks in reading order. `flutter_tts` is already proven in Medicine Reminder. |
| Search / bookmarks | Content stored locally as structured JSON. |
| Deep links into Vitals (straight to BP entry) | `relatedTools` entries can carry a target later. |
| Doctor Directory app | `toolLinks.doctorDirectory` switch + a "Find a specialist" slot on S3. |
| New graphics over the air | `image` block has `assetKey`; a later `remoteUrl` field can be added. |
| Shared theme package | Theme lives in one file, ready to extract. |
| "New topic" badge | Manifest `contentVersion` compared on launch. |
| Web version | The same JSON can feed pages on livehealthy.homilabs.org. |
| Low-BP content | Added together with a Vitals low-BP band. |

---

## 13. Build Sequence — LOCKED as the baseline

Build one piece, verify, then move on:

1. **Skeleton + one disease, offline.** Project folder, Vitals theme, S1–S4 for Hypertension from bundled JSON, both languages, RTL. *Verify on the Samsung A12 at 1.3× font. That device found layout bugs in Vitals the emulator missed.*
2. **Content pipeline + topic groups.** Content JSON rules + Python validator (including the Vitals number check, skipped for gestational content). Add the S2b topic-group screen, the three diabetes topics and Obesity. *Verify: the validator rejects a section with no reference.*
3. **References + cross-links.** S5, reference panel, "Track it" with installed / Play / coming-soon behaviour.
4. **Firestore updates.** New `livehealthy-learn` project, rules + rules tests, publish script, in-app update check. *Verify: change a sentence, publish, and see it on the phone without a reinstall. Airplane mode still works.*
5. **Polish + release prep.** Settings/About, website pages, icons, store listing, release build, `prelaunch_review.md` in the Vitals format.

**Parallel track (the real bottleneck):** writing and reviewing the content itself.

---

## 14. Suite Observations (outside Learn's scope, flagged for later)

Found while reading the code. **These are not changes to Learn.** They're noted so they don't get lost:

- **Name.** Settled as the name in the code (D11): Learn's button says **"LiveHealthy Medicine Reminder"**, from the pubspec. Still open at suite level: that app's launcher label on the phone is only "LiveHealthy", which could be confused with the suite name once three apps are installed.
- The Vitals prelaunch review lists open owner items: deploy the shared Firestore rules, and add the cascade in Medicine Reminder's account deletion so it also removes vitals data.

---

## 15. Decision Record

| # | Decision | Outcome |
|---|---|---|
| D1 | BMI cut-offs | **LOCKED:** standard table (matches Vitals) + labelled note on WHO lower Asian action points in the Obesity module. Vitals flags revisited separately. |
| D2 | BP guideline note | **LOCKED:** AHA/ACC numbers; one footnote naming NICE's 140/90. |
| D3 | Firebase project | **LOCKED:** separate project `livehealthy-learn`. |
| D4 | Crash reports / analytics | **LOCKED:** Crashlytics on, analytics off. |
| D5 | Read aloud | **LOCKED:** deferred to V1.1. |
| D6 | Graphics tool | **LOCKED:** Inkscape, on Hadi's PC. Access to be granted before the project starts. |
| D7 | Signing key | **LOCKED:** own key `livehealthy-learn-release.jks`. |
| D8 | Diabetes scope | **LOCKED:** prediabetes, Type 2 diabetes, gestational diabetes. Not covered: Type 1, MODY, LADA, other rare types. |
| D9 | Build sequence | **LOCKED as the baseline** (§13). Adjustable as needed, but any change is raised and confirmed first, not made silently. |
| D10 | Urdu font | **LOCKED:** bundle Noto Nastaliq Urdu in Learn; later share with the other apps via the theme package. |
| D11 | Medicine Reminder name | **LOCKED:** go with the code. Button label "LiveHealthy Medicine Reminder". |
| D13 | How the three diabetes topics are shown | **LOCKED:** one Diabetes card on Home, opening a topic-group screen (S2b) with Prediabetes, Type 2 Diabetes and Gestational Diabetes; each uses the standard seven sections. The group mechanism is reusable for future grouped diseases. |
| D12 | Folder + repo | **LOCKED:** folder `live_healthy_learn/` (already exists, holding `docs/design-v1.md`); Git repo created by you before the build starts. |

---

*This document is the build reference. Changes go through discussion and confirmation first.*
