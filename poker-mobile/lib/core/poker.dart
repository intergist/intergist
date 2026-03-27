// Poker Sharp — Hand Evaluator Engine
// Cards: rank 0=2, 1=3, ..., 8=T, 9=J, 10=Q, 11=K, 12=A
// Suits: 0=spade, 1=heart, 2=diamond, 3=club

import 'dart:math';

class Card {
  final int rank; // 0-12 where 0=2, 12=Ace
  final int suit; // 0=spade, 1=heart, 2=diamond, 3=club

  const Card({required this.rank, required this.suit});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => suit * 13 + rank;

  @override
  String toString() => cardToString(this);
}

class HandResult {
  final int category; // 0=HighCard ... 9=RoyalFlush
  final String categoryName;
  final String description;
  final List<Card> fiveCards;
  final int strength; // comparable numeric strength

  const HandResult({
    required this.category,
    required this.categoryName,
    required this.description,
    required this.fiveCards,
    required this.strength,
  });
}

class RankedHolding {
  final List<Card> cards; // always 2 cards
  final HandResult handResult;
  final int rank; // 1-based position

  const RankedHolding({
    required this.cards,
    required this.handResult,
    required this.rank,
  });
}

class EquivalenceClass {
  final int rank; // 1-based position (one per class)
  final int strength; // shared HandResult.strength
  final String label; // human-readable label (e.g., "AA", "AKs", "A♥K♥")
  final String description; // hand description (e.g., "Three of a Kind, Aces")
  final List<Card> fiveCards; // representative best 5 cards
  final List<List<Card>> members; // all specific holdings in this class
  final int memberCount;

  const EquivalenceClass({
    required this.rank,
    required this.strength,
    required this.label,
    required this.description,
    required this.fiveCards,
    required this.members,
    required this.memberCount,
  });
}

const List<String> rankNames = [
  '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'
];
const List<String> suitSymbols = ['♠', '♥', '♦', '♣'];
const List<String> suitNames = ['spades', 'hearts', 'diamonds', 'clubs'];

const List<String> handCategories = [
  'High Card', // 0
  'One Pair', // 1
  'Two Pair', // 2
  'Three of a Kind', // 3
  'Straight', // 4
  'Flush', // 5
  'Full House', // 6
  'Four of a Kind', // 7
  'Straight Flush', // 8
  'Royal Flush', // 9
];

String cardToString(Card card) {
  return rankNames[card.rank] + suitSymbols[card.suit];
}

bool cardsEqual(Card a, Card b) {
  return a.rank == b.rank && a.suit == b.suit;
}

int cardKey(Card card) {
  return card.suit * 13 + card.rank;
}

/// Build a full 52-card deck
List<Card> buildDeck() {
  final deck = <Card>[];
  for (int suit = 0; suit < 4; suit++) {
    for (int rank = 0; rank < 13; rank++) {
      deck.add(Card(rank: rank, suit: suit));
    }
  }
  return deck;
}

/// Shuffle deck using Fisher-Yates
List<Card> shuffleDeck(List<Card> deck) {
  final arr = List<Card>.from(deck);
  final rng = Random();
  for (int i = arr.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
  }
  return arr;
}

/// Generate all C(n,k) combinations from a list
List<List<T>> combinations<T>(List<T> arr, int k) {
  final result = <List<T>>[];
  void backtrack(int start, List<T> current) {
    if (current.length == k) {
      result.add(List<T>.from(current));
      return;
    }
    for (int i = start; i < arr.length; i++) {
      current.add(arr[i]);
      backtrack(i + 1, current);
      current.removeLast();
    }
  }
  backtrack(0, []);
  return result;
}

/// Encode strength value.
/// category * 10^10 + v1 * 10^8 + v2 * 10^6 + v3 * 10^4 + v4 * 10^2 + v5
int _encode(int cat, List<int> values) {
  final v = List<int>.from(values);
  while (v.length < 5) {
    v.add(0);
  }
  return cat * 10000000000 +
      v[0] * 100000000 +
      v[1] * 1000000 +
      v[2] * 10000 +
      v[3] * 100 +
      v[4];
}

/// Evaluate a 5-card hand and return category, strength, and the cards.
/// Higher strength is better.
({int category, int strength, List<Card> cards}) evaluate5(List<Card> cards) {
  final ranks = cards.map((c) => c.rank).toList()..sort((a, b) => b - a);
  final suits = cards.map((c) => c.suit).toList();

  // Check flush
  final isFlush = suits.every((s) => s == suits[0]);

  // Check straight
  bool isStraight = false;
  int straightHigh = -1;

  final uniqueRanks = ranks.toSet().toList()..sort((a, b) => b - a);
  if (uniqueRanks.length == 5) {
    if (uniqueRanks[0] - uniqueRanks[4] == 4) {
      isStraight = true;
      straightHigh = uniqueRanks[0];
    }
    // Ace-low straight (A-2-3-4-5) → wheel
    if (uniqueRanks[0] == 12 &&
        uniqueRanks[1] == 3 &&
        uniqueRanks[2] == 2 &&
        uniqueRanks[3] == 1 &&
        uniqueRanks[4] == 0) {
      isStraight = true;
      straightHigh = 3; // 5-high straight
    }
  }

  // Count rank frequencies
  final freq = <int, int>{};
  for (final r in ranks) {
    freq[r] = (freq[r] ?? 0) + 1;
  }

  final freqEntries = freq.entries.toList()
    ..sort((a, b) {
      if (b.value != a.value) return b.value - a.value;
      return b.key - a.key;
    });

  // Straight Flush / Royal Flush
  if (isFlush && isStraight) {
    if (straightHigh == 12) {
      return (
        category: 9,
        strength: _encode(9, [straightHigh]),
        cards: cards,
      );
    }
    return (
      category: 8,
      strength: _encode(8, [straightHigh]),
      cards: cards,
    );
  }

  // Four of a Kind
  if (freqEntries[0].value == 4) {
    final quad = freqEntries[0].key;
    final kicker = freqEntries[1].key;
    return (
      category: 7,
      strength: _encode(7, [quad, kicker]),
      cards: cards,
    );
  }

  // Full House
  if (freqEntries[0].value == 3 && freqEntries[1].value == 2) {
    final trips = freqEntries[0].key;
    final pair = freqEntries[1].key;
    return (
      category: 6,
      strength: _encode(6, [trips, pair]),
      cards: cards,
    );
  }

  // Flush
  if (isFlush) {
    return (category: 5, strength: _encode(5, ranks), cards: cards);
  }

  // Straight
  if (isStraight) {
    return (
      category: 4,
      strength: _encode(4, [straightHigh]),
      cards: cards,
    );
  }

  // Three of a Kind
  if (freqEntries[0].value == 3) {
    final trips = freqEntries[0].key;
    final kickers = freqEntries.sublist(1).map((e) => e.key).toList()
      ..sort((a, b) => b - a);
    return (
      category: 3,
      strength: _encode(3, [trips, ...kickers]),
      cards: cards,
    );
  }

  // Two Pair
  if (freqEntries[0].value == 2 && freqEntries[1].value == 2) {
    final highPair = max(freqEntries[0].key, freqEntries[1].key);
    final lowPair = min(freqEntries[0].key, freqEntries[1].key);
    final kicker = freqEntries[2].key;
    return (
      category: 2,
      strength: _encode(2, [highPair, lowPair, kicker]),
      cards: cards,
    );
  }

  // One Pair
  if (freqEntries[0].value == 2) {
    final pair = freqEntries[0].key;
    final kickers = freqEntries.sublist(1).map((e) => e.key).toList()
      ..sort((a, b) => b - a);
    return (
      category: 1,
      strength: _encode(1, [pair, ...kickers]),
      cards: cards,
    );
  }

  // High Card
  return (category: 0, strength: _encode(0, ranks), cards: cards);
}

/// Given 7 cards (5 board + 2 hole), find the best 5-card hand.
HandResult evaluateBestHand(List<Card> sevenCards) {
  final combos = combinations(sevenCards, 5);
  ({int category, int strength, List<Card> cards})? best;

  for (final combo in combos) {
    final result = evaluate5(combo);
    if (best == null || result.strength > best.strength) {
      best = result;
    }
  }

  final cat = best!.category;
  final fiveCards = List<Card>.from(best.cards)
    ..sort((a, b) => b.rank - a.rank);

  return HandResult(
    category: cat,
    categoryName: handCategories[cat],
    description: describeHand(cat, fiveCards),
    fiveCards: fiveCards,
    strength: best.strength,
  );
}

String describeHand(int category, List<Card> cards) {
  final sorted = List<Card>.from(cards)..sort((a, b) => b.rank - a.rank);

  switch (category) {
    case 9:
      return 'Royal Flush';
    case 8:
      return 'Straight Flush, ${rankNames[sorted[0].rank]}-high';
    case 7:
      {
        final freq = <int, int>{};
        for (final c in sorted) {
          freq[c.rank] = (freq[c.rank] ?? 0) + 1;
        }
        final quad = freq.entries.firstWhere((e) => e.value == 4).key;
        return 'Four of a Kind, ${rankNames[quad]}s';
      }
    case 6:
      {
        final freq = <int, int>{};
        for (final c in sorted) {
          freq[c.rank] = (freq[c.rank] ?? 0) + 1;
        }
        final trips = freq.entries.firstWhere((e) => e.value == 3).key;
        final pair = freq.entries.firstWhere((e) => e.value == 2).key;
        return 'Full House, ${rankNames[trips]}s full of ${rankNames[pair]}s';
      }
    case 5:
      return 'Flush, ${rankNames[sorted[0].rank]}-high';
    case 4:
      {
        final ranks = sorted.map((c) => c.rank).toList();
        if (ranks.contains(12) &&
            ranks.contains(0) &&
            ranks.contains(1) &&
            ranks.contains(2) &&
            ranks.contains(3)) {
          return 'Straight, 5-high';
        }
        return 'Straight, ${rankNames[sorted[0].rank]}-high';
      }
    case 3:
      {
        final freq = <int, int>{};
        for (final c in sorted) {
          freq[c.rank] = (freq[c.rank] ?? 0) + 1;
        }
        final trips = freq.entries.firstWhere((e) => e.value == 3).key;
        return 'Three of a Kind, ${rankNames[trips]}s';
      }
    case 2:
      {
        final freq = <int, int>{};
        for (final c in sorted) {
          freq[c.rank] = (freq[c.rank] ?? 0) + 1;
        }
        final pairs = freq.entries
            .where((e) => e.value == 2)
            .map((e) => e.key)
            .toList()
          ..sort((a, b) => b - a);
        return 'Two Pair, ${rankNames[pairs[0]]}s and ${rankNames[pairs[1]]}s';
      }
    case 1:
      {
        final freq = <int, int>{};
        for (final c in sorted) {
          freq[c.rank] = (freq[c.rank] ?? 0) + 1;
        }
        final pair = freq.entries.firstWhere((e) => e.value == 2).key;
        return 'Pair of ${rankNames[pair]}s';
      }
    case 0:
      return '${rankNames[sorted[0].rank]}-high';
    default:
      return 'Unknown';
  }
}

/// Evaluate all 1081 possible holdings for a given board, rank them.
List<RankedHolding> rankAllHoldings(List<Card> board) {
  final boardSet = board.map(cardKey).toSet();
  final remaining = buildDeck().where((c) => !boardSet.contains(cardKey(c))).toList();

  // Generate all C(47,2) = 1081 combinations
  final allHoldings = <({List<Card> cards, HandResult handResult})>[];

  for (int i = 0; i < remaining.length; i++) {
    for (int j = i + 1; j < remaining.length; j++) {
      final holding = [remaining[i], remaining[j]];
      final sevenCards = [...board, ...holding];
      final handResult = evaluateBestHand(sevenCards);
      allHoldings.add((cards: holding, handResult: handResult));
    }
  }

  // Sort descending by strength
  allHoldings.sort((a, b) => b.handResult.strength - a.handResult.strength);

  // Assign ranks, handling ties
  final ranked = <RankedHolding>[];
  int currentRank = 1;
  for (int i = 0; i < allHoldings.length; i++) {
    if (i > 0 &&
        allHoldings[i].handResult.strength <
            allHoldings[i - 1].handResult.strength) {
      currentRank = i + 1;
    }
    ranked.add(RankedHolding(
      cards: allHoldings[i].cards,
      handResult: allHoldings[i].handResult,
      rank: currentRank,
    ));
  }

  return ranked;
}

/// Get top N holdings for a given board.
List<RankedHolding> getTopHoldings(List<Card> board, int n) {
  final all = rankAllHoldings(board);
  final distinctRanks = all.map((h) => h.rank).toSet().toList()
    ..sort((a, b) => a - b);
  final cutoffRank = distinctRanks[min(n - 1, distinctRanks.length - 1)];
  return all.where((h) => h.rank <= cutoffRank).toList();
}

/// Deal random board (5 cards).
List<Card> dealBoard() {
  final deck = shuffleDeck(buildDeck());
  return deck.sublist(0, 5);
}

/// Get hand name for a holding + board.
String getHandName(List<Card> board, List<Card> holding) {
  final sevenCards = [...board, ...holding];
  final result = evaluateBestHand(sevenCards);
  return result.description;
}

/// Generate a human-readable label for an equivalence class.
///
/// Rules:
/// - 1 member → specific cards "A♥K♥"
/// - Same two ranks, pair, all 6 combos → "AA"
/// - Same two ranks, pair, fewer combos → "AA (N combos)"
/// - Same two ranks, all suited (4 combos) → "AKs"
/// - Same two ranks, all offsuit (12 combos) → "AKo"
/// - Same two ranks, mixed → "AK (N combos)"
/// - Mixed ranks → descriptive label
String getEquivalenceLabel(List<List<Card>> members, List<Card> board) {
  if (members.length == 1) {
    final c1 = members[0][0];
    final c2 = members[0][1];
    return cardToString(c1) + cardToString(c2);
  }

  // Check if all members share the same two ranks
  final ranks0 = members.map((m) {
    final r = [m[0].rank, m[1].rank]..sort((a, b) => b - a);
    return r;
  }).toList();
  final firstRank = ranks0[0];
  final allSameRanks =
      ranks0.every((r) => r[0] == firstRank[0] && r[1] == firstRank[1]);

  if (allSameRanks) {
    final rankA = firstRank[0]; // higher rank
    final rankB = firstRank[1]; // lower rank
    final rA = rankNames[rankA];
    final rB = rankNames[rankB];

    if (rankA == rankB) {
      // Pair — max 6 combos (C(4,2))
      if (members.length == 6) {
        return '$rA$rB'; // e.g., "AA"
      }
      return '$rA$rB (${members.length} combos)';
    } else {
      // Two different ranks
      // Suited: both cards have same suit
      final allSuited = members.every((m) => m[0].suit == m[1].suit);
      // Offsuit: cards have different suits
      final allOffsuit = members.every((m) => m[0].suit != m[1].suit);

      // Max suited combos = 4 (one per suit), max offsuit = 12
      if (allSuited && members.length == 4) {
        return '$rA${rB}s'; // e.g., "AKs"
      }
      if (allSuited) {
        // Partial suited
        return '$rA${rB}s (${members.length})';
      }
      if (allOffsuit && members.length == 12) {
        return '$rA${rB}o'; // e.g., "AKo"
      }
      if (allOffsuit) {
        return '$rA${rB}o (${members.length})';
      }
      // Mixed
      return '$rA$rB (${members.length} combos)';
    }
  }

  // Mixed ranks — describe generically
  if (members.length <= 3) {
    // List them all
    return members
        .map((m) => cardToString(m[0]) + cardToString(m[1]))
        .join('/');
  }

  // Try to find if they're all flush combos or some pattern
  final allSuited = members.every((m) => m[0].suit == m[1].suit);
  if (allSuited) {
    return 'Flush combos (${members.length})';
  }

  return 'Mixed combos (${members.length})';
}

/// Group all holdings into equivalence classes.
/// Two holdings are equivalent iff they produce the same HandResult.strength.
/// Returns the first [targetCount] classes, ranked 1, 2, 3, ...
List<EquivalenceClass> groupIntoEquivalenceClasses(
    List<Card> board, int targetCount) {
  final allRanked = rankAllHoldings(board);

  // Group by strength — use a LinkedHashMap to preserve insertion order (descending strength)
  final strengthMap =
      <int, List<({List<Card> cards, HandResult handResult})>>{};
  for (final h in allRanked) {
    final s = h.handResult.strength;
    strengthMap.putIfAbsent(s, () => []);
    strengthMap[s]!.add((cards: h.cards, handResult: h.handResult));
  }

  // Build equivalence classes in order of descending strength
  final classes = <EquivalenceClass>[];
  int classRank = 1;

  for (final entry in strengthMap.entries) {
    if (classRank > targetCount) break;

    final group = entry.value;
    final members = group.map((g) => g.cards).toList();
    final representative = group[0];
    final label = getEquivalenceLabel(members, board);

    classes.add(EquivalenceClass(
      rank: classRank,
      strength: entry.key,
      label: label,
      description: representative.handResult.description,
      fiveCards: representative.handResult.fiveCards,
      members: members,
      memberCount: members.length,
    ));

    classRank++;
  }

  return classes;
}

/// Find which equivalence class a given holding belongs to.
/// Matches by evaluating the holding's strength and finding the matching class.
EquivalenceClass? findEquivalenceClassForHolding(
  List<Card> holding,
  List<Card> board,
  List<EquivalenceClass> classes,
) {
  final sevenCards = [...board, ...holding];
  final handResult = evaluateBestHand(sevenCards);
  final strength = handResult.strength;

  for (final c in classes) {
    if (c.strength == strength) return c;
  }
  return null;
}
