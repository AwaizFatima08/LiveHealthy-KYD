import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_kyd/core/content/models.dart';
import 'package:livehealthy_kyd/services/content_repository.dart';
import 'package:livehealthy_kyd/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

Map<String, dynamic> bumped(String id, int version, {String? newSummary}) {
  final d = jsonDecode(jsonEncode(bundledJson(id))) as Map<String, dynamic>;
  d['version'] = version;
  if (newSummary != null) (d['summary'] as Map)['en'] = newSummary;
  return d;
}

Map<String, dynamic> manifestWith({int contentVersion = 2, Map<String, int>? versions, int minApp = 1}) {
  final m = jsonDecode(jsonEncode(bundledJson('manifest'))) as Map<String, dynamic>;
  m['contentVersion'] = contentVersion;
  m['minAppVersion'] = minApp;
  if (versions != null) (m['diseases'] as Map).addAll(versions);
  return m;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentRepository', () {
    test('serves bundled content offline, with no cache at all', () async {
      final repo = await loadedRepository();
      expect(repo.manifest.contentVersion, greaterThanOrEqualTo(1));
      for (final id in allTopicIds) {
        expect(repo.disease(id), isNotNull, reason: id);
      }
    });

    test('Home: three cards in order, diabetes topics grouped (D13)', () async {
      final repo = await loadedRepository();
      final items = repo.homeItems;
      expect(items.length, 3);
      expect((items[0] as DiseaseItem).disease.id, 'hypertension');
      final g = items[1] as GroupItem;
      expect(g.group.id, 'diabetes');
      expect(g.members.map((d) => d.id), ['prediabetes', 'type2_diabetes', 'gestational_diabetes']);
      expect((items[2] as DiseaseItem).disease.id, 'obesity');
    });

    test('uses a newer downloaded copy, and survives a restart', () async {
      final cache = tempCacheDir();
      final repo = await loadedRepository(cache: cache);
      await repo.saveDownloaded(
        manifestJson: manifestWith(versions: {'hypertension': 5}),
        diseaseJson: {'hypertension': bumped('hypertension', 5, newSummary: 'Corrected summary')},
      );
      expect(repo.disease('hypertension')!.summary.of('en'), 'Corrected summary');
      final restarted = await loadedRepository(cache: cache);
      expect(restarted.disease('hypertension')!.version, 5);
      expect(restarted.manifest.contentVersion, 2);
    });

    test('ignores a downloaded copy older than the bundled one (app update wins)', () async {
      final cache = tempCacheDir();
      Directory('${cache.path}/content').createSync(recursive: true);
      File('${cache.path}/content/obesity.json').writeAsStringSync(
        jsonEncode(bumped('obesity', 0, newSummary: 'Stale')),
      );
      final repo = await loadedRepository(cache: cache);
      expect(repo.disease('obesity')!.summary.of('en'), isNot('Stale'));
    });

    test('ignores corrupt downloaded files', () async {
      final cache = tempCacheDir();
      Directory('${cache.path}/content').createSync(recursive: true);
      File('${cache.path}/content/hypertension.json').writeAsStringSync('{"id": "hypertension", "version": 99');
      File('${cache.path}/content/manifest.json').writeAsStringSync('not json');
      final repo = await loadedRepository(cache: cache);
      expect(repo.disease('hypertension')!.version, lessThan(99));
      expect(repo.homeItems.length, 3);
    });

    test('a downloaded file can never replace a different topic', () async {
      final cache = tempCacheDir();
      Directory('${cache.path}/content').createSync(recursive: true);
      File('${cache.path}/content/hypertension.json').writeAsStringSync(jsonEncode(bumped('obesity', 50)));
      final repo = await loadedRepository(cache: cache);
      expect(repo.disease('hypertension')!.id, 'hypertension');
      expect(repo.disease('hypertension')!.version, lessThan(50));
    });
  });

  group('UpdateService (§7)', () {
    late FakeFirebaseFirestore db;
    late ContentRepository repo;
    late SharedPreferences prefs;
    var now = DateTime(2026, 10, 1, 9);

    UpdateService service({int appBuild = 1}) =>
        UpdateService(firestore: db, repository: repo, prefs: prefs, appBuild: appBuild, now: () => now);

    setUp(() async {
      db = FakeFirebaseFirestore();
      repo = await loadedRepository(cache: tempCacheDir());
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      now = DateTime(2026, 10, 1, 9);
    });

    test('no remote manifest yet: up to date, bundled content stays', () async {
      expect(await service().checkForUpdates(), UpdateResult.upToDate);
      expect(repo.disease('hypertension'), isNotNull);
    });

    test('downloads only changed topics, then applies them', () async {
      await db.doc('kyd_diseases/hypertension').set(bumped('hypertension', 7, newSummary: 'Fixed a sentence'));
      await db.doc('kyd_manifest/current').set(manifestWith(contentVersion: 3, versions: {'hypertension': 7}));
      expect(await service().checkForUpdates(), UpdateResult.updated);
      expect(repo.disease('hypertension')!.summary.of('en'), 'Fixed a sentence');
      expect(repo.manifest.contentVersion, 3);
    });

    test('checks at most once a day unless forced', () async {
      final s = service();
      expect(await s.checkForUpdates(), UpdateResult.upToDate);
      now = now.add(const Duration(hours: 5));
      expect(await s.checkForUpdates(), UpdateResult.skipped);
      expect(await s.checkForUpdates(force: true), UpdateResult.upToDate);
      now = now.add(const Duration(hours: 25));
      expect(await s.checkForUpdates(), UpdateResult.upToDate);
    });

    test('a clock set backwards does not block checks forever', () async {
      final s = service();
      await s.checkForUpdates();
      now = now.subtract(const Duration(days: 30));
      expect(await s.checkForUpdates(), UpdateResult.upToDate);
    });

    test('rejects an invalid download and keeps the old copy', () async {
      final bad = bumped('hypertension', 9);
      ((bad['sections'] as List)[2]['blocks'] as List).clear();
      await db.doc('kyd_diseases/hypertension').set(bad);
      await db.doc('kyd_manifest/current').set(manifestWith(contentVersion: 2, versions: {'hypertension': 9}));
      final before = repo.disease('hypertension')!.version;
      await service().checkForUpdates();
      expect(repo.disease('hypertension')!.version, before);
    });

    test('rejects a document whose version or id disagrees with the manifest', () async {
      await db.doc('kyd_diseases/obesity').set(bumped('obesity', 4));
      await db.doc('kyd_manifest/current').set(manifestWith(contentVersion: 2, versions: {'obesity': 6}));
      await service().checkForUpdates();
      expect(repo.disease('obesity')!.version, lessThan(4));
    });

    test('content that needs a newer app is not applied', () async {
      await db.doc('kyd_diseases/obesity').set(bumped('obesity', 4));
      await db.doc('kyd_manifest/current').set(manifestWith(contentVersion: 5, versions: {'obesity': 4}, minApp: 2));
      expect(await service(appBuild: 1).checkForUpdates(), UpdateResult.needsAppUpdate);
      expect(repo.disease('obesity')!.version, lessThan(4));
    });

    test('tool link switch flips without an app update (§9)', () async {
      final m = manifestWith(contentVersion: 2);
      m['toolLinks'] = {'vitals': 'live', 'medicineReminder': 'hidden'};
      await db.doc('kyd_manifest/current').set(m);
      await service().checkForUpdates();
      expect(repo.toolStatus(ToolApp.vitals), ToolLinkStatus.live);
      expect(repo.toolStatus(ToolApp.medicineReminder), ToolLinkStatus.hidden);
    });

    test('without Firebase (offline start), updates are simply skipped', () async {
      final s = UpdateService(firestore: null, repository: repo, prefs: prefs, appBuild: 1);
      expect(await s.checkForUpdates(force: true), UpdateResult.skipped);
    });
  });
}
