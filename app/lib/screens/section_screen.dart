import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/content_repository.dart';
import '../widgets/block_view.dart';
import '../widgets/content_text.dart';
import 'disease_screen.dart';
import 'references_screen.dart';

/// S4 — reads one section, block by block, with Previous / Next.
/// Next from the last written section goes on to References (6/6).
class SectionScreen extends StatelessWidget {
  final String diseaseId;
  final int index;

  const SectionScreen({super.key, required this.diseaseId, required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final disease = context.watch<ContentRepository>().disease(diseaseId);
    if (disease == null || index >= disease.sections.length) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.contentUnavailable)));
    }
    final section = disease.sections[index];
    final total = totalSections(disease);

    void goTo(int i) {
      final route = i < disease.sections.length
          ? MaterialPageRoute<void>(builder: (_) => SectionScreen(diseaseId: diseaseId, index: i))
          : MaterialPageRoute<void>(builder: (_) => ReferencesScreen(diseaseId: diseaseId, fromReader: true));
      Navigator.of(context).pushReplacement(route);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(section.title.tr(context), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: Text(
                l10n.sectionProgress(index + 1, total),
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
      body: ListView.separated(
        key: const Key('section-body'),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: section.blocks.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          if (i == section.blocks.length) {
            return Text(
              disease.title.tr(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            );
          }
          return BlockView(disease: disease, block: section.blocks[i]);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('prev'),
                  onPressed: index == 0 ? null : () => goTo(index - 1),
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.previous, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('next'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () => goTo(index + 1),
                  icon: const Icon(Icons.chevron_right),
                  iconAlignment: IconAlignment.end,
                  label: Text(l10n.next, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
