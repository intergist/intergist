// Poker Sharp — Scoring Engine
// Implements class-based scoring (2pts exact, 1pt partial, 0pts wrong/missing)

import 'dart:math';

import 'poker.dart';

class GroupedHoldingScore {
  final int userPosition;
  final ({List<Card> cards, HandResult handResult})? userHolding;
  final EquivalenceClass correctClass;
  final int points; // 0, 1, or 2
  final String status; // 'exact', 'partial', 'wrong', 'missing'

  const GroupedHoldingScore({
    required this.userPosition,
    required this.userHolding,
    required this.correctClass,
    required this.points,
    required this.status,
  });
}

class GroupedScoringResult {
  final int totalPoints;
  final int maxPoints;
  final int percentage;
  final List<GroupedHoldingScore> perPosition;
  final List<EquivalenceClass> missedClasses;
  final bool isSuitSensitive;

  const GroupedScoringResult({
    required this.totalPoints,
    required this.maxPoints,
    required this.percentage,
    required this.perPosition,
    required this.missedClasses,
    required this.isSuitSensitive,
  });
}

class BoardTexture {
  final bool isMonotone;
  final bool isTwoTone;
  final bool isRainbow;
  final bool isPaired;
  final bool isDoublePaired;
  final bool isTrips;
  final bool isQuads;
  final String connectivity; // 'connected', 'semi-connected', 'disconnected'
  final Card highestCard;
  final String description;

  const BoardTexture({
    required this.isMonotone,
    required this.isTwoTone,
    required this.isRainbow,
    required this.isPaired,
    required this.isDoublePaired,
    required this.isTrips,
    required this.isQuads,
    required this.connectivity,
    required this.highestCard,
    required this.description,
  });
}

String _holdingKey(List<Card> cards) {
  final keys = cards.map(cardKey).toList()..sort();
  return '${keys[0]}_${keys[1]}';
}

/// Group-aware scoring using equivalence classes.
/// Each user holding is evaluated against the equivalence class at that position.
/// - 2 points: user's holding belongs to the correct class at position i (exact)
/// - 1 point: user's holding is in top-N classes but not at position i (partial)
/// - 0 points: holding not in any top-N class, or slot empty (wrong/missing)
GroupedScoringResult scoreSubmissionGrouped(
  List<Card> board,
  List<({List<Card> cards})> userHoldings,
  int targetCount,
) {
  final classes = groupIntoEquivalenceClasses(board, targetCount);

  // Build a map from strength → class for quick lookup
  final strengthToClass = <int, EquivalenceClass>{};
  for (final cls in classes) {
    strengthToClass[cls.strength] = cls;
  }

  final perPosition = <GroupedHoldingScore>[];
  int totalPoints = 0;

  // Track which classes have been "hit" by the user
  final hitClassRanks = <int>{};

  for (int i = 0; i < targetCount; i++) {
    final correctClass =
        i < classes.length ? classes[i] : classes[classes.length - 1];

    if (i >= userHoldings.length) {
      // Missing slot
      perPosition.add(GroupedHoldingScore(
        userPosition: i,
        userHolding: null,
        correctClass: correctClass,
        points: 0,
        status: 'missing',
      ));
      continue;
    }

    final userCards = userHoldings[i].cards;
    final sevenCards = [...board, ...userCards];
    final userHandResult = evaluateBestHand(sevenCards);
    final userStrength = userHandResult.strength;

    // Find which class the user's holding belongs to
    final userClass = strengthToClass[userStrength];

    if (userClass == null) {
      // Not in any top-N class → 0 points
      perPosition.add(GroupedHoldingScore(
        userPosition: i,
        userHolding: (cards: userCards, handResult: userHandResult),
        correctClass: correctClass,
        points: 0,
        status: 'wrong',
      ));
    } else if (userClass.rank == correctClass.rank) {
      // Exact: user's holding is in the correct class for this position
      hitClassRanks.add(userClass.rank);
      perPosition.add(GroupedHoldingScore(
        userPosition: i,
        userHolding: (cards: userCards, handResult: userHandResult),
        correctClass: correctClass,
        points: 2,
        status: 'exact',
      ));
      totalPoints += 2;
    } else {
      // Partial: user's holding is in a top-N class, but not the right position
      hitClassRanks.add(userClass.rank);
      perPosition.add(GroupedHoldingScore(
        userPosition: i,
        userHolding: (cards: userCards, handResult: userHandResult),
        correctClass: correctClass,
        points: 1,
        status: 'partial',
      ));
      totalPoints += 1;
    }
  }

  // Missed classes: classes in top N not hit by any user holding
  final missedClasses =
      classes.where((c) => !hitClassRanks.contains(c.rank)).toList();

  final maxPoints = targetCount * 2;
  final suitSensitive = isBoardSuitSensitive(board);

  return GroupedScoringResult(
    totalPoints: totalPoints,
    maxPoints: maxPoints,
    percentage: (totalPoints / maxPoints * 100).round(),
    perPosition: perPosition,
    missedClasses: missedClasses,
    isSuitSensitive: suitSensitive,
  );
}

/// Speed rating per Section 5.4
/// Multipliers: 5 holdings → ×0.8, 10 → ×1.0, 15 → ×1.1, 20 → ×1.2
int getSpeedRating(int timeTakenMs, int targetCount) {
  const multipliers = {5: 0.8, 10: 1.0, 15: 1.1, 20: 1.2};
  final multiplier = multipliers[targetCount] ?? 1.0;
  final adjustedMs = timeTakenMs / multiplier;
  final msPerHolding = adjustedMs / targetCount;
  final secPerHolding = msPerHolding / 1000;

  if (secPerHolding <= 1.5) return 5;
  if (secPerHolding <= 3) return 4;
  if (secPerHolding <= 5) return 3;
  if (secPerHolding <= 8) return 2;
  return 1;
}

/// Determine if a board is suit-sensitive.
/// A board is suit-sensitive if there are 3+ cards of the same suit.
bool isBoardSuitSensitive(List<Card> board) {
  final suitCounts = [0, 0, 0, 0];
  for (final c in board) {
    suitCounts[c.suit]++;
  }
  if (suitCounts.reduce(max) >= 3) return true;
  return false;
}

/// Board texture analysis.
BoardTexture analyzeBoardTexture(List<Card> board) {
  // Suit analysis
  final suitCounts = [0, 0, 0, 0];
  for (final c in board) {
    suitCounts[c.suit]++;
  }
  final maxSuitCount = suitCounts.reduce(max);
  final uniqueSuits = suitCounts.where((c) => c > 0).length;

  final isMonotone = uniqueSuits == 1;
  final isTwoTone = maxSuitCount >= 3 && !isMonotone;
  final isRainbow = uniqueSuits >= 4;

  // Rank analysis
  final rankCounts = List<int>.filled(13, 0);
  for (final c in board) {
    rankCounts[c.rank]++;
  }
  final maxRankCount = rankCounts.reduce(max);
  final pairCount = rankCounts.where((c) => c == 2).length;

  final isPaired = pairCount >= 1;
  final isDoublePaired = pairCount >= 2;
  final isTrips = maxRankCount == 3;
  final isQuads = maxRankCount == 4;

  // Connectivity: check how many gaps between sorted ranks
  final uniqueRanks = board.map((c) => c.rank).toSet().toList()..sort();
  int connectedCount = 0;
  for (int i = 1; i < uniqueRanks.length; i++) {
    if (uniqueRanks[i] - uniqueRanks[i - 1] <= 2) {
      connectedCount++;
    }
  }
  // Also check ace-low connections
  if (uniqueRanks.contains(12) && uniqueRanks.contains(0)) {
    connectedCount++;
  }

  final String connectivity;
  if (connectedCount >= uniqueRanks.length - 1) {
    connectivity = 'connected';
  } else if (connectedCount >= (uniqueRanks.length / 2).floor()) {
    connectivity = 'semi-connected';
  } else {
    connectivity = 'disconnected';
  }

  final highestCard =
      board.reduce((best, c) => c.rank > best.rank ? c : best);

  // Build description
  final parts = <String>[];
  if (isMonotone) {
    final suitIdx = suitCounts.indexWhere((c) => c == 5);
    parts.add('Monotone (all ${suitSymbols[suitIdx]})');
    parts.add('flushes dominate');
  } else if (isTwoTone) {
    parts.add('Two-tone board');
    parts.add('flush draws possible');
  } else if (isRainbow) {
    parts.add('Rainbow board');
    parts.add('no flush possible');
  }

  if (isQuads) {
    parts.add('four of a kind on board');
  } else if (isTrips) {
    parts.add('trips on board — full houses and quads likely');
  } else if (isDoublePaired) {
    parts.add('double-paired — full houses common');
  } else if (isPaired) {
    parts.add('paired board — full house possible');
  }

  if (connectivity == 'connected') {
    parts.add('highly connected — straight possibilities');
  } else if (connectivity == 'semi-connected') {
    parts.add('semi-connected');
  } else {
    parts.add('disconnected — fewer straights');
  }

  parts.add('${rankNames[highestCard.rank]}-high');

  return BoardTexture(
    isMonotone: isMonotone,
    isTwoTone: isTwoTone,
    isRainbow: isRainbow,
    isPaired: isPaired,
    isDoublePaired: isDoublePaired,
    isTrips: isTrips,
    isQuads: isQuads,
    connectivity: connectivity,
    highestCard: highestCard,
    description: '${parts.join('. ')}.',
  );
}
