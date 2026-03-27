enum TrackType { reference, riff, userRiff }

class Track {
  final String id;
  final String projectId;
  final String filename;
  final TrackType type;
  final String language;
  final int cueCount;
  final bool isEnabled;
  final String? source;
  final String? hashSha256;
  final DateTime createdAt;

  const Track({
    required this.id,
    required this.projectId,
    required this.filename,
    required this.type,
    required this.language,
    required this.cueCount,
    required this.isEnabled,
    this.source,
    this.hashSha256,
    required this.createdAt,
  });

  Track copyWith({
    String? id,
    String? projectId,
    String? filename,
    TrackType? type,
    String? language,
    int? cueCount,
    bool? isEnabled,
    String? source,
    String? hashSha256,
    DateTime? createdAt,
  }) {
    return Track(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      filename: filename ?? this.filename,
      type: type ?? this.type,
      language: language ?? this.language,
      cueCount: cueCount ?? this.cueCount,
      isEnabled: isEnabled ?? this.isEnabled,
      source: source ?? this.source,
      hashSha256: hashSha256 ?? this.hashSha256,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'filename': filename,
      'type': type.name,
      'language': language,
      'cueCount': cueCount,
      'isEnabled': isEnabled ? 1 : 0,
      'source': source,
      'hashSha256': hashSha256,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      filename: map['filename'] as String,
      type: TrackType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      language: map['language'] as String,
      cueCount: map['cueCount'] as int,
      isEnabled: map['isEnabled'] == 1 || map['isEnabled'] == true,
      source: map['source'] as String?,
      hashSha256: map['hashSha256'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track &&
        other.id == id &&
        other.projectId == projectId &&
        other.filename == filename &&
        other.type == type &&
        other.language == language &&
        other.cueCount == cueCount &&
        other.isEnabled == isEnabled &&
        other.source == source &&
        other.hashSha256 == hashSha256 &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      filename,
      type,
      language,
      cueCount,
      isEnabled,
      source,
      hashSha256,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'Track(id: $id, projectId: $projectId, filename: $filename, '
        'type: $type, language: $language, cueCount: $cueCount, '
        'isEnabled: $isEnabled, source: $source, hashSha256: $hashSha256, '
        'createdAt: $createdAt)';
  }
}
