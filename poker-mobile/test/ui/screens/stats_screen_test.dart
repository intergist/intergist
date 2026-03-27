// Poker Sharp — Stats Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/stats/stats_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('StatsScreen', () {
    testWidgets('shows Stats & History title', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('Stats & History'), findsOneWidget);
    });

    testWidgets('shows Track your progress subtitle', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('Track your progress'), findsOneWidget);
    });

    testWidgets('shows total drills count', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1'),
        createTestDrillRecord(id: 'd2'),
        createTestDrillRecord(id: 'd3'),
      ];

      await pumpScreen(
        tester,
        const StatsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      expect(find.text('Total Drills'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('shows Current Streak label', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('Current Streak'), findsOneWidget);
    });

    testWidgets('shows Best (7d) label', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('Best (7d)'), findsOneWidget);
    });

    testWidgets('shows Longest Streak label', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('Longest Streak'), findsOneWidget);
    });

    testWidgets('shows SUIT SENSITIVITY section', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('SUIT SENSITIVITY'), findsOneWidget);
    });

    testWidgets('shows suit sensitivity placeholder when no data',
        (tester) async {
      await pumpScreen(
        tester,
        const StatsScreen(),
        overrides: createProviderOverrides(history: []),
      );

      expect(
        find.textContaining('Complete drills on both'),
        findsOneWidget,
      );
    });

    testWidgets('shows DRILL HISTORY section', (tester) async {
      await pumpScreen(tester, const StatsScreen());

      expect(find.text('DRILL HISTORY'), findsOneWidget);
    });

    testWidgets('shows empty history message when no drills', (tester) async {
      await pumpScreen(
        tester,
        const StatsScreen(),
        overrides: createProviderOverrides(history: []),
      );

      expect(
        find.textContaining('No drills yet'),
        findsOneWidget,
      );
    });

    testWidgets('shows drill history cards when drills exist', (tester) async {
      final history = [
        createTestDrillRecord(
          id: 'd1',
          percentageOverride: 85,
        ),
      ];

      await pumpScreen(
        tester,
        const StatsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      // Should display the percentage
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('10 holdings'), findsOneWidget);
    });

    testWidgets('shows suit sensitivity comparison with mixed data',
        (tester) async {
      final history = [
        createTestDrillRecord(
          id: 's1',
          suitSensitive: true,
          percentageOverride: 80,
          board: createSuitSensitiveBoard(),
        ),
        createTestDrillRecord(
          id: 'ns1',
          suitSensitive: false,
          percentageOverride: 60,
        ),
      ];

      await pumpScreen(
        tester,
        const StatsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      expect(find.text('Suit-Sensitive'), findsOneWidget);
      expect(find.text('Non-Sensitive'), findsOneWidget);
    });
  });
}
