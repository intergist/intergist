/// Recording Mode session controller.
///
/// Manages participation windows with red/yellow/green light indicators,
/// handles capture timing, and ensures cues are never spoken aloud.
library;

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/cue_engine/participation_window.dart';
import 'package:scifionly/features/cue_engine/window_calculator.dart';
import 'package:scifionly/features/session/session_controller.dart';
import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/models/participation_window_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'SESSION';

/// Maximum capture duration in milliseconds.
const int kMaxCaptureDurationMs = 7000;

/// Warning time before a window opens or closes (ms).
const int kWarningMs = 1500;

/// Minimum window duration for green state (ms).
const int kMinGreenWindowMs = 2500;

/// The traffic-light state shown to the user.
enum TrafficLightState {
  /// No window near — cannot record.
  red,

  /// A window is about to open or close — get ready / wrap up.
  yellow,

  /// Window is open and long enough — go ahead and record.
  green,
}

/// Callback for traffic-light state changes.
typedef TrafficLightCallback = void Function(
  TrafficLightState state,
  ParticipationWindowModel? window,
);

/// Callback when a capture should start or stop.
typedef CaptureTimingCallback = void Function({
  required bool shouldCapture,
  required int remainingMs,
});

/// Controller for Recording Mode sessions.
///
/// Recording Mode rules:
/// - Priority resolution uses rule 3 (display-only outranks spoken).
/// - Cues are NEVER spoken aloud — display only.
/// - Participation windows control when the user can record.
/// - Traffic light: red (closed), yellow (1.5 s before open/close),
///   green (open and >= 2.5 s window).
/// - Max capture = 7 seconds.
class RecordingModeController extends BaseSessionController {
  /// The reference (dialogue) track used to compute windows.
  final CueTrack _referenceTrack;

  /// Computed participation windows.
  List<ParticipationWindowModel> _windows = [];

  /// Window calculator configuration.
  final WindowCalculator _windowCalculator;

  /// Current traffic-light state.
  TrafficLightState _trafficLight = TrafficLightState.red;

  /// The currently active window, if any.
  ParticipationWindowModel? _activeWindow;

  /// Whether the user is currently capturing audio.
  bool _isCapturing = false;

  /// Timestamp (ms) when capture started.
  int? _captureStartMs;

  /// Callbacks.
  TrafficLightCallback? onTrafficLightChanged;
  CaptureTimingCallback? onCaptureTiming;

  RecordingModeController({
    required super.tracks,
    required CueTrack referenceTrack,
    super.syncEngine,
    WindowCalculator windowCalculator = const WindowCalculator(),
    this.onTrafficLightChanged,
    this.onCaptureTiming,
  })  : _referenceTrack = referenceTrack,
        _windowCalculator = windowCalculator,
        super(
          mode: SessionMode.recording,
        );

  @override
  SessionMode get mode => SessionMode.recording;

  /// Current traffic-light state.
  TrafficLightState get trafficLight => _trafficLight;

  /// Currently active participation window, or null.
  ParticipationWindowModel? get activeWindowModel => _activeWindow;

  /// Whether the user is currently capturing.
  bool get isCapturing => _isCapturing;

  /// All computed participation windows.
  List<ParticipationWindowModel> get windows =>
      List.unmodifiable(_windows);

  @override
  void start({int startPositionMs = 0}) {
    // Compute participation windows from the reference track.
    _windows = _windowCalculator.calculate(_referenceTrack);
    AppLogger.info(
      _tag,
      'Recording Mode: computed ${_windows.length} participation windows',
    );
    super.start(startPositionMs: startPositionMs);
  }

  @override
  void stop() {
    _stopCapture();
    _trafficLight = TrafficLightState.red;
    _activeWindow = null;
    super.stop();
  }

  @override
  void seekTo(int positionMs) {
    _stopCapture();
    _trafficLight = TrafficLightState.red;
    _activeWindow = null;
    super.seekTo(positionMs);
  }

  @override
  void onSyncStateUpdated(SyncStateData syncState) {
    if (sessionState != SessionState.active) return;

    final positionMs = syncState.estimatedPositionMs;
    _updateTrafficLight(positionMs);
    _updateCaptureTiming(positionMs);
  }

  @override
  void evaluateCues(int positionMs, {bool isActivelyRecording = false}) {
    // In recording mode, pass the capture state to the evaluator.
    super.evaluateCues(positionMs, isActivelyRecording: _isCapturing);
  }

  /// Signal that the user has started speaking (capture onset).
  void onSpeechOnset() {
    if (!_canCapture()) {
      AppLogger.warn(_tag, 'Speech onset rejected: window not open');
      return;
    }
    _startCapture();
  }

  /// Signal that the user has stopped speaking.
  void onSpeechEnd() {
    _stopCapture();
  }

  // ---------------------------------------------------------------------------
  // Internal: traffic light management
  // ---------------------------------------------------------------------------

  void _updateTrafficLight(int positionMs) {
    // Find the current or next window.
    final active = activeWindow(_windows, positionMs);
    final next = nextWindow(_windows, positionMs);

    TrafficLightState newState;

    if (active != null) {
      // We are inside an open window.
      final windowState = getWindowState(active, positionMs);
      final windowDuration = active.endMs - active.startMs;

      if (windowState == WindowState.warning) {
        newState = TrafficLightState.yellow;
      } else if (windowDuration >= kMinGreenWindowMs) {
        newState = TrafficLightState.green;
      } else {
        // Window is open but too short for green.
        newState = TrafficLightState.yellow;
      }
    } else if (next != null) {
      // Check if we are in the lead-in warning zone.
      final windowState = getWindowState(next, positionMs);
      if (windowState == WindowState.warning) {
        newState = TrafficLightState.yellow;
      } else {
        newState = TrafficLightState.red;
      }
    } else {
      newState = TrafficLightState.red;
    }

    if (newState != _trafficLight || active != _activeWindow) {
      _trafficLight = newState;
      _activeWindow = active;

      AppLogger.debug(
        _tag,
        'Traffic light: ${newState.name} at ${positionMs}ms',
      );

      onTrafficLightChanged?.call(newState, active);
    }

    // If the window closed while capturing, stop.
    if (_isCapturing && active == null) {
      AppLogger.info(_tag, 'Window closed during capture; stopping');
      _stopCapture();
    }
  }

  void _updateCaptureTiming(int positionMs) {
    if (!_isCapturing) return;

    final elapsed = positionMs - (_captureStartMs ?? positionMs);
    final remaining = kMaxCaptureDurationMs - elapsed;

    if (remaining <= 0) {
      AppLogger.info(_tag, 'Max capture duration reached');
      _stopCapture();
      return;
    }

    onCaptureTiming?.call(shouldCapture: true, remainingMs: remaining);
  }

  bool _canCapture() {
    return _trafficLight == TrafficLightState.green ||
        _trafficLight == TrafficLightState.yellow;
  }

  void _startCapture() {
    if (_isCapturing) return;
    _isCapturing = true;
    _captureStartMs = syncEngine.state.estimatedPositionMs;
    AppLogger.info(_tag, 'Capture started at ${_captureStartMs}ms');
    onCaptureTiming?.call(
      shouldCapture: true,
      remainingMs: kMaxCaptureDurationMs,
    );
  }

  void _stopCapture() {
    if (!_isCapturing) return;
    _isCapturing = false;
    _captureStartMs = null;
    AppLogger.info(_tag, 'Capture stopped');
    onCaptureTiming?.call(shouldCapture: false, remainingMs: 0);
  }

  @override
  void dispose() {
    _stopCapture();
    onTrafficLightChanged = null;
    onCaptureTiming = null;
    super.dispose();
  }
}
