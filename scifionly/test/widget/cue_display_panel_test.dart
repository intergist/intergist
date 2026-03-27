import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/components/cue_display_panel.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CueDisplayPanel', () {
    group('displayOnly mode', () {
      testWidgets('shows text', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'I have a bad feeling about this.',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        expect(
          find.text('I have a bad feeling about this.'),
          findsOneWidget,
        );
      });

      testWidgets('shows DISPLAY badge', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Test cue',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('DISPLAY'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      });
    });

    group('spoken mode', () {
      testWidgets('shows text with SPOKEN badge', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'May the Force be with you.',
              mode: CueVisualMode.spoken,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('May the Force be with you.'), findsOneWidget);
        expect(find.text('SPOKEN'), findsOneWidget);
        expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
      });
    });

    group('displayAndSpoken mode', () {
      testWidgets('shows text with DISPLAY + SPOKEN badge', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'That\'s no moon.',
              mode: CueVisualMode.displayAndSpoken,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('That\'s no moon.'), findsOneWidget);
        expect(find.text('DISPLAY + SPOKEN'), findsOneWidget);
        expect(
          find.byIcon(Icons.record_voice_over_outlined),
          findsOneWidget,
        );
      });
    });

    group('highlighted state', () {
      testWidgets('renders without error when highlighted', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Highlighted cue text',
              mode: CueVisualMode.spoken,
              highlighted: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Highlighted cue text'), findsOneWidget);
        expect(find.byType(CueDisplayPanel), findsOneWidget);
      });
    });

    group('suppressed state', () {
      testWidgets('applies suppressed styling with reduced opacity',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Suppressed cue',
              mode: CueVisualMode.displayOnly,
              suppressed: true,
            ),
          ),
        );
        await tester.pump();

        // Suppressed state should have opacity 0.35.
        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 0.35);
      });

      testWidgets('applies line-through decoration when suppressed',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Struck through',
              mode: CueVisualMode.displayOnly,
              suppressed: true,
            ),
          ),
        );
        await tester.pump();

        // Find the main cue text widget that has line-through.
        final textWidget = tester.widget<Text>(
          find.text('Struck through'),
        );
        expect(
          textWidget.style?.decoration,
          TextDecoration.lineThrough,
        );
      });
    });

    group('idle state', () {
      testWidgets('shows idle message with reduced opacity', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Waiting for next cue...',
              mode: CueVisualMode.displayOnly,
              idle: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Waiting for next cue...'), findsOneWidget);

        // Idle state should have opacity 0.5.
        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 0.5);
      });
    });

    group('next cue text', () {
      testWidgets('shows next cue text when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Current cue',
              nextText: 'Upcoming cue preview',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Current cue'), findsOneWidget);
        expect(find.text('Upcoming cue preview'), findsOneWidget);
        expect(find.byIcon(Icons.skip_next_outlined), findsOneWidget);
      });

      testWidgets('does not show next cue row when null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Current cue',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.skip_next_outlined), findsNothing);
      });

      testWidgets('does not show next cue row when empty string',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Current cue',
              nextText: '',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.skip_next_outlined), findsNothing);
      });
    });

    group('normal opacity', () {
      testWidgets('has full opacity when not suppressed or idle',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const CueDisplayPanel(
              text: 'Normal cue',
              mode: CueVisualMode.displayOnly,
            ),
          ),
        );
        await tester.pump();

        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 1.0);
      });
    });

    group('all visual modes render', () {
      for (final mode in CueVisualMode.values) {
        testWidgets('${mode.name} mode renders without error',
            (tester) async {
          await tester.pumpWidget(
            wrapWithTheme(
              CueDisplayPanel(
                text: 'Test cue for ${mode.name}',
                mode: mode,
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(CueDisplayPanel), findsOneWidget);
        });
      }
    });
  });
}
