import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/components/participation_ring.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ParticipationRing', () {
    group('closed state', () {
      testWidgets('renders with correct label', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.closed,
              label: 'WAIT',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('WAIT'), findsOneWidget);
        expect(find.byType(ParticipationRing), findsOneWidget);
      });

      testWidgets('renders as 160x160 SizedBox', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.closed,
            ),
          ),
        );
        await tester.pump();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(ParticipationRing),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, 160.0);
        expect(sizedBox.height, 160.0);
      });
    });

    group('warning state', () {
      testWidgets('renders with label', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.warning,
              label: 'SOON',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('SOON'), findsOneWidget);
        expect(find.byType(ParticipationRing), findsOneWidget);
      });
    });

    group('open state', () {
      testWidgets('renders with label', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('TAP'), findsOneWidget);
        expect(find.byType(ParticipationRing), findsOneWidget);
      });
    });

    group('recording state', () {
      testWidgets('renders with depletion mode', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.recording,
              label: 'REC',
              progress: 0.5,
              useDepletionMode: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('REC'), findsOneWidget);
        expect(find.byType(ParticipationRing), findsOneWidget);
      });

      testWidgets('renders with full progress', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.recording,
              label: 'REC',
              progress: 1.0,
              useDepletionMode: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('REC'), findsOneWidget);
      });
    });

    group('disabled state', () {
      testWidgets('renders with reduced opacity', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.disabled,
              label: 'OFF',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('OFF'), findsOneWidget);

        // The AnimatedOpacity should be set to 0.4 for disabled state.
        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(ParticipationRing),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(animatedOpacity.opacity, 0.4);
      });

      testWidgets('does not respond to tap when disabled', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ParticipationRing(
              state: ParticipationVisualState.disabled,
              label: 'OFF',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(ParticipationRing));
        await tester.pump();

        expect(tapped, isFalse);
      });
    });

    group('countdown text', () {
      testWidgets('shows countdown when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
              countdownSeconds: 5,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('5s'), findsOneWidget);
        expect(find.text('TAP'), findsOneWidget);
      });

      testWidgets('does not show countdown when null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
            ),
          ),
        );
        await tester.pump();

        // Should only show "TAP", not any countdown text like "Ns".
        expect(find.text('5s'), findsNothing);
        expect(find.text('3s'), findsNothing);
      });
    });

    group('subtitle', () {
      testWidgets('shows subtitle when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
              subtitle: 'to record',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('to record'), findsOneWidget);
      });

      testWidgets('does not show subtitle when null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
            ),
          ),
        );
        await tester.pump();

        // Only the label "TAP" should be visible in the ring.
        expect(find.text('TAP'), findsOneWidget);
        expect(find.text('to record'), findsNothing);
      });
    });

    group('onTap callback', () {
      testWidgets('fires when tapped in open state', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ParticipationRing(
              state: ParticipationVisualState.open,
              label: 'TAP',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(ParticipationRing));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('fires when tapped in recording state', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ParticipationRing(
              state: ParticipationVisualState.recording,
              label: 'REC',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(ParticipationRing));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('fires when tapped in closed state', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithTheme(
            ParticipationRing(
              state: ParticipationVisualState.closed,
              label: 'WAIT',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(ParticipationRing));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('all visual states render without error', () {
      for (final state in ParticipationVisualState.values) {
        testWidgets('${state.name} state renders', (tester) async {
          await tester.pumpWidget(
            wrapWithTheme(
              ParticipationRing(
                state: state,
                label: state.name.toUpperCase(),
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(ParticipationRing), findsOneWidget);
        });
      }
    });
  });
}
