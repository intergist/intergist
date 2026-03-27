// Poker Sharp — Game State Management

import 'poker.dart';
import 'scoring.dart';

enum PickerMode { twoStep, fullGrid }

class DrillConfig {
  final int holdingsCount; // 5, 10, 15, 20
  final bool timerEnabled;
  final PickerMode pickerMode;

  const DrillConfig({
    this.holdingsCount = 10,
    this.timerEnabled = true,
    this.pickerMode = PickerMode.twoStep,
  });

  DrillConfig copyWith({
    int? holdingsCount,
    bool? timerEnabled,
    PickerMode? pickerMode,
  }) {
    return DrillConfig(
      holdingsCount: holdingsCount ?? this.holdingsCount,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      pickerMode: pickerMode ?? this.pickerMode,
    );
  }
}

class DrillRecord {
  final String id;
  final DateTime date;
  final List<Card> board;
  final int targetCount;
  final PickerMode pickerMode;
  final bool timerEnabled;
  final int? timeTakenMs;
  final bool hintUsed;
  final List<({List<Card> cards, int rank})> userHoldings;
  final GroupedScoringResult? scoringResult;
  final BoardTexture? boardTexture;
  final bool suitSensitive;

  const DrillRecord({
    required this.id,
    required this.date,
    required this.board,
    required this.targetCount,
    required this.pickerMode,
    required this.timerEnabled,
    this.timeTakenMs,
    this.hintUsed = false,
    this.userHoldings = const [],
    this.scoringResult,
    this.boardTexture,
    this.suitSensitive = false,
  });
}

class AppSettings {
  final bool darkMode;
  final String playerName;
  final int defaultHoldingsCount;
  final bool defaultTimerEnabled;
  final PickerMode defaultPickerMode;
  final bool soundEnabled;
  final bool hapticEnabled;

  const AppSettings({
    this.darkMode = true,
    this.playerName = 'Player',
    this.defaultHoldingsCount = 10,
    this.defaultTimerEnabled = true,
    this.defaultPickerMode = PickerMode.twoStep,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  AppSettings copyWith({
    bool? darkMode,
    String? playerName,
    int? defaultHoldingsCount,
    bool? defaultTimerEnabled,
    PickerMode? defaultPickerMode,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      playerName: playerName ?? this.playerName,
      defaultHoldingsCount: defaultHoldingsCount ?? this.defaultHoldingsCount,
      defaultTimerEnabled: defaultTimerEnabled ?? this.defaultTimerEnabled,
      defaultPickerMode: defaultPickerMode ?? this.defaultPickerMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

const defaultConfig = DrillConfig();
const defaultSettings = AppSettings();

/// Generate a unique ID.
String generateId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final random = now.toRadixString(36) +
      (DateTime.now().microsecond).toRadixString(36).padLeft(4, '0');
  return random;
}

/// Stats calculation from drill history.
({
  int drillsToday,
  int streak,
  int longestStreak,
  int bestAccuracy,
  int totalDrills,
}) getStats(List<DrillRecord> history) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final drillsToday = history.where((d) {
    final drillDate = DateTime(d.date.year, d.date.month, d.date.day);
    return drillDate == today;
  }).length;

  // Current streak (consecutive days with at least 1 drill)
  int streak = 0;
  const dayMs = 86400000;
  var checkDate = today;

  while (true) {
    final hasForDay = history.any((d) {
      final drillDate = DateTime(d.date.year, d.date.month, d.date.day);
      return drillDate == checkDate;
    });
    if (hasForDay) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  // Longest streak
  int longestStreak = 0;
  if (history.isNotEmpty) {
    final allDates = history
        .map((d) => DateTime(d.date.year, d.date.month, d.date.day)
            .millisecondsSinceEpoch)
        .toSet()
        .toList()
      ..sort();

    int currentRun = 1;
    int maxRun = 1;
    for (int i = 1; i < allDates.length; i++) {
      if (allDates[i] - allDates[i - 1] == dayMs) {
        currentRun++;
        if (currentRun > maxRun) maxRun = currentRun;
      } else {
        currentRun = 1;
      }
    }
    longestStreak = maxRun;
  }

  // Best accuracy (last 7 days)
  final weekAgo = today.subtract(const Duration(days: 7));
  final recentDrills = history.where((d) => d.date.isAfter(weekAgo)).toList();
  final bestAccuracy = recentDrills.isNotEmpty
      ? recentDrills
          .map((d) => d.scoringResult?.percentage ?? 0)
          .reduce((a, b) => a > b ? a : b)
      : 0;

  final totalDrills = history.length;

  return (
    drillsToday: drillsToday,
    streak: streak,
    longestStreak: longestStreak,
    bestAccuracy: bestAccuracy,
    totalDrills: totalDrills,
  );
}

/// Calculate accuracy comparison between suit-sensitive and non-suit-sensitive boards.
({
  int? sensitiveAvg,
  int? nonSensitiveAvg,
  int sensitiveCount,
  int nonSensitiveCount,
}) getSuitSensitivity(List<DrillRecord> history) {
  final sensitive = history.where((d) => d.suitSensitive).toList();
  final nonSensitive = history.where((d) => !d.suitSensitive).toList();

  int? avg(List<DrillRecord> records) {
    if (records.isEmpty) return null;
    final sum = records.fold<int>(
        0, (acc, d) => acc + (d.scoringResult?.percentage ?? 0));
    return (sum / records.length).round();
  }

  return (
    sensitiveAvg: avg(sensitive),
    nonSensitiveAvg: avg(nonSensitive),
    sensitiveCount: sensitive.length,
    nonSensitiveCount: nonSensitive.length,
  );
}
