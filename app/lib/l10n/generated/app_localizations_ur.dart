// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'اپنی بیماری کو جانیں';

  @override
  String get appFullName => 'لِو ہیلدی: اپنی بیماری کو جانیں';

  @override
  String get appTagline =>
      'عام بیماریوں کے بارے میں سیدھی سادی معلومات، معتبر طبی ذرائع سے۔';

  @override
  String get chooseLanguage => 'اپنی زبان منتخب کریں';

  @override
  String get disclaimerTitle => 'شروع کرنے سے پہلے';

  @override
  String get disclaimerText =>
      'یہ ایپ صرف عام صحت کی معلومات دیتی ہے۔ یہ نہ بیماری کی تشخیص کرتی ہے اور نہ علاج۔ ہمیشہ کسی مستند ڈاکٹر سے مشورہ کریں۔';

  @override
  String get disclaimerEmergency =>
      'ایمرجنسی کی صورت میں فوراً قریبی ہسپتال جائیں۔';

  @override
  String get iUnderstand => 'میں سمجھ گیا/گئی';

  @override
  String get homeIntro => 'پڑھنے کے لیے کوئی موضوع منتخب کریں۔';

  @override
  String get moreTopicsSoon => 'مزید موضوعات جلد آ رہے ہیں';

  @override
  String topicsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موضوعات',
      one: '1 موضوع',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'سیٹنگز';

  @override
  String sectionProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get previous => 'پچھلا';

  @override
  String get next => 'اگلا';

  @override
  String get backToTopic => 'موضوع پر واپس';

  @override
  String get references => 'حوالہ جات';

  @override
  String get referencesIntro => 'اس موضوع کی ہر بات ان ذرائع سے لی گئی ہے۔';

  @override
  String get trackIt => 'ریکارڈ رکھیں';

  @override
  String get trackItIntro =>
      'لِو ہیلدی کی ایک اور مفت ایپ میں اپنا ریکارڈ رکھیں۔';

  @override
  String openApp(String app) {
    return '$app کھولیں';
  }

  @override
  String getOnPlay(String app) {
    return '$app حاصل کریں';
  }

  @override
  String comingSoonApp(String app) {
    return '$app — جلد آ رہی ہے';
  }

  @override
  String get appNameVitals => 'لِو ہیلدی: وائٹلز';

  @override
  String get appNameMedicineReminder => 'لِو ہیلدی: میڈیسن ریمائنڈر';

  @override
  String get couldNotOpen =>
      'یہ نہیں کھل سکا۔ اپنا انٹرنیٹ کنکشن چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String reviewedBy(String name) {
    return 'طبی جائزہ: $name';
  }

  @override
  String reviewDates(String reviewed, String next) {
    return 'جائزے کی تاریخ $reviewed · اگلا جائزہ $next';
  }

  @override
  String get source => 'ماخذ';

  @override
  String get openSource => 'ماخذ کھولیں';

  @override
  String get linkNeedsInternet => 'براؤزر میں کھلے گا · انٹرنیٹ درکار ہے';

  @override
  String linkChecked(String date) {
    return 'لنک کی جانچ $date';
  }

  @override
  String referenceNumber(int number) {
    return 'حوالہ $number';
  }

  @override
  String get urgentLabel => 'فوری: ابھی ہسپتال جائیں';

  @override
  String get soonLabel => 'جلد اپنے ڈاکٹر سے ملیں';

  @override
  String get language => 'زبان';

  @override
  String get textSize => 'تحریر کا سائز';

  @override
  String get textSizeNormal => 'عام';

  @override
  String get textSizeLarge => 'بڑا';

  @override
  String get textSizeExtraLarge => 'بہت بڑا';

  @override
  String get textSizePreview => 'پڑھنے والی تحریر ایسی نظر آئے گی۔';

  @override
  String get about => 'ایپ کے بارے میں';

  @override
  String get disclaimer => 'اعلانِ لاتعلقی';

  @override
  String get contentSection => 'مواد';

  @override
  String contentVersion(int version) {
    return 'مواد کا ورژن $version';
  }

  @override
  String lastChecked(String date) {
    return 'اپڈیٹ کی آخری جانچ: $date';
  }

  @override
  String get neverChecked => 'ابھی تک اپڈیٹ چیک نہیں ہوئی';

  @override
  String get checkForUpdates => 'اپڈیٹ چیک کریں';

  @override
  String get checking => 'چیک ہو رہا ہے…';

  @override
  String get updateUpToDate => 'آپ کے پاس تازہ ترین مواد موجود ہے۔';

  @override
  String get updateDone => 'مواد اپڈیٹ ہو گیا۔';

  @override
  String get updateFailed =>
      'چیک نہیں ہو سکا۔ آپ آف لائن پڑھنا جاری رکھ سکتے ہیں۔';

  @override
  String get updateNeedsApp =>
      'نئے مواد کے لیے ایپ کا نیا ورژن درکار ہے۔ براہِ کرم گوگل پلے سے ایپ اپڈیٹ کریں۔';

  @override
  String get howSourcesChosen => 'ذرائع کیسے چنے جاتے ہیں';

  @override
  String get howSourcesChosenText =>
      'ہر حصے میں کم از کم ایک ماخذ کا حوالہ دیا جاتا ہے۔ ہم پہلے رہنما طبی اداروں کو ترجیح دیتے ہیں: عالمی ادارۂ صحت (WHO)، برطانیہ کا NICE، امریکن ہارٹ ایسوسی ایشن اور امریکن کالج آف کارڈیالوجی (AHA/ACC)، اور امریکن ذیابیطس ایسوسی ایشن (ADA)۔ آسان زبان میں وضاحت کے لیے میو کلینک اور کلیولینڈ کلینک سے مدد لی جاتی ہے۔ ہر موضوع کا کم از کم سال میں ایک بار ڈاکٹر جائزہ لیتا ہے، اور اردو کی جانچ ایک دوسرا فرد کرتا ہے۔ تمام اعداد و شمار لِو ہیلدی: وائٹلز میں استعمال ہونے والی حدوں کے مطابق ہیں۔';

  @override
  String get privacyPolicy => 'پرائیویسی پالیسی';

  @override
  String get terms => 'شرائط و ضوابط';

  @override
  String get reportError => 'مواد میں غلطی کی نشاندہی کریں';

  @override
  String get reportErrorSubject => 'Know Your Disease: content error';

  @override
  String reportErrorBody(String version, int content) {
    return 'موضوع / حصہ:\n\nکیا غلط ہے:\n\n(App $version, content $content)';
  }

  @override
  String appVersion(String version) {
    return 'ایپ ورژن $version';
  }

  @override
  String get privacyNote =>
      'نہ کوئی اکاؤنٹ، نہ اشتہارات، نہ یہ ریکارڈ کہ آپ کیا پڑھتے ہیں۔ صرف گمنام کریش رپورٹس بھیجی جاتی ہیں تاکہ خرابیاں دور کی جا سکیں۔';

  @override
  String get close => 'بند کریں';

  @override
  String get contentUnavailable =>
      'یہ موضوع لوڈ نہیں ہو سکا۔ براہِ کرم ایپ دوبارہ انسٹال یا اپڈیٹ کریں۔';
}
