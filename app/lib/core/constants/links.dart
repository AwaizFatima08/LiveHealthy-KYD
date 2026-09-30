/// Public pages on livehealthy.homilabs.org — the shared site for the whole
/// LiveHealthy family. One privacy policy and one set of terms cover every
/// app; this app has its own section in each. The site's source lives in the
/// Medicine Reminder repo (live_healthy/website/).
class Links {
  Links._();

  static const String site = 'https://livehealthy.homilabs.org/';
  static const String privacyPolicy = 'https://livehealthy.homilabs.org/privacy-policy.html';
  static const String terms = 'https://livehealthy.homilabs.org/terms-and-conditions.html';

  /// "Report an error" in content goes to the medical reviewer's inbox.
  static const String reportEmail = 'info@homilabs.org';

  static String playStore(String packageName) => 'https://play.google.com/store/apps/details?id=$packageName';
}
