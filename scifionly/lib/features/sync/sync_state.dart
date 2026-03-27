/// Sync state definitions for the sync engine.
///
/// The sync engine transitions between states as it tracks the user's
/// playback position relative to the cue timeline.
library;

/// Possible states of the sync engine.
enum SyncState {
  /// No sync lock acquired. The engine does not know the playback position.
  unlocked,

  /// Sync is locked with high confidence.
  locked,

  /// Sync was locked but confidence has degraded (e.g., drift detected).
  degraded,

  /// The engine lost sync and is attempting to reacquire lock.
  reacquiring,
}

/// Snapshot of the current sync engine state.
class SyncStateData {
  /// The current sync state.
  final SyncState state;

  /// Confidence level 0.0–1.0 that the position is correct.
  final double confidence;

  /// Best estimate of the current playback position in milliseconds.
  final int estimatedPositionMs;

  /// Measured drift from the expected position in milliseconds.
  /// Positive = ahead, negative = behind.
  final int driftMs;

  /// When this state snapshot was produced.
  final DateTime lastUpdateTime;

  const SyncStateData({
    required this.state,
    required this.confidence,
    required this.estimatedPositionMs,
    required this.driftMs,
    required this.lastUpdateTime,
  });

  /// Create a copy with optional overrides.
  SyncStateData copyWith({
    SyncState? state,
    double? confidence,
    int? estimatedPositionMs,
    int? driftMs,
    DateTime? lastUpdateTime,
  }) {
    return SyncStateData(
      state: state ?? this.state,
      confidence: confidence ?? this.confidence,
      estimatedPositionMs: estimatedPositionMs ?? this.estimatedPositionMs,
      driftMs: driftMs ?? this.driftMs,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  /// Whether the engine considers itself locked (locked or degraded).
  bool get isTracking =>
      state == SyncState.locked || state == SyncState.degraded;

  @override
  String toString() {
    return 'SyncStateData(state: ${state.name}, confidence: '
        '${confidence.toStringAsFixed(2)}, position: ${estimatedPositionMs}ms, '
        'drift: ${driftMs}ms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncStateData &&
        other.state == state &&
        other.confidence == confidence &&
        other.estimatedPositionMs == estimatedPositionMs &&
        other.driftMs == driftMs;
  }

  @override
  int get hashCode =>
      Object.hash(state, confidence, estimatedPositionMs, driftMs);
}
