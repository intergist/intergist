# CR-001 Implementation Specification

## Overview
Add equivalence grouping to Poker Sharp. Holdings that produce identical best-hand strength (same HandResult.strength value) must be grouped into a single equivalence class, scored as a group, and displayed as a group.

## Key Concept
The `evaluateBestHand()` function already produces a numeric `strength` value. Two holdings are equivalent if and only if `handResult.strength` is identical. The grouping pass happens after `rankAllHoldings()`.

## New Types (add to poker.ts)

```typescript
export interface EquivalenceClass {
  rank: number;           // 1-based position (one per class)
  strength: number;       // shared HandResult.strength
  label: string;          // human-readable label (e.g., "AA", "AKs", "A♥K♥")
  description: string;    // hand description (e.g., "Three of a Kind, Aces")
  fiveCards: Card[];      // representative best 5 cards
  members: [Card, Card][]; // all specific holdings in this class
  memberCount: number;
}
```

## New Functions (add to poker.ts)

### `groupIntoEquivalenceClasses(board: Card[], targetCount: number): EquivalenceClass[]`

1. Call `rankAllHoldings(board)` to get all 1081 holdings sorted by strength.
2. Group by `handResult.strength` — holdings with identical strength form one class.
3. Number classes sequentially: rank 1, 2, 3, ...
4. Return the first `targetCount` classes.
5. For each class, generate a label using `getEquivalenceLabel()`.

### `getEquivalenceLabel(members: [Card, Card][], board: Card[]): string`

Generate a human-readable poker notation label:

1. If only 1 member → use specific notation: `cardToString(c1) + cardToString(c2)` e.g., "A♥K♥"
2. If all members share the same two ranks:
   - Check if all members are suited → suffix `s` (e.g., "AKs" but only if all combos of that suited type are present)
   - Check if all members are offsuit → suffix `o` (e.g., "AKo")
   - If pair (same rank) and all 6 combos → "AA"
   - If pair but fewer than 6 → list them or use partial: "A♥A*" or just list count
   - Otherwise → use abbreviated notation
3. If members have mixed ranks → describe the group generically: "Flush, A-high combos (N)" or list if small

Simpler approach for v1: If memberCount == 1, show specific cards. If memberCount <= 3, list all. Otherwise show the abstract label + "(N combos)".

### `findEquivalenceClassForHolding(holding: [Card, Card], classes: EquivalenceClass[]): EquivalenceClass | null`

Given a user-selected holding and the pre-computed classes, find which class it belongs to by matching `handResult.strength`.

## Changes to scoring.ts

### Replace `scoreSubmission` with group-aware scoring:

```typescript
export function scoreSubmissionGrouped(
  board: Card[],
  userHoldings: { cards: [Card, Card] }[],
  targetCount: number
): GroupedScoringResult {
  const classes = groupIntoEquivalenceClasses(board, targetCount);
  
  // For each position i in the user's list:
  // - Evaluate the user's holding strength
  // - If it matches the class at position i → 2 points (exact)
  // - If it matches ANY class in the top N but not at position i → 1 point (partial)
  // - If it doesn't match any class → 0 points (wrong)
  // - If slot is empty → 0 points (missing)
  
  // Missed classes: classes not represented by any user holding
}
```

New types:
```typescript
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
```

## Changes to DrillScreen.tsx

### Duplicate-class detection
After a holding is added (in handleSuitTap where second card is selected):
1. Compute the new holding's strength: `evaluateBestHand([...board, card1, card2])`
2. Check against all existing holdings in the user's list — if any existing holding has the same strength, show a toast: `"${className} already ranked at #${position}."`
3. Block the addition (don't add duplicates from same equivalence class)

### Holdings list display
When displaying a holding in the list, if it belongs to an equivalence class with >1 members, show the class label instead of specific cards. E.g., "AA" instead of "A♠A♥".

To determine this at display time, we need the equivalence classes pre-computed. Add a `useMemo` that calls `groupIntoEquivalenceClasses(board, config.holdingsCount)` once when the board changes.

### Toast for group acceptance
When a holding is added that belongs to a multi-member class, show a subtle toast: "All equivalent suit combos accepted."

## Changes to Results.tsx

### One row per equivalence class
The comparison table shows one row per class position (not per individual holding):
- Rank number, class label, hand description, member count (collapsible)
- Expanded row shows all individual members of that class
- User's submitted holding for that position (if any)

### Missed classes section
Show missed equivalence classes (not individual holdings).

## Changes to gameState.ts

### DrillRecord update
Add field: `suitSensitive: boolean` — was this a suit-sensitive board?

### Stats helper update
Add `getSuitSensitivity(history: DrillRecord[])` function:
- Calculates percentage accuracy on suit-sensitive boards vs non-sensitive
- A board is suit-sensitive if the equivalence classes differ from what they'd be on a hypothetical rainbow version

Simple approach: just track the `isSuitSensitive` flag from `GroupedScoringResult` and compare average scores.

## Changes to Stats.tsx
Add a "Suit Sensitivity" metric card below existing stats.

## Changes to App.tsx
Update the `handleSubmit` to use the new `scoreSubmissionGrouped` and pass the new result type to Results.

## Test Cases (must pass)

Board: K♠ Q♥ 9♦ 5♣ 2♦ (rainbow-ish)
- A♠A♥ and A♣A♦ → same class "AA" (both make pair of Aces with same kickers)

Board: K♥ Q♥ 9♥ 5♥ 2♣ (4 hearts)
- A♥A♠ and A♦A♣ → DIFFERENT classes (A♥ makes flush, A♦ doesn't)

Board: 7♠ 8♠ 9♠ 2♦ 3♣
- T♠6♠ and T♥6♥ → DIFFERENT (T♠6♠ = straight flush, T♥6♥ = straight)
- T♥6♥ and T♦6♦ → SAME (both make T-high straight, no flush)

Board: A♠ A♥ K♣ K♦ Q♠
- A♣A♦ → only 1 combo exists (other 2 aces on board), class has 1 member

## File Edit Order
1. poker.ts — add EquivalenceClass type + groupIntoEquivalenceClasses + getEquivalenceLabel + findEquivalenceClassForHolding
2. scoring.ts — add GroupedScoringResult + scoreSubmissionGrouped + update isSuitSensitive logic
3. gameState.ts — update DrillRecord, add suitSensitivity stat helper
4. App.tsx — wire new scoring, pass new result type
5. DrillScreen.tsx — add duplicate-class blocking, toast, class-label display
6. Results.tsx — rewrite comparison table for class-based rows
7. Stats.tsx — add Suit Sensitivity card
