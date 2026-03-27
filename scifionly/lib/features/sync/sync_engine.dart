/// Simulated sync engine for v1.
///
/// Implements a state machine that transitions between sync states
/// based on confidence thresholds. For v1 this uses simulated
/// timeline progression rather than actual audio fingerprinting.
///
/// State machine:
///   UNLOCKED -> LOCKED -> DEGRADED -> REACQUIRING -> LOCKED
library;

import 'dart:async';

import 'package:scifionly/features/sync/drift_corrector.dart';
import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'SYNC';

/// Callback signature for sync state changes.
typedef SyncStateCallback = void Function(SyncStateData state);

/// Simulated sync engine for v1.
///
/// Uses a [Timer] to advance the simulated playback position and
/// emits [SyncStateData] changes via [onStateChanged].
class SyncEngine {
  /// Confidence above which we transition to LOCKED.
  final double lockConfidenceThreshold;

  /// Confidence below which we transition from LOCKED to DEGRADED.
  final double hysteresisThreshold;

  /// Interval for the simulated tick timer.
  final Duration tickInterval;

  /// Optional drift corrector.
  final DriftCorrector _driftCorrector;

  /// Callback invoked on every state change.
  SyncStateCallback? onStateChanged;

  // Internal state.
  SyncStateData _state;
  Timer? _tickTimer;
  bool _isPaused = false;
  int _simulatedPositionMs = 0;
  DateTime? _lastTickTime;

  SyncEngine({
    this.lockConfidenceThreshold = 0.85,
    this.hysteresisThreshold = 0.70,
    this.tickInterval = const Duration(milliseconds: 100),
    this.onStateChanged,
    DriftCorrector? driftCorrector,
  })  : _driftCorrector = driftCorrector ?? DriftCorrector(),
        _state = SyncStateData(
          state: SyncState.unlocked,
          confidence: 0.0,
          estimatedPositionMs: 0,
          driftMs: 0,
          lastUpdateTime: DateTime.now(),
        );

  /// Current state snapshot.
  SyncStateData get state => _state;

  /// Whether the engine is currently running.
  bool get isRunning => _tickTimer != null;

  /// Whether the simulated playback is paused.
  bool get isPaused => _isPaused;

  /// Start the sync engine.
  ///
  /// Begins simulated timeline progression from [startPositionMs].
  void start({int startPositionMs = 0}) {
    AppLogger.info(_tag, 'Starting sync engine at ${startPositionMs}ms');

    _simulatedPositionMs = startPositionMs;
    _isPaused = false;
    _lastTickTime = DateTime.now();

    // Transition to LOCKED with high confidence.
    _updateState(
      state: SyncState.locked,
      confidence: 1.0,
      positionMs: _simulatedPositionMs,
      driftMs: 0,
    );

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(tickInterval, _onTick);
  }

  /// Stop the sync engine.
  void stop() {
    AppLogger.info(_tag, 'Stopping sync engine');

    _tickTimer?.cancel();
    _tickTimer = null;
    _isPaused = false;

    _updateState(
      state: SyncState.unlocked,
      confidence: 0.0,
      positionMs: _simulatedPositionMs,
      driftMs: 0,
    );
  }

  /// Update the known playback position (e.g., from an external sync cue).
  void updatePosition(int positionMs) {
    AppLogger.debug(_tag, 'External position update: ${positionMs}ms');

    final drift = positionMs - _simulatedPositionMs;
    _simulatedPositionMs = positionMs;

    final correctedDrift = _driftCorrector.correct(drift);

    if (_driftCorrector.shouldReacquire(correctedDrift)) {
      _updateState(
        state: SyncState.reacquiring,
        confidence: 0.5,
        positionMs: positionMs,
        driftMs: correctedDrift,
      );
      // Simulate quick reacquisition.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state.state == SyncState.reacquiring) {
          _updateState(
            state: SyncState.locked,
            confidence: lockConfidenceThreshold,
            positionMs: _simulatedPositionMs,
            driftMs: 0,
          );
        }
      });
    } else {
      _simulatedPositionMs = positionMs - correctedDrift;
      final newConfidence = _calculateConfidence(correctedDrift);
      final newState = _determineState(newConfidence);

      _updateState(
        state: newState,
        confidence: newConfidence,
        positionMs: _simulatedPositionMs,
        driftMs: correctedDrift,
      );
    }
  }

  /// Simulate a drift event for testing.
  void simulateDrift(int driftMs) {
    AppLogger.debug(_tag, 'Simulating drift: ${driftMs}ms');

    final correctedDrift = _driftCorrector.correct(driftMs);

    if (_driftCorrector.shouldReacquire(correctedDrift)) {
      _updateState(
        state: SyncState.reacquiring,
        confidence: 0.3,
        positionMs: _simulatedPositionMs,
        driftMs: correctedDrift,
      );
    } else {
      _simulatedPositionMs += correctedDrift;
      final newConfidence = _calculateConfidence(correctedDrift);
      final newState = _determineState(newConfidence);

      _updateState(
        state: newState,
        confidence: newConfidence,
        positionMs: _simulatedPositionMs,
        driftMs: correctedDrift,
      );
    }
  }

  /// Simulate a playback pause.
  void simulatePause() {
    AppLogger.info(_tag, 'Simulating pause');
    _isPaused = true;
  }

  /// Resume from a simulated pause.
  void simulateResume() {
    AppLogger.info(_tag, 'Simulating resume');
    _isPaused = false;
    _lastTickTime = DateTime.now();
  }

  /// Simulate a seek to a new position.
  void simulateSeek(int positionMs) {
    AppLogger.info(_tag, 'Simulating seek to ${positionMs}ms');
    _simulatedPositionMs = positionMs;
    _lastTickTime = DateTime.now();

    _updateState(
      state: SyncState.reacquiring,
      confidence: 0.5,
      positionMs: positionMs,
      driftMs: 0,
    );

    // Simulate quick reacquisition after seek.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_state.state == SyncState.reacquiring) {
        _updateState(
          state: SyncState.locked,
          confidence: 1.0,
          positionMs: _simulatedPositionMs,
          driftMs: 0,
        );
      }
    });
  }

  /// Dispose of resources.
  void dispose() {
    _tickTimer?.cancel();
    _tickTimer = null;
    onStateChanged = null;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onTick(Timer timer) {
    if (_isPaused) return;

    final now = DateTime.now();
    if (_lastTickTime != null) {
      final elapsed = now.difference(_lastTickTime!).inMilliseconds;
      _simulatedPositionMs += elapsed;
    }
    _lastTickTime = now;

    // If reacquiring, gradually increase confidence.
    if (_state.state == SyncState.reacquiring) {
      final newConfidence = (_state.confidence + 0.05).clamp(0.0, 1.0);
      final newState = _determineState(newConfidence);
      _updateState(
        state: newState,
        confidence: newConfidence,
        positionMs: _simulatedPositionMs,
        driftMs: _state.driftMs,
      );
    } else {
      // Normal tick: just update position.
      _updateState(
        state: _state.state,
        confidence: _state.confidence,
        positionMs: _simulatedPositionMs,
        driftMs: _state.driftMs,
      );
    }
  }

  double _calculateConfidence(int driftMs) {
    final absDrift = driftMs.abs();
    if (absDrift == 0) return 1.0;
    if (absDrift >= _driftCorrector.driftToleranceMs) return 0.3;
    // Linear interpolation.
    return 1.0 - (absDrift / _driftCorrector.driftToleranceMs) * 0.7;
  }

  SyncState _determineState(double confidence) {
    if (confidence >= lockConfidenceThreshold) return SyncState.locked;
    if (confidence >= hysteresisThreshold) return SyncState.degraded;
    return SyncState.reacquiring;
  }

  void _updateState({
    required SyncState state,
    required double confidence,
    required int positionMs,
    required int driftMs,
  }) {
    final newState = SyncStateData(
      state: state,
      confidence: confidence,
      estimatedPositionMs: positionMs,
      driftMs: driftMs,
      lastUpdateTime: DateTime.now(),
    );

    final stateChanged = _state.state != newState.state;
    _state = newState;

    if (stateChanged) {
      AppLogger.info(
        _tag,
        'Sync state changed: ${newState.state.name} '
        '(confidence=${newState.confidence.toStringAsFixed(2)}, '
        'drift=${newState.driftMs}ms)',
      );
    }

    onStateChanged?.call(newState);
  }
}
