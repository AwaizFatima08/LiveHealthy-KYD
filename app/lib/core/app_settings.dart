import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reader-chosen text size, on top of the phone's own font setting (S7).
enum TextSize {
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  final double factor;
  const TextSize(this.factor);
}

/// Language, text size and "disclaimer accepted", kept on the phone only.
/// There's no account, so nothing here ever leaves the device.
class AppSettings extends ChangeNotifier {
  final SharedPreferences prefs;

  AppSettings(this.prefs);

  static const _languageKey = 'language';
  static const _textSizeKey = 'textSize';
  static const _disclaimerKey = 'disclaimerAccepted';

  /// 'en' until the reader picks; the first screen offers the choice.
  String get languageCode => prefs.getString(_languageKey) ?? 'en';

  bool get isUrdu => languageCode == 'ur';

  TextSize get textSize {
    final name = prefs.getString(_textSizeKey);
    return TextSize.values.firstWhere((t) => t.name == name, orElse: () => TextSize.normal);
  }

  bool get disclaimerAccepted => prefs.getBool(_disclaimerKey) ?? false;

  Future<void> setLanguage(String code) async {
    await prefs.setString(_languageKey, code);
    notifyListeners();
  }

  Future<void> setTextSize(TextSize size) async {
    await prefs.setString(_textSizeKey, size.name);
    notifyListeners();
  }

  Future<void> acceptDisclaimer() async {
    await prefs.setBool(_disclaimerKey, true);
    notifyListeners();
  }
}
