/// The [CueEvaluator] determines which cues should fire at any given
/// playback position, using the priority resolver to handle conflicts
/// and tracking fired cues to avoid duplicates.
library;

import 'package:scifionly/features/cue_engine/cue_priority.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'CUE_ENGINE';

/// Result of evaluating cues at a position.
class CueEvaluation {
  /// The winning cue to fire, if any.
  final CueEventModel? activeCue;

  /// All candidates that were considered.
  final List<CueEventModel> candidates;

  /// Whether this is a new cue that hasn't been fired before.
  final bool isNewFire;

  const CueEvaluation({
    this.activeCue,
    required this.candidates,
    required this.isNewFire,
  });
}

/// Evaluates which cues should fire at the current playback position.
class CueEvaluator {
  final List<CueTrack> _tracks;
  final CuePriorityResolver _resolver;
  final SessionMode _mode;

  /// Set of cue IDs that have already been fired.
  final Set<String> _firedCueIds = {};

  /// The ID of the currently active (displayed) cue, if any.
  String? _currentCueId;

  CueEvaluator({
    required List<CueTrack> tracks,
    required SessionMode mode,
    CuePriorityResolver resolver = const CuePriorityResolver(),
  })  : _tracks = tracks,
        _mode = mode,
        _resolver = resolver;

  /// The currently active cue ID, or null.
  String? get currentCueId => _currentCueId;

  /// Set of all cue IDs that have been fired in this session.
  Set<String> get firedCueIds => Set.unmodifiable(_firedCueIds);

  /// Evaluate cues at [positionMs].
  ///
  /// Returns a [CueEvaluation] describing the winning cue (if any),
  /// all candidates, and whether this is a new fire event.
  ///
  /// [isActivelyRecording] is forwarded to the priority resolver for rule 4.
  CueEvaluation evaluate(
    int positionMs, {
    bool isActivelyRecording = false,
  }) {
    // Gather all candidates across all tracks.
    final candidates = <CueEventModel>[];
    for (final track in _tracks) {
      final cue = track.getCueAt(positionMs);
      if (cue != null) {
        candidates.add(cue);
      }
    }

    if (candidates.isEmpty) {
      // No cues at this position — clear current.
      if (_currentCueId != null) {
        AppLogger.debug(_tag, 'No cues at ${positionMs}ms, clearing active');
        _currentCueId = null;
      }
      return const CueEvaluation(
        activeCue: null,
        candidates: [],
        isNewFire: false,
      );
    }

    // Resolve priority.
    final winner = _resolver.resolve(
      candidates,
      _mode,
      isActivelyRecording: isActivelyRecording,
    );

    if (winner == null) {
      _currentCueId = null;
      return CueEvaluation(
        activeCue: null,
        candidates: candidates,
        isNewFire: false,
      );
    }

    // Determine if this is a new fire.
    final isNew = !_firedCueIds.contains(winner.id);

    if (isNew) {
      _firedCueIds.add(winner.id);
      AppLogger.debug(
        _tag,
        'Firing new cue: ${winner.id} at ${positionMs}ms',
      );
    }

    _currentCueId = winner.id;

    return CueEvaluation(
      activeCue: winner,
      candidates: candidates,
      isNewFire: isNew,
    );
  }

  /// Evaluate and return all active cues in a time range.
  ///
  /// Useful for lookahead or rendering a range of cues.
  List<CueEventModel> evaluateRange(int startMs, int endMs) {
    final results = <CueEventModel>[];
    for (final track in _tracks) {
      results.addAll(track.getCuesInRange(startMs, endMs));
    }
    // Sort by start time, then source index.
    results.sort((a, b) {
      final cmp = a.startMs.compareTo(b.startMs);
      if (cmp != 0) return cmp;
      return (a.sourceIndex ?? 0).compareTo(b.sourceIndex ?? 0);
    });
    return results;
  }

  /// Reset the evaluator state (e.g., on seek or restart).
  void reset() {
    _firedCueIds.clear();
    _currentCueId = null;
    AppLogger.info(_tag, 'CueEvaluator reset');
  }

  /// Mark a specific cue as already fired (e.g., after manual trigger).
  void markFired(String cueId) {
    _firedCueIds.add(cueId);
  }

  /// Check whether a cue has already fired.
  bool hasFired(String cueId) => _firedCueIds.contains(cueId);
}
