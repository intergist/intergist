// Poker Sharp — Scoring Engine Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_sharp/core/poker.dart';
import 'package:poker_sharp/core/scoring.dart';

import '../helpers/test_helpers.dart';

void main() {
  // =========================================================================
  // 1. Perfect score
  // =========================================================================
  group('Perfect score', () {
    test('submitting correct classes in order yields 100%', () {
      final board = createTestBoard();
      const targetCount = 5;
      final classes = groupIntoEquivalenceClasses(board, targetCount);

      // Pick one member from each class in order
      final userHoldings = classes.map((c) => (cards: c.members[0])).toList();
      final result = scoreSubmissionGrouped(board, userHoldings, targetCount);

      expect(result.percentage, 100);
      expect(result.totalPoints, targetCount * 2);
      expect(result.perPosition.every((p) => p.status == 'exact'), true);
      expect(result.missedClasses, isEmpty);
    });
  });

  // =========================================================================
  // 2. Partial score
  // =========================================================================
  group('Partial score', () {
    test('correct classes in wrong order yields partial points', () {
      final board = createTestBoard();
      const targetCount = 5;
      final classes = groupIntoEquivalenceClasses(board, targetCount);

      // Reverse the order — all classes are correct but wrong positions
      final userHoldings =
          classes.reversed.map((c) => (cards: c.members[0])).toList();
      final result = scoreSubmissionGrouped(board, userHoldings, targetCount);

      // All should be partial (1 point each) except any that land on their original position
      expect(result.totalPoints, greaterThan(0));
      expect(result.totalPoints, lessThanOrEqualTo(targetCount * 2));

      // Count partial statuses
      final partialCount =
          result.perPosition.where((p) => p.status == 'partial').length;
      final exactCount =
          result.perPosition.where((p) => p.status == 'exact').length;
      expect(partialCount + exactCount, targetCount);
    });
  });

  // =========================================================================
  // 3. Wrong holdings
  // =========================================================================
  group('Wrong holdings', () {
    test('holdings not in top N yield 0 points', () {
      final board = createTestBoard();
      const targetCount = 3;

      // Get all ranked holdings and pick from the very bottom
      final allRanked = rankAllHoldings(board);
      final bottom = allRanked.reversed.take(3).toList();
      final userHoldings = bottom.map((h) => (cards: h.cards)).toList();

      final result = scoreSubmissionGrouped(board, userHoldings, targetCount);

      // These should all be wrong (0 points) since they're the worst holdings
      final wrongCount =
          result.perPosition.where((p) => p.status == 'wrong').length;
      // At least some should be wrong
      expect(wrongCount, greaterThan(0));
    });
  });

  // =========================================================================
  // 4. Missing slots
  // =========================================================================
  group('Missing slots', () {
    test('fewer holdings than target yields missing status', () {
      final board = createTestBoard();
      const targetCount = 10;
      final classes = groupIntoEquivalenceClasses(board, targetCount);

      // Only submit 3 holdings
      final userHoldings =
          classes.take(3).map((c) => (cards: c.members[0])).toList();
      final result = scoreSubmissionGrouped(board, userHoldings, targetCount);

      final missingCount =
          result.perPosition.where((p) => p.status == 'missing').length;
      expect(missingCount, 7); // 10 - 3 = 7 missing
      expect(result.percentage, lessThan(100));
    });

    test('empty submission yields 0%', () {
      final board = createTestBoard();
      const targetCount = 5;

      final result = scoreSubmissionGrouped(board, [], targetCount);

      expect(result.totalPoints, 0);
      expect(result.percentage, 0);
      final missingCount =
          result.perPosition.where((p) => p.status == 'missing').length;
      expect(missingCount, targetCount);
    });
  });

  // =========================================================================
  // 5. Speed rating
  // =========================================================================
  group('Speed rating', () {
    test('5 stars: very fast (≤1.5 sec/holding)', () {
      // 10 holdings in 10 seconds = 1.0 sec/holding
      expect(getSpeedRating(10000, 10), 5);
    });

    test('4 stars: fast (≤3 sec/holding)', () {
      // 10 holdings in 25 seconds = 2.5 sec/holding
      expect(getSpeedRating(25000, 10), 4);
    });

    test('3 stars: moderate (≤5 sec/holding)', () {
      // 10 holdings in 45 seconds = 4.5 sec/holding
      expect(getSpeedRating(45000, 10), 3);
    });

    test('2 stars: slow (≤8 sec/holding)', () {
      // 10 holdings in 70 seconds = 7 sec/holding
      expect(getSpeedRating(70000, 10), 2);
    });

    test('1 star: very slow (>8 sec/holding)', () {
      // 10 holdings in 100 seconds = 10 sec/holding
      expect(getSpeedRating(100000, 10), 1);
    });

    test('multiplier applied for 5 holdings (×0.8)', () {
      // 5 holdings in 5 seconds = 1.0 sec/holding before multiplier
      // After: 5000 / 0.8 = 6250 adjusted → 6250/5 = 1250 ms → 1.25 sec
      expect(getSpeedRating(5000, 5), 5);
    });

    test('multiplier applied for 20 holdings (×1.2)', () {
      // 20 holdings in 30 seconds = 1.5 sec/holding before multiplier
      // After: 30000 / 1.2 = 25000 → 25000/20 = 1250 ms → 1.25 sec
      expect(getSpeedRating(30000, 20), 5);
    });
  });

  // =========================================================================
  // 6. Board texture analysis
  // =========================================================================
  group('Board texture analysis', () {
    test('monotone board (all hearts)', () {
      final board = [
        const Card(rank: 12, suit: 1),
        const Card(rank: 10, suit: 1),
        const Card(rank: 7, suit: 1),
        const Card(rank: 3, suit: 1),
        const Card(rank: 0, suit: 1),
      ];
      final texture = analyzeBoardTexture(board);

      expect(texture.isMonotone, true);
      expect(texture.isTwoTone, false);
      expect(texture.isRainbow, false);
      expect(texture.description, contains('Monotone'));
    });

    test('rainbow board (4 suits)', () {
      final texture = analyzeBoardTexture(createRainbowBoard());

      expect(texture.isRainbow, true);
      expect(texture.isMonotone, false);
      expect(texture.description, contains('Rainbow'));
    });

    test('paired board', () {
      final board = [
        const Card(rank: 11, suit: 0), // K♠
        const Card(rank: 11, suit: 1), // K♥
        const Card(rank: 5, suit: 2), // 7♦
        const Card(rank: 3, suit: 3), // 5♣
        const Card(rank: 0, suit: 0), // 2♠
      ];
      final texture = analyzeBoardTexture(board);

      expect(texture.isPaired, true);
      expect(texture.isDoublePaired, false);
      expect(texture.description, contains('paired'));
    });

    test('double-paired board', () {
      final texture = analyzeBoardTexture(createDoublePairedBoard());

      expect(texture.isDoublePaired, true);
      expect(texture.isPaired, true);
      expect(texture.description, contains('double-paired'));
    });

    test('trips on board', () {
      final texture = analyzeBoardTexture(createTripsBoard());

      expect(texture.isTrips, true);
      expect(texture.description, contains('trips'));
    });

    test('connected board', () {
      final board = [
        const Card(rank: 8, suit: 0), // T
        const Card(rank: 7, suit: 1), // 9
        const Card(rank: 6, suit: 2), // 8
        const Card(rank: 5, suit: 3), // 7
        const Card(rank: 4, suit: 0), // 6
      ];
      final texture = analyzeBoardTexture(board);

      expect(texture.connectivity, 'connected');
    });

    test('highest card is correct', () {
      final board = createRainbowBoard();
      final texture = analyzeBoardTexture(board);

      expect(texture.highestCard.rank, 12); // Ace
    });
  });

  // =========================================================================
  // 7. Suit sensitivity detection
  // =========================================================================
  group('Suit sensitivity', () {
    test('3+ of same suit is suit-sensitive', () {
      expect(isBoardSuitSensitive(createSuitSensitiveBoard()), true);
    });

    test('monotone board is suit-sensitive', () {
      final board = [
        const Card(rank: 12, suit: 1),
        const Card(rank: 10, suit: 1),
        const Card(rank: 7, suit: 1),
        const Card(rank: 3, suit: 1),
        const Card(rank: 0, suit: 1),
      ];
      expect(isBoardSuitSensitive(board), true);
    });

    test('rainbow board is NOT suit-sensitive', () {
      expect(isBoardSuitSensitive(createRainbowBoard()), false);
    });
  });

  // =========================================================================
  // 8. Mixed scenario
  // =========================================================================
  group('Mixed scoring scenario', () {
    test('some exact, some partial, some wrong', () {
      final board = createTestBoard();
      const targetCount = 5;
      final classes = groupIntoEquivalenceClasses(board, targetCount);
      final allRanked = rankAllHoldings(board);

      // Position 0: exact (class #1 member)
      // Position 1: exact (class #2 member)
      // Position 2: class #4 member (partial — right class wrong position)
      // Position 3: class #3 member (partial — right class wrong position)
      // Position 4: worst holding in the deck (wrong)
      final userHoldings = <({List<Card> cards})>[
        (cards: classes[0].members[0]),
        (cards: classes[1].members[0]),
        (cards: classes[3].members[0]),
        (cards: classes[2].members[0]),
        (cards: allRanked.last.cards),
      ];

      final result = scoreSubmissionGrouped(board, userHoldings, targetCount);

      final exactCount =
          result.perPosition.where((p) => p.status == 'exact').length;
      final partialCount =
          result.perPosition.where((p) => p.status == 'partial').length;
      final wrongCount =
          result.perPosition.where((p) => p.status == 'wrong').length;

      expect(exactCount, greaterThanOrEqualTo(2)); // positions 0, 1
      expect(partialCount, greaterThanOrEqualTo(1)); // at least one partial
      expect(result.totalPoints, greaterThan(0));
      expect(result.totalPoints, lessThan(targetCount * 2));
    });
  });
}
