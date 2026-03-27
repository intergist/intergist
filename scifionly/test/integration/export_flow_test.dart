import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/srt_parser.dart';

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/export/srt_exporter.dart';

import 'package:scifionly/models/track.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SRT Export Flow', () {
    late SrtParser parser;
    late SrtExporter exporter;

    setUp(() {
      parser = const SrtParser();
      exporter = const SrtExporter();
    });

    group('export reference track to SRT', () {
      test('produces valid SRT content', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final exportResult = exporter.export(track);

        expect(exportResult.success, isTrue);
        expect(exportResult.content, isNotNull);
        expect(exportResult.content!.isNotEmpty, isTrue);
      });

      test('exported SRT can be re-parsed', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        expect(reParseResult.isValid, isTrue);
        expect(reParseResult.errors, isEmpty);
      });

      test('roundtrip preserves cue count', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        expect(reParseResult.entries.length, parseResult.entries.length);
      });

      test('roundtrip preserves text content', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        for (int i = 0; i < parseResult.entries.length; i++) {
          expect(
            reParseResult.entries[i].text,
            parseResult.entries[i].text,
            reason: 'Text mismatch at index $i',
          );
        }
      });

      test('roundtrip preserves timestamps', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        for (int i = 0; i < parseResult.entries.length; i++) {
          expect(
            reParseResult.entries[i].startMs,
            parseResult.entries[i].startMs,
            reason: 'startMs mismatch at index $i',
          );
          expect(
            reParseResult.entries[i].endMs,
            parseResult.entries[i].endMs,
            reason: 'endMs mismatch at index $i',
          );
        }
      });
    });

    group('export riff track to SRT', () {
      test('produces valid SRT with tags', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);

        expect(exportResult.success, isTrue);
        expect(exportResult.content, isNotNull);
      });

      test('exported riff SRT contains tag markers', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);
        final content = exportResult.content!;

        // Riff tracks should have [APP] and [SPEAK] tags preserved.
        expect(content.contains('[APP]'), isTrue);
        expect(content.contains('[SPEAK]'), isTrue);
      });

      test('roundtrip preserves riff tags', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        // Verify the re-parsed entries retain APP tag.
        for (final entry in reParseResult.entries) {
          expect(entry.tags.isApp, isTrue);
        }
      });

      test('roundtrip preserves SPEAK tag on spoken entries', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        // First and third entries had SPEAK tag.
        expect(reParseResult.entries[0].tags.isSpeak, isTrue);
        expect(reParseResult.entries[2].tags.isSpeak, isTrue);
      });

      test('roundtrip preserves riff text content', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        for (int i = 0; i < parseResult.entries.length; i++) {
          expect(
            reParseResult.entries[i].text,
            parseResult.entries[i].text,
            reason: 'Riff text mismatch at index $i',
          );
        }
      });

      test('roundtrip preserves riff timestamps', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final exportResult = exporter.export(track);
        final reParseResult = parser.parse(
          exportResult.content!,
          source: 'exported',
        );

        for (int i = 0; i < parseResult.entries.length; i++) {
          expect(
            reParseResult.entries[i].startMs,
            parseResult.entries[i].startMs,
            reason: 'Riff startMs mismatch at index $i',
          );
          expect(
            reParseResult.entries[i].endMs,
            parseResult.entries[i].endMs,
            reason: 'Riff endMs mismatch at index $i',
          );
        }
      });
    });

    group('export with test cues', () {
      test('exports manually created CueTrack', () {
        final cues = [
          createTestCue(
            id: 'cue-1',
            startMs: 5000,
            endMs: 8000,
            text: 'First test cue',
            priority: 50,
          ),
          createTestCue(
            id: 'cue-2',
            startMs: 10000,
            endMs: 13000,
            text: 'Second test cue',
            priority: 50,
          ),
          createTestCue(
            id: 'cue-3',
            startMs: 20000,
            endMs: 24000,
            text: 'Third test cue',
            priority: 50,
          ),
        ];

        final track = CueTrack(
          trackId: 'test-track',
          trackType: TrackType.riff,
          cues: cues,
        );

        final result = exporter.export(track);

        expect(result.success, isTrue);
        expect(result.content, isNotNull);
        expect(result.cueCount, 3);
      });

      test('exported content contains correct timecodes', () {
        final cues = [
          createTestCue(
            id: 'cue-1',
            startMs: 5000,
            endMs: 8000,
            text: 'Test cue',
          ),
        ];

        final track = CueTrack(
          trackId: 'test-track',
          trackType: TrackType.reference,
          cues: cues,
        );

        final result = exporter.export(track);
        final content = result.content!;

        expect(content.contains('00:00:05,000'), isTrue);
        expect(content.contains('00:00:08,000'), isTrue);
      });

      test('exports empty track as empty string', () {
        final track = CueTrack(
          trackId: 'empty-track',
          trackType: TrackType.reference,
        );

        final result = exporter.export(track);

        expect(result.success, isTrue);
        expect(result.content, '');
        expect(result.cueCount, 0);
      });
    });

    group('export result metadata', () {
      test('includes track filename in includedFiles', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final result = exporter.export(track);

        expect(result.includedFiles, contains('riff-001.srt'));
      });

      test('reports correct cue count', () {
        final riffSrt = readFixture('riffs.srt');
        final parseResult = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final result = exporter.export(track);

        expect(result.cueCount, 3);
      });

      test('isSuccess is true for successful export', () {
        final movieSrt = readFixture('movie.srt');
        final parseResult = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          parseResult.entries,
          TrackType.reference,
          'ref-001',
        );

        final result = exporter.export(track);

        expect(result.isSuccess, isTrue);
        expect(result.isFailed, isFalse);
      });
    });

    group('exportAll for multiple tracks', () {
      test('exports multiple tracks', () {
        final movieSrt = readFixture('movie.srt');
        final riffSrt = readFixture('riffs.srt');

        final refResult = parser.parse(movieSrt, source: 'movie.srt');
        final riffResult = parser.parse(riffSrt, source: 'riffs.srt');

        final refTrack = CueTrack.normalize(
          refResult.entries,
          TrackType.reference,
          'ref-001',
        );
        final riffTrack = CueTrack.normalize(
          riffResult.entries,
          TrackType.riff,
          'riff-001',
        );

        final results = exporter.exportAll([refTrack, riffTrack]);

        expect(results.length, 2);
        expect(results.containsKey('ref-001'), isTrue);
        expect(results.containsKey('riff-001'), isTrue);
        expect(results['ref-001']!.success, isTrue);
        expect(results['riff-001']!.success, isTrue);
      });
    });
  });
}
