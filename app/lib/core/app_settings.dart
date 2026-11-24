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

  AppSettings(this.prefs) {
    // Updating from 1.0/1.1 (disclaimer already accepted, no list yet): the
    // reader has seen the topics those versions had, so 1.2's topics show
    // "New". A fresh install gets its list on first Home (markAllSeen).
    if (prefs.getStringList(_seenKey) == null && disclaimerAccepted) {
      prefs.setStringList(_seenKey, topicsBefore12.toList());
    }
  }

  static const _languageKey = 'language';
  static const _textSizeKey = 'textSize';
  static const _disclaimerKey = 'disclaimerAccepted';
  static const _seenKey = 'seenTopics';

  /// Topics shipped in versions before 1.2, which had no "New" badge.
  static const topicsBefore12 = {
    'hypertension',
    'prediabetes',
    'type2_diabetes',
    'gestational_diabetes',
    'obesity',
    'high_cholesterol',
    'migraine',
    'breast_cancer',
  };

  /// Topic ids the reader has already seen; null until first Home.
  Set<String>? get seenTopics => prefs.getStringList(_seenKey)?.toSet();

  /// "New" on Home until the topic is opened (design-v1.2 §4).
  bool isNew(String topicId) {
    final seen = seenTopics;
    return seen != null && !seen.contains(topicId);
  }

  /// First Home on a fresh install: everything there is simply "the app".
  Future<void> markAllSeen(Iterable<String> ids) async {
    if (seenTopics != null) return;
    await prefs.setStringList(_seenKey, ids.toSet().toList());
    notifyListeners();
  }

  Future<void> markSeen(String topicId) async {
    final seen = seenTopics;
    if (seen == null || seen.contains(topicId)) return;
    await prefs.setStringList(_seenKey, (seen..add(topicId)).toList());
    notifyListeners();
  }

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
