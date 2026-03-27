/// Exports a [CueTrack] back to standard SRT format.
///
/// Preserves riff-track tags for riff and user-riff tracks, and ensures
/// the output is valid SRT.
library;

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/export/models/export_result.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'EXPORT';

/// Exports cue tracks to SRT format.
class SrtExporter {
  const SrtExporter();

  /// Export a single [CueTrack] to SRT string content.
  ExportResult export(CueTrack track) {
    AppLogger.info(
      _tag,
      'Exporting CueTrack "${track.trackId}" '
      '(${track.length} cues) to SRT',
    );

    if (track.isEmpty) {
      AppLogger.warn(_tag, 'Track is empty; producing empty SRT');
      return ExportResult.srtContent(
        content: '',
        cueCount: 0,
        includedFiles: ['${track.trackId}.srt'],
      );
    }

    final buffer = StringBuffer();
    final cues = track.allCues;

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];

      // Index line (1-based).
      buffer.writeln(i + 1);

      // Timecode line.
      buffer.writeln(
        '${_formatTimecode(cue.startMs)} --> ${_formatTimecode(cue.endMs)}',
      );

      // Text line with optional tags.
      final text = _buildTextLine(cue, track.trackType);
      buffer.writeln(text);

      // Blank line separator.
      buffer.writeln();
    }

    final content = buffer.toString().trimRight();

    AppLogger.info(
      _tag,
      'SRT export complete: ${cues.length} cues, '
      '${content.length} characters',
    );

    return ExportResult.srtContent(
      content: content,
      cueCount: cues.length,
      includedFiles: ['${track.trackId}.srt'],
    );
  }

  /// Export multiple [CueTrack]s, returning a map of trackId -> SRT content.
  Map<String, ExportResult> exportAll(List<CueTrack> tracks) {
    final results = <String, ExportResult>{};
    for (final track in tracks) {
      results[track.trackId] = export(track);
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Format milliseconds as SRT timecode: HH:MM:SS,mmm
  String _formatTimecode(int ms) {
    final hours = ms ~/ 3600000;
    final minutes = (ms % 3600000) ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final millis = ms % 1000;

    return '${_pad2(hours)}:${_pad2(minutes)}:${_pad2(seconds)},${_pad3(millis)}';
  }

  String _pad2(int value) => value.toString().padLeft(2, '0');
  String _pad3(int value) => value.toString().padLeft(3, '0');

  /// Build the text line for a cue, prepending tags for riff tracks.
  String _buildTextLine(CueEventModel cue, TrackType trackType) {
    if (trackType == TrackType.reference) {
      // Reference tracks don't get tags.
      return cue.text;
    }

    final tagParts = <String>[];

    // Speaker role tags.
    if (cue.speakerRole == SpeakerRole.app) {
      tagParts.add('[APP]');
    } else if (cue.speakerRole == SpeakerRole.user) {
      tagParts.add('[USER]');
    }

    // Mode tags.
    if (cue.mode == CueMode.speak || cue.mode == CueMode.displayAndSpeak) {
      tagParts.add('[SPEAK]');
    }
    if (cue.mode == CueMode.displayOnly) {
      tagParts.add('[DISPLAY]');
    }

    // Mute-in-recording tag.
    if (cue.tags.contains('MUTE_IN_RECORDING')) {
      tagParts.add('[MUTE_IN_RECORDING]');
    }

    // Priority tag (only if non-default).
    final defaultPriority = trackType == TrackType.riff ? 50 : 60;
    if (cue.priority != defaultPriority) {
      tagParts.add('[PRIORITY=${cue.priority}]');
    }

    // Window reference tag.
    if (cue.windowRef != null) {
      tagParts.add('[WINDOW=${cue.windowRef}]');
    }

    if (tagParts.isEmpty) {
      return cue.text;
    }

    return '${tagParts.join(" ")} ${cue.text}';
  }
}
