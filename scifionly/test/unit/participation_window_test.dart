import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/features/cue_engine/participation_window.dart';
import 'package:scifionly/models/participation_window_model.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    enableTestLogging();
  });

  tearDown(() {
    disableTestLogging();
  });

  /// Create a standard test window that opens at [startMs] and closes at
  /// [endMs]. Default: opens at 10000ms, closes at 20000ms.
  ParticipationWindowModel makeWindow({
    int startMs = 10000,
    int endMs = 20000,
  }) {
    return createTestWindow(startMs: startMs, endMs: endMs);
  }

  group('getWindowState', () {
    late ParticipationWindowModel window;

    setUp(() {
      window = makeWindow(); // opens at 10000, closes at 20000
    });

    test('returns closed when well before window opens', () {
      expect(getWindowState(window, 0), WindowState.closed);
      expect(getWindowState(window, 5000), WindowState.closed);
    });

    test('returns closed just before lead-in warning zone', () {
      // Warning zone starts at openMs - kWindowWarningMs = 10000 - 1500 = 8500
      expect(getWindowState(window, 8499), WindowState.closed);
    });

    test('returns warning at start of lead-in zone (1.5s before open)', () {
      expect(getWindowState(window, 8500), WindowState.warning);
    });

    test('returns warning during lead-in zone', () {
      expect(getWindowState(window, 9000), WindowState.warning);
      expect(getWindowState(window, 9500), WindowState.warning);
      expect(getWindowState(window, 9999), WindowState.warning);
    });

    test('returns open at exact window open time', () {
      expect(getWindowState(window, 10000), WindowState.open);
    });

    test('returns open during the middle of the window', () {
      expect(getWindowState(window, 15000), WindowState.open);
    });

    test('returns open just before lead-out warning zone', () {
      // Lead-out warning starts at closeMs - kWindowWarningMs = 20000 - 1500 = 18500
      expect(getWindowState(window, 18499), WindowState.open);
    });

    test('returns warning at start of lead-out zone (1.5s before close)', () {
      expect(getWindowState(window, 18500), WindowState.warning);
    });

    test('returns warning during lead-out zone', () {
      expect(getWindowState(window, 19000), WindowState.warning);
      expect(getWindowState(window, 19500), WindowState.warning);
      expect(getWindowState(window, 19999), WindowState.warning);
    });

    test('returns closed at exact close time', () {
      expect(getWindowState(window, 20000), WindowState.closed);
    });

    test('returns closed well after window closes', () {
      expect(getWindowState(window, 25000), WindowState.closed);
      expect(getWindowState(window, 100000), WindowState.closed);
    });
  });

  group('getWindowState with short window', () {
    test('very short window where lead-out covers entire open range', () {
      // Window from 1000 to 2500 (1500ms duration)
      // Lead-out warning starts at 2500 - 1500 = 1000
      // So the entire window is in lead-out warning zone
      final shortWindow = makeWindow(startMs: 1000, endMs: 2500);
      expect(getWindowState(shortWindow, 1000), WindowState.warning);
      expect(getWindowState(shortWindow, 2000), WindowState.warning);
    });

    test('window shorter than kWindowWarningMs has no open state', () {
      // Window from 5000 to 6000 (1000ms, less than 1500ms warning)
      final tinyWindow = makeWindow(startMs: 5000, endMs: 6000);
      // closeMs - kWindowWarningMs = 6000 - 1500 = 4500
      // At 5000: inside window but >= 4500, so warning
      expect(getWindowState(tinyWindow, 5000), WindowState.warning);
      expect(getWindowState(tinyWindow, 5500), WindowState.warning);
    });
  });

  group('isWindowOpen', () {
    late ParticipationWindowModel window;

    setUp(() {
      window = makeWindow(); // opens at 10000, closes at 20000
    });

    test('returns false before window', () {
      expect(isWindowOpen(window, 5000), isFalse);
      expect(isWindowOpen(window, 9999), isFalse);
    });

    test('returns true at exact open time', () {
      expect(isWindowOpen(window, 10000), isTrue);
    });

    test('returns true during window', () {
      expect(isWindowOpen(window, 15000), isTrue);
      expect(isWindowOpen(window, 19999), isTrue);
    });

    test('returns false at exact close time (exclusive)', () {
      expect(isWindowOpen(window, 20000), isFalse);
    });

    test('returns false after window', () {
      expect(isWindowOpen(window, 25000), isFalse);
    });
  });

  group('window model copyWith', () {
    test('copyWith creates a new instance with changed fields', () {
      final original = createTestWindow(
        id: 'pw-001',
        startMs: 10000,
        endMs: 20000,
      );

      final modified = original.copyWith(id: 'pw-002', startMs: 15000);

      expect(modified.id, 'pw-002');
      expect(modified.startMs, 15000);
      expect(modified.endMs, 20000); // unchanged
      expect(modified.predictedFrom, original.predictedFrom);
    });

    test('copyWith with no changes returns equal object', () {
      final original = createTestWindow();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('copyWith preserves all unchanged fields', () {
      final original = createTestWindow(
        id: 'pw-001',
        startMs: 10000,
        endMs: 20000,
        stateLeadInMs: 1500,
        stateLeadOutMs: 1500,
        minOpenMs: 2500,
        maxUserRiffMs: 7000,
        allowAppSpeech: false,
        allowUserCapture: true,
      );

      final modified = original.copyWith(endMs: 25000);

      expect(modified.id, 'pw-001');
      expect(modified.startMs, 10000);
      expect(modified.endMs, 25000);
      expect(modified.stateLeadInMs, 1500);
      expect(modified.stateLeadOutMs, 1500);
      expect(modified.minOpenMs, 2500);
      expect(modified.maxUserRiffMs, 7000);
      expect(modified.allowAppSpeech, isFalse);
      expect(modified.allowUserCapture, isTrue);
    });

    test('copyWith can change boolean fields', () {
      final original = createTestWindow(
        allowAppSpeech: false,
        allowUserCapture: true,
      );
      final modified = original.copyWith(
        allowAppSpeech: true,
        allowUserCapture: false,
      );
      expect(modified.allowAppSpeech, isTrue);
      expect(modified.allowUserCapture, isFalse);
    });
  });

  group('window model toMap/fromMap roundtrip', () {
    test('toMap produces correct map', () {
      final window = createTestWindow(
        id: 'pw-001',
        startMs: 10000,
        endMs: 20000,
      );

      final map = window.toMap();

      expect(map['id'], 'pw-001');
      expect(map['startMs'], 10000);
      expect(map['endMs'], 20000);
      expect(map['predictedFrom'], 'reference_track_dialogue_gap');
      expect(map['stateLeadInMs'], 1500);
      expect(map['stateLeadOutMs'], 1500);
      expect(map['minOpenMs'], 2500);
      expect(map['maxUserRiffMs'], 7000);
      expect(map['allowAppSpeech'], 0); // false -> 0
      expect(map['allowUserCapture'], 1); // true -> 1
    });

    test('fromMap reconstructs identical object', () {
      final original = createTestWindow(
        id: 'pw-roundtrip',
        startMs: 5000,
        endMs: 15000,
      );

      final map = original.toMap();
      final restored = ParticipationWindowModel.fromMap(map);

      expect(restored, equals(original));
    });

    test('fromMap handles int-encoded booleans (1/0)', () {
      final map = {
        'id': 'pw-bool',
        'startMs': 1000,
        'endMs': 5000,
        'predictedFrom': 'test',
        'stateLeadInMs': 1500,
        'stateLeadOutMs': 1500,
        'minOpenMs': 2500,
        'maxUserRiffMs': 7000,
        'allowAppSpeech': 1,
        'allowUserCapture': 0,
      };

      final window = ParticipationWindowModel.fromMap(map);

      expect(window.allowAppSpeech, isTrue);
      expect(window.allowUserCapture, isFalse);
    });

    test('fromMap handles actual boolean values', () {
      final map = {
        'id': 'pw-bool2',
        'startMs': 1000,
        'endMs': 5000,
        'predictedFrom': 'test',
        'stateLeadInMs': 1500,
        'stateLeadOutMs': 1500,
        'minOpenMs': 2500,
        'maxUserRiffMs': 7000,
        'allowAppSpeech': true,
        'allowUserCapture': false,
      };

      final window = ParticipationWindowModel.fromMap(map);

      expect(window.allowAppSpeech, isTrue);
      expect(window.allowUserCapture, isFalse);
    });

    test('roundtrip preserves all fields', () {
      final original = ParticipationWindowModel(
        id: 'pw-full',
        startMs: 3000,
        endMs: 8000,
        predictedFrom: 'custom_gap',
        stateLeadInMs: 2000,
        stateLeadOutMs: 1000,
        minOpenMs: 3000,
        maxUserRiffMs: 5000,
        allowAppSpeech: true,
        allowUserCapture: false,
      );

      final restored = ParticipationWindowModel.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.startMs, original.startMs);
      expect(restored.endMs, original.endMs);
      expect(restored.predictedFrom, original.predictedFrom);
      expect(restored.stateLeadInMs, original.stateLeadInMs);
      expect(restored.stateLeadOutMs, original.stateLeadOutMs);
      expect(restored.minOpenMs, original.minOpenMs);
      expect(restored.maxUserRiffMs, original.maxUserRiffMs);
      expect(restored.allowAppSpeech, original.allowAppSpeech);
      expect(restored.allowUserCapture, original.allowUserCapture);
    });
  });

  group('window model aliases and computed properties', () {
    test('openMs is alias for startMs', () {
      final window = makeWindow(startMs: 5000, endMs: 10000);
      expect(window.openMs, 5000);
      expect(window.openMs, window.startMs);
    });

    test('closeMs is alias for endMs', () {
      final window = makeWindow(startMs: 5000, endMs: 10000);
      expect(window.closeMs, 10000);
      expect(window.closeMs, window.endMs);
    });

    test('durationMs is endMs - startMs', () {
      final window = makeWindow(startMs: 5000, endMs: 10000);
      expect(window.durationMs, 5000);
    });
  });

  group('activeWindow', () {
    test('returns the window that is open at currentMs', () {
      final windows = [
        createTestWindow(id: 'w1', startMs: 1000, endMs: 5000),
        createTestWindow(id: 'w2', startMs: 10000, endMs: 15000),
      ];

      final result = activeWindow(windows, 3000);
      expect(result, isNotNull);
      expect(result!.id, 'w1');
    });

    test('returns null when no window is open', () {
      final windows = [
        createTestWindow(id: 'w1', startMs: 1000, endMs: 5000),
        createTestWindow(id: 'w2', startMs: 10000, endMs: 15000),
      ];

      final result = activeWindow(windows, 7000);
      expect(result, isNull);
    });

    test('returns null for empty list', () {
      expect(activeWindow([], 5000), isNull);
    });
  });

  group('nextWindow', () {
    test('returns the next upcoming window after currentMs', () {
      final windows = [
        createTestWindow(id: 'w1', startMs: 1000, endMs: 5000),
        createTestWindow(id: 'w2', startMs: 10000, endMs: 15000),
      ];

      final result = nextWindow(windows, 3000);
      expect(result, isNotNull);
      expect(result!.id, 'w2');
    });

    test('returns first window when position is before all', () {
      final windows = [
        createTestWindow(id: 'w1', startMs: 5000, endMs: 8000),
        createTestWindow(id: 'w2', startMs: 15000, endMs: 20000),
      ];

      final result = nextWindow(windows, 0);
      expect(result, isNotNull);
      expect(result!.startMs, 5000);
    });

    test('returns null when no more windows upcoming', () {
      final windows = [
        createTestWindow(id: 'w1', startMs: 1000, endMs: 5000),
      ];

      final result = nextWindow(windows, 6000);
      expect(result, isNull);
    });

    test('returns null for empty list', () {
      expect(nextWindow([], 0), isNull);
    });
  });

  group('remainingOpenMs', () {
    late ParticipationWindowModel window;

    setUp(() {
      window = makeWindow(); // opens at 10000, closes at 20000
    });

    test('returns full duration at window start', () {
      expect(remainingOpenMs(window, 10000), 10000);
    });

    test('returns partial remaining during window', () {
      expect(remainingOpenMs(window, 15000), 5000);
    });

    test('returns 0 before window', () {
      expect(remainingOpenMs(window, 5000), 0);
    });

    test('returns 0 at exact window end', () {
      expect(remainingOpenMs(window, 20000), 0);
    });

    test('returns 0 after window', () {
      expect(remainingOpenMs(window, 25000), 0);
    });
  });

  group('window model equality', () {
    test('two identical windows are equal', () {
      final a = createTestWindow(id: 'w1', startMs: 1000, endMs: 5000);
      final b = createTestWindow(id: 'w1', startMs: 1000, endMs: 5000);
      expect(a, equals(b));
    });

    test('windows with different IDs are not equal', () {
      final a = createTestWindow(id: 'w1', startMs: 1000, endMs: 5000);
      final b = createTestWindow(id: 'w2', startMs: 1000, endMs: 5000);
      expect(a, isNot(equals(b)));
    });

    test('toString produces readable output', () {
      final window = createTestWindow(id: 'pw-str', startMs: 1000, endMs: 5000);
      final str = window.toString();
      expect(str, contains('pw-str'));
      expect(str, contains('1000'));
      expect(str, contains('5000'));
    });
  });
}
