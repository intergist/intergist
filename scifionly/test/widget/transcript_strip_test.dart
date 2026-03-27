import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/components/transcript_strip.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('TranscriptStrip', () {
    group('text content', () {
      testWidgets('shows text content', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(text: 'I have a bad feeling about this.'),
          ),
        );
        await tester.pump();

        expect(
          find.text('I have a bad feeling about this.'),
          findsOneWidget,
        );
      });
    });

    group('timestamp', () {
      testWidgets('shows timestamp when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Test dialogue',
              timestamp: '01:23:45',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('01:23:45'), findsOneWidget);
        expect(find.text('Test dialogue'), findsOneWidget);
      });

      testWidgets('does not show timestamp when null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(text: 'Test dialogue'),
          ),
        );
        await tester.pump();

        // Only the main text should be present.
        expect(find.text('Test dialogue'), findsOneWidget);
      });
    });

    group('partial text styling', () {
      testWidgets('partial text uses italic font style', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Partial transcript...',
              isPartial: true,
            ),
          ),
        );
        await tester.pump();

        final textWidget = tester.widget<Text>(
          find.text('Partial transcript...'),
        );
        expect(textWidget.style?.fontStyle, FontStyle.italic);
      });

      testWidgets('partial text uses lighter opacity (0.6)', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Partial transcript...',
              isPartial: true,
            ),
          ),
        );
        await tester.pump();

        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 0.6);
      });
    });

    group('final text styling', () {
      testWidgets('final text uses normal font style', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Final transcript.',
              isFinal: true,
            ),
          ),
        );
        await tester.pump();

        final textWidget = tester.widget<Text>(
          find.text('Final transcript.'),
        );
        expect(textWidget.style?.fontStyle, FontStyle.normal);
      });

      testWidgets('final text uses full opacity (1.0)', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Final transcript.',
              isFinal: true,
            ),
          ),
        );
        await tester.pump();

        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 1.0);
      });

      testWidgets('final text shows check icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Final transcript.',
              isFinal: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('non-final text does not show check icon', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Regular transcript.',
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      });
    });

    group('leading icon', () {
      testWidgets('shows leading icon when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'With microphone icon',
              leadingIcon: Icons.mic,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('does not show leading icon when null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(text: 'No icon'),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.mic), findsNothing);
      });

      testWidgets('shows both leading icon and timestamp', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(
              text: 'Full featured',
              timestamp: '00:05:30',
              leadingIcon: Icons.speaker,
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.speaker), findsOneWidget);
        expect(find.text('00:05:30'), findsOneWidget);
        expect(find.text('Full featured'), findsOneWidget);
      });
    });

    group('default state', () {
      testWidgets('default state has full opacity', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(text: 'Normal text'),
          ),
        );
        await tester.pump();

        final animatedOpacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacity.opacity, 1.0);
      });

      testWidgets('default state uses normal font style', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const TranscriptStrip(text: 'Normal text'),
          ),
        );
        await tester.pump();

        final textWidget = tester.widget<Text>(
          find.text('Normal text'),
        );
        expect(textWidget.style?.fontStyle, FontStyle.normal);
      });
    });
  });
}
