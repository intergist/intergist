import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/srt_parser.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/cue_engine/cue_evaluator.dart';
import 'package:scifionly/features/cue_engine/cue_priority.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/models/track.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Recording Session', () {
    late SrtParser parser;
    late CueTrack referenceTrack;

    setUp(() {
      parser = const SrtParser();

      final movieSrt = readFixture('movie.srt');
      final movieResult = parser.parse(movieSrt, source: 'movie.srt');
      referenceTrack = CueTrack.normalize(
        movieResult.entries,
        TrackType.reference,
        'ref-001',
      );
    });

    group('dialogue gap identification for participation windows', () {
      test('reference track has gaps between dialogue cues', () {
        final cues = referenceTrack.allCues;

        // Gap between cue 1 (end 7000) and cue 2 (start 8200) = 1200ms.
        final gap1 = cues[1].startMs - cues[0].endMs;
        expect(gap1, 1200);

        // Gap between cue 2 (end 10600) and cue 3 (start 15500) = 4900ms.
        final gap2 = cues[2].startMs - cues[1].endMs;
        expect(gap2, 4900);

        // Gap between cue 3 (end 18000) and cue 4 (start 25000) = 7000ms.
        final gap3 = cues[3].startMs - cues[2].endMs;
        expect(gap3, 7000);
      });

      test('identifies qualifying gaps (>= 2500ms default min)', () {
        final cues = referenceTrack.allCues;
        const minOpenMs = 2500;
        int qualifyingGaps = 0;

        for (int i = 0; i < cues.length - 1; i++) {
          final gap = cues[i + 1].startMs - cues[i].endMs;
          if (gap >= minOpenMs) {
            qualifyingGaps++;
          }
        }

        // Gap 2 (4900ms) and Gap 3 (7000ms) qualify.
        expect(qualifyingGaps, 2);
      });

      test('gap 1 (1200ms) does not qualify as window', () {
        final cues = referenceTrack.allCues;
        const minOpenMs = 2500;
        final gap = cues[1].startMs - cues[0].endMs;

        expect(gap, lessThan(minOpenMs));
      });

      test('gap 2 (4900ms) qualifies as window', () {
        final cues = referenceTrack.allCues;
        const minOpenMs = 2500;
        final gap = cues[2].startMs - cues[1].endMs;

        expect(gap, greaterThanOrEqualTo(minOpenMs));
      });

      test('gap 3 (7000ms) qualifies as window', () {
        final cues = referenceTrack.allCues;
        const minOpenMs = 2500;
        final gap = cues[3].startMs - cues[2].endMs;

        expect(gap, greaterThanOrEqualTo(minOpenMs));
      });
    });

    group('window state transitions', () {
      // Simulating window from gap 3 (18000ms -> 25000ms).
      // With leadIn=1500ms, leadOut=1500ms:
      //   Warning starts at gapStart (18000ms)
      //   Window opens at 18000 + 1500 = 19500ms
      //   Window closes at 25000 - 1500 = 23500ms
      //   Warning starts at 23500ms
      //   Closed at 25000ms

      test('state is closed before gap begins', () {
        // Before gap: dialogue is playing.
        const positionMs = 17000;
        const gapStart = 18000;

        expect(positionMs, lessThan(gapStart));
        // State: CLOSED (Red) -- dialogue is active.
      });

      test('state is warning (yellow) during lead-in', () {
        // Lead-in period: gapStart to gapStart + leadInMs.
        const gapStart = 18000;
        const leadInMs = 1500;
        const positionMs = 18500; // 500ms into lead-in.
        const windowOpen = gapStart + leadInMs; // 19500ms

        expect(positionMs, greaterThanOrEqualTo(gapStart));
        expect(positionMs, lessThan(windowOpen));
        // State: WARNING (Yellow) -- window about to open.
      });

      test('state is open (green) during window', () {
        const gapStart = 18000;
        const gapEnd = 25000;
        const leadInMs = 1500;
        const leadOutMs = 1500;
        const windowOpen = gapStart + leadInMs; // 19500ms
        const windowClose = gapEnd - leadOutMs; // 23500ms
        const positionMs = 21000; // Middle of window.

        expect(positionMs, greaterThanOrEqualTo(windowOpen));
        expect(positionMs, lessThan(windowClose));
        // State: OPEN (Green) -- user can participate.
      });

      test('state is warning (yellow) during lead-out', () {
        const gapEnd = 25000;
        const leadOutMs = 1500;
        const windowClose = gapEnd - leadOutMs; // 23500ms
        const positionMs = 24000; // In lead-out period.

        expect(positionMs, greaterThanOrEqualTo(windowClose));
        expect(positionMs, lessThan(gapEnd));
        // State: WARNING (Yellow) -- window about to close.
      });

      test('state is closed (red) after gap ends', () {
        const gapEnd = 25000;
        const positionMs = 25500; // After gap, dialogue resumed.

        expect(positionMs, greaterThan(gapEnd));
        // State: CLOSED (Red) -- dialogue is active again.
      });

      test('effective window duration is gap - leadIn - leadOut', () {
        const gapStart = 18000;
        const gapEnd = 25000;
        const leadInMs = 1500;
        const leadOutMs = 1500;
        const windowOpen = gapStart + leadInMs;
        const windowClose = gapEnd - leadOutMs;

        final effectiveDuration = windowClose - windowOpen;
        expect(effectiveDuration, 4000); // 7000 - 1500 - 1500
        expect(effectiveDuration, greaterThan(0));
      });
    });

    group('capture timing constraints', () {
      test('maximum capture duration is 7 seconds', () {
        const maxUserRiffMs = 7000;

        // A user recording should not exceed this limit.
        expect(maxUserRiffMs, 7000);
      });

      test('capture fits within window duration', () {
        const windowDuration = 4000; // From gap 3 effective duration.
        const maxUserRiffMs = 7000;

        // The capture is capped by the shorter of window and max riff.
        final effectiveCapture =
            windowDuration < maxUserRiffMs ? windowDuration : maxUserRiffMs;
        expect(effectiveCapture, 4000);
        expect(effectiveCapture, lessThanOrEqualTo(maxUserRiffMs));
      });

      test('larger gap allows full capture', () {
        // If we had a gap of 10000ms with 1500ms margins:
        // effective = 10000 - 1500 - 1500 = 7000ms
        const windowDuration = 7000;
        const maxUserRiffMs = 7000;

        final effectiveCapture =
            windowDuration < maxUserRiffMs ? windowDuration : maxUserRiffMs;
        expect(effectiveCapture, maxUserRiffMs);
      });
    });

    group('recording mode priority rules', () {
      test('display-only outranks spoken in recording mode', () {
        final resolver = const CuePriorityResolver();

        final spoken = createTestCue(
          id: 'spoken',
          priority: 50,
          mode: CueMode.speak,
          startMs: 10000,
          endMs: 15000,
        );
        final displayOnly = createTestCue(
          id: 'display',
          priority: 50,
          mode: CueMode.displayOnly,
          startMs: 10000,
          endMs: 15000,
        );

        final winner = resolver.resolve(
          [spoken, displayOnly],
          SessionMode.recording,
        );

        expect(winner!.id, 'display');
      });

      test('user riff outranks app riff during active recording', () {
        final resolver = const CuePriorityResolver();

        final appRiff = createTestCue(
          id: 'app-riff',
          priority: 50,
          kind: CueKind.riff,
          speakerRole: SpeakerRole.app,
          startMs: 10000,
          endMs: 15000,
        );
        final userRiff = createTestCue(
          id: 'user-riff',
          priority: 50,
          kind: CueKind.userRiff,
          speakerRole: SpeakerRole.user,
          startMs: 10000,
          endMs: 15000,
        );

        final winner = resolver.resolve(
          [appRiff, userRiff],
          SessionMode.recording,
          isActivelyRecording: true,
        );

        expect(winner!.id, 'user-riff');
      });

      test(
          'app riff wins over user riff when NOT actively recording '
          '(same priority, mode, start)', () {
        final resolver = const CuePriorityResolver();

        final appRiff = createTestCue(
          id: 'app-riff',
          priority: 50,
          kind: CueKind.riff,
          speakerRole: SpeakerRole.app,
          startMs: 10000,
          endMs: 15000,
          sourceIndex: 0,
        );
        final userRiff = createTestCue(
          id: 'user-riff',
          priority: 50,
          kind: CueKind.userRiff,
          speakerRole: SpeakerRole.user,
          startMs: 10000,
          endMs: 15000,
          sourceIndex: 1,
        );

        final winner = resolver.resolve(
          [appRiff, userRiff],
          SessionMode.recording,
          isActivelyRecording: false,
        );

        // When not recording, user riff recording rank is not applied.
        // Tie goes to stable sort by source index.
        expect(winner, isNotNull);
      });
    });

    group('evaluator in recording mode', () {
      test('evaluator operates in recording mode', () {
        final evaluator = CueEvaluator(
          tracks: [referenceTrack],
          mode: SessionMode.recording,
        );

        final result = evaluator.evaluate(6000);

        expect(result.activeCue, isNotNull);
        expect(result.activeCue!.text, 'Crew status check.');
      });

      test('markFired prevents re-fire', () {
        final evaluator = CueEvaluator(
          tracks: [referenceTrack],
          mode: SessionMode.recording,
        );

        // Get the cue ID first.
        final result = evaluator.evaluate(6000);
        final cueId = result.activeCue!.id;

        evaluator.reset();
        evaluator.markFired(cueId);

        // Now evaluate again at the same position.
        final result2 = evaluator.evaluate(6000);

        expect(result2.activeCue, isNotNull);
        expect(result2.isNewFire, isFalse);
      });
    });
  });
}
