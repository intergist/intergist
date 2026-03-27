# SciFiOnly

SciFiOnly is a participatory movie-riffing companion app for sci-fi fans. It synchronizes with movie playback to identify participation windows -- moments of silence or low dialogue -- where viewers can riff, comment, and react. Record your riffs, share them, and build a library of participatory movie experiences.

## Features

- **SRT Import** -- Import subtitle files (SRT format) to define movie cue tracks with full validation and error reporting.
- **Cue Timing** -- Analyze imported tracks to compute precisely timed cue events and participation windows.
- **Participation Windows** -- Real-time identification of gaps (>= 2.5s) in dialogue where you can jump in and riff.
- **Audio Sync** -- Lock to movie playback with drift correction and sync confidence monitoring.
- **Recording** -- Capture your riffs and commentary during participation windows.
- **Export** -- Package and share your recorded riffing sessions.
- **Three Sci-Fi Themes** -- Choose from three visual themes built with Material 3 and ThemeExtension.

## Quick Start

```bash
cd scifionly
flutter pub get
flutter test
flutter run
```

## Documentation

| Document | Description |
|----------|-------------|
| [Setup Guide](docs/SETUP.md) | Developer environment setup (Flutter, Android SDK, IDE configuration) |
| [Build Instructions](docs/BUILD.md) | Debug builds, release APKs, app bundles, analysis, and formatting |
| [Testing Guide](docs/TESTING.md) | Running unit, widget, and integration tests with coverage |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Debug logging, common errors, and issue reporting template |
| [Architecture](docs/ARCHITECTURE.md) | Component layers, data flow, state machines, and design decisions |

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.22+ |
| Language | Dart 3.4+ |
| State Management | Riverpod (flutter_riverpod) |
| Routing | GoRouter |
| Database | SQLite (sqflite) |
| Design System | Material 3 with ThemeExtension |
| File Import | file_picker |
| Sharing | share_plus |
| Text-to-Speech | flutter_tts |
| Typography | google_fonts |

## Project Structure

```
lib/
  app/                  # App-level configuration and routing
  features/
    cue_engine/         # Cue evaluation and participation windows
    sync/               # Audio sync engine and drift correction
    session/            # Session lifecycle and mode controllers
    recording/          # Audio capture and riff tracks
    import/             # SRT and package import pipeline
    export/             # Session export packaging
    persistence/        # SQLite database and repositories
  models/               # Shared data classes
  providers/            # Riverpod state management providers
  ui/
    screens/            # Full-page screens
    components/         # Reusable UI components
    theme/              # Theme definitions and extensions
    tokens/             # Design tokens (colors, spacing, typography)
  utils/                # Cross-cutting utilities (logger, SRT utils, time utils)
  main.dart             # App entry point
```

## License

Private. All rights reserved.
