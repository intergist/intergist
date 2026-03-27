/// Utility extensions on [CueEventModel].
///
/// Provides convenience getters and helpers for working with cue events
/// in the cue engine.
library;

import 'package:scifionly/models/cue_event_model.dart';

/// Extension methods for [CueEventModel].
extension CueEventExtensions on CueEventModel {
  /// Duration of this cue in milliseconds.
  int get durationMs => endMs - startMs;

  /// Whether this cue overlaps with [other] in time.
  bool overlapsWith(CueEventModel other) {
    return startMs < other.endMs && endMs > other.startMs;
  }

  /// Whether this cue contains the given [positionMs].
  bool containsPosition(int positionMs) {
    return positionMs >= startMs && positionMs < endMs;
  }

  /// Whether this cue is active (enabled and has non-empty text).
  bool get isActive => enabled && text.isNotEmpty;

  /// Whether this cue is a spoken cue.
  bool get isSpoken =>
      mode == CueMode.speak || mode == CueMode.displayAndSpeak;

  /// Whether this cue is display-only.
  bool get isDisplayOnly => mode == CueMode.displayOnly;

  /// Whether this cue was authored by the app (pre-authored).
  bool get isAppCue => speakerRole == SpeakerRole.app;

  /// Whether this cue was recorded by the user.
  bool get isUserCue => speakerRole == SpeakerRole.user;
}

/// Utility functions for working with lists of [CueEventModel].
class CueEventUtils {
  CueEventUtils._();

  /// Find all cues in [cues] that overlap with the time range
  /// [startMs] to [endMs].
  static List<CueEventModel> findOverlapping(
    List<CueEventModel> cues,
    int startMs,
    int endMs,
  ) {
    return cues
        .where((c) => c.startMs < endMs && c.endMs > startMs)
        .toList();
  }

  /// Find the cue in [cues] that contains [positionMs], or null.
  static CueEventModel? findAt(List<CueEventModel> cues, int positionMs) {
    for (final cue in cues) {
      if (positionMs >= cue.startMs && positionMs < cue.endMs) {
        return cue;
      }
    }
    return null;
  }

  /// Sort cues by start time, then by source index for stability.
  static List<CueEventModel> sortByTime(List<CueEventModel> cues) {
    final sorted = List<CueEventModel>.from(cues);
    sorted.sort((a, b) {
      final cmp = a.startMs.compareTo(b.startMs);
      if (cmp != 0) return cmp;
      return (a.sourceIndex ?? 0).compareTo(b.sourceIndex ?? 0);
    });
    return sorted;
  }
}
