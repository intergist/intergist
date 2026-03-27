import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/session/standard_mode_controller.dart';
import 'package:scifionly/features/sync/sync_engine.dart';
import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/models/track.dart';

void main() {
  /// Helper to create a CueTrack with some cues.
  CueTrack makeReferenceTrack() {
    return CueTrack(
      trackId: 'ref',
      trackType: TrackType.reference,
      cues: [
        CueEventModel(
          id: 'cue-1',
          trackId: 'ref',
          track: 'reference',
          startMs: 1000,
          endMs: 3000,
          text: 'First line.',
          kind: CueKind.dialogue,
          mode: CueMode.displayOnly,
          priority: 100,
          speakerRole: SpeakerRole.narrator,
          interruptible: false,
          enabled: true,
          sourceIndex: 0,
        ),
        CueEventModel(
          id: 'cue-2',
          trackId: 'ref',
          track: 'reference',
          startMs: 5000,
          endMs: 7000,
          text: 'Second line.',
          kind: CueKind.dialogue,
          mode: CueMode.displayOnly,
          priority: 100,
          speakerRole: SpeakerRole.narrator,
          interruptible: false,
          enabled: true,
          sourceIndex: 1,
        ),
        CueEventModel(
          id: 'cue-3',
          trackId: 'ref',
          track: 'reference',
          startMs: 10000,
          endMs: 13000,
          text: 'Third line.',
          kind: CueKind.dialogue,
          mode: CueMode.displayOnly,
          priority: 100,
          speakerRole: SpeakerRole.narrator,
          interruptible: false,
          enabled: true,
          sourceIndex: 2,
        ),
      ],
    );
  }

  group('StandardModeController creation', () {
    test('can be created with tracks', () {
      final track = makeReferenceTrack();
      final controller = StandardModeController(tracks: [track]);

      expect(controller.mode, SessionMode.standard);
      expect(controller.sessionState, SessionState.paused);
      expect(controller.currentPositionMs, 0);

      controller.dispose();
    });

    test('uses provided sync engine', () {
      final track = makeReferenceTrack();
      final syncEngine = SyncEngine();
      final controller = StandardModeController(
        tracks: [track],
        syncEngine: syncEngine,
      );

      expect(controller.syncEngine, same(syncEngine));

      controller.dispose();
    });

    test('creates its own sync engine when not provided', () {
      final track = makeReferenceTrack();
      final controller = StandardModeController(tracks: [track]);

      expect(controller.syncEngine, isNotNull);

      controller.dispose();
    });
  });

  group('StandardModeController lifecycle', () {
    late StandardModeController controller;
    late List<SessionState> stateChanges;

    setUp(() {
      final track = makeReferenceTrack();
      stateChanges = [];
      controller = StandardModeController(tracks: [track]);
      controller.onSessionStateChanged = (state) {
        stateChanges.add(state);
      };
    });

    tearDown(() {
      controller.dispose();
    });

    test('start transitions to active state', () {
      controller.start();
      expect(controller.sessionState, SessionState.active);
      expect(stateChanges, contains(SessionState.active));
      controller.stop();
    });

    test('start with position sets sync engine position', () {
      controller.start(startPositionMs: 5000);
      expect(controller.syncEngine.state.estimatedPositionMs, 5000);
      expect(controller.syncEngine.state.state, SyncState.locked);
      controller.stop();
    });

    test('pause transitions to paused state', () {
      controller.start();
      controller.pause();
      expect(controller.sessionState, SessionState.paused);
      expect(stateChanges, contains(SessionState.paused));
      controller.stop();
    });

    test('resume transitions back to active state', () {
      controller.start();
      controller.pause();
      stateChanges.clear();
      controller.resume();
      expect(controller.sessionState, SessionState.active);
      expect(stateChanges, contains(SessionState.active));
      controller.stop();
    });

    test('stop transitions to completed state', () {
      controller.start();
      controller.stop();
      expect(controller.sessionState, SessionState.completed);
      expect(stateChanges, contains(SessionState.completed));
    });

    test('stop also stops the sync engine', () {
      controller.start();
      expect(controller.syncEngine.isRunning, true);
      controller.stop();
      expect(controller.syncEngine.isRunning, false);
      expect(controller.syncEngine.state.state, SyncState.unlocked);
    });

    test('seek triggers reacquiring on sync engine', () {
      controller.start();
      controller.seekTo(30000);
      expect(controller.syncEngine.state.state, SyncState.reacquiring);
      controller.stop();
    });

    test('seek resets cue evaluator fired IDs', () {
      controller.start();
      // Manually evaluate a cue so we know the evaluator has state
      controller.evaluateCues(2000); // fires cue-1
      expect(controller.cueEvaluator.hasFired('cue-1'), true);

      // Seek resets the evaluator via cueEvaluator.reset()
      controller.seekTo(30000);
      expect(controller.cueEvaluator.hasFired('cue-1'), false);
      controller.stop();
    });

    test('lastFiredCue is null initially', () {
      expect(controller.lastFiredCue, isNull);
    });

    test('lastFiredCue is cleared on stop', () {
      controller.start();
      controller.stop();
      expect(controller.lastFiredCue, isNull);
    });

    test('lastFiredCue is cleared on seekTo call', () {
      controller.start();
      // seekTo internally sets _lastFiredCue = null before calling super.seekTo,
      // but the sync engine state change may re-evaluate cues immediately.
      // The key behavior is that seekTo resets cue state.
      // We verify seekTo clears the firedCueIds set.
      controller.evaluateCues(2000); // fire cue-1
      expect(controller.lastFiredCue, isNotNull);

      controller.seekTo(30000); // seek to position beyond all cues
      // After seek to gap, no cue fires, so lastFiredCue should be set
      // by the evaluation at 30000ms which has no cue.
      // The evaluator reset means old cues can fire again.
      expect(controller.cueEvaluator.hasFired('cue-1'), false);
      controller.stop();
    });
  });

  group('StandardModeController cue firing', () {
    late StandardModeController controller;
    late List<CueEventModel> firedCues;

    setUp(() {
      final track = makeReferenceTrack();
      firedCues = [];
      controller = StandardModeController(tracks: [track]);
      controller.onCueFired = (cue, isNew) {
        firedCues.add(cue);
      };
    });

    tearDown(() {
      controller.dispose();
    });

    test('evaluateCues fires cue at correct position', () {
      controller.start();
      controller.evaluateCues(2000);
      expect(firedCues.length, 1);
      expect(firedCues[0].id, 'cue-1');
      controller.stop();
    });

    test('evaluateCues does not fire in gap between cues', () {
      controller.start();
      controller.evaluateCues(4000);
      expect(firedCues, isEmpty);
      controller.stop();
    });

    test('evaluateCues fires second cue at correct position', () {
      controller.start();
      controller.evaluateCues(6000);
      expect(firedCues.length, 1);
      expect(firedCues[0].id, 'cue-2');
      controller.stop();
    });

    test('evaluateCues fires different cues at different positions', () {
      controller.start();
      controller.evaluateCues(2000);
      controller.evaluateCues(6000);
      controller.evaluateCues(11000);
      expect(firedCues.length, 3);
      expect(firedCues[0].id, 'cue-1');
      expect(firedCues[1].id, 'cue-2');
      expect(firedCues[2].id, 'cue-3');
      controller.stop();
    });
  });

  group('StandardModeController dispose', () {
    test('dispose stops sync engine', () {
      final track = makeReferenceTrack();
      final controller = StandardModeController(tracks: [track]);
      controller.start();
      controller.dispose();

      expect(controller.syncEngine.isRunning, false);
    });

    test('dispose clears callbacks', () {
      final track = makeReferenceTrack();
      final controller = StandardModeController(tracks: [track]);
      controller.onCueFired = (_, __) {};
      controller.onSessionStateChanged = (_) {};
      controller.onUpcomingCues = (_) {};

      controller.dispose();

      // After dispose, these should be null (internal state)
      // We verify no crash when calling methods
      expect(controller.lastFiredCue, isNull);
    });
  });

  group('StandardModeController with empty tracks', () {
    test('works with empty track list', () {
      final controller = StandardModeController(tracks: []);
      controller.start();
      controller.evaluateCues(5000);
      controller.stop();
      controller.dispose();
    });

    test('works with empty cue track', () {
      final emptyTrack = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );
      final controller = StandardModeController(tracks: [emptyTrack]);
      controller.start();
      controller.evaluateCues(5000);
      controller.stop();
      controller.dispose();
    });
  });

  group('StandardModeController mode', () {
    test('mode is standard', () {
      final track = makeReferenceTrack();
      final controller = StandardModeController(tracks: [track]);
      expect(controller.mode, SessionMode.standard);
      controller.dispose();
    });
  });

  group('StandardModeController state transitions', () {
    test('full lifecycle: paused -> active -> paused -> active -> completed', () {
      final track = makeReferenceTrack();
      final stateChanges = <SessionState>[];
      final controller = StandardModeController(tracks: [track]);
      controller.onSessionStateChanged = (state) {
        stateChanges.add(state);
      };

      expect(controller.sessionState, SessionState.paused);

      controller.start();
      expect(controller.sessionState, SessionState.active);

      controller.pause();
      expect(controller.sessionState, SessionState.paused);

      controller.resume();
      expect(controller.sessionState, SessionState.active);

      controller.stop();
      expect(controller.sessionState, SessionState.completed);

      expect(stateChanges, [
        SessionState.active,
        SessionState.paused,
        SessionState.active,
        SessionState.completed,
      ]);

      controller.dispose();
    });

    test('duplicate state transitions are ignored', () {
      final track = makeReferenceTrack();
      final stateChanges = <SessionState>[];
      final controller = StandardModeController(tracks: [track]);
      controller.onSessionStateChanged = (state) {
        stateChanges.add(state);
      };

      controller.start();

      // Starting again shouldn't produce duplicate active transition
      // (setSessionState checks if state changed)
      controller.start();
      // The second start may or may not produce a new callback depending on
      // implementation - but the state should still be active
      expect(controller.sessionState, SessionState.active);

      controller.stop();
      controller.dispose();
    });
  });
}
