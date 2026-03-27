# SciFiOnly Troubleshooting Guide

This guide covers how to enable debug logging, interpret log output, resolve common errors, and report issues.

## Enabling Debug Logging

SciFiOnly uses a structured logging system (`AppLogger`) with four severity levels: `debug`, `info`, `warn`, and `error`. By default, messages below `info` are suppressed.

### Lower the Minimum Log Level

To see all log messages, including debug-level output, set the minimum level to `debug`:

```dart
AppLogger.minimumLevel = LogLevel.debug;
```

Place this early in your app startup (e.g., in `main()`) or in a test `setUp()` block.

### Enable the Log Collector

The log collector stores entries in memory for programmatic inspection. This is useful for diagnostics screens and test assertions:

```dart
AppLogger.collectorOutput = true;
```

Once enabled, all logged entries are available via `LogCollector.instance`:

```dart
final errors = LogCollector.instance.errors;
final syncLogs = LogCollector.instance.where(tag: 'SYNC');
```

### Log Format

All log entries follow this format:

```
2026-03-26T19:42:00.123Z [LEVEL] [TAG] message
```

- **Timestamp**: UTC in ISO 8601 format.
- **LEVEL**: One of `DEBUG`, `INFO`, `WARN`, `ERROR`.
- **TAG**: Component identifier such as `SRT_PARSER`, `CUE_ENGINE`, `SYNC`, `SESSION`, `RECORDING`, `IMPORT`, `EXPORT`, or `UI`.
- **Message**: Human-readable description of the event.

Example log lines:

```
2026-03-26T19:42:00.123Z [INFO] [IMPORT] File imported (245ms)
2026-03-26T19:42:01.456Z [WARN] [SYNC] Sync confidence low
2026-03-26T19:42:02.789Z [ERROR] [SRT_PARSER] Invalid SRT timestamp at line 14
```

## Common Errors and Solutions

### "Invalid SRT timestamp"

**Cause**: The imported SRT file contains malformed time codes that do not conform to the SRT timestamp format (`HH:MM:SS,mmm --> HH:MM:SS,mmm`).

**Solution**:
1. Check the validation output for the specific line numbers with errors.
2. Open the SRT file in a text editor and inspect the flagged lines.
3. Correct the timestamp format. Ensure the separator between start and end times is ` --> ` (with spaces).
4. Re-import the corrected file.

Common issues include:
- Using periods instead of commas for milliseconds (`00:01:23.456` instead of `00:01:23,456`).
- Missing or extra spaces around the `-->` separator.
- Truncated or incomplete timestamps.

### "Sync confidence low"

**Cause**: The sync engine cannot establish a reliable lock with the movie audio. This typically happens when the audio environment is too noisy or the movie audio is too quiet for accurate synchronization.

**Solution**:
1. Reduce background noise in the listening environment.
2. Increase the movie playback volume.
3. Move the device closer to the audio source.
4. If the problem persists, check the sync diagnostics panel for confidence metrics and drift values.

### "No participation windows found"

**Cause**: The cue engine could not identify any gaps in the reference track long enough to constitute a participation window. Windows require a gap of at least 2.5 seconds between cue events.

**Solution**:
1. Verify that the reference track (movie SRT) was imported correctly and contains valid cue data.
2. Check that the reference track is not empty or missing.
3. Examine the track in the Track Manager to confirm cue events are present.
4. If the movie genuinely has no gaps of 2.5 seconds or longer, participation windows cannot be generated for that segment.

### "Flutter analyze errors"

**Cause**: Static analysis has found issues in the Dart source code, such as type errors, unused imports, or lint violations.

**Solution**:
1. Run `flutter pub get` to ensure all dependencies are resolved.
2. Run `flutter analyze` and review the output.
3. Check import paths -- ensure they reference the correct package and file locations.
4. Fix each reported issue. Common fixes include:
   - Adding missing imports.
   - Removing unused imports or variables.
   - Correcting type mismatches.
   - Following lint rules defined in `analysis_options.yaml`.

### "Tests failing"

**Cause**: One or more tests are not passing, which may indicate a bug, a missing dependency, or missing test fixture files.

**Solution**:
1. Verify that test fixture files exist at `test/fixtures/`. The following files are expected:
   - `malformed.srt`
   - `manifest.json`
   - `movie.srt`
   - `overlapping.srt`
   - `riffs.srt`
2. Run `flutter pub get` to ensure test dependencies are resolved.
3. Run the failing test in isolation with verbose output:
   ```bash
   flutter test --reporter expanded test/unit/srt_parser_test.dart
   ```
4. Check the test output for expected vs. actual values and stack traces.
5. If the test depends on mock providers, verify `test/helpers/mock_providers.dart` is up to date.

## Issue Report Template

When reporting a bug or issue, use the following template to provide all necessary context:

```
## Issue Description
[What happened]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]

## Expected Behavior
[What should happen]

## Log Output
[Paste relevant log lines]

## Test Output (if applicable)
[Paste flutter test output]

## Environment
- Flutter version: [flutter --version]
- Device: [model / emulator]
- OS: [Android version]
```

### Tips for Effective Reports

- **Include log output**: Enable debug logging (`AppLogger.minimumLevel = LogLevel.debug`) and reproduce the issue. Paste the relevant log lines, including timestamps and tags.
- **Include test output**: If a test is failing, run it with `--reporter expanded` and paste the full output.
- **Capture environment details**: Run `flutter --version` and `flutter doctor` and include the output.
- **Be specific about steps**: List the exact sequence of actions that triggers the issue, starting from a clean state.

## Next Steps

- [Testing guide](TESTING.md)
- [Build instructions](BUILD.md)
- [Architecture overview](ARCHITECTURE.md)
