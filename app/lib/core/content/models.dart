/// Content model for LiveHealthy: Know Your Disease (design §3, §7).
///
/// Pure Dart: the same classes parse the bundled JSON in assets/content/ and
/// documents downloaded from Firestore. Parsing is strict about what the
/// screens need (both languages, resolvable references) and lenient about
/// what they don't: unknown block types are skipped, so older app versions
/// keep working when a new block type is introduced (§12).
library;

/// Languages every text field must carry. Adding a third language later means
/// adding its code here and to the content files.
const List<String> kContentLanguages = ['en', 'ur'];

/// The five written sections, in reading order. References (6) and
/// "Track it" (7) are built by the app from the disease's reference list
/// and related tools.
const List<String> kSectionIds = ['whatIs', 'causes', 'complications', 'lifestyle', 'whenToSeeDoctor'];

class ContentFormatException extends FormatException {
  ContentFormatException(super.message);
}

Never _fail(String message) => throw ContentFormatException(message);

Map<String, dynamic> _map(Object? v, String where) {
  if (v is Map) return v.cast<String, dynamic>();
  _fail('$where: expected an object');
}

List<dynamic> _list(Object? v, String where) {
  if (v is List) return v;
  _fail('$where: expected a list');
}

String _string(Object? v, String where) {
  if (v is String && v.trim().isNotEmpty) return v;
  _fail('$where: expected a non-empty string');
}

int _int(Object? v, String where) {
  if (v is int) return v;
  if (v is num && v == v.roundToDouble()) return v.toInt();
  _fail('$where: expected an integer');
}

List<String> _refIds(Object? v, String where) {
  if (v == null) return const [];
  return [for (final (i, r) in _list(v, where).indexed) _string(r, '$where[$i]')];
}

/// A piece of text stored in every supported language: `{ "en": ..., "ur": ... }`.
class LocalizedText {
  final Map<String, String> values;

  const LocalizedText(this.values);

  factory LocalizedText.fromJson(Object? json, String where) {
    final m = _map(json, where);
    final values = <String, String>{};
    for (final lang in kContentLanguages) {
      values[lang] = _string(m[lang], '$where.$lang');
    }
    return LocalizedText(values);
  }

  static LocalizedText? optional(Object? json, String where) =>
      json == null ? null : LocalizedText.fromJson(json, where);

  /// Falls back to English, so a missing translation can never blank a screen.
  String of(String languageCode) => values[languageCode] ?? values['en'] ?? '';

  Map<String, dynamic> toJson() => Map.of(values);
}

// ---------------------------------------------------------------- blocks

sealed class ContentBlock {
  const ContentBlock();

  /// Reference ids this block cites.
  List<String> get refs;

  /// Returns null for block types this app version doesn't know (skipped).
  static ContentBlock? fromJson(Object? json, String where) {
    final m = _map(json, where);
    final type = _string(m['type'], '$where.type');
    switch (type) {
      case 'paragraph':
        return ParagraphBlock(LocalizedText.fromJson(m['text'], '$where.text'), _refIds(m['refs'], '$where.refs'));
      case 'bullets':
        final items = _list(m['items'], '$where.items');
        if (items.isEmpty) _fail('$where.items: empty');
        return BulletsBlock(
          title: LocalizedText.optional(m['title'], '$where.title'),
          items: [for (final (i, it) in items.indexed) LocalizedText.fromJson(it, '$where.items[$i]')],
          refs: _refIds(m['refs'], '$where.refs'),
        );
      case 'image':
        return ImageBlock(
          assetKey: _string(m['assetKey'], '$where.assetKey'),
          caption: LocalizedText.fromJson(m['caption'], '$where.caption'),
          refs: _refIds(m['refs'], '$where.refs'),
        );
      case 'keyNumber':
        return KeyNumberBlock(
          label: LocalizedText.fromJson(m['label'], '$where.label'),
          value: LocalizedText.fromJson(m['value'], '$where.value'),
          note: LocalizedText.optional(m['note'], '$where.note'),
          level: KeyLevel.parse(m['level'], '$where.level'),
          refs: _refIds(m['refs'], '$where.refs'),
        );
      case 'alert':
        final items = m['items'] == null ? const <dynamic>[] : _list(m['items'], '$where.items');
        return AlertBlock(
          level: AlertLevel.parse(m['level'], '$where.level'),
          title: LocalizedText.fromJson(m['title'], '$where.title'),
          text: LocalizedText.optional(m['text'], '$where.text'),
          items: [for (final (i, it) in items.indexed) LocalizedText.fromJson(it, '$where.items[$i]')],
          refs: _refIds(m['refs'], '$where.refs'),
        );
      case 'refMarker':
        final refs = _refIds(m['refs'], '$where.refs');
        if (refs.isEmpty) _fail('$where.refs: empty');
        return RefMarkerBlock(refs);
      default:
        return null;
    }
  }
}

class ParagraphBlock extends ContentBlock {
  final LocalizedText text;
  @override
  final List<String> refs;
  const ParagraphBlock(this.text, this.refs);
}

class BulletsBlock extends ContentBlock {
  final LocalizedText? title;
  final List<LocalizedText> items;
  @override
  final List<String> refs;
  const BulletsBlock({this.title, required this.items, required this.refs});
}

class ImageBlock extends ContentBlock {
  /// File name under assets/graphics/. Graphics ship inside the app (§7).
  final String assetKey;
  final LocalizedText caption;
  @override
  final List<String> refs;
  const ImageBlock({required this.assetKey, required this.caption, required this.refs});
}

/// Same three levels and colours as the Vitals flags (§8).
enum KeyLevel {
  normal,
  caution,
  alert,
  neutral;

  static KeyLevel parse(Object? v, String where) {
    if (v == null) return KeyLevel.neutral;
    for (final l in values) {
      if (l.name == v) return l;
    }
    _fail('$where: unknown level "$v"');
  }
}

class KeyNumberBlock extends ContentBlock {
  final LocalizedText label;
  final LocalizedText value;
  final LocalizedText? note;
  final KeyLevel level;
  @override
  final List<String> refs;
  const KeyNumberBlock({required this.label, required this.value, this.note, required this.level, required this.refs});
}

/// The two "When to see a doctor" levels (§3.5).
enum AlertLevel {
  urgent,
  soon;

  static AlertLevel parse(Object? v, String where) {
    for (final l in values) {
      if (l.name == v) return l;
    }
    _fail('$where: unknown alert level "$v"');
  }
}

class AlertBlock extends ContentBlock {
  final AlertLevel level;
  final LocalizedText title;
  final LocalizedText? text;
  final List<LocalizedText> items;
  @override
  final List<String> refs;
  const AlertBlock({required this.level, required this.title, this.text, required this.items, required this.refs});
}

class RefMarkerBlock extends ContentBlock {
  @override
  final List<String> refs;
  const RefMarkerBlock(this.refs);
}

// ------------------------------------------------------ disease structure

class ContentSection {
  final String id;
  final LocalizedText title;
  final List<ContentBlock> blocks;

  const ContentSection({required this.id, required this.title, required this.blocks});

  Iterable<String> get citedRefs => blocks.expand((b) => b.refs);
}

class Reference {
  final String id;
  final String org;
  final String title;
  final int year;
  final String url;

  /// When the link was last checked (ISO date) — shown so an old or dead
  /// link is still an honest citation (§4.3).
  final String checkedOn;

  const Reference({
    required this.id,
    required this.org,
    required this.title,
    required this.year,
    required this.url,
    required this.checkedOn,
  });

  factory Reference.fromJson(Object? json, String where) {
    final m = _map(json, where);
    final url = _string(m['url'], '$where.url');
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) _fail('$where.url: must be an https link');
    return Reference(
      id: _string(m['id'], '$where.id'),
      org: _string(m['org'], '$where.org'),
      title: _string(m['title'], '$where.title'),
      year: _int(m['year'], '$where.year'),
      url: url,
      checkedOn: _string(m['checkedOn'], '$where.checkedOn'),
    );
  }
}

/// The sibling LiveHealthy apps a disease can link to (§9).
enum ToolApp {
  vitals('com.homilabs.livehealthy_vitals'),
  medicineReminder('com.homilabs.medicine_reminder');

  final String packageName;
  const ToolApp(this.packageName);

  static ToolApp? tryParse(Object? v) {
    for (final t in values) {
      if (t.name == v) return t;
    }
    return null;
  }
}

class RelatedTool {
  final ToolApp app;

  /// What to track there, e.g. "Track your blood pressure".
  final LocalizedText label;

  const RelatedTool(this.app, this.label);
}

class Disease {
  final String id;
  final int version;
  final int order;
  final String? group;
  final LocalizedText title;
  final LocalizedText summary;
  final String headerAsset;
  final LocalizedText reviewedBy;
  final String reviewedOn;
  final String nextReviewDue;
  final List<ContentSection> sections;
  final List<Reference> references;
  final List<RelatedTool> relatedTools;

  const Disease({
    required this.id,
    required this.version,
    required this.order,
    required this.group,
    required this.title,
    required this.summary,
    required this.headerAsset,
    required this.reviewedBy,
    required this.reviewedOn,
    required this.nextReviewDue,
    required this.sections,
    required this.references,
    required this.relatedTools,
  });

  /// Parses and validates one disease document. Throws
  /// [ContentFormatException] on anything the app can't show safely, so a
  /// bad download is rejected and the previous copy stays in use (§7 step 4).
  factory Disease.fromJson(Object? json) {
    final m = _map(json, 'disease');
    final id = _string(m['id'], 'disease.id');
    final w = 'disease[$id]';
    if (m['status'] != 'published') _fail('$w.status: not published');

    final references = [
      for (final (i, r) in _list(m['references'], '$w.references').indexed) Reference.fromJson(r, '$w.references[$i]'),
    ];
    final refIds = <String>{};
    for (final r in references) {
      if (!refIds.add(r.id)) _fail('$w: duplicate reference id "${r.id}"');
    }

    final sectionsJson = _list(m['sections'], '$w.sections');
    final sections = <ContentSection>[];
    for (final (i, s) in sectionsJson.indexed) {
      final sm = _map(s, '$w.sections[$i]');
      final sid = _string(sm['id'], '$w.sections[$i].id');
      final blocks = <ContentBlock>[];
      for (final (j, b) in _list(sm['blocks'], '$w.$sid.blocks').indexed) {
        final block = ContentBlock.fromJson(b, '$w.$sid.blocks[$j]');
        if (block != null) blocks.add(block);
      }
      sections.add(
        ContentSection(id: sid, title: LocalizedText.fromJson(sm['title'], '$w.$sid.title'), blocks: blocks),
      );
    }
    // Same seven-part structure for every disease (§3).
    final ids = sections.map((s) => s.id).toList();
    if (ids.join(',') != kSectionIds.join(',')) {
      _fail('$w.sections: expected ${kSectionIds.join(', ')} in that order, got ${ids.join(', ')}');
    }
    for (final s in sections) {
      if (s.blocks.isEmpty) _fail('$w.${s.id}: no blocks');
      // "No reference, no publish" (§4.1).
      final cited = s.citedRefs.toList();
      if (cited.isEmpty) _fail('$w.${s.id}: cites no reference');
      for (final r in cited) {
        if (!refIds.contains(r)) _fail('$w.${s.id}: unknown reference "$r"');
      }
    }

    final tools = <RelatedTool>[];
    for (final (i, t) in (m['relatedTools'] == null ? const [] : _list(m['relatedTools'], '$w.relatedTools')).indexed) {
      final tm = _map(t, '$w.relatedTools[$i]');
      final app = ToolApp.tryParse(tm['tool']);
      if (app == null) continue; // a tool this version doesn't know yet
      tools.add(RelatedTool(app, LocalizedText.fromJson(tm['label'], '$w.relatedTools[$i].label')));
    }

    final group = m['group'];
    return Disease(
      id: id,
      version: _int(m['version'], '$w.version'),
      order: _int(m['order'], '$w.order'),
      group: group == null ? null : _string(group, '$w.group'),
      title: LocalizedText.fromJson(m['title'], '$w.title'),
      summary: LocalizedText.fromJson(m['summary'], '$w.summary'),
      headerAsset: _string(m['headerAsset'], '$w.headerAsset'),
      reviewedBy: LocalizedText.fromJson(m['reviewedBy'], '$w.reviewedBy'),
      reviewedOn: _string(m['reviewedOn'], '$w.reviewedOn'),
      nextReviewDue: _string(m['nextReviewDue'], '$w.nextReviewDue'),
      sections: sections,
      references: references,
      relatedTools: tools,
    );
  }

  /// 1-based number shown in the [n] markers.
  int refNumber(String refId) => references.indexWhere((r) => r.id == refId) + 1;

  Reference? refById(String refId) {
    for (final r in references) {
      if (r.id == refId) return r;
    }
    return null;
  }
}

/// Topics that share one Home card (D13), e.g. the three diabetes topics.
class TopicGroup {
  final String id;
  final int order;
  final LocalizedText title;
  final LocalizedText summary;
  final String headerAsset;
  final LocalizedText? note;
  final List<String> members;

  const TopicGroup({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
    required this.headerAsset,
    this.note,
    required this.members,
  });

  factory TopicGroup.fromJson(String id, Object? json) {
    final w = 'groups[$id]';
    final m = _map(json, w);
    return TopicGroup(
      id: id,
      order: _int(m['order'], '$w.order'),
      title: LocalizedText.fromJson(m['title'], '$w.title'),
      summary: LocalizedText.fromJson(m['summary'], '$w.summary'),
      headerAsset: _string(m['headerAsset'], '$w.headerAsset'),
      note: LocalizedText.optional(m['note'], '$w.note'),
      members: [for (final (i, x) in _list(m['members'], '$w.members').indexed) _string(x, '$w.members[$i]')],
    );
  }
}

/// Whether a "Track it" button is shown, and how (§9). Remote-switchable.
enum ToolLinkStatus {
  live,
  comingSoon,
  hidden;

  static ToolLinkStatus parse(Object? v) {
    for (final s in values) {
      if (s.name == v) return s;
    }
    return ToolLinkStatus.hidden;
  }
}

class ContentManifest {
  final int contentVersion;
  final int minAppVersion;
  final Map<String, int> diseases;
  final Map<String, TopicGroup> groups;
  final Map<ToolApp, ToolLinkStatus> toolLinks;
  final String updatedAt;

  const ContentManifest({
    required this.contentVersion,
    required this.minAppVersion,
    required this.diseases,
    required this.groups,
    required this.toolLinks,
    required this.updatedAt,
  });

  factory ContentManifest.fromJson(Object? json) {
    final m = _map(json, 'manifest');
    final diseases = <String, int>{
      for (final e in _map(m['diseases'], 'manifest.diseases').entries) e.key: _int(e.value, 'manifest.diseases.${e.key}'),
    };
    final groups = <String, TopicGroup>{
      for (final e in (m['groups'] == null ? const <String, dynamic>{} : _map(m['groups'], 'manifest.groups')).entries)
        e.key: TopicGroup.fromJson(e.key, e.value),
    };
    final links = m['toolLinks'] == null ? const <String, dynamic>{} : _map(m['toolLinks'], 'manifest.toolLinks');
    return ContentManifest(
      contentVersion: _int(m['contentVersion'], 'manifest.contentVersion'),
      minAppVersion: _int(m['minAppVersion'] ?? 1, 'manifest.minAppVersion'),
      diseases: diseases,
      groups: groups,
      toolLinks: {for (final t in ToolApp.values) t: ToolLinkStatus.parse(links[t.name])},
      updatedAt: (m['updatedAt'] as String?) ?? '',
    );
  }
}
