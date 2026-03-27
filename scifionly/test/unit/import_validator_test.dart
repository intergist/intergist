import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/import_validator.dart';
import 'package:scifionly/features/import/models/import_result.dart';

void main() {
  const validator = ImportValidator();

  group('validateSrtFile', () {
    test('valid SRT file passes validation', () async {
      final file = File('test/fixtures/movie.srt');
      final result = await validator.validateSrtFile(file);

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
      expect(result.srtResult, isNotNull);
      expect(result.srtResult!.entries.length, 4);
    });

    test('non-existent file fails validation', () async {
      final file = File('test/fixtures/does_not_exist.srt');
      final result = await validator.validateSrtFile(file);

      expect(result.isValid, false);
      expect(result.errors.isNotEmpty, true);
      expect(
        result.errors.any((m) => m.title.contains('not found')),
        true,
      );
    });

    test('malformed SRT file produces errors', () async {
      final file = File('test/fixtures/malformed.srt');
      final result = await validator.validateSrtFile(file);

      expect(result.isValid, false);
      expect(result.errors.isNotEmpty, true);
    });

    test('overlapping SRT file is valid with warnings', () async {
      final file = File('test/fixtures/overlapping.srt');
      final result = await validator.validateSrtFile(file);

      expect(result.isValid, true);
      expect(result.warnings.isNotEmpty, true);
    });

    test('riffs SRT file passes validation', () async {
      final file = File('test/fixtures/riffs.srt');
      final result = await validator.validateSrtFile(file);

      expect(result.isValid, true);
      expect(result.srtResult, isNotNull);
      expect(result.srtResult!.entries.length, 3);
    });

    test('empty SRT file fails validation', () async {
      // Create a temporary empty file
      final tempDir = await Directory.systemTemp.createTemp('srt_test_');
      final emptyFile = File('${tempDir.path}/empty.srt');
      await emptyFile.writeAsString('');

      try {
        final result = await validator.validateSrtFile(emptyFile);
        expect(result.isValid, false);
        expect(
          result.messages.any((m) =>
              m.severity == ImportValidationSeverity.error &&
              m.title.contains('Empty')),
          true,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('validateManifestFile', () {
    test('valid manifest file passes validation', () async {
      final file = File('test/fixtures/manifest.json');
      final result = await validator.validateManifestFile(file);

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
      expect(result.manifestResult, isNotNull);
      expect(result.manifestResult!.manifest, isNotNull);
      expect(result.manifestResult!.manifest!.title, 'Demo Sci-Fi Film');
    });

    test('non-existent manifest file fails validation', () async {
      final file = File('test/fixtures/no_manifest.json');
      final result = await validator.validateManifestFile(file);

      expect(result.isValid, false);
      expect(result.errors.isNotEmpty, true);
    });

    test('invalid JSON manifest fails validation', () async {
      final tempDir = await Directory.systemTemp.createTemp('manifest_test_');
      final badJsonFile = File('${tempDir.path}/bad.json');
      await badJsonFile.writeAsString('{ not valid json }}}');

      try {
        final result = await validator.validateManifestFile(badJsonFile);
        expect(result.isValid, false);
        expect(
          result.errors.any((m) => m.title.contains('Invalid JSON')),
          true,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('manifest missing required fields fails validation', () async {
      final tempDir = await Directory.systemTemp.createTemp('manifest_test_');
      final incompleteFile = File('${tempDir.path}/incomplete.json');
      await incompleteFile.writeAsString('{"schemaVersion": "1.0"}');

      try {
        final result = await validator.validateManifestFile(incompleteFile);
        expect(result.isValid, false);
        expect(result.errors.isNotEmpty, true);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('validatePackageFile', () {
    test('non-existent package file fails', () async {
      final file = File('test/fixtures/nonexistent.zip');
      final result = await validator.validatePackageFile(file);

      expect(result.isValid, false);
      expect(result.errors.isNotEmpty, true);
    });

    test('empty package file fails', () async {
      final tempDir = await Directory.systemTemp.createTemp('pkg_test_');
      final emptyFile = File('${tempDir.path}/empty.zip');
      await emptyFile.writeAsBytes([]);

      try {
        final result = await validator.validatePackageFile(emptyFile);
        expect(result.isValid, false);
        expect(
          result.errors.any((m) => m.title.contains('Empty')),
          true,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('file with unexpected extension generates warning', () async {
      final tempDir = await Directory.systemTemp.createTemp('pkg_test_');
      final oddFile = File('${tempDir.path}/package.tar.gz');
      await oddFile.writeAsBytes([0x1F, 0x8B, 0x08, 0x00]); // some bytes

      try {
        final result = await validator.validatePackageFile(oddFile);
        expect(
          result.warnings.any((m) => m.title.contains('Unexpected file type')),
          true,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('ImportValidationResult', () {
    test('errors getter filters correctly', () {
      final result = ImportValidationResult(
        isValid: false,
        messages: [
          const ImportValidationMessage(
            severity: ImportValidationSeverity.error,
            title: 'Error 1',
            detail: 'detail',
          ),
          const ImportValidationMessage(
            severity: ImportValidationSeverity.warning,
            title: 'Warning 1',
            detail: 'detail',
          ),
          const ImportValidationMessage(
            severity: ImportValidationSeverity.info,
            title: 'Info 1',
            detail: 'detail',
          ),
        ],
      );

      expect(result.errors.length, 1);
      expect(result.errors[0].title, 'Error 1');
    });

    test('warnings getter filters correctly', () {
      final result = ImportValidationResult(
        isValid: true,
        messages: [
          const ImportValidationMessage(
            severity: ImportValidationSeverity.warning,
            title: 'Warn A',
            detail: 'detail',
          ),
          const ImportValidationMessage(
            severity: ImportValidationSeverity.warning,
            title: 'Warn B',
            detail: 'detail',
          ),
          const ImportValidationMessage(
            severity: ImportValidationSeverity.info,
            title: 'Info',
            detail: 'detail',
          ),
        ],
      );

      expect(result.warnings.length, 2);
    });
  });
}
