import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/app_settings.dart';
import 'package:livehealthy_kyd/widgets/common.dart';

import '../helpers.dart';

Finder badgeOn(String cardKey) => find.descendant(of: find.byKey(Key(cardKey)), matching: find.byType(NewBadge));

void main() {
  testWidgets('a topic the reader has not seen shows New until it is opened', (tester) async {
    final app = await pumpApp(tester, seen: allTopicIds.where((id) => id != 'migraine').toList());
    await tester.scrollUntilVisible(find.byKey(const Key('topic-migraine')), 200);
    expect(badgeOn('topic-migraine'), findsOneWidget);
    expect(badgeOn('topic-obesity'), findsNothing);

    await scrollAndTap(tester, find.byKey(const Key('topic-migraine')));
    expect(app.settings.isNew('migraine'), isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(badgeOn('topic-migraine'), findsNothing);
  });

  testWidgets('a group shows New while any member is new', (tester) async {
    await pumpApp(tester, seen: allTopicIds.where((id) => id != 'prediabetes').toList());
    expect(badgeOn('group-diabetes'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const Key('group-diabetes')));
    expect(badgeOn('topic-prediabetes'), findsOneWidget);
    expect(badgeOn('topic-type2_diabetes'), findsNothing);
  });

  testWidgets('fresh install: nothing is new', (tester) async {
    final app = await pumpApp(tester, accepted: false);
    await tester.tap(find.byKey(const Key('accept-disclaimer')));
    await tester.pumpAndSettle();
    expect(find.byType(NewBadge), findsNothing);
    expect(app.settings.seenTopics, containsAll(allTopicIds));
  });

  test('updating from 1.0/1.1: only topics added in 1.2 or later are new', () async {
    final s = await settings(accepted: true);
    expect(s.seenTopics, AppSettings.topicsBefore12);
    expect(s.isNew('hypertension'), isFalse);
    expect(s.isNew('stroke'), isTrue);
  });
}
