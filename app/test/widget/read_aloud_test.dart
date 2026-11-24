import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/services/read_aloud.dart';

import '../helpers.dart';

/// Records what would be spoken; each chunk "plays" until [finishOne].
class FakeEngine implements SpeechEngine {
  final Set<String> voices;
  final List<(String, String)> spoken = [];
  Completer<void>? _current;
  bool stopped = false;
  FakeEngine({this.voices = const {'en-US', 'ur-PK'}});

  @override
  Future<bool> hasVoice(String locale) async => voices.contains(locale);

  @override
  Future<void> speak(String text, String locale) {
    spoken.add((text, locale));
    _current = Completer<void>();
    return _current!.future;
  }

  void finishOne() => _current?.complete();

  @override
  Future<void> stop() async {
    stopped = true;
    if (!(_current?.isCompleted ?? true)) _current!.complete();
  }
}

Future<void> openFirstSection(WidgetTester tester) async {
  await scrollAndTap(tester, find.byKey(const Key('topic-hypertension')));
  await scrollAndTap(tester, find.byKey(const Key('section-whatIs')));
}

void main() {
  testWidgets('reads the section title and text in order, in English', (tester) async {
    final engine = FakeEngine();
    await pumpApp(tester, readAloud: ReadAloud(engine));
    await openFirstSection(tester);
    await tester.tap(find.byKey(const Key('read-aloud')));
    await tester.pump();
    expect(engine.spoken.first, ('What it is', 'en-US'));
    expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);
    engine.finishOne();
    await tester.pump();
    expect(engine.spoken.length, 2);
    expect(engine.spoken.every((s) => !s.$1.contains('[')), isTrue, reason: 'reference markers are not read');
  });

  testWidgets('pressing again stops; leaving the section stops', (tester) async {
    final engine = FakeEngine();
    await pumpApp(tester, readAloud: ReadAloud(engine));
    await openFirstSection(tester);
    await tester.tap(find.byKey(const Key('read-aloud')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('read-aloud')));
    await tester.pump();
    expect(engine.stopped, isTrue);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);

    engine.stopped = false;
    await tester.tap(find.byKey(const Key('read-aloud')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('next')));
    await tester.pumpAndSettle();
    expect(engine.stopped, isTrue);
  });

  testWidgets('Urdu uses the Urdu voice; without one, the reader is told how to add it', (tester) async {
    final engine = FakeEngine(voices: {'en-US'});
    await pumpApp(tester, language: 'ur', readAloud: ReadAloud(engine));
    await openFirstSection(tester);
    await tester.tap(find.byKey(const Key('read-aloud')));
    await tester.pump();
    expect(engine.spoken, isEmpty);
    expect(find.textContaining('اردو آواز موجود نہیں'), findsOneWidget);
  });

  test('spoken text has no bidi marks and skips reference markers', () async {
    final repo = await loadedRepository();
    for (final id in allTopicIds) {
      for (final s in repo.disease(id)!.sections) {
        for (final lang in ['en', 'ur']) {
          final chunks = spokenChunks(s, lang);
          expect(chunks, isNotEmpty);
          expect(chunks.join().contains(RegExp(r'[\u2060\u2066-\u2069]')), isFalse, reason: '$id ${s.id} $lang');
        }
      }
    }
  });
}
