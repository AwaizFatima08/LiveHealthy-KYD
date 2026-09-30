import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/content/models.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/content_repository.dart';
import '../services/tool_launcher.dart';
import '../widgets/block_view.dart';
import '../widgets/content_text.dart';
import 'references_screen.dart';
import 'section_screen.dart';

/// Five written sections + References.
int totalSections(Disease d) => d.sections.length + 1;

/// S3 — one disease: header, the six sections, "Track it", review line.
class DiseaseScreen extends StatelessWidget {
  final String diseaseId;
  const DiseaseScreen({super.key, required this.diseaseId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = context.watch<ContentRepository>();
    final disease = repo.disease(diseaseId);
    if (disease == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.contentUnavailable)));
    }
    final total = totalSections(disease);
    final tools = disease.relatedTools.where((t) => repo.toolStatus(t.app) != ToolLinkStatus.hidden).toList();

    return Scaffold(
      appBar: AppBar(title: Text(disease.title.tr(context))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: ContentGraphic(assetKey: disease.headerAsset),
          ),
          const SizedBox(height: 12),
          Text(disease.summary.tr(context), style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, s) in disease.sections.indexed) ...[
                  _SectionTile(
                    key: Key('section-${s.id}'),
                    number: i + 1,
                    title: s.title.tr(context),
                    accent: s.id == 'whenToSeeDoctor' ? AppTheme.flagAlert : null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SectionScreen(diseaseId: disease.id, index: i)),
                    ),
                  ),
                  const Divider(height: 1),
                ],
                _SectionTile(
                  key: const Key('section-references'),
                  number: total,
                  title: l10n.references,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ReferencesScreen(diseaseId: disease.id)),
                  ),
                ),
              ],
            ),
          ),
          if (tools.isNotEmpty) ...[
            const SizedBox(height: 20),
            _TrackItCard(tools: tools),
          ],
          const SizedBox(height: 20),
          Text(
            l10n.reviewedBy(disease.reviewedBy.tr(context)),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            l10n.reviewDates(formatIsoDate(context, disease.reviewedOn), formatIsoDate(context, disease.nextReviewDue)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final int number;
  final String title;
  final Color? accent;
  final VoidCallback onTap;

  const _SectionTile({super.key, required this.number, required this.title, this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: accent == null
            ? null
            : BoxDecoration(border: BorderDirectional(start: BorderSide(color: accent!, width: 5))),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 10, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Text(
                '$number',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontFamily: 'Roboto', fontSize: 15),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

String toolAppName(AppLocalizations l10n, ToolApp app) => switch (app) {
  ToolApp.vitals => l10n.appNameVitals,
  ToolApp.medicineReminder => l10n.appNameMedicineReminder,
};

/// "Track it" (§9): Open if installed, otherwise Get (Play) or Coming soon,
/// as set remotely by the manifest's toolLinks switch.
class _TrackItCard extends StatelessWidget {
  final List<RelatedTool> tools;
  const _TrackItCard({required this.tools});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.trackIt, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.trackItIntro, style: theme.textTheme.bodyMedium),
            for (final t in tools) ...[const SizedBox(height: 12), _ToolButton(tool: t)],
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatefulWidget {
  final RelatedTool tool;
  const _ToolButton({required this.tool});

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  late final Future<bool> _installed = context.read<ToolLauncher>().isInstalled(widget.tool.app);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = context.watch<ContentRepository>().toolStatus(widget.tool.app);
    final name = toolAppName(l10n, widget.tool.app);
    return FutureBuilder<bool>(
      future: _installed,
      builder: (context, snap) {
        final installed = snap.data ?? false;
        final Widget button;
        if (installed || status == ToolLinkStatus.live) {
          button = FilledButton.tonalIcon(
            key: Key('tool-${widget.tool.app.name}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await context.read<ToolLauncher>().open(widget.tool.app);
              if (!ok) messenger.showSnackBar(SnackBar(content: Text(l10n.couldNotOpen)));
            },
            icon: Icon(installed ? Icons.open_in_new : Icons.shop_outlined),
            label: Text(installed ? l10n.openApp(name) : l10n.getOnPlay(name), textAlign: TextAlign.center),
          );
        } else {
          button = OutlinedButton(
            key: Key('tool-${widget.tool.app.name}'),
            onPressed: null,
            child: Text(l10n.comingSoonApp(name), textAlign: TextAlign.center),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.tool.label.tr(context), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            button,
          ],
        );
      },
    );
  }
}
