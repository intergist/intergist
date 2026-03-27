// Poker Sharp — Centralized Logging Utility
// Supports structured logging with module tags, level filtering,
// and a test mode that captures all logs to a buffer.

import 'package:logger/logger.dart';

/// Log levels used by AppLogger.
enum AppLogLevel {
  debug,
  info,
  warning,
  error,
}

/// A captured log entry for test assertions.
class CapturedLog {
  final String module;
  final AppLogLevel level;
  final String message;
  final dynamic data;
  final DateTime timestamp;

  CapturedLog({
    required this.module,
    required this.level,
    required this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] ${level.name.toUpperCase()} [$module] $message'
      '${data != null ? ': $data' : ''}';
}

/// Named loggers for each module with structured logging and test capture.
class AppLogger {
  // -------------------------------------------------------------------------
  // Test mode
  // -------------------------------------------------------------------------

  static bool _testMode = false;
  static final List<CapturedLog> _capturedLogs = [];
  static AppLogLevel _minLevel = AppLogLevel.debug;

  /// Enable test mode — all logs are captured to an in-memory buffer
  /// instead of printing to console. Call before running tests.
  static void enableTestMode() {
    _testMode = true;
    _capturedLogs.clear();
  }

  /// Disable test mode and resume normal logging.
  static void disableTestMode() {
    _testMode = false;
    _capturedLogs.clear();
  }

  /// Returns all captured logs (test mode only).
  static List<CapturedLog> get capturedLogs =>
      List.unmodifiable(_capturedLogs);

  /// Clear the captured log buffer.
  static void clearCapturedLogs() => _capturedLogs.clear();

  /// Dump captured logs as a formatted string for diagnostics.
  static String dumpCapturedLogs() {
    if (_capturedLogs.isEmpty) return '(no captured logs)';
    return _capturedLogs.map((l) => l.toString()).join('\n');
  }

  /// Set the minimum log level (logs below this level are suppressed).
  static void setMinLevel(AppLogLevel level) => _minLevel = level;

  /// Query captured logs by module and/or level.
  static List<CapturedLog> queryLogs({
    String? module,
    AppLogLevel? level,
    String? messageContains,
  }) {
    return _capturedLogs.where((log) {
      if (module != null && log.module != module) return false;
      if (level != null && log.level != level) return false;
      if (messageContains != null && !log.message.contains(messageContains)) {
        return false;
      }
      return true;
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Production loggers
  // -------------------------------------------------------------------------

  static final Logger _pokerEngine = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: ProductionFilter(),
  );

  static final Logger _scoring = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: ProductionFilter(),
  );

  static final Logger _database = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: ProductionFilter(),
  );

  static final Logger _ui = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: ProductionFilter(),
  );

  static final Logger _providers = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: ProductionFilter(),
  );

  static Logger get pokerEngine => _pokerEngine;
  static Logger get scoring => _scoring;
  static Logger get database => _database;
  static Logger get ui => _ui;
  static Logger get providers => _providers;

  // -------------------------------------------------------------------------
  // Structured logging methods
  // -------------------------------------------------------------------------

  static void debug(String module, String message, [dynamic data]) {
    _log(module, AppLogLevel.debug, message, data);
  }

  static void info(String module, String message, [dynamic data]) {
    _log(module, AppLogLevel.info, message, data);
  }

  static void warning(String module, String message, [dynamic data]) {
    _log(module, AppLogLevel.warning, message, data);
  }

  static void error(String module, String message, [dynamic data]) {
    _log(module, AppLogLevel.error, message, data);
  }

  /// Legacy method — routes to debug.
  static void testDiagnostic(String module, String message, [dynamic data]) {
    debug(module, message, data);
  }

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  static void _log(
      String module, AppLogLevel level, String message, dynamic data) {
    if (level.index < _minLevel.index) return;

    if (_testMode) {
      _capturedLogs.add(CapturedLog(
        module: module,
        level: level,
        message: message,
        data: data,
      ));
      return;
    }

    final logger = _loggerForModule(module);
    final formatted = '[$module] $message${data != null ? ': $data' : ''}';

    switch (level) {
      case AppLogLevel.debug:
        logger.d(formatted);
      case AppLogLevel.info:
        logger.i(formatted);
      case AppLogLevel.warning:
        logger.w(formatted);
      case AppLogLevel.error:
        logger.e(formatted);
    }
  }

  static Logger _loggerForModule(String module) {
    switch (module) {
      case 'poker_engine':
        return _pokerEngine;
      case 'scoring':
        return _scoring;
      case 'database':
        return _database;
      case 'ui':
        return _ui;
      case 'providers':
        return _providers;
      default:
        return _ui;
    }
  }
}
