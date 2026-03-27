import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/manifest_parser.dart';


void main() {
  const parser = ManifestParser();

  /// Build a valid manifest JSON map.
  Map<String, dynamic> validManifest() {
    return {
      'schemaVersion': '1.0',
      'packageId': 'scifionly.example.demo',
      'title': 'Demo Sci-Fi Film',
      'releaseYear': 2026,
      'locale': 'en-US',
      'referenceTrack': {
        'file': 'movie.srt',
        'type': 'srt',
        'language': 'en',
      },
      'riffTrack': {
        'file': 'riffs.srt',
        'type': 'srt',
        'language': 'en',
      },
      'timing': {
        'warningLeadInMs': 1500,
        'minParticipationWindowMs': 2500,
        'maxUserRiffMs': 7000,
      },
      'sync': {
        'anchorStrategy': 'hybrid_audio_and_text',
        'driftToleranceMs': 400,
        'lockConfidenceThreshold': 0.85,
      },
    };
  }

  group('valid manifest parsing', () {
    test('parses complete manifest from fixture', () {
      final content = File('test/fixtures/manifest.json').readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final result = parser.parse(json);

      expect(result.isValid, true);
      expect(result.manifest, isNotNull);
      expect(result.manifest!.title, 'Demo Sci-Fi Film');
      expect(result.manifest!.packageId, 'scifionly.example.demo');
      expect(result.manifest!.schemaVersion, '1.0');
      expect(result.manifest!.locale, 'en-US');
      expect(result.manifest!.releaseYear, 2026);
    });

    test('parses reference track', () {
      final result = parser.parse(validManifest());

      expect(result.manifest!.referenceTrack.file, 'movie.srt');
      expect(result.manifest!.referenceTrack.type, 'srt');
      expect(result.manifest!.referenceTrack.language, 'en');
    });

    test('parses riff track', () {
      final result = parser.parse(validManifest());

      expect(result.manifest!.riffTrack, isNotNull);
      expect(result.manifest!.riffTrack!.file, 'riffs.srt');
      expect(result.manifest!.riffTrack!.type, 'srt');
      expect(result.manifest!.riffTrack!.language, 'en');
    });

    test('parses timing section', () {
      final result = parser.parse(validManifest());

      expect(result.manifest!.timing.warningLeadInMs, 1500);
      expect(result.manifest!.timing.minParticipationWindowMs, 2500);
      expect(result.manifest!.timing.maxUserRiffMs, 7000);
    });

    test('parses sync section', () {
      final result = parser.parse(validManifest());

      expect(result.manifest!.sync.anchorStrategy, 'hybrid_audio_and_text');
      expect(result.manifest!.sync.driftToleranceMs, 400);
      expect(result.manifest!.sync.lockConfidenceThreshold, 0.85);
    });

    test('no issues for fully valid manifest', () {
      final result = parser.parse(validManifest());
      expect(result.issues, isEmpty);
    });

    test('parses manifest without optional sections', () {
      final json = validManifest();
      json.remove('riffTrack');
      json.remove('releaseYear');

      final result = parser.parse(json);
      expect(result.isValid, true);
      expect(result.manifest!.riffTrack, isNull);
      expect(result.manifest!.releaseYear, isNull);
    });
  });

  group('missing required fields', () {
    test('missing schemaVersion produces error', () {
      final json = validManifest();
      json.remove('schemaVersion');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'schemaVersion'),
        true,
      );
    });

    test('missing packageId produces error', () {
      final json = validManifest();
      json.remove('packageId');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'packageId'),
        true,
      );
    });

    test('missing title produces error', () {
      final json = validManifest();
      json.remove('title');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'title'),
        true,
      );
    });

    test('missing locale produces error', () {
      final json = validManifest();
      json.remove('locale');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'locale'),
        true,
      );
    });

    test('missing referenceTrack produces error', () {
      final json = validManifest();
      json.remove('referenceTrack');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'referenceTrack'),
        true,
      );
    });

    test('missing timing produces error', () {
      final json = validManifest();
      json.remove('timing');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'timing'),
        true,
      );
    });

    test('missing sync produces error', () {
      final json = validManifest();
      json.remove('sync');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field == 'sync'),
        true,
      );
    });
  });

  group('invalid field types', () {
    test('non-string schemaVersion produces error', () {
      final json = validManifest();
      json['schemaVersion'] = 1;

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) =>
            e.field == 'schemaVersion' && e.message.contains('string')),
        true,
      );
    });

    test('empty title produces error', () {
      final json = validManifest();
      json['title'] = '';

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any(
            (e) => e.field == 'title' && e.message.contains('empty')),
        true,
      );
    });

    test('referenceTrack as non-object produces error', () {
      final json = validManifest();
      json['referenceTrack'] = 'not an object';

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) =>
            e.field == 'referenceTrack' && e.message.contains('object')),
        true,
      );
    });

    test('timing as non-object produces error', () {
      final json = validManifest();
      json['timing'] = 'not an object';

      final result = parser.parse(json);
      expect(result.isValid, false);
    });

    test('sync as non-object produces error', () {
      final json = validManifest();
      json['sync'] = 42;

      final result = parser.parse(json);
      expect(result.isValid, false);
    });
  });

  group('track ref validation', () {
    test('referenceTrack missing file produces error', () {
      final json = validManifest();
      (json['referenceTrack'] as Map).remove('file');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field.contains('file')),
        true,
      );
    });

    test('referenceTrack missing type produces error', () {
      final json = validManifest();
      (json['referenceTrack'] as Map).remove('type');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field.contains('type')),
        true,
      );
    });

    test('referenceTrack missing language produces error', () {
      final json = validManifest();
      (json['referenceTrack'] as Map).remove('language');

      final result = parser.parse(json);
      expect(result.isValid, false);
      expect(
        result.errors.any((e) => e.field.contains('language')),
        true,
      );
    });

    test('riffTrack as non-object produces warning, not error', () {
      final json = validManifest();
      json['riffTrack'] = 'bad';

      final result = parser.parse(json);
      // riffTrack is optional, so non-object should be a warning
      final riffIssues = result.issues.where((e) => e.field == 'riffTrack');
      expect(riffIssues.isNotEmpty, true);
      expect(riffIssues.first.isError, false);
    });
  });

  group('optional sections', () {
    test('display section is parsed when present', () {
      final json = validManifest();
      json['display'] = {
        'theme': 'dark',
        'fontScale': 1.2,
        'countdownStyle': 'ring',
      };

      final result = parser.parse(json);
      expect(result.isValid, true);
      expect(result.manifest!.display, isNotNull);
      expect(result.manifest!.display!.theme, 'dark');
      expect(result.manifest!.display!.fontScale, 1.2);
      expect(result.manifest!.display!.countdownStyle, 'ring');
    });

    test('cueDefaults section is parsed when present', () {
      final json = validManifest();
      json['cueDefaults'] = {
        'channel': 'center',
        'priority': 50,
        'mode': 'speak',
      };

      final result = parser.parse(json);
      expect(result.isValid, true);
      expect(result.manifest!.cueDefaults, isNotNull);
      expect(result.manifest!.cueDefaults!.channel, 'center');
      expect(result.manifest!.cueDefaults!.priority, 50);
      expect(result.manifest!.cueDefaults!.mode, 'speak');
    });

    test('authoring section is parsed when present', () {
      final json = validManifest();
      json['authoring'] = {
        'creator': 'Test Author',
        'createdAt': '2026-03-27',
        'license': 'MIT',
        'notes': 'Test notes.',
      };

      final result = parser.parse(json);
      expect(result.isValid, true);
      expect(result.manifest!.authoring, isNotNull);
      expect(result.manifest!.authoring!.creator, 'Test Author');
      expect(result.manifest!.authoring!.license, 'MIT');
    });

    test('manifest without optional sections still parses', () {
      final json = validManifest();
      // No display, cueDefaults, or authoring
      final result = parser.parse(json);
      expect(result.isValid, true);
      expect(result.manifest!.display, isNull);
      expect(result.manifest!.cueDefaults, isNull);
      expect(result.manifest!.authoring, isNull);
    });
  });

  group('ManifestParseResult', () {
    test('isValid is true when manifest is present and no errors', () {
      final result = parser.parse(validManifest());
      expect(result.isValid, true);
      expect(result.manifest, isNotNull);
    });

    test('isValid is false when manifest is null', () {
      final result = parser.parse(<String, dynamic>{});
      expect(result.isValid, false);
      expect(result.manifest, isNull);
    });

    test('errors getter returns only error issues', () {
      final json = validManifest();
      json.remove('title');
      json.remove('locale');

      final result = parser.parse(json);
      expect(result.errors.length, greaterThanOrEqualTo(2));
      for (final error in result.errors) {
        expect(error.isError, true);
      }
    });
  });

  group('sync section details', () {
    test('parses optional candidateWindowMs', () {
      final json = validManifest();
      (json['sync'] as Map)['candidateWindowMs'] = 3000;

      final result = parser.parse(json);
      expect(result.manifest!.sync.candidateWindowMs, 3000);
    });

    test('parses precomputedAnchors', () {
      final json = validManifest();
      (json['sync'] as Map)['precomputedAnchors'] = [
        {'timeMs': 5000, 'fingerprint': 'abc'},
        {'timeMs': 10000, 'fingerprint': 'def'},
      ];

      final result = parser.parse(json);
      expect(result.manifest!.sync.precomputedAnchors, isNotNull);
      expect(result.manifest!.sync.precomputedAnchors!.length, 2);
    });
  });

  group('timing section details', () {
    test('parses optional cueAccuracyTargetMs', () {
      final json = validManifest();
      (json['timing'] as Map)['cueAccuracyTargetMs'] = 100;

      final result = parser.parse(json);
      expect(result.manifest!.timing.cueAccuracyTargetMs, 100);
    });

    test('parses optional reacquireTargetMs', () {
      final json = validManifest();
      (json['timing'] as Map)['reacquireTargetMs'] = 2000;

      final result = parser.parse(json);
      expect(result.manifest!.timing.reacquireTargetMs, 2000);
    });
  });
}
