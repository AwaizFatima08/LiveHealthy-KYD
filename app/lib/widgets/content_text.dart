import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_settings.dart';
import '../core/content/models.dart';
import '../l10n/generated/app_localizations.dart';

/// Number runs (with range dashes, slashes, comparison signs and units)
/// such as "130–139", "≥ 140/90" or "126 mg/dL".
const String _number = r'(?:[<>≥≤]\s?)?\d[\d.,]*%?';
final RegExp _numberRun = RegExp(
  '$_number(?:\\s?[–\\-/]\\s?$_number)*(?:\\s?(?:mg/dL|mmol/L|mmHg|kg/m²))?',
);

/// In right-to-left text, the bidi algorithm reverses "130–139" into
/// "139–130" and moves "≥" to the wrong side. Isolating each number run as
/// left-to-right (U+2066 … U+2069) keeps it exactly as written.
///
/// In both languages a run is also kept on one line (word joiners around
/// its dashes and slashes), so "120–129" never splits into "120–" / "129".
String bidiSafe(String text, String languageCode) {
  return text.replaceAllMapped(_numberRun, (m) {
    final run = m[0]!.replaceAllMapped(RegExp(r'\s?[–/-]\s?'), (d) => '\u2060${d[0]!.trim()}\u2060');
    return languageCode == 'ur' ? '\u2066$run\u2069' : run;
  });
}

extension LocalizedTextX on LocalizedText {
  /// Text in the reader's language, number runs made RTL-safe.
  String tr(BuildContext context) {
    final lang = context.read<AppSettings>().languageCode;
    return bidiSafe(of(lang), lang);
  }
}

/// Short date in the reader's language, from an ISO yyyy-mm-dd string.
String formatIsoDate(BuildContext context, String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(d);
}

/// Opens an https link in the browser; tells the reader if it can't.
Future<void> openLink(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.couldNotOpen)));
  }
}

/// The small tappable [1] [2] markers after a block (§10, S4).
class RefMarkers extends StatelessWidget {
  final Disease disease;
  final List<String> refs;

  const RefMarkers({super.key, required this.disease, required this.refs});

  @override
  Widget build(BuildContext context) {
    if (refs.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final id in refs)
          Semantics(
            button: true,
            label: l10n.referenceNumber(disease.refNumber(id)),
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showReferenceSheet(context, disease, id),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '[${disease.refNumber(id)}]',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Roboto'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The small panel a [n] marker opens: the citation plus "Open source".
Future<void> showReferenceSheet(BuildContext context, Disease disease, String refId) {
  final ref = disease.refById(refId);
  if (ref == null) return Future.value();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.referenceNumber(disease.refNumber(refId)),
                style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ReferenceCitation(reference: ref),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => openLink(sheetContext, ref.url),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openSource),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.linkNeedsInternet,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Organisation · year, title, host and check date. Citations stay in the
/// original (English) wording of the source, left-to-right, in both
/// languages — they're titles of documents, not translatable text.
class ReferenceCitation extends StatelessWidget {
  final Reference reference;

  const ReferenceCitation({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    const latin = 'Roboto';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reference.org} · ${reference.year}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontFamily: latin, height: 1.3),
                ),
                const SizedBox(height: 2),
                Text(reference.title, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: latin, height: 1.35)),
                const SizedBox(height: 2),
                Text(
                  Uri.parse(reference.url).host,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted, fontFamily: latin, height: 1.3),
                ),
              ],
            ),
          ),
        ),
        Text(
          l10n.linkChecked(formatIsoDate(context, reference.checkedOn)),
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}
