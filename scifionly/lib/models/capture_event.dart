class CaptureEvent {
  final String id;
  final String sessionId;
  final String? windowId;
  final int startMs;
  final int endMs;
  final String transcriptText;
  final bool isFinal;
  final DateTime capturedAt;

  const CaptureEvent({
    required this.id,
    required this.sessionId,
    this.windowId,
    required this.startMs,
    required this.endMs,
    required this.transcriptText,
    required this.isFinal,
    required this.capturedAt,
  });

  CaptureEvent copyWith({
    String? id,
    String? sessionId,
    String? windowId,
    int? startMs,
    int? endMs,
    String? transcriptText,
    bool? isFinal,
    DateTime? capturedAt,
  }) {
    return CaptureEvent(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      windowId: windowId ?? this.windowId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      transcriptText: transcriptText ?? this.transcriptText,
      isFinal: isFinal ?? this.isFinal,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'windowId': windowId,
      'startMs': startMs,
      'endMs': endMs,
      'transcriptText': transcriptText,
      'isFinal': isFinal ? 1 : 0,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }

  factory CaptureEvent.fromMap(Map<String, dynamic> map) {
    return CaptureEvent(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      windowId: map['windowId'] as String?,
      startMs: map['startMs'] as int,
      endMs: map['endMs'] as int,
      transcriptText: map['transcriptText'] as String,
      isFinal: map['isFinal'] == 1 || map['isFinal'] == true,
      capturedAt: DateTime.parse(map['capturedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptureEvent &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.windowId == windowId &&
        other.startMs == startMs &&
        other.endMs == endMs &&
        other.transcriptText == transcriptText &&
        other.isFinal == isFinal &&
        other.capturedAt == capturedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      windowId,
      startMs,
      endMs,
      transcriptText,
      isFinal,
      capturedAt,
    );
  }

  @override
  String toString() {
    return 'CaptureEvent(id: $id, sessionId: $sessionId, '
        'windowId: $windowId, startMs: $startMs, endMs: $endMs, '
        'transcriptText: $transcriptText, isFinal: $isFinal, '
        'capturedAt: $capturedAt)';
  }
}
