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
      textTheme = textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 2.0),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 2.0),
        bodySmall: textTheme.bodySmall?.copyWith(height: 1.9),
        titleLarge: textTheme.titleLarge?.copyWith(height: 1.8),
        titleMedium: textTheme.titleMedium?.copyWith(height: 1.8),
        titleSmall: textTheme.titleSmall?.copyWith(height: 1.8),
        headlineSmall: textTheme.headlineSmall?.copyWith(height: 1.7),
        labelLarge: textTheme.labelLarge?.copyWith(height: 1.6),
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
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
