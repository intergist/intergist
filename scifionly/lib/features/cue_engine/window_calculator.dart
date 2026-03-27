/// Calculates participation windows from gaps in a reference dialogue track.
///
/// Detects silence gaps between dialogue cues and converts qualifying gaps
/// into [ParticipationWindowModel] instances with configurable lead-in
/// and lead-out margins.
library;

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/models/participation_window_model.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'CUE_ENGINE';

/// Default minimum gap duration to qualify as a participation window (ms).
const int kDefaultMinOpenMs = 2500;

/// Default lead-in duration before a window opens (ms).
const int kDefaultLeadInMs = 1500;

/// Default lead-out duration before a window closes (ms).
const int kDefaultLeadOutMs = 1500;

/// Calculates participation windows from dialogue gaps.
class WindowCalculator {
  /// Minimum gap duration to create a window.
  final int minOpenMs;

  /// Lead-in time subtracted from the start of the gap.
  final int leadInMs;

  /// Lead-out time subtracted from the end of the gap.
  final int leadOutMs;

  const WindowCalculator({
    this.minOpenMs = kDefaultMinOpenMs,
    this.leadInMs = kDefaultLeadInMs,
    this.leadOutMs = kDefaultLeadOutMs,
  });

  /// Calculate participation windows from a reference (dialogue) [CueTrack].
  ///
  /// Detects gaps between consecutive dialogue cues that are at least
  /// [minOpenMs] long, applies lead-in and lead-out margins, and returns
  /// the resulting windows sorted by time.
  List<ParticipationWindowModel> calculate(CueTrack referenceTrack) {
    final cues = referenceTrack.allCues;

    if (cues.isEmpty) {
      AppLogger.warn(_tag, 'Reference track is empty; no windows generated');
      return [];
    }

    AppLogger.info(
      _tag,
      'Calculating participation windows from ${cues.length} dialogue cues '
      '(minOpen=${minOpenMs}ms, leadIn=${leadInMs}ms, leadOut=${leadOutMs}ms)',
    );

    final windows = <ParticipationWindowModel>[];
    int windowIndex = 0;

    for (int i = 0; i < cues.length - 1; i++) {
      final gapStart = cues[i].endMs;
      final gapEnd = cues[i + 1].startMs;
      final gapDuration = gapEnd - gapStart;

      if (gapDuration < minOpenMs) continue;

      // Apply lead-in: the window opens after the lead-in period.
      final openMs = gapStart + leadInMs;

      // Apply lead-out: the window closes before the lead-out period.
      final closeMs = gapEnd - leadOutMs;

      // After applying margins, the effective window must still be > 0.
      if (closeMs <= openMs) {
        AppLogger.debug(
          _tag,
          'Gap at ${gapStart}ms-${gapEnd}ms too short after margins; skipping',
        );
        continue;
      }

      final window = ParticipationWindowModel(
        id: 'window_$windowIndex',
        startMs: openMs,
        endMs: closeMs,
        predictedFrom: 'dialogue_gap',
        stateLeadInMs: leadInMs,
        stateLeadOutMs: leadOutMs,
        minOpenMs: minOpenMs,
        maxUserRiffMs: 7000,
        allowAppSpeech: false,
        allowUserCapture: true,
      );

      windows.add(window);
      windowIndex++;

      AppLogger.debug(
        _tag,
        'Window $windowIndex: open=${openMs}ms, close=${closeMs}ms '
        '(gap ${gapStart}ms-${gapEnd}ms, duration=${closeMs - openMs}ms)',
      );
    }

    AppLogger.info(
      _tag,
      'Generated ${windows.length} participation windows',
    );

    return windows;
  }
}
