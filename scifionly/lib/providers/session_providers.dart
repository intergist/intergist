import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/participation_window_model.dart';
import 'package:scifionly/features/persistence/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final activeSessionProvider = StateProvider<Session?>((ref) => null);

final currentCueProvider = StateProvider<CueEventModel?>((ref) => null);

final nextCueProvider = StateProvider<CueEventModel?>((ref) => null);

final sessionElapsedProvider = StateProvider<Duration>((ref) => Duration.zero);

final currentPositionMsProvider = StateProvider<int>((ref) => 0);

// Recording mode providers
final participationWindowStateProvider =
    StateProvider<ParticipationWindowState>((ref) {
  return ParticipationWindowState.closed;
});

enum ParticipationWindowState { closed, warning, open }

final isCapturingProvider = StateProvider<bool>((ref) => false);

final captureCountdownProvider = StateProvider<double>((ref) => 0.0);

final captureProgressProvider = StateProvider<double>((ref) => 0.0);

final transcriptTextProvider = StateProvider<String>((ref) => '');

final isTranscriptFinalProvider = StateProvider<bool>((ref) => false);

final currentWindowProvider =
    StateProvider<ParticipationWindowModel?>((ref) => null);

final windowsProvider =
    StateProvider<List<ParticipationWindowModel>>((ref) => []);
