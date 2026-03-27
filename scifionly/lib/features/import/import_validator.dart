/// Validates import files before ingestion.
///
/// Checks that files exist, are readable, have proper encoding, and that
/// their content passes SRT / manifest parsing validation. Returns
/// user-friendly [ImportValidationResult] messages.
library;

import 'dart:convert';
import 'dart:io';

import 'package:scifionly/features/import/manifest_parser.dart';
import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/features/import/srt_parser.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'IMPORT';

/// Validates import files and produces user-friendly diagnostics.
class ImportValidator {
  final SrtParser _srtParser;
  final ManifestParser _manifestParser;

  const ImportValidator({
    SrtParser srtParser = const SrtParser(),
    ManifestParser manifestParser = const ManifestParser(),
  })  : _srtParser = srtParser,
        _manifestParser = manifestParser;

  /// Validate a standalone SRT file.
  Future<ImportValidationResult> validateSrtFile(File file) async {
    AppLogger.info(_tag, 'Validating SRT file: ${file.path}');

    final messages = <ImportValidationMessage>[];

    // Check file exists.
    if (!await file.exists()) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'File not found',
        detail: 'The selected file does not exist or is not accessible.',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    // Check file size.
    final stat = await file.stat();
    if (stat.size == 0) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'Empty file',
        detail: 'The SRT file is empty.',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    if (stat.size > 10 * 1024 * 1024) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.warning,
        title: 'Large file',
        detail: 'The SRT file is larger than 10 MB. Import may be slow.',
      ));
    }

    // Try to read as UTF-8.
    final String content;
    try {
      content = await file.readAsString(encoding: utf8);
    } catch (e) {
      messages.add(ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'Encoding error',
        detail: 'Could not read file as UTF-8. '
            'Please re-save the file with UTF-8 encoding. ($e)',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    // Run SRT parser.
    final srtResult = _srtParser.parse(content, source: file.path);

    // Convert parser issues to user-friendly messages.
    for (final issue in srtResult.issues) {
      messages.add(ImportValidationMessage(
        severity: _mapSrtSeverity(issue.severity),
        title: _srtIssueTitle(issue),
        detail: issue.message,
      ));
    }

    if (srtResult.entries.isEmpty && srtResult.isValid) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.warning,
        title: 'No cues found',
        detail: 'The SRT file was parsed successfully but contains no cues.',
      ));
    }

    final isValid = !messages.any(
      (m) => m.severity == ImportValidationSeverity.error,
    );

    AppLogger.info(
      _tag,
      'SRT validation complete: valid=$isValid, '
      '${messages.length} messages',
    );

    return ImportValidationResult(
      isValid: isValid,
      messages: messages,
      srtResult: srtResult,
    );
  }

  /// Validate a manifest.json file.
  Future<ImportValidationResult> validateManifestFile(File file) async {
    AppLogger.info(_tag, 'Validating manifest file: ${file.path}');

    final messages = <ImportValidationMessage>[];

    if (!await file.exists()) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'File not found',
        detail: 'The manifest file does not exist or is not accessible.',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    final String content;
    try {
      content = await file.readAsString(encoding: utf8);
    } catch (e) {
      messages.add(ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'Encoding error',
        detail: 'Could not read manifest as UTF-8. ($e)',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      messages.add(ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'Invalid JSON',
        detail: 'The manifest file is not valid JSON. ($e)',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    final manifestResult = _manifestParser.parse(json);

    for (final issue in manifestResult.issues) {
      messages.add(ImportValidationMessage(
        severity: issue.isError
            ? ImportValidationSeverity.error
            : ImportValidationSeverity.warning,
        title: 'Manifest: ${issue.field}',
        detail: issue.message,
      ));
    }

    final isValid = !messages.any(
      (m) => m.severity == ImportValidationSeverity.error,
    );

    AppLogger.info(
      _tag,
      'Manifest validation complete: valid=$isValid, '
      '${messages.length} messages',
    );

    return ImportValidationResult(
      isValid: isValid,
      messages: messages,
      manifestResult: manifestResult,
    );
  }

  /// Validate a complete cue-package ZIP file.
  Future<ImportValidationResult> validatePackageFile(File file) async {
    AppLogger.info(_tag, 'Validating package file: ${file.path}');

    final messages = <ImportValidationMessage>[];

    if (!await file.exists()) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'File not found',
        detail: 'The package file does not exist or is not accessible.',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    final ext = file.path.toLowerCase();
    if (!ext.endsWith('.zip') && !ext.endsWith('.cuepkg')) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.warning,
        title: 'Unexpected file type',
        detail:
            'Expected a .zip or .cuepkg file. The import may still succeed.',
      ));
    }

    final stat = await file.stat();
    if (stat.size == 0) {
      messages.add(const ImportValidationMessage(
        severity: ImportValidationSeverity.error,
        title: 'Empty file',
        detail: 'The package file is empty.',
      ));
      return ImportValidationResult(isValid: false, messages: messages);
    }

    messages.add(ImportValidationMessage(
      severity: ImportValidationSeverity.info,
      title: 'File size',
      detail: '${(stat.size / 1024).toStringAsFixed(1)} KB',
    ));

    final isValid = !messages.any(
      (m) => m.severity == ImportValidationSeverity.error,
    );

    return ImportValidationResult(
      isValid: isValid,
      messages: messages,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ImportValidationSeverity _mapSrtSeverity(SrtIssueSeverity s) {
    switch (s) {
      case SrtIssueSeverity.info:
        return ImportValidationSeverity.info;
      case SrtIssueSeverity.warning:
        return ImportValidationSeverity.warning;
      case SrtIssueSeverity.error:
        return ImportValidationSeverity.error;
    }
  }

  String _srtIssueTitle(SrtValidationIssue issue) {
    switch (issue.severity) {
      case SrtIssueSeverity.info:
        return 'Info';
      case SrtIssueSeverity.warning:
        return 'Warning';
      case SrtIssueSeverity.error:
        return 'Parse error';
    }
  }
}
