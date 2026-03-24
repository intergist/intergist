# Poker Sharp — Mobile App Specification
## Drills That Make You Dangerous

**Version:** 4.0
**Date:** March 24, 2026
**Based on:** Angel Largay's *No-Limit Texas Hold'em: A Complete Course*

---

## 1. Overview

### 1.1 Purpose
Poker Sharp is a mobile training app based on the board-reading drill described in Angel Largay's *No-Limit Texas Hold'em: A Complete Course*[1]. The app displays five random community cards ("the board") and challenges the user to identify and rank the best possible two-card holdings (hole cards) from best to Nth best. Holdings with identical hand strength are grouped into equivalence classes, so the user ranks groups rather than individual hands. The app tracks performance over time so users can measure improvement in speed and accuracy.

### 1.2 Target Platforms
- iOS 16+ (iPhone)
- Android 12+ (phones)
- Built with a cross-platform framework (React Native or Flutter recommended)

### 1.3 Target Users
- Beginner to intermediate Texas Hold'em players
- Serious players looking to sharpen board-reading speed
- Poker students and coaches

---

## 2. Core Concepts

### 2.1 The Drill
1. The app deals five random community cards face-up (the board).
2. The user selects and ranks two-card holdings from the remaining 47 cards, ordered from strongest (#1) to weakest (#N). Holdings that produce identical hand strength form an equivalence class and share the same rank — the user ranks classes, not individual holdings. **Note:** The same card may appear in more than one holding. Card availability constraints apply only to the 5 board cards, which cannot be selected as hole cards. This follows the drill design described in the source material, where inter-holding card conflicts are intentionally ignored[1].
3. The user may add, remove, and reorder holdings before submitting.
4. On submission, the app scores the answer against the mathematically correct class-based ranking.
5. A timer (optional) tracks how long the user takes.

### 2.2 Hand Evaluation Engine
- A built-in poker hand evaluator determines the absolute best 5-card hand achievable from each possible two-card holding combined with the five board cards.
- All C(47,2) = 1,081 possible holdings are evaluated independently — each holding is assessed as if it is the only one that exists, with no mutual exclusion between holdings.
- The engine must handle all standard hand rankings: Royal Flush → Straight Flush → Four of a Kind → Full House → Flush → Straight → Three of a Kind → Two Pair → One Pair → High Card, with proper kicker evaluation.

### 2.3 Equivalence Grouping
After all 1,081 holdings are evaluated, holdings that produce identical best-hand strength (same numeric strength value) are grouped into equivalence classes. Each class occupies a single rank position.

**Key rules:**
- Two holdings are equivalent if and only if their best-hand `strength` value is identical.
- Each equivalence class receives a sequential rank (1, 2, 3, …). There are no shared or skipped ranks — each class is one rank.
- Any member of an equivalence class represents the entire class. Selecting one member during a drill counts as selecting that class.
- Duplicate-class blocking: the user cannot add a second holding from the same equivalence class during a drill.

**Suit sensitivity:** On boards with flush or straight-flush possibilities, holdings that would otherwise be equivalent may split into separate classes because one specific suit combination produces a stronger hand. For example, on a four-hearts board, A♥A♠ and A♦A♣ form different classes because the A♥ contributes to a flush. The app tracks suit sensitivity as a board property for analytics.

### 2.4 Card Availability Rule
Per the source material[1], the drill intentionally ignores card availability conflicts between holdings. In a real game, if one player holds J♦T♦, no other player can hold a hand containing J♦ or T♦. However, for the purposes of this drill, all 47 non-board cards are always available for every holding. This means:
- A card such as T♦ may appear in the #1 holding (J♦T♦) and also in the #2 holding (T♦6♦).
- The card picker never removes, dims, or disables a card because it was used in a previously built holding.
- The only cards excluded from selection are the 5 board cards.

This design trains pure board-reading skill — recognizing the full landscape of strong hands a board supports — rather than combinatorial card-counting.

---

## 3. Information Architecture

### 3.1 Screen Map

Launch / Splash
  │
  ├── Home (Dashboard)
  │     ├── Quick Start (new drill)
  │     ├── Stats Overview (mini-summary)
  │     └── Settings gear icon
  │
  ├── Drill Configuration
  │     ├── Number of classes to rank (5 / 10 / 15 / 20)
  │     ├── Timer ON / OFF
  │     ├── Card Picker Mode (Two-Step / Full Grid)
  │     ├── Board type (random / custom)
  │     └── Start button
  │
  ├── Drill Screen (main gameplay)
  │     ├── Board display (5 cards)
  │     ├── Card picker (two-step or grid mode)
  │     ├── Selected holdings list (ranked by equivalence class, reorderable)
  │     ├── Timer (if enabled)
  │     └── Submit button
  │
  ├── Results Screen
  │     ├── Score breakdown (class-based)
  │     ├── Side-by-side comparison (user vs. correct, one row per class)
  │     ├── Missed equivalence classes
  │     ├── Detailed hand explanations
  │     └── Play Again / Home buttons
  │
  ├── Stats & History
  │     ├── Accuracy over time (chart)
  │     ├── Speed over time (chart)
  │     ├── Suit sensitivity performance
  │     ├── Drill history log
  │     ├── Streaks & milestones
  │     └── Filter by date / drill type
  │
  └── Settings
        ├── Card deck theme
        ├── Color scheme (light / dark)
        ├── Card Picker Mode (Two-Step / Full Grid)
        ├── Sound & haptics toggle
        ├── Notifications / daily reminders
        ├── Reset stats
        └── About / Help

---

## 4. Detailed Screen Specifications

### 4.1 Home Screen (Dashboard)

**Layout:**
- App logo and greeting ("Good evening, Player")
- Primary CTA button: "Start Drill" (large, centered, prominent)
- Mini-stats card row (3 cards, horizontally scrollable):
  - Today's drills completed
  - Current streak (consecutive days)
  - Best accuracy (last 7 days)
- Recent drill history (last 3 sessions, tappable for detail)
- Bottom tab bar: Home | Stats | Settings

**Behavior:**
- Tapping "Start Drill" navigates to Drill Configuration.
- Tapping a history card opens the Results Screen for that session.

---

### 4.2 Drill Configuration Screen

**Layout:**
- Section: "Classes to Rank"
  - Segmented control: 5 | 10 | 15 | 20
  - Default: 10
- Section: "Timer"
  - Toggle switch (ON by default)
  - When ON, a benchmark hint appears: "Pro target: ~30s for 20 classes"
- Section: "Card Picker Mode"
  - Segmented control: Two-Step (default) | Full Grid
  - Help icon with tooltip explaining each mode
- Section: "Board Setup"
  - Toggle: Random (default) | Custom
  - If Custom: tappable 5-slot board where user picks specific cards (for studying specific textures)
- Large "Deal" button at bottom

**Behavior:**
- Tapping "Deal" shuffles the deck, deals 5 board cards (or uses the custom board), pre-computes all equivalence classes for the board, and transitions to the Drill Screen with a card-flip animation.

---

### 4.3 Drill Screen (Core Gameplay)

This is the most critical screen. It must be highly optimized for speed and one-handed use.

#### 4.3.1 Board Display (top region)
- Five community cards displayed horizontally across the top, large enough to read suits and ranks clearly.
- Cards shown with a brief flip animation on first load.
- Board is static and always visible (pinned to top).
- Below the board: a label showing the best possible hand category for context (hidden until user opts to reveal via a "hint" icon; off by default).

#### 4.3.2 Card Picker (middle region)

**The app offers two picker modes, selectable in Drill Configuration and Settings.**

**Card availability principle (applies to both modes):** Only the 5 board cards are excluded from selection. All other 47 cards remain fully available at all times, regardless of whether they appear in previously built holdings. Cards are never consumed, dimmed, or disabled based on holdings (see §2.4).

---

##### **Mode A: Two-Step Picker (Default, Recommended)**

This mode prioritizes speed, accessibility, and works on all phone sizes.

**Step 1 — Rank Selection:**
- Two horizontal rows of rank buttons displayed prominently
  - Row 1: A K Q J T 9 8 (7 buttons)
  - Row 2: 7 6 5 4 3 2 (6 buttons, with blank space or helper text in 7th position)
- Each button: 48×48pt minimum tap target
- Total width required: 7 × 48 + 6 × 4 (padding) = 360px — fits all modern phones
- Ranks are grayed out and disabled only when all 4 suits of that rank appear among the 5 board cards (i.e., none remain in the deck at all). Ranks used in existing holdings remain fully available.
- User taps a rank button → it highlights with a glow and "Step 2: Pick suit" prompt appears

**Step 2 — Suit Selection:**
- A bottom sheet or inline panel slides up immediately after rank selection
- Displays 4 large suit buttons arranged in a 2×2 grid: ♠ ♥ ♦ ♣
- Each button: 80×80pt — extremely easy to tap
- Four-color mode uses: ♠ (black), ♥ (red), ♦ (blue), ♣ (green)
- Suits are grayed out and disabled only when that specific card appears on the board. Suits used in existing holdings remain available for selection in new holdings.
- **Auto-selection:** If only one suit is available for the chosen rank (because the other 3 are on the board), it auto-selects immediately (saves a tap)
- User taps a suit → the card is formed and added to the current holding being built
- The picker resets to Step 1 for the next card selection

**Interaction flow for one holding:**
1. Tap rank (e.g., A) → suit picker appears
2. Tap suit (e.g., ♠) → A♠ selected, brief haptic, picker resets
3. Tap rank (e.g., K) → suit picker appears
4. Tap suit (e.g., ♠) → K♠ selected
5. Holding [A♠ K♠] auto-added to list with equivalence class label and hand strength shown
6. If the holding belongs to a multi-member equivalence class, a toast appears: "All equivalent suit combos accepted"

**Duplicate-class blocking:** Before adding a holding, the app checks if any existing holding in the user's list belongs to the same equivalence class (identical hand strength). If so, the addition is blocked and a toast shows: "{Class label} already ranked at #{position}."

**Total: 4 taps per holding** (or 3 if auto-selection triggers once)

**Visual design:**
- Rank buttons use large, bold monospace font (SF Mono / Roboto Mono)
- Suit buttons show centered suit symbol with color-coding
- Disabled buttons (board cards only): 40% opacity with subtle strikethrough or "X" overlay
- Active selection glows with primary color border

---

##### **Mode B: Full Grid (Advanced, Optional)**

This mode shows all 47 available cards simultaneously for users who want maximum speed and have larger phones.

**Layout:**
- Grid of 7 columns × 8 rows (56 cells total: 52 cards across 4 suits × 13 ranks, plus 4 empty cells). 5 board cards are grayed out, leaving 47 selectable.
- Each suit occupies 2 rows (high cards in row 1, low cards in row 2):

        A   K   Q   J   T   9   8
  ♠    [·] [·] [·] [·] [·] [·] [·]
  ♠    [7] [6] [5] [4] [3] [2] [_]

  ♥    [·] [·] [·] [·] [·] [·] [·]
  ♥    [7] [6] [5] [4] [3] [2] [_]

  ♦    [·] [·] [·] [·] [·] [·] [·]
  ♦    [7] [6] [5] [4] [3] [2] [_]

  ♣    [·] [·] [·] [·] [·] [·] [·]
  ♣    [7] [6] [5] [4] [3] [2] [_]

- Cell size: 44×44pt minimum
- Total dimensions: 332px wide × 380px tall
- Suit label (♠ ♥ ♦ ♣) displayed on the left edge of each pair of rows
- Cards that appear on the board are shown as empty slots or grayed placeholders and are not selectable. All other 47 cards are displayed at full opacity and remain selectable regardless of whether they have been used in previously built holdings. There is no dimming or badging of cards based on holdings.

**Interaction:**
- User taps two cards sequentially to form a holding
- First tap: card highlights with glow, "Select second card" prompt appears
- Second tap: holding is formed. Duplicate-class blocking applies (same as Two-Step mode). If valid, auto-added to list.
- If user taps same card twice or a board card: gentle shake animation, no action
- Quick-cancel: tap the highlighted first card again to deselect

**Total: 2 taps per holding**

**Visual design:**
- Four-color deck: ♠ black, ♥ red, ♦ blue, ♣ green
- Each row color-coded by suit background (subtle tint)
- Mini card representations (rank + suit symbol)

---

**Mode Selection Guidance:**

| Aspect | Two-Step (Mode A) | Full Grid (Mode B) |
|---|---|---|
| Speed | 4 taps/holding | 2 taps/holding |
| Screen size req. | Works on all phones | Needs ~380px vertical space |
| Accessibility | Larger tap targets (48pt, 80pt) | Smaller tap targets (44pt) |
| Learning curve | Beginner-friendly | Requires spatial memory |
| Best for | First-time users, small phones | Experienced users, large phones |
| Default | ✅ Yes | No |

Users can switch modes in Settings or Drill Configuration. The app remembers their preference.

---

#### 4.3.3 Selected Holdings List (bottom region, expandable)

- A vertically scrollable, numbered list of holdings the user has chosen, ranked from #1 (best) at the top to #N at the bottom. Each entry represents one equivalence class.
- Each list item shows:
  - Rank number (#1, #2, …)
  - **Equivalence class label** — if the holding belongs to a class with multiple members, the class label is shown (e.g., "AA", "AKs") instead of specific cards. If the class has a single member, the specific cards are shown (e.g., "A♥K♥").
  - The resulting 5-card hand name (e.g., "Flush, A-high") — auto-computed in real time
  - A drag handle (≡ icon) on the right for reordering
  - A delete button (✕) on the left, revealed on swipe-left

**Equivalence class labels** follow this hierarchy:
1. Single member → specific notation: "A♥K♥"
2. Two or three members → list all: "A♥K♥, A♠K♠, A♦K♦"
3. All suited combos of a rank pair → abbreviated: "AKs"
4. All offsuit combos of a rank pair → abbreviated: "AKo"
5. All combos of a pair rank → abbreviated: "AA"
6. Mixed or large groups → abstract label with count: "Flush, A-high combos (4)"

**Reordering:**
- Long-press on any holding to activate drag mode. The item lifts with a shadow and can be dragged to a new position.
- Other items animate smoothly to make room.
- Rank numbers update automatically after reordering.

**Editing:**
- Swipe left on a holding to reveal a red "Remove" button. Tapping the Remove button deletes the holding from the list and renumbers the remaining entries. No change is made to card availability in the picker, since cards are never consumed by holdings.
- Tapping an existing holding (not in drag mode) highlights its two cards in the picker for easy identification.

#### 4.3.4 Timer Bar
- If timer is enabled, a slim bar below the board shows elapsed time in MM:SS format.
- Counts up from 00:00 on board reveal.
- Tapping the timer pauses it (board is obscured during pause to prevent "free" thinking time).

#### 4.3.5 Submit Button
- Fixed at the very bottom of the screen.
- Enabled once at least 1 holding is selected. Disabled when 0 holdings selected.
- Label: "Submit [N] Holdings" with a checkmark icon.
- Shows confirmation dialog if fewer than target count submitted: "You've ranked [X] of [Target]. Submit anyway?"
- On confirmation, stops the timer and navigates to the Results Screen.

#### 4.3.6 Toolbar
- Top-right icons:
  - **Undo** (↩): undoes the last action (add, remove, or reorder). Supports up to 20 undo steps.
  - **Clear All** (🗑): clears all selected holdings after confirmation prompt.
  - **Hint** (💡): reveals the best possible hand category achievable on this board (e.g., "Best possible: Straight Flush"). Using a hint flags the drill as "assisted" in stats. Hints are unlimited but affect the drill's unassisted status.

---

### 4.4 Results Screen

**Layout (scrollable):**

#### Section 1: Score Summary
- Large circular score graphic: e.g., "8 / 10 correct" with percentage ring.
- Time taken (if timer was on), color-coded: green (under target), yellow (near target), red (over target).
- Label: "Assisted" if hints were used.

#### Section 2: Class-Based Comparison Table
- One row per equivalence class position (not per individual holding):
  - Left column: "Your Ranking" — the holding the user submitted for this rank position, with its class label.
  - Right column: "Correct Ranking" — the correct equivalence class at this position, showing class label, hand description, and member count.
- Each row is color-coded:
  - ✅ Green: user's holding matches the correct equivalence class at this exact rank position.
  - 🟡 Yellow: user's holding belongs to a correct class but is ranked in the wrong position (off by 1–2 places).
  - 🔴 Red: user's holding belongs to a class not in the correct position (off by 3+ places) or does not belong in the top N classes at all.
- Tapping any row expands it to show:
  - The best 5-card hand formed by the representative holding + the board.
  - The hand category and full card breakdown (e.g., "Full House, Kings full of Nines: K♠ K♦ 9♣ 9♥ 9♠").
  - All individual members of the equivalence class.

#### Section 3: Missed Classes
- Shows equivalence classes from the correct top-N that the user did not represent with any holding. Displays the class label, hand description, member count, and what rank it should have occupied.

#### Section 4: Board Texture Note (educational)
- A short auto-generated note about the board texture: "This board is monotone (all hearts), making flushes dominant. The best holdings involve high hearts."
- If the board is suit-sensitive, an additional note: "This board has suit-sensitive equivalence classes — specific suit combinations matter for ranking."

#### Action Buttons:
- "Play Again" (same settings) — primary CTA
- "New Settings" — returns to Drill Configuration
- "Home" — returns to Dashboard
- "Share" — generates a shareable image card of the board + score for social media

---

### 4.5 Stats & History Screen

#### Tab 1: Overview
- Accuracy Trend: line chart showing average accuracy (%) per day over the last 30 days.
- Speed Trend: line chart showing average completion time per drill over the last 30 days.
- Total drills completed (all time).
- Current streak and longest streak.
- Average score by drill size (5 / 10 / 15 / 20).
- Average score by picker mode (Two-Step vs. Full Grid).
- **Suit Sensitivity**: comparison of average accuracy on suit-sensitive boards versus non-sensitive boards, displayed as a stat card.

#### Tab 2: History
- Chronological list of all completed drills.
- Each entry shows: date/time, drill size, picker mode, score, time, assisted flag, suit-sensitive flag.
- Tappable to revisit the full Results Screen.
- Filter by: date range, drill size, picker mode, score range.
- Search by board cards (e.g., show all drills containing A♠).

#### Tab 3: Insights
- "Weakest Hand Types": shows which hand categories (e.g., recognizing straight possibilities, flush blockers) the user most often misranks.
- "Most Improved": categories where accuracy has increased the most over the last 14 days.
- "Speed by Board Texture": average time broken down by board texture type (monotone, paired, connected, rainbow, dry, wet).
- "Picker Mode Performance": comparison of accuracy and speed between Two-Step and Full Grid modes.

---

### 4.6 Settings Screen

| Setting | Options | Default |
|---|---|---|
| Card Deck Theme | Classic, Modern, Four-Color | Classic |
| App Theme | Light, Dark, System | System |
| Card Picker Mode | Two-Step, Full Grid | Two-Step |
| Sound Effects | On / Off | On |
| Haptic Feedback | On / Off | On |
| Daily Reminder | Off / Custom time | Off |
| Player Name | Free text | "Player" |
| Target Classes | 5, 10, 15, 20 | 10 |
| Show Timer | On / Off | On |
| Show Hand Names in Picker | On / Off | On |
| Difficulty Presets | Beginner (5), Intermediate (10), Pro (20) | Intermediate |
| Data | Export stats (CSV) / Reset all stats | — |

> **Note:** Four-Color deck theme is available for Pro tier users. Free tier users default to Classic.

---

## 5. Scoring Algorithm

### 5.1 Correct Ranking Generation
1. For the dealt board B (5 cards), enumerate all C(47,2) = 1,081 possible two-card holdings from the remaining deck.
2. For each holding H, evaluate the best 5-card poker hand from the 7 cards (B ∪ H) and compute a numeric strength value. Each holding is evaluated independently — no mutual exclusion between holdings.
3. Group holdings by identical strength value into equivalence classes. Each class contains one or more holdings that produce hands of identical absolute strength.
4. Rank the equivalence classes by strength (descending). Each class receives a unique sequential rank (1, 2, 3, …).
5. The top N equivalence classes (per drill configuration) form the "correct answer."

### 5.2 Equivalence Class Labeling
Each class is assigned a human-readable label:
- **Single member**: specific card notation (e.g., "A♥K♥")
- **2–3 members**: list all members (e.g., "A♥K♥, A♠K♠, A♦K♦")
- **All suited combos of a rank pair**: abbreviated suited (e.g., "AKs")
- **All offsuit combos of a rank pair**: abbreviated offsuit (e.g., "AKo")
- **All combos of a pocket pair**: abbreviated pair (e.g., "AA")
- **Large or mixed groups**: abstract description with count (e.g., "Flush, A-high combos (4)")

### 5.3 User Score Calculation

**Per-position scoring (out of 2 points each):**
- **2 points**: The user's holding at position P belongs to the same equivalence class as the correct class at position P.
- **1 point**: The user's holding belongs to a correct top-N equivalence class, but is placed at the wrong rank position.
- **0 points**: The user's holding does not belong to any of the top-N equivalence classes, or the slot is empty.

**Overall Score:** Sum of per-position points / (2 × N) × 100%.

### 5.4 Speed Score (Optional Gamification)
- Speed rating = total_time_ms ÷ target_count. Thresholds are calibrated for 10-class drills; for other sizes, adjust proportionally (×0.8 for 5 classes, ×1.0 for 10, ×1.1 for 15, ×1.2 for 20).
- A separate "speed rating" from 1–5 stars based on time per class:
  - ⭐⭐⭐⭐⭐: ≤ 1.5 seconds per class
  - ⭐⭐⭐⭐: ≤ 3 seconds per class
  - ⭐⭐⭐: ≤ 5 seconds per class
  - ⭐⭐: ≤ 8 seconds per class
  - ⭐: > 8 seconds per class

---

## 6. Design System

### 6.1 Color Palette

| Role | Light Mode | Dark Mode |
|---|---|---|
| Background | #FAFAFA | #1A1A2E |
| Surface / Cards | #FFFFFF | #25253E |
| Primary (CTA) | #2E7D32 (felt green) | #4CAF50 |
| Accent | #FFD700 (gold) | #FFD700 |
| Text Primary | #212121 | #F5F5F5 |
| Text Secondary | #757575 | #BDBDBD |
| Correct | #43A047 | #66BB6A |
| Partial | #FFA726 | #FFB74D |
| Incorrect | #E53935 | #EF5350 |
| Card Red (♥♦) | #D32F2F | #EF5350 |
| Card Black (♠♣) | #212121 | #F5F5F5 |
| Card Blue (♦ four-color) | #1976D2 | #42A5F5 |
| Card Green (♣ four-color) | #388E3C | #81C784 |

### 6.2 Typography
- **Headings**: SF Pro Display (iOS) / Roboto (Android), Bold, 20–28pt
- **Body**: SF Pro Text / Roboto, Regular, 16pt
- **Card Labels**: SF Mono / Roboto Mono, Bold, 14–18pt (monospaced for consistent card sizing)
- **Timer**: SF Mono / Roboto Mono, Light, 24pt

### 6.3 Card Design
- Cards should be rendered as vector graphics (SVG) for sharp display at any size.
- Standard dimensions proportional to real poker cards (2.5:3.5 aspect ratio).
- **Four-Color Deck option** (recommended default for online players):
  - ♠ Black, ♥ Red, ♦ Blue, ♣ Green
- Corner pips (rank + suit) in the top-left and bottom-right.
- Large center pip for quick identification.
- Subtle drop shadow to give cards depth.

### 6.4 Iconography
- Use SF Symbols (iOS) and Material Icons (Android) for consistency with platform conventions.
- Custom icons for suit symbols and poker-specific actions.

### 6.5 Animations & Micro-Interactions
- **Card deal**: Cards fly in from off-screen and flip over (0.3s per card, staggered).
- **Card selection**: Gentle scale-up (1.0 → 1.08) with border glow on tap.
- **Holding added**: New list item slides in from the right with a subtle bounce.
- **Duplicate-class blocked**: Gentle shake animation on the holding list with toast notification.
- **Reorder drag**: Item lifts with shadow; other items slide smoothly to reposition.
- **Submit**: Cards sweep off-screen; score ring animates from 0 to final percentage.
- **Correct answer reveal**: Equivalence classes cascade in one by one with color coding and member count badges.
- **Mode transition**: Two-Step to Full Grid (or vice versa) crossfades smoothly.
- All animations respect the device's "Reduce Motion" accessibility setting.

---

## 7. Data Model

### 7.1 Core Entities

User
  ├── id: UUID
  ├── name: String
  ├── settings: UserSettings
  ├── created_at: DateTime
  └── drills: [Drill]

Drill
  ├── id: UUID
  ├── date: DateTime
  ├── board: [Card; 5]
  ├── target_count: Int (5/10/15/20)
  ├── picker_mode: Enum (TwoStep, FullGrid)
  ├── timer_enabled: Bool
  ├── time_taken_ms: Int?
  ├── hint_used: Bool
  ├── suit_sensitive: Bool
  ├── user_holdings: [RankedHolding]
  ├── correct_classes: [EquivalenceClass]
  ├── score_percent: Float
  ├── speed_rating: Int (1–5)
  └── board_texture: BoardTexture

Card
  ├── rank: Enum (2–A)
  └── suit: Enum (♠♥♦♣)

EquivalenceClass
  ├── rank: Int (1-based, one per class)
  ├── strength: Int (shared numeric strength value)
  ├── label: String (human-readable, e.g., "AA", "AKs", "A♥K♥")
  ├── description: String (hand description, e.g., "Three of a Kind, Aces")
  ├── five_cards: [Card; 5] (representative best 5 cards)
  ├── members: [[Card; 2]] (all specific holdings in this class)
  └── member_count: Int

RankedHolding
  ├── rank: Int
  ├── cards: [Card; 2]
  ├── best_hand: HandResult
  ├── equivalence_class: EquivalenceClass
  └── points_awarded: Int (0, 1, or 2)

HandResult
  ├── category: Enum (RoyalFlush...HighCard)
  ├── five_cards: [Card; 5]
  └── strength_value: Int (absolute comparable value)

BoardTexture
  ├── is_monotone: Bool
  ├── is_two_tone: Bool
  ├── is_rainbow: Bool
  ├── is_paired: Bool
  ├── is_double_paired: Bool
  ├── is_trips: Bool
  ├── is_quads: Bool
  ├── connectivity: Enum (connected, semi-connected, disconnected)
  └── highest_card: Card

### 7.2 Local Storage
- All data stored locally using SQLite (via Drift/Floor for Flutter or WatermelonDB for React Native).
- No user account or cloud sync required for v1 (local-only).
- Export to CSV available from Settings.

---

## 8. Technical Architecture

### 8.1 Recommended Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) or React Native (TypeScript) |
| Hand Evaluator | Native module in C/Rust via FFI (for speed) or optimized Dart/TS lookup table |
| Local DB | SQLite (Drift for Flutter / WatermelonDB for RN) |
| State Management | Riverpod (Flutter) / Zustand (RN) |
| Animations | Flutter built-in / Reanimated 3 (RN) |
| Card Rendering | Custom SVG components |
| Charts | fl_chart (Flutter) / Victory Native (RN) |
| Testing | Unit tests for hand evaluator and equivalence grouping (exhaustive), widget/component tests for UI |

### 8.2 Hand Evaluator Performance
- Must rank all 1,081 holdings and compute equivalence classes in < 50ms on a modern phone.
- Recommended approach: use a precomputed lookup table (e.g., Two Plus Two evaluator ported to native) invoked via FFI.
- Fallback: pure Dart/TS evaluator using Cactus Kev's algorithm with perfect hash.
- Equivalence grouping is a single O(N) pass over the sorted results — negligible additional cost.

### 8.3 Offline-First
- The app is fully functional offline. No network calls are needed for core functionality.
- Network used only for: analytics (opt-in), future cloud backup, App Store updates.

### 8.4 Error Handling & Edge Cases

- **Auto-save:** Drill state (board, selected holdings, ordering, timer) is auto-saved after every user action (add, remove, reorder). If the app is terminated or crashes, the user can resume the in-progress drill on next launch.
- **Back button during drill:** Pressing the back button or system navigation gesture during an active drill shows a confirmation dialog: "Leave drill? Progress will be saved." The user may choose "Leave" (saves state, returns to previous screen) or "Cancel" (stays in drill).
- **Portrait orientation lock:** The app locks to portrait orientation. Landscape mode is not supported in v1. The lock is enforced at the app level so all screens render in portrait only.
- **Duplicate-class blocking:** When a user attempts to add a holding whose equivalence class is already represented in their list, the addition is blocked. A toast shows the class label and its current rank position. Duplicate-class blocking operates at the equivalence class level only. There is no card-level prevention — the same card may appear in multiple holdings. The only card-level constraint is board-card exclusion: the 5 community cards cannot be selected as hole cards.
- **Board validation:** When dealing a random board, the app verifies that no duplicate cards are dealt (standard 52-card deck constraint). If a custom board is entered, the app validates that all 5 cards are distinct before starting the drill.

---

## 9. Accessibility

- **VoiceOver / TalkBack** support: all cards announced by rank and suit (e.g., "Ace of Spades"). Holdings list is navigable with equivalence class labels read aloud. Picker mode buttons have clear labels.
- **Dynamic Type / Font Scaling**: UI adapts to system font size up to 200%.
- **Color-blind support**: Four-color deck mode uses distinct colors (black, red, blue, green). Correct/incorrect indicators use icons (✓ / ✕) alongside color.
- **Reduce Motion**: all animations replaced with simple fades.
- Minimum tap target: 44×44 pt (iOS) / 48×48 dp (Android) in Two-Step mode.
- Full Grid mode uses 44×44pt minimum, meeting iOS guidelines.

---

## 10. Monetization (Optional)

### Free Tier
- 3 drills per day
- Drill sizes 5 and 10 only
- Both picker modes available
- 7-day stats history
- Classic card theme only

### Pro Tier (one-time purchase or subscription)
- Unlimited drills
- All drill sizes (5, 10, 15, 20)
- Both picker modes (no restrictions)
- Full stats history and insights
- All card themes
- Custom board mode
- Export stats to CSV
- No ads

**Suggested pricing:** $4.99 one-time or $1.99/month

---

## 11. Future Enhancements (v2+)

- **Multiplayer / Leaderboard**: Compete on the same board with friends or globally (timed).
- **Daily Challenge**: A curated board-of-the-day with global leaderboard.
- **Flop-Only Mode**: Show only 3 cards; user predicts best holdings (easier entry point).
- **Turn & River Drill**: Start with a flop, add turn, then river — re-rank after each card.
- **Coach Mode**: Step-by-step walkthrough explaining *why* each holding ranks where it does, with equivalence class reasoning.
- **Board Texture Trainer**: A separate mini-drill that asks the user to classify board textures (monotone, paired, connected, etc.).
- **Omaha Mode**: 4-card holdings with must-use-exactly-2 rule.
- **Apple Watch / Wear OS**: Quick one-board drill on the wrist.
- **Cloud Sync**: Sync progress across devices via Apple/Google sign-in.
- **Widget**: iOS/Android home screen widget showing daily streak and a "Start Drill" shortcut.
- **Adaptive Difficulty**: Analyze user's weak areas and generate boards that target those patterns.

---

## 12. Success Metrics

| Metric | Target (6 months post-launch) |
|---|---|
| Daily Active Users | 5,000+ |
| Average drills per user per day | 3+ |
| Day-7 retention | > 30% |
| Day-30 retention | > 15% |
| App Store rating | ≥ 4.5 stars |
| Pro conversion rate | > 5% of active users |
| Average accuracy improvement (user over 30 days) | +20 percentage points |
| Picker mode adoption | 70% Two-Step, 30% Full Grid (projected) |

---

## 13. Card Picker Design Rationale

### 13.1 Why Two Modes?

User testing and phone screen analysis revealed that the original 4×13 grid (all 52 cards) cannot fit on any modern phone while maintaining minimum tap target sizes[2]. The revised spec offers two modes to balance competing needs:

**Two-Step Mode** optimizes for:
- Universal device compatibility (works on all phones from iPhone SE to Pro Max)
- Accessibility (48pt and 80pt tap targets exceed all platform guidelines)
- Beginner-friendliness (clear two-stage flow reduces cognitive load)
- Error prevention (large targets minimize mistaps)

**Full Grid Mode** optimizes for:
- Speed for experienced users (2 taps vs. 4 taps per holding)
- Spatial recognition (advanced players develop muscle memory for card positions)
- Single-screen workflow (no mode transitions between rank and suit selection)

### 13.2 Design Validation

| Constraint | Two-Step Mode | Full Grid Mode |
|---|---|---|
| Smallest phone (iPhone SE, 343px usable) | ✅ 332px wide | ✅ 332px wide |
| iOS min tap target (44pt) | ✅ Exceeds (48pt, 80pt) | ✅ Meets (44pt) |
| Android min tap target (48dp) | ✅ Meets | ⚠️ Slightly below (44pt) |
| Vertical space budget | ✅ ~150px | ⚠️ 380px (requires scrolling) |
| Accessibility (WCAG) | ✅ AAA | ✅ AA |
| Speed (taps per holding) | 4 taps | 2 taps |

Both modes meet core usability requirements, giving users choice based on their device, skill level, and preference.

---

## Appendix A: Example Drill Walkthrough

**Board:** 9♥ 8♥ 7♥ 3♠ 2♦

This is a suit-sensitive board (three hearts enable flush and straight flush possibilities). Equivalence classes differ based on whether holdings include hearts.

**Top 5 correct equivalence classes:**

| Class Rank | Label | Members | Best Hand | Explanation |
|---|---|---|---|---|
| 1 | J♥T♥ | 1 | Straight Flush (J-high) | J♥ T♥ 9♥ 8♥ 7♥ |
| 2 | T♥6♥ | 1 | Straight Flush (T-high) | T♥ 9♥ 8♥ 7♥ 6♥ |
| 3 | 6♥5♥ | 1 | Straight Flush (9-high) | 9♥ 8♥ 7♥ 6♥ 5♥ |
| 4 | A♥K♥ | 1 | Flush, Ace-high | A♥ K♥ 9♥ 8♥ 7♥ |
| 5 | A♥Q♥ | 1 | Flush, Ace-high | A♥ Q♥ 9♥ 8♥ 7♥ |

Note: On this board, each top class has a single member because the heart suit is what creates the dominant hands. On a rainbow board, many of these classes would contain multiple members. Also note that T♥ appears in both class #1 (J♥T♥) and class #2 (T♥6♥) — this is correct per the card availability rule (§2.4).

### Two-Step Mode Interaction:
User selects J♥:
1. Tap "J" button → suit picker appears
2. Tap "♥" button → J♥ selected

User selects T♥:
3. Tap "T" button → suit picker appears
4. Tap suit (♥) → T♥ selected

Holding [J♥ T♥] added to list as class "J♥T♥", labeled "Straight Flush, J-high"

User now builds the #2 holding — T♥ is still available in the picker:
5. Tap "T" button → suit picker appears (♥ is NOT grayed out — card reuse is allowed)
6. Tap "♥" button → T♥ selected again
7. Tap "6" button → suit picker appears
8. Tap "♥" button → 6♥ selected

Holding [T♥ 6♥] added to list as class "T♥6♥", labeled "Straight Flush, T-high"

### Full Grid Mode Interaction:
1. Tap J♥ in grid (row 1, ♥ section, position 4)
2. Tap T♥ in grid (row 1, ♥ section, position 5)
Holding [J♥ T♥] added to list as class "J♥T♥", labeled "Straight Flush, J-high"

User builds #2 — T♥ remains at full opacity, fully selectable:
3. Tap T♥ in grid (same cell as before — still available)
4. Tap 6♥ in grid (row 2, ♥ section, position 1)
Holding [T♥ 6♥] added to list as class "T♥6♥", labeled "Straight Flush, T-high"

### Equivalence Grouping Example (Rainbow Board):

**Board:** K♠ Q♥ 9♦ 5♣ 2♦

On this non-flush board, many rank combinations produce equivalent hands regardless of suit:
- A♠A♥, A♣A♦, A♠A♦, A♥A♣, A♠A♣, A♥A♦ → all 6 combos form one class "AA" (Pair of Aces, K-Q-9 kickers)
- A♠K♥, A♣K♠, A♦K♠, A♥K♠ → forms class "AK" (Pair of Kings, A-Q-9 kickers) — suits do not matter since no flush is possible

---

## Appendix B: Equivalence Grouping Test Cases

The following test cases verify correct equivalence class behavior:

**Test 1 — Rainbow board, pairs group fully:**
Board: K♠ Q♥ 9♦ 5♣ 2♦
- A♠A♥ and A♣A♦ → SAME class "AA" (both make pair of Aces with same kickers)

**Test 2 — Suit-sensitive board, pairs split:**
Board: K♥ Q♥ 9♥ 5♥ 2♣ (4 hearts)
- A♥A♠ and A♦A♣ → DIFFERENT classes (A♥ makes a flush, A♦ doesn't)

**Test 3 — Straight flush vs. straight:**
Board: 7♠ 8♠ 9♠ 2♦ 3♣
- T♠6♠ and T♥6♥ → DIFFERENT classes (T♠6♠ = straight flush, T♥6♥ = straight)
- T♥6♥ and T♦6♦ → SAME class (both make T-high straight, no flush)

**Test 4 — Board aces reduce combo count:**
Board: A♠ A♥ K♣ K♦ Q♠
- A♣A♦ → only 1 combo exists (other 2 aces on board), class has 1 member

**Test 5 — Card reuse across holdings:**
Board: 9♥ 8♥ 7♥ 3♠ 2♦
- J♥T♥ at rank #1 and T♥6♥ at rank #2 → VALID. T♥ appears in both holdings. Cards are not consumed between holdings per the card availability rule (§2.4).

---

## Appendix C: Card Picker Wireframes

### Two-Step Mode — Step 1 (Rank Selection)

┌──────────────────────────────────────────────┐
│             SELECT RANK                       │
├──────────────────────────────────────────────┤
│   [A]  [K]  [Q]  [J]  [T]  [9]  [8]          │
│   [7]  [6]  [5]  [4]  [3]  [2]  [_]          │
│                                               │
│   (Each button 48×48pt, 4pt padding)          │
│   (Grayed = all 4 suits on the board)         │
└──────────────────────────────────────────────┘

### Two-Step Mode — Step 2 (Suit Selection, Bottom Sheet)

┌──────────────────────────────────────────────┐
│   You selected: A                             │
│   Now pick a suit:                            │
│                                               │
│         [♠]      [♥]                          │
│         80×80pt  80×80pt                      │
│                                               │
│         [♦]      [♣]                          │
│         80×80pt  80×80pt                      │
│                                               │
│   (Grayed = card is on the board)             │
└──────────────────────────────────────────────┘

### Full Grid Mode (7 cols × 8 rows)

┌──────────────────────────────────────────────┐
│        A   K   Q   J   T   9   8             │
│  ♠    [ ] [ ] [ ] [ ] [ ] [ ] [ ]            │
│  ♠    [7] [6] [5] [4] [3] [2] [_]            │
│                                               │
│  ♥    [ ] [ ] [█] [ ] [ ] [█] [█]  (board)   │
│  ♥    [█] [6] [5] [4] [3] [2] [_]            │
│                                               │
│  ♦    [ ] [ ] [ ] [ ] [ ] [ ] [ ]            │
│  ♦    [7] [6] [5] [4] [3] [█] [_]  (board)   │
│                                               │
│  ♣    [ ] [ ] [ ] [ ] [ ] [ ] [ ]            │
│  ♣    [7] [6] [5] [4] [█] [2] [_]  (board)   │
│                                               │
│   [ ] = available (44×44pt tap target)        │
│   [█] = on board (hidden/grayed)              │
│   Rows color-coded: ♠ black, ♥ red, ♦ blue,   │
│                     ♣ green (four-color)       │
└──────────────────────────────────────────────┘

Note: All non-board cards remain at full opacity and selectable at all times, regardless of whether they appear in existing holdings.

---

## References

[1] Largay, A. (2006). *No-Limit Texas Hold'em: A Complete Course*. ECW Press. https://ecwpress.com/products/no-limit-texas-holdem — Footnote on p. 19: "Often the availability of two cards is not possible due to another player's holdings, but we will ignore this problem for the purposes of the quiz."

[2] Analysis based on standard phone dimensions: iPhone SE (375pt), iPhone 15 (393pt), iPhone 15 Pro Max (430pt), typical Android (360–412dp), with iOS minimum tap target 44×44pt and Android 48×48dp per platform guidelines.

---

## Revision History

| Version | Date | Changes |
|---|---|---|
| 1.0 | March 18, 2026 | Initial specification |
| 2.0 | March 19, 2026 | 12 fixes (naming, grid math, submit logic, scoring clarity, error handling, etc.) |
| 3.0 | March 23, 2026 | Consolidated CR-001: equivalence grouping throughout |
| 4.0 | March 24, 2026 | Consolidated CR-002: card availability rule — cards are no longer consumed by holdings (see below) |

**Changes in v4.0 (CR-002 consolidation):**

1. **Section 2.1 — The Drill, step 2**: Added explicit note that the same card may appear in more than one holding. Card availability constraints apply only to the 5 board cards. This follows the source material's footnote where inter-holding card conflicts are intentionally ignored.
2. **Section 2.2 — Hand Evaluation Engine**: Clarified that all 1,081 holdings are evaluated independently with no mutual exclusion.
3. **Section 2.4 — New section "Card Availability Rule"**: Defines and explains the rule that cards are never consumed by holdings. Only board cards are excluded. Cites the source material's explicit footnote on p. 19.
4. **Section 4.3.2 — Card Picker preamble**: Added a card availability principle statement that applies to both picker modes.
5. **Section 4.3.2 — Mode A, Step 1**: Rank disabling rule changed — ranks are grayed only when all 4 suits appear on the board, not when used in holdings.
6. **Section 4.3.2 — Mode A, Step 2**: Suit disabling rule changed — suits are grayed only when that card appears on the board, not when used in holdings.
7. **Section 4.3.2 — Mode A, Visual design**: "Disabled buttons" clarified as "board cards only."
8. **Section 4.3.2 — Mode B, Layout**: Removed "Cards already selected in holdings are dimmed (40% opacity) with a small badge showing rank number." Replaced with statement that all 47 non-board cards display at full opacity regardless of holdings.
9. **Section 4.3.2 — Mode B, Visual design**: Removed "Selected cards have colored border matching the holding rank" since cards are not tracked per-holding in the picker.
10. **Section 4.3.3 — Editing**: Removed "returns its two cards to the available pool in the picker." Replaced with "No change is made to card availability in the picker, since cards are never consumed by holdings."
11. **Section 5.1 — Correct Ranking Generation, step 2**: Added "Each holding is evaluated independently — no mutual exclusion between holdings."
12. **Section 8.4 — Duplicate-class blocking**: Removed "This replaces simple duplicate-card prevention — the constraint operates at the class level, not the individual card level." Replaced with explicit statement that there is no card-level prevention, only board-card exclusion.
13. **Appendix A — Walkthrough**: Added note that T♥ appears in both class #1 and #2 per the card availability rule. Expanded Two-Step and Full Grid interaction examples to show card reuse across holdings.
14. **Appendix B — Test Case 5**: New test case explicitly verifying card reuse across holdings.
15. **Appendix C — Wireframes**: Removed `[◉] = selected in holding (dimmed + badge)` legend entry from Full Grid wireframe. Updated legend text in both modes to reflect board-only exclusion. Added closing note that all non-board cards remain selectable at all times.
16. **References [1]**: Expanded to include the specific footnote citation from p. 19 regarding card availability.
