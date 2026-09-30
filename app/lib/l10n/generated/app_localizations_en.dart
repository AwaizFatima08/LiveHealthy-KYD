// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Know Your Disease';

  @override
  String get appFullName => 'LiveHealthy: Know Your Disease';

  @override
  String get appTagline =>
      'Plain facts about common diseases, from trusted medical sources.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get disclaimerTitle => 'Before you start';

  @override
  String get disclaimerText =>
      'This app provides general health information only. It does not diagnose or treat. Always consult a qualified doctor.';

  @override
  String get disclaimerEmergency =>
      'In an emergency, go to the nearest hospital straight away.';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get homeIntro => 'Choose a topic to read about.';

  @override
  String get moreTopicsSoon => 'More topics coming soon';

  @override
  String topicsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count topics',
      one: '1 topic',
    );
    return '$_temp0';
  }

  @override
  String get settings => 'Settings';

  @override
  String sectionProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get backToTopic => 'Back to topic';

  @override
  String get references => 'References';

  @override
  String get referencesIntro =>
      'Every fact in this topic comes from these sources.';

  @override
  String get trackIt => 'Track it';

  @override
  String get trackItIntro => 'Keep a record with another free LiveHealthy app.';

  @override
  String openApp(String app) {
    return 'Open $app';
  }

  @override
  String getOnPlay(String app) {
    return 'Get $app';
  }

  @override
  String comingSoonApp(String app) {
    return '$app — coming soon';
  }

  @override
  String get appNameVitals => 'LiveHealthy: Vitals';

  @override
  String get appNameMedicineReminder => 'LiveHealthy: Medicine Reminder';

  @override
  String get couldNotOpen =>
      'Couldn\'t open it. Check your internet connection and try again.';

  @override
  String reviewedBy(String name) {
    return 'Medically reviewed by $name';
  }

  @override
  String reviewDates(String reviewed, String next) {
    return 'Reviewed on $reviewed · Next review $next';
  }

  @override
  String get source => 'Source';

  @override
  String get openSource => 'Open source';

  @override
  String get linkNeedsInternet => 'Opens in your browser · needs internet';

  @override
  String linkChecked(String date) {
    return 'Link checked $date';
  }

  @override
  String referenceNumber(int number) {
    return 'Reference $number';
  }

  @override
  String get urgentLabel => 'Urgent: go to hospital now';

  @override
  String get soonLabel => 'See your doctor soon';

  @override
  String get language => 'Language';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get textSizePreview => 'This is how reading text will look.';

  @override
  String get about => 'About';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get contentSection => 'Content';

  @override
  String contentVersion(int version) {
    return 'Content version $version';
  }

  @override
  String lastChecked(String date) {
    return 'Last checked for updates: $date';
  }

  @override
  String get neverChecked => 'Not checked for updates yet';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checking => 'Checking…';

  @override
  String get updateUpToDate => 'You have the latest content.';

  @override
  String get updateDone => 'Content updated.';

  @override
  String get updateFailed => 'Couldn\'t check. You can keep reading offline.';

  @override
  String get updateNeedsApp =>
      'New content needs a newer version of the app. Please update it from Google Play.';

  @override
  String get howSourcesChosen => 'How sources are chosen';

  @override
  String get howSourcesChosenText =>
      'Every section cites at least one source. We use guideline bodies first: the World Health Organization (WHO), NICE (UK), the American Heart Association and American College of Cardiology (AHA/ACC), and the American Diabetes Association (ADA). Mayo Clinic and Cleveland Clinic are used for plain-language explanations. Each topic is reviewed by a doctor at least once a year, and the Urdu is checked by a second reader. The numbers match the ranges used in LiveHealthy: Vitals.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get terms => 'Terms and conditions';

  @override
  String get reportError => 'Report an error in the content';

  @override
  String get reportErrorSubject => 'Know Your Disease: content error';

  @override
  String reportErrorBody(String version, int content) {
    return 'Topic / section:\n\nWhat is wrong:\n\n(App $version, content $content)';
  }

  @override
  String appVersion(String version) {
    return 'App version $version';
  }

  @override
  String get privacyNote =>
      'No account, no ads, no tracking of what you read. Only anonymous crash reports are sent, to help fix bugs.';

  @override
  String get close => 'Close';

  @override
  String get contentUnavailable =>
      'This topic couldn\'t be loaded. Please reinstall or update the app.';
}
