// End-to-end run of the real app on a real device, with the phone's own
// fonts and font-size setting. Reads content from the LOCAL Firestore
// emulator (seeded by scripts/run_e2e.sh), never production.
// Store screenshots are captured separately (scripts/make_screenshots.sh).
// Run via scripts/run_e2e.sh.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:livehealthy_kyd/main.dart' as app;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> waitFor(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> settle(WidgetTester tester) => pumpFor(tester, const Duration(milliseconds: 700));

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 250, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await settle(tester);
}

Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  final rect = tester.getRect(finder);
  final height = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  if (rect.center.dy > height - 90) {
    await tester.tapAt(rect.topLeft + const Offset(24, 24));
  } else {
    await tester.tap(finder);
  }
  await settle(tester);
}

/// Scrolls the current section/reference list to the end, a screen at a time,
/// so every block is laid out with real fonts.
Future<void> readToEnd(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 40; i++) {
    final pos = tester.state<ScrollableState>(scrollable).position;
    if (pos.pixels >= pos.maxScrollExtent - 1) break;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pump(const Duration(milliseconds: 150));
  }
  await settle(tester);
}

/// True if a single-line / max-lines Text was cut off.
bool truncated(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(find.descendant(of: text, matching: find.byType(RichText)).first)
        .didExceedMaxLines;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full reading journey on a real phone', (tester) async {
    // Start as a brand-new install.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final support = await getApplicationSupportDirectory();
    final cache = Directory('${support.path}/content');
    if (cache.existsSync()) cache.deleteSync(recursive: true);

    app.main();
    await waitFor(tester, find.byKey(const Key('accept-disclaimer')));
    await settle(tester);

    // Language toggle both ways; Urdu is right-to-left.
    await tester.tap(find.byKey(const Key('lang-ur')));
    await settle(tester);
    expect(find.text('میں سمجھ گیا/گئی'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lang-en')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('accept-disclaimer')));
    await waitFor(tester, find.byKey(const Key('topic-hypertension')));
    await settle(tester);
    expect(truncated(tester, find.text('Know Your Disease')), isFalse, reason: 'Home title cut off');

    // Every topic, every section read to the end, then References.
    const topics = {
      'hypertension': null,
      'prediabetes': 'diabetes',
      'type2_diabetes': 'diabetes',
      'gestational_diabetes': 'diabetes',
      'obesity': null,
    };
    for (final e in topics.entries) {
      final id = e.key, group = e.value;
      if (group != null) {
        await tapScrolled(tester, find.byKey(Key('group-$group')));
      }
      await tapScrolled(tester, find.byKey(Key('topic-$id')));
      if (id == 'hypertension') {
        await scrollTo(tester, find.byKey(const Key('tool-vitals')));
        // Vitals is installed on the test phone, so Track it offers "Open".
        await waitFor(tester, find.text('Open LiveHealthy: Vitals'));
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
        await settle(tester);
      }
      await tapScrolled(tester, find.byKey(const Key('section-whatIs')));
      for (var s = 1; s <= 5; s++) {
        expect(find.text('$s/6'), findsOneWidget);
        await readToEnd(tester);
        if (id == 'hypertension' && s == 5) {
          await tester.drag(find.byType(Scrollable).first, const Offset(0, 20000));
          await settle(tester);
        }
        expect(truncated(tester, find.byKey(const Key('next'))), isFalse);
        await tester.tap(find.byKey(const Key('next')));
        await settle(tester);
      }
      expect(find.text('6/6'), findsOneWidget);
      await readToEnd(tester);
      await tester.tap(find.byKey(const Key('back-to-topic')));
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      if (group != null) {
        await tester.pageBack();
        await settle(tester);
      }
      await waitFor(tester, find.byKey(const Key('topic-hypertension')));
    }

    // A reference marker opens its citation panel.
    await tapScrolled(tester, find.byKey(const Key('topic-obesity')));
    await tapScrolled(tester, find.byKey(const Key('section-whatIs')));
    await tester.tap(find.text('[1]').first);
    await settle(tester);
    expect(find.text('Open source'), findsOneWidget);
    await tester.tapAt(const Offset(20, 60)); // dismiss the sheet
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);

    // Settings: content update from the emulator, then Urdu.
    await tester.tap(find.byKey(const Key('open-settings')));
    await settle(tester);
    await tapScrolled(tester, find.byKey(const Key('check-updates')));
    await waitFor(tester, find.byType(SnackBar));
    expect(find.text("Couldn't check. You can keep reading offline."), findsNothing);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await settle(tester);
    await tester.tap(find.byKey(const Key('lang-ur')));
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    expect(find.text('اپنی بیماری کو جانیں'), findsWidgets);
    await tapScrolled(tester, find.byKey(const Key('topic-hypertension')));
    await tapScrolled(tester, find.byKey(const Key('section-whatIs')));
    for (var s = 1; s <= 5; s++) {
      await readToEnd(tester);
      await tester.tap(find.byKey(const Key('next')));
      await settle(tester);
    }
    expect(find.text('6/6'), findsOneWidget);
  });
}
