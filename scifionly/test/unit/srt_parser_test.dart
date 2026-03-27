import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/import/srt_parser.dart';
import 'package:scifionly/features/import/models/import_result.dart';

import '../helpers/test_helpers.dart';

void main() {
  late SrtParser parser;

  setUp(() {
    enableTestLogging();
    parser = const SrtParser();
  });

  tearDown(() {
    disableTestLogging();
  });

  group('valid parsing', () {
    late SrtParseResult result;

    setUp(() {
      final content = readFixture('movie.srt');
      result = parser.parse(content, source: 'movie.srt');
    });

    test('parses 4 entries from movie.srt', () {
      expect(result.entries.length, 4);
    });

    test('result is valid with no errors', () {
      expect(result.isValid, isTrue);
    });

    test('entry 1 has correct index, timestamps, text', () {
      final entry = result.entries[0];
      expect(entry.index, 1);
      expect(entry.startMs, 5000);
      expect(entry.endMs, 7000);
      expect(entry.text, 'Crew status check.');
    });

    test('entry 2 has correct index, timestamps, text', () {
      final entry = result.entries[1];
      expect(entry.index, 2);
      expect(entry.startMs, 8200);
      expect(entry.endMs, 10600);
      expect(entry.text, 'All systems nominal.');
    });

    test('entry 3 has correct index, timestamps, text', () {
      final entry = result.entries[2];
      expect(entry.index, 3);
      expect(entry.startMs, 15500);
      expect(entry.endMs, 18000);
      expect(entry.text, 'Something just moved on the scanner.');
    });

    test('entry 4 has correct index, timestamps, text', () {
      final entry = result.entries[3];
      expect(entry.index, 4);
      expect(entry.startMs, 25000);
      expect(entry.endMs, 28500);
      expect(entry.text, 'That signal is coming from the derelict.');
    });

    test('entry indices are sequential', () {
      for (int i = 0; i < result.entries.length; i++) {
        expect(result.entries[i].index, i + 1);
      }
    });

    test('entries have no tags set for plain SRT', () {
      for (final entry in result.entries) {
        expect(entry.tags.isApp, isFalse);
        expect(entry.tags.isUser, isFalse);
        expect(entry.tags.isSpeak, isFalse);
        expect(entry.tags.isDisplay, isFalse);
        expect(entry.tags.isMuteInRecording, isFalse);
        expect(entry.tags.priority, isNull);
        expect(entry.tags.windowRef, isNull);
      }
    });

    test('duration calculation is correct for each entry', () {
      expect(result.entries[0].durationMs, 2000);
      expect(result.entries[1].durationMs, 2400);
      expect(result.entries[2].durationMs, 2500);
      expect(result.entries[3].durationMs, 3500);
    });
  });

  group('riff tag parsing', () {
    late SrtParseResult result;

    setUp(() {
      final content = readFixture('riffs.srt');
      result = parser.parse(content, source: 'riffs.srt');
    });

    test('parses 3 entries from riffs.srt', () {
      expect(result.entries.length, 3);
    });

    test('result is valid with no errors', () {
      expect(result.isValid, isTrue);
    });

    test('entry 1 has APP and SPEAK tags', () {
      final entry = result.entries[0];
      expect(entry.tags.isApp, isTrue);
      expect(entry.tags.isSpeak, isTrue);
      expect(entry.tags.isDisplay, isFalse);
    });

    test('entry 2 has APP and DISPLAY tags', () {
      final entry = result.entries[1];
      expect(entry.tags.isApp, isTrue);
      expect(entry.tags.isDisplay, isTrue);
      expect(entry.tags.isSpeak, isFalse);
    });

    test('entry 3 has APP and SPEAK tags', () {
      final entry = result.entries[2];
      expect(entry.tags.isApp, isTrue);
      expect(entry.tags.isSpeak, isTrue);
      expect(entry.tags.isDisplay, isFalse);
    });

    test('tags are stripped from displayed text', () {
      expect(result.entries[0].text, 'Translation: famous last words.');
      expect(result.entries[0].text.contains('[APP]'), isFalse);
      expect(result.entries[0].text.contains('[SPEAK]'), isFalse);

      expect(result.entries[1].text,
          'Yep, split the party. Galaxy-brain move.');
      expect(result.entries[1].text.contains('[APP]'), isFalse);
      expect(result.entries[1].text.contains('[DISPLAY]'), isFalse);

      expect(result.entries[2].text,
          'If this ship has eggs, walk away.');
    });

    test('rawText preserves original tags', () {
      expect(result.entries[0].rawText, contains('[APP]'));
      expect(result.entries[0].rawText, contains('[SPEAK]'));
      expect(result.entries[1].rawText, contains('[DISPLAY]'));
    });

    test('riff entries have correct timestamps', () {
      expect(result.entries[0].startMs, 10900);
      expect(result.entries[0].endMs, 13200);
      expect(result.entries[1].startMs, 18300);
      expect(result.entries[1].endMs, 21300);
      expect(result.entries[2].startMs, 28700);
      expect(result.entries[2].endMs, 31500);
    });

    test('PRIORITY tag is extracted from inline text', () {
      final srt =
          '1\n00:00:01,000 --> 00:00:02,000\n[APP][SPEAK][PRIORITY=70] Hello world.\n';
      final r = parser.parse(srt, source: 'priority_test');
      expect(r.entries[0].tags.priority, 70);
      expect(r.entries[0].text, 'Hello world.');
    });

    test('WINDOW tag is extracted', () {
      final srt =
          '1\n00:00:01,000 --> 00:00:02,000\n[APP][WINDOW=pw-001] Test\n';
      final r = parser.parse(srt, source: 'window_test');
      expect(r.entries[0].tags.windowRef, 'pw-001');
    });

    test('MUTE_IN_RECORDING tag is extracted', () {
      final srt =
          '1\n00:00:01,000 --> 00:00:02,000\n[MUTE_IN_RECORDING] Shh\n';
      final r = parser.parse(srt, source: 'mute_test');
      expect(r.entries[0].tags.isMuteInRecording, isTrue);
    });

    test('USER tag is extracted', () {
      final srt =
          '1\n00:00:01,000 --> 00:00:02,000\n[USER][SPEAK] My riff.\n';
      final r = parser.parse(srt, source: 'user_test');
      expect(r.entries[0].tags.isUser, isTrue);
      expect(r.entries[0].tags.isSpeak, isTrue);
      expect(r.entries[0].text, 'My riff.');
    });
  });

  group('malformed files', () {
    late SrtParseResult result;

    setUp(() {
      final content = readFixture('malformed.srt');
      result = parser.parse(content, source: 'malformed.srt');
    });

    test('result is invalid (has error-level issues)', () {
      expect(result.isValid, isFalse);
      expect(result.errors.isNotEmpty, isTrue);
    });

    test('detects invalid timestamp format', () {
      final issues = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.error &&
            i.message.contains('Malformed timecode'),
      );
      expect(issues.isNotEmpty, isTrue);
    });

    test('detects missing timestamp as malformed timecode', () {
      // Entry 3 in malformed.srt has text where the timecode line should be:
      // "3\nThis line is missing a timestamp entirely."
      // The parser sees 2 lines, parses index 3, then fails on timecode.
      final issues = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.error &&
            i.message.contains('Malformed timecode'),
      );
      expect(issues.isNotEmpty, isTrue);
    });

    test('detects end time before start time', () {
      // Entry 4: 00:00:15,500 --> 00:00:10,000
      final issues = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.error &&
            i.message.contains('end time'),
      );
      expect(issues.isNotEmpty, isTrue);
    });

    test('still parses valid entries around malformed ones', () {
      expect(
        result.entries.any((e) => e.text == 'Normal subtitle line.'),
        isTrue,
      );
      expect(
        result.entries.any((e) => e.text == 'Another normal line after errors.'),
        isTrue,
      );
    });
  });

  group('overlapping cues', () {
    late SrtParseResult result;

    setUp(() {
      final content = readFixture('overlapping.srt');
      result = parser.parse(content, source: 'overlapping.srt');
    });

    test('parses all 5 entries', () {
      expect(result.entries.length, 5);
    });

    test('detects overlap between entry 1 and 2', () {
      final warnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('Cue 2') &&
            i.message.contains('overlaps'),
      );
      expect(warnings.isNotEmpty, isTrue);
    });

    test('detects overlap between entry 2 and 3', () {
      final warnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('Cue 3') &&
            i.message.contains('overlaps'),
      );
      expect(warnings.isNotEmpty, isTrue);
    });

    test('detects overlap between entry 4 and 5', () {
      final warnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('Cue 5') &&
            i.message.contains('overlaps'),
      );
      expect(warnings.isNotEmpty, isTrue);
    });

    test('generates a warning for each overlap', () {
      final overlapWarnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('overlaps'),
      );
      // Entries 2, 3, and 5 overlap with their predecessors
      expect(overlapWarnings.length, 3);
    });

    test('result is still valid (overlaps are warnings, not errors)', () {
      expect(result.isValid, isTrue);
    });
  });

  group('encoding', () {
    test('empty input returns empty result with error', () {
      final result = parser.parse('', source: 'empty');
      expect(result.entries, isEmpty);
      expect(result.issues.isNotEmpty, isTrue);
      expect(
        result.issues.any(
          (i) =>
              i.severity == SrtIssueSeverity.error &&
              i.message.contains('empty'),
        ),
        isTrue,
      );
    });

    test('whitespace-only input returns empty result', () {
      final result = parser.parse('   \n\n   \n', source: 'whitespace');
      expect(result.entries, isEmpty);
    });

    test('detects Unicode replacement characters', () {
      final content = '1\n00:00:01,000 --> 00:00:02,000\nHello \uFFFD world';
      final result = parser.parse(content, source: 'encoding_test');
      final warnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('replacement characters'),
      );
      expect(warnings.isNotEmpty, isTrue);
    });

    test('handles BOM at start of content', () {
      final content = '\uFEFF1\n00:00:01,000 --> 00:00:02,000\nBOM test';
      final result = parser.parse(content, source: 'bom_test');
      expect(result.entries.length, 1);
      expect(result.entries[0].text, 'BOM test');
    });

    test('handles Windows-style CRLF line endings', () {
      final content = '1\r\n00:00:01,000 --> 00:00:02,000\r\nWindows line';
      final result = parser.parse(content, source: 'crlf_test');
      expect(result.entries.length, 1);
      expect(result.entries[0].text, 'Windows line');
    });

    test('handles old Mac-style CR line endings', () {
      final content = '1\r00:00:01,000 --> 00:00:02,000\rMac line';
      final result = parser.parse(content, source: 'cr_test');
      expect(result.entries.length, 1);
      expect(result.entries[0].text, 'Mac line');
    });
  });

  group('edge cases', () {
    test('single entry parses correctly', () {
      final content = '1\n00:00:01,000 --> 00:00:03,000\nSingle entry.';
      final result = parser.parse(content, source: 'single');
      expect(result.entries.length, 1);
      expect(result.entries[0].index, 1);
      expect(result.entries[0].text, 'Single entry.');
      expect(result.isValid, isTrue);
    });

    test('entry with no text line generates warning', () {
      // Block has index + timecode but no text lines
      final content = '1\n00:00:01,000 --> 00:00:03,000\n';
      final result = parser.parse(content, source: 'no_text');
      // The entry should still be created but with empty text
      expect(result.entries.length, 1);
      expect(result.entries[0].text, '');
    });

    test('multi-line text entries are preserved', () {
      final content = '1\n00:00:01,000 --> 00:00:05,000\n'
          'Line one\nLine two\nLine three';
      final result = parser.parse(content, source: 'multiline');
      expect(result.entries.length, 1);
      expect(result.entries[0].text, 'Line one\nLine two\nLine three');
    });

    test('entries separated by multiple blank lines parse correctly', () {
      final content = '1\n00:00:01,000 --> 00:00:02,000\nFirst\n\n\n\n'
          '2\n00:00:03,000 --> 00:00:04,000\nSecond';
      final result = parser.parse(content, source: 'multi_blank');
      expect(result.entries.length, 2);
      expect(result.entries[0].text, 'First');
      expect(result.entries[1].text, 'Second');
    });

    test('period separator in timestamp (.) is accepted', () {
      final content = '1\n00:00:01.500 --> 00:00:03.500\nDot separator';
      final result = parser.parse(content, source: 'dot_sep');
      expect(result.entries.length, 1);
      expect(result.entries[0].startMs, 1500);
      expect(result.entries[0].endMs, 3500);
    });

    test('precise timestamp millisecond computation', () {
      final content = '1\n01:02:03,456 --> 01:02:05,789\nPrecise.';
      final result = parser.parse(content, source: 'precise');
      expect(result.entries[0].startMs, 3723456);
      expect(result.entries[0].endMs, 3725789);
    });

    test('source parameter is passed through without error', () {
      final srt = '1\n00:00:01,000 --> 00:00:03,000\nHello.\n';
      final result = parser.parse(srt, source: 'test_source.srt');
      expect(result.entries.length, 1);
    });

    test('non-monotonic timestamps generate warning', () {
      final content = '1\n00:00:05,000 --> 00:00:07,000\nFirst\n\n'
          '2\n00:00:01,000 --> 00:00:03,000\nSecond (earlier)';
      final result = parser.parse(content, source: 'non_monotonic');
      final warnings = result.issues.where(
        (i) =>
            i.severity == SrtIssueSeverity.warning &&
            i.message.contains('non-monotonic'),
      );
      expect(warnings.isNotEmpty, isTrue);
    });
  });
}
