import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/content/models.dart';
import 'package:livehealthy_kyd/screens/disease_screen.dart';

import '../helpers.dart';

Map<String, dynamic> copyOf(Map<String, dynamic> m) => jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

Map<String, dynamic> treatmentSection(String ref) => {
  'id': 'treatment',
  'title': {'en': 'Treatment', 'ur': 'علاج'},
  'blocks': [
    {
      'type': 'paragraph',
      'text': {'en': 'Ask your doctor.', 'ur': 'اپنے ڈاکٹر سے پوچھیں۔'},
      'refs': [ref],
    },
  ],
};

Map<String, dynamic> withTreatment(int at) {
  final m = copyOf(bundledJson('hypertension'));
  final ref = ((m['references'] as List).first as Map)['id'] as String;
  (m['sections'] as List).insert(at, treatmentSection(ref));
  return m;
}

Map<String, dynamic> withLink(String target) {
  final m = copyOf(bundledJson('hypertension'));
  ((m['sections'] as List)[2]['blocks'] as List).add({
    'type': 'topicLink',
    'target': target,
    'text': {'en': 'Obesity', 'ur': 'موٹاپا'},
  });
  return m;
}

void main() {
  group('treatment section (1.2)', () {
    test('allowed after complications; the reader then counts 7 screens', () {
      final d = Disease.fromJson(withTreatment(3));
      expect(d.sections.map((s) => s.id), kSectionIdsWithTreatment);
      expect(totalSections(d), 7);
    });

    test('rejected anywhere else', () {
      expect(() => Disease.fromJson(withTreatment(1)), throwsA(isA<ContentFormatException>()));
    });
  });

  group('topic links (1.2)', () {
    test('parse, cite nothing, and reject path-like targets', () {
      final link = Disease.fromJson(withLink('obesity')).sections[2].blocks.whereType<TopicLinkBlock>().last;
      expect(link.target, 'obesity');
      expect(link.refs, isEmpty);
      expect(() => Disease.fromJson(withLink('../manifest')), throwsA(isA<ContentFormatException>()));
    });

    testWidgets('a link opens its topic; a link to a topic not on the phone is hidden', (tester) async {
      final cache = tempCacheDir();
      final repo = (await tester.runAsync(() => loadedRepository(cache: cache)))!;
      for (final target in ['obesity', 'not_here_yet']) {
        final json = withLink(target)..['version'] = 90 + target.length;
        await tester.runAsync(
          () => repo.saveDownloaded(manifestJson: null, diseaseJson: {'hypertension': json}),
        );
        await tester.pumpWidget(const SizedBox()); // start each round from Home
        await pumpApp(tester, repo: repo);
        await scrollAndTap(tester, find.byKey(const Key('topic-hypertension')));
        await scrollAndTap(tester, find.byKey(const Key('section-complications')));
        await tester.drag(find.byKey(const Key('section-body')), const Offset(0, -20000));
        await tester.pumpAndSettle();
        if (target == 'obesity') {
          await tester.ensureVisible(find.byKey(const Key('topic-link-obesity')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('topic-link-obesity')));
          await tester.pumpAndSettle();
          expect(find.byType(DiseaseScreen), findsOneWidget);
          expect(find.text('Obesity'), findsWidgets);
        } else {
          expect(find.byKey(const Key('topic-link-not_here_yet')), findsNothing);
        }
      }
    });
  });
}
