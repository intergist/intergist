/// Imports a cue-package ZIP file.
///
/// Reads the ZIP, extracts `manifest.json`, validates it and all referenced
/// SRT files, and returns a [PackageImportResult].
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:scifionly/features/import/manifest_parser.dart';
import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/features/import/srt_parser.dart';
import 'package:scifionly/models/manifest.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = 'IMPORT';

/// Imports a cue-package ZIP and returns structured results.
class PackageImporter {
  final SrtParser _srtParser;
  final ManifestParser _manifestParser;

  const PackageImporter({
    SrtParser srtParser = const SrtParser(),
    ManifestParser manifestParser = const ManifestParser(),
  })  : _srtParser = srtParser,
        _manifestParser = manifestParser;

  /// Import a cue-package from a ZIP file on disk.
  Future<PackageImportResult> importFromFile(File zipFile) async {
    AppLogger.info(_tag, 'Importing package from ${zipFile.path}');

    if (!await zipFile.exists()) {
      AppLogger.error(_tag, 'ZIP file does not exist: ${zipFile.path}');
      return const PackageImportResult(
        status: PackageImportStatus.failed,
        errors: ['ZIP file does not exist.'],
      );
    }

    final Uint8List bytes;
    try {
      bytes = await zipFile.readAsBytes();
    } catch (e) {
      AppLogger.error(_tag, 'Failed to read ZIP file: $e');
      return PackageImportResult(
        status: PackageImportStatus.failed,
        errors: ['Failed to read ZIP file: $e'],
      );
    }

    return importFromBytes(bytes);
  }

  /// Import a cue-package from raw ZIP bytes.
  PackageImportResult importFromBytes(Uint8List bytes) {
    AppLogger.info(_tag, 'Importing package from bytes (${bytes.length} bytes)');

    final List<String> errors = [];
    final List<String> warnings = [];

    // Decode the ZIP archive.
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      AppLogger.error(_tag, 'Failed to decode ZIP archive: $e');
      return PackageImportResult(
        status: PackageImportStatus.failed,
        errors: ['Invalid or corrupt ZIP archive: $e'],
      );
    }

    // Build a filename -> ArchiveFile lookup.
    final Map<String, ArchiveFile> fileMap = {};
    for (final file in archive) {
      // Normalise paths: strip leading slashes and directory prefixes.
      final name = _normalisePath(file.name);
      if (!file.isFile) continue;
      fileMap[name] = file;
    }

    // Locate manifest.json.
    final manifestFile = fileMap['manifest.json'];
    if (manifestFile == null) {
      AppLogger.error(_tag, 'manifest.json not found in archive');
      return const PackageImportResult(
        status: PackageImportStatus.failed,
        errors: ['Archive does not contain manifest.json.'],
      );
    }

    // Parse manifest.
    final Map<String, dynamic> manifestJson;
    try {
      final manifestContent = utf8.decode(manifestFile.content as List<int>);
      manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse manifest.json: $e');
      return PackageImportResult(
        status: PackageImportStatus.failed,
        errors: ['Failed to parse manifest.json: $e'],
      );
    }

    final manifestResult = _manifestParser.parse(manifestJson);

    if (!manifestResult.isValid) {
      final manifestErrors =
          manifestResult.errors.map((e) => 'Manifest: ${e.message}').toList();
      AppLogger.error(_tag, 'Manifest validation failed');
      return PackageImportResult(
        status: PackageImportStatus.failed,
        errors: manifestErrors,
      );
    }

    final manifest = manifestResult.manifest!;

    // Collect all track refs from the manifest.
    final trackRefs = <String, ManifestTrackRef>{};
    trackRefs[manifest.referenceTrack.file] = manifest.referenceTrack;
    if (manifest.riffTrack != null) {
      trackRefs[manifest.riffTrack!.file] = manifest.riffTrack!;
    }
    if (manifest.userTrack != null) {
      trackRefs[manifest.userTrack!.file] = manifest.userTrack!;
    }

    // Validate and parse referenced SRT files.
    final Map<String, SrtParseResult> srtResults = {};

    for (final entry in trackRefs.entries) {
      final filename = entry.key;
      final trackRef = entry.value;

      final srtFile = fileMap[filename];
      if (srtFile == null) {
        // If the track is marked optional, warn instead of error.
        if (trackRef.optional == true) {
          warnings.add('Optional track "$filename" not found in archive.');
          AppLogger.warn(
            _tag,
            'Optional track missing: $filename',
          );
        } else {
          errors.add('Track "$filename" referenced in manifest '
              'not found in archive.');
          AppLogger.error(
            _tag,
            'Missing referenced file: $filename',
          );
        }
        continue;
      }

      final String srtContent;
      try {
        srtContent = utf8.decode(srtFile.content as List<int>);
      } catch (e) {
        errors.add('Failed to decode "$filename": $e');
        AppLogger.error(
          _tag,
          'Failed to decode $filename: $e',
        );
        continue;
      }

      final result = _srtParser.parse(srtContent, source: filename);
      srtResults[filename] = result;

      if (!result.isValid) {
        errors.add('SRT file "$filename" has validation errors.');
      }

      for (final issue in result.warnings) {
        warnings.add('$filename: ${issue.message}');
      }
    }

    // Determine overall status.
    final PackageImportStatus status;
    if (errors.isEmpty) {
      status = PackageImportStatus.success;
    } else if (srtResults.isNotEmpty) {
      status = PackageImportStatus.partialSuccess;
    } else {
      status = PackageImportStatus.failed;
    }

    AppLogger.info(
      _tag,
      'Package import completed with status: ${status.name}',
    );

    return PackageImportResult(
      status: status,
      manifest: manifest,
      srtResults: srtResults,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Normalise a path inside a ZIP (strip leading slash / directory prefix).
  String _normalisePath(String path) {
    // Remove leading slashes.
    var normalised = path;
    while (normalised.startsWith('/')) {
      normalised = normalised.substring(1);
    }

    // If the file is inside a single top-level directory, strip it.
    // e.g. "package_name/manifest.json" -> "manifest.json"
    final parts = normalised.split('/');
    if (parts.length == 2 && !parts[0].contains('.')) {
      return parts[1];
    }

    return normalised;
  }
}
