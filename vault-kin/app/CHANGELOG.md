# Changelog

All notable changes to Vault Kin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-03-24

### Added
- Android mobile packaging with Capacitor
- PWA support with vite-plugin-pwa (service worker, web app manifest)
- Self-hosted Satoshi and Inter fonts for offline operation
- Mobile SQLite database abstraction layer (@capacitor-community/sqlite)
- Schema migration runner for on-device database
- Offline backup/restore service interface (stubs)
- GitHub Actions CI/CD pipeline for Android builds
- Signed APK (sideload) and AAB (Play Store) build targets
- Release notes structure (whatsnew/)
- Corrected mobile packaging specification (v1.2.0)

### Technical Details
- App ID: `com.intergist.vaultkin`
- Min Android SDK: 24 (Android 7.0+)
- Target SDK: 34
- Build output: `dist/public/` (Vite) → Capacitor sync → Gradle build
