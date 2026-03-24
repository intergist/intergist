// Poker Sharp — Scoring Engine (v2.0 spec)
// Implements Section 5.2, 5.3, 5.4

import type { Card, RankedHolding, HandResult } from './poker';
import { cardKey, rankAllHoldings, RANK_NAMES, SUIT_SYMBOLS, cardToString, groupIntoEquivalenceClasses, evaluateBestHand } from './poker';
import type { EquivalenceClass } from './poker';

export type { EquivalenceClass };

export interface HoldingScore {
  userPosition: number; // 0-based index in user's list
  userHolding: { cards: [Card, Card]; handResult: HandResult } | null;
  correctPosition: number; // 0-based index in correct list
  correctHolding: RankedHolding;
  points: number; // 0, 1, or 2
  status: 'exact' | 'partial' | 'wrong' | 'missing';
}

export interface ScoringResult {
  totalPoints: number;
  maxPoints: number;
  percentage: number;
  perHolding: HoldingScore[];
  missedHoldings: RankedHolding[]; // correct holdings not in user's list
}

export interface GroupedHoldingScore {
  userPosition: number;
  userHolding: { cards: [Card, Card]; handResult: HandResult } | null;
  correctClass: EquivalenceClass;
  points: number;        // 0, 1, or 2
  status: 'exact' | 'partial' | 'wrong' | 'missing';
}

export interface GroupedScoringResult {
  totalPoints: number;
  maxPoints: number;
  percentage: number;
  perPosition: GroupedHoldingScore[];
  missedClasses: EquivalenceClass[];
  isSuitSensitive: boolean;  // true if board has flush/straight-flush possibilities that split equivalence
}

function holdingKey(cards: [Card, Card]): string {
  const keys = cards.map(cardKey).sort((a, b) => a - b);
  return `${keys[0]}_${keys[1]}`;
}

/**
 * Score user's submission per v2.0 spec:
 * - 2 points: correct holding at correct rank, OR tied equivalent at that position
 * - 1 point: correct holding present but at wrong rank
 * - 0 points: holding not in top N, or missing slot
 *
 * Tie handling (v2.0 Section 5.3):
 * Tied holdings are interchangeable. Full credit (2 pts) if placed at ANY
 * position that a tied group occupies in the correct ranking.
 */
export function scoreSubmission(
  board: Card[],
  userHoldings: { cards: [Card, Card] }[],
  targetCount: number
): ScoringResult {
  const allRanked = rankAllHoldings(board);

  // Get top N holdings (by distinct rank, not by index)
  // We need exactly targetCount positions worth of holdings
  const topN: RankedHolding[] = [];
  const distinctRanks: number[] = [];
  for (const h of allRanked) {
    if (!distinctRanks.includes(h.rank)) {
      distinctRanks.push(h.rank);
    }
    if (distinctRanks.length <= targetCount) {
      topN.push(h);
    } else {
      break;
    }
  }

  // Build a lookup: holdingKey -> RankedHolding (from all 1081)
  const allMap = new Map<string, RankedHolding>();
  for (const h of allRanked) {
    allMap.set(holdingKey(h.cards), h);
  }

  // Build tie groups: rank -> set of strengths at that rank
  // For the top N, find which positions share the same strength
  // A "tie group" is a set of positions in the correct ranking that share identical strength
  const strengthToPositions = new Map<number, number[]>();
  for (let i = 0; i < Math.min(targetCount, topN.length); i++) {
    const strength = topN[i].handResult.strength;
    if (!strengthToPositions.has(strength)) {
      strengthToPositions.set(strength, []);
    }
    strengthToPositions.get(strength)!.push(i);
  }

  // Set of holdingKeys that are in the top N
  const topNKeys = new Set<string>();
  for (const h of topN.slice(0, targetCount)) {
    topNKeys.add(holdingKey(h.cards));
  }

  // Also build strength -> set of holdingKeys in topN with that strength
  const strengthToKeys = new Map<number, Set<string>>();
  for (let i = 0; i < Math.min(targetCount, topN.length); i++) {
    const s = topN[i].handResult.strength;
    if (!strengthToKeys.has(s)) {
      strengthToKeys.set(s, new Set());
    }
    strengthToKeys.get(s)!.add(holdingKey(topN[i].cards));
  }

  const perHolding: HoldingScore[] = [];
  let totalPoints = 0;
  const userKeys = new Set<string>();

  for (let i = 0; i < targetCount; i++) {
    const correctHolding = i < topN.length ? topN[i] : topN[topN.length - 1];

    if (i >= userHoldings.length) {
      // Missing slot
      perHolding.push({
        userPosition: i,
        userHolding: null,
        correctPosition: i,
        correctHolding,
        points: 0,
        status: 'missing',
      });
      continue;
    }

    const uKey = holdingKey(userHoldings[i].cards as [Card, Card]);
    userKeys.add(uKey);
    const userRanked = allMap.get(uKey);

    if (!userRanked) {
      // Should not happen but handle it
      perHolding.push({
        userPosition: i,
        userHolding: null,
        correctPosition: i,
        correctHolding,
        points: 0,
        status: 'wrong',
      });
      continue;
    }

    // Check if this holding is in the top N
    const isInTopN = topNKeys.has(uKey);

    if (!isInTopN) {
      // Holding not in top N → 0 points
      perHolding.push({
        userPosition: i,
        userHolding: { cards: userRanked.cards, handResult: userRanked.handResult },
        correctPosition: i,
        correctHolding,
        points: 0,
        status: 'wrong',
      });
    } else {
      // Holding IS in the top N
      const userStrength = userRanked.handResult.strength;
      const correctStrength = correctHolding.handResult.strength;

      // Check tie: if user's holding strength matches the correct holding's strength
      // at this position, it's an exact match (tied holdings are interchangeable)
      if (userStrength === correctStrength) {
        // Exact match or tied equivalent at this position → 2 points
        perHolding.push({
          userPosition: i,
          userHolding: { cards: userRanked.cards, handResult: userRanked.handResult },
          correctPosition: i,
          correctHolding,
          points: 2,
          status: 'exact',
        });
        totalPoints += 2;
      } else {
        // Check if user's holding is tied with any holding at this position
        // i.e., does the user's holding strength match any position in the correct ranking
        // that overlaps with position i's tie group?
        const positionsForUserStrength = strengthToPositions.get(userStrength);
        if (positionsForUserStrength && positionsForUserStrength.includes(i)) {
          // User's holding is in a tie group that includes this position
          perHolding.push({
            userPosition: i,
            userHolding: { cards: userRanked.cards, handResult: userRanked.handResult },
            correctPosition: i,
            correctHolding,
            points: 2,
            status: 'exact',
          });
          totalPoints += 2;
        } else {
          // Correct holding but wrong position → 1 point
          perHolding.push({
            userPosition: i,
            userHolding: { cards: userRanked.cards, handResult: userRanked.handResult },
            correctPosition: i,
            correctHolding,
            points: 1,
            status: 'partial',
          });
          totalPoints += 1;
        }
      }
    }
  }

  // Determine missed holdings: correct top-N holdings not submitted by user
  const missedHoldings: RankedHolding[] = [];
  for (let i = 0; i < Math.min(targetCount, topN.length); i++) {
    const cKey = holdingKey(topN[i].cards);
    if (!userKeys.has(cKey)) {
      missedHoldings.push(topN[i]);
    }
  }

  const maxPoints = targetCount * 2;
  return {
    totalPoints,
    maxPoints,
    percentage: Math.round((totalPoints / maxPoints) * 100),
    perHolding,
    missedHoldings,
  };
}

/**
 * Determine if a board is suit-sensitive.
 * A board is suit-sensitive if there are 3+ cards of the same suit (flush possible)
 * OR if there are cards that could form a straight-flush.
 * More precisely: if two holdings that would otherwise be equivalent (same ranks)
 * end up in different classes due to suit interactions.
 */
function isBoardSuitSensitive(board: Card[]): boolean {
  // Check for 3+ of same suit (flush draw possible from hole cards)
  const suitCounts = [0, 0, 0, 0];
  board.forEach(c => suitCounts[c.suit]++);
  // If 3+ of a suit on board, a suited holding can complete a flush
  // while an offsuit holding cannot — creating different equivalence classes
  if (Math.max(...suitCounts) >= 3) return true;
  return false;
}

/**
 * Group-aware scoring using equivalence classes.
 * Each user holding is evaluated against the equivalence class at that position.
 * - 2 points: user's holding belongs to the correct class at position i (exact)
 * - 1 point: user's holding is in top-N classes but not at position i (partial)
 * - 0 points: holding not in any top-N class, or slot empty (wrong/missing)
 */
export function scoreSubmissionGrouped(
  board: Card[],
  userHoldings: { cards: [Card, Card] }[],
  targetCount: number
): GroupedScoringResult {
  const classes = groupIntoEquivalenceClasses(board, targetCount);

  // Build a map from strength → class for quick lookup
  const strengthToClass = new Map<number, EquivalenceClass>();
  for (const cls of classes) {
    strengthToClass.set(cls.strength, cls);
  }

  const perPosition: GroupedHoldingScore[] = [];
  let totalPoints = 0;

  // Track which classes have been "hit" by the user (for missed classes)
  const hitClassRanks = new Set<number>();

  for (let i = 0; i < targetCount; i++) {
    const correctClass = i < classes.length ? classes[i] : classes[classes.length - 1];

    if (i >= userHoldings.length) {
      // Missing slot
      perPosition.push({
        userPosition: i,
        userHolding: null,
        correctClass,
        points: 0,
        status: 'missing',
      });
      continue;
    }

    const userCards = userHoldings[i].cards as [Card, Card];
    const sevenCards = [...board, ...userCards];
    const userHandResult = evaluateBestHand(sevenCards);
    const userStrength = userHandResult.strength;

    // Find which class the user's holding belongs to
    const userClass = strengthToClass.get(userStrength);

    if (!userClass) {
      // Not in any top-N class → 0 points
      perPosition.push({
        userPosition: i,
        userHolding: { cards: userCards, handResult: userHandResult },
        correctClass,
        points: 0,
        status: 'wrong',
      });
    } else if (userClass.rank === correctClass.rank) {
      // Exact: user's holding is in the correct class for this position
      hitClassRanks.add(userClass.rank);
      perPosition.push({
        userPosition: i,
        userHolding: { cards: userCards, handResult: userHandResult },
        correctClass,
        points: 2,
        status: 'exact',
      });
      totalPoints += 2;
    } else {
      // Partial: user's holding is in a top-N class, but not the right position
      hitClassRanks.add(userClass.rank);
      perPosition.push({
        userPosition: i,
        userHolding: { cards: userCards, handResult: userHandResult },
        correctClass,
        points: 1,
        status: 'partial',
      });
      totalPoints += 1;
    }
  }

  // Missed classes: classes in top N not hit by any user holding
  const missedClasses: EquivalenceClass[] = classes.filter(c => !hitClassRanks.has(c.rank));

  const maxPoints = targetCount * 2;
  const isSuitSensitive = isBoardSuitSensitive(board);

  return {
    totalPoints,
    maxPoints,
    percentage: Math.round((totalPoints / maxPoints) * 100),
    perPosition,
    missedClasses,
    isSuitSensitive,
  };
}

/**
 * Speed rating per Section 5.4
 * Multipliers: 5 holdings → ×0.8, 10 → ×1.0, 15 → ×1.1, 20 → ×1.2
 */
export function getSpeedRating(timeTakenMs: number, targetCount: number): number {
  const multipliers: Record<number, number> = { 5: 0.8, 10: 1.0, 15: 1.1, 20: 1.2 };
  const multiplier = multipliers[targetCount] || 1.0;
  const adjustedMs = timeTakenMs / multiplier;
  const msPerHolding = adjustedMs / targetCount;
  const secPerHolding = msPerHolding / 1000;

  if (secPerHolding <= 1.5) return 5;
  if (secPerHolding <= 3) return 4;
  if (secPerHolding <= 5) return 3;
  if (secPerHolding <= 8) return 2;
  return 1;
}

/**
 * Board texture analysis per Section 7.1
 */
export interface BoardTexture {
  isMonotone: boolean;
  isTwoTone: boolean;
  isRainbow: boolean;
  isPaired: boolean;
  isDoublePaired: boolean;
  isTrips: boolean;
  isQuads: boolean;
  connectivity: 'connected' | 'semi-connected' | 'disconnected';
  highestCard: Card;
  description: string;
}

export function analyzeBoardTexture(board: Card[]): BoardTexture {
  // Suit analysis
  const suitCounts = [0, 0, 0, 0];
  board.forEach(c => suitCounts[c.suit]++);
  const maxSuitCount = Math.max(...suitCounts);
  const uniqueSuits = suitCounts.filter(c => c > 0).length;

  const isMonotone = uniqueSuits === 1;
  const isTwoTone = maxSuitCount >= 3 && !isMonotone;
  const isRainbow = uniqueSuits >= 4;

  // Rank analysis
  const rankCounts = new Array(13).fill(0);
  board.forEach(c => rankCounts[c.rank]++);
  const maxRankCount = Math.max(...rankCounts);
  const pairCount = rankCounts.filter(c => c === 2).length;

  const isPaired = pairCount >= 1;
  const isDoublePaired = pairCount >= 2;
  const isTrips = maxRankCount === 3;
  const isQuads = maxRankCount === 4;

  // Connectivity: check how many gaps between sorted ranks
  const uniqueRanks = [...new Set(board.map(c => c.rank))].sort((a, b) => a - b);
  let connectedCount = 0;
  for (let i = 1; i < uniqueRanks.length; i++) {
    if (uniqueRanks[i] - uniqueRanks[i - 1] <= 2) {
      connectedCount++;
    }
  }
  // Also check ace-low connections
  if (uniqueRanks.includes(12) && uniqueRanks.includes(0)) {
    connectedCount++;
  }

  const connectivity: BoardTexture['connectivity'] =
    connectedCount >= uniqueRanks.length - 1 ? 'connected' :
      connectedCount >= Math.floor(uniqueRanks.length / 2) ? 'semi-connected' :
        'disconnected';

  const highestCard = board.reduce((best, c) => c.rank > best.rank ? c : best, board[0]);

  // Build description
  const parts: string[] = [];
  if (isMonotone) {
    const suitIdx = suitCounts.findIndex(c => c === 5);
    parts.push(`Monotone (all ${SUIT_SYMBOLS[suitIdx]})`);
    parts.push('flushes dominate');
  } else if (isTwoTone) {
    parts.push('Two-tone board');
    parts.push('flush draws possible');
  } else if (isRainbow) {
    parts.push('Rainbow board');
    parts.push('no flush possible');
  }

  if (isQuads) {
    parts.push('four of a kind on board');
  } else if (isTrips) {
    parts.push('trips on board — full houses and quads likely');
  } else if (isDoublePaired) {
    parts.push('double-paired — full houses common');
  } else if (isPaired) {
    parts.push('paired board — full house possible');
  }

  if (connectivity === 'connected') {
    parts.push('highly connected — straight possibilities');
  } else if (connectivity === 'semi-connected') {
    parts.push('semi-connected');
  } else {
    parts.push('disconnected — fewer straights');
  }

  parts.push(`${RANK_NAMES[highestCard.rank]}-high`);

  return {
    isMonotone,
    isTwoTone,
    isRainbow,
    isPaired,
    isDoublePaired,
    isTrips,
    isQuads,
    connectivity,
    highestCard,
    description: parts.join('. ') + '.',
  };
}
