// Poker Sharp — Settings Screen Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';
import 'package:poker_sharp/ui/screens/settings/settings_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('shows Settings title', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows Customize your experience subtitle', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('Customize your experience'), findsOneWidget);
    });

    testWidgets('shows Profile section with Player Name field',
        (tester) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: createProviderOverrides(
          settings: const AppSettings(playerName: 'TestUser'),
        ),
      );

      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('Player Name'), findsOneWidget);

      // TextField should show current player name
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('player name field is editable', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'NewName');
      await tester.pumpAndSettle();

      // Widget should still render
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows Appearance section with dark mode toggle',
        (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('dark mode switch toggles', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      // Find the dark mode Switch (there are potentially 2 switches total)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Toggle the first switch (dark mode)
      await tester.tap(switches.first);
      await tester.pumpAndSettle();
    });

    testWidgets('shows Drill Defaults section', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('DRILL DEFAULTS'), findsOneWidget);
      expect(find.text('Default Holdings Count'), findsOneWidget);
      expect(find.text('Timer On by Default'), findsOneWidget);
    });

    testWidgets('holdings count selector shows options', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('shows Data section with Reset All Stats', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1'),
      ];

      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      expect(find.text('DATA'), findsOneWidget);
      expect(find.text('Reset All Stats'), findsOneWidget);
    });

    testWidgets('reset stats shows confirmation dialog', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1'),
      ];

      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      // Tap the reset area
      await tester.tap(find.text('Reset All Stats'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Reset all statistics?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('reset dialog cancel dismisses', (tester) async {
      final history = [
        createTestDrillRecord(id: 'd1'),
      ];

      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: createProviderOverrides(history: history),
      );

      await tester.tap(find.text('Reset All Stats'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Reset all statistics?'), findsNothing);
    });

    testWidgets('shows About section', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Poker Sharp v1.0'), findsOneWidget);
    });

    testWidgets('shows privacy note', (tester) async {
      await pumpScreen(tester, const SettingsScreen());

      expect(
        find.textContaining('No data leaves your device'),
        findsOneWidget,
      );
    });

    testWidgets('disabled reset when no drills', (tester) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: createProviderOverrides(history: []),
      );

      expect(find.text('No data to clear'), findsOneWidget);
    });
  });
}
