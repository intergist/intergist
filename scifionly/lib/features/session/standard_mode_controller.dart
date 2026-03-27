/// Standard Mode session controller.
///
/// Manages the sync engine and cue evaluator for normal (non-recording)
/// playback. Fires cues at correct times and handles pause/resume.
library;

import 'package:scifionly/features/session/session_controller.dart';
import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'SESSION';

/// Callback invoked with the list of upcoming cues (lookahead).
typedef UpcomingCuesCallback = void Function(List<CueEventModel> upcoming);

/// Controller for Standard Mode sessions.
///
/// In Standard Mode:
/// - Cues are spoken aloud (TTS) and/or displayed based on their [CueMode].
/// - Priority resolution uses rule 2 (spoken outranks display-only).
/// - No participation windows or recording logic.
class StandardModeController extends BaseSessionController {
  /// Duration of the lookahead window in milliseconds.
  final int lookaheadMs;

  /// Callback for upcoming cues (optional).
  UpcomingCuesCallback? onUpcomingCues;

  /// The most recently fired cue.
  CueEventModel? _lastFiredCue;

  StandardModeController({
    required super.tracks,
    super.syncEngine,
    this.lookaheadMs = 5000,
    this.onUpcomingCues,
  }) : super(
          mode: SessionMode.standard,
        );

  @override
  SessionMode get mode => SessionMode.standard;

  /// The most recently fired cue, if any.
  CueEventModel? get lastFiredCue => _lastFiredCue;

  @override
  void start({int startPositionMs = 0}) {
    AppLogger.info(
      _tag,
      'Starting Standard Mode session at ${startPositionMs}ms',
    );
    super.start(startPositionMs: startPositionMs);
  }

  @override
  void stop() {
    _lastFiredCue = null;
    super.stop();
  }

  @override
  void seekTo(int positionMs) {
    _lastFiredCue = null;
    super.seekTo(positionMs);
  }

  @override
  void onSyncStateUpdated(SyncStateData syncState) {
    // Update lookahead if we have a listener.
    if (onUpcomingCues != null && sessionState == SessionState.active) {
      final positionMs = syncState.estimatedPositionMs;
      final upcoming = cueEvaluator.evaluateRange(
        positionMs,
        positionMs + lookaheadMs,
      );
      onUpcomingCues?.call(upcoming);
    }
  }

  @override
  void evaluateCues(int positionMs, {bool isActivelyRecording = false}) {
    final evaluation = cueEvaluator.evaluate(positionMs);

    if (evaluation.activeCue != null) {
      _lastFiredCue = evaluation.activeCue;
      onCueFired?.call(evaluation.activeCue!, evaluation.isNewFire);
    }
  }

  @override
  void dispose() {
    onUpcomingCues = null;
    _lastFiredCue = null;
    super.dispose();
  }
}
