# SciFiOnly Developer Environment Setup

This guide walks you through setting up a local development environment for the SciFiOnly Flutter application.

## Prerequisites

| Tool | Minimum Version | Recommended Version |
|------|----------------|---------------------|
| Flutter SDK | 3.22+ | Latest stable |
| Dart SDK | 3.4+ | Bundled with Flutter |
| Android SDK | API 31 | API 33+ |
| Java JDK | 17 | 17 |

## 1. Install Flutter SDK

Follow the official Flutter installation guide for your operating system:
https://docs.flutter.dev/get-started/install

Ensure Flutter 3.22 or later is installed. Dart 3.4+ is bundled with the Flutter SDK, so no separate Dart installation is required.

Verify your installation:

```bash
flutter --version
```

You should see Flutter 3.22.x or later and Dart 3.4.x or later in the output.

## 2. Install Android SDK

The Android SDK is required to build and run SciFiOnly on Android devices and emulators.

- **Minimum**: API level 31 (Android 12)
- **Recommended**: API level 33 (Android 13) or later

Install the Android SDK through Android Studio or the standalone command-line tools. Ensure the following SDK components are installed:

- Android SDK Build-Tools (latest)
- Android SDK Platform-Tools
- Android SDK Platform for API 33+
- Android Emulator (if using emulators)

## 3. IDE Setup

### VS Code (Recommended)

1. Install [Visual Studio Code](https://code.visualstudio.com/).
2. Install the following extensions from the VS Code marketplace:
   - **Flutter** (`Dart-Code.flutter`) -- provides Flutter tooling, hot reload, device selection, and debugging.
   - **Dart** (`Dart-Code.dart-code`) -- provides Dart language support, analysis, and code completion.
3. Open the `scifionly` directory in VS Code:
   ```bash
   code scifionly
   ```
4. VS Code will automatically detect the Flutter project and offer to fetch dependencies.

### Android Studio

1. Install [Android Studio](https://developer.android.com/studio).
2. Open Android Studio and go to **Settings > Plugins**.
3. Install the **Flutter** plugin (this also installs the Dart plugin).
4. Restart Android Studio.
5. Open the `scifionly` directory as an existing project.

## 4. Clone the Repository

```bash
git clone <repository-url>
cd scifionly
```

## 5. Install Dependencies

From the project root, fetch all Dart/Flutter packages:

```bash
flutter pub get
```

This downloads all dependencies declared in `pubspec.yaml`, including:

- `flutter_riverpod` -- state management
- `go_router` -- declarative routing
- `sqflite` -- SQLite database
- `file_picker` -- file import
- `share_plus` -- sharing/export
- And other supporting packages

## 6. Emulator Setup

An Android emulator lets you run the app without a physical device.

### Create an Android Virtual Device (AVD)

1. Open Android Studio.
2. Go to **Tools > Device Manager** (or **AVD Manager**).
3. Click **Create Virtual Device**.
4. Select a device definition:
   - **Recommended**: Pixel 6
   - Any device with a reasonable screen size works.
5. Select a system image:
   - **Recommended**: API 33 (Android 13) with Google APIs, x86_64.
   - Minimum: API 31 (Android 12).
6. Finish the wizard and launch the emulator.

### Launch the emulator from the command line

```bash
# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch <emulator_name>
```

## 7. Physical Device Setup

To run SciFiOnly on a physical Android device:

1. **Enable Developer Options** on the device:
   - Go to **Settings > About Phone**.
   - Tap **Build Number** seven times until you see "You are now a developer."
2. **Enable USB Debugging**:
   - Go to **Settings > Developer Options**.
   - Toggle **USB Debugging** on.
3. Connect the device to your computer via USB.
4. When prompted on the device, select **Allow USB Debugging** and check "Always allow from this computer."
5. Verify the device is detected:
   ```bash
   flutter devices
   ```

## 8. Verify Your Setup

Run Flutter's diagnostic tool to confirm everything is configured correctly:

```bash
flutter doctor
```

You should see checkmarks next to:

- Flutter (Channel stable, 3.22.x or later)
- Android toolchain (API 31+)
- Connected device (emulator or physical device)
- Your IDE (VS Code or Android Studio)

Address any issues reported by `flutter doctor` before proceeding to build and run the app.

## Next Steps

- [Build and run the app](BUILD.md)
- [Run the test suite](TESTING.md)
- [Architecture overview](ARCHITECTURE.md)
