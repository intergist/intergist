// Poker Sharp — Drill Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/poker.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/drill/drill_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DrillScreen', () {
    List<Override> _drillOverrides({List<Card>? board}) {
      final testBoard = board ?? createTestBoard();
      return [
        ...createProviderOverrides(
          config: const DrillConfig(timerEnabled: false),
          board: testBoard,
        ),
      ];
    }

    testWidgets('renders board cards', (tester) async {
      final board = createTestBoard();
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(board: board),
      );

      // Board display should be present
      // Check for rank characters from the board (A, K, 7, 4, 2)
      expect(find.text('A'), findsWidgets);
      expect(find.text('K'), findsWidgets);
    });

    testWidgets('shows holdings counter text', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      // Should show "0 / 10" (default config)
      expect(find.text('0 / 10'), findsOneWidget);
      expect(find.text('holdings'), findsOneWidget);
    });

    testWidgets('shows rank buttons in two-step picker', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      // Should show SELECT RANK label
      expect(find.text('SELECT RANK'), findsOneWidget);

      // Should show rank labels (A through 2 minus those on the board)
      // The board has A, K, 7, 4, 2 — but ranks are still tappable unless
      // all 4 suits are used. So all 13 ranks should appear.
      expect(find.text('J'), findsWidgets);
      expect(find.text('Q'), findsWidgets);
    });

    testWidgets('back button is present with Leave drill tooltip',
        (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      expect(find.byTooltip('Leave drill'), findsOneWidget);
    });

    testWidgets('hint button is present', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      expect(find.byTooltip('Toggle hint'), findsOneWidget);
    });

    testWidgets('undo button is present', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      expect(find.byTooltip('Undo'), findsOneWidget);
    });

    testWidgets('clear button is present', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      expect(find.byTooltip('Clear all'), findsOneWidget);
    });

    testWidgets('progress bar starts empty', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.0);
    });

    testWidgets('empty holdings shows placeholder text', (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      expect(
        find.text('Pick two cards to add a holding'),
        findsOneWidget,
      );
    });

    testWidgets('leave dialog does not appear when holdings empty and back tapped',
        (tester) async {
      await pumpFullScreen(
        tester,
        const DrillScreen(),
        overrides: _drillOverrides(),
      );

      // Tap back button
      await tester.tap(find.byTooltip('Leave drill'));
      await tester.pumpAndSettle();

      // With empty holdings, it should navigate directly (no dialog)
      // The dialog title "Leave drill?" should NOT appear
      expect(find.text('Leave drill?'), findsNothing);
    });
  });
}
