// Poker Sharp — Results Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/poker.dart';
import 'package:poker_sharp/core/scoring.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/results/results_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  /// Create a LastResultState for testing.
  LastResultState _createResult({int percentage = 80}) {
    final board = createTestBoard();
    final classes = groupIntoEquivalenceClasses(board, 5);
    final userHoldings =
        classes.map((c) => (cards: c.members[0])).toList();
    final scoring = scoreSubmissionGrouped(board, userHoldings, 5);

    return LastResultState(
      board: board,
      scoringResult: scoring,
      timeTakenMs: 15000,
      targetCount: 5,
      hintUsed: false,
    );
  }

  group('ResultsScreen', () {
    testWidgets('shows "No results" when lastResult is null', (tester) async {
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(),
      );

      expect(find.text('No results to display'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
    });

    testWidgets('shows Results header', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Results'), findsOneWidget);
    });

    testWidgets('shows score percentage', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      // The score ring shows the percentage
      expect(
        find.textContaining('%'),
        findsWidgets,
      );
    });

    testWidgets('shows Exact stat', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Exact'), findsOneWidget);
    });

    testWidgets('shows Points stat', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Points'), findsOneWidget);
    });

    testWidgets('shows Time stat when timer was enabled', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Time'), findsOneWidget);
      expect(find.text('00:15'), findsOneWidget); // 15000ms = 00:15
    });

    testWidgets('shows CLASS COMPARISON header', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('CLASS COMPARISON'), findsOneWidget);
    });

    testWidgets('shows Board Texture section', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Board Texture'), findsOneWidget);
    });

    testWidgets('shows Play Again button', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Play Again'), findsOneWidget);
    });

    testWidgets('shows New Settings button', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('New Settings'), findsOneWidget);
    });

    testWidgets('shows Home button', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('shows speed stars when timer used', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      // Should find star icons
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('shows comparison rows matching target count', (tester) async {
      final result = _createResult();
      await pumpFullScreen(
        tester,
        const ResultsScreen(),
        overrides: createProviderOverrides(lastResult: result),
      );

      // Should find multiple #N position labels
      expect(find.text('#1'), findsWidgets);
    });
  });
}
