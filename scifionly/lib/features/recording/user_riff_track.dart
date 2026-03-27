/// Manages user-recorded riffs and converts them into a [CueTrack].
///
/// Collects [CaptureEvent] instances from the [CaptureController] and
/// converts them into [CueEventModel] entries that can participate in
/// the cue engine's priority resolution.
library;

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/recording/capture_controller.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'RECORDING';

/// Manages user-recorded riffs for a session.
///
/// Converts [CaptureEvent] objects into [CueEventModel] instances and
/// provides a [CueTrack] view for the cue engine.
class UserRiffTrack {
  /// Unique track ID for this user riff track.
  final String trackId;

  /// Ordered list of user riff cue events.
  final List<CueEventModel> _riffs = [];

  /// Counter for generating cue IDs.
  int _riffCounter = 0;

  UserRiffTrack({
    required this.trackId,
  });

  /// Number of riffs recorded.
  int get length => _riffs.length;

  /// Whether any riffs have been recorded.
  bool get isEmpty => _riffs.isEmpty;

  /// All riff events in order.
  List<CueEventModel> get riffs => List.unmodifiable(_riffs);

  /// Add a user riff from a capture event.
  ///
  /// [capture] is the completed capture event.
  /// [text] is the optional transcription or label for this riff.
  /// Returns the created [CueEventModel].
  CueEventModel addCapture(CaptureEvent capture, {String text = ''}) {
    _riffCounter++;

    final cue = CueEventModel(
      id: '${trackId}_riff_$_riffCounter',
      trackId: trackId,
      track: TrackType.userRiff.name,
      startMs: capture.startPositionMs,
      endMs: capture.endPositionMs,
      text: text.isNotEmpty ? text : 'User riff #$_riffCounter',
      kind: CueKind.userRiff,
      mode: CueMode.displayOnly,
      priority: 60, // User riffs default priority.
      speakerRole: SpeakerRole.user,
      windowRef: capture.windowId,
      interruptible: true,
      enabled: true,
      sourceFile: capture.audioFilePath,
      sourceIndex: _riffCounter - 1,
      tags: const ['USER'],
    );

    _riffs.add(cue);

    // Keep sorted by start time.
    _riffs.sort((a, b) => a.startMs.compareTo(b.startMs));

    AppLogger.info(
      _tag,
      'Added user riff ${cue.id}: ${cue.startMs}ms–${cue.endMs}ms',
    );

    return cue;
  }

  /// Remove a riff by ID.
  ///
  /// Returns `true` if the riff was found and removed.
  bool removeRiff(String riffId) {
    final index = _riffs.indexWhere((r) => r.id == riffId);
    if (index < 0) return false;
    _riffs.removeAt(index);
    AppLogger.info(_tag, 'Removed user riff: $riffId');
    return true;
  }

  /// Enable or disable a riff by ID.
  bool setEnabled(String riffId, bool enabled) {
    final index = _riffs.indexWhere((r) => r.id == riffId);
    if (index < 0) return false;
    _riffs[index] = _riffs[index].copyWith(enabled: enabled);
    return true;
  }

  /// Convert this user riff track to a [CueTrack].
  ///
  /// The returned [CueTrack] can be added to the cue evaluator for
  /// priority resolution alongside pre-authored tracks.
  CueTrack toCueTrack() {
    return CueTrack(
      trackId: trackId,
      trackType: TrackType.userRiff,
      cues: List.from(_riffs),
    );
  }

  /// Clear all riffs.
  void clear() {
    _riffs.clear();
    _riffCounter = 0;
    AppLogger.info(_tag, 'User riff track cleared');
  }

  /// Get a riff by ID, or null.
  CueEventModel? getRiff(String riffId) {
    try {
      return _riffs.firstWhere((r) => r.id == riffId);
    } catch (_) {
      return null;
    }
  }

  /// Get the riff at a specific playback position, or null.
  CueEventModel? getRiffAt(int positionMs) {
    for (final riff in _riffs) {
      if (riff.enabled &&
          positionMs >= riff.startMs &&
          positionMs < riff.endMs) {
        return riff;
      }
    }
    return null;
  }
}
