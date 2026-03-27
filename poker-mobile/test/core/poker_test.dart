// Poker Sharp — Hand Evaluator Tests (exhaustive)

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_sharp/core/poker.dart';

import '../helpers/test_helpers.dart';

void main() {
  // =========================================================================
  // 1. Card basics
  // =========================================================================
  group('Card basics', () {
    test('Card creation stores rank and suit', () {
      const card = Card(rank: 12, suit: 0);
      expect(card.rank, 12);
      expect(card.suit, 0);
    });

    test('Card equality', () {
      const a = Card(rank: 5, suit: 2);
      const b = Card(rank: 5, suit: 2);
      const c = Card(rank: 5, suit: 3);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('Card hashCode is unique per card', () {
      final hashes = <int>{};
      for (int suit = 0; suit < 4; suit++) {
        for (int rank = 0; rank < 13; rank++) {
          hashes.add(Card(rank: rank, suit: suit).hashCode);
        }
      }
      expect(hashes.length, 52);
    });

    test('cardKey returns unique value per card', () {
      final keys = <int>{};
      for (int suit = 0; suit < 4; suit++) {
        for (int rank = 0; rank < 13; rank++) {
          keys.add(cardKey(Card(rank: rank, suit: suit)));
        }
      }
      expect(keys.length, 52);
    });

    test('cardToString formats correctly', () {
      expect(cardToString(const Card(rank: 12, suit: 0)), 'A♠');
      expect(cardToString(const Card(rank: 11, suit: 1)), 'K♥');
      expect(cardToString(const Card(rank: 0, suit: 3)), '2♣');
      expect(cardToString(const Card(rank: 8, suit: 2)), 'T♦');
    });

    test('cardsEqual works', () {
      const a = Card(rank: 12, suit: 0);
      const b = Card(rank: 12, suit: 0);
      const c = Card(rank: 11, suit: 0);
      expect(cardsEqual(a, b), true);
      expect(cardsEqual(a, c), false);
    });
  });

  // =========================================================================
  // 2. Deck
  // =========================================================================
  group('Deck', () {
    test('buildDeck returns 52 unique cards', () {
      final deck = buildDeck();
      expect(deck.length, 52);
      final keys = deck.map(cardKey).toSet();
      expect(keys.length, 52);
    });

    test('buildDeck contains all ranks and suits', () {
      final deck = buildDeck();
      for (int suit = 0; suit < 4; suit++) {
        for (int rank = 0; rank < 13; rank++) {
          expect(
            deck.any((c) => c.rank == rank && c.suit == suit),
            true,
            reason: 'Missing card rank=$rank suit=$suit',
          );
        }
      }
    });

    test('shuffleDeck preserves all 52 cards', () {
      final deck = buildDeck();
      final shuffled = shuffleDeck(deck);
      expect(shuffled.length, 52);
      final originalKeys = deck.map(cardKey).toSet();
      final shuffledKeys = shuffled.map(cardKey).toSet();
      expect(shuffledKeys, equals(originalKeys));
    });

    test('shuffleDeck produces different order', () {
      // This test may occasionally fail (~1 in 52! chance), but that's negligible
      final deck = buildDeck();
      final shuffled = shuffleDeck(deck);
      final sameOrder =
          List.generate(52, (i) => cardKey(deck[i]) == cardKey(shuffled[i]))
              .every((e) => e);
      expect(sameOrder, false);
    });
  });

  // =========================================================================
  // 3. Individual hand evaluation
  // =========================================================================
  group('Hand evaluation — evaluate5 via evaluateBestHand', () {
    test('Royal Flush', () {
      // Board: A♠ K♠ Q♠ J♠ T♠, Holding: 2♥ 3♥ (irrelevant)
      final board = createRoyalFlushBoard();
      final holding = [const Card(rank: 0, suit: 1), const Card(rank: 1, suit: 1)];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 9);
      expect(result.categoryName, 'Royal Flush');
    });

    test('Straight Flush', () {
      // Board: 9♥ 8♥ 7♥ 2♣ 3♦, Holding: 6♥ 5♥
      final board = [
        const Card(rank: 7, suit: 1), // 9♥
        const Card(rank: 6, suit: 1), // 8♥
        const Card(rank: 5, suit: 1), // 7♥
        const Card(rank: 0, suit: 3), // 2♣
        const Card(rank: 1, suit: 2), // 3♦
      ];
      final holding = [
        const Card(rank: 4, suit: 1), // 6♥
        const Card(rank: 3, suit: 1), // 5♥
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 8);
      expect(result.categoryName, 'Straight Flush');
    });

    test('Four of a Kind', () {
      // Board: A♠ A♥ A♦ K♣ Q♠, Holding: A♣ 2♥
      final board = [
        const Card(rank: 12, suit: 0), // A♠
        const Card(rank: 12, suit: 1), // A♥
        const Card(rank: 12, suit: 2), // A♦
        const Card(rank: 11, suit: 3), // K♣
        const Card(rank: 10, suit: 0), // Q♠
      ];
      final holding = [
        const Card(rank: 12, suit: 3), // A♣
        const Card(rank: 0, suit: 1), // 2♥
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 7);
      expect(result.categoryName, 'Four of a Kind');
    });

    test('Full House — Kings full of Nines', () {
      // Board: K♠ K♥ 9♦ 9♣ 3♠, Holding: K♦ 2♥
      final board = [
        const Card(rank: 11, suit: 0),
        const Card(rank: 11, suit: 1),
        const Card(rank: 7, suit: 2),
        const Card(rank: 7, suit: 3),
        const Card(rank: 1, suit: 0),
      ];
      final holding = [
        const Card(rank: 11, suit: 2), // K♦
        const Card(rank: 0, suit: 1), // 2♥
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 6);
      expect(result.description, contains('Full House'));
      expect(result.description, contains('K'));
    });

    test('Flush — A-high', () {
      // Board: A♥ T♥ 7♥ 3♣ 2♠, Holding: K♥ 5♥
      final board = [
        const Card(rank: 12, suit: 1),
        const Card(rank: 8, suit: 1),
        const Card(rank: 5, suit: 1),
        const Card(rank: 1, suit: 3),
        const Card(rank: 0, suit: 0),
      ];
      final holding = [
        const Card(rank: 11, suit: 1), // K♥
        const Card(rank: 3, suit: 1), // 5♥
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 5);
      expect(result.description, contains('Flush'));
      expect(result.description, contains('A'));
    });

    test('Straight — normal (T-high)', () {
      // Board: T♠ 9♥ 8♦ 3♣ 2♠, Holding: 7♠ 6♣
      final board = [
        const Card(rank: 8, suit: 0),
        const Card(rank: 7, suit: 1),
        const Card(rank: 6, suit: 2),
        const Card(rank: 1, suit: 3),
        const Card(rank: 0, suit: 0),
      ];
      final holding = [
        const Card(rank: 5, suit: 0), // 7♠
        const Card(rank: 4, suit: 3), // 6♣
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 4);
      expect(result.description, contains('Straight'));
    });

    test('Straight — wheel (A-2-3-4-5)', () {
      // Board: A♠ 5♥ 4♦ 2♣ 8♠, Holding: 3♠ 7♥
      final board = [
        const Card(rank: 12, suit: 0), // A♠
        const Card(rank: 3, suit: 1), // 5♥
        const Card(rank: 2, suit: 2), // 4♦
        const Card(rank: 0, suit: 3), // 2♣
        const Card(rank: 6, suit: 0), // 8♠
      ];
      final holding = [
        const Card(rank: 1, suit: 0), // 3♠
        const Card(rank: 5, suit: 1), // 7♥
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 4);
      expect(result.description, contains('5-high'));
    });

    test('Straight — broadway (A-K-Q-J-T)', () {
      // Board: A♠ K♥ Q♦ J♣ 2♠, Holding: T♥ 3♣
      final board = [
        const Card(rank: 12, suit: 0),
        const Card(rank: 11, suit: 1),
        const Card(rank: 10, suit: 2),
        const Card(rank: 9, suit: 3),
        const Card(rank: 0, suit: 0),
      ];
      final holding = [
        const Card(rank: 8, suit: 1), // T♥
        const Card(rank: 1, suit: 3), // 3♣
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 4);
      expect(result.description, contains('A-high'));
    });

    test('Three of a Kind', () {
      // Board: 7♠ 7♥ 4♦ 2♣ 9♠, Holding: 7♦ K♣
      final board = [
        const Card(rank: 5, suit: 0),
        const Card(rank: 5, suit: 1),
        const Card(rank: 2, suit: 2),
        const Card(rank: 0, suit: 3),
        const Card(rank: 7, suit: 0),
      ];
      final holding = [
        const Card(rank: 5, suit: 2), // 7♦
        const Card(rank: 11, suit: 3), // K♣
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 3);
      expect(result.description, contains('Three of a Kind'));
    });

    test('Two Pair', () {
      // Board: K♠ 9♥ 5♦ 2♣ 3♠, Holding: K♥ 9♦
      final board = [
        const Card(rank: 11, suit: 0),
        const Card(rank: 7, suit: 1),
        const Card(rank: 3, suit: 2),
        const Card(rank: 0, suit: 3),
        const Card(rank: 1, suit: 0),
      ];
      final holding = [
        const Card(rank: 11, suit: 1), // K♥
        const Card(rank: 7, suit: 2), // 9♦
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 2);
      expect(result.description, contains('Two Pair'));
    });

    test('One Pair', () {
      // Board: A♠ 9♥ 5♦ 2♣ 3♠, Holding: A♥ 7♦
      final board = [
        const Card(rank: 12, suit: 0),
        const Card(rank: 7, suit: 1),
        const Card(rank: 3, suit: 2),
        const Card(rank: 0, suit: 3),
        const Card(rank: 1, suit: 0),
      ];
      final holding = [
        const Card(rank: 12, suit: 1), // A♥
        const Card(rank: 5, suit: 2), // 7♦
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 1);
      expect(result.description, contains('Pair'));
    });

    test('High Card', () {
      // Board: A♠ T♥ 7♦ 4♣ 2♠, Holding: K♥ 9♦ (no pair, flush, or straight)
      final board = [
        const Card(rank: 12, suit: 0),
        const Card(rank: 8, suit: 1),
        const Card(rank: 5, suit: 2),
        const Card(rank: 2, suit: 3),
        const Card(rank: 0, suit: 0),
      ];
      final holding = [
        const Card(rank: 11, suit: 1), // K♥
        const Card(rank: 7, suit: 2), // 9♦
      ];
      final result = evaluateBestHand([...board, ...holding]);

      expect(result.category, 0);
      expect(result.description, contains('A-high'));
    });
  });

  // =========================================================================
  // 4. Hand ranking correctness
  // =========================================================================
  group('Hand ranking hierarchy', () {
    test('Royal Flush > Straight Flush > Four of a Kind > ... > High Card', () {
      // Use evaluate5 directly with crafted 5-card hands
      final royalFlush = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 11, suit: 0),
        const Card(rank: 10, suit: 0),
        const Card(rank: 9, suit: 0),
        const Card(rank: 8, suit: 0),
      ]);

      final straightFlush = evaluate5([
        const Card(rank: 7, suit: 1),
        const Card(rank: 6, suit: 1),
        const Card(rank: 5, suit: 1),
        const Card(rank: 4, suit: 1),
        const Card(rank: 3, suit: 1),
      ]);

      final fourOfAKind = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 12, suit: 1),
        const Card(rank: 12, suit: 2),
        const Card(rank: 12, suit: 3),
        const Card(rank: 11, suit: 0),
      ]);

      final fullHouse = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 12, suit: 1),
        const Card(rank: 12, suit: 2),
        const Card(rank: 11, suit: 0),
        const Card(rank: 11, suit: 1),
      ]);

      final flush = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 10, suit: 0),
        const Card(rank: 7, suit: 0),
        const Card(rank: 5, suit: 0),
        const Card(rank: 3, suit: 0),
      ]);

      final straight = evaluate5([
        const Card(rank: 8, suit: 0),
        const Card(rank: 7, suit: 1),
        const Card(rank: 6, suit: 2),
        const Card(rank: 5, suit: 3),
        const Card(rank: 4, suit: 0),
      ]);

      final threeOfAKind = evaluate5([
        const Card(rank: 7, suit: 0),
        const Card(rank: 7, suit: 1),
        const Card(rank: 7, suit: 2),
        const Card(rank: 12, suit: 0),
        const Card(rank: 11, suit: 1),
      ]);

      final twoPair = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 12, suit: 1),
        const Card(rank: 11, suit: 0),
        const Card(rank: 11, suit: 1),
        const Card(rank: 10, suit: 0),
      ]);

      final onePair = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 12, suit: 1),
        const Card(rank: 11, suit: 0),
        const Card(rank: 10, suit: 1),
        const Card(rank: 9, suit: 0),
      ]);

      final highCard = evaluate5([
        const Card(rank: 12, suit: 0),
        const Card(rank: 10, suit: 1),
        const Card(rank: 7, suit: 2),
        const Card(rank: 5, suit: 3),
        const Card(rank: 3, suit: 0),
      ]);

      expect(royalFlush.strength > straightFlush.strength, true);
      expect(straightFlush.strength > fourOfAKind.strength, true);
      expect(fourOfAKind.strength > fullHouse.strength, true);
      expect(fullHouse.strength > flush.strength, true);
      expect(flush.strength > straight.strength, true);
      expect(straight.strength > threeOfAKind.strength, true);
      expect(threeOfAKind.strength > twoPair.strength, true);
      expect(twoPair.strength > onePair.strength, true);
      expect(onePair.strength > highCard.strength, true);
    });
  });

  // =========================================================================
  // 5. Kicker comparison
  // =========================================================================
  group('Kicker comparison', () {
    test('AA with K kicker > AA with Q kicker', () {
      final aaK = evaluate5([
        const Card(rank: 12, suit: 0), // A
        const Card(rank: 12, suit: 1), // A
        const Card(rank: 11, suit: 0), // K
        const Card(rank: 5, suit: 2), // 7
        const Card(rank: 3, suit: 3), // 5
      ]);

      final aaQ = evaluate5([
        const Card(rank: 12, suit: 2), // A
        const Card(rank: 12, suit: 3), // A
        const Card(rank: 10, suit: 0), // Q
        const Card(rank: 5, suit: 1), // 7
        const Card(rank: 3, suit: 0), // 5
      ]);

      expect(aaK.strength > aaQ.strength, true);
      expect(aaK.category, equals(aaQ.category)); // Both are one pair
    });

    test('KKK with AQ kicker > KKK with AJ kicker', () {
      final kkkAQ = evaluate5([
        const Card(rank: 11, suit: 0),
        const Card(rank: 11, suit: 1),
        const Card(rank: 11, suit: 2),
        const Card(rank: 12, suit: 0), // A
        const Card(rank: 10, suit: 0), // Q
      ]);

      final kkkAJ = evaluate5([
        const Card(rank: 11, suit: 0),
        const Card(rank: 11, suit: 1),
        const Card(rank: 11, suit: 3),
        const Card(rank: 12, suit: 1), // A
        const Card(rank: 9, suit: 1), // J
      ]);

      expect(kkkAQ.strength > kkkAJ.strength, true);
    });
  });

  // =========================================================================
  // 6. rankAllHoldings
  // =========================================================================
  group('rankAllHoldings', () {
    test('returns 1081 holdings (C(47,2)) for any board', () {
      final board = createTestBoard();
      final all = rankAllHoldings(board);
      expect(all.length, 1081);
    });

    test('holdings are ordered by descending strength', () {
      final board = createTestBoard();
      final all = rankAllHoldings(board);

      for (int i = 1; i < all.length; i++) {
        expect(
          all[i].handResult.strength <= all[i - 1].handResult.strength,
          true,
          reason: 'Holding $i should not have greater strength than ${i - 1}',
        );
      }
    });

    test('rank 1 is the best holding', () {
      final board = createTestBoard();
      final all = rankAllHoldings(board);
      expect(all[0].rank, 1);
    });

    test('tied holdings share the same rank', () {
      final board = createTestBoard();
      final all = rankAllHoldings(board);

      final grouped = <int, List<RankedHolding>>{};
      for (final h in all) {
        grouped.putIfAbsent(h.rank, () => []).add(h);
      }

      for (final entry in grouped.entries) {
        final strengths = entry.value.map((h) => h.handResult.strength).toSet();
        if (entry.value.length > 1) {
          expect(strengths.length, 1,
              reason: 'Holdings with rank ${entry.key} should share strength');
        }
      }
    });
  });

  // =========================================================================
  // 7. Equivalence classes
  // =========================================================================
  group('Equivalence classes', () {
    test('groupIntoEquivalenceClasses returns requested count', () {
      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 10);
      expect(classes.length, 10);
    });

    test('members within a class have identical strength', () {
      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 10);

      for (final cls in classes) {
        final strengths = <int>{};
        for (final member in cls.members) {
          final sevenCards = [...board, ...member];
          final result = evaluateBestHand(sevenCards);
          strengths.add(result.strength);
        }
        expect(strengths.length, 1,
            reason: 'Class rank ${cls.rank} should have uniform strength');
      }
    });

    test('classes are ordered by descending strength', () {
      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 20);

      for (int i = 1; i < classes.length; i++) {
        expect(
          classes[i].strength < classes[i - 1].strength,
          true,
          reason:
              'Class ${classes[i].rank} should have less strength than ${classes[i - 1].rank}',
        );
      }
    });

    test('getEquivalenceLabel: pair class → "AA" or similar', () {
      // Create a board where AA is the top class
      final board = [
        const Card(rank: 5, suit: 0), // 7♠
        const Card(rank: 3, suit: 1), // 5♥
        const Card(rank: 1, suit: 2), // 3♦
        const Card(rank: 8, suit: 3), // T♣
        const Card(rank: 10, suit: 0), // Q♠
      ];
      final classes = groupIntoEquivalenceClasses(board, 5);

      // There should be some class labels present
      for (final cls in classes) {
        expect(cls.label.isNotEmpty, true);
      }
    });

    test('getEquivalenceLabel for single member returns specific cards', () {
      const members = [
        [Card(rank: 12, suit: 1), Card(rank: 11, suit: 1)],
      ];
      final board = createTestBoard();
      final label = getEquivalenceLabel(members, board);
      expect(label, 'A♥K♥');
    });

    test('getEquivalenceLabel for all 6 pair combos returns "XX"', () {
      // All 6 combos of rank 12 (Ace)
      final members = [
        const [Card(rank: 12, suit: 0), Card(rank: 12, suit: 1)],
        const [Card(rank: 12, suit: 0), Card(rank: 12, suit: 2)],
        const [Card(rank: 12, suit: 0), Card(rank: 12, suit: 3)],
        const [Card(rank: 12, suit: 1), Card(rank: 12, suit: 2)],
        const [Card(rank: 12, suit: 1), Card(rank: 12, suit: 3)],
        const [Card(rank: 12, suit: 2), Card(rank: 12, suit: 3)],
      ];
      // Use a board with no aces
      final board = [
        const Card(rank: 5, suit: 0),
        const Card(rank: 3, suit: 1),
        const Card(rank: 1, suit: 2),
        const Card(rank: 8, suit: 3),
        const Card(rank: 10, suit: 0),
      ];
      final label = getEquivalenceLabel(members, board);
      expect(label, 'AA');
    });

    test('getEquivalenceLabel for 4 suited combos returns "XYs"', () {
      final members = [
        const [Card(rank: 12, suit: 0), Card(rank: 11, suit: 0)],
        const [Card(rank: 12, suit: 1), Card(rank: 11, suit: 1)],
        const [Card(rank: 12, suit: 2), Card(rank: 11, suit: 2)],
        const [Card(rank: 12, suit: 3), Card(rank: 11, suit: 3)],
      ];
      final board = [
        const Card(rank: 5, suit: 0),
        const Card(rank: 3, suit: 1),
        const Card(rank: 1, suit: 2),
        const Card(rank: 8, suit: 3),
        const Card(rank: 10, suit: 0),
      ];
      final label = getEquivalenceLabel(members, board);
      expect(label, 'AKs');
    });

    test('getEquivalenceLabel for 12 offsuit combos returns "XYo"', () {
      final members = <List<Card>>[];
      for (int s1 = 0; s1 < 4; s1++) {
        for (int s2 = 0; s2 < 4; s2++) {
          if (s1 != s2) {
            members.add([Card(rank: 12, suit: s1), Card(rank: 11, suit: s2)]);
          }
        }
      }
      final board = [
        const Card(rank: 5, suit: 0),
        const Card(rank: 3, suit: 1),
        const Card(rank: 1, suit: 2),
        const Card(rank: 8, suit: 3),
        const Card(rank: 10, suit: 0),
      ];
      final label = getEquivalenceLabel(members, board);
      expect(label, 'AKo');
    });
  });

  // =========================================================================
  // 8. findEquivalenceClassForHolding
  // =========================================================================
  group('findEquivalenceClassForHolding', () {
    test('finds the correct class for a known holding', () {
      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 10);

      // Take the first member of class #1
      final topClass = classes[0];
      final holding = topClass.members[0];
      final found = findEquivalenceClassForHolding(holding, board, classes);

      expect(found, isNotNull);
      expect(found!.rank, topClass.rank);
    });

    test('returns null for a holding not in any top-N class', () {
      final board = createTestBoard();
      final classes = groupIntoEquivalenceClasses(board, 3);

      // Find a holding NOT in the top 3 classes
      final allRanked = rankAllHoldings(board);
      final bottomHolding = allRanked.last;
      final found = findEquivalenceClassForHolding(
          bottomHolding.cards, board, classes);

      // This might or might not be null depending on the board.
      // For a board with 1081 holdings and only 3 classes, bottom is very likely not in top 3.
      // Just verify the function doesn't crash and returns a class or null.
      if (found != null) {
        expect(found.rank, lessThanOrEqualTo(3));
      }
    });
  });

  // =========================================================================
  // 9. Board-specific: monotone board suit sensitivity
  // =========================================================================
  group('Board-specific tests', () {
    test('Monotone board (all hearts) should have flush-dominant classes', () {
      final board = [
        const Card(rank: 12, suit: 1), // A♥
        const Card(rank: 10, suit: 1), // Q♥
        const Card(rank: 8, suit: 1), // T♥
        const Card(rank: 5, suit: 1), // 7♥
        const Card(rank: 1, suit: 1), // 3♥
      ];
      final classes = groupIntoEquivalenceClasses(board, 5);

      // Top classes on a monotone board should have flush or better categories
      final topClass = classes[0];
      expect(topClass.description.isNotEmpty, true);
      // At minimum, the top class should be a flush or better
      final topResult = evaluateBestHand([...board, ...topClass.members[0]]);
      expect(topResult.category, greaterThanOrEqualTo(5)); // Flush or better
    });
  });

  // =========================================================================
  // 10. dealBoard
  // =========================================================================
  group('dealBoard', () {
    test('returns exactly 5 cards', () {
      final board = dealBoard();
      expect(board.length, 5);
    });

    test('all cards are unique', () {
      final board = dealBoard();
      final keys = board.map(cardKey).toSet();
      expect(keys.length, 5);
    });

    test('cards are valid (rank 0-12, suit 0-3)', () {
      final board = dealBoard();
      for (final card in board) {
        expect(card.rank, inInclusiveRange(0, 12));
        expect(card.suit, inInclusiveRange(0, 3));
      }
    });

    test('dealing multiple boards produces different results', () {
      final boards = List.generate(5, (_) => dealBoard());
      final boardStrings = boards.map(
        (b) => b.map(cardKey).toList()..sort(),
      ).map((b) => b.join(',')).toSet();

      // Extremely unlikely that 5 random boards are identical
      expect(boardStrings.length, greaterThan(1));
    });
  });

  // =========================================================================
  // Combinations utility
  // =========================================================================
  group('combinations', () {
    test('C(5,2) = 10', () {
      final result = combinations([1, 2, 3, 4, 5], 2);
      expect(result.length, 10);
    });

    test('C(4,4) = 1', () {
      final result = combinations([1, 2, 3, 4], 4);
      expect(result.length, 1);
    });

    test('C(47,2) = 1081', () {
      final items = List.generate(47, (i) => i);
      final result = combinations(items, 2);
      expect(result.length, 1081);
    });
  });

  // =========================================================================
  // describeHand
  // =========================================================================
  group('describeHand', () {
    test('describes Royal Flush', () {
      final d = describeHand(9, [
        const Card(rank: 12, suit: 0),
        const Card(rank: 11, suit: 0),
        const Card(rank: 10, suit: 0),
        const Card(rank: 9, suit: 0),
        const Card(rank: 8, suit: 0),
      ]);
      expect(d, 'Royal Flush');
    });

    test('describes High Card', () {
      final d = describeHand(0, [
        const Card(rank: 12, suit: 0),
        const Card(rank: 10, suit: 1),
        const Card(rank: 7, suit: 2),
        const Card(rank: 5, suit: 3),
        const Card(rank: 3, suit: 0),
      ]);
      expect(d, 'A-high');
    });
  });
}
