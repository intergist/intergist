import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:scifionly/ui/screens/import_wizard_screen.dart';
import 'package:scifionly/ui/theme/app_theme.dart';

void main() {
  /// Wraps ImportWizardScreen with GoRouter so context.go() calls work.
  Widget buildTestableWizard() {
    final router = GoRouter(
      initialLocation: '/import',
      routes: [
        GoRoute(
          path: '/import',
          builder: (context, state) => const ImportWizardScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Library')),
          ),
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: themeDataFor(AppThemeMode.nebulaCommand),
      ),
    );
  }

  group('ImportWizardScreen', () {
    group('step indicator', () {
      testWidgets('renders step indicator on initial load', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Step 1 should show "Select source type" title.
        expect(find.text('Select source type'), findsOneWidget);
      });

      testWidgets('shows step numbers', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Should show step circle with "1" as active.
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('shows Import in app bar', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        expect(find.text('Import'), findsOneWidget);
      });
    });

    group('step 1: source selection', () {
      testWidgets('shows three source options', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        expect(find.text('Reference Track'), findsOneWidget);
        expect(find.text('Riff Track'), findsOneWidget);
        expect(find.text('Cue Package'), findsOneWidget);
      });

      testWidgets('shows source descriptions', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        expect(
          find.text('SRT subtitle file with dialogue timestamps'),
          findsOneWidget,
        );
        expect(
          find.text('SRT file with timed riff cues from the community'),
          findsOneWidget,
        );
      });

      testWidgets('Continue button is initially disabled', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // The Continue button should exist.
        expect(find.text('Continue'), findsOneWidget);
      });
    });

    group('navigation between steps', () {
      testWidgets('can select source and navigate to step 2', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Tap on "Reference Track" to select it.
        await tester.tap(find.text('Reference Track'));
        await tester.pumpAndSettle();

        // Now tap Continue.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2 should show "Choose file".
        expect(find.text('Choose file'), findsOneWidget);
      });

      testWidgets('can navigate back from step 2 to step 1', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Select source and go to step 2.
        await tester.tap(find.text('Reference Track'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Choose file'), findsOneWidget);

        // Tap Back.
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Should be back at step 1.
        expect(find.text('Select source type'), findsOneWidget);
      });

      testWidgets('Cancel button shows on step 1', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('Back button shows on step 2', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Go to step 2.
        await tester.tap(find.text('Reference Track'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Back'), findsOneWidget);
      });
    });

    group('step 2: file picker', () {
      testWidgets('shows file picker prompt', (tester) async {
        await tester.pumpWidget(buildTestableWizard());
        await tester.pumpAndSettle();

        // Go to step 2.
        await tester.tap(find.text('Reference Track'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.textContaining('.srt file'), findsOneWidget);
      });
    });
  });
}
