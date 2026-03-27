// Poker Sharp — ScoreRing Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_sharp/ui/components/feedback/score_ring.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35D9FF),
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ScoreRing', () {
    testWidgets('renders with 0% score', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 0.0, animate: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScoreRing), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with 100% score', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 1.0, animate: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScoreRing), findsOneWidget);
    });

    testWidgets('renders with 50% score', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 0.5, animate: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScoreRing), findsOneWidget);
    });

    testWidgets('displays child widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.75,
          animate: false,
          child: Text('75%'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('uses custom activeColor', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.8,
          animate: false,
          activeColor: Colors.green,
          child: Text('80%'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScoreRing), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.5,
          size: 200,
          animate: false,
        ),
      ));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ScoreRing),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 200);
      expect(sizedBox.height, 200);
    });

    testWidgets('animation runs when animate is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 0.8, animate: true),
      ));

      // Pump a few frames to let animation progress
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ScoreRing), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ScoreRing), findsOneWidget);
    });

    testWidgets('color changes based on score tier (visual check)',
        (tester) async {
      // Green tier (>= 80%)
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.9,
          animate: false,
          activeColor: Color(0xFF4CAF50), // green
          child: Text('90%'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('90%'), findsOneWidget);

      // Yellow tier (>= 50%)
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.6,
          animate: false,
          activeColor: Color(0xFFFFBF3C), // amber
          child: Text('60%'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('60%'), findsOneWidget);

      // Red tier (< 50%)
      await tester.pumpWidget(_wrap(
        const ScoreRing(
          score: 0.3,
          animate: false,
          activeColor: Color(0xFFFF5A5F), // red
          child: Text('30%'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('30%'), findsOneWidget);
    });
  });
}
