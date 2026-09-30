import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/content/models.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'content_text.dart';

/// Renders one content block. The reader walks blocks in order, which is
/// also the order a future read-aloud feature would use (§12).
class BlockView extends StatelessWidget {
  final Disease disease;
  final ContentBlock block;

  const BlockView({super.key, required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    final b = block;
    return switch (b) {
      ParagraphBlock() => _Paragraph(disease: disease, block: b),
      BulletsBlock() => _Bullets(disease: disease, block: b),
      ImageBlock() => _Image(disease: disease, block: b),
      KeyNumberBlock() => _KeyNumber(disease: disease, block: b),
      AlertBlock() => _Alert(disease: disease, block: b),
      RefMarkerBlock() => RefMarkers(disease: disease, refs: b.refs),
    };
  }
}

class _Paragraph extends StatelessWidget {
  final Disease disease;
  final ParagraphBlock block;
  const _Paragraph({required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(block.text.tr(context), style: Theme.of(context).textTheme.bodyLarge),
        if (block.refs.isNotEmpty) ...[
          const SizedBox(height: 6),
          RefMarkers(disease: disease, refs: block.refs),
        ],
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<LocalizedText> items;
  final Color dotColor;
  const _BulletList({required this.items, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final lineHeight = (style?.fontSize ?? 16) * (style?.height ?? 1.4) * MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: lineHeight,
                  width: 22,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.tr(context), style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  final Disease disease;
  final BulletsBlock block;
  const _Bullets({required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title != null) ...[
          Text(block.title!.tr(context), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
        ],
        _BulletList(items: block.items, dotColor: theme.colorScheme.primary),
        if (block.refs.isNotEmpty) RefMarkers(disease: disease, refs: block.refs),
      ],
    );
  }
}

/// A language-free graphic with a caption in the reader's language.
/// Graphics ship inside the app; an unknown asset key (content newer than
/// the app) shows just the caption.
class _Image extends StatelessWidget {
  final Disease disease;
  final ImageBlock block;
  const _Image({required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          padding: const EdgeInsets.all(12),
          child: ContentGraphic(assetKey: block.assetKey, semanticLabel: block.caption.tr(context)),
        ),
        const SizedBox(height: 6),
        Text(
          block.caption.tr(context),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (block.refs.isNotEmpty) ...[
          const SizedBox(height: 4),
          RefMarkers(disease: disease, refs: block.refs),
        ],
      ],
    );
  }
}

/// SVG from assets/graphics/, with a quiet placeholder if it's missing.
class ContentGraphic extends StatelessWidget {
  final String assetKey;
  final String? semanticLabel;
  final double? height;

  const ContentGraphic({super.key, required this.assetKey, this.semanticLabel, this.height});

  @override
  Widget build(BuildContext context) {
    // Graphics are drawn language-free, but always left-to-right.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.asset(
        'assets/graphics/$assetKey',
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: semanticLabel,
        errorBuilder: (context, error, stack) => SizedBox(
          height: height ?? 80,
          child: Icon(Icons.image_not_supported_outlined, color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

class _KeyNumber extends StatelessWidget {
  final Disease disease;
  final KeyNumberBlock block;
  const _KeyNumber({required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.keyLevelColor(block.level);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: BorderDirectional(start: BorderSide(color: color, width: 6)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.label.tr(context),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.keyLevelTextColor(block.level),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            block.value.tr(context),
            style: (Localizations.localeOf(context).languageCode == 'ur'
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
          ),
          if (block.note != null) ...[
            const SizedBox(height: 4),
            Text(block.note!.tr(context), style: theme.textTheme.bodyMedium),
          ],
          if (block.refs.isNotEmpty) ...[
            const SizedBox(height: 6),
            RefMarkers(disease: disease, refs: block.refs),
          ],
        ],
      ),
    );
  }
}

/// Red "go to hospital now" / amber "see your doctor soon" box (§3.5).
/// The level is always spelled out in words, never colour alone.
class _Alert extends StatelessWidget {
  final Disease disease;
  final AlertBlock block;
  const _Alert({required this.disease, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = AppTheme.alertColor(block.level);
    final urgent = block.level == AlertLevel.urgent;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppTheme.alertTextColor(block.level),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Icon(urgent ? Icons.local_hospital : Icons.event_available, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    urgent ? l10n.urgentLabel : l10n.soonLabel,
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block.title.tr(context), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                // Signs first, then what to do about them.
                if (block.items.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _BulletList(items: block.items, dotColor: color),
                ],
                if (block.text != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    block.text!.tr(context),
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
                if (block.refs.isNotEmpty) RefMarkers(disease: disease, refs: block.refs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
