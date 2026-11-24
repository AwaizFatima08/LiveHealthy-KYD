# Know Your Disease 1.2 — Design (upgrade to design-v1.md)

**Status:** decisions agreed by Homi on 24 Nov 2026 ("all suggestions agreed"). Branch `release/1.2`.
Everything in design-v1.md still applies unless a section below changes it.

## 1. Scope

| # | Item | Decision |
|---|---|---|
| U1 | New topics | **Heart attack & coronary heart disease**, **Stroke**, and a **Hepatitis** group with **Hepatitis B** and **Hepatitis C** (4 topic files, 12 home items in total) |
| U2 | Treatment section | New optional section `treatment`, **new topics only** (see §2) |
| U3 | Ads | AdMob banner on Home and Settings only, with Google's consent message (built on `feature/admob`, merged here; release checklist in prelaunch_review.md) |
| U4 | Links between topics | New `topicLink` content block (§3) |
| U5 | "New" badge | On Home cards for topics added since the reader last opened the app (§4) |
| U6 | Read aloud | The phone's own text-to-speech voice (§5). Recorded narration (Kokoro / VoxCPM2 on homidev) moves to 1.3 |
| U7 | "Track it" Play links | Switch `toolLinks` to `live`; needs `secrets/firebase-admin-service-account.json` (owner) |

Later (1.3): kidney disease, Lungs group (asthma, COPD), Thyroid group, Home categories and search,
website topic pages, continue reading and share, recorded narration. After that: anaemia, fatty
liver, PCOS, low BP; depression and anxiety with a doctor shaping the wording.

## 2. Treatment section (U2)

- Section ids become: `whatIs, causes, complications, [treatment], lifestyle, whenToSeeDoctor`.
  `treatment` is optional and sits after complications. The reader counts it (n/7 instead of n/6).
- **General only**, in line with design-v1 §1 ("never tells a user which medicine to take"): the kinds
  of treatment that exist and what they do, that treatment is decided with a doctor, and "don't stop a
  medicine without asking your doctor". **No doses, no brand names, no "take X".** Every claim cited,
  as for every other section.
- Where it helps, a "Track it" link to LiveHealthy: Medicine Reminder.
- **The existing eight topics keep their five sections.** Apps 1.0 and 1.1 accept exactly five
  sections, so a topic with a treatment section is rejected there: the old app keeps its previous copy
  and simply never shows the new topic (checked in `update_service.dart`). That is acceptable for new
  topics but would block corrections to existing ones.

## 3. Links between topics (U4)

Block `{"type": "topicLink", "target": "<topic id>", "text": {"en", "ur"}}`, shown as a tappable card
("Read more: Stroke") that opens that topic. The validator checks that the target exists. Older apps
skip unknown block types, so links can be added to existing topics too (e.g. high BP → heart attack,
stroke; diabetes → heart attack; obesity → heart attack).

## 4. "New" badge (U5)

The app stores the topic ids the reader has already seen. A card shows "New" for an id not in that set
until the topic is opened. On a fresh install every topic is marked seen, so nothing is "new".

## 5. Read aloud (U6)

- A speaker button in each section's app bar reads that section's text in reading order (headings,
  paragraphs, bullets, key numbers, alerts, captions; reference markers skipped). Stop with the same
  button; leaving the screen stops it.
- Voice: the phone's text-to-speech in the app language (`en` / `ur`). If the phone has no voice for
  that language, the button explains that and offers the phone's speech settings. No audio is bundled.
- Package `flutter_tts` (proven in Medicine Reminder).

## 6. New-topic content plan (U1)

| Topic | Sections | Graphics (SVG, code) | Animation (Lottie, homi-nas) | Main sources |
|---|---|---|---|---|
| Heart attack & coronary heart disease | 6 (with treatment) | header; heart attack warning signs; how an artery blocks | — (reuses nothing; artery animation stays with cholesterol) | WHO CVD fact sheet, NHS heart attack / CHD, AHA warning signs, NICE CG181 / NG185 |
| Stroke | 6 (with treatment) | header; FAST still (fallback and Urdu-friendly); stroke types | **FAST** (face, arm, speech, time → call 1122), needs Homi's approval | WHO stroke, NHS stroke, AHA/ASA BE FAST, NICE NG128 |
| Hepatitis B | 6 (with treatment) | header; how it spreads / doesn't; vaccine schedule (no doses) | — | WHO hepatitis B fact sheet, CDC, NHS, Pakistan EPI |
| Hepatitis C | 6 (with treatment) | header; test → treat → cured | — | WHO hepatitis C fact sheet & Pakistan elimination programme, NHS, CDC |

- Group "Hepatitis" (`hepatitis_group_header.svg`), like Diabetes.
- Key numbers are `{"metric": "none"}` unless Vitals tracks them (BP targets in heart/stroke reuse the
  hypertension numbers and the Vitals check).
- Red alerts: heart attack and stroke signs → "Call Rescue 1122 now". Hepatitis: jaundice, vomiting
  blood, confusion → hospital.
- Every new topic: medical review and Urdu second-reader review by the owner before release.

## 7. Release

Version 1.2.0 (build 3). Before release: the ads checklist, release-check.sh, both phones (A12, Mi 9),
new screenshots (12 topics, a treatment screen, read aloud), listing and website updates.
