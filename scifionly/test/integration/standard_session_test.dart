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
  group('Standard Session Lifecycle', () {
    late SrtParser parser;
    late CueTrack referenceTrack;
    late CueTrack riffTrack;

    setUp(() {
      parser = const SrtParser();

      // Parse reference track.
      final movieSrt = readFixture('movie.srt');
      final movieResult = parser.parse(movieSrt, source: 'movie.srt');
      referenceTrack = CueTrack.normalize(
        movieResult.entries,
        TrackType.reference,
        'ref-001',
      );

      // Parse riff track.
      final riffSrt = readFixture('riffs.srt');
      final riffResult = parser.parse(riffSrt, source: 'riffs.srt');
      riffTrack = CueTrack.normalize(
        riffResult.entries,
        TrackType.riff,
        'riff-001',
      );
    });

    group('project setup with reference and riff tracks', () {
      test('reference track has 4 cues', () {
        expect(referenceTrack.length, 4);
      });

      test('riff track has 3 cues', () {
        expect(riffTrack.length, 3);
      });

      test('reference track is type reference', () {
        expect(referenceTrack.trackType, TrackType.reference);
      });

      test('riff track is type riff', () {
        expect(riffTrack.trackType, TrackType.riff);
      });
    });

    group('cue evaluation at specific timestamps', () {
      late CueEvaluator evaluator;

      setUp(() {
        evaluator = CueEvaluator(
          tracks: [referenceTrack, riffTrack],
          mode: SessionMode.standard,
        );
      });

      test('no cue fires at timestamp 0ms (before any cue)', () {
        final result = evaluator.evaluate(0);

        expect(result.activeCue, isNull);
        expect(result.candidates, isEmpty);
      });

      test('reference cue fires at 5500ms (during first dialogue)', () {
        final result = evaluator.evaluate(5500);

        expect(result.activeCue, isNotNull);
        expect(result.activeCue!.text, 'Crew status check.');
        expect(result.isNewFire, isTrue);
      });

      test('no cue fires at 7500ms (gap between cue 1 and 2)', () {
        // Cue 1 ends at 7000ms, cue 2 starts at 8200ms.
        final result = evaluator.evaluate(7500);

        expect(result.activeCue, isNull);
      });

      test('reference cue fires at 9000ms (during second dialogue)', () {
        final result = evaluator.evaluate(9000);

        expect(result.activeCue, isNotNull);
        expect(result.activeCue!.text, 'All systems nominal.');
      });

      test('riff cue fires at 11000ms (overlap with riff entry 1)', () {
        // Riff entry 1: 10900ms -> 13200ms
        // Reference entry 3: 15500ms -> 18000ms (not active yet)
        final result = evaluator.evaluate(11000);

        expect(result.activeCue, isNotNull);
        // The riff entry is the only cue active at 11000ms.
        expect(result.activeCue!.text, contains('Translation'));
      });

      test('correct cue fires at 16000ms (during third dialogue)', () {
        final result = evaluator.evaluate(16000);

        expect(result.activeCue, isNotNull);
        expect(
          result.activeCue!.text,
          'Something just moved on the scanner.',
        );
      });

      test('correct cue fires at 26000ms (during fourth dialogue)', () {
        final result = evaluator.evaluate(26000);

        expect(result.activeCue, isNotNull);
        expect(
          result.activeCue!.text,
          'That signal is coming from the derelict.',
        );
      });

      test('no cue fires at 35000ms (after all cues)', () {
        final result = evaluator.evaluate(35000);

        expect(result.activeCue, isNull);
      });
    });

    group('priority resolution between overlapping cues', () {
      test('reference outranks riff when both active at same priority', () {
        // Reference cues have priority 100, riff cues have priority 50.
        // So reference should always win when both are active.
        expect(
          referenceTrack.allCues.first.priority,
          greaterThan(riffTrack.allCues.first.priority),
        );
      });

      test('higher priority wins in standard mode', () {
        final resolver = const CuePriorityResolver();

        final highPriority = createTestCue(
          id: 'high',
          priority: 100,
          startMs: 10000,
          endMs: 15000,
        );
        final lowPriority = createTestCue(
          id: 'low',
          priority: 50,
          startMs: 10000,
          endMs: 15000,
        );

        final winner = resolver.resolve(
          [lowPriority, highPriority],
          SessionMode.standard,
        );

        expect(winner, isNotNull);
        expect(winner!.id, 'high');
      });

      test('spoken outranks display-only in standard mode (same priority)',
          () {
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
          [displayOnly, spoken],
          SessionMode.standard,
        );

        expect(winner, isNotNull);
        expect(winner!.id, 'spoken');
      });

      test('display-only outranks spoken in recording mode (same priority)',
          () {
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

        expect(winner, isNotNull);
        expect(winner!.id, 'display');
      });

      test('earlier start time wins when priority and mode are tied', () {
        final resolver = const CuePriorityResolver();

        final earlier = createTestCue(
          id: 'earlier',
          priority: 50,
          startMs: 10000,
          endMs: 15000,
        );
        final later = createTestCue(
          id: 'later',
          priority: 50,
          startMs: 11000,
          endMs: 16000,
        );

        final winner = resolver.resolve(
          [later, earlier],
          SessionMode.standard,
        );

        expect(winner, isNotNull);
        expect(winner!.id, 'earlier');
      });

      test('shorter duration wins when priority, mode, and start are tied',
          () {
        final resolver = const CuePriorityResolver();

        final shorter = createTestCue(
          id: 'shorter',
          priority: 50,
          startMs: 10000,
          endMs: 12000,
        );
        final longer = createTestCue(
          id: 'longer',
          priority: 50,
          startMs: 10000,
          endMs: 15000,
        );

        final winner = resolver.resolve(
          [longer, shorter],
          SessionMode.standard,
        );

        expect(winner, isNotNull);
        expect(winner!.id, 'shorter');
      });
    });

    group('evaluator state tracking', () {
      late CueEvaluator evaluator;

      setUp(() {
        evaluator = CueEvaluator(
          tracks: [referenceTrack, riffTrack],
          mode: SessionMode.standard,
        );
      });

      test('tracks fired cue IDs', () {
        evaluator.evaluate(5500);
        evaluator.evaluate(9000);

        expect(evaluator.firedCueIds.length, 2);
      });

      test('same cue does not fire twice', () {
        final first = evaluator.evaluate(5500);
        expect(first.isNewFire, isTrue);

        final second = evaluator.evaluate(5800);
        expect(second.isNewFire, isFalse);
        expect(second.activeCue?.text, first.activeCue?.text);
      });

      test('reset clears fired state', () {
        evaluator.evaluate(5500);
        expect(evaluator.firedCueIds, isNotEmpty);

        evaluator.reset();
        expect(evaluator.firedCueIds, isEmpty);
        expect(evaluator.currentCueId, isNull);
      });

      test('hasFired correctly reports state', () {
        final result = evaluator.evaluate(5500);

        expect(evaluator.hasFired(result.activeCue!.id), isTrue);
        expect(evaluator.hasFired('nonexistent'), isFalse);
      });

      test('evaluateRange returns all cues in time window', () {
        // Reference entries span 5000-28500, riff entries span 10900-31500.
        final rangeCues = evaluator.evaluateRange(0, 30000);

        // Should include all 7 cues (4 reference + 3 riff).
        expect(rangeCues.length, 7);
      });

      test('evaluateRange returns subset for narrow window', () {
        // Only the first reference cue (5000-7000) should be in range.
        final rangeCues = evaluator.evaluateRange(4000, 7500);

        expect(rangeCues.length, 1);
        expect(rangeCues.first.text, 'Crew status check.');
      });
    });

    group('getCueAt and getCuesInRange on CueTrack', () {
      test('getCueAt returns correct cue', () {
        final cue = referenceTrack.getCueAt(6000);

        expect(cue, isNotNull);
        expect(cue!.text, 'Crew status check.');
      });

      test('getCueAt returns null when no cue at position', () {
        final cue = referenceTrack.getCueAt(7500);

        expect(cue, isNull);
      });

      test('getCuesInRange returns overlapping cues', () {
        final cues = referenceTrack.getCuesInRange(4000, 11000);

        // Reference cues 1 (5000-7000), 2 (8200-10600) overlap with range.
        expect(cues.length, 2);
      });

      test('getCuesInRange returns empty for gap', () {
        final cues = referenceTrack.getCuesInRange(7100, 8100);

        expect(cues, isEmpty);
      });
    });
  });
}
