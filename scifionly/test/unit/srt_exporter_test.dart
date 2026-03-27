import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/export/models/export_result.dart';
import 'package:scifionly/features/export/srt_exporter.dart';
import 'package:scifionly/features/import/srt_parser.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';

void main() {
  const exporter = SrtExporter();
  const parser = SrtParser();

  /// Helper to create a CueEventModel.
  CueEventModel makeCue({
    required String id,
    required int startMs,
    required int endMs,
    required String text,
    CueKind kind = CueKind.dialogue,
    CueMode mode = CueMode.displayOnly,
    int priority = 100,
    SpeakerRole speakerRole = SpeakerRole.narrator,
    String? windowRef,
    List<String> tags = const [],
    int? sourceIndex,
  }) {
    return CueEventModel(
      id: id,
      trackId: 'track-1',
      track: 'reference',
      startMs: startMs,
      endMs: endMs,
      text: text,
      kind: kind,
      mode: mode,
      priority: priority,
      speakerRole: speakerRole,
      windowRef: windowRef,
      interruptible: false,
      enabled: true,
      sourceIndex: sourceIndex,
      tags: tags,
    );
  }

  group('basic export', () {
    test('exports empty track to empty content', () {
      final track = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );

      final result = exporter.export(track);
      expect(result.success, true);
      expect(result.content, '');
      expect(result.cueCount, 0);
    });

    test('exports single cue with correct format', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 5000,
            endMs: 7000,
            text: 'Hello world.',
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.success, true);
      expect(result.cueCount, 1);

      final content = result.content!;
      expect(content, contains('1'));
      expect(content, contains('00:00:05,000 --> 00:00:07,000'));
      expect(content, contains('Hello world.'));
    });

    test('exports multiple cues with sequential indices', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 1000, endMs: 3000, text: 'First.'),
          makeCue(id: 'c2', startMs: 5000, endMs: 7000, text: 'Second.'),
          makeCue(id: 'c3', startMs: 10000, endMs: 12000, text: 'Third.'),
        ],
      );

      final result = exporter.export(track);
      expect(result.success, true);
      expect(result.cueCount, 3);

      final lines = result.content!.split('\n');
      // First index line should be "1"
      expect(lines[0], '1');
    });
  });

  group('timecode formatting', () {
    test('formats hours correctly', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 3723456, // 01:02:03,456
            endMs: 3725789, // 01:02:05,789
            text: 'Precise.',
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('01:02:03,456 --> 01:02:05,789'));
    });

    test('formats zero milliseconds correctly', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 0, endMs: 1000, text: 'Start.'),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('00:00:00,000 --> 00:00:01,000'));
    });

    test('pads small values correctly', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 100, endMs: 2005, text: 'Pad.'),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('00:00:00,100 --> 00:00:02,005'));
    });
  });

  group('reference track export', () {
    test('reference track cues have no tags', () {
      final track = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Plain dialogue.',
            speakerRole: SpeakerRole.narrator,
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('Plain dialogue.'));
      expect(result.content!.contains('[APP]'), false);
      expect(result.content!.contains('[SPEAK]'), false);
    });
  });

  group('riff track export with tags', () {
    test('exports APP and SPEAK tags for riff track', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Funny riff.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 50,
            speakerRole: SpeakerRole.app,
          ),
        ],
      );

      final result = exporter.export(track);
      final content = result.content!;
      expect(content, contains('[APP]'));
      expect(content, contains('[SPEAK]'));
      expect(content, contains('Funny riff.'));
    });

    test('exports DISPLAY tag for displayOnly riff', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Display riff.',
            kind: CueKind.riff,
            mode: CueMode.displayOnly,
            priority: 50,
            speakerRole: SpeakerRole.app,
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('[DISPLAY]'));
    });

    test('exports PRIORITY tag when non-default for riff track', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'High priority.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 80, // non-default (default for riff is 50)
            speakerRole: SpeakerRole.app,
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('[PRIORITY=80]'));
    });

    test('does not export PRIORITY tag when default for riff', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Default priority.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 50, // default for riff
            speakerRole: SpeakerRole.app,
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content!.contains('[PRIORITY='), false);
    });

    test('exports WINDOW tag when present', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Windowed.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 50,
            speakerRole: SpeakerRole.app,
            windowRef: 'pw-001',
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('[WINDOW=pw-001]'));
    });

    test('exports MUTE_IN_RECORDING tag when present in tags list', () {
      final track = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'Muted.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 50,
            speakerRole: SpeakerRole.app,
            tags: ['MUTE_IN_RECORDING'],
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('[MUTE_IN_RECORDING]'));
    });

    test('exports USER tag for user speaker role', () {
      final track = CueTrack(
        trackId: 'user',
        trackType: TrackType.userRiff,
        cues: [
          makeCue(
            id: 'c1',
            startMs: 1000,
            endMs: 3000,
            text: 'User riff.',
            kind: CueKind.userRiff,
            mode: CueMode.displayOnly,
            priority: 60,
            speakerRole: SpeakerRole.user,
          ),
        ],
      );

      final result = exporter.export(track);
      expect(result.content, contains('[USER]'));
    });
  });

  group('roundtrip export/import', () {
    test('reference track roundtrips correctly', () {
      final srt = File('test/fixtures/movie.srt').readAsStringSync();
      final parseResult = parser.parse(srt);
      final track = CueTrack.normalize(
        parseResult.entries,
        TrackType.reference,
        'ref',
      );

      final exportResult = exporter.export(track);
      expect(exportResult.success, true);
      expect(exportResult.cueCount, parseResult.entries.length);

      // Re-parse the exported content
      final reparse = parser.parse(exportResult.content!);
      expect(reparse.entries.length, parseResult.entries.length);

      for (int i = 0; i < parseResult.entries.length; i++) {
        expect(reparse.entries[i].text, parseResult.entries[i].text);
        expect(reparse.entries[i].startMs, parseResult.entries[i].startMs);
        expect(reparse.entries[i].endMs, parseResult.entries[i].endMs);
      }
    });

    test('riff track roundtrips tags correctly', () {
      final srt = File('test/fixtures/riffs.srt').readAsStringSync();
      final parseResult = parser.parse(srt);
      final track = CueTrack.normalize(
        parseResult.entries,
        TrackType.riff,
        'riff',
      );

      final exportResult = exporter.export(track);
      expect(exportResult.success, true);

      // Re-parse the exported content
      final reparse = parser.parse(exportResult.content!);
      expect(reparse.entries.length, parseResult.entries.length);

      // Check that tags are preserved
      for (int i = 0; i < parseResult.entries.length; i++) {
        expect(reparse.entries[i].tags.isApp, parseResult.entries[i].tags.isApp);
        expect(
            reparse.entries[i].tags.isSpeak, parseResult.entries[i].tags.isSpeak);
        expect(reparse.entries[i].tags.isDisplay,
            parseResult.entries[i].tags.isDisplay);
      }
    });
  });

  group('exportAll', () {
    test('exports multiple tracks', () {
      final ref = CueTrack(
        trackId: 'ref',
        trackType: TrackType.reference,
        cues: [makeCue(id: 'r1', startMs: 0, endMs: 1000, text: 'Ref.')],
      );
      final riff = CueTrack(
        trackId: 'riff',
        trackType: TrackType.riff,
        cues: [
          makeCue(
            id: 'f1',
            startMs: 2000,
            endMs: 3000,
            text: 'Riff.',
            kind: CueKind.riff,
            mode: CueMode.speak,
            priority: 50,
            speakerRole: SpeakerRole.app,
          ),
        ],
      );

      final results = exporter.exportAll([ref, riff]);
      expect(results.length, 2);
      expect(results.containsKey('ref'), true);
      expect(results.containsKey('riff'), true);
      expect(results['ref']!.success, true);
      expect(results['riff']!.success, true);
    });
  });

  group('ExportResult', () {
    test('srtContent factory creates correct result', () {
      final result = ExportResult.srtContent(
        content: 'test content',
        cueCount: 5,
        includedFiles: ['test.srt'],
      );

      expect(result.success, true);
      expect(result.content, 'test content');
      expect(result.cueCount, 5);
      expect(result.trackCount, 1);
      expect(result.includedFiles, ['test.srt']);
      expect(result.isSuccess, true);
      expect(result.isFailed, false);
    });

    test('failure factory creates failed result', () {
      final result = ExportResult.failure('Something went wrong');

      expect(result.success, false);
      expect(result.errorMessage, 'Something went wrong');
      expect(result.isSuccess, false);
      expect(result.isFailed, true);
    });
  });
}
