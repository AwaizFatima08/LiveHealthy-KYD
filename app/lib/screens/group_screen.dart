import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/content_repository.dart';
import '../widgets/common.dart';
import '../widgets/content_text.dart';
import 'disease_screen.dart';

/// S2b — the topics in one group (D13), e.g. Prediabetes, Type 2 and
/// Gestational diabetes. Each opens the normal disease page.
class GroupScreen extends StatelessWidget {
  final String groupId;
  const GroupScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = context.watch<ContentRepository>();
    final group = repo.group(groupId);
    if (group == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(AppLocalizations.of(context).contentUnavailable)));
    }
    final members = repo.membersOf(group);
    return Scaffold(
      appBar: AppBar(title: Text(group.title.tr(context))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            group.summary.tr(context),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final d in members) ...[
            TopicCard(
              key: Key('topic-${d.id}'),
              graphic: d.headerAsset,
              title: d.title.tr(context),
              summary: d.summary.tr(context),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiseaseScreen(diseaseId: d.id))),
            ),
            const SizedBox(height: 12),
          ],
          if (group.note != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(child: Text(group.note!.tr(context), style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
