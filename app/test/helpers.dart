import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/app_settings.dart';
import 'package:livehealthy_kyd/core/content/models.dart';
import 'package:livehealthy_kyd/main.dart';
import 'package:livehealthy_kyd/services/content_repository.dart';
import 'package:livehealthy_kyd/services/tool_launcher.dart';
import 'package:livehealthy_kyd/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the real bundled content straight from app/assets/content/.
Map<String, dynamic> bundledJson(String name) =>
    jsonDecode(File('assets/content/$name.json').readAsStringSync()) as Map<String, dynamic>;

const allTopicIds = ['hypertension', 'prediabetes', 'type2_diabetes', 'gestational_diabetes', 'obesity'];

/// A fresh temp directory standing in for app-private storage.
Directory tempCacheDir() {
  final dir = Directory.systemTemp.createTempSync('kyd_test_');
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dir;
}

Future<ContentRepository> loadedRepository({Directory? cache}) async {
  final repo = ContentRepository(bundle: rootBundle, cacheDir: () async => cache);
  await repo.load();
  return repo;
}

Future<AppSettings> settings({String? language, bool accepted = true, TextSize? size}) async {
  SharedPreferences.setMockInitialValues({
    'language': ?language,
    'disclaimerAccepted': accepted,
    'textSize': ?size?.name,
  });
  return AppSettings(await SharedPreferences.getInstance());
}

/// Records "Track it" calls instead of touching the platform.
class FakeToolLauncher extends ToolLauncher {
  final Set<ToolApp> installed;
  final List<ToolApp> opened = [];
  FakeToolLauncher({this.installed = const {}});

  @override
  Future<bool> isInstalled(ToolApp app) async => installed.contains(app);

  @override
  Future<bool> open(ToolApp app) async {
    opened.add(app);
    return true;
  }
}

Future<({AppSettings settings, ContentRepository repo, FakeToolLauncher tools})> pumpApp(
  WidgetTester tester, {
  String? language = 'en',
  bool accepted = true,
  TextSize? size,
  Set<ToolApp> installed = const {},
  UpdateService? updates,
  ContentRepository? repo,
}) async {
  final s = await settings(language: language, accepted: accepted, size: size);
  final r = repo ?? await tester.runAsync(() => loadedRepository()) as ContentRepository;
  final tools = FakeToolLauncher(installed: installed);
  await tester.pumpWidget(
    KnowYourDiseaseApp(settings: s, repository: r, updates: updates, toolLauncher: tools, appVersion: '1.0.0 (1)'),
  );
  await tester.pumpAndSettle();
  return (settings: s, repo: r, tools: tools);
}

/// Scrolls the first scrollable until [finder] is built, then taps it.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  // Very tall widgets (huge text) may have their centre off screen.
  final rect = tester.getRect(finder);
  final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
  if (rect.center.dy > screen.height - 80) {
    await tester.tapAt(rect.topLeft + const Offset(24, 24));
  } else {
    await tester.tap(finder);
  }
  await tester.pumpAndSettle();
}

extension TextFinderX on CommonFinders {
  /// Text widgets whose data contains [s] (ignoring bidi isolates).
  Finder textContaining(String s) => find.byWidgetPredicate(
    (w) => w is Text && (w.data ?? '').replaceAll(RegExp('[\u2066-\u2069]'), '').contains(s),
  );
}
