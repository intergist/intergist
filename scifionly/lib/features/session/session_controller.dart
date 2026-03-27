/// Abstract session controller providing the common interface and shared
/// logic for both Standard Mode and Recording Mode sessions.
library;

import 'package:scifionly/features/cue_engine/cue_evaluator.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/sync/sync_engine.dart';
import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'SESSION';

/// Callback when a cue fires.
typedef CueFiredCallback = void Function(CueEventModel cue, bool isNew);

/// Callback when session state changes.
typedef SessionStateCallback = void Function(SessionState state);

/// Abstract base for session controllers.
///
/// Subclasses implement mode-specific behaviour (standard vs. recording)
/// while sharing sync, cue evaluation, and lifecycle management.
abstract class SessionController {
  /// The session mode (standard or recording).
  SessionMode get mode;

  /// Current session state.
  SessionState get sessionState;

  /// Current playback position in milliseconds.
  int get currentPositionMs;

  /// The sync engine used by this session.
  SyncEngine get syncEngine;

  /// The cue evaluator.
  CueEvaluator get cueEvaluator;

  /// Callback invoked when a cue fires.
  CueFiredCallback? onCueFired;

  /// Callback invoked when session state changes.
  SessionStateCallback? onSessionStateChanged;

  /// Start the session.
  void start({int startPositionMs = 0});

  /// Pause the session.
  void pause();

  /// Resume the session.
  void resume();

  /// Stop and clean up the session.
  void stop();

  /// Seek to a specific position.
  void seekTo(int positionMs);

  /// Dispose all resources.
  void dispose();
}

/// Base implementation with shared logic for session controllers.
abstract class BaseSessionController implements SessionController {
  @override
  final SyncEngine syncEngine;

  @override
  final CueEvaluator cueEvaluator;

  @override
  CueFiredCallback? onCueFired;

  @override
  SessionStateCallback? onSessionStateChanged;

  SessionState _sessionState = SessionState.paused;

  BaseSessionController({
    required List<CueTrack> tracks,
    required SessionMode mode,
    SyncEngine? syncEngine,
  })  : syncEngine = syncEngine ?? SyncEngine(),
        cueEvaluator = CueEvaluator(tracks: tracks, mode: mode) {
    // Wire up sync engine state changes.
    this.syncEngine.onStateChanged = _onSyncStateChanged;
  }

  @override
  SessionState get sessionState => _sessionState;

  @override
  int get currentPositionMs => syncEngine.state.estimatedPositionMs;

  @override
  void start({int startPositionMs = 0}) {
    AppLogger.info(_tag, 'Starting ${mode.name} session at ${startPositionMs}ms');
    _setSessionState(SessionState.active);
    syncEngine.start(startPositionMs: startPositionMs);
  }

  @override
  void pause() {
    AppLogger.info(_tag, 'Pausing session');
    _setSessionState(SessionState.paused);
    syncEngine.simulatePause();
  }

  @override
  void resume() {
    AppLogger.info(_tag, 'Resuming session');
    _setSessionState(SessionState.active);
    syncEngine.simulateResume();
  }

  @override
  void stop() {
    AppLogger.info(_tag, 'Stopping session');
    syncEngine.stop();
    _setSessionState(SessionState.completed);
  }

  @override
  void seekTo(int positionMs) {
    AppLogger.info(_tag, 'Seeking to ${positionMs}ms');
    cueEvaluator.reset();
    syncEngine.simulateSeek(positionMs);
  }

  @override
  void dispose() {
    AppLogger.info(_tag, 'Disposing session controller');
    syncEngine.dispose();
    onCueFired = null;
    onSessionStateChanged = null;
  }

  /// Evaluate cues at the current position.
  ///
  /// Subclasses should call this from the sync tick handler.
  void evaluateCues(int positionMs, {bool isActivelyRecording = false}) {
    final evaluation = cueEvaluator.evaluate(
      positionMs,
      isActivelyRecording: isActivelyRecording,
    );

    if (evaluation.activeCue != null) {
      onCueFired?.call(evaluation.activeCue!, evaluation.isNewFire);
    }
  }

  /// Update session state and notify listener.
  void setSessionState(SessionState state) => _setSessionState(state);

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _setSessionState(SessionState state) {
    if (_sessionState == state) return;
    _sessionState = state;
    AppLogger.info(_tag, 'Session state: ${state.name}');
    onSessionStateChanged?.call(state);
  }

  /// Handle sync engine state changes.
  ///
  /// Subclasses can override [onSyncStateUpdated] to add mode-specific logic.
  void _onSyncStateChanged(SyncStateData syncState) {
    if (_sessionState == SessionState.active) {
      evaluateCues(syncState.estimatedPositionMs);
    }
    onSyncStateUpdated(syncState);
  }

  /// Hook for subclasses to react to sync state updates.
  void onSyncStateUpdated(SyncStateData syncState) {}
}
