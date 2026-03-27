class SyncSnapshot {
  final String id;
  final String sessionId;
  final int estimatedPositionMs;
  final double confidence;
  final int driftMs;
  final DateTime timestamp;

  const SyncSnapshot({
    required this.id,
    required this.sessionId,
    required this.estimatedPositionMs,
    required this.confidence,
    required this.driftMs,
    required this.timestamp,
  });

  SyncSnapshot copyWith({
    String? id,
    String? sessionId,
    int? estimatedPositionMs,
    double? confidence,
    int? driftMs,
    DateTime? timestamp,
  }) {
    return SyncSnapshot(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      estimatedPositionMs: estimatedPositionMs ?? this.estimatedPositionMs,
      confidence: confidence ?? this.confidence,
      driftMs: driftMs ?? this.driftMs,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'estimatedPositionMs': estimatedPositionMs,
      'confidence': confidence,
      'driftMs': driftMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncSnapshot.fromMap(Map<String, dynamic> map) {
    return SyncSnapshot(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      estimatedPositionMs: map['estimatedPositionMs'] as int,
      confidence: (map['confidence'] as num).toDouble(),
      driftMs: map['driftMs'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncSnapshot &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.estimatedPositionMs == estimatedPositionMs &&
        other.confidence == confidence &&
        other.driftMs == driftMs &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      estimatedPositionMs,
      confidence,
      driftMs,
      timestamp,
    );
  }

  @override
  String toString() {
    return 'SyncSnapshot(id: $id, sessionId: $sessionId, '
        'estimatedPositionMs: $estimatedPositionMs, '
        'confidence: $confidence, driftMs: $driftMs, '
        'timestamp: $timestamp)';
  }
}
