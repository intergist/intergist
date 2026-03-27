# SciFiOnly Architecture Overview

This document describes the high-level architecture of SciFiOnly, including component layers, data flow, state machines, module dependencies, and key design decisions.

## Component Overview

```
+---------------------------------------------------------------+
|                     Flutter UI Layer                           |
|  screens/         components/         theme/        tokens/   |
|  - SplashScreen   - CueDisplayPanel   - AppTheme    - Colors  |
|  - LibraryScreen  - ParticipationRing - TextTheme   - Spacing |
|  - ImportWizard   - SyncStateChip     - Effects     - Typo    |
|  - ProjectDetails - SessionTopBar     - Semantic              |
|  - TrackManager   - TranscriptStrip   - Session               |
|  - Onboarding     - SciFiPanelCard                            |
|  - Permissions    - ProjectCard                               |
+---------------------------------------------------------------+
         |                    |                    |
         v                    v                    v
+---------------------------------------------------------------+
|                   State Management                             |
|  Riverpod Providers                                            |
|  - project_providers      - session_providers                  |
|  - sync_providers         - settings_providers                 |
|  - theme_providers                                             |
+---------------------------------------------------------------+
         |                    |                    |
         v                    v                    v
+---------------------------------------------------------------+
|                     Feature Layer                              |
|                                                                |
|  cue_engine/       sync/            session/                   |
|  - CueEvaluator   - SyncEngine     - SessionController        |
|  - CueTrack       - DriftCorrector - StandardModeController    |
|  - CueEvent       - SyncState      - RecordingModeController   |
|  - CuePriority                                                 |
|  - WindowCalc      recording/       import/                    |
|  - Participation   - CaptureCtrl   - SrtParser                 |
|    Window          - UserRiffTrack - ManifestParser             |
|                                    - ImportValidator            |
|                    export/         - PackageImporter             |
|                    - ExportResult                               |
+---------------------------------------------------------------+
         |                    |                    |
         v                    v                    v
+---------------------------------------------------------------+
|                   Persistence Layer                            |
|  SQLite via sqflite                                            |
|  - database.dart          - project_repository.dart            |
|  - session_repository.dart - track_repository.dart             |
+---------------------------------------------------------------+
         |
         v
+---------------------------------------------------------------+
|                        Models                                  |
|  Shared data classes used across all layers                    |
|  - Project          - Session           - Track                |
|  - CueEventModel    - SyncSnapshot      - Manifest            |
|  - ParticipationWindowModel             - CaptureEvent         |
+---------------------------------------------------------------+
```

## Data Flow

The primary data flow follows the SRT import-to-playback pipeline:

```
SRT File Import
      |
      v
  SrtParser               Parses raw SRT text into timed subtitle entries.
      |                    Validates timestamps and sequence numbers.
      v
  CueTrack                Normalizes parsed entries into a uniform
  Normalization           CueTrack structure with CueEvents.
      |
      v
  CueEvaluator            Analyzes the CueTrack to compute participation
      |                    windows (gaps >= 2.5s between cue events).
      v
  ParticipationWindows     Timed windows where the user can participate
      |                    (riff, comment, react).
      v
  UI Rendering             CueDisplayPanel, ParticipationRing, and
                           TranscriptStrip render the current state.
```

Supporting flows:

- **Import flow**: File picker -> PackageImporter -> ManifestParser + SrtParser -> ImportValidator -> Persistence
- **Session flow**: User starts session -> SessionController manages lifecycle -> SyncEngine tracks playback position -> CueEvaluator provides real-time window state -> UI updates
- **Recording flow**: User enters participation window -> CaptureController begins recording -> UserRiffTrack stores capture -> Export packages result
- **Export flow**: Session data + captures -> ExportResult packaging -> share_plus for distribution

## State Machines

SciFiOnly uses explicit state machines for its core real-time subsystems. Transitions are logged via `AppLogger.stateTransition()`.

### Sync State Machine

Tracks the lock status between the app and the movie audio.

```
                 lock acquired
  UNLOCKED ─────────────────────> LOCKED
      ^                             |
      |                             | confidence drop
      |          reacquired         v
      |         ┌───────────── DEGRADED
      |         |                   |
      |         v                   | further degradation
      |    REACQUIRING <────────────┘
      |         |
      └─────────┘
        lock lost
```

- **UNLOCKED**: No sync established. Waiting for audio signal.
- **LOCKED**: Sync is established and confident. Normal operation.
- **DEGRADED**: Sync confidence has dropped below threshold but is still partially tracking.
- **REACQUIRING**: Actively attempting to re-establish sync lock.

### Window State Machine

Tracks whether the user is inside a participation window.

```
  CLOSED ──────> WARNING ──────> OPEN ──────> WARNING ──────> CLOSED
    ^                                                            |
    └────────────────────────────────────────────────────────────┘
```

- **CLOSED**: No active participation window. User should be quiet.
- **WARNING**: A window is about to open (or close). Visual/audio cue to prepare.
- **OPEN**: The participation window is active. User can riff, comment, or react.

### Session State Machine

Tracks the lifecycle of a riffing session.

```
  active ──────> paused ──────> resumed ──────> completed
    |               |               |                ^
    |               |               └────────────────┘
    |               v                      (repeat)
    |          abandoned
    v
  completed
```

- **active**: Session is running. Sync is engaged, cues are being evaluated.
- **paused**: Session is temporarily suspended (user paused playback).
- **resumed**: Session has been resumed after a pause.
- **completed**: Session finished normally.
- **abandoned**: Session was terminated before completion.

### Capture State Machine

Tracks the state of audio capture during participation windows.

```
  idle ──────> recording ──────> stopped ──────> saved
                                    |
                                    v
                                 discarded
```

- **idle**: No capture in progress.
- **recording**: Audio is actively being captured.
- **stopped**: Recording has ended, awaiting user decision.
- **saved**: Capture has been persisted to the session.
- **discarded**: Capture was discarded by the user.

## Module Dependencies

```
  UI Layer
    |
    +-- providers/ (Riverpod)
    |     |
    |     +-- features/session/
    |     |     +-- features/cue_engine/
    |     |     +-- features/sync/
    |     |     +-- features/recording/
    |     |
    |     +-- features/import/
    |     |     +-- utils/srt_utils
    |     |
    |     +-- features/export/
    |     +-- features/persistence/
    |
    +-- models/ (shared, no feature dependencies)
    +-- utils/ (shared, no feature dependencies)
          +-- logger.dart
          +-- srt_utils.dart
          +-- time_utils.dart
```

Key dependency rules:
- **Models** and **utils** have no dependencies on features or UI. They are pure Dart.
- **Features** depend on models and utils but not on each other except through explicit interfaces (e.g., session depends on cue_engine and sync).
- **Providers** wire features together and expose state to the UI.
- **UI** depends on providers and models. It does not import features directly.

## Key Design Decisions

### Simulated Sync for v1

The current sync engine uses simulated audio synchronization rather than native audio fingerprinting. This was a deliberate v1 decision to unblock development of the full session and cue pipeline without requiring platform-specific native audio processing. Native audio fingerprinting is planned for a future release.

### No Code Generation

SciFiOnly uses manually written data classes and Riverpod providers rather than relying on code generation tools like `freezed`, `json_serializable`, or `riverpod_generator`. This keeps the build simple (no `build_runner` step), reduces dependency surface area, and avoids generated file churn in version control.

### Three Themes via ThemeExtension

The app ships with three visual themes (defined in `lib/ui/theme/`), implemented using Flutter's `ThemeExtension` mechanism. This provides:
- Type-safe access to custom theme properties (semantic colors, effects, session styling).
- Clean separation between Material 3 base theming and SciFiOnly-specific visual tokens.
- Easy addition of new themes without modifying core widget code.

The three theme extensions are:
- `SciFiOnlySemanticColors` -- semantic color assignments.
- `SciFiOnlyEffectsTheme` -- visual effects and decorations.
- `SciFiOnlySessionTheme` -- session-specific styling (window states, sync indicators).

### Feature-First Module Organization

Code is organized by feature rather than by technical layer:

```
lib/
  features/
    cue_engine/     # Cue evaluation and participation windows
    sync/           # Audio sync engine and drift correction
    session/        # Session lifecycle and mode controllers
    recording/      # Audio capture and riff tracks
    import/         # SRT and package import pipeline
    export/         # Session export packaging
    persistence/    # SQLite database and repositories
```

Each feature directory contains all the classes needed for that feature (controllers, models specific to the feature, utilities). Shared data classes live in `lib/models/`, and cross-cutting utilities live in `lib/utils/`.

## Next Steps

- [Setup guide](SETUP.md)
- [Build instructions](BUILD.md)
- [Testing guide](TESTING.md)
- [Troubleshooting](TROUBLESHOOTING.md)
