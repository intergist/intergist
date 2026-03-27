# SciFiOnly Build Instructions

This guide covers all build, analysis, and formatting commands for the SciFiOnly Flutter application.

## Prerequisites

Ensure your development environment is set up. See [SETUP.md](SETUP.md) for details.

## Debug Build

Run the app in debug mode on a connected device or running emulator:

```bash
flutter run
```

This requires either:
- A physical device connected via USB with USB debugging enabled, or
- A running Android emulator.

Debug mode enables:
- Hot reload (`r` in the terminal while running)
- Hot restart (`R` in the terminal while running)
- Debug logging to the console
- Dart DevTools access

To target a specific device when multiple are connected:

```bash
# List connected devices
flutter devices

# Run on a specific device
flutter run -d <device_id>
```

## Release APK

Build a release APK for distribution or manual installation:

```bash
flutter build apk --release
```

The output APK is located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

This produces a fat APK containing native libraries for all supported architectures (arm64-v8a, armeabi-v7a, x86_64).

### Split APKs by ABI

To produce smaller, architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

## App Bundle

Build an Android App Bundle for Google Play Store distribution:

```bash
flutter build appbundle
```

The output bundle is located at:
```
build/app/outputs/bundle/release/app-release.aab
```

App bundles are the recommended format for Play Store uploads. Google Play generates optimized APKs for each device configuration automatically.

## Static Analysis

Run the Dart analyzer to check for errors, warnings, and lint violations:

```bash
flutter analyze
```

The analyzer uses rules defined in `analysis_options.yaml` at the project root. All code must pass analysis with zero issues before merging.

## Code Formatting

Format all Dart source files to follow the standard Dart style:

```bash
dart format lib/ test/
```

To check formatting without modifying files (useful in CI):

```bash
dart format --output=none --set-exit-if-changed lib/ test/
```

## Clean Build

If you encounter stale build artifacts or unexpected behavior, perform a clean build:

```bash
flutter clean && flutter pub get
```

This removes the `build/` directory and `.dart_tool/` caches, then re-fetches all dependencies. Follow this with your desired build command.

## Build Summary

| Task | Command |
|------|---------|
| Debug run | `flutter run` |
| Release APK | `flutter build apk --release` |
| Split APKs | `flutter build apk --release --split-per-abi` |
| App Bundle | `flutter build appbundle` |
| Static analysis | `flutter analyze` |
| Format code | `dart format lib/ test/` |
| Check formatting | `dart format --output=none --set-exit-if-changed lib/ test/` |
| Clean rebuild | `flutter clean && flutter pub get` |

## Next Steps

- [Run the test suite](TESTING.md)
- [Troubleshooting](TROUBLESHOOTING.md)
