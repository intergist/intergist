// Poker Sharp — Riverpod Providers

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'poker.dart';
import 'scoring.dart';
import 'game_state.dart';
import 'database_service.dart';

// --- Drill Config ---

class DrillConfigNotifier extends StateNotifier<DrillConfig> {
  DrillConfigNotifier() : super(defaultConfig);

  void setHoldingsCount(int count) {
    state = state.copyWith(holdingsCount: count);
  }

  void setTimerEnabled(bool enabled) {
    state = state.copyWith(timerEnabled: enabled);
  }

  void setPickerMode(PickerMode mode) {
    state = state.copyWith(pickerMode: mode);
  }

  void reset() {
    state = defaultConfig;
  }
}

final drillConfigProvider =
    StateNotifierProvider<DrillConfigNotifier, DrillConfig>(
  (ref) => DrillConfigNotifier(),
);

// --- App Settings ---

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(defaultSettings) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await DatabaseService.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await DatabaseService.saveSettings(settings);
  }

  Future<void> setDarkMode(bool value) async {
    await updateSettings(state.copyWith(darkMode: value));
  }

  Future<void> setPlayerName(String name) async {
    await updateSettings(state.copyWith(playerName: name));
  }

  Future<void> setDefaultHoldingsCount(int count) async {
    await updateSettings(state.copyWith(defaultHoldingsCount: count));
  }

  Future<void> setDefaultTimerEnabled(bool enabled) async {
    await updateSettings(state.copyWith(defaultTimerEnabled: enabled));
  }

  Future<void> setDefaultPickerMode(PickerMode mode) async {
    await updateSettings(state.copyWith(defaultPickerMode: mode));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await updateSettings(state.copyWith(soundEnabled: enabled));
  }

  Future<void> setHapticEnabled(bool enabled) async {
    await updateSettings(state.copyWith(hapticEnabled: enabled));
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

// --- Drill History ---

class DrillHistoryNotifier extends StateNotifier<List<DrillRecord>> {
  DrillHistoryNotifier() : super([]) {
    _loadDrills();
  }

  Future<void> _loadDrills() async {
    state = await DatabaseService.getDrills();
  }

  Future<void> addDrill(DrillRecord drill) async {
    await DatabaseService.saveDrill(drill);
    state = [drill, ...state];
  }

  Future<void> removeDrill(String id) async {
    await DatabaseService.deleteDrill(id);
    state = state.where((d) => d.id != id).toList();
  }

  Future<void> clearAll() async {
    await DatabaseService.clearDrills();
    state = [];
  }

  Future<void> refresh() async {
    state = await DatabaseService.getDrills();
  }
}

final drillHistoryProvider =
    StateNotifierProvider<DrillHistoryNotifier, List<DrillRecord>>(
  (ref) => DrillHistoryNotifier(),
);

// --- Current Board ---

final currentBoardProvider = StateProvider<List<Card>?>(
  (ref) => null,
);

// --- Equivalence Classes (computed from board + config) ---

final equivalenceClassesProvider = Provider<List<EquivalenceClass>>((ref) {
  final board = ref.watch(currentBoardProvider);
  final config = ref.watch(drillConfigProvider);
  if (board == null) return [];
  return groupIntoEquivalenceClasses(board, config.holdingsCount);
});

// --- Current Holdings (user selections) ---

class CurrentHoldingsNotifier extends StateNotifier<List<List<Card>>> {
  final List<List<List<Card>>> _undoStack = [];

  CurrentHoldingsNotifier() : super([]);

  void _pushUndo() {
    _undoStack.add(List<List<Card>>.from(state));
  }

  void add(List<Card> holding) {
    _pushUndo();
    state = [...state, holding];
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    _pushUndo();
    final newList = List<List<Card>>.from(state);
    newList.removeAt(index);
    state = newList;
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    _pushUndo();
    final newList = List<List<Card>>.from(state);
    final item = newList.removeAt(oldIndex);
    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newList.insert(adjustedNew, item);
    state = newList;
  }

  void clear() {
    if (state.isEmpty) return;
    _pushUndo();
    state = [];
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    state = _undoStack.removeLast();
  }

  bool get canUndo => _undoStack.isNotEmpty;
}

final currentHoldingsProvider =
    StateNotifierProvider<CurrentHoldingsNotifier, List<List<Card>>>(
  (ref) => CurrentHoldingsNotifier(),
);

// --- Timer ---

class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  TimerNotifier() : super(0);

  void start() {
    _timer?.cancel();
    state = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state += 100;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = 0;
  }

  int get elapsedMs => state;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, int>(
  (ref) => TimerNotifier(),
);

// --- Last Drill Result (for results screen) ---

class LastResultState {
  final List<Card> board;
  final GroupedScoringResult scoringResult;
  final int? timeTakenMs;
  final int targetCount;
  final bool hintUsed;

  const LastResultState({
    required this.board,
    required this.scoringResult,
    this.timeTakenMs,
    required this.targetCount,
    required this.hintUsed,
  });
}

final lastResultProvider = StateProvider<LastResultState?>(
  (ref) => null,
);

// --- Stats (computed from drillHistory) ---

final statsProvider = Provider((ref) {
  final history = ref.watch(drillHistoryProvider);
  return getStats(history);
});

// --- Suit Sensitivity (computed from drillHistory) ---

final suitSensitivityProvider = Provider((ref) {
  final history = ref.watch(drillHistoryProvider);
  return getSuitSensitivity(history);
});
