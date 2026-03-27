import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/cue_track.dart';
import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/track.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    enableTestLogging();
  });

  tearDown(() {
    disableTestLogging();
  });

  /// Helper to create an SrtEntry for testing.
  SrtEntry makeEntry({
    required int index,
    required int startMs,
    required int endMs,
    required String text,
    SrtTags tags = const SrtTags(),
  }) {
    return SrtEntry(
      index: index,
      startMs: startMs,
      endMs: endMs,
      text: text,
      rawText: text,
      tags: tags,
    );
  }

  /// Helper to create a CueEventModel directly.
  CueEventModel makeCue({
    required String id,
    required int startMs,
    required int endMs,
    String text = 'test',
    bool enabled = true,
  }) {
    return CueEventModel(
      id: id,
      trackId: 'track-1',
      track: 'reference',
      startMs: startMs,
      endMs: endMs,
      text: text,
      kind: CueKind.dialogue,
      mode: CueMode.displayOnly,
      priority: 100,
      speakerRole: SpeakerRole.narrator,
      interruptible: false,
      enabled: enabled,
    );
  }

  group('CueTrack.normalize', () {
    test('converts SRT entries to CueEventModel instances', () {
      final entries = [
        makeEntry(index: 1, startMs: 1000, endMs: 3000, text: 'Hello'),
        makeEntry(index: 2, startMs: 5000, endMs: 7000, text: 'World'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.reference, 'ref-track');

      expect(track.length, 2);
      expect(track.trackId, 'ref-track');
      expect(track.trackType, TrackType.reference);
      expect(track.allCues[0].text, 'Hello');
      expect(track.allCues[1].text, 'World');
    });

    test('assigns correct IDs from trackId and entry index', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'A'),
        makeEntry(index: 2, startMs: 2000, endMs: 3000, text: 'B'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.reference, 'my-track');

      expect(track.allCues[0].id, 'my-track_1');
      expect(track.allCues[1].id, 'my-track_2');
    });

    test('reference track gets dialogue kind, displayOnly mode, narrator role',
        () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'Line'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.reference, 'ref');

      expect(track.allCues[0].kind, CueKind.dialogue);
      expect(track.allCues[0].mode, CueMode.displayOnly);
      expect(track.allCues[0].speakerRole, SpeakerRole.narrator);
      expect(track.allCues[0].interruptible, isFalse);
    });

    test('riff track gets riff kind, displayAndSpeak mode, app role', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'Riff'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff-track');

      expect(track.allCues[0].kind, CueKind.riff);
      expect(track.allCues[0].mode, CueMode.displayAndSpeak);
      expect(track.allCues[0].speakerRole, SpeakerRole.app);
      expect(track.allCues[0].interruptible, isTrue);
    });

    test('userRiff track gets userRiff kind, displayOnly mode, user role', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'User riff'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.userRiff, 'user-track');

      expect(track.allCues[0].kind, CueKind.userRiff);
      expect(track.allCues[0].speakerRole, SpeakerRole.user);
      expect(track.allCues[0].interruptible, isTrue);
    });

    test('sorts entries by startMs', () {
      final entries = [
        makeEntry(index: 1, startMs: 5000, endMs: 7000, text: 'Late'),
        makeEntry(index: 2, startMs: 1000, endMs: 3000, text: 'Early'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.reference, 'ref');

      expect(track.allCues[0].text, 'Early');
      expect(track.allCues[1].text, 'Late');
    });

    test('uses SPEAK tag to override mode', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Tagged',
          tags: const SrtTags(isApp: true, isSpeak: true),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].mode, CueMode.speak);
      expect(track.allCues[0].speakerRole, SpeakerRole.app);
    });

    test('uses DISPLAY tag to set displayOnly mode', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Display only',
          tags: const SrtTags(isApp: true, isDisplay: true),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].mode, CueMode.displayOnly);
    });

    test('uses SPEAK+DISPLAY tags to set displayAndSpeak mode', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Both',
          tags: const SrtTags(isSpeak: true, isDisplay: true),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].mode, CueMode.displayAndSpeak);
    });

    test('uses tag priority when available', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Priority',
          tags: const SrtTags(priority: 75),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].priority, 75);
    });

    test('default priority for reference is 100', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'Ref'),
      ];
      final track =
          CueTrack.normalize(entries, TrackType.reference, 'ref');
      expect(track.allCues[0].priority, 100);
    });

    test('default priority for riff is 50', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'Riff'),
      ];
      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');
      expect(track.allCues[0].priority, 50);
    });

    test('default priority for userRiff is 60', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'UserRiff'),
      ];
      final track =
          CueTrack.normalize(entries, TrackType.userRiff, 'user');
      expect(track.allCues[0].priority, 60);
    });

    test('collects tags into tags list', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Tagged',
          tags: const SrtTags(
            isApp: true,
            isSpeak: true,
            priority: 80,
            windowRef: 'w1',
          ),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].tags, contains('APP'));
      expect(track.allCues[0].tags, contains('SPEAK'));
      expect(track.allCues[0].tags, contains('PRIORITY=80'));
      expect(track.allCues[0].tags, contains('WINDOW=w1'));
    });

    test('sets windowRef from tag', () {
      final entries = [
        makeEntry(
          index: 1,
          startMs: 0,
          endMs: 1000,
          text: 'Windowed',
          tags: const SrtTags(windowRef: 'pw-001'),
        ),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.riff, 'riff');

      expect(track.allCues[0].windowRef, 'pw-001');
    });

    test('sets sourceIndex from iteration order', () {
      final entries = [
        makeEntry(index: 1, startMs: 0, endMs: 1000, text: 'A'),
        makeEntry(index: 2, startMs: 2000, endMs: 3000, text: 'B'),
        makeEntry(index: 3, startMs: 4000, endMs: 5000, text: 'C'),
      ];

      final track =
          CueTrack.normalize(entries, TrackType.reference, 'ref');

      expect(track.allCues[0].sourceIndex, 0);
      expect(track.allCues[1].sourceIndex, 1);
      expect(track.allCues[2].sourceIndex, 2);
    });
  });

  group('getCuesInRange', () {
    late CueTrack track;

    setUp(() {
      track = CueTrack(
        trackId: 'test',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 1000, endMs: 3000),
          makeCue(id: 'c2', startMs: 5000, endMs: 7000),
          makeCue(id: 'c3', startMs: 10000, endMs: 12000),
        ],
      );
    });

    test('returns correct subset of cues overlapping the range', () {
      final cues = track.getCuesInRange(2000, 6000);
      expect(cues.length, 2);
      expect(cues[0].id, 'c1');
      expect(cues[1].id, 'c2');
    });

    test('returns empty when no cues overlap', () {
      final cues = track.getCuesInRange(3000, 5000);
      expect(cues, isEmpty);
    });

    test('returns cue that starts at range start boundary', () {
      final cues = track.getCuesInRange(5000, 6000);
      expect(cues.length, 1);
      expect(cues[0].id, 'c2');
    });

    test('returns all cues for full range', () {
      final cues = track.getCuesInRange(0, 20000);
      expect(cues.length, 3);
    });

    test('excludes disabled cues', () {
      final trackWithDisabled = CueTrack(
        trackId: 'test',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 1000, endMs: 3000, enabled: false),
          makeCue(id: 'c2', startMs: 5000, endMs: 7000),
        ],
      );

      final cues = trackWithDisabled.getCuesInRange(0, 8000);
      expect(cues.length, 1);
      expect(cues[0].id, 'c2');
    });
  });

  group('getCueAt', () {
    late CueTrack track;

    setUp(() {
      track = CueTrack(
        trackId: 'test',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 1000, endMs: 3000),
          makeCue(id: 'c2', startMs: 5000, endMs: 7000),
        ],
      );
    });

    test('returns correct cue at exact start time', () {
      final cue = track.getCueAt(1000);
      expect(cue, isNotNull);
      expect(cue!.id, 'c1');
    });

    test('returns correct cue for timestamp inside range', () {
      final cue = track.getCueAt(2000);
      expect(cue, isNotNull);
      expect(cue!.id, 'c1');
    });

    test('returns null at exact end time (exclusive boundary)', () {
      final cue = track.getCueAt(3000);
      expect(cue, isNull);
    });

    test('returns null in gap between cues', () {
      final cue = track.getCueAt(4000);
      expect(cue, isNull);
    });

    test('returns null before all cues', () {
      final cue = track.getCueAt(0);
      expect(cue, isNull);
    });

    test('returns null after all cues', () {
      final cue = track.getCueAt(8000);
      expect(cue, isNull);
    });

    test('skips disabled cues', () {
      final trackWithDisabled = CueTrack(
        trackId: 'test',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 1000, endMs: 3000, enabled: false),
          makeCue(id: 'c2', startMs: 5000, endMs: 7000),
        ],
      );

      final cue = trackWithDisabled.getCueAt(2000);
      expect(cue, isNull);
    });
  });

  group('empty track', () {
    test('isEmpty is true for empty track', () {
      final track = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );
      expect(track.isEmpty, isTrue);
      expect(track.length, 0);
      expect(track.allCues, isEmpty);
    });

    test('getCuesInRange returns empty for empty track', () {
      final track = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );
      expect(track.getCuesInRange(0, 10000), isEmpty);
    });

    test('getCueAt returns null for empty track', () {
      final track = CueTrack(
        trackId: 'empty',
        trackType: TrackType.reference,
      );
      expect(track.getCueAt(5000), isNull);
    });

    test('normalize with empty entries returns empty track', () {
      final track =
          CueTrack.normalize([], TrackType.reference, 'empty');
      expect(track.isEmpty, isTrue);
      expect(track.length, 0);
    });
  });

  group('allCues immutability', () {
    test('allCues returns unmodifiable list', () {
      final track = CueTrack(
        trackId: 'test',
        trackType: TrackType.reference,
        cues: [
          makeCue(id: 'c1', startMs: 0, endMs: 1000),
        ],
      );

      expect(
        () => track.allCues
            .add(makeCue(id: 'c2', startMs: 1000, endMs: 2000)),
        throwsUnsupportedError,
      );
    });
  });
}
