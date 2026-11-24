import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/content/models.dart';

/// The text-to-speech engine, behind an interface so tests don't need the
/// platform plugin.
abstract class SpeechEngine {
  Future<bool> hasVoice(String locale);
  Future<void> speak(String text, String locale);
  Future<void> stop();
}

class FlutterTtsEngine implements SpeechEngine {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    // Wait for each chunk to finish, so a section is read in order.
    await _tts.awaitSpeakCompletion(true);
    // A little slower than default: many readers are older (design-v1 §1).
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _ready = true;
  }

  @override
  Future<bool> hasVoice(String locale) async {
    try {
      final available = await _tts.isLanguageAvailable(locale);
      return available == true || available == 1;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> speak(String text, String locale) async {
    await _init();
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}

/// Result of pressing "Read aloud".
enum ReadAloudStart { started, noVoice, unavailable }

/// Reads one section aloud with the phone's own voice (design-v1.2 §5).
/// Nothing is recorded or bundled; no audio leaves the phone.
class ReadAloud extends ChangeNotifier {
  final SpeechEngine? _engine;
  ReadAloud(SpeechEngine engine) : _engine = engine;

  /// Tests and platforms without TTS: the button explains it can't read.
  ReadAloud.unavailable() : _engine = null;

  static String localeFor(String languageCode) => languageCode == 'ur' ? 'ur-PK' : 'en-US';

  Object? _speakingKey;
  int _run = 0;

  /// The section currently being read, if any.
  bool isSpeaking(Object key) => _speakingKey == key;

  Future<ReadAloudStart> start(Object key, List<String> chunks, String languageCode) async {
    final engine = _engine;
    if (engine == null) return ReadAloudStart.unavailable;
    final locale = localeFor(languageCode);
    if (!await engine.hasVoice(locale)) return ReadAloudStart.noVoice;
    await stop();
    final run = ++_run;
    _speakingKey = key;
    notifyListeners();
    _readAll(engine, run, chunks, locale);
    return ReadAloudStart.started;
  }

  Future<void> _readAll(SpeechEngine engine, int run, List<String> chunks, String locale) async {
    try {
      for (final chunk in chunks) {
        if (run != _run) return; // stopped or restarted
        await engine.speak(chunk, locale);
      }
    } catch (e) {
      debugPrint('Read aloud failed: $e');
    }
    if (run == _run) {
      _speakingKey = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    _run++;
    final wasSpeaking = _speakingKey != null;
    _speakingKey = null;
    await _engine?.stop();
    if (wasSpeaking) notifyListeners();
  }
}

/// What gets read for a section, in reading order: the title, then each
/// block's words. Reference markers, graphics without captions and links are
/// skipped; bidi marks (used for Urdu number runs) are removed.
List<String> spokenChunks(ContentSection section, String languageCode) {
  String t(LocalizedText text) => _clean(text.of(languageCode));
  final out = <String>[t(section.title)];
  for (final b in section.blocks) {
    switch (b) {
      case ParagraphBlock(:final text):
        out.add(t(text));
      case BulletsBlock(:final title, :final items):
        if (title != null) out.add(t(title));
        out.addAll(items.map(t));
      case ImageBlock(:final caption):
        out.add(t(caption));
      case AnimationBlock(:final caption):
        out.add(t(caption));
      case KeyNumberBlock(:final label, :final value, :final note):
        out.add('${t(label)}: ${t(value)}');
        if (note != null) out.add(t(note));
      case AlertBlock(:final title, :final items, :final text):
        out.add(t(title));
        out.addAll(items.map(t));
        if (text != null) out.add(t(text));
      case RefMarkerBlock():
      case TopicLinkBlock():
        break;
    }
  }
  return out.where((s) => s.trim().isNotEmpty).toList();
}

String _clean(String s) => s.replaceAll(RegExp(r'[\u2060\u2066-\u2069]'), '');
