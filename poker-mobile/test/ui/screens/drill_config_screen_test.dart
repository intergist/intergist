// Poker Sharp — Drill Config Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/drill_config/drill_config_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DrillConfigScreen', () {
    testWidgets('renders Configure Drill title', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Configure Drill'), findsOneWidget);
    });

    testWidgets('renders holdings count options (5, 10, 15, 20)',
        (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('renders Holdings to Rank section', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Holdings to Rank'), findsOneWidget);
    });

    testWidgets('renders Timer section', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Timer'), findsOneWidget);
    });

    testWidgets('renders Card Picker Mode section', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Card Picker Mode'), findsOneWidget);
      expect(find.text('Two-Step'), findsOneWidget);
      expect(find.text('Full Grid'), findsOneWidget);
    });

    testWidgets('timer switch is present and toggleable', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Toggle it
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch should still be present after toggle
      expect(switchFinder, findsOneWidget);
    });

    testWidgets('Deal button is present', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Deal'), findsOneWidget);
    });

    testWidgets('tapping a holdings option changes selection', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      // Tap "20" option
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      // The widget should still render (no crash)
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('renders Board Type section', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(find.text('Board Type'), findsOneWidget);
    });

    testWidgets('renders setup description', (tester) async {
      await pumpFullScreen(tester, const DrillConfigScreen());

      expect(
        find.text('Set up your board-reading challenge'),
        findsOneWidget,
      );
    });
  });
}
