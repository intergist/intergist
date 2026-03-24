// Poker Sharp — Hand Evaluator Engine
// Cards: rank 0=2, 1=3, ..., 8=T, 9=J, 10=Q, 11=K, 12=A
// Suits: 0=spade, 1=heart, 2=diamond, 3=club

export interface Card {
  rank: number; // 0-12 where 0=2, 12=Ace
  suit: number; // 0=spade, 1=heart, 2=diamond, 3=club
}

export interface HandResult {
  category: number; // 0=HighCard ... 9=RoyalFlush
  categoryName: string;
  description: string;
  fiveCards: Card[];
  strength: number; // comparable numeric strength
}

export interface RankedHolding {
  cards: [Card, Card];
  handResult: HandResult;
  rank: number; // 1-based position
}

export interface EquivalenceClass {
  rank: number;           // 1-based position (one per class)
  strength: number;       // shared HandResult.strength
  label: string;          // human-readable label (e.g., "AA", "AKs", "A♥K♥")
  description: string;    // hand description (e.g., "Three of a Kind, Aces")
  fiveCards: Card[];      // representative best 5 cards
  members: [Card, Card][]; // all specific holdings in this class
  memberCount: number;
}

export const RANK_NAMES = ['2','3','4','5','6','7','8','9','T','J','Q','K','A'];
export const SUIT_SYMBOLS = ['♠','♥','♦','♣'];
export const SUIT_NAMES = ['spades','hearts','diamonds','clubs'];

export const HAND_CATEGORIES = [
  'High Card',      // 0
  'One Pair',       // 1
  'Two Pair',       // 2
  'Three of a Kind',// 3
  'Straight',       // 4
  'Flush',          // 5
  'Full House',     // 6
  'Four of a Kind', // 7
  'Straight Flush', // 8
  'Royal Flush',    // 9
];

export function cardToString(card: Card): string {
  return RANK_NAMES[card.rank] + SUIT_SYMBOLS[card.suit];
}

export function cardsEqual(a: Card, b: Card): boolean {
  return a.rank === b.rank && a.suit === b.suit;
}

export function cardKey(card: Card): number {
  return card.suit * 13 + card.rank;
}

// Build a full 52-card deck
export function buildDeck(): Card[] {
  const deck: Card[] = [];
  for (let suit = 0; suit < 4; suit++) {
    for (let rank = 0; rank < 13; rank++) {
      deck.push({ rank, suit });
    }
  }
  return deck;
}

// Shuffle deck using Fisher-Yates
export function shuffleDeck(deck: Card[]): Card[] {
  const arr = [...deck];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

// Generate all C(n,k) combinations from an array
function combinations<T>(arr: T[], k: number): T[][] {
  const result: T[][] = [];
  function backtrack(start: number, current: T[]) {
    if (current.length === k) {
      result.push([...current]);
      return;
    }
    for (let i = start; i < arr.length; i++) {
      current.push(arr[i]);
      backtrack(i + 1, current);
      current.pop();
    }
  }
  backtrack(0, []);
  return result;
}

// Evaluate a 5-card hand and return a numeric strength
// Higher is better.
// Encoding: category * 10^10 + v1 * 10^8 + v2 * 10^6 + v3 * 10^4 + v4 * 10^2 + v5
function evaluate5(cards: Card[]): { category: number; strength: number; cards: Card[] } {
  const ranks = cards.map(c => c.rank).sort((a, b) => b - a); // descending
  const suits = cards.map(c => c.suit);

  // Check flush
  const isFlush = suits.every(s => s === suits[0]);

  // Check straight
  let isStraight = false;
  let straightHigh = -1;
  
  // Normal straight check
  const uniqueRanks = [...new Set(ranks)].sort((a, b) => b - a);
  if (uniqueRanks.length === 5) {
    if (uniqueRanks[0] - uniqueRanks[4] === 4) {
      isStraight = true;
      straightHigh = uniqueRanks[0];
    }
    // Ace-low straight (A-2-3-4-5) → wheel
    if (uniqueRanks[0] === 12 && uniqueRanks[1] === 3 && uniqueRanks[2] === 2 && uniqueRanks[3] === 1 && uniqueRanks[4] === 0) {
      isStraight = true;
      straightHigh = 3; // 5-high straight, highest card in the straight context is 5 (rank 3)
    }
  }

  // Count rank frequencies
  const freq: Map<number, number> = new Map();
  for (const r of ranks) {
    freq.set(r, (freq.get(r) || 0) + 1);
  }
  
  const freqEntries = [...freq.entries()].sort((a, b) => {
    // Sort by frequency desc, then by rank desc
    if (b[1] !== a[1]) return b[1] - a[1];
    return b[0] - a[0];
  });

  const encode = (cat: number, values: number[]): number => {
    // Pad values to 5 entries
    while (values.length < 5) values.push(0);
    return cat * 1e10 + values[0] * 1e8 + values[1] * 1e6 + values[2] * 1e4 + values[3] * 1e2 + values[4];
  };

  // Straight Flush / Royal Flush
  if (isFlush && isStraight) {
    if (straightHigh === 12) {
      // Royal Flush: A-K-Q-J-T suited
      return { category: 9, strength: encode(9, [straightHigh]), cards };
    }
    return { category: 8, strength: encode(8, [straightHigh]), cards };
  }

  // Four of a Kind
  if (freqEntries[0][1] === 4) {
    const quad = freqEntries[0][0];
    const kicker = freqEntries[1][0];
    return { category: 7, strength: encode(7, [quad, kicker]), cards };
  }

  // Full House
  if (freqEntries[0][1] === 3 && freqEntries[1][1] === 2) {
    const trips = freqEntries[0][0];
    const pair = freqEntries[1][0];
    return { category: 6, strength: encode(6, [trips, pair]), cards };
  }

  // Flush
  if (isFlush) {
    return { category: 5, strength: encode(5, ranks), cards };
  }

  // Straight
  if (isStraight) {
    return { category: 4, strength: encode(4, [straightHigh]), cards };
  }

  // Three of a Kind
  if (freqEntries[0][1] === 3) {
    const trips = freqEntries[0][0];
    const kickers = freqEntries.slice(1).map(e => e[0]).sort((a, b) => b - a);
    return { category: 3, strength: encode(3, [trips, ...kickers]), cards };
  }

  // Two Pair
  if (freqEntries[0][1] === 2 && freqEntries[1][1] === 2) {
    const highPair = Math.max(freqEntries[0][0], freqEntries[1][0]);
    const lowPair = Math.min(freqEntries[0][0], freqEntries[1][0]);
    const kicker = freqEntries[2][0];
    return { category: 2, strength: encode(2, [highPair, lowPair, kicker]), cards };
  }

  // One Pair
  if (freqEntries[0][1] === 2) {
    const pair = freqEntries[0][0];
    const kickers = freqEntries.slice(1).map(e => e[0]).sort((a, b) => b - a);
    return { category: 1, strength: encode(1, [pair, ...kickers]), cards };
  }

  // High Card
  return { category: 0, strength: encode(0, ranks), cards };
}

// Given 7 cards (5 board + 2 hole), find the best 5-card hand
export function evaluateBestHand(sevenCards: Card[]): HandResult {
  const combos = combinations(sevenCards, 5);
  let best: { category: number; strength: number; cards: Card[] } | null = null;

  for (const combo of combos) {
    const result = evaluate5(combo);
    if (!best || result.strength > best.strength) {
      best = result;
    }
  }

  const cat = best!.category;
  const fiveCards = best!.cards.sort((a, b) => b.rank - a.rank);

  return {
    category: cat,
    categoryName: HAND_CATEGORIES[cat],
    description: describeHand(cat, fiveCards),
    fiveCards,
    strength: best!.strength,
  };
}

function describeHand(category: number, cards: Card[]): string {
  const sorted = [...cards].sort((a, b) => b.rank - a.rank);
  
  switch (category) {
    case 9: return 'Royal Flush';
    case 8: return `Straight Flush, ${RANK_NAMES[sorted[0].rank]}-high`;
    case 7: {
      const freq = new Map<number, number>();
      sorted.forEach(c => freq.set(c.rank, (freq.get(c.rank) || 0) + 1));
      const quad = [...freq.entries()].find(([, v]) => v === 4)![0];
      return `Four of a Kind, ${RANK_NAMES[quad]}s`;
    }
    case 6: {
      const freq = new Map<number, number>();
      sorted.forEach(c => freq.set(c.rank, (freq.get(c.rank) || 0) + 1));
      const trips = [...freq.entries()].find(([, v]) => v === 3)![0];
      const pair = [...freq.entries()].find(([, v]) => v === 2)![0];
      return `Full House, ${RANK_NAMES[trips]}s full of ${RANK_NAMES[pair]}s`;
    }
    case 5: return `Flush, ${RANK_NAMES[sorted[0].rank]}-high`;
    case 4: {
      // Handle wheel
      const ranks = sorted.map(c => c.rank);
      if (ranks.includes(12) && ranks.includes(0) && ranks.includes(1) && ranks.includes(2) && ranks.includes(3)) {
        return 'Straight, 5-high';
      }
      return `Straight, ${RANK_NAMES[sorted[0].rank]}-high`;
    }
    case 3: {
      const freq = new Map<number, number>();
      sorted.forEach(c => freq.set(c.rank, (freq.get(c.rank) || 0) + 1));
      const trips = [...freq.entries()].find(([, v]) => v === 3)![0];
      return `Three of a Kind, ${RANK_NAMES[trips]}s`;
    }
    case 2: {
      const freq = new Map<number, number>();
      sorted.forEach(c => freq.set(c.rank, (freq.get(c.rank) || 0) + 1));
      const pairs = [...freq.entries()].filter(([, v]) => v === 2).map(([k]) => k).sort((a, b) => b - a);
      return `Two Pair, ${RANK_NAMES[pairs[0]]}s and ${RANK_NAMES[pairs[1]]}s`;
    }
    case 1: {
      const freq = new Map<number, number>();
      sorted.forEach(c => freq.set(c.rank, (freq.get(c.rank) || 0) + 1));
      const pair = [...freq.entries()].find(([, v]) => v === 2)![0];
      return `Pair of ${RANK_NAMES[pair]}s`;
    }
    case 0: return `${RANK_NAMES[sorted[0].rank]}-high`;
    default: return 'Unknown';
  }
}

// Evaluate all 1081 possible holdings for a given board, rank them
export function rankAllHoldings(board: Card[]): RankedHolding[] {
  const boardSet = new Set(board.map(cardKey));
  const remaining = buildDeck().filter(c => !boardSet.has(cardKey(c)));
  
  // Generate all C(47,2) = 1081 combinations
  const allHoldings: { cards: [Card, Card]; handResult: HandResult }[] = [];
  
  for (let i = 0; i < remaining.length; i++) {
    for (let j = i + 1; j < remaining.length; j++) {
      const holding: [Card, Card] = [remaining[i], remaining[j]];
      const sevenCards = [...board, ...holding];
      const handResult = evaluateBestHand(sevenCards);
      allHoldings.push({ cards: holding, handResult });
    }
  }

  // Sort descending by strength
  allHoldings.sort((a, b) => b.handResult.strength - a.handResult.strength);

  // Assign ranks, handling ties
  const ranked: RankedHolding[] = [];
  let currentRank = 1;
  for (let i = 0; i < allHoldings.length; i++) {
    if (i > 0 && allHoldings[i].handResult.strength < allHoldings[i - 1].handResult.strength) {
      currentRank = i + 1;
    }
    ranked.push({
      ...allHoldings[i],
      rank: currentRank,
    });
  }

  return ranked;
}

// Get top N holdings for a given board
export function getTopHoldings(board: Card[], n: number): RankedHolding[] {
  const all = rankAllHoldings(board);
  // Find the cutoff: include all tied with the Nth distinct rank
  const distinctRanks = [...new Set(all.map(h => h.rank))].sort((a, b) => a - b);
  const cutoffRank = distinctRanks[Math.min(n - 1, distinctRanks.length - 1)];
  return all.filter(h => h.rank <= cutoffRank);
}

// Score a user's submitted holdings against the correct rankings
export interface ScoringResult {
  totalPoints: number;
  maxPoints: number;
  percentage: number;
  perHolding: {
    userHolding: RankedHolding | null;
    correctHolding: RankedHolding;
    points: number; // 0, 1, or 2
    status: 'exact' | 'close' | 'wrong' | 'missing';
    positionDiff: number;
  }[];
}

export function scoreSubmission(
  board: Card[],
  userHoldings: { cards: [Card, Card] }[],
  targetCount: number
): ScoringResult {
  const allRanked = rankAllHoldings(board);
  const topN = allRanked.slice(0, targetCount);

  // Build a map from holding key to rank info
  const holdingKeyFn = (cards: [Card, Card]) => {
    const keys = cards.map(cardKey).sort((a, b) => a - b);
    return `${keys[0]}_${keys[1]}`;
  };

  const correctMap = new Map<string, RankedHolding>();
  for (const h of allRanked) {
    correctMap.set(holdingKeyFn(h.cards), h);
  }

  const perHolding: ScoringResult['perHolding'] = [];
  let totalPoints = 0;

  for (let i = 0; i < targetCount; i++) {
    const correctHolding = topN[i];
    
    if (i >= userHoldings.length) {
      // Missing holding
      perHolding.push({
        userHolding: null,
        correctHolding,
        points: 0,
        status: 'missing',
        positionDiff: targetCount,
      });
      continue;
    }

    const userKey = holdingKeyFn(userHoldings[i].cards as [Card, Card]);
    const userInCorrect = correctMap.get(userKey);

    if (!userInCorrect || userInCorrect.rank > targetCount) {
      // User submitted a holding that's not in the top N
      perHolding.push({
        userHolding: userInCorrect ? { ...userInCorrect, rank: userInCorrect.rank } : null,
        correctHolding,
        points: 0,
        status: 'wrong',
        positionDiff: targetCount,
      });
    } else {
      // Holding is correct (in the top N)
      const userRank = userInCorrect.rank;
      const correctRank = correctHolding.rank;
      const diff = Math.abs(userRank - correctRank);

      // Per spec issue fix #5: tied holdings at correct rank get full 2 points
      if (userInCorrect.handResult.strength === correctHolding.handResult.strength) {
        // Same hand strength = tied = exact match
        perHolding.push({
          userHolding: userInCorrect,
          correctHolding,
          points: 2,
          status: 'exact',
          positionDiff: 0,
        });
        totalPoints += 2;
      } else if (diff === 0) {
        // Exact position match
        perHolding.push({
          userHolding: userInCorrect,
          correctHolding,
          points: 2,
          status: 'exact',
          positionDiff: 0,
        });
        totalPoints += 2;
      } else if (diff <= 2) {
        perHolding.push({
          userHolding: userInCorrect,
          correctHolding,
          points: 1,
          status: 'close',
          positionDiff: diff,
        });
        totalPoints += 1;
      } else {
        perHolding.push({
          userHolding: userInCorrect,
          correctHolding,
          points: 1,
          status: 'wrong',
          positionDiff: diff,
        });
        totalPoints += 1;
      }
    }
  }

  return {
    totalPoints,
    maxPoints: targetCount * 2,
    percentage: Math.round((totalPoints / (targetCount * 2)) * 100),
    perHolding,
  };
}

// Deal random board
export function dealBoard(): Card[] {
  const deck = shuffleDeck(buildDeck());
  return deck.slice(0, 5);
}

// Get hand name for a holding + board
export function getHandName(board: Card[], holding: [Card, Card]): string {
  const sevenCards = [...board, ...holding];
  const result = evaluateBestHand(sevenCards);
  return result.description;
}

/**
 * Generate a human-readable label for an equivalence class.
 * 
 * Rules:
 * - 1 member → specific cards "A♥K♥"
 * - Same two ranks, pair, all 6 combos → "AA"
 * - Same two ranks, pair, fewer combos → "AA (N combos)"
 * - Same two ranks, all suited (2 combos) → "AKs"
 * - Same two ranks, all offsuit (12 combos) → "AKo"
 * - Same two ranks, mixed → "AK (N combos)"
 * - Mixed ranks → descriptive label
 */
export function getEquivalenceLabel(members: [Card, Card][], _board: Card[]): string {
  if (members.length === 1) {
    const [c1, c2] = members[0];
    return cardToString(c1) + cardToString(c2);
  }

  // Check if all members share the same two ranks
  const ranks0 = members.map(m => [m[0].rank, m[1].rank].sort((a, b) => b - a));
  const firstRank = ranks0[0];
  const allSameRanks = ranks0.every(r => r[0] === firstRank[0] && r[1] === firstRank[1]);

  if (allSameRanks) {
    const rankA = firstRank[0]; // higher rank
    const rankB = firstRank[1]; // lower rank
    const rA = RANK_NAMES[rankA];
    const rB = RANK_NAMES[rankB];

    if (rankA === rankB) {
      // Pair — max 6 combos (C(4,2))
      if (members.length === 6) {
        return rA + rB; // e.g., "AA"
      }
      return `${rA}${rB} (${members.length} combos)`;
    } else {
      // Two different ranks
      // Suited: both cards have same suit
      const allSuited = members.every(([c1, c2]) => c1.suit === c2.suit);
      // Offsuit: cards have different suits
      const allOffsuit = members.every(([c1, c2]) => c1.suit !== c2.suit);

      // Max suited combos = 4 (one per suit), max offsuit = 12
      if (allSuited && members.length === 4) {
        return `${rA}${rB}s`; // e.g., "AKs"
      }
      if (allSuited) {
        // Partial suited
        return `${rA}${rB}s (${members.length})`;
      }
      if (allOffsuit && members.length === 12) {
        return `${rA}${rB}o`; // e.g., "AKo"
      }
      if (allOffsuit) {
        return `${rA}${rB}o (${members.length})`;
      }
      // Mixed
      return `${rA}${rB} (${members.length} combos)`;
    }
  }

  // Mixed ranks — describe generically
  if (members.length <= 3) {
    // List them all
    return members.map(([c1, c2]) => cardToString(c1) + cardToString(c2)).join('/');
  }

  // Try to find if they're all flush combos or some pattern
  const allSuited = members.every(([c1, c2]) => c1.suit === c2.suit);
  if (allSuited) {
    return `Flush combos (${members.length})`;
  }

  return `Mixed combos (${members.length})`;
}

/**
 * Group all holdings into equivalence classes.
 * Two holdings are equivalent iff they produce the same HandResult.strength.
 * Returns the first targetCount classes, ranked 1, 2, 3, ...
 */
export function groupIntoEquivalenceClasses(board: Card[], targetCount: number): EquivalenceClass[] {
  const allRanked = rankAllHoldings(board);

  // Group by strength — use a Map to preserve insertion order (descending strength)
  const strengthMap = new Map<number, { cards: [Card, Card]; handResult: typeof allRanked[0]['handResult'] }[]>();
  for (const h of allRanked) {
    const s = h.handResult.strength;
    if (!strengthMap.has(s)) {
      strengthMap.set(s, []);
    }
    strengthMap.get(s)!.push({ cards: h.cards, handResult: h.handResult });
  }

  // Build equivalence classes in order of descending strength
  const classes: EquivalenceClass[] = [];
  let classRank = 1;

  for (const [strength, group] of Array.from(strengthMap.entries())) {
    if (classRank > targetCount) break;

    const members: [Card, Card][] = group.map((g: { cards: [Card, Card]; handResult: HandResult }) => g.cards);
    const representative = group[0]; // Use first member's hand result as representative
    const label = getEquivalenceLabel(members, board);

    classes.push({
      rank: classRank,
      strength,
      label,
      description: representative.handResult.description,
      fiveCards: representative.handResult.fiveCards,
      members,
      memberCount: members.length,
    });

    classRank++;
  }

  return classes;
}

/**
 * Find which equivalence class a given holding belongs to.
 * Matches by evaluating the holding's strength and finding the matching class.
 */
export function findEquivalenceClassForHolding(
  holding: [Card, Card],
  board: Card[],
  classes: EquivalenceClass[]
): EquivalenceClass | null {
  const sevenCards = [...board, ...holding];
  const handResult = evaluateBestHand(sevenCards);
  const strength = handResult.strength;

  return classes.find(c => c.strength === strength) ?? null;
}
