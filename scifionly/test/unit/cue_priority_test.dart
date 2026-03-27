import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/cue_priority.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';

import '../helpers/test_helpers.dart';

void main() {
  const resolver = CuePriorityResolver();

  setUp(() {
    enableTestLogging();
  });

  tearDown(() {
    disableTestLogging();
  });

  /// Helper to create a CueEventModel with sensible defaults.
  CueEventModel makeCue({
    String id = 'cue-1',
    int startMs = 1000,
    int endMs = 3000,
    String text = 'test',
    CueKind kind = CueKind.riff,
    CueMode mode = CueMode.speak,
    int priority = 50,
    SpeakerRole speakerRole = SpeakerRole.app,
    int? sourceIndex,
  }) {
    return CueEventModel(
      id: id,
      trackId: 'track-1',
      track: 'riff',
      startMs: startMs,
      endMs: endMs,
      text: text,
      kind: kind,
      mode: mode,
      priority: priority,
      speakerRole: speakerRole,
      interruptible: true,
      enabled: true,
      sourceIndex: sourceIndex,
    );
  }

  group('basic resolution', () {
    test('returns null for empty candidates', () {
      final result = resolver.resolve([], SessionMode.standard);
      expect(result, isNull);
    });

    test('returns the only candidate when list has one entry', () {
      final cue = makeCue(id: 'solo');
      final result = resolver.resolve([cue], SessionMode.standard);
      expect(result, equals(cue));
      expect(result!.id, 'solo');
    });
  });

  group('Rule 1: higher explicit priority wins', () {
    test('priority 70 beats priority 50', () {
      final high = makeCue(id: 'high', priority: 70);
      final low = makeCue(id: 'low', priority: 50);

      final result =
          resolver.resolve([low, high], SessionMode.standard);
      expect(result!.id, 'high');
    });

    test('higher priority number wins in standard mode', () {
      final high = makeCue(id: 'high', priority: 80);
      final low = makeCue(id: 'low', priority: 40);

      final result =
          resolver.resolve([low, high], SessionMode.standard);
      expect(result!.id, 'high');
    });

    test('higher priority number wins in recording mode', () {
      final high = makeCue(id: 'high', priority: 90);
      final low = makeCue(id: 'low', priority: 10);

      final result =
          resolver.resolve([low, high], SessionMode.recording);
      expect(result!.id, 'high');
    });

    test('priority is checked before mode-based rules', () {
      final highPriDisplay = makeCue(
        id: 'high-display',
        priority: 100,
        mode: CueMode.displayOnly,
      );
      final lowPriSpeak = makeCue(
        id: 'low-speak',
        priority: 30,
        mode: CueMode.speak,
      );

      // In standard mode, speak normally outranks displayOnly,
      // but priority rule wins first.
      final result = resolver.resolve(
        [lowPriSpeak, highPriDisplay],
        SessionMode.standard,
      );
      expect(result!.id, 'high-display');
    });
  });

  group('Rule 2: standard mode - app_spoken outranks display_only', () {
    test('speak beats displayOnly at same priority', () {
      final spoken = makeCue(id: 'spoken', mode: CueMode.speak);
      final display = makeCue(id: 'display', mode: CueMode.displayOnly);

      final result = resolver.resolve(
        [display, spoken],
        SessionMode.standard,
      );
      expect(result!.id, 'spoken');
    });

    test('displayAndSpeak beats displayOnly at same priority', () {
      final both = makeCue(id: 'both', mode: CueMode.displayAndSpeak);
      final display = makeCue(id: 'display', mode: CueMode.displayOnly);

      final result = resolver.resolve(
        [display, both],
        SessionMode.standard,
      );
      expect(result!.id, 'both');
    });

    test('speak and displayAndSpeak are equal rank in standard mode', () {
      final speak = makeCue(
        id: 'speak',
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 0,
      );
      final both = makeCue(
        id: 'both',
        mode: CueMode.displayAndSpeak,
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 1,
      );

      final result = resolver.resolve(
        [both, speak],
        SessionMode.standard,
      );
      // Both have same modeRank (2), falls to rule 5/6/7
      // Same start, same duration, so sourceIndex breaks tie
      expect(result!.id, 'speak');
    });
  });

  group('Rule 3: recording mode - display_only outranks app_spoken', () {
    test('displayOnly beats speak at same priority in recording mode', () {
      final spoken = makeCue(id: 'spoken', mode: CueMode.speak);
      final display = makeCue(id: 'display', mode: CueMode.displayOnly);

      final result = resolver.resolve(
        [spoken, display],
        SessionMode.recording,
      );
      expect(result!.id, 'display');
    });

    test('displayOnly beats displayAndSpeak at same priority in recording mode',
        () {
      final both = makeCue(id: 'both', mode: CueMode.displayAndSpeak);
      final display = makeCue(id: 'display', mode: CueMode.displayOnly);

      final result = resolver.resolve(
        [both, display],
        SessionMode.recording,
      );
      expect(result!.id, 'display');
    });
  });

  group('Rule 4: user capture indicators outrank pre-authored riffs during active recording', () {
    test('user riff beats app riff when actively recording', () {
      final appRiff = makeCue(
        id: 'app-riff',
        kind: CueKind.riff,
        speakerRole: SpeakerRole.app,
      );
      final userRiff = makeCue(
        id: 'user-riff',
        kind: CueKind.userRiff,
        speakerRole: SpeakerRole.user,
      );

      final result = resolver.resolve(
        [appRiff, userRiff],
        SessionMode.recording,
        isActivelyRecording: true,
      );
      expect(result!.id, 'user-riff');
    });

    test('rule 4 does not apply when not actively recording', () {
      final appRiff = makeCue(
        id: 'app-riff',
        kind: CueKind.riff,
        speakerRole: SpeakerRole.app,
        startMs: 1000,
      );
      final userRiff = makeCue(
        id: 'user-riff',
        kind: CueKind.userRiff,
        speakerRole: SpeakerRole.user,
        startMs: 2000,
      );

      // Without isActivelyRecording, rule 4 is skipped.
      // Both have same priority, same mode. Falls to rule 5 (earlier start).
      final result = resolver.resolve(
        [userRiff, appRiff],
        SessionMode.recording,
        isActivelyRecording: false,
      );
      expect(result!.id, 'app-riff');
    });

    test('rule 4 applies in standard mode when actively recording', () {
      final appRiff = makeCue(
        id: 'app-riff',
        kind: CueKind.riff,
        speakerRole: SpeakerRole.app,
      );
      final userRiff = makeCue(
        id: 'user-riff',
        kind: CueKind.userRiff,
        speakerRole: SpeakerRole.user,
      );

      final result = resolver.resolve(
        [appRiff, userRiff],
        SessionMode.standard,
        isActivelyRecording: true,
      );
      expect(result!.id, 'user-riff');
    });
  });

  group('Rule 5: earlier startMs wins', () {
    test('earlier start wins when other rules are tied', () {
      final early = makeCue(id: 'early', startMs: 1000, endMs: 5000);
      final late_ = makeCue(id: 'late', startMs: 2000, endMs: 6000);

      final result = resolver.resolve(
        [late_, early],
        SessionMode.standard,
      );
      expect(result!.id, 'early');
    });
  });

  group('Rule 6: shorter duration wins', () {
    test('shorter cue wins when startMs is the same', () {
      final short =
          makeCue(id: 'short', startMs: 1000, endMs: 2000); // 1000ms
      final long =
          makeCue(id: 'long', startMs: 1000, endMs: 5000); // 4000ms

      final result = resolver.resolve(
        [long, short],
        SessionMode.standard,
      );
      expect(result!.id, 'short');
    });
  });

  group('Rule 7: stable sort by source file order (sourceIndex)', () {
    test('lower sourceIndex wins as final tiebreaker', () {
      final first = makeCue(
        id: 'first',
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 0,
      );
      final second = makeCue(
        id: 'second',
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 5,
      );

      final result = resolver.resolve(
        [second, first],
        SessionMode.standard,
      );
      expect(result!.id, 'first');
    });

    test('null sourceIndex defaults to 0', () {
      final withIndex = makeCue(
        id: 'indexed',
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 1,
      );
      final noIndex = makeCue(
        id: 'no-index',
        startMs: 1000,
        endMs: 3000,
        sourceIndex: null,
      );

      final result = resolver.resolve(
        [withIndex, noIndex],
        SessionMode.standard,
      );
      // null defaults to 0, which is < 1
      expect(result!.id, 'no-index');
    });
  });

  group('combination tests', () {
    test('priority + mode + startMs interaction: priority wins first', () {
      final highPriDisplay = makeCue(
        id: 'high-display',
        priority: 100,
        mode: CueMode.displayOnly,
        startMs: 5000,
        endMs: 8000,
      );
      final lowPriSpeak = makeCue(
        id: 'low-speak',
        priority: 30,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
      );

      final result = resolver.resolve(
        [lowPriSpeak, highPriDisplay],
        SessionMode.standard,
      );
      expect(result!.id, 'high-display');
    });

    test('three candidates resolved correctly by priority', () {
      final a = makeCue(id: 'a', priority: 50, startMs: 3000, endMs: 5000);
      final b = makeCue(id: 'b', priority: 50, startMs: 1000, endMs: 4000);
      final c = makeCue(id: 'c', priority: 80, startMs: 2000, endMs: 6000);

      final result = resolver.resolve(
        [a, b, c],
        SessionMode.standard,
      );
      expect(result!.id, 'c');
    });

    test('all rules cascading tiebreak scenario', () {
      // Same priority, same mode, same speakerRole, same startMs, same duration
      final a = makeCue(
        id: 'a',
        priority: 50,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 2,
      );
      final b = makeCue(
        id: 'b',
        priority: 50,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 1,
      );

      final result = resolver.resolve(
        [a, b],
        SessionMode.standard,
      );
      // Falls through to rule 7: sourceIndex 1 < 2
      expect(result!.id, 'b');
    });

    test('mode rank applies only when priority is equal', () {
      // Same priority, recording mode: displayOnly should outrank speak
      final spoken = makeCue(
        id: 'spoken',
        priority: 50,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
      );
      final display = makeCue(
        id: 'display',
        priority: 50,
        mode: CueMode.displayOnly,
        startMs: 1000,
        endMs: 3000,
      );

      final result = resolver.resolve(
        [spoken, display],
        SessionMode.recording,
      );
      expect(result!.id, 'display');
    });

    test('four candidates with mixed rules', () {
      final a = makeCue(
        id: 'a',
        priority: 50,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 4000,
        sourceIndex: 0,
      );
      final b = makeCue(
        id: 'b',
        priority: 50,
        mode: CueMode.speak,
        startMs: 1000,
        endMs: 3000,
        sourceIndex: 1,
      );
      final c = makeCue(
        id: 'c',
        priority: 50,
        mode: CueMode.speak,
        startMs: 2000,
        endMs: 4000,
        sourceIndex: 2,
      );
      final d = makeCue(
        id: 'd',
        priority: 60,
        mode: CueMode.displayOnly,
        startMs: 3000,
        endMs: 5000,
        sourceIndex: 3,
      );

      final result = resolver.resolve(
        [a, b, c, d],
        SessionMode.standard,
      );
      // d has highest priority (60), wins by rule 1
      expect(result!.id, 'd');
    });
  });
}
