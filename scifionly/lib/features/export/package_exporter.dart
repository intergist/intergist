/// Creates exportable packages from cue tracks and manifests.
///
/// Supports three export modes:
/// - User riffs only (SRT)
/// - Riff pack (SRT + manifest)
/// - Full package (ZIP with all tracks + manifest)
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/export/models/export_result.dart';
import 'package:scifionly/features/export/srt_exporter.dart';
import 'package:scifionly/models/manifest.dart';
import 'package:scifionly/models/project.dart';
import 'package:scifionly/utils/logger.dart';

const String _tag = LogTag.export_;

/// Exports cue packages in various formats.
///
/// Uses [SrtExporter] to convert individual tracks and the `archive`
/// package to produce ZIP bundles.
class PackageExporter {
  final SrtExporter _srtExporter;

  const PackageExporter({
    SrtExporter srtExporter = const SrtExporter(),
  }) : _srtExporter = srtExporter;

  /// Export user riffs as a standalone SRT file.
  ///
  /// Returns an [ExportResult] with the SRT content string.
  ExportResult exportUserRiffs(CueTrack userTrack) {
    AppLogger.info(
      _tag,
      'Exporting user riffs: ${userTrack.length} cues from '
      'track "${userTrack.trackId}"',
    );

    if (userTrack.isEmpty) {
      AppLogger.warn(_tag, 'User riff track is empty; nothing to export');
      return ExportResult.failure('No user riffs to export.');
    }

    final srtResult = _srtExporter.export(userTrack);

    if (!srtResult.success) {
      AppLogger.error(
        _tag,
        'Failed to export user riffs: ${srtResult.errorMessage}',
      );
      return srtResult;
    }

    AppLogger.info(
      _tag,
      'User riff export complete: ${srtResult.cueCount} cues',
    );

    return srtResult;
  }

  /// Export a riff pack (riff track SRT + manifest JSON) as a ZIP.
  ///
  /// [riffTrack] is the pre-authored riff track.
  /// [manifest] is the package manifest to include.
  ExportResult exportRiffPack(CueTrack riffTrack, Manifest manifest) {
    AppLogger.info(
      _tag,
      'Exporting riff pack: "${manifest.title}" '
      '(${riffTrack.length} cues)',
    );

    if (riffTrack.isEmpty) {
      return ExportResult.failure('Riff track is empty; nothing to export.');
    }

    final warnings = <String>[];
    final includedFiles = <String>[];
    final archive = Archive();

    // Add manifest.json.
    final manifestJson = _encodeManifest(manifest);
    final manifestBytes = utf8.encode(manifestJson);
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    includedFiles.add('manifest.json');

    // Add riff track SRT.
    final riffFilename = manifest.riffTrack?.file ?? 'riff.srt';
    final srtResult = _srtExporter.export(riffTrack);

    if (!srtResult.success || srtResult.content == null) {
      return ExportResult.failure(
        'Failed to export riff track: '
        '${srtResult.errorMessage ?? "unknown error"}',
      );
    }

    final srtBytes = utf8.encode(srtResult.content!);
    archive.addFile(
      ArchiveFile(riffFilename, srtBytes.length, srtBytes),
    );
    includedFiles.add(riffFilename);

    // Encode ZIP.
    final zipBytes = _encodeArchive(archive);
    if (zipBytes == null) {
      return ExportResult.failure('Failed to encode ZIP archive.');
    }

    AppLogger.info(
      _tag,
      'Riff pack exported: ${zipBytes.length} bytes, '
      '${includedFiles.length} files',
    );

    return ExportResult.zipBytes(
      bytes: zipBytes,
      cueCount: srtResult.cueCount,
      trackCount: 1,
      includedFiles: includedFiles,
      warnings: warnings,
    );
  }

  /// Export a full package with all tracks as a ZIP.
  ///
  /// [project] provides metadata for the export.
  /// [tracks] maps filename to CueTrack for each track to include.
  /// [manifest] is the package manifest.
  ExportResult exportFullPackage(
    Project project,
    Map<String, CueTrack> tracks,
    Manifest manifest,
  ) {
    AppLogger.info(
      _tag,
      'Exporting full package for "${project.title}" '
      '(${tracks.length} tracks)',
    );

    if (tracks.isEmpty) {
      return ExportResult.failure('No tracks to export.');
    }

    final warnings = <String>[];
    final includedFiles = <String>[];
    int totalCueCount = 0;
    final archive = Archive();

    // Add manifest.json.
    final manifestJson = _encodeManifest(manifest);
    final manifestBytes = utf8.encode(manifestJson);
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    includedFiles.add('manifest.json');

    // Add each track as an SRT file.
    for (final entry in tracks.entries) {
      final filename = entry.key;
      final track = entry.value;

      final srtResult = _srtExporter.export(track);

      if (!srtResult.success || srtResult.content == null) {
        warnings.add(
          'Failed to export track "$filename": '
          '${srtResult.errorMessage ?? "unknown error"}',
        );
        AppLogger.warn(_tag, 'Skipping failed track: $filename');
        continue;
      }

      final srtBytes = utf8.encode(srtResult.content!);
      archive.addFile(
        ArchiveFile(filename, srtBytes.length, srtBytes),
      );
      includedFiles.add(filename);
      totalCueCount += srtResult.cueCount;
    }

    // Validate that manifest-referenced tracks were included.
    _validateManifestTracks(manifest, tracks, warnings);

    // Encode ZIP.
    final zipBytes = _encodeArchive(archive);
    if (zipBytes == null) {
      return ExportResult.failure('Failed to encode ZIP archive.');
    }

    AppLogger.info(
      _tag,
      'Full package exported: ${zipBytes.length} bytes, '
      '$totalCueCount cues, ${includedFiles.length} files',
    );

    return ExportResult.zipBytes(
      bytes: zipBytes,
      cueCount: totalCueCount,
      trackCount: tracks.length,
      includedFiles: includedFiles,
      warnings: warnings,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Serialize a [Manifest] to a pretty-printed JSON string.
  String _encodeManifest(Manifest manifest) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(manifest.toJson());
  }

  /// Encode an [Archive] to ZIP bytes.
  ///
  /// Returns null on failure and logs the error.
  Uint8List? _encodeArchive(Archive archive) {
    try {
      final encoded = ZipEncoder().encode(archive);
      if (encoded == null) {
        AppLogger.error(_tag, 'ZIP encoder returned null');
        return null;
      }
      return Uint8List.fromList(encoded);
    } catch (e, stackTrace) {
      AppLogger.error(_tag, 'Failed to encode ZIP: $e', stackTrace);
      return null;
    }
  }

  /// Check that all tracks referenced in the manifest have corresponding
  /// entries in the [tracks] map, adding warnings for any missing.
  void _validateManifestTracks(
    Manifest manifest,
    Map<String, CueTrack> tracks,
    List<String> warnings,
  ) {
    // Check reference track.
    if (!tracks.containsKey(manifest.referenceTrack.file)) {
      warnings.add(
        'Manifest reference track "${manifest.referenceTrack.file}" '
        'has no corresponding CueTrack.',
      );
    }

    // Check riff track if present.
    if (manifest.riffTrack != null &&
        !tracks.containsKey(manifest.riffTrack!.file)) {
      warnings.add(
        'Manifest riff track "${manifest.riffTrack!.file}" '
        'has no corresponding CueTrack.',
      );
    }

    // Check user track if present.
    if (manifest.userTrack != null &&
        !tracks.containsKey(manifest.userTrack!.file)) {
      warnings.add(
        'Manifest user track "${manifest.userTrack!.file}" '
        'has no corresponding CueTrack.',
      );
    }
  }
}
