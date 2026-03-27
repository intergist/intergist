/// A [CueTrack] holds an ordered list of [CueEventModel] instances and
/// provides query methods for the cue engine.
library;

import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'CUE_ENGINE';

/// An in-memory track of cue events, sorted by start time.
class CueTrack {
  final String trackId;
  final TrackType trackType;
  final List<CueEventModel> _cues;

  CueTrack({
    required this.trackId,
    required this.trackType,
    List<CueEventModel>? cues,
  }) : _cues = List<CueEventModel>.from(cues ?? []);

  /// All cues in this track, ordered by start time.
  List<CueEventModel> get allCues => List.unmodifiable(_cues);

  /// Number of cues.
  int get length => _cues.length;

  /// Whether this track has no cues.
  bool get isEmpty => _cues.isEmpty;

  /// Build a [CueTrack] from parsed SRT entries.
  ///
  /// Converts each [SrtEntry] into a [CueEventModel] using the given
  /// [trackType] and [trackId].
  static CueTrack normalize(
    List<SrtEntry> entries,
    TrackType trackType,
    String trackId,
  ) {
    AppLogger.info(
      _tag,
      'Normalizing ${entries.length} SRT entries into CueTrack '
      '"$trackId" (${trackType.name})',
    );

    final cues = <CueEventModel>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];

      final kind = _kindFromTrackType(trackType);
      final mode = _modeFromTags(entry.tags, trackType);
      final speakerRole = _speakerFromTags(entry.tags, trackType);
      final priority = entry.tags.priority ?? _defaultPriority(trackType);

      final cue = CueEventModel(
        id: '${trackId}_${entry.index}',
        trackId: trackId,
        track: trackType.name,
        startMs: entry.startMs,
        endMs: entry.endMs,
        text: entry.text,
        kind: kind,
        mode: mode,
        priority: priority,
        speakerRole: speakerRole,
        windowRef: entry.tags.windowRef,
        interruptible: trackType != TrackType.reference,
        enabled: true,
        sourceFile: null,
        sourceIndex: i,
        tags: _collectTags(entry.tags),
      );

      cues.add(cue);
    }

    // Sort by start time for consistent access.
    cues.sort((a, b) {
      final cmp = a.startMs.compareTo(b.startMs);
      if (cmp != 0) return cmp;
      return (a.sourceIndex ?? 0).compareTo(b.sourceIndex ?? 0);
    });

    AppLogger.info(
      _tag,
      'CueTrack "$trackId" normalized with ${cues.length} cues',
    );

    return CueTrack(
      trackId: trackId,
      trackType: trackType,
      cues: cues,
    );
  }

  /// Return all cues whose time range overlaps [startMs]..[endMs].
  List<CueEventModel> getCuesInRange(int startMs, int endMs) {
    // Binary search could be used for large tracks; linear is fine for
    // typical SRT sizes (< 2000 cues).
    return _cues
        .where((c) => c.startMs < endMs && c.endMs > startMs && c.enabled)
        .toList();
  }

  /// Return the first cue that contains [positionMs], or null.
  CueEventModel? getCueAt(int positionMs) {
    for (final cue in _cues) {
      if (cue.enabled &&
          positionMs >= cue.startMs &&
          positionMs < cue.endMs) {
        return cue;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static CueKind _kindFromTrackType(TrackType type) {
    switch (type) {
      case TrackType.reference:
        return CueKind.dialogue;
      case TrackType.riff:
        return CueKind.riff;
      case TrackType.userRiff:
        return CueKind.userRiff;
    }
  }

  static CueMode _modeFromTags(SrtTags tags, TrackType trackType) {
    if (tags.isSpeak && tags.isDisplay) return CueMode.displayAndSpeak;
    if (tags.isSpeak) return CueMode.speak;
    if (tags.isDisplay) return CueMode.displayOnly;

    // Defaults per track type.
    switch (trackType) {
      case TrackType.reference:
        return CueMode.displayOnly;
      case TrackType.riff:
        return CueMode.displayAndSpeak;
      case TrackType.userRiff:
        return CueMode.displayOnly;
    }
  }

  static SpeakerRole _speakerFromTags(SrtTags tags, TrackType trackType) {
    if (tags.isUser) return SpeakerRole.user;
    if (tags.isApp) return SpeakerRole.app;

    switch (trackType) {
      case TrackType.reference:
        return SpeakerRole.narrator;
      case TrackType.riff:
        return SpeakerRole.app;
      case TrackType.userRiff:
        return SpeakerRole.user;
    }
  }

  static int _defaultPriority(TrackType trackType) {
    switch (trackType) {
      case TrackType.reference:
        return 100;
      case TrackType.riff:
        return 50;
      case TrackType.userRiff:
        return 60;
    }
  }

  static List<String> _collectTags(SrtTags tags) {
    final result = <String>[];
    if (tags.isApp) result.add('APP');
    if (tags.isUser) result.add('USER');
    if (tags.isSpeak) result.add('SPEAK');
    if (tags.isDisplay) result.add('DISPLAY');
    if (tags.isMuteInRecording) result.add('MUTE_IN_RECORDING');
    if (tags.priority != null) result.add('PRIORITY=${tags.priority}');
    if (tags.windowRef != null) result.add('WINDOW=${tags.windowRef}');
    return result;
  }
}
