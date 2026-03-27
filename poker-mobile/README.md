# Poker Sharp

**Drills That Make You Dangerous** — A mobile app for practicing poker hand-reading through board-evaluation drills.

## Overview

Poker Sharp is a Flutter mobile app that helps poker players sharpen their board-reading skills. Given a random 5-card board, players rank the top N holdings (2-card combinations) by hand strength. The app scores submissions using an equivalence-class system — holdings that produce identical hand strengths are grouped into classes, and scoring awards 2 points for exact position matches, 1 for correct class in wrong position, and 0 for incorrect or missing entries.

Key features:
- Full 5-card board evaluation against all 1,081 possible holdings (C(47,2))
- Equivalence class grouping with intelligent labeling (AA, AKs, AKo, etc.)
- Two card picker modes: Two-Step (rank → suit) and Full Grid (52-card grid)
- Undo system with full history
- Timed drills with speed ratings (1-5 stars)
- Board texture analysis and suit sensitivity detection
- Drill history with stats tracking and streak calculation

## Architecture

```
lib/
├── main.dart                     # Entry point
├── app/
│   ├── app.dart                  # MaterialApp with theme & router
│   └── router/
│       └── app_router.dart       # GoRouter with ShellRoute for bottom nav
├── core/
│   ├── poker.dart                # Hand evaluator engine (evaluate5, rankAllHoldings, equivalence classes)
│   ├── scoring.dart              # Class-based scoring engine, board texture, speed rating
│   ├── game_state.dart           # DrillConfig, DrillRecord, AppSettings models
│   ├── providers.dart            # Riverpod providers (config, holdings, timer, history)
│   ├── database_service.dart     # SQLite persistence via sqflite
│   └── app_logger.dart           # Structured logging with test capture mode
└── ui/
    ├── tokens/                   # Design tokens (color, spacing, radius, motion, etc.)
    ├── theme/                    # Material 3 theme with ThemeExtensions
    ├── components/               # Reusable UI components (buttons, cards, indicators)
    └── screens/
        ├── home/                 # Dashboard with stats and recent drills
        ├── drill_config/         # Drill configuration (holdings count, timer, picker mode)
        ├── drill/                # Main drill screen with pickers and holdings list
        ├── results/              # Score ring, comparison table, board texture
        ├── stats/                # Stats grid, suit sensitivity, drill history
        └── settings/             # Profile, appearance, defaults, data management
```

**State management**: Riverpod with `StateNotifier` pattern
**Routing**: GoRouter with `ShellRoute` for bottom navigation (Home/Stats/Settings share nav bar; Config/Drill/Results are standalone)
**Persistence**: SQLite via `sqflite`
**Design system**: Token-driven with 8 token categories and 3 `ThemeExtension` types

## Prerequisites

- **Flutter SDK** 3.22 or higher
- **Dart SDK** 3.4 or higher
- **Android Studio** (for Android) or **Xcode** (for iOS)
- Git

Verify your setup:

```bash
flutter doctor
```

## Dev Environment Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd poker-mobile

# 2. Install dependencies
flutter pub get

# 3. Generate platform directories (if not present)
flutter create . --platforms android,ios

# 4. Run the app (with a connected device or emulator)
flutter run
```

## Building the App

### Debug

```bash
flutter run
```

### Release — Android

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

### Release — iOS

```bash
flutter build ios --release
```

Requires a valid Apple Developer account and provisioning profile.

## Running Tests

### All tests

```bash
flutter test
```

### Specific test file

```bash
flutter test test/core/poker_test.dart
```

### With verbose output

```bash
flutter test --reporter=expanded
```

### Generate test report

```bash
bash test/run_tests.sh
```

This saves timestamped output to `test/results/test_output_YYYYMMDD_HHMMSS.txt` and prints a pass/fail summary.

### Run a single test by name

```bash
flutter test --reporter=expanded --name='Royal Flush' test/core/poker_test.dart
```

## Test Architecture

Tests are organized in three layers:

### Unit Tests (`test/core/`)

| File | Covers | Key Tests |
|------|--------|-----------|
| `poker_test.dart` | Hand evaluator engine | All 10 hand categories, kicker comparison, 1081 holdings ranking, equivalence class grouping, labels, board dealing |
| `scoring_test.dart` | Scoring engine | Perfect/partial/wrong/missing scoring, speed rating thresholds, board texture analysis, suit sensitivity |
| `game_state_test.dart` | State models | Stats calculation, streak logic, suit sensitivity averages, model defaults and copyWith |
| `providers_test.dart` | Riverpod providers | DrillConfigNotifier, CurrentHoldingsNotifier (add/remove/reorder/clear/undo), TimerNotifier, equivalenceClassesProvider, lastResultProvider |

### Widget Tests (`test/ui/screens/`, `test/ui/components/`)

| File | Covers | Key Tests |
|------|--------|-----------|
| `home_screen_test.dart` | Home dashboard | Greeting, stats cards, recent drills, empty state, Start Drill button |
| `drill_config_screen_test.dart` | Config screen | Holdings options, timer toggle, picker mode, Deal button |
| `drill_screen_test.dart` | Drill screen | Board display, rank buttons, holdings counter, progress bar, toolbar buttons |
| `results_screen_test.dart` | Results screen | Score ring, comparison rows, stats, speed stars, action buttons |
| `stats_screen_test.dart` | Stats screen | Stats grid, suit sensitivity, drill history list |
| `settings_screen_test.dart` | Settings screen | Player name, dark mode, defaults, reset dialog, about section |
| `score_ring_test.dart` | ScoreRing widget | 0%/50%/100% rendering, custom colors, sizes, animation |

### Shared Utilities (`test/helpers/`)

`test_helpers.dart` provides:
- `createTestBoard()`, `createRainbowBoard()`, `createSuitSensitiveBoard()` etc. — deterministic boards
- `createTestDrillRecord()` — factory for test drill records with configurable fields
- `createProviderOverrides()` — standard Riverpod overrides that bypass the database
- `pumpScreen()` / `pumpFullScreen()` — wraps widgets in `MaterialApp` + `ProviderScope` for testing

## Troubleshooting Failed Tests

### Reading test output

The `--reporter=expanded` flag shows each test with a pass/fail indicator:
- `✓` — passed
- `✗` — failed (with error message and stack trace)

### Using the app_logger for debugging

In tests, enable log capture to inspect what the app logged:

```dart
setUp(() {
  AppLogger.enableTestMode();
});

tearDown(() {
  if (someCondition) {
    print(AppLogger.dumpCapturedLogs()); // Print all captured logs
  }
  AppLogger.disableTestMode();
});

// Query specific logs
final errors = AppLogger.queryLogs(
  module: 'scoring',
  level: AppLogLevel.error,
);
```

### Running a single failing test

```bash
flutter test --reporter=expanded --name='Royal Flush > Straight Flush' test/core/poker_test.dart
```

### Feeding results back for AI-assisted troubleshooting

1. Run `bash test/run_tests.sh`
2. Copy the output file from `test/results/`
3. Share it for analysis — the file contains full test output, pass/fail counts, and timestamps

## Design System

The app uses a token-driven design system with 8 token categories:

| Token | File | Purpose |
|-------|------|---------|
| Color | `color_tokens.dart` | Graphite, steel, cyan, lime, amber, red, violet, teal palettes |
| Typography | `typography_tokens.dart` | Inter (UI) + JetBrains Mono (data) via Google Fonts |
| Spacing | `spacing_tokens.dart` | 2px–48px scale (xxs through section) |
| Radius | `radius_tokens.dart` | 6px–pill scale (xs through circle) |
| Motion | `motion_tokens.dart` | 80ms–420ms durations with easing curves |
| Elevation | `elevation_tokens.dart` | Card, panel, modal, toast elevation levels |
| Opacity | `opacity_tokens.dart` | Standard opacity values for overlays and states |
| Stroke | `stroke_tokens.dart` | 1px–3px border widths |

Three `ThemeExtension` types extend Material 3:
- `SciFiSemanticColors` — role-based colors (positive, warning, critical, etc.)
- `SciFiSessionTheme` — drill session-specific theming (ring, track, flash colors)
- `SciFiEffectsTheme` — glow, shadow, and scanline effect parameters

**Rule**: Never hardcode colors — always use `colorScheme`, `AppColors`, or `ThemeExtension` values.

## Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.22+ | Cross-platform UI framework |
| Dart | 3.4+ | Programming language |
| Riverpod | 2.5+ | State management (StateNotifier pattern) |
| GoRouter | 14.2+ | Declarative routing with ShellRoute |
| sqflite | 2.3+ | Local SQLite persistence |
| Google Fonts | 6.2+ | Inter + JetBrains Mono typefaces |
| Material 3 | Built-in | Design system foundation |
| logger | 2.3+ | Structured logging with test capture |
| mockito | 5.4+ | Test mocking (dev dependency) |
| flutter_test | SDK | Widget and unit testing |

## 4-Color Suit System

Cards use a 4-color suit rendering:

| Suit | Symbol | Color |
|------|--------|-------|
| Spades | ♠ | White (onSurface) |
| Hearts | ♥ | Red (#FF5A5F) |
| Diamonds | ♦ | Blue (#5FA8FF) |
| Clubs | ♣ | Green (#4CAF50) |

## License

All rights reserved.
