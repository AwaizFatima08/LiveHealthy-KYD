import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/content/models.dart';
import 'content_repository.dart';

enum UpdateResult {
  /// Checked less than a day ago; nothing done.
  skipped,
  upToDate,
  updated,

  /// Newer content exists but needs a newer app version.
  needsAppUpdate,

  /// Offline, timed out or bad data. The current content stays in use.
  failed,
}

/// Checks Firestore for corrected or new content at most once a day, online
/// only (§7): 1 read for the manifest, then 1 read per changed disease.
/// Anything invalid is rejected and the previous copy stays in use.
class UpdateService {
  final FirebaseFirestore? firestore;
  final ContentRepository repository;
  final SharedPreferences prefs;

  /// This build's number (pubspec `+N`), compared with `minAppVersion`.
  final int appBuild;
  final DateTime Function() now;

  UpdateService({
    required this.firestore,
    required this.repository,
    required this.prefs,
    required this.appBuild,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  static const String manifestPath = 'kyd_manifest/current';
  static const String diseasesCollection = 'kyd_diseases';
  static const String _lastCheckKey = 'lastContentCheck';
  static const Duration checkInterval = Duration(hours: 24);
  static const Duration timeout = Duration(seconds: 20);

  bool _running = false;

  DateTime? get lastChecked {
    final ms = prefs.getInt(_lastCheckKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<UpdateResult> checkForUpdates({bool force = false}) async {
    final db = firestore;
    if (db == null || _running) return UpdateResult.skipped;
    final last = lastChecked;
    if (!force && last != null && now().difference(last) < checkInterval && !now().isBefore(last)) {
      return UpdateResult.skipped;
    }
    _running = true;
    try {
      final result = await _check(db).timeout(timeout);
      await prefs.setInt(_lastCheckKey, now().millisecondsSinceEpoch);
      return result;
    } catch (e) {
      // Not recorded as a check, so it's retried next launch.
      debugPrint('Content update failed: $e');
      return UpdateResult.failed;
    } finally {
      _running = false;
    }
  }

  Future<UpdateResult> _check(FirebaseFirestore db) async {
    final snap = await db.doc(manifestPath).get(const GetOptions(source: Source.server));
    final data = snap.data();
    if (data == null) return UpdateResult.upToDate;
    final remote = ContentManifest.fromJson(data);
    if (remote.minAppVersion > appBuild) return UpdateResult.needsAppUpdate;

    final changed = <String, Map<String, dynamic>>{};
    for (final e in remote.diseases.entries) {
      if (e.value <= repository.versionOf(e.key)) continue;
      try {
        final doc = await db
            .collection(diseasesCollection)
            .doc(e.key)
            .get(const GetOptions(source: Source.server));
        final json = doc.data();
        if (json == null) continue;
        final disease = Disease.fromJson(json);
        if (disease.id != e.key || disease.version != e.value) {
          throw ContentFormatException('"${e.key}" version/id does not match the manifest');
        }
        changed[e.key] = json;
      } catch (err) {
        // Keep the old copy of this disease; the rest can still update.
        debugPrint('Rejected downloaded "${e.key}": $err');
      }
    }

    final newManifest = remote.contentVersion > repository.manifest.contentVersion;
    if (changed.isEmpty && !newManifest) return UpdateResult.upToDate;
    await repository.saveDownloaded(manifestJson: newManifest ? data : null, diseaseJson: changed);
    return UpdateResult.updated;
  }
}
