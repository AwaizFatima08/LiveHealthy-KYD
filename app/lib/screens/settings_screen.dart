import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_settings.dart';
import '../core/constants/links.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import '../services/content_repository.dart';
import '../services/update_service.dart';
import '../widgets/common.dart';
import '../widgets/content_text.dart';

/// S7 — Settings / About.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checking = false;

  Future<void> _checkNow() async {
    final updates = context.read<UpdateService?>();
    if (updates == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    final result = await updates.checkForUpdates(force: true);
    if (!mounted) return;
    setState(() => _checking = false);
    final message = switch (result) {
      UpdateResult.updated => l10n.updateDone,
      UpdateResult.upToDate || UpdateResult.skipped => l10n.updateUpToDate,
      UpdateResult.needsAppUpdate => l10n.updateNeedsApp,
      UpdateResult.failed => l10n.updateFailed,
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reportError(int contentVersion, String appVersion) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: Links.reportEmail,
      query: _encodeQuery({
        'subject': l10n.reportErrorSubject,
        'body': l10n.reportErrorBody(appVersion, contentVersion),
      }),
    );
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {}
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(Links.reportEmail)));
  }

  // mailto wants %20, not '+', for spaces.
  static String _encodeQuery(Map<String, String> params) =>
      params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<AppSettings>();
    final repo = context.watch<ContentRepository>();
    final updates = context.watch<UpdateService?>();
    final appVersion = context.read<AppVersion>().value;
    final last = updates?.lastChecked;

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
      ),
    );

    Widget linkTile(IconData icon, String title, VoidCallback onTap, {Key? key}) => ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      minTileHeight: 56,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          header(l10n.language),
          const LanguageToggle(),
          header(l10n.textSize),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final size in TextSize.values)
                    RadioListTile<TextSize>(
                      key: Key('text-${size.name}'),
                      value: size,
                      // ignore: deprecated_member_use
                      groupValue: settings.textSize,
                      // ignore: deprecated_member_use
                      onChanged: (v) => settings.setTextSize(v!),
                      title: Text(switch (size) {
                        TextSize.normal => l10n.textSizeNormal,
                        TextSize.large => l10n.textSizeLarge,
                        TextSize.extraLarge => l10n.textSizeExtraLarge,
                      }),
                      contentPadding: EdgeInsets.zero,
                    ),
                  const Divider(),
                  Text(l10n.textSizePreview, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          header(l10n.contentSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.contentVersion(repo.manifest.contentVersion), style: theme.textTheme.bodyLarge),
                  Text(
                    last == null
                        ? l10n.neverChecked
                        : l10n.lastChecked(
                            '${MaterialLocalizations.of(context).formatMediumDate(last)} '
                            '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(last))}',
                          ),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (updates != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('check-updates'),
                      onPressed: _checking ? null : _checkNow,
                      icon: _checking
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync),
                      label: Text(_checking ? l10n.checking : l10n.checkForUpdates),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                linkTile(
                  Icons.fact_check_outlined,
                  l10n.howSourcesChosen,
                  () => _showText(context, l10n.howSourcesChosen, l10n.howSourcesChosenText),
                ),
                const Divider(height: 1),
                linkTile(
                  Icons.flag_outlined,
                  l10n.reportError,
                  () => _reportError(repo.manifest.contentVersion, appVersion),
                  key: const Key('report-error'),
                ),
              ],
            ),
          ),
          header(l10n.about),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                linkTile(
                  Icons.info_outline,
                  l10n.disclaimer,
                  () => _showText(context, l10n.disclaimer, '${l10n.disclaimerText}\n\n${l10n.disclaimerEmergency}'),
                  key: const Key('disclaimer'),
                ),
                const Divider(height: 1),
                linkTile(Icons.privacy_tip_outlined, l10n.privacyPolicy, () => openLink(context, Links.privacyPolicy)),
                const Divider(height: 1),
                linkTile(Icons.description_outlined, l10n.terms, () => openLink(context, Links.terms)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.privacyNote,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const AppMark(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appFullName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      l10n.appVersion(appVersion),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _showText(BuildContext context, String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body, style: Theme.of(dialogContext).textTheme.bodyLarge)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(AppLocalizations.of(dialogContext).close)),
        ],
      ),
    );
  }
}
