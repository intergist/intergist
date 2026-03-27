import 'dart:convert';

enum CueKind { dialogue, riff, userRiff, marker, transition }

enum CueMode { displayOnly, speak, displayAndSpeak }

enum SpeakerRole { app, user, narrator }

class CueEventModel {
  final String id;
  final String trackId;
  final String track; // "reference", "riff", "user_riff"
  final int startMs;
  final int endMs;
  final String text;
  final CueKind kind;
  final CueMode mode;
  final int priority;
  final SpeakerRole speakerRole;
  final String? windowRef;
  final bool interruptible;
  final bool enabled;
  final String? sourceFile;
  final int? sourceIndex;
  final List<String> tags;

  const CueEventModel({
    required this.id,
    required this.trackId,
    required this.track,
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.kind,
    required this.mode,
    required this.priority,
    required this.speakerRole,
    this.windowRef,
    required this.interruptible,
    required this.enabled,
    this.sourceFile,
    this.sourceIndex,
    this.tags = const [],
  });

  CueEventModel copyWith({
    String? id,
    String? trackId,
    String? track,
    int? startMs,
    int? endMs,
    String? text,
    CueKind? kind,
    CueMode? mode,
    int? priority,
    SpeakerRole? speakerRole,
    String? windowRef,
    bool? interruptible,
    bool? enabled,
    String? sourceFile,
    int? sourceIndex,
    List<String>? tags,
  }) {
    return CueEventModel(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      track: track ?? this.track,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      text: text ?? this.text,
      kind: kind ?? this.kind,
      mode: mode ?? this.mode,
      priority: priority ?? this.priority,
      speakerRole: speakerRole ?? this.speakerRole,
      windowRef: windowRef ?? this.windowRef,
      interruptible: interruptible ?? this.interruptible,
      enabled: enabled ?? this.enabled,
      sourceFile: sourceFile ?? this.sourceFile,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'track': track,
      'startMs': startMs,
      'endMs': endMs,
      'text': text,
      'kind': kind.name,
      'mode': mode.name,
      'priority': priority,
      'speakerRole': speakerRole.name,
      'windowRef': windowRef,
      'interruptible': interruptible ? 1 : 0,
      'enabled': enabled ? 1 : 0,
      'sourceFile': sourceFile,
      'sourceIndex': sourceIndex,
      'tags': jsonEncode(tags),
    };
  }

  factory CueEventModel.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'];
    List<String> parsedTags;
    if (rawTags is String) {
      parsedTags = (jsonDecode(rawTags) as List<dynamic>).cast<String>();
    } else if (rawTags is List) {
      parsedTags = rawTags.cast<String>();
    } else {
      parsedTags = [];
    }

    return CueEventModel(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      track: map['track'] as String,
      startMs: map['startMs'] as int,
      endMs: map['endMs'] as int,
      text: map['text'] as String,
      kind: CueKind.values.firstWhere(
        (e) => e.name == map['kind'],
      ),
      mode: CueMode.values.firstWhere(
        (e) => e.name == map['mode'],
      ),
      priority: map['priority'] as int,
      speakerRole: SpeakerRole.values.firstWhere(
        (e) => e.name == map['speakerRole'],
      ),
      windowRef: map['windowRef'] as String?,
      interruptible: map['interruptible'] == 1 || map['interruptible'] == true,
      enabled: map['enabled'] == 1 || map['enabled'] == true,
      sourceFile: map['sourceFile'] as String?,
      sourceIndex: map['sourceIndex'] as int?,
      tags: parsedTags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CueEventModel) return false;
    if (other.id != id ||
        other.trackId != trackId ||
        other.track != track ||
        other.startMs != startMs ||
        other.endMs != endMs ||
        other.text != text ||
        other.kind != kind ||
        other.mode != mode ||
        other.priority != priority ||
        other.speakerRole != speakerRole ||
        other.windowRef != windowRef ||
        other.interruptible != interruptible ||
        other.enabled != enabled ||
        other.sourceFile != sourceFile ||
        other.sourceIndex != sourceIndex) {
      return false;
    }
    if (other.tags.length != tags.length) return false;
    for (int i = 0; i < tags.length; i++) {
      if (other.tags[i] != tags[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      trackId,
      track,
      startMs,
      endMs,
      text,
      kind,
      mode,
      priority,
      speakerRole,
      windowRef,
      interruptible,
      enabled,
      sourceFile,
      sourceIndex,
      Object.hashAll(tags),
    );
  }

  @override
  String toString() {
    return 'CueEventModel(id: $id, trackId: $trackId, track: $track, '
        'startMs: $startMs, endMs: $endMs, text: $text, kind: $kind, '
        'mode: $mode, priority: $priority, speakerRole: $speakerRole, '
        'windowRef: $windowRef, interruptible: $interruptible, '
        'enabled: $enabled, sourceFile: $sourceFile, '
        'sourceIndex: $sourceIndex, tags: $tags)';
  }
}
