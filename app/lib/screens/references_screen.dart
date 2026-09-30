import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/content_repository.dart';
import '../widgets/content_text.dart';
import 'disease_screen.dart';
import 'section_screen.dart';

/// S5 — every source for one disease. The citation stays readable offline;
/// only "Open" needs the internet.
class ReferencesScreen extends StatelessWidget {
  final String diseaseId;

  /// Reached with Next from the reader, so show Previous / Back to topic.
  final bool fromReader;

  const ReferencesScreen({super.key, required this.diseaseId, this.fromReader = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final disease = context.watch<ContentRepository>().disease(diseaseId);
    if (disease == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.contentUnavailable)));
    }
    final total = totalSections(disease);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.references),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: Text(
                l10n.sectionProgress(total, total),
                textDirection: TextDirection.ltr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l10n.referencesIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          for (final (i, ref) in disease.references.indexed) ...[
            Card(
              key: Key('ref-${ref.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[${i + 1}]',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReferenceCitation(reference: ref),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(minimumSize: const Size(120, 44)),
                              onPressed: () => openLink(context, ref.url),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text(l10n.openSource),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            l10n.linkNeedsInternet,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: fromReader
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('prev'),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => SectionScreen(diseaseId: diseaseId, index: disease.sections.length - 1),
                          ),
                        ),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(l10n.previous, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('back-to-topic'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.backToTopic, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
