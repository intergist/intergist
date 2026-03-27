// Poker Sharp — Home Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/home/home_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders greeting text', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      // Should contain one of the greeting variants
      final greetingFinder = find.textContaining(RegExp(
        r'Good (morning|afternoon|evening)',
      ));
      expect(greetingFinder, findsOneWidget);
    });

    testWidgets('renders app title', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('Poker Sharp'), findsOneWidget);
    });

    testWidgets('renders subtitle tagline', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('Drills That Make You Dangerous'), findsOneWidget);
    });

    testWidgets('shows Start Drill button', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('Start Drill'), findsOneWidget);
    });

    testWidgets('shows mini stats cards (TODAY, STREAK, BEST)', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('BEST (7D)'), findsOneWidget);
    });

    testWidgets('shows empty state when no drills', (tester) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: createProviderOverrides(history: []),
      );

      expect(find.text('No drills yet. Start your first drill!'), findsOneWidget);
    });

    testWidgets('shows RECENT DRILLS header', (tester) async {
      await pumpScreen(tester, const HomeScreen());

      expect(find.text('RECENT DRILLS'), findsOneWidget);
    });

    testWidgets('shows recent drills when history exists', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1', percentageOverride: 80),
        createTestDrillRecord(id: 'd2', percentageOverride: 60),
      ];

      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: createProviderOverrides(history: history),
      );

      // Should display percentage texts for the drills
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('displays player name from settings', (tester) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: createProviderOverrides(
          settings: const AppSettings(playerName: 'TestPlayer'),
        ),
      );

      expect(find.textContaining('TestPlayer'), findsOneWidget);
    });

    testWidgets('shows stats values from provider', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1'),
        createTestDrillRecord(id: 'd2'),
      ];

      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: createProviderOverrides(history: history),
      );

      // Total drills today should be 2
      expect(find.text('2'), findsWidgets);
    });
  });
}
