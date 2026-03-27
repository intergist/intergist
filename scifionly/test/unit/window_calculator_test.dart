import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/cue_engine/window_calculator.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';

import '../helpers/test_helpers.dart';

void main() {
  const calculator = WindowCalculator();

  setUp(() {
    enableTestLogging();
  });

  tearDown(() {
    disableTestLogging();
  });

  /// Helper to build a CueTrack with cues at specified time ranges.
  CueTrack buildTrack(List<List<int>> timeRanges) {
    final cues = <CueEventModel>[];
    for (int i = 0; i < timeRanges.length; i++) {
      cues.add(CueEventModel(
        id: 'cue_$i',
        trackId: 'ref',
        track: 'reference',
        startMs: timeRanges[i][0],
        endMs: timeRanges[i][1],
        text: 'Cue $i',
        kind: CueKind.dialogue,
        mode: CueMode.displayOnly,
        priority: 100,
        speakerRole: SpeakerRole.narrator,
        interruptible: false,
        enabled: true,
        sourceIndex: i,
      ));
    }
    return CueTrack(
      trackId: 'ref',
      trackType: TrackType.reference,
      cues: cues,
    );
  }

  group('detecting gaps between dialogue cues', () {
    test('creates window for large gap between two cues', () {
      // Gap: 5000 to 15000 = 10000ms gap (well above 2500ms minimum)
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);

      expect(windows.length, 1);
      // openMs = gapStart + leadIn = 5000 + 1500 = 6500
      expect(windows[0].startMs, 6500);
      // closeMs = gapEnd - leadOut = 15000 - 1500 = 13500
      expect(windows[0].endMs, 13500);
    });

    test('detects multiple gaps in a multi-cue track', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
        [30000, 35000],
      ]);
      final windows = calculator.calculate(track);

      expect(windows.length, 2);
      // First gap: 5000 to 15000
      expect(windows[0].startMs, 6500);
      expect(windows[0].endMs, 13500);
      // Second gap: 20000 to 30000
      expect(windows[1].startMs, 21500);
      expect(windows[1].endMs, 28500);
    });
  });

  group('filtering gaps shorter than minWindowMs (2.5s)', () {
    test('skips gaps smaller than minOpenMs', () {
      // Gap: 5000 to 6000 = 1000ms (below 2500ms default minimum)
      final track = buildTrack([
        [0, 5000],
        [6000, 10000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });

    test('skips gap exactly at minOpenMs boundary if effective window <= 0', () {
      // Gap: 5000 to 7500 = 2500ms (equals minOpenMs)
      // But openMs = 5000 + 1500 = 6500, closeMs = 7500 - 1500 = 6000
      // closeMs <= openMs, so skip
      final track = buildTrack([
        [0, 5000],
        [7500, 12000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });

    test('skips gaps where effective window <= 0 after margins', () {
      // Gap: 5000 to 8000 = 3000ms (above 2500ms)
      // But openMs = 5000 + 1500 = 6500, closeMs = 8000 - 1500 = 6500
      // closeMs <= openMs, so skip
      final track = buildTrack([
        [0, 5000],
        [8000, 12000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });

    test('mixes qualifying and non-qualifying gaps', () {
      final track = buildTrack([
        [0, 5000], // gap to 6000: 1000ms (skip)
        [6000, 10000], // gap to 20000: 10000ms (qualify)
        [20000, 25000], // gap to 26000: 1000ms (skip)
        [26000, 30000],
      ]);
      final windows = calculator.calculate(track);

      expect(windows.length, 1);
      expect(windows[0].startMs, 11500); // 10000 + 1500
      expect(windows[0].endMs, 18500); // 20000 - 1500
    });
  });

  group('window boundaries from gap boundaries', () {
    test('window start = gapStart + leadInMs', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      // gapStart = 5000, leadInMs = 1500
      expect(windows[0].startMs, 5000 + 1500);
    });

    test('window end = gapEnd - leadOutMs', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      // gapEnd = 15000, leadOutMs = 1500
      expect(windows[0].endMs, 15000 - 1500);
    });

    test('window duration is correct', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      // 13500 - 6500 = 7000
      expect(windows[0].durationMs, 7000);
    });
  });

  group('leadIn/leadOut values', () {
    test('default calculator sets stateLeadInMs to 1500', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].stateLeadInMs, 1500);
    });

    test('default calculator sets stateLeadOutMs to 1500', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].stateLeadOutMs, 1500);
    });

    test('custom leadIn/leadOut change window edges', () {
      final customCalc =
          const WindowCalculator(leadInMs: 500, leadOutMs: 500);
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);

      final windows = customCalc.calculate(track);
      expect(windows.length, 1);
      expect(windows[0].startMs, 5500); // 5000 + 500
      expect(windows[0].endMs, 14500); // 15000 - 500
    });

    test('zero leadIn and leadOut uses full gap', () {
      final customCalc = const WindowCalculator(
        leadInMs: 0,
        leadOutMs: 0,
        minOpenMs: 1000,
      );
      final track = buildTrack([
        [0, 5000],
        [7000, 12000], // gap = 2000ms
      ]);

      final windows = customCalc.calculate(track);
      expect(windows.length, 1);
      expect(windows[0].startMs, 5000);
      expect(windows[0].endMs, 7000);
    });
  });

  group('empty reference track returns no windows', () {
    test('empty track produces no windows', () {
      final track = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });
  });

  group('single cue returns no windows', () {
    test('track with one cue produces no windows (no gap possible)', () {
      final track = buildTrack([
        [0, 5000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });
  });

  group('adjacent cues with small gap: no window', () {
    test('adjacent cues with zero gap produce no windows', () {
      final track = buildTrack([
        [0, 5000],
        [5000, 10000],
        [10000, 15000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });

    test('cues with very small gap (100ms) produce no windows', () {
      final track = buildTrack([
        [0, 5000],
        [5100, 10000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows, isEmpty);
    });
  });

  group('large gap between cues: window created', () {
    test('very large gap produces valid wide window', () {
      final track = buildTrack([
        [0, 1000],
        [100000, 101000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows.length, 1);
      expect(windows[0].startMs, 2500); // 1000 + 1500
      expect(windows[0].endMs, 98500); // 100000 - 1500
      expect(windows[0].durationMs, 96000);
    });

    test('barely qualifying gap produces narrow window', () {
      // Minimum gap for effective window > 0: leadIn + leadOut + 1 = 3001ms
      final track = buildTrack([
        [0, 5000],
        [8001, 12000], // gap = 3001ms
      ]);
      final windows = calculator.calculate(track);
      expect(windows.length, 1);
      expect(windows[0].startMs, 6500); // 5000 + 1500
      expect(windows[0].endMs, 6501); // 8001 - 1500
      expect(windows[0].durationMs, 1);
    });
  });

  group('window metadata fields', () {
    test('window has correct predictedFrom field', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].predictedFrom, 'dialogue_gap');
    });

    test('window has correct minOpenMs field', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].minOpenMs, 2500);
    });

    test('window has correct maxUserRiffMs field', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].maxUserRiffMs, 7000);
    });

    test('window has allowAppSpeech false and allowUserCapture true', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].allowAppSpeech, isFalse);
      expect(windows[0].allowUserCapture, isTrue);
    });

    test('windows have sequential IDs starting from window_0', () {
      final track = buildTrack([
        [0, 5000],
        [15000, 20000],
        [30000, 35000],
      ]);
      final windows = calculator.calculate(track);
      expect(windows[0].id, 'window_0');
      expect(windows[1].id, 'window_1');
    });
  });

  group('custom minOpenMs', () {
    test('lower minOpenMs allows smaller gaps', () {
      // Default would skip 2000ms gap but custom allows it
      final customCalc = const WindowCalculator(
        minOpenMs: 1000,
        leadInMs: 0,
        leadOutMs: 0,
      );
      final track = buildTrack([
        [0, 5000],
        [7000, 12000], // gap = 2000ms
      ]);

      final windows = customCalc.calculate(track);
      expect(windows.length, 1);
    });

    test('higher minOpenMs filters more gaps', () {
      final customCalc = const WindowCalculator(minOpenMs: 15000);
      final track = buildTrack([
        [0, 5000],
        [15000, 20000], // gap = 10000ms, below 15000ms threshold
      ]);

      final windows = customCalc.calculate(track);
      expect(windows, isEmpty);
    });
  });
}
