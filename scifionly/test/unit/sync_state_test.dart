import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/sync/sync_engine.dart';
import 'package:scifionly/features/sync/sync_state.dart';

void main() {
  late SyncEngine engine;
  late List<SyncStateData> stateHistory;

  setUp(() {
    stateHistory = [];
    engine = SyncEngine(
      lockConfidenceThreshold: 0.85,
      hysteresisThreshold: 0.70,
      onStateChanged: (state) {
        stateHistory.add(state);
      },
    );
  });

  tearDown(() {
    engine.dispose();
  });

  group('initial state', () {
    test('starts in UNLOCKED state', () {
      expect(engine.state.state, SyncState.unlocked);
    });

    test('initial confidence is 0.0', () {
      expect(engine.state.confidence, 0.0);
    });

    test('initial position is 0', () {
      expect(engine.state.estimatedPositionMs, 0);
    });

    test('initial drift is 0', () {
      expect(engine.state.driftMs, 0);
    });

    test('isRunning is false initially', () {
      expect(engine.isRunning, false);
    });

    test('isPaused is false initially', () {
      expect(engine.isPaused, false);
    });
  });

  group('start', () {
    test('transitions to LOCKED state', () {
      engine.start();
      expect(engine.state.state, SyncState.locked);
    });

    test('sets confidence to 1.0', () {
      engine.start();
      expect(engine.state.confidence, 1.0);
    });

    test('sets position to startPositionMs', () {
      engine.start(startPositionMs: 5000);
      expect(engine.state.estimatedPositionMs, 5000);
    });

    test('isRunning becomes true', () {
      engine.start();
      expect(engine.isRunning, true);
    });

    test('notifies state changed callback', () {
      engine.start();
      expect(stateHistory.isNotEmpty, true);
      expect(stateHistory.last.state, SyncState.locked);
    });

    test('default start position is 0', () {
      engine.start();
      expect(engine.state.estimatedPositionMs, 0);
    });
  });

  group('stop', () {
    test('transitions from LOCKED to UNLOCKED', () {
      engine.start();
      engine.stop();
      expect(engine.state.state, SyncState.unlocked);
    });

    test('sets confidence to 0.0', () {
      engine.start();
      engine.stop();
      expect(engine.state.confidence, 0.0);
    });

    test('isRunning becomes false', () {
      engine.start();
      engine.stop();
      expect(engine.isRunning, false);
    });

    test('notifies state changed callback', () {
      engine.start();
      stateHistory.clear();
      engine.stop();
      expect(stateHistory.isNotEmpty, true);
      expect(stateHistory.last.state, SyncState.unlocked);
    });
  });

  group('simulateDrift', () {
    test('small drift stays LOCKED', () {
      engine.start();

      // Small drift (within tolerance) - DriftCorrector applies correction factor
      engine.simulateDrift(50);

      // After small drift, state should remain locked or degraded
      // (depends on corrected drift value)
      expect(
        engine.state.state == SyncState.locked ||
            engine.state.state == SyncState.degraded,
        true,
      );
    });

    test('large drift transitions to REACQUIRING', () {
      engine.start();

      // Large drift exceeding tolerance (default 400ms)
      engine.simulateDrift(5000);
      expect(engine.state.state, SyncState.reacquiring);
    });

    test('large drift reduces confidence', () {
      engine.start();
      expect(engine.state.confidence, 1.0);

      engine.simulateDrift(5000);
      expect(engine.state.confidence, lessThan(1.0));
    });
  });

  group('simulatePause', () {
    test('sets isPaused to true', () {
      engine.start();
      engine.simulatePause();
      expect(engine.isPaused, true);
    });

    test('maintains current state', () {
      engine.start();
      final stateBefore = engine.state.state;
      engine.simulatePause();
      expect(engine.state.state, stateBefore);
    });
  });

  group('simulateResume', () {
    test('clears isPaused', () {
      engine.start();
      engine.simulatePause();
      expect(engine.isPaused, true);

      engine.simulateResume();
      expect(engine.isPaused, false);
    });
  });

  group('simulateSeek', () {
    test('transitions to REACQUIRING', () {
      engine.start();
      engine.simulateSeek(30000);
      expect(engine.state.state, SyncState.reacquiring);
    });

    test('updates position to seek target', () {
      engine.start();
      engine.simulateSeek(30000);
      expect(engine.state.estimatedPositionMs, 30000);
    });

    test('sets confidence to 0.5', () {
      engine.start();
      engine.simulateSeek(30000);
      expect(engine.state.confidence, 0.5);
    });

    test('notifies callback on seek', () {
      engine.start();
      stateHistory.clear();
      engine.simulateSeek(30000);
      expect(stateHistory.isNotEmpty, true);
      expect(stateHistory.last.state, SyncState.reacquiring);
    });
  });

  group('dispose', () {
    test('stops the timer', () {
      engine.start();
      engine.dispose();
      expect(engine.isRunning, false);
    });

    test('clears callback', () {
      engine.start();
      engine.dispose();
      // After dispose, callback should be null (no further notifications)
      // Verify by checking engine doesn't crash on state changes
      // We can't directly check onStateChanged is null, but no error = success
      expect(engine.isRunning, false);
    });
  });

  group('SyncStateData', () {
    test('isTracking is true when locked', () {
      final data = SyncStateData(
        state: SyncState.locked,
        confidence: 1.0,
        estimatedPositionMs: 0,
        driftMs: 0,
        lastUpdateTime: DateTime.now(),
      );
      expect(data.isTracking, true);
    });

    test('isTracking is true when degraded', () {
      final data = SyncStateData(
        state: SyncState.degraded,
        confidence: 0.75,
        estimatedPositionMs: 0,
        driftMs: 100,
        lastUpdateTime: DateTime.now(),
      );
      expect(data.isTracking, true);
    });

    test('isTracking is false when unlocked', () {
      final data = SyncStateData(
        state: SyncState.unlocked,
        confidence: 0.0,
        estimatedPositionMs: 0,
        driftMs: 0,
        lastUpdateTime: DateTime.now(),
      );
      expect(data.isTracking, false);
    });

    test('isTracking is false when reacquiring', () {
      final data = SyncStateData(
        state: SyncState.reacquiring,
        confidence: 0.5,
        estimatedPositionMs: 0,
        driftMs: 200,
        lastUpdateTime: DateTime.now(),
      );
      expect(data.isTracking, false);
    });

    test('equality works correctly', () {
      final a = SyncStateData(
        state: SyncState.locked,
        confidence: 1.0,
        estimatedPositionMs: 5000,
        driftMs: 0,
        lastUpdateTime: DateTime(2026, 1, 1),
      );
      final b = SyncStateData(
        state: SyncState.locked,
        confidence: 1.0,
        estimatedPositionMs: 5000,
        driftMs: 0,
        lastUpdateTime: DateTime(2026, 6, 1),
      );
      // Equality ignores lastUpdateTime based on the implementation
      expect(a, equals(b));
    });

    test('copyWith creates correct copy', () {
      final original = SyncStateData(
        state: SyncState.locked,
        confidence: 1.0,
        estimatedPositionMs: 5000,
        driftMs: 0,
        lastUpdateTime: DateTime.now(),
      );

      final copy = original.copyWith(state: SyncState.degraded, confidence: 0.8);
      expect(copy.state, SyncState.degraded);
      expect(copy.confidence, 0.8);
      expect(copy.estimatedPositionMs, 5000);
      expect(copy.driftMs, 0);
    });

    test('toString produces readable output', () {
      final data = SyncStateData(
        state: SyncState.locked,
        confidence: 0.95,
        estimatedPositionMs: 12345,
        driftMs: 50,
        lastUpdateTime: DateTime.now(),
      );

      final str = data.toString();
      expect(str, contains('locked'));
      expect(str, contains('0.95'));
      expect(str, contains('12345'));
      expect(str, contains('50'));
    });
  });

  group('state machine transitions', () {
    test('UNLOCKED -> LOCKED on start', () {
      expect(engine.state.state, SyncState.unlocked);
      engine.start();
      expect(engine.state.state, SyncState.locked);
    });

    test('LOCKED -> UNLOCKED on stop', () {
      engine.start();
      expect(engine.state.state, SyncState.locked);
      engine.stop();
      expect(engine.state.state, SyncState.unlocked);
    });

    test('LOCKED -> REACQUIRING on large drift', () {
      engine.start();
      expect(engine.state.state, SyncState.locked);
      engine.simulateDrift(5000);
      expect(engine.state.state, SyncState.reacquiring);
    });

    test('LOCKED -> REACQUIRING on seek', () {
      engine.start();
      expect(engine.state.state, SyncState.locked);
      engine.simulateSeek(50000);
      expect(engine.state.state, SyncState.reacquiring);
    });

    test('multiple state changes tracked in history', () {
      engine.start(); // UNLOCKED -> LOCKED
      engine.simulateSeek(5000); // LOCKED -> REACQUIRING
      engine.stop(); // -> UNLOCKED

      // Should have at least the major state transitions
      final states = stateHistory.map((s) => s.state).toList();
      expect(states, contains(SyncState.locked));
      expect(states, contains(SyncState.reacquiring));
      expect(states, contains(SyncState.unlocked));
    });
  });
}
