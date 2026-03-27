// Poker Sharp — Game State Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/scoring.dart';

import '../helpers/test_helpers.dart';

void main() {
  // =========================================================================
  // getStats
  // =========================================================================
  group('getStats', () {
    test('empty history returns zeros', () {
      final stats = getStats([]);

      expect(stats.drillsToday, 0);
      expect(stats.streak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.bestAccuracy, 0);
      expect(stats.totalDrills, 0);
    });

    test('drillsToday counts drills from today', () {
      final now = DateTime.now();
      final today1 = createTestDrillRecord(
        id: 'today1',
        date: now,
      );
      final today2 = createTestDrillRecord(
        id: 'today2',
        date: now.subtract(const Duration(hours: 2)),
      );
      final yesterday = createTestDrillRecord(
        id: 'yesterday',
        date: now.subtract(const Duration(days: 1)),
      );

      final stats = getStats([today1, today2, yesterday]);

      expect(stats.drillsToday, 2);
      expect(stats.totalDrills, 3);
    });

    test('streak calculation with consecutive days', () {
      final now = DateTime.now();
      final history = [
        createTestDrillRecord(
          id: 'd0',
          date: now,
        ),
        createTestDrillRecord(
          id: 'd1',
          date: now.subtract(const Duration(days: 1)),
        ),
        createTestDrillRecord(
          id: 'd2',
          date: now.subtract(const Duration(days: 2)),
        ),
      ];

      final stats = getStats(history);

      expect(stats.streak, 3);
    });

    test('streak breaks on gap day', () {
      final now = DateTime.now();
      final history = [
        createTestDrillRecord(
          id: 'd0',
          date: now,
        ),
        // Gap: no drill yesterday
        createTestDrillRecord(
          id: 'd2',
          date: now.subtract(const Duration(days: 2)),
        ),
      ];

      final stats = getStats(history);

      expect(stats.streak, 1); // Only today counts
    });

    test('longestStreak finds maximum consecutive run', () {
      final now = DateTime.now();
      // Current streak: 2 days (today + yesterday)
      // Old streak: 4 days (5-8 days ago)
      final history = [
        createTestDrillRecord(id: 'd0', date: now),
        createTestDrillRecord(
            id: 'd1', date: now.subtract(const Duration(days: 1))),
        // Gap at day 2-4
        createTestDrillRecord(
            id: 'd5', date: now.subtract(const Duration(days: 5))),
        createTestDrillRecord(
            id: 'd6', date: now.subtract(const Duration(days: 6))),
        createTestDrillRecord(
            id: 'd7', date: now.subtract(const Duration(days: 7))),
        createTestDrillRecord(
            id: 'd8', date: now.subtract(const Duration(days: 8))),
      ];

      final stats = getStats(history);

      expect(stats.longestStreak, 4);
    });

    test('bestAccuracy within 7-day window', () {
      final now = DateTime.now();
      final history = [
        createTestDrillRecord(
          id: 'd1',
          date: now,
          percentageOverride: 60,
        ),
        createTestDrillRecord(
          id: 'd2',
          date: now.subtract(const Duration(days: 3)),
          percentageOverride: 95,
        ),
        createTestDrillRecord(
          id: 'd3',
          date: now.subtract(const Duration(days: 10)),
          percentageOverride: 100, // Outside 7-day window
        ),
      ];

      final stats = getStats(history);

      expect(stats.bestAccuracy, 95);
    });
  });

  // =========================================================================
  // getSuitSensitivity
  // =========================================================================
  group('getSuitSensitivity', () {
    test('returns nulls with no data', () {
      final result = getSuitSensitivity([]);
      expect(result.sensitiveAvg, isNull);
      expect(result.nonSensitiveAvg, isNull);
      expect(result.sensitiveCount, 0);
      expect(result.nonSensitiveCount, 0);
    });

    test('separates sensitive and non-sensitive drills', () {
      final history = [
        createTestDrillRecord(
          id: 's1',
          suitSensitive: true,
          percentageOverride: 80,
        ),
        createTestDrillRecord(
          id: 's2',
          suitSensitive: true,
          percentageOverride: 90,
        ),
        createTestDrillRecord(
          id: 'ns1',
          suitSensitive: false,
          percentageOverride: 60,
        ),
        createTestDrillRecord(
          id: 'ns2',
          suitSensitive: false,
          percentageOverride: 70,
        ),
      ];

      final result = getSuitSensitivity(history);

      expect(result.sensitiveAvg, 85); // (80 + 90) / 2
      expect(result.nonSensitiveAvg, 65); // (60 + 70) / 2
      expect(result.sensitiveCount, 2);
      expect(result.nonSensitiveCount, 2);
    });

    test('handles only sensitive drills', () {
      final history = [
        createTestDrillRecord(
          id: 's1',
          suitSensitive: true,
          percentageOverride: 75,
        ),
      ];

      final result = getSuitSensitivity(history);

      expect(result.sensitiveAvg, 75);
      expect(result.nonSensitiveAvg, isNull);
      expect(result.sensitiveCount, 1);
      expect(result.nonSensitiveCount, 0);
    });
  });

  // =========================================================================
  // Model classes
  // =========================================================================
  group('Model classes', () {
    test('DrillConfig defaults', () {
      const config = DrillConfig();
      expect(config.holdingsCount, 10);
      expect(config.timerEnabled, true);
      expect(config.pickerMode, PickerMode.twoStep);
    });

    test('DrillConfig copyWith', () {
      const config = DrillConfig();
      final updated = config.copyWith(holdingsCount: 20, timerEnabled: false);
      expect(updated.holdingsCount, 20);
      expect(updated.timerEnabled, false);
      expect(updated.pickerMode, PickerMode.twoStep); // unchanged
    });

    test('AppSettings defaults', () {
      const settings = AppSettings();
      expect(settings.darkMode, true);
      expect(settings.playerName, 'Player');
      expect(settings.defaultHoldingsCount, 10);
    });

    test('AppSettings copyWith', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        playerName: 'Ace',
        darkMode: false,
      );
      expect(updated.playerName, 'Ace');
      expect(updated.darkMode, false);
      expect(updated.defaultHoldingsCount, 10); // unchanged
    });

    test('PickerMode enum values', () {
      expect(PickerMode.values.length, 2);
      expect(PickerMode.twoStep.name, 'twoStep');
      expect(PickerMode.fullGrid.name, 'fullGrid');
    });

    test('generateId produces unique IDs', () {
      final ids = List.generate(100, (_) => generateId()).toSet();
      expect(ids.length, 100);
    });
  });
}
