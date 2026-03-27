// Poker Sharp — Riverpod Provider Tests

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_sharp/core/poker.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';

import '../helpers/test_helpers.dart';

void main() {
  // =========================================================================
  // DrillConfigNotifier
  // =========================================================================
  group('DrillConfigNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('default values match defaultConfig', () {
      final config = container.read(drillConfigProvider);
      expect(config.holdingsCount, 10);
      expect(config.timerEnabled, true);
      expect(config.pickerMode, PickerMode.twoStep);
    });

    test('setHoldingsCount updates state', () {
      container.read(drillConfigProvider.notifier).setHoldingsCount(20);
      final config = container.read(drillConfigProvider);
      expect(config.holdingsCount, 20);
    });

    test('setTimerEnabled updates state', () {
      container.read(drillConfigProvider.notifier).setTimerEnabled(false);
      final config = container.read(drillConfigProvider);
      expect(config.timerEnabled, false);
    });

    test('setPickerMode updates state', () {
      container
          .read(drillConfigProvider.notifier)
          .setPickerMode(PickerMode.fullGrid);
      final config = container.read(drillConfigProvider);
      expect(config.pickerMode, PickerMode.fullGrid);
    });

    test('reset restores defaults', () {
      final notifier = container.read(drillConfigProvider.notifier);
      notifier.setHoldingsCount(20);
      notifier.setTimerEnabled(false);
      notifier.setPickerMode(PickerMode.fullGrid);

      notifier.reset();
      final config = container.read(drillConfigProvider);
      expect(config.holdingsCount, 10);
      expect(config.timerEnabled, true);
      expect(config.pickerMode, PickerMode.twoStep);
    });
  });

  // =========================================================================
  // CurrentHoldingsNotifier
  // =========================================================================
  group('CurrentHoldingsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts empty', () {
      final holdings = container.read(currentHoldingsProvider);
      expect(holdings, isEmpty);
    });

    test('add appends a holding', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);

      final holdings = container.read(currentHoldingsProvider);
      expect(holdings.length, 1);
      expect(holdings[0][0].rank, 12);
    });

    test('add multiple holdings in sequence', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);
      notifier.add(const [Card(rank: 8, suit: 2), Card(rank: 7, suit: 2)]);

      final holdings = container.read(currentHoldingsProvider);
      expect(holdings.length, 3);
    });

    test('removeAt removes specific holding', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);
      notifier.add(const [Card(rank: 8, suit: 2), Card(rank: 7, suit: 2)]);

      notifier.removeAt(1); // Remove middle

      final holdings = container.read(currentHoldingsProvider);
      expect(holdings.length, 2);
      expect(holdings[0][0].rank, 12);
      expect(holdings[1][0].rank, 8);
    });

    test('removeAt with invalid index is a no-op', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.removeAt(5);
      notifier.removeAt(-1);

      expect(container.read(currentHoldingsProvider).length, 1);
    });

    test('reorder moves holding to new position', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]); // A
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]); // B
      notifier.add(const [Card(rank: 8, suit: 2), Card(rank: 7, suit: 2)]); // C

      notifier.reorder(2, 0); // Move C before A

      final holdings = container.read(currentHoldingsProvider);
      expect(holdings[0][0].rank, 8); // C is now first
      expect(holdings[1][0].rank, 12); // A
      expect(holdings[2][0].rank, 10); // B
    });

    test('reorder same index is a no-op', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      notifier.reorder(0, 0);

      expect(container.read(currentHoldingsProvider).length, 2);
      expect(notifier.canUndo, false); // no-op doesn't push undo
    });

    test('clear removes all holdings', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      notifier.clear();

      expect(container.read(currentHoldingsProvider), isEmpty);
    });

    test('clear on empty list is a no-op', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.clear();
      expect(notifier.canUndo, false);
    });

    test('undo after add restores previous state', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      expect(notifier.canUndo, true);
      notifier.undo();

      final holdings = container.read(currentHoldingsProvider);
      expect(holdings.length, 1);
      expect(holdings[0][0].rank, 12);
    });

    test('undo after removeAt restores removed holding', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      notifier.removeAt(0);
      expect(container.read(currentHoldingsProvider).length, 1);

      notifier.undo();
      expect(container.read(currentHoldingsProvider).length, 2);
    });

    test('undo after reorder restores original order', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      notifier.reorder(1, 0);
      expect(container.read(currentHoldingsProvider)[0][0].rank, 10);

      notifier.undo();
      expect(container.read(currentHoldingsProvider)[0][0].rank, 12);
    });

    test('undo after clear restores all holdings', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.add(const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)]);
      notifier.add(const [Card(rank: 10, suit: 1), Card(rank: 9, suit: 1)]);

      notifier.clear();
      expect(container.read(currentHoldingsProvider), isEmpty);

      notifier.undo();
      expect(container.read(currentHoldingsProvider).length, 2);
    });

    test('canUndo is false when no actions taken', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      expect(notifier.canUndo, false);
    });

    test('undo on empty stack is a no-op', () {
      final notifier = container.read(currentHoldingsProvider.notifier);
      notifier.undo(); // Should not throw
      expect(container.read(currentHoldingsProvider), isEmpty);
    });
  });

  // =========================================================================
  // TimerNotifier
  // =========================================================================
  group('TimerNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.read(timerProvider.notifier).stop();
      container.dispose();
    });

    test('starts at 0', () {
      expect(container.read(timerProvider), 0);
    });

    test('start begins incrementing', () async {
      container.read(timerProvider.notifier).start();

      // Wait for a few ticks
      await Future.delayed(const Duration(milliseconds: 350));

      final elapsed = container.read(timerProvider);
      expect(elapsed, greaterThan(0));
    });

    test('stop freezes the value', () async {
      final notifier = container.read(timerProvider.notifier);
      notifier.start();
      await Future.delayed(const Duration(milliseconds: 250));

      notifier.stop();
      final frozen = container.read(timerProvider);

      await Future.delayed(const Duration(milliseconds: 200));
      final after = container.read(timerProvider);

      expect(after, frozen);
    });

    test('reset zeroes out and stops', () async {
      final notifier = container.read(timerProvider.notifier);
      notifier.start();
      await Future.delayed(const Duration(milliseconds: 200));

      notifier.reset();
      expect(container.read(timerProvider), 0);
    });
  });

  // =========================================================================
  // equivalenceClassesProvider
  // =========================================================================
  group('equivalenceClassesProvider', () {
    test('returns empty when no board set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final classes = container.read(equivalenceClassesProvider);
      expect(classes, isEmpty);
    });

    test('computes classes when board is set', () {
      final container = ProviderContainer(overrides: [
        currentBoardProvider.overrideWith((ref) => createTestBoard()),
      ]);
      addTearDown(container.dispose);

      final classes = container.read(equivalenceClassesProvider);
      expect(classes.length, 10); // default holdingsCount is 10
    });

    test('updates when board changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially empty
      expect(container.read(equivalenceClassesProvider), isEmpty);

      // Set board
      container.read(currentBoardProvider.notifier).state = createTestBoard();
      final classes = container.read(equivalenceClassesProvider);
      expect(classes, isNotEmpty);
    });
  });

  // =========================================================================
  // LastResultState / lastResultProvider
  // =========================================================================
  group('lastResultProvider', () {
    test('starts null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(lastResultProvider), isNull);
    });

    test('can set and read a result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 5);
      final userHoldings =
          classes.map((c) => (cards: c.members[0])).toList();
      final scoring = scoreSubmissionGrouped(board, userHoldings, 5);

      container.read(lastResultProvider.notifier).state = LastResultState(
        board: board,
        scoringResult: scoring,
        timeTakenMs: 15000,
        targetCount: 5,
        hintUsed: false,
      );

      final result = container.read(lastResultProvider);
      expect(result, isNotNull);
      expect(result!.board.length, 5);
      expect(result.scoringResult.percentage, 100);
      expect(result.timeTakenMs, 15000);
      expect(result.hintUsed, false);
    });
  });

  // =========================================================================
  // statsProvider / suitSensitivityProvider
  // =========================================================================
  group('Computed providers', () {
    test('statsProvider computes from drillHistory', () {
      final history = [
        createTestDrillRecord(id: 'd1', percentageOverride: 80),
        createTestDrillRecord(id: 'd2', percentageOverride: 90),
      ];

      final container = ProviderContainer(overrides: [
        drillHistoryProvider.overrideWith(
          (ref) => _TestHistoryNotifier(history),
        ),
      ]);
      addTearDown(container.dispose);

      final stats = container.read(statsProvider);
      expect(stats.totalDrills, 2);
      expect(stats.bestAccuracy, 90);
    });

    test('suitSensitivityProvider computes from drillHistory', () {
      final history = [
        createTestDrillRecord(
            id: 's1', suitSensitive: true, percentageOverride: 80),
        createTestDrillRecord(
            id: 'ns1', suitSensitive: false, percentageOverride: 60),
      ];

      final container = ProviderContainer(overrides: [
        drillHistoryProvider.overrideWith(
          (ref) => _TestHistoryNotifier(history),
        ),
      ]);
      addTearDown(container.dispose);

      final sens = container.read(suitSensitivityProvider);
      expect(sens.sensitiveAvg, 80);
      expect(sens.nonSensitiveAvg, 60);
    });
  });
}

class _TestHistoryNotifier extends DrillHistoryNotifier {
  _TestHistoryNotifier(List<DrillRecord> initial) {
    state = initial;
  }

  @override
  Future<void> addDrill(DrillRecord drill) async {
    state = [drill, ...state];
  }

  @override
  Future<void> clearAll() async {
    state = [];
  }
}
