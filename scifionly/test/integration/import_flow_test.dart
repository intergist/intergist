import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/srt_parser.dart';

import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/models/track.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SRT Import Flow', () {
    late SrtParser parser;
    late String movieSrt;

    setUp(() {
      parser = const SrtParser();
      movieSrt = readFixture('movie.srt');
    });

    group('parse movie.srt fixture', () {
      test('parses without errors', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('returns correct number of entries', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        expect(result.entries.length, 4);
      });

      test('first entry has correct text', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        expect(result.entries.first.text, 'Crew status check.');
      });

      test('last entry has correct text', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        expect(
          result.entries.last.text,
          'That signal is coming from the derelict.',
        );
      });

      test('first entry has correct timestamps', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        final first = result.entries.first;
        expect(first.startMs, 5000); // 00:00:05,000
        expect(first.endMs, 7000); // 00:00:07,000
      });

      test('last entry has correct timestamps', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        final last = result.entries.last;
        expect(last.startMs, 25000); // 00:00:25,000
        expect(last.endMs, 28500); // 00:00:28,500
      });

      test('entries are in chronological order', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        for (int i = 1; i < result.entries.length; i++) {
          expect(
            result.entries[i].startMs,
            greaterThanOrEqualTo(result.entries[i - 1].startMs),
          );
        }
      });

      test('all entries have sequential indices', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        for (int i = 0; i < result.entries.length; i++) {
          expect(result.entries[i].index, i + 1);
        }
      });
    });

    group('validate parsed SRT', () {
      test('valid SRT has no error issues', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        expect(result.isValid, isTrue);
        expect(result.isClean, isTrue);
      });

      test('all entries have positive durations', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');

        for (final entry in result.entries) {
          expect(entry.durationMs, greaterThan(0));
        }
      });
    });

    group('create CueTrack from parsed entries', () {
      test('creates track with correct cue count', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        expect(track.length, result.entries.length);
        expect(track.length, 4);
      });

      test('track has correct ID and type', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        expect(track.trackId, 'ref-001');
        expect(track.trackType, TrackType.reference);
      });

      test('first cue preserves original timestamps', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        final firstCue = track.allCues.first;
        expect(firstCue.startMs, 5000);
        expect(firstCue.endMs, 7000);
      });

      test('last cue preserves original timestamps', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        final lastCue = track.allCues.last;
        expect(lastCue.startMs, 25000);
        expect(lastCue.endMs, 28500);
      });

      test('reference track cues have dialogue kind', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        for (final cue in track.allCues) {
          expect(cue.kind.name, 'dialogue');
        }
      });

      test('track is not empty', () {
        final result = parser.parse(movieSrt, source: 'movie.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.reference,
          'ref-001',
        );

        expect(track.isEmpty, isFalse);
      });
    });

    group('parse riff track SRT', () {
      test('parses riff track with tags', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');

        expect(result.isValid, isTrue);
        expect(result.entries.length, 3);
      });

      test('extracts APP tag from riff entries', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');

        // All entries in riffs.srt have [APP] tag.
        for (final entry in result.entries) {
          expect(entry.tags.isApp, isTrue);
        }
      });

      test('extracts SPEAK tag', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');

        // Entry 1 and 3 have [SPEAK] tag.
        expect(result.entries[0].tags.isSpeak, isTrue);
        expect(result.entries[2].tags.isSpeak, isTrue);
      });

      test('extracts DISPLAY tag', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');

        // Entry 2 has [DISPLAY] tag.
        expect(result.entries[1].tags.isDisplay, isTrue);
      });

      test('strips tags from text content', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');

        // Text should not contain tag markers.
        for (final entry in result.entries) {
          expect(entry.text.contains('[APP]'), isFalse);
          expect(entry.text.contains('[SPEAK]'), isFalse);
          expect(entry.text.contains('[DISPLAY]'), isFalse);
        }
      });

      test('normalizes riff entries to CueTrack', () {
        final riffSrt = readFixture('riffs.srt');
        final result = parser.parse(riffSrt, source: 'riffs.srt');
        final track = CueTrack.normalize(
          result.entries,
          TrackType.riff,
          'riff-001',
        );

        expect(track.length, 3);
        expect(track.trackType, TrackType.riff);
      });
    });

    group('parse malformed SRT', () {
      test('detects errors in malformed SRT', () {
        final malformedSrt = readFixture('malformed.srt');
        final result = parser.parse(malformedSrt, source: 'malformed.srt');

        expect(result.errors.length, greaterThan(0));
      });

      test('still extracts valid entries from malformed SRT', () {
        final malformedSrt = readFixture('malformed.srt');
        final result = parser.parse(malformedSrt, source: 'malformed.srt');

        // Should extract at least the valid entries.
        expect(result.entries.length, greaterThan(0));
      });
    });

    group('parse overlapping SRT', () {
      test('detects overlapping timestamps', () {
        final overlappingSrt = readFixture('overlapping.srt');
        final result = parser.parse(
          overlappingSrt,
          source: 'overlapping.srt',
        );

        expect(result.warnings.length, greaterThan(0));
      });

      test('still parses all entries despite overlaps', () {
        final overlappingSrt = readFixture('overlapping.srt');
        final result = parser.parse(
          overlappingSrt,
          source: 'overlapping.srt',
        );

        expect(result.entries.length, 5);
      });
    });
  });
}
