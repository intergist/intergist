/// Structured logging system for SciFiOnly.
///
/// Provides leveled logging with component tags, timing support,
/// state-transition tracking, and a collector for test inspection.
library;

import 'package:flutter/foundation.dart';

/// Severity levels for log messages.
enum LogLevel { debug, info, warn, error }

/// A single structured log entry.
class LogEntry {
  /// Creates a log entry.
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.stackTrace,
    this.duration,
  });

  /// When the entry was recorded.
  final DateTime timestamp;

  /// Severity level.
  final LogLevel level;

  /// Component tag (e.g. [LogTag.cueEngine]).
  final String tag;

  /// Human-readable message.
  final String message;

  /// Optional stack trace (typically attached to errors).
  final StackTrace? stackTrace;

  /// Optional duration for timed operations.
  final Duration? duration;

  /// Formats the entry as an ISO-timestamped log line.
  ///
  /// Example: `2026-03-26T19:42:00.123Z [INFO] [CUE_ENGINE] message`
  @override
  String toString() {
    final ts = timestamp.toUtc().toIso8601String();
    final lvl = level.name.toUpperCase();
    final buf = StringBuffer('$ts [$lvl] [$tag] $message');
    if (stackTrace != null) {
      buf.writeln();
      buf.write(stackTrace);
    }
    return buf.toString();
  }
}

/// Collects log entries in-memory so tests (or diagnostics screens) can
/// inspect them.
class LogCollector {
  LogCollector._();

  /// Shared instance.
  static final LogCollector instance = LogCollector._();

  /// Recorded entries (oldest first).
  final List<LogEntry> entries = [];

  /// Whether the collector accepts new entries.
  bool isEnabled = false;

  /// Records [entry] if the collector is enabled.
  void add(LogEntry entry) {
    if (!isEnabled) return;
    entries.add(entry);
  }

  /// Removes all recorded entries.
  void clear() => entries.clear();

  /// Returns entries matching optional [level] and/or [tag] filters.
  List<LogEntry> where({LogLevel? level, String? tag}) {
    return entries.where((e) {
      if (level != null && e.level != level) return false;
      if (tag != null && e.tag != tag) return false;
      return true;
    }).toList();
  }

  /// All entries with [LogLevel.error].
  List<LogEntry> get errors => where(level: LogLevel.error);

  /// All entries with [LogLevel.warn].
  List<LogEntry> get warnings => where(level: LogLevel.warn);
}

/// Static structured logger used throughout the app.
///
/// ```dart
/// AppLogger.info(LogTag.cueEngine, 'Cue loaded');
/// AppLogger.error(LogTag.srtParser, 'Parse failed', stackTrace);
/// AppLogger.timed(LogTag.import_, 'File imported', elapsed);
/// ```
class AppLogger {
  AppLogger._();

  /// Messages below this level are silently discarded.
  static LogLevel minimumLevel = LogLevel.info;

  /// Whether to print to the debug console via [debugPrint].
  static bool consoleOutput = true;

  /// Placeholder for future file-based logging.
  static bool fileOutput = false;

  /// When `true`, entries are also forwarded to [LogCollector.instance].
  static bool collectorOutput = false;

  /// Logs a [LogLevel.debug] message.
  static void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  /// Logs a [LogLevel.info] message.
  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  /// Logs a [LogLevel.warn] message.
  static void warn(String tag, String message) {
    _log(LogLevel.warn, tag, message);
  }

  /// Logs a [LogLevel.error] message with an optional [stackTrace].
  static void error(String tag, String message, [StackTrace? stackTrace]) {
    _log(LogLevel.error, tag, message, stackTrace);
  }

  /// Logs a timed operation at [LogLevel.info], appending the elapsed
  /// [duration] in milliseconds.
  static void timed(String tag, String message, Duration duration) {
    _log(
      LogLevel.info,
      tag,
      '$message (${duration.inMilliseconds}ms)',
      null,
      duration,
    );
  }

  /// Convenience for logging state-machine transitions.
  static void stateTransition(
    String tag,
    String from,
    String to, {
    String? reason,
  }) {
    info(
      tag,
      'State transition: $from -> $to${reason != null ? ', $reason' : ''}',
    );
  }

  // ------------------------------------------------------------------
  // Internal
  // ------------------------------------------------------------------

  static void _log(
    LogLevel level,
    String tag,
    String message, [
    StackTrace? stackTrace,
    Duration? duration,
  ]) {
    if (level.index < minimumLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      stackTrace: stackTrace,
      duration: duration,
    );

    if (consoleOutput) {
      debugPrint(entry.toString());
    }

    if (collectorOutput) {
      LogCollector.instance.add(entry);
    }
  }
}

/// Well-known component tags.
///
/// Use these instead of free-form strings so that filtering is reliable.
abstract final class LogTag {
  static const srtParser = 'SRT_PARSER';
  static const cueEngine = 'CUE_ENGINE';
  static const sync = 'SYNC';
  static const session = 'SESSION';
  static const recording = 'RECORDING';
  static const import_ = 'IMPORT';
  static const export_ = 'EXPORT';
  static const ui = 'UI';
}
