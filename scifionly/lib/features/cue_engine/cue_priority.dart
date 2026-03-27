/// Cue priority resolution implementing all 7 priority rules.
///
/// Used by the cue evaluator to determine which cue should fire when
/// multiple candidates overlap at the same point in time.
library;

import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'CUE_ENGINE';

/// Resolves which cue should fire from a set of overlapping candidates.
///
/// Priority rules (in order):
///
/// 1. Higher explicit priority number wins.
/// 2. In Standard Mode: `app_spoken` (speak/displayAndSpeak) outranks
///    `display_only`.
/// 3. In Recording Mode: `display_only` outranks `app_spoken`.
/// 4. User-recorded capture indicators outrank pre-authored riffs during
///    active recording.
/// 5. If tied: earlier [startMs] wins.
/// 6. If still tied: shorter duration wins.
/// 7. If still tied: stable sort by source file order ([sourceIndex]).
class CuePriorityResolver {
  const CuePriorityResolver();

  /// Resolve the highest-priority cue from [candidates].
  ///
  /// Returns `null` if [candidates] is empty.
  ///
  /// [mode] is the current session mode (standard or recording).
  /// [isActivelyRecording] indicates whether the user is currently capturing
  /// audio (relevant to rule 4).
  CueEventModel? resolve(
    List<CueEventModel> candidates,
    SessionMode mode, {
    bool isActivelyRecording = false,
  }) {
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    AppLogger.debug(
      _tag,
      'Resolving priority among ${candidates.length} candidates '
      '(mode: ${mode.name}, recording: $isActivelyRecording)',
    );

    // Work on a copy so we don't mutate the caller's list.
    final sorted = List<CueEventModel>.from(candidates);

    sorted.sort((a, b) => _compare(a, b, mode, isActivelyRecording));

    final winner = sorted.first;
    AppLogger.debug(
      _tag,
      'Priority winner: ${winner.id} (priority=${winner.priority}, '
      'mode=${winner.mode.name}, start=${winner.startMs})',
    );

    return winner;
  }

  /// Compare two cues. Returns negative if [a] should win (come first).
  int _compare(
    CueEventModel a,
    CueEventModel b,
    SessionMode mode,
    bool isActivelyRecording,
  ) {
    // Rule 1: Higher explicit priority wins.
    final priorityCmp = b.priority.compareTo(a.priority);
    if (priorityCmp != 0) return priorityCmp;

    // Rule 2 & 3: Mode-dependent mode ranking.
    final modeRankA = _modeRank(a, mode);
    final modeRankB = _modeRank(b, mode);
    final modeRankCmp = modeRankB.compareTo(modeRankA);
    if (modeRankCmp != 0) return modeRankCmp;

    // Rule 4: During active recording, user riffs outrank pre-authored riffs.
    if (isActivelyRecording) {
      final userRankA = _userRecordingRank(a);
      final userRankB = _userRecordingRank(b);
      final userCmp = userRankB.compareTo(userRankA);
      if (userCmp != 0) return userCmp;
    }

    // Rule 5: Earlier startMs wins.
    final startCmp = a.startMs.compareTo(b.startMs);
    if (startCmp != 0) return startCmp;

    // Rule 6: Shorter duration wins.
    final durA = a.endMs - a.startMs;
    final durB = b.endMs - b.startMs;
    final durCmp = durA.compareTo(durB);
    if (durCmp != 0) return durCmp;

    // Rule 7: Stable sort by source file order.
    return (a.sourceIndex ?? 0).compareTo(b.sourceIndex ?? 0);
  }

  /// Rank a cue's mode for priority purposes.
  ///
  /// Higher number = higher priority in the current session mode.
  int _modeRank(CueEventModel cue, SessionMode mode) {
    final isSpoken =
        cue.mode == CueMode.speak || cue.mode == CueMode.displayAndSpeak;
    final isDisplayOnly = cue.mode == CueMode.displayOnly;

    if (mode == SessionMode.standard) {
      // Rule 2: app_spoken outranks display_only in Standard Mode.
      if (isSpoken) return 2;
      if (isDisplayOnly) return 1;
      return 0;
    } else {
      // Rule 3: display_only outranks app_spoken in Recording Mode.
      if (isDisplayOnly) return 2;
      if (isSpoken) return 1;
      return 0;
    }
  }

  /// Rank a cue for rule 4: user recordings outrank pre-authored during
  /// active recording.
  int _userRecordingRank(CueEventModel cue) {
    if (cue.kind == CueKind.userRiff && cue.speakerRole == SpeakerRole.user) {
      return 2;
    }
    if (cue.kind == CueKind.riff && cue.speakerRole == SpeakerRole.app) {
      return 1;
    }
    return 0;
  }
}
