// Poker Sharp — Shared Test Utilities

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_sharp/core/poker.dart';
import 'package:poker_sharp/core/scoring.dart';
import 'package:poker_sharp/core/game_state.dart';
import 'package:poker_sharp/core/providers.dart';

// ---------------------------------------------------------------------------
// Deterministic test boards
// ---------------------------------------------------------------------------

/// A♠ K♠ Q♠ J♠ T♠ — Royal flush board (monotone spades)
List<Card> createRoyalFlushBoard() => const [
      Card(rank: 12, suit: 0), // A♠
      Card(rank: 11, suit: 0), // K♠
      Card(rank: 10, suit: 0), // Q♠
      Card(rank: 9, suit: 0), // J♠
      Card(rank: 8, suit: 0), // T♠
    ];

/// A♥ K♦ 7♣ 4♠ 2♥ — Rainbow, disconnected, unpaired
List<Card> createRainbowBoard() => const [
      Card(rank: 12, suit: 1), // A♥
      Card(rank: 11, suit: 2), // K♦
      Card(rank: 5, suit: 3), // 7♣
      Card(rank: 2, suit: 0), // 4♠
      Card(rank: 0, suit: 1), // 2♥
    ];

/// T♥ 9♥ 8♥ 7♦ 2♣ — Two-tone, semi-connected, suit-sensitive (3 hearts)
List<Card> createSuitSensitiveBoard() => const [
      Card(rank: 8, suit: 1), // T♥
      Card(rank: 7, suit: 1), // 9♥
      Card(rank: 6, suit: 1), // 8♥
      Card(rank: 5, suit: 2), // 7♦
      Card(rank: 0, suit: 3), // 2♣
    ];

/// K♠ K♥ 5♦ 5♣ 3♠ — Double-paired board
List<Card> createDoublePairedBoard() => const [
      Card(rank: 11, suit: 0), // K♠
      Card(rank: 11, suit: 1), // K♥
      Card(rank: 3, suit: 2), // 5♦
      Card(rank: 3, suit: 3), // 5♣
      Card(rank: 1, suit: 0), // 3♠
    ];

/// A♠ A♥ A♦ K♣ Q♠ — Trips on board
List<Card> createTripsBoard() => const [
      Card(rank: 12, suit: 0), // A♠
      Card(rank: 12, suit: 1), // A♥
      Card(rank: 12, suit: 2), // A♦
      Card(rank: 11, suit: 3), // K♣
      Card(rank: 10, suit: 0), // Q♠
    ];

/// Standard deterministic test board.
/// A♥ K♦ 7♣ 4♠ 2♥ — same as createRainbowBoard
List<Card> createTestBoard() => createRainbowBoard();

// ---------------------------------------------------------------------------
// DrillRecord factory
// ---------------------------------------------------------------------------

/// Create a test DrillRecord with configurable fields.
DrillRecord createTestDrillRecord({
  String? id,
  DateTime? date,
  List<Card>? board,
  int targetCount = 10,
  PickerMode pickerMode = PickerMode.twoStep,
  bool timerEnabled = true,
  int? timeTakenMs = 30000,
  bool hintUsed = false,
  int? percentageOverride,
  bool suitSensitive = false,
}) {
  final now = date ?? DateTime.now();
  final testBoard = board ?? createTestBoard();
  final percentage = percentageOverride ?? 70;

  return DrillRecord(
    id: id ?? 'test_${now.millisecondsSinceEpoch}',
    date: now,
    board: testBoard,
    targetCount: targetCount,
    pickerMode: pickerMode,
    timerEnabled: timerEnabled,
    timeTakenMs: timeTakenMs,
    hintUsed: hintUsed,
    userHoldings: const [],
    scoringResult: GroupedScoringResult(
      totalPoints: (percentage * targetCount * 2 / 100).round(),
      maxPoints: targetCount * 2,
      percentage: percentage,
      perPosition: const [],
      missedClasses: const [],
      isSuitSensitive: suitSensitive,
    ),
    boardTexture: analyzeBoardTexture(testBoard),
    suitSensitive: suitSensitive,
  );
}

// ---------------------------------------------------------------------------
// Provider override helpers for widget tests
// ---------------------------------------------------------------------------

/// Returns a list of standard provider overrides for widget tests.
/// Overrides database-dependent providers with in-memory defaults.
List<Override> createProviderOverrides({
  DrillConfig? config,
  AppSettings? settings,
  List<DrillRecord>? history,
  List<Card>? board,
  List<List<Card>>? holdings,
  LastResultState? lastResult,
}) {
  return [
    drillConfigProvider.overrideWith(
      (ref) {
        final notifier = DrillConfigNotifier();
        if (config != null) {
          notifier.setHoldingsCount(config.holdingsCount);
          notifier.setTimerEnabled(config.timerEnabled);
          notifier.setPickerMode(config.pickerMode);
        }
        return notifier;
      },
    ),
    appSettingsProvider.overrideWith(
      (ref) => _TestAppSettingsNotifier(settings ?? const AppSettings()),
    ),
    drillHistoryProvider.overrideWith(
      (ref) => _TestDrillHistoryNotifier(history ?? []),
    ),
    if (board != null)
      currentBoardProvider.overrideWith((ref) => board),
    if (lastResult != null)
      lastResultProvider.overrideWith((ref) => lastResult),
  ];
}

/// A test-friendly AppSettingsNotifier that doesn't touch the database.
class _TestAppSettingsNotifier extends AppSettingsNotifier {
  _TestAppSettingsNotifier(AppSettings initial) {
    state = initial;
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }
}

/// A test-friendly DrillHistoryNotifier that doesn't touch the database.
class _TestDrillHistoryNotifier extends DrillHistoryNotifier {
  _TestDrillHistoryNotifier(List<DrillRecord> initial) {
    state = initial;
  }

  @override
  Future<void> addDrill(DrillRecord drill) async {
    state = [drill, ...state];
  }

  @override
  Future<void> removeDrill(String id) async {
    state = state.where((d) => d.id != id).toList();
  }

  @override
  Future<void> clearAll() async {
    state = [];
  }
}

// ---------------------------------------------------------------------------
// Widget pump helpers
// ---------------------------------------------------------------------------

/// Pumps a widget wrapped in MaterialApp + ProviderScope with optional overrides.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget widget, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? createProviderOverrides(),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF35D9FF),
            brightness: Brightness.dark,
          ),
        ),
        home: Scaffold(body: widget),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps a screen widget wrapped in MaterialApp + ProviderScope (screen as full route).
Future<void> pumpFullScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? createProviderOverrides(),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF35D9FF),
            brightness: Brightness.dark,
          ),
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
