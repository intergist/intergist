/// Audio capture lifecycle controller.
///
/// Manages starting, stopping, and enforcing time limits on audio capture.
/// For v1 this uses mocked audio — no actual microphone access.
library;

import 'dart:async';

import 'package:scifionly/utils/logger.dart';

const String _tag = 'RECORDING';

/// Maximum capture duration in milliseconds.
const int kMaxCaptureDurationMs = 7000;

/// Represents a single captured audio segment.
class CaptureEvent {
  /// Unique identifier for this capture.
  final String id;

  /// The playback position (ms) when capture started.
  final int startPositionMs;

  /// The playback position (ms) when capture ended.
  final int endPositionMs;

  /// Duration of the capture in milliseconds.
  final int durationMs;

  /// Path to the captured audio file (v1: may be null / mocked).
  final String? audioFilePath;

  /// Timestamp when capture was initiated.
  final DateTime capturedAt;

  /// The participation window ID during which this capture occurred.
  final String? windowId;

  const CaptureEvent({
    required this.id,
    required this.startPositionMs,
    required this.endPositionMs,
    required this.durationMs,
    this.audioFilePath,
    required this.capturedAt,
    this.windowId,
  });

  @override
  String toString() {
    return 'CaptureEvent(id: $id, start: ${startPositionMs}ms, '
        'end: ${endPositionMs}ms, duration: ${durationMs}ms)';
  }
}

/// State of the capture controller.
enum CaptureState {
  /// Idle — not capturing.
  idle,

  /// Actively capturing audio.
  capturing,

  /// Capture finished, processing.
  processing,

  /// An error occurred.
  error,
}

/// Callback when capture state changes.
typedef CaptureStateCallback = void Function(CaptureState state);

/// Callback when a capture completes.
typedef CaptureCompleteCallback = void Function(CaptureEvent event);

/// Manages the audio capture lifecycle.
///
/// For v1 this is mocked — no actual audio recording. The controller
/// tracks timing and produces [CaptureEvent] objects that can be used
/// to create user riff entries.
class CaptureController {
  /// Maximum duration for a single capture.
  final int maxDurationMs;

  /// Current capture state.
  CaptureState _state = CaptureState.idle;

  /// Timer that enforces the maximum duration.
  Timer? _maxDurationTimer;

  /// When the current capture started (playback position).
  int? _captureStartMs;

  /// When the current capture started (wall clock).
  DateTime? _captureStartTime;

  /// The window ID for the current capture.
  String? _currentWindowId;

  /// Counter for generating capture IDs.
  int _captureCounter = 0;

  /// All completed captures in this session.
  final List<CaptureEvent> _captures = [];

  /// Callbacks.
  CaptureStateCallback? onStateChanged;
  CaptureCompleteCallback? onCaptureComplete;

  CaptureController({
    this.maxDurationMs = kMaxCaptureDurationMs,
    this.onStateChanged,
    this.onCaptureComplete,
  });

  /// Current state.
  CaptureState get state => _state;

  /// Whether the controller is currently capturing.
  bool get isCapturing => _state == CaptureState.capturing;

  /// All completed captures.
  List<CaptureEvent> get captures => List.unmodifiable(_captures);

  /// Number of completed captures.
  int get captureCount => _captures.length;

  /// Start capturing audio.
  ///
  /// [positionMs] is the current playback position.
  /// [windowId] is the ID of the participation window, if applicable.
  ///
  /// Returns `true` if capture started, `false` if already capturing.
  bool startCapture({
    required int positionMs,
    String? windowId,
  }) {
    if (_state == CaptureState.capturing) {
      AppLogger.warn(_tag, 'Already capturing; ignoring startCapture');
      return false;
    }

    _captureStartMs = positionMs;
    _captureStartTime = DateTime.now();
    _currentWindowId = windowId;
    _setState(CaptureState.capturing);

    AppLogger.info(
      _tag,
      'Capture started at ${positionMs}ms '
      '(window: ${windowId ?? "none"})',
    );

    // Start max-duration timer.
    _maxDurationTimer?.cancel();
    _maxDurationTimer = Timer(
      Duration(milliseconds: maxDurationMs),
      _onMaxDurationReached,
    );

    return true;
  }

  /// Stop the current capture.
  ///
  /// [positionMs] is the current playback position at stop time.
  ///
  /// Returns the [CaptureEvent], or null if not capturing.
  CaptureEvent? stopCapture({required int positionMs}) {
    if (_state != CaptureState.capturing) {
      AppLogger.warn(_tag, 'Not capturing; ignoring stopCapture');
      return null;
    }

    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;

    final startMs = _captureStartMs ?? positionMs;
    final durationMs = positionMs - startMs;

    _setState(CaptureState.processing);

    final event = _createCaptureEvent(
      startMs: startMs,
      endMs: positionMs,
      durationMs: durationMs,
    );

    _captures.add(event);
    _setState(CaptureState.idle);

    AppLogger.info(
      _tag,
      'Capture completed: ${event.durationMs}ms '
      '(${event.startPositionMs}ms–${event.endPositionMs}ms)',
    );

    onCaptureComplete?.call(event);
    return event;
  }

  /// Cancel the current capture without saving.
  void cancelCapture() {
    if (_state != CaptureState.capturing) return;

    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    _captureStartMs = null;
    _captureStartTime = null;
    _currentWindowId = null;

    _setState(CaptureState.idle);

    AppLogger.info(_tag, 'Capture cancelled');
  }

  /// Reset the controller, clearing all captures.
  void reset() {
    cancelCapture();
    _captures.clear();
    _captureCounter = 0;
    AppLogger.info(_tag, 'Capture controller reset');
  }

  /// Dispose resources.
  void dispose() {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    onStateChanged = null;
    onCaptureComplete = null;
  }

  /// Elapsed capture time in milliseconds, or 0 if not capturing.
  int get elapsedMs {
    if (_captureStartTime == null || _state != CaptureState.capturing) return 0;
    return DateTime.now().difference(_captureStartTime!).inMilliseconds;
  }

  /// Remaining capture time in milliseconds, or 0 if not capturing.
  int get remainingMs {
    final elapsed = elapsedMs;
    if (elapsed == 0) return 0;
    return (maxDurationMs - elapsed).clamp(0, maxDurationMs);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onMaxDurationReached() {
    AppLogger.info(_tag, 'Max capture duration reached');
    final endMs = (_captureStartMs ?? 0) + maxDurationMs;
    stopCapture(positionMs: endMs);
  }

  CaptureEvent _createCaptureEvent({
    required int startMs,
    required int endMs,
    required int durationMs,
  }) {
    _captureCounter++;
    return CaptureEvent(
      id: 'capture_$_captureCounter',
      startPositionMs: startMs,
      endPositionMs: endMs,
      durationMs: durationMs.clamp(0, maxDurationMs),
      audioFilePath: null, // Mocked for v1.
      capturedAt: _captureStartTime ?? DateTime.now(),
      windowId: _currentWindowId,
    );
  }

  void _setState(CaptureState newState) {
    if (_state == newState) return;
    _state = newState;
    onStateChanged?.call(newState);
  }
}
