import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/common.dart';

/// S1 — language choice and disclaimer, first launch only.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<AppSettings>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppMark(size: 88)),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appFullName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.appTagline, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Text(l10n.chooseLanguage, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    const LanguageToggle(),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.disclaimerTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.disclaimerText, style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 8),
                            Text(
                              l10n.disclaimerEmergency,
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pinned, so it's never below the fold at large font sizes
            // (a real problem Vitals hit on the Galaxy A12).
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                key: const Key('accept-disclaimer'),
                onPressed: settings.acceptDisclaimer,
                child: Text(l10n.iUnderstand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
