# Play Store Listing — LiveHealthy: Know Your Disease

Package: `com.homilabs.livehealthy_kyd` · Version 1.0.0 (1)

## App name (30 chars max)
LiveHealthy: Know Your Disease   (30 characters)

The home-screen label is "Know Your Disease", following the suite convention (Vitals' label is
"Vitals", Medicine Reminder's is "Medicine Reminder").

## Short description (80 chars max)
Plain facts on BP, diabetes & obesity in Urdu/English, with trusted sources.

## Full description
LiveHealthy: Know Your Disease explains common long-term conditions in plain language, in
Urdu or English, with a trusted medical source behind every fact.

**Topics in this version**
• High blood pressure
• Diabetes: prediabetes, type 2 diabetes, and diabetes in pregnancy (gestational)
• Obesity, including BMI and waist size, and the lower BMI action points for South Asian people

**The same clear structure for every topic**
1. What it is
2. Causes and risk factors: what you can change, and what you can't
3. Complications of poor control
4. Lifestyle changes: concrete, practical steps
5. When to see a doctor: red "go to hospital now" and amber "see your doctor soon" warning signs
6. References
Plus "Track it", which opens LiveHealthy: Vitals or LiveHealthy: Medicine Reminder when you want to
keep a record.

**Trusted sources.** Every section cites guideline bodies such as the World Health Organization
(WHO), NICE, the American Heart Association and the American Diabetes Association, with Mayo
Clinic and Cleveland Clinic used for plain-language explanations. Tap any [1] to see the source.
Every topic is reviewed by a doctor, at least once a year.

**Made to be easy to read.** Large text with three size options, simple pictures, and a proper
Urdu Nastaliq font. The numbers are the same as in LiveHealthy: Vitals.

**Works offline.** Everything is inside the app. When you're online, corrections and new topics
download quietly in the background.

**Private by design.** No account, no ads, and no tracking of what you read.

This app gives general health information only. It does not diagnose or treat, and it is not a
substitute for a doctor. In an emergency, go to the nearest hospital.

## Urdu listing (add as a translation: Urdu – ur)
**App name:** LiveHealthy: Know Your Disease
**Short description:** بلڈ پریشر، ذیابیطس اور موٹاپے پر آسان معلومات، معتبر حوالوں کے ساتھ۔
**Full description:**
لِو ہیلدی: اپنی بیماری کو جانیں — عام طویل مدتی بیماریوں کے بارے میں آسان زبان میں معلومات، اردو یا انگریزی میں، اور ہر بات کے پیچھے ایک معتبر طبی ماخذ۔

موضوعات: ہائی بلڈ پریشر · ذیابیطس (پری ذیابیطس، ٹائپ 2، حمل کی ذیابیطس) · موٹاپا

ہر موضوع میں: یہ کیا ہے · وجوہات اور خطرے کے عوامل · پیچیدگیاں · طرزِ زندگی میں تبدیلیاں · ڈاکٹر کو کب دکھائیں · حوالہ جات

عالمی ادارۂ صحت، NICE، امریکن ہارٹ ایسوسی ایشن اور امریکن ذیابیطس ایسوسی ایشن جیسے اداروں کے حوالے۔ ہر موضوع کا سال میں کم از کم ایک بار ڈاکٹر جائزہ لیتا ہے۔
انٹرنیٹ کے بغیر بھی چلتی ہے۔ نہ اکاؤنٹ، نہ اشتہارات، نہ یہ ریکارڈ کہ آپ کیا پڑھتے ہیں۔

یہ ایپ صرف عام صحت کی معلومات دیتی ہے۔ یہ نہ تشخیص کرتی ہے نہ علاج۔ ایمرجنسی میں فوراً قریبی ہسپتال جائیں۔

## Category
Medical

## Contact
- Email: info@homilabs.org
- Website: https://livehealthy.homilabs.org/
- Privacy policy: https://livehealthy.homilabs.org/privacy-policy.html  (shared by the whole family,
  with a Know Your Disease section)

## App access (Play Console → App content → App access)
**All functionality is available without special access.** There is no login, so no review
account is needed.

## Ads
No ads.

## Content rating (IARC questionnaire)
Category: Reference, News, or Educational. No violence, sexual content, profanity, controlled
substances, gambling, user-to-user communication or location sharing. Some content discusses
medical conditions factually. Expected: Everyone / PEGI 3.

## Target audience
18+ (health information for adults). Not a "Designed for Families" app.

## Health apps declaration (Play Console → App content → Health apps)
Tick exactly:
- Medical → **Medical reference and education**

Leave everything else unticked. It is not a medical device, does no diagnosis or clinical
decision support, collects no health data, and doesn't track fitness or nutrition. The "general
information only, not a diagnosis" disclaimer appears on first launch, at the bottom of Home, in
Settings → Disclaimer, and in the terms.

## Data safety form
- Does the app collect or share user data? **Yes, collected** (crash reports only). Shared: **No.**
- Encrypted in transit: **Yes.**
- Can users request deletion? Nothing is linked to a person. Crash reports expire after 90
  days, and uninstalling removes all on-device data.

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| App info and performance → **Crash logs** | Yes | No | App functionality (fixing crashes) | Required |
| App info and performance → **Diagnostics** | Yes | No | App functionality | Required |
| Device or other IDs (Firebase installation ID, used by Crashlytics) | Yes | No | App functionality | Required |

Not collected: personal info, health and fitness, location, contacts, photos, audio, messages,
financial info, web history, app interactions or in-app search, advertising ID.
Data is processed by Google Firebase (Crashlytics, and Firestore for downloading public
articles) as a service provider, which Play does not count as "sharing".

## Permissions (final, from the release APK — see docs/prelaunch_review.md)
| Permission | Why |
|---|---|
| INTERNET | content updates, reference links |
| ACCESS_NETWORK_STATE | added by Firebase (Firestore/Crashlytics) to check connectivity |
| DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION | AndroidX internal, no user-facing access |

No camera, location, contacts, storage, notification or alarm permissions.

## Assets
- Hi-res icon 512×512: `store/graphics/play_store_icon_512.png`
- Feature graphic 1024×500: `store/graphics/feature_graphic.png`
- Phone screenshots 1080×2160 (2:1), upload in order: `store/graphics/phone_screenshots/`
- Sources: `scripts/make_icons.py` (icon and feature graphic), `scripts/make_screenshots.py`
  (framed screenshots from device captures), `scripts/make_graphics.py` (in-app graphics)

## Release notes (v1.0.0)
First release: high blood pressure, diabetes (prediabetes, type 2, gestational) and obesity in
Urdu and English, with sources for every section. Works offline.

اولین ریلیز: ہائی بلڈ پریشر، ذیابیطس اور موٹاپا — اردو اور انگریزی میں، ہر حصے کے حوالوں کے ساتھ۔

## Release artifacts
- Upload to Play Console: `app/build/app/outputs/bundle/release/app-release.aab`
- Direct-install test APK (not for Play): `app/build/app/outputs/flutter-apk/app-release.apk`
- Upload key: `secrets/livehealthy-kyd-release.jks` (alias `livehealthykyd`). This is its own key
  (D7). Enrol in Play App Signing when you create the app, and back the key up offline.
  SHA-256: `06:7F:4F:5C:FF:7E:D9:8A:F9:6D:42:F8:CC:83:58:A1:BD:F0:AE:FD:EE:53:C3:E0:47:30:6C:F0:82:28:C3:C8`
