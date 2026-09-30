import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_settings.dart';
import '../core/theme/app_theme.dart';
import 'block_view.dart';

/// The app icon, drawn from the bundled asset.
class AppMark extends StatelessWidget {
  final double size;
  const AppMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset('assets/images/app_icon.png', width: size, height: size, excludeFromSemantics: true),
    );
  }
}

/// اردو | English. Each label is shown in its own script and font, whatever
/// the current language.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    Widget option(String code, String label, String? font) {
      final selected = settings.languageCode == code;
      final child = Text(
        label,
        style: TextStyle(fontSize: 20, fontFamily: font, height: font == null ? 1.2 : 1.6, fontWeight: FontWeight.w600),
      );
      return Expanded(
        child: Semantics(
          selected: selected,
          child: selected
              ? FilledButton(key: Key('lang-$code'), onPressed: () => settings.setLanguage(code), child: child)
              : OutlinedButton(
                  key: Key('lang-$code'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: () => settings.setLanguage(code),
                  child: child,
                ),
        ),
      );
    }

    // Fixed order on screen in both directions.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          option('ur', 'اردو', AppTheme.urduFont),
          const SizedBox(width: 12),
          option('en', 'English', 'Roboto'),
        ],
      ),
    );
  }
}

/// A white Home / topic card: graphic, title, summary, chevron.
class TopicCard extends StatelessWidget {
  final String graphic;
  final String title;
  final String summary;
  final String? badge;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.graphic,
    required this.title,
    required this.summary,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // At large text sizes the text needs the full width, so the graphic
    // moves above it instead of beside it.
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.3 || MediaQuery.sizeOf(context).width < 340;
    final thumb = Container(
      width: stacked ? double.infinity : 72,
      height: stacked ? 64 : 72,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(6),
      child: ContentGraphic(assetKey: graphic),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(summary, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (badge != null) ...[
          const SizedBox(height: 4),
          Text(badge!, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        ],
      ],
    );
    final chevron = Icon(Icons.chevron_right, color: theme.colorScheme.primary);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    thumb,
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: text), chevron]),
                  ],
                )
              : Row(
                  children: [
                    thumb,
                    const SizedBox(width: 14),
                    Expanded(child: text),
                    const SizedBox(width: 6),
                    chevron,
                  ],
                ),
        ),
      ),
    );
  }
}
