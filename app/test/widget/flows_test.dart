import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/app_settings.dart';
import 'package:livehealthy_kyd/core/content/models.dart';
import 'package:livehealthy_kyd/screens/home_screen.dart';
import 'package:livehealthy_kyd/screens/onboarding_screen.dart';

import '../helpers.dart';

void main() {
  testWidgets('first launch: language + disclaimer, then Home; not shown again', (tester) async {
    final app = await pumpApp(tester, language: null, accepted: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.textContaining('does not diagnose'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lang-ur')));
    await tester.pumpAndSettle();
    expect(app.settings.languageCode, 'ur');
    expect(find.text('میں سمجھ گیا/گئی'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(OnboardingScreen))), TextDirection.rtl);

    await tester.tap(find.byKey(const Key('lang-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('accept-disclaimer')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(app.settings.disclaimerAccepted, isTrue);
  });

  testWidgets('Home shows three cards: BP, Diabetes (3 topics), Obesity', (tester) async {
    await pumpApp(tester);
    expect(find.byKey(const Key('topic-hypertension')), findsOneWidget);
    expect(find.byKey(const Key('group-diabetes')), findsOneWidget);
    expect(find.text('3 topics'), findsOneWidget);
    expect(find.byKey(const Key('topic-obesity')), findsOneWidget);
    expect(find.text('More topics coming soon'), findsOneWidget);
  });

  testWidgets('Diabetes group lists its three topics and the Type 1 note (S2b)', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('group-diabetes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('topic-prediabetes')), findsOneWidget);
    expect(find.byKey(const Key('topic-type2_diabetes')), findsOneWidget);
    expect(find.byKey(const Key('topic-gestational_diabetes')), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Type 1'), 200);
    expect(find.textContaining('Type 1 diabetes and other rare types'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-type2_diabetes')));
    await tester.pumpAndSettle();
    expect(find.text('Type 2 Diabetes'), findsWidgets);
  });

  testWidgets('read a whole topic: sections 1–5 with Next, then References 6/6', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('topic-hypertension')));
    await tester.pumpAndSettle();
    expect(find.text('Medically reviewed by Dr. Humayun Shahzad, MBBS'), findsNothing); // below the fold
    await tester.tap(find.byKey(const Key('section-whatIs')));
    await tester.pumpAndSettle();
    expect(find.text('1/6'), findsOneWidget);
    expect(find.textContaining('Blood pressure is the force'), findsOneWidget);
    // Previous is disabled on the first section.
    expect(tester.widget<OutlinedButton>(find.byKey(const Key('prev'))).onPressed, isNull);

    for (var i = 2; i <= 5; i++) {
      await tester.tap(find.byKey(const Key('next')));
      await tester.pumpAndSettle();
      expect(find.text('$i/6'), findsOneWidget);
    }
    expect(find.text('When to see a doctor'), findsOneWidget);
    expect(find.text('Urgent: go to hospital now'), findsOneWidget);

    await tester.tap(find.byKey(const Key('next')));
    await tester.pumpAndSettle();
    expect(find.text('6/6'), findsOneWidget);
    expect(find.text('References'), findsOneWidget);
    expect(find.textContaining('World Health Organization (WHO)'), findsWidgets);

    await tester.tap(find.byKey(const Key('prev')));
    await tester.pumpAndSettle();
    expect(find.text('5/6'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('back-to-topic')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('section-whatIs')), findsOneWidget);
  });

  testWidgets('a [n] marker opens the reference panel with Open source', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('topic-obesity')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-whatIs')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('[1]').first);
    await tester.pumpAndSettle();
    expect(find.text('Reference 1'), findsOneWidget);
    expect(find.text('Open source'), findsOneWidget);
    expect(find.text('Opens in your browser · needs internet'), findsOneWidget);
    expect(find.textContaining('Obesity and overweight (fact sheet)'), findsOneWidget);
  });

  testWidgets('Track it: Open when installed, Coming soon otherwise (§9)', (tester) async {
    final app = await pumpApp(tester, installed: {ToolApp.vitals});
    await tester.tap(find.byKey(const Key('topic-hypertension')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('tool-medicineReminder')), 200);
    expect(find.text('Open LiveHealthy: Vitals'), findsOneWidget);
    expect(find.text('LiveHealthy: Medicine Reminder — coming soon'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('tool-vitals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tool-vitals')));
    await tester.pumpAndSettle();
    expect(app.tools.opened, [ToolApp.vitals]);
    expect(find.textContaining('Medically reviewed by'), findsOneWidget);
  });

  testWidgets('Urdu: whole app right-to-left, Urdu content and font', (tester) async {
    await pumpApp(tester, language: 'ur');
    expect(find.text('اپنی بیماری کو جانیں'), findsWidgets);
    expect(Directionality.of(tester.element(find.byType(HomeScreen))), TextDirection.rtl);
    await tester.tap(find.byKey(const Key('topic-hypertension')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-whatIs')));
    await tester.pumpAndSettle();
    expect(find.textContaining('بلڈ پریشر وہ دباؤ ہے'), findsOneWidget);
    final body = tester.widget<Text>(find.textContaining('بلڈ پریشر وہ دباؤ ہے'));
    final style = DefaultTextStyle.of(tester.element(find.textContaining('بلڈ پریشر وہ دباؤ ہے'))).style.merge(body.style);
    expect(style.fontFamily, 'NotoNastaliqUrdu');
    // Number ranges are isolated so RTL can't reverse them.
    final range = find.byWidgetPredicate((w) => w is Text && (w.data ?? '').contains('\u2066130–139\u2069'));
    await tester.scrollUntilVisible(range, 200);
    expect(range, findsOneWidget);
  });

  testWidgets('Settings: language, text size, content version, version', (tester) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Content version'), findsOneWidget);
    await tester.tap(find.byKey(const Key('text-extraLarge')));
    await tester.pumpAndSettle();
    expect(app.settings.textSize, TextSize.extraLarge);
    final scale = MediaQuery.textScalerOf(tester.element(find.text('Settings'))).scale(10);
    expect(scale, closeTo(13, 0.01));

    await tester.tap(find.byKey(const Key('lang-ur')));
    await tester.pumpAndSettle();
    expect(find.text('سیٹنگز'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const Key('disclaimer')));
    expect(find.textContaining('تشخیص'), findsWidgets);
    await tester.tap(find.text('بند کریں'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('1.0.0 (1)'), 200);
    expect(find.textContaining('1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('every topic opens, in both languages, with every section readable', (tester) async {
    for (final lang in ['en', 'ur']) {
      final app = await pumpApp(tester, language: lang);
      for (final id in allTopicIds) {
        final d = app.repo.disease(id)!;
        for (var i = 0; i < d.sections.length; i++) {
          await tester.pumpWidget(const SizedBox());
          final r = await pumpApp(tester, language: lang, repo: app.repo);
          expect(r.repo, same(app.repo));
          // Straight to the section via navigation from Home is covered above;
          // here we just prove each section renders without errors.
          await tester.tap(find.byKey(Key(d.group == null ? 'topic-$id' : 'group-${d.group}')));
          await tester.pumpAndSettle();
          if (d.group != null) {
            await tester.tap(find.byKey(Key('topic-$id')));
            await tester.pumpAndSettle();
          }
          await scrollAndTap(tester, find.byKey(Key('section-${d.sections[i].id}')));
          expect(tester.takeException(), isNull, reason: '$lang $id ${d.sections[i].id}');
          expect(find.byKey(const Key('section-body')), findsOneWidget);
        }
      }
    }
  });
}
