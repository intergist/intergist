/// A participation window representing a time range where user
/// interaction (recording, speaking) is allowed.
///
/// Windows are computed from gaps in the reference dialogue track.
/// [startMs]/[endMs] represent the effective open/close times.
class ParticipationWindowModel {
  /// Unique identifier for this window.
  final String id;

  /// When the effective window opens (ms in playback time).
  final int startMs;

  /// When the effective window closes (ms in playback time).
  final int endMs;

  /// Description of how this window was predicted.
  final String predictedFrom;

  /// Lead-in duration (ms) before the window opens.
  final int stateLeadInMs;

  /// Lead-out duration (ms) before the window closes.
  final int stateLeadOutMs;

  /// Minimum gap duration that qualifies as a window (ms).
  final int minOpenMs;

  /// Maximum user riff capture duration (ms).
  final int maxUserRiffMs;

  /// Whether app speech is allowed during this window.
  final bool allowAppSpeech;

  /// Whether user capture is allowed during this window.
  final bool allowUserCapture;

  const ParticipationWindowModel({
    required this.id,
    required this.startMs,
    required this.endMs,
    required this.predictedFrom,
    required this.stateLeadInMs,
    required this.stateLeadOutMs,
    required this.minOpenMs,
    required this.maxUserRiffMs,
    required this.allowAppSpeech,
    required this.allowUserCapture,
  });

  /// Alias for [startMs] — when the window opens.
  int get openMs => startMs;

  /// Alias for [endMs] — when the window closes.
  int get closeMs => endMs;

  /// Duration of the effective open window in milliseconds.
  int get durationMs => endMs - startMs;

  ParticipationWindowModel copyWith({
    String? id,
    int? startMs,
    int? endMs,
    String? predictedFrom,
    int? stateLeadInMs,
    int? stateLeadOutMs,
    int? minOpenMs,
    int? maxUserRiffMs,
    bool? allowAppSpeech,
    bool? allowUserCapture,
  }) {
    return ParticipationWindowModel(
      id: id ?? this.id,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      predictedFrom: predictedFrom ?? this.predictedFrom,
      stateLeadInMs: stateLeadInMs ?? this.stateLeadInMs,
      stateLeadOutMs: stateLeadOutMs ?? this.stateLeadOutMs,
      minOpenMs: minOpenMs ?? this.minOpenMs,
      maxUserRiffMs: maxUserRiffMs ?? this.maxUserRiffMs,
      allowAppSpeech: allowAppSpeech ?? this.allowAppSpeech,
      allowUserCapture: allowUserCapture ?? this.allowUserCapture,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startMs': startMs,
      'endMs': endMs,
      'predictedFrom': predictedFrom,
      'stateLeadInMs': stateLeadInMs,
      'stateLeadOutMs': stateLeadOutMs,
      'minOpenMs': minOpenMs,
      'maxUserRiffMs': maxUserRiffMs,
      'allowAppSpeech': allowAppSpeech ? 1 : 0,
      'allowUserCapture': allowUserCapture ? 1 : 0,
    };
  }

  factory ParticipationWindowModel.fromMap(Map<String, dynamic> map) {
    return ParticipationWindowModel(
      id: map['id'] as String,
      startMs: map['startMs'] as int,
      endMs: map['endMs'] as int,
      predictedFrom: map['predictedFrom'] as String,
      stateLeadInMs: map['stateLeadInMs'] as int,
      stateLeadOutMs: map['stateLeadOutMs'] as int,
      minOpenMs: map['minOpenMs'] as int,
      maxUserRiffMs: map['maxUserRiffMs'] as int,
      allowAppSpeech:
          map['allowAppSpeech'] == 1 || map['allowAppSpeech'] == true,
      allowUserCapture:
          map['allowUserCapture'] == 1 || map['allowUserCapture'] == true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipationWindowModel &&
        other.id == id &&
        other.startMs == startMs &&
        other.endMs == endMs &&
        other.predictedFrom == predictedFrom &&
        other.stateLeadInMs == stateLeadInMs &&
        other.stateLeadOutMs == stateLeadOutMs &&
        other.minOpenMs == minOpenMs &&
        other.maxUserRiffMs == maxUserRiffMs &&
        other.allowAppSpeech == allowAppSpeech &&
        other.allowUserCapture == allowUserCapture;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      startMs,
      endMs,
      predictedFrom,
      stateLeadInMs,
      stateLeadOutMs,
      minOpenMs,
      maxUserRiffMs,
      allowAppSpeech,
      allowUserCapture,
    );
  }

  @override
  String toString() {
    return 'ParticipationWindowModel(id: $id, startMs: $startMs, '
        'endMs: $endMs, predictedFrom: $predictedFrom, '
        'stateLeadInMs: $stateLeadInMs, stateLeadOutMs: $stateLeadOutMs, '
        'minOpenMs: $minOpenMs, maxUserRiffMs: $maxUserRiffMs, '
        'allowAppSpeech: $allowAppSpeech, '
        'allowUserCapture: $allowUserCapture)';
  }
}
