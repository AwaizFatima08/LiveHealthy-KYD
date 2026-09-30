import 'package:flutter/material.dart';

import '../content/models.dart';

/// Copied from LiveHealthy: Vitals (design §8), including its fixes for the
/// Material 3 text-scaling crash and invisible white-on-white text. Reading
/// is this app's main job, so Urdu gets Noto Nastaliq with extra line
/// spacing, which Nastaliq's tall letters need (D10).
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0B6E4F);
  static const Color background = Color(0xFFF7F9F8);
  static const Color cardBorder = Color(0xFFE2E8E5);

  // Same flag colours as Vitals, always paired with a text label — colour is
  // never the only signal.
  static const Color flagNormal = Color(0xFF1B7F3B);
  static const Color flagCaution = Color(0xFFB26A00);
  static const Color flagAlert = Color(0xFFC62828);

  /// #B26A00 is 4.2:1 against white — fine for borders, tints and large
  /// type, too light for small text. Amber *text* (and white text on an
  /// amber band) uses this darker shade, which is 6.3:1.
  static const Color flagCautionText = Color(0xFF8A5300);

  static const String urduFont = 'NotoNastaliqUrdu';

  static Color keyLevelColor(KeyLevel level) => switch (level) {
    KeyLevel.normal => flagNormal,
    KeyLevel.caution => flagCaution,
    KeyLevel.alert => flagAlert,
    KeyLevel.neutral => primary,
  };

  static Color alertColor(AlertLevel level) => switch (level) {
    AlertLevel.urgent => flagAlert,
    AlertLevel.soon => flagCaution,
  };

  /// Readable text colour for a level: amber text is darkened (see above).
  static Color keyLevelTextColor(KeyLevel level) => level == KeyLevel.caution ? flagCautionText : keyLevelColor(level);

  static Color alertTextColor(AlertLevel level) => level == AlertLevel.soon ? flagCautionText : flagAlert;

  static ThemeData light({String languageCode = 'en'}) {
    final urdu = languageCode == 'ur';
    // Build a complete text theme (colours from `black`, sizes from the
    // `englishLike` geometry) and scale that. ThemeData.textTheme alone has
    // null sizes under Material 3, and the geometry alone has no colours —
    // passing either one scaled breaks (assertion / invisible text).
    final scheme = ColorScheme.fromSeed(seedColor: primary);
    final typography = Typography.material2021(colorScheme: scheme);
    var textTheme = typography.black
        .merge(typography.englishLike)
        .apply(fontSizeFactor: 1.1, bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    if (urdu) {
      // Nastaliq reads small at the same point size and its letters stack
      // high and low, so it's a little larger with generous line height.
      textTheme = textTheme.apply(fontFamily: urduFont, fontSizeFactor: 1.05);
      // Even leading keeps the extra space balanced above and below, so
      // descenders never reach into the next widget.
      TextStyle? roomy(TextStyle? t, double h) =>
          t?.copyWith(height: h, leadingDistribution: TextLeadingDistribution.even);
      textTheme = textTheme.copyWith(
        bodyLarge: roomy(textTheme.bodyLarge, 2.0),
        bodyMedium: roomy(textTheme.bodyMedium, 2.0),
        bodySmall: roomy(textTheme.bodySmall, 2.0),
        titleLarge: roomy(textTheme.titleLarge, 1.9),
        titleMedium: roomy(textTheme.titleMedium, 1.9),
        titleSmall: roomy(textTheme.titleSmall, 1.9),
        headlineSmall: roomy(textTheme.headlineSmall, 1.9),
        labelLarge: roomy(textTheme.labelLarge, 1.8),
      );
    } else {
      textTheme = textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      );
    }
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: urdu ? urduFont : null,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        toolbarHeight: urdu ? 68 : 56,
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: urdu ? urduFont : null),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: TextStyle(fontSize: 17, fontFamily: urdu ? urduFont : null),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cardBorder),
        ),
      ),
    );
  }
}
