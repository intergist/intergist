import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/models/project.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/models/session.dart';

import 'package:scifionly/providers/session_providers.dart';
import 'package:scifionly/providers/sync_providers.dart';

import 'package:scifionly/features/sync/sync_state.dart';
import 'test_helpers.dart';

/// Create a ProviderContainer with mock overrides for testing
ProviderContainer createTestContainer({
  List<Project>? projects,
  Session? activeSession,
  SyncStateData? syncState,
}) {
  return ProviderContainer(
    overrides: [
      if (activeSession != null)
        activeSessionProvider.overrideWith((ref) => activeSession),
      if (syncState != null)
        syncStateProvider.overrideWith((ref) => syncState),
    ],
  );
}

/// Sample project list for testing
List<Project> sampleProjects() {
  return [
    createTestProject(
      id: 'proj-001',
      title: 'Alien',
      releaseYear: 1979,
      status: ProjectStatus.ready,
    ),
    createTestProject(
      id: 'proj-002',
      title: 'Blade Runner',
      releaseYear: 1982,
      status: ProjectStatus.ready,
    ),
    createTestProject(
      id: 'proj-003',
      title: 'The Thing',
      releaseYear: 1982,
      status: ProjectStatus.missingRiffTrack,
    ),
  ];
}

/// Sample track list for testing
List<Track> sampleTracks() {
  return [
    createTestTrack(
      id: 'track-001',
      projectId: 'proj-001',
      filename: 'movie.srt',
      type: TrackType.reference,
      cueCount: 4,
    ),
    createTestTrack(
      id: 'track-002',
      projectId: 'proj-001',
      filename: 'riffs.srt',
      type: TrackType.riff,
      cueCount: 3,
    ),
  ];
}
