# SciFiOnly Test Execution Guide

This guide covers how to run, organize, and debug tests in the SciFiOnly project.

## Running Tests

### Run All Tests

From the project root:

```bash
cd scifionly
flutter test
```

This discovers and runs every `*_test.dart` file under the `test/` directory.

### Run Tests by Category

SciFiOnly organizes tests into three categories:

```bash
# Unit tests -- business logic, parsers, models, engines
flutter test test/unit/

# Widget tests -- UI components, screens, rendering
flutter test test/widget/

# Integration tests -- end-to-end flows spanning multiple layers
flutter test test/integration/
```

### Run a Specific Test File

```bash
flutter test test/unit/srt_parser_test.dart
```

### Verbose Output

Use the expanded reporter for detailed per-test output:

```bash
flutter test --reporter expanded
```

This displays each test name and its pass/fail status individually, which is helpful when diagnosing failures.

### Code Coverage

Generate a coverage report:

```bash
flutter test --coverage
```

This produces an LCOV coverage file at `coverage/lcov.info`. To view it as HTML (requires `lcov` installed):

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Organization

```
test/
  fixtures/         # Static test data files (SRT files, manifests)
    malformed.srt
    manifest.json
    movie.srt
    overlapping.srt
    riffs.srt
  helpers/           # Shared test utilities
    mock_providers.dart
    test_helpers.dart
  unit/              # Unit tests for business logic
  widget/            # Widget tests for UI components
  integration/       # Integration tests for end-to-end flows
  widget_test.dart   # Default Flutter widget test
```

- **`test/unit/`** -- Tests for individual classes and functions in isolation. Covers parsers (SRT, manifest), cue engine logic, sync algorithms, model behavior, and utility functions.
- **`test/widget/`** -- Tests for Flutter widgets and UI components. Uses `WidgetTester` to pump widgets, interact with them, and verify rendered output.
- **`test/integration/`** -- Tests that exercise multiple layers together. Covers flows like SRT import through parsing through cue evaluation, or session lifecycle from start to completion.
- **`test/fixtures/`** -- Static data files loaded by tests. Includes valid and malformed SRT files, manifest JSON, and other test inputs.
- **`test/helpers/`** -- Shared mock providers, builder functions, and test utilities used across all test categories.

## Debug Logging in Tests

### Environment Variable

Set the `SCIFIONLY_DEBUG` environment variable to enable verbose debug logging during test runs:

```bash
SCIFIONLY_DEBUG=true flutter test
```

### Programmatic Setup

In individual test files or in `setUp()` blocks, call `enableTestLogging()` from the test helpers:

```dart
import 'helpers/test_helpers.dart';

void main() {
  setUp(() {
    enableTestLogging();
  });

  // ... tests ...
}
```

This configures `AppLogger` with `minimumLevel = LogLevel.debug` and enables the log collector so entries can be inspected in assertions.

## Capturing Test Output

To save the full output of a test run (including any failures) to a file:

```bash
flutter test 2>&1 | tee test_output.log
```

This writes all stdout and stderr to `test_output.log` while still displaying output in the terminal. Useful for sharing failing test output in issue reports.

## Understanding Test Output

### Passing Tests

When all tests pass, you will see output similar to:

```
00:05 +42: All tests passed!
```

The `+42` indicates 42 tests passed. With `--reporter expanded`, each test prints individually:

```
00:00 +0: SrtParser parses valid SRT content
00:00 +1: SrtParser rejects malformed timestamps
00:00 +2: CueEvaluator computes participation windows
...
00:05 +42: All tests passed!
```

### Failing Tests

A failing test produces output like:

```
00:03 +30 -1: CueEvaluator handles empty track [E]
  Expected: <3>
    Actual: <0>

  package:test_api              expect
  test/unit/cue_evaluator_test.dart 47:5  main.<fn>

00:05 +41 -1: Some tests failed.
```

The `-1` count indicates one failure. The output shows the expected vs. actual values and a stack trace pointing to the failing assertion.

## Test Commands Summary

| Task | Command |
|------|---------|
| Run all tests | `flutter test` |
| Unit tests only | `flutter test test/unit/` |
| Widget tests only | `flutter test test/widget/` |
| Integration tests only | `flutter test test/integration/` |
| Specific file | `flutter test test/unit/srt_parser_test.dart` |
| Verbose output | `flutter test --reporter expanded` |
| With coverage | `flutter test --coverage` |
| Debug logging | `SCIFIONLY_DEBUG=true flutter test` |
| Save output to file | `flutter test 2>&1 \| tee test_output.log` |

## Next Steps

- [Troubleshooting common issues](TROUBLESHOOTING.md)
- [Build instructions](BUILD.md)
