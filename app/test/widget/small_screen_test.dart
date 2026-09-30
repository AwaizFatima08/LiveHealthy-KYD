import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/app_settings.dart';
import 'package:livehealthy_kyd/core/theme/app_theme.dart';

import '../helpers.dart';

/// Layout at the worst case the Galaxy A12 showed for Vitals: a small
/// screen, 1.3× system font, and here also the app's own "Extra large" text.
/// Any RenderFlex overflow is reported as an exception and fails the test.
void main() {
  Future<void> worstCase(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> expectClean(WidgetTester tester, String where) async {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: where);
  }

  for (final lang in ['en', 'ur']) {
    testWidgets('onboarding fits, button reachable ($lang)', (tester) async {
      await worstCase(tester);
      await pumpApp(tester, language: lang, accepted: false, size: TextSize.extraLarge);
      await expectClean(tester, 'onboarding');
      // The accept button is pinned, so it's on screen without scrolling.
      final r = tester.getRect(find.byKey(const Key('accept-disclaimer')));
      expect(r.bottom, lessThanOrEqualTo(640));
    });

    testWidgets('every screen lays out at 320×640, 1.3× font, extra large ($lang)', (tester) async {
      await worstCase(tester);
      final app = await pumpApp(tester, language: lang, size: TextSize.extraLarge);
      await expectClean(tester, 'home');

      await scrollAndTap(tester, find.byKey(const Key('group-diabetes')));
      await expectClean(tester, 'group');
      expect(find.byKey(const Key('topic-prediabetes')), findsOneWidget);

      for (final id in allTopicIds) {
        final d = app.repo.disease(id)!;
        await tester.pumpWidget(const SizedBox());
        await pumpApp(tester, language: lang, size: TextSize.extraLarge, repo: app.repo);
        if (d.group != null) {
          await scrollAndTap(tester, find.byKey(Key('group-${d.group}')));
          await scrollAndTap(tester, find.byKey(Key('topic-$id')));
        } else {
          await scrollAndTap(tester, find.byKey(Key('topic-$id')));
        }
        await expectClean(tester, '$id page');
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
        await expectClean(tester, '$id page bottom');
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
        await tester.pumpAndSettle();

        await scrollAndTap(tester, find.byKey(const Key('section-whatIs')));
        for (var i = 0; i < d.sections.length; i++) {
          // Walk to the end of the section so every block is built.
          await tester.drag(find.byKey(const Key('section-body')), const Offset(0, -20000));
          await expectClean(tester, '$id ${d.sections[i].id}');
          await tester.tap(find.byKey(const Key('next')));
          await tester.pumpAndSettle();
        }
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -20000));
        await expectClean(tester, '$id references');
        expect(find.text('6/6'), findsOneWidget, reason: '$id reached References');
      }

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, language: lang, size: TextSize.extraLarge, repo: app.repo);
      await tester.tap(find.byKey(const Key('open-settings')));
      await expectClean(tester, 'settings');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await expectClean(tester, 'settings bottom');
    });
  }

  test('text is dark on light backgrounds (the Vitals white-on-white bug)', () {
    for (final lang in ['en', 'ur']) {
      final theme = AppTheme.light(languageCode: lang);
      for (final style in [
        theme.textTheme.bodyLarge,
        theme.textTheme.bodyMedium,
        theme.textTheme.titleLarge,
        theme.textTheme.titleMedium,
        theme.textTheme.headlineSmall,
      ]) {
        expect(style?.color, isNotNull);
        expect(style?.fontSize, isNotNull);
        expect(_contrast(style!.color!, AppTheme.background), greaterThan(7), reason: '$lang $style');
        expect(_contrast(style.color!, Colors.white), greaterThan(7));
      }
    }
    // Colours used behind white text, or as small text on white, meet WCAG AA.
    for (final c in [AppTheme.flagAlert, AppTheme.flagCautionText, AppTheme.primary]) {
      expect(_contrast(c, Colors.white), greaterThan(4.5), reason: '$c');
    }
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
