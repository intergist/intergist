/// Result models for import operations.
///
/// Contains [SrtParseResult], [ManifestParseResult], [PackageImportResult],
/// and [ImportValidationResult].
library;

import 'package:scifionly/models/manifest.dart';

// ---------------------------------------------------------------------------
// SRT types
// ---------------------------------------------------------------------------

/// Severity of an SRT validation issue.
enum SrtIssueSeverity { info, warning, error }

/// Parsed riff-track tags embedded in SRT text lines.
class SrtTags {
  final bool isApp;
  final bool isUser;
  final bool isSpeak;
  final bool isDisplay;
  final bool isMuteInRecording;
  final int? priority;
  final String? windowRef;

  const SrtTags({
    this.isApp = false,
    this.isUser = false,
    this.isSpeak = false,
    this.isDisplay = false,
    this.isMuteInRecording = false,
    this.priority,
    this.windowRef,
  });

  @override
  String toString() {
    return 'SrtTags(isApp: $isApp, isUser: $isUser, isSpeak: $isSpeak, '
        'isDisplay: $isDisplay, isMuteInRecording: $isMuteInRecording, '
        'priority: $priority, windowRef: $windowRef)';
  }
}

/// A single parsed SRT entry (subtitle cue).
class SrtEntry {
  final int index;
  final int startMs;
  final int endMs;

  /// Text with tags stripped.
  final String text;

  /// Original text including any embedded tags.
  final String rawText;

  final SrtTags tags;

  const SrtEntry({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.rawText,
    required this.tags,
  });

  /// Duration in milliseconds.
  int get durationMs => endMs - startMs;

  @override
  String toString() {
    return 'SrtEntry(index: $index, startMs: $startMs, endMs: $endMs, '
        'text: "$text")';
  }
}

/// A validation issue detected during SRT parsing.
class SrtValidationIssue {
  final SrtIssueSeverity severity;
  final String message;
  final int? lineNumber;

  const SrtValidationIssue({
    required this.severity,
    required this.message,
    this.lineNumber,
  });

  @override
  String toString() {
    final ln = lineNumber != null ? ' (line $lineNumber)' : '';
    return 'SrtValidationIssue(${severity.name}$ln: $message)';
  }
}

/// Result of parsing an SRT file.
class SrtParseResult {
  final List<SrtEntry> entries;
  final List<SrtValidationIssue> issues;

  const SrtParseResult({
    required this.entries,
    required this.issues,
  });

  /// True when no error-level issues were found.
  bool get isValid =>
      issues.every((i) => i.severity != SrtIssueSeverity.error);

  /// True when there are no issues at all.
  bool get isClean => issues.isEmpty;

  /// Convenience: only error-severity issues.
  List<SrtValidationIssue> get errors =>
      issues.where((i) => i.severity == SrtIssueSeverity.error).toList();

  /// Convenience: only warning-severity issues.
  List<SrtValidationIssue> get warnings =>
      issues.where((i) => i.severity == SrtIssueSeverity.warning).toList();
}

// ---------------------------------------------------------------------------
// Manifest types
// ---------------------------------------------------------------------------

/// A generic validation issue (used by manifest parser).
class ValidationIssue {
  final String field;
  final String message;
  final bool isError;

  const ValidationIssue({
    required this.field,
    required this.message,
    this.isError = true,
  });

  @override
  String toString() =>
      'ValidationIssue(field: $field, isError: $isError, message: $message)';
}

/// Result of parsing a manifest.json.
class ManifestParseResult {
  final Manifest? manifest;
  final List<ValidationIssue> issues;

  const ManifestParseResult({
    this.manifest,
    required this.issues,
  });

  /// True when the manifest parsed without any error-level issues.
  bool get isValid => manifest != null && issues.every((i) => !i.isError);

  /// Convenience: only error-level issues.
  List<ValidationIssue> get errors =>
      issues.where((i) => i.isError).toList();
}

// ---------------------------------------------------------------------------
// Package import types
// ---------------------------------------------------------------------------

/// Status of a package import operation.
enum PackageImportStatus { success, partialSuccess, failed }

/// Result of importing a cue package ZIP.
class PackageImportResult {
  final PackageImportStatus status;
  final Manifest? manifest;
  final Map<String, SrtParseResult> srtResults;
  final List<String> errors;
  final List<String> warnings;

  const PackageImportResult({
    required this.status,
    this.manifest,
    this.srtResults = const {},
    this.errors = const [],
    this.warnings = const [],
  });

  /// True when the import succeeded without errors.
  bool get isSuccess => status == PackageImportStatus.success;

  @override
  String toString() {
    return 'PackageImportResult(status: ${status.name}, '
        'errors: ${errors.length}, warnings: ${warnings.length})';
  }
}

// ---------------------------------------------------------------------------
// Import validation types
// ---------------------------------------------------------------------------

/// Severity for import validation messages.
enum ImportValidationSeverity { info, warning, error }

/// A user-friendly import validation message.
class ImportValidationMessage {
  final ImportValidationSeverity severity;
  final String title;
  final String detail;

  const ImportValidationMessage({
    required this.severity,
    required this.title,
    required this.detail,
  });

  @override
  String toString() =>
      'ImportValidationMessage(${severity.name}: $title — $detail)';
}

/// Result of validating import files.
class ImportValidationResult {
  final bool isValid;
  final List<ImportValidationMessage> messages;
  final SrtParseResult? srtResult;
  final ManifestParseResult? manifestResult;

  const ImportValidationResult({
    required this.isValid,
    required this.messages,
    this.srtResult,
    this.manifestResult,
  });

  /// Convenience: only error-level messages.
  List<ImportValidationMessage> get errors => messages
      .where((m) => m.severity == ImportValidationSeverity.error)
      .toList();

  /// Convenience: only warning-level messages.
  List<ImportValidationMessage> get warnings => messages
      .where((m) => m.severity == ImportValidationSeverity.warning)
      .toList();
}
