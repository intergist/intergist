import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/components/sync_state_chip.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SyncStateChip', () {
    group('locked state', () {
      testWidgets('shows LOCKED text', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.locked),
          ),
        );
        await tester.pump();

        expect(find.text('LOCKED'), findsOneWidget);
      });

      testWidgets('shows lock icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.locked),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
      });
    });

    group('reacquiring state', () {
      testWidgets('shows REACQUIRING text', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.reacquiring),
          ),
        );
        await tester.pump();

        expect(find.text('REACQUIRING'), findsOneWidget);
      });

      testWidgets('shows sync icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.reacquiring),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.sync), findsOneWidget);
      });
    });

    group('degraded state', () {
      testWidgets('shows DEGRADED text', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.degraded),
          ),
        );
        await tester.pump();

        expect(find.text('DEGRADED'), findsOneWidget);
      });

      testWidgets('shows warning icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.degraded),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });
    });

    group('lost state', () {
      testWidgets('shows LOST text', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.lost),
          ),
        );
        await tester.pump();

        expect(find.text('LOST'), findsOneWidget);
      });

      testWidgets('shows sync_disabled icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.lost),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.sync_disabled), findsOneWidget);
      });
    });

    group('confidence display', () {
      testWidgets('shows confidence percentage when showConfidence is true',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(
              state: SyncVisualState.locked,
              confidence: 95.0,
              showConfidence: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('LOCKED 95%'), findsOneWidget);
      });

      testWidgets('does not show confidence when showConfidence is false',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(
              state: SyncVisualState.locked,
              confidence: 95.0,
              showConfidence: false,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('LOCKED'), findsOneWidget);
        expect(find.textContaining('95%'), findsNothing);
      });

      testWidgets('does not show confidence when confidence is null',
          (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(
              state: SyncVisualState.degraded,
              showConfidence: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('DEGRADED'), findsOneWidget);
      });

      testWidgets('rounds confidence to whole number', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(
              state: SyncVisualState.reacquiring,
              confidence: 72.8,
              showConfidence: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('REACQUIRING 73%'), findsOneWidget);
      });
    });

    group('fixed width constraint', () {
      testWidgets('has minimum width of 110', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SyncStateChip(state: SyncVisualState.locked),
          ),
        );
        await tester.pump();

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(animatedContainer.constraints?.minWidth, 110.0);
      });

      testWidgets('minimum width is consistent across states',
          (tester) async {
        for (final state in SyncVisualState.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              SyncStateChip(state: state),
            ),
          );
          await tester.pump();

          final animatedContainer = tester.widget<AnimatedContainer>(
            find.byType(AnimatedContainer),
          );
          expect(
            animatedContainer.constraints?.minWidth,
            110.0,
            reason: '${state.name} should have minWidth 110',
          );
        }
      });
    });

    group('all visual states render without error', () {
      for (final state in SyncVisualState.values) {
        testWidgets('${state.name} state renders', (tester) async {
          await tester.pumpWidget(
            wrapWithTheme(
              SyncStateChip(state: state),
            ),
          );
          await tester.pump();

          expect(find.byType(SyncStateChip), findsOneWidget);
        });
      }
    });
  });
}
