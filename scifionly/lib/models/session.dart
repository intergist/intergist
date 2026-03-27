enum SessionMode { standard, recording }

enum SessionState { idle, active, paused, completed, abandoned }

class Session {
  final String id;
  final String projectId;
  final SessionMode mode;
  final SessionState state;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? lastPositionMs;

  const Session({
    required this.id,
    required this.projectId,
    required this.mode,
    required this.state,
    required this.startedAt,
    this.endedAt,
    this.lastPositionMs,
  });

  Session copyWith({
    String? id,
    String? projectId,
    SessionMode? mode,
    SessionState? state,
    DateTime? startedAt,
    DateTime? endedAt,
    int? lastPositionMs,
  }) {
    return Session(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'mode': mode.name,
      'state': state.name,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'lastPositionMs': lastPositionMs,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      mode: SessionMode.values.firstWhere(
        (e) => e.name == map['mode'],
      ),
      state: SessionState.values.firstWhere(
        (e) => e.name == map['state'],
      ),
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: map['endedAt'] != null
          ? DateTime.parse(map['endedAt'] as String)
          : null,
      lastPositionMs: map['lastPositionMs'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.id == id &&
        other.projectId == projectId &&
        other.mode == mode &&
        other.state == state &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.lastPositionMs == lastPositionMs;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      mode,
      state,
      startedAt,
      endedAt,
      lastPositionMs,
    );
  }

  @override
  String toString() {
    return 'Session(id: $id, projectId: $projectId, mode: $mode, '
        'state: $state, startedAt: $startedAt, endedAt: $endedAt, '
        'lastPositionMs: $lastPositionMs)';
  }
}
