/// Parses a manifest.json [Map] into a [Manifest] model.
///
/// Validates required fields and returns a [ManifestParseResult] containing
/// either a valid [Manifest] or a list of [ValidationIssue]s.
library;

import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/models/manifest.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'IMPORT';

/// Parses and validates manifest.json content.
class ManifestParser {
  const ManifestParser();

  /// Parse a decoded JSON map into a [ManifestParseResult].
  ManifestParseResult parse(Map<String, dynamic> json) {
    AppLogger.info(_tag, 'Parsing manifest.json');

    final List<ValidationIssue> issues = [];

    // ----- Required top-level fields -----

    final String? schemaVersion =
        _expectString(json, 'schemaVersion', issues);
    final String? packageId = _expectString(json, 'packageId', issues);
    final String? title = _expectString(json, 'title', issues);
    final String? locale = _expectString(json, 'locale', issues);

    // Optional top-level fields
    final int? releaseYear = json['releaseYear'] as int?;

    // ----- Reference track (required) -----

    ManifestTrackRef? referenceTrack;
    final dynamic rawRefTrack = json['referenceTrack'];
    if (rawRefTrack == null) {
      issues.add(const ValidationIssue(
        field: 'referenceTrack',
        message: 'Missing required field "referenceTrack".',
      ));
    } else if (rawRefTrack is! Map<String, dynamic>) {
      issues.add(const ValidationIssue(
        field: 'referenceTrack',
        message: '"referenceTrack" must be a JSON object.',
      ));
    } else {
      referenceTrack = _parseTrackRef(rawRefTrack, 'referenceTrack', issues);
    }

    // ----- Optional tracks -----

    ManifestTrackRef? riffTrack;
    final dynamic rawRiffTrack = json['riffTrack'];
    if (rawRiffTrack != null) {
      if (rawRiffTrack is! Map<String, dynamic>) {
        issues.add(const ValidationIssue(
          field: 'riffTrack',
          message: '"riffTrack" must be a JSON object.',
          isError: false,
        ));
      } else {
        riffTrack = _parseTrackRef(rawRiffTrack, 'riffTrack', issues);
      }
    }

    ManifestTrackRef? userTrack;
    final dynamic rawUserTrack = json['userTrack'];
    if (rawUserTrack != null) {
      if (rawUserTrack is! Map<String, dynamic>) {
        issues.add(const ValidationIssue(
          field: 'userTrack',
          message: '"userTrack" must be a JSON object.',
          isError: false,
        ));
      } else {
        userTrack = _parseTrackRef(rawUserTrack, 'userTrack', issues);
      }
    }

    // ----- Timing (required) -----

    ManifestTiming? timing;
    final dynamic rawTiming = json['timing'];
    if (rawTiming == null) {
      issues.add(const ValidationIssue(
        field: 'timing',
        message: 'Missing required field "timing".',
      ));
    } else if (rawTiming is! Map<String, dynamic>) {
      issues.add(const ValidationIssue(
        field: 'timing',
        message: '"timing" must be a JSON object.',
      ));
    } else {
      timing = _parseTiming(rawTiming, issues);
    }

    // ----- Sync (required) -----

    ManifestSync? sync;
    final dynamic rawSync = json['sync'];
    if (rawSync == null) {
      issues.add(const ValidationIssue(
        field: 'sync',
        message: 'Missing required field "sync".',
      ));
    } else if (rawSync is! Map<String, dynamic>) {
      issues.add(const ValidationIssue(
        field: 'sync',
        message: '"sync" must be a JSON object.',
      ));
    } else {
      sync = _parseSync(rawSync, issues);
    }

    // ----- Optional sections -----

    ManifestDisplay? display;
    if (json['display'] is Map<String, dynamic>) {
      try {
        display = ManifestDisplay.fromJson(
          json['display'] as Map<String, dynamic>,
        );
      } catch (e) {
        issues.add(ValidationIssue(
          field: 'display',
          message: 'Failed to parse display section: $e',
          isError: false,
        ));
      }
    }

    ManifestCueDefaults? cueDefaults;
    if (json['cueDefaults'] is Map<String, dynamic>) {
      try {
        cueDefaults = ManifestCueDefaults.fromJson(
          json['cueDefaults'] as Map<String, dynamic>,
        );
      } catch (e) {
        issues.add(ValidationIssue(
          field: 'cueDefaults',
          message: 'Failed to parse cueDefaults section: $e',
          isError: false,
        ));
      }
    }

    ManifestAuthoring? authoring;
    if (json['authoring'] is Map<String, dynamic>) {
      try {
        authoring = ManifestAuthoring.fromJson(
          json['authoring'] as Map<String, dynamic>,
        );
      } catch (e) {
        issues.add(ValidationIssue(
          field: 'authoring',
          message: 'Failed to parse authoring section: $e',
          isError: false,
        ));
      }
    }

    // ----- Build manifest if no errors -----

    final hasErrors = issues.any((i) => i.isError);

    if (hasErrors ||
        schemaVersion == null ||
        packageId == null ||
        title == null ||
        locale == null ||
        referenceTrack == null ||
        timing == null ||
        sync == null) {
      AppLogger.warn(
        _tag,
        'Manifest parse completed with ${issues.length} issues',
      );
      return ManifestParseResult(issues: issues);
    }

    final manifest = Manifest(
      schemaVersion: schemaVersion,
      packageId: packageId,
      title: title,
      releaseYear: releaseYear,
      locale: locale,
      referenceTrack: referenceTrack,
      riffTrack: riffTrack,
      userTrack: userTrack,
      timing: timing,
      sync: sync,
      display: display,
      cueDefaults: cueDefaults,
      authoring: authoring,
    );

    AppLogger.info(
      _tag,
      'Manifest parsed successfully: "${manifest.title}" '
      '(package: ${manifest.packageId})',
    );

    return ManifestParseResult(manifest: manifest, issues: issues);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extract and validate a required string field.
  String? _expectString(
    Map<String, dynamic> json,
    String key,
    List<ValidationIssue> issues,
  ) {
    final value = json[key];
    if (value == null) {
      issues.add(ValidationIssue(
        field: key,
        message: 'Missing required field "$key".',
      ));
      return null;
    }
    if (value is! String) {
      issues.add(ValidationIssue(
        field: key,
        message: '"$key" must be a string.',
      ));
      return null;
    }
    if (value.trim().isEmpty) {
      issues.add(ValidationIssue(
        field: key,
        message: '"$key" must not be empty.',
      ));
      return null;
    }
    return value;
  }

  /// Parse a ManifestTrackRef from JSON.
  ManifestTrackRef? _parseTrackRef(
    Map<String, dynamic> json,
    String fieldName,
    List<ValidationIssue> issues,
  ) {
    final file = json['file'] as String?;
    final type = json['type'] as String?;
    final language = json['language'] as String?;

    if (file == null || file.isEmpty) {
      issues.add(ValidationIssue(
        field: '$fieldName.file',
        message: 'Track ref "$fieldName" is missing required field "file".',
      ));
      return null;
    }
    if (type == null || type.isEmpty) {
      issues.add(ValidationIssue(
        field: '$fieldName.type',
        message: 'Track ref "$fieldName" is missing required field "type".',
      ));
      return null;
    }
    if (language == null || language.isEmpty) {
      issues.add(ValidationIssue(
        field: '$fieldName.language',
        message:
            'Track ref "$fieldName" is missing required field "language".',
      ));
      return null;
    }

    return ManifestTrackRef(
      file: file,
      type: type,
      language: language,
      hashSha256: json['hashSha256'] as String?,
      optional: json['optional'] as bool?,
    );
  }

  /// Parse ManifestTiming from JSON.
  ManifestTiming? _parseTiming(
    Map<String, dynamic> json,
    List<ValidationIssue> issues,
  ) {
    try {
      return ManifestTiming.fromJson(json);
    } catch (e) {
      issues.add(ValidationIssue(
        field: 'timing',
        message: 'Failed to parse timing: $e',
      ));
      return null;
    }
  }

  /// Parse ManifestSync from JSON.
  ManifestSync? _parseSync(
    Map<String, dynamic> json,
    List<ValidationIssue> issues,
  ) {
    try {
      return ManifestSync.fromJson(json);
    } catch (e) {
      issues.add(ValidationIssue(
        field: 'sync',
        message: 'Failed to parse sync: $e',
      ));
      return null;
    }
  }
}
