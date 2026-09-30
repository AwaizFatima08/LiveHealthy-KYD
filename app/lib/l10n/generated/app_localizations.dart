import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Know Your Disease'**
  String get appTitle;

  /// No description provided for @appFullName.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy: Know Your Disease'**
  String get appFullName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Plain facts about common diseases, from trusted medical sources.'**
  String get appTagline;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This app provides general health information only. It does not diagnose or treat. Always consult a qualified doctor.'**
  String get disclaimerText;

  /// No description provided for @disclaimerEmergency.
  ///
  /// In en, this message translates to:
  /// **'In an emergency, go to the nearest hospital straight away.'**
  String get disclaimerEmergency;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic to read about.'**
  String get homeIntro;

  /// No description provided for @moreTopicsSoon.
  ///
  /// In en, this message translates to:
  /// **'More topics coming soon'**
  String get moreTopicsSoon;

  /// No description provided for @topicsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 topic} other{{count} topics}}'**
  String topicsCount(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String sectionProgress(int current, int total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @backToTopic.
  ///
  /// In en, this message translates to:
  /// **'Back to topic'**
  String get backToTopic;

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @referencesIntro.
  ///
  /// In en, this message translates to:
  /// **'Every fact in this topic comes from these sources.'**
  String get referencesIntro;

  /// No description provided for @trackIt.
  ///
  /// In en, this message translates to:
  /// **'Track it'**
  String get trackIt;

  /// No description provided for @trackItIntro.
  ///
  /// In en, this message translates to:
  /// **'Keep a record with another free LiveHealthy app.'**
  String get trackItIntro;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open {app}'**
  String openApp(String app);

  /// No description provided for @getOnPlay.
  ///
  /// In en, this message translates to:
  /// **'Get {app}'**
  String getOnPlay(String app);

  /// No description provided for @comingSoonApp.
  ///
  /// In en, this message translates to:
  /// **'{app} — coming soon'**
  String comingSoonApp(String app);

  /// No description provided for @appNameVitals.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy: Vitals'**
  String get appNameVitals;

  /// No description provided for @appNameMedicineReminder.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy: Medicine Reminder'**
  String get appNameMedicineReminder;

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open it. Check your internet connection and try again.'**
  String get couldNotOpen;

  /// No description provided for @reviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Medically reviewed by {name}'**
  String reviewedBy(String name);

  /// No description provided for @reviewDates.
  ///
  /// In en, this message translates to:
  /// **'Reviewed on {reviewed} · Next review {next}'**
  String reviewDates(String reviewed, String next);

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get openSource;

  /// No description provided for @linkNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Opens in your browser · needs internet'**
  String get linkNeedsInternet;

  /// No description provided for @linkChecked.
  ///
  /// In en, this message translates to:
  /// **'Link checked {date}'**
  String linkChecked(String date);

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference {number}'**
  String referenceNumber(int number);

  /// No description provided for @urgentLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgent: go to hospital now'**
  String get urgentLabel;

  /// No description provided for @soonLabel.
  ///
  /// In en, this message translates to:
  /// **'See your doctor soon'**
  String get soonLabel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textSizeExtraLarge;

  /// No description provided for @textSizePreview.
  ///
  /// In en, this message translates to:
  /// **'This is how reading text will look.'**
  String get textSizePreview;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @contentSection.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentSection;

  /// No description provided for @contentVersion.
  ///
  /// In en, this message translates to:
  /// **'Content version {version}'**
  String contentVersion(int version);

  /// No description provided for @lastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked for updates: {date}'**
  String lastChecked(String date);

  /// No description provided for @neverChecked.
  ///
  /// In en, this message translates to:
  /// **'Not checked for updates yet'**
  String get neverChecked;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest content.'**
  String get updateUpToDate;

  /// No description provided for @updateDone.
  ///
  /// In en, this message translates to:
  /// **'Content updated.'**
  String get updateDone;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check. You can keep reading offline.'**
  String get updateFailed;

  /// No description provided for @updateNeedsApp.
  ///
  /// In en, this message translates to:
  /// **'New content needs a newer version of the app. Please update it from Google Play.'**
  String get updateNeedsApp;

  /// No description provided for @howSourcesChosen.
  ///
  /// In en, this message translates to:
  /// **'How sources are chosen'**
  String get howSourcesChosen;

  /// No description provided for @howSourcesChosenText.
  ///
  /// In en, this message translates to:
  /// **'Every section cites at least one source. We use guideline bodies first: the World Health Organization (WHO), NICE (UK), the American Heart Association and American College of Cardiology (AHA/ACC), and the American Diabetes Association (ADA). Mayo Clinic and Cleveland Clinic are used for plain-language explanations. Each topic is reviewed by a doctor at least once a year, and the Urdu is checked by a second reader. The numbers match the ranges used in LiveHealthy: Vitals.'**
  String get howSourcesChosenText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get terms;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report an error in the content'**
  String get reportError;

  /// No description provided for @reportErrorSubject.
  ///
  /// In en, this message translates to:
  /// **'Know Your Disease: content error'**
  String get reportErrorSubject;

  /// No description provided for @reportErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Topic / section:\n\nWhat is wrong:\n\n(App {version}, content {content})'**
  String reportErrorBody(String version, int content);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version {version}'**
  String appVersion(String version);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no tracking of what you read. Only anonymous crash reports are sent, to help fix bugs.'**
  String get privacyNote;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @contentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This topic couldn\'t be loaded. Please reinstall or update the app.'**
  String get contentUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
