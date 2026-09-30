import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/content/models.dart';

/// One card on Home: a single disease, or a topic group (D13).
sealed class HomeItem {
  int get order;
}

class DiseaseItem extends HomeItem {
  final Disease disease;
  DiseaseItem(this.disease);
  @override
  int get order => disease.order;
}

class GroupItem extends HomeItem {
  final TopicGroup group;
  final List<Disease> members;
  GroupItem(this.group, this.members);
  @override
  int get order => group.order;
}

/// Serves the newest valid copy of each disease: downloaded if present and
/// newer, otherwise the copy bundled in the app. Always works offline (§6).
class ContentRepository extends ChangeNotifier {
  final AssetBundle bundle;

  /// Where downloaded content is kept (app-private storage). Null disables
  /// downloads (e.g. tests that only need bundled content).
  final Future<Directory?> Function() cacheDir;

  ContentRepository({required this.bundle, required this.cacheDir});

  static const String bundledRoot = 'assets/content';

  ContentManifest? _manifest;
  final Map<String, Disease> _diseases = {};

  bool get isLoaded => _manifest != null;
  ContentManifest get manifest => _manifest!;

  Disease? disease(String id) => _diseases[id];

  /// Version of the copy in use, 0 if none.
  int versionOf(String id) => _diseases[id]?.version ?? 0;

  Future<void> load() async {
    final bundledManifest = ContentManifest.fromJson(
      jsonDecode(await bundle.loadString('$bundledRoot/manifest.json')),
    );
    final dir = await _contentDir();
    final downloadedManifest = dir == null ? null : _tryParse(File('${dir.path}/manifest.json'), ContentManifest.fromJson);

    final useDownloaded =
        downloadedManifest != null && downloadedManifest.contentVersion > bundledManifest.contentVersion;
    final manifest = useDownloaded ? downloadedManifest : bundledManifest;

    final diseases = <String, Disease>{};
    for (final id in manifest.diseases.keys) {
      Disease? bundled;
      if (bundledManifest.diseases.containsKey(id)) {
        try {
          bundled = Disease.fromJson(jsonDecode(await bundle.loadString('$bundledRoot/$id.json')));
        } catch (e) {
          debugPrint('Bundled content "$id" invalid: $e');
        }
      }
      final downloaded = dir == null ? null : _tryParse(File('${dir.path}/$id.json'), Disease.fromJson);
      // A file can only ever stand in for its own topic.
      final best = [bundled, downloaded].whereType<Disease>().where((d) => d.id == id).fold<Disease?>(
            null,
            (a, b) => a == null || b.version > a.version ? b : a,
          );
      if (best != null) diseases[id] = best;
    }

    _manifest = manifest;
    _diseases
      ..clear()
      ..addAll(diseases);
    notifyListeners();
  }

  /// Home cards in display order. A group card appears once at least one of
  /// its topics is available.
  List<HomeItem> get homeItems {
    if (_manifest == null) return const [];
    final items = <HomeItem>[];
    for (final g in manifest.groups.values) {
      final members = [for (final id in g.members) ?_diseases[id]];
      if (members.isNotEmpty) items.add(GroupItem(g, members));
    }
    for (final d in _diseases.values) {
      if (d.group == null || !manifest.groups.containsKey(d.group)) items.add(DiseaseItem(d));
    }
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  TopicGroup? group(String id) => _manifest?.groups[id];

  List<Disease> membersOf(TopicGroup g) => [for (final id in g.members) ?_diseases[id]];

  ToolLinkStatus toolStatus(ToolApp app) => _manifest?.toolLinks[app] ?? ToolLinkStatus.hidden;

  /// Stores already-validated downloaded content, then reloads. Each file is
  /// written to a temp name and renamed, so a crash mid-write can't leave a
  /// half-written file behind.
  Future<void> saveDownloaded({
    Map<String, dynamic>? manifestJson,
    Map<String, Map<String, dynamic>> diseaseJson = const {},
  }) async {
    final dir = await _contentDir();
    if (dir == null) return;
    for (final e in diseaseJson.entries) {
      await _writeAtomic(File('${dir.path}/${e.key}.json'), jsonEncode(e.value));
    }
    if (manifestJson != null) {
      await _writeAtomic(File('${dir.path}/manifest.json'), jsonEncode(manifestJson));
    }
    await load();
  }

  Future<Directory?> _contentDir() async {
    final base = await cacheDir();
    if (base == null) return null;
    final dir = Directory('${base.path}/content');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static T? _tryParse<T>(File file, T Function(Object?) parse) {
    try {
      if (!file.existsSync()) return null;
      return parse(jsonDecode(file.readAsStringSync()));
    } catch (e) {
      debugPrint('Ignoring invalid downloaded content ${file.path}: $e');
      return null;
    }
  }

  static Future<void> _writeAtomic(File file, String contents) async {
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(contents, flush: true);
    await tmp.rename(file.path);
  }
}
