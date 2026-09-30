import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/content_repository.dart';
import '../widgets/common.dart';
import '../widgets/content_text.dart';
import 'disease_screen.dart';
import 'group_screen.dart';
import 'settings_screen.dart';

/// S2 — Home: one card per disease or topic group.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = context.watch<ContentRepository>().homeItems;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            key: const Key('open-settings'),
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l10n.homeIntro, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          for (final item in items) ...[
            switch (item) {
              DiseaseItem(:final disease) => TopicCard(
                key: Key('topic-${disease.id}'),
                graphic: disease.headerAsset,
                title: disease.title.tr(context),
                summary: disease.summary.tr(context),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DiseaseScreen(diseaseId: disease.id)),
                ),
              ),
              GroupItem(:final group, :final members) => TopicCard(
                key: Key('group-${group.id}'),
                graphic: group.headerAsset,
                title: group.title.tr(context),
                summary: group.summary.tr(context),
                badge: l10n.topicsCount(members.length),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GroupScreen(groupId: group.id)),
                ),
              ),
            },
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.moreTopicsSoon,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.disclaimerText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
