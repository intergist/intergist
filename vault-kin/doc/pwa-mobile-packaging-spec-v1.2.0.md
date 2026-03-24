# PWA Mobile App Packaging Build System — Technical Specification

**Version:** 1.2.0
**Author:** intergist
**Date:** March 24, 2026
**Status:** Revised — Corrected for Vault Kin project structure

---

## Table of Contents

1. [Purpose & Scope](#1-purpose--scope)
2. [Architecture Overview](#2-architecture-overview)
3. [Technology Stack Reference](#3-technology-stack-reference)
4. [PWA Readiness Requirements](#4-pwa-readiness-requirements)
5. [Monorepo Build Strategy](#5-monorepo-build-strategy)
6. [Capacitor Android Packaging](#6-capacitor-android-packaging)
7. [SQLite / Database Layer Migration](#7-sqlite--database-layer-migration)
8. [Offline Backup Strategy](#8-offline-backup-strategy)
9. [GitHub Actions CI/CD Pipeline](#9-github-actions-cicd-pipeline)
10. [Secrets & Environment Variables](#10-secrets--environment-variables)
11. [Direct Install (Sideload) Delivery](#11-direct-install-sideload-delivery)
12. [Google Play Store Submission](#12-google-play-store-submission)
13. [iOS — Deferred Phase](#13-ios--deferred-phase)
14. [Versioning & Release Strategy](#14-versioning--release-strategy)
15. [Compliance Checklist](#15-compliance-checklist)
16. [Open Risks & Decisions](#16-open-risks--decisions)

---

## 1. Purpose & Scope

This specification defines a reproducible, CI/CD-integrated build system that:

- Pulls the React/Vite/Express PWA from the `vault-kin/app/` directory in the intergist monorepo
- Wraps the compiled frontend static assets in a Capacitor Android shell
- Replaces the browser-based SQLite (better-sqlite3) with a native mobile SQLite layer
- Produces distributable `.apk` (sideload) and `.aab` (Google Play Store) artifacts
- Enables fully offline operation on the user's device, with internet used exclusively for encrypted cloud backup

**Out of scope for v1.2:** iOS packaging (deferred — see §13).

---

## 2. Architecture Overview

```
GitHub Repo (monorepo: intergist/intergist)
  └── vault-kin/app/          ← Vault Kin application root
            │
            ▼
  [Stage 1: Web Asset Build]
  npm ci → vite build → dist/public/
            │
            ▼
  [Stage 2: Capacitor Sync]
  npx cap sync android
  (copies dist/public/ into android/app/src/main/assets/public/)
            │
            ▼
  [Stage 3: Native DB Shim]
  Replace better-sqlite3 references with
  @capacitor-community/sqlite (native Android SQLite)
            │
            ▼
  [Stage 4: Gradle Build + Sign]
  ./gradlew bundleRelease assembleRelease
  → app-release.aab  (Play Store)
  → app-release.apk  (direct install)
            │
            ├──▶ GitHub Release (APK sideload)
            └──▶ Google Play Console (AAB)
```

### Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Wrapping strategy | Capacitor (bundled assets) | App must run fully offline; no live URL required |
| Database on device | @capacitor-community/sqlite | Native Android SQLite; replaces Node.js better-sqlite3 |
| Express backend | Not packaged into mobile app | API layer stays cloud-hosted; mobile app uses local SQLite + offline sync |
| iOS | Deferred | No Apple Developer account yet |
| Build trigger | GitHub Actions on git tag push | Clean, reproducible releases tied to semver tags |

---

## 3. Technology Stack Reference

### Source PWA Stack

| Layer | Technology |
|---|---|
| Frontend framework | React 18 + TypeScript |
| Styling | Tailwind CSS 3.4 |
| UI components | shadcn/ui (Radix UI) |
| Routing | Wouter 3.3.5 (hash-based — compatible with WebView) |
| Server state | TanStack React Query 5.60 |
| Build tool | Vite 7.3 |
| Backend (API) | Express 5.0.1 (Node.js) — cloud only |
| ORM | Drizzle ORM 0.39.3 |
| Database (server) | better-sqlite3 11.7.0 (server-side only) |
| Icons | Lucide React |
| Fonts | Satoshi (Fontshare), Inter (Google Fonts) |
| Date utils | date-fns |

### Added Mobile Build Stack

| Layer | Technology |
|---|---|
| Mobile container | Capacitor 6.x |
| Android native DB | @capacitor-community/sqlite |
| Android build | Gradle 8.x |
| CI/CD | GitHub Actions |
| Signing | Android Keystore (jarsigner + apksigner) |
| Play Store upload | r0adkll/upload-google-play GitHub Action |

---

## 4. PWA Readiness Requirements

The following must be verified or added to the PWA source before packaging.

### 4.1 Web App Manifest

Generated via `vite-plugin-pwa` configuration (no separate `manifest.json` file needed):

```json
{
  "name": "Vault Kin",
  "short_name": "VaultKin",
  "description": "Your personal life vault — organize, protect, and share what matters most.",
  "start_url": "./",
  "display": "standalone",
  "background_color": "#f0f2f5",
  "theme_color": "#1a2744",
  "icons": [
    { "src": "./icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "./icons/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "./icons/icon-512-maskable.png", "sizes": "512x512",
      "type": "image/png", "purpose": "maskable" }
  ]
}
```

Note: `start_url` uses `"./"` (relative) because `vite.config.ts` sets `base: "./"`.

### 4.2 Service Worker (Offline Shell Caching)

A Vite-PWA plugin (vite-plugin-pwa) is the recommended approach as it auto-generates
a service worker from the Vite build output, ensuring all hashed asset filenames
are captured for cache-first serving.

Install:
```bash
cd vault-kin/app && npm install -D vite-plugin-pwa
```

`vault-kin/app/vite.config.ts` addition:
```typescript
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: ({ request }) => request.destination === 'font',
            handler: 'CacheFirst',
            options: {
              cacheName: 'vaultkin-fonts',
              expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 * 24 * 365 }
            }
          }
        ]
      },
      manifest: {
        name: 'Vault Kin',
        short_name: 'VaultKin',
        description: 'Your personal life vault — organize, protect, and share what matters most.',
        start_url: './',
        display: 'standalone',
        background_color: '#f0f2f5',
        theme_color: '#1a2744',
        icons: [
          { src: './icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: './icons/icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: './icons/icon-512-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }
        ]
      }
    })
  ]
})
```

### 4.3 Font Self-Hosting

Both Satoshi (from Fontshare CDN) and Inter (from Google Fonts CDN) must be self-hosted
for full offline operation.

1. Download Satoshi font files (woff2) and place in `vault-kin/app/client/public/fonts/satoshi/`
2. Download Inter font files (woff2) and place in `vault-kin/app/client/public/fonts/inter/`
3. Replace CDN `<link>` tags in `vault-kin/app/client/index.html` with local `@font-face` declarations in `vault-kin/app/client/src/index.css`
4. Include `woff2` in Workbox `globPatterns` (already covered above)

### 4.4 Routing

Wouter's hash-based routing is natively compatible with WebView
file:// serving — no additional changes required.

### 4.5 API Calls

All TanStack React Query fetches that target the Express backend must gracefully
degrade to the local SQLite store when offline. Pattern:

```typescript
const { data } = useQuery({
  queryKey: ['items'],
  queryFn: async () => {
    try {
      return await fetchFromApi('/api/items')
    } catch {
      return await readFromLocalDb('SELECT * FROM items')
    }
  }
})
```

---

## 5. Monorepo Build Strategy

### Actual Repo Structure

```
intergist/                       ← GitHub repo root
├── .github/
│   └── workflows/
│       └── mobile-build.yml     ← CI/CD pipeline (added by this spec)
├── vault-kin/
│   ├── app/                     ← Vault Kin application root (package.json lives here)
│   │   ├── package.json         ← Scripts, dependencies
│   │   ├── vite.config.ts       ← Vite build config
│   │   ├── tsconfig.json        ← TypeScript config
│   │   ├── tailwind.config.ts   ← Tailwind CSS config
│   │   ├── capacitor.config.ts  ← Added by this build system
│   │   ├── client/              ← React/Vite frontend
│   │   │   ├── index.html
│   │   │   ├── public/          ← Static assets (fonts, icons)
│   │   │   └── src/             ← React source code
│   │   ├── server/              ← Express.js backend (NOT packaged for mobile)
│   │   ├── shared/              ← Shared types / Drizzle schema
│   │   │   └── schema.ts
│   │   └── android/             ← Generated by `npx cap add android` (not committed until generated)
│   └── doc/                     ← Documentation
│       ├── pwa-mobile-packaging-spec-v1.1.0.md
│       └── pwa-mobile-packaging-spec-v1.2.0.md
└── ...                          ← Other monorepo projects
```

### 5.1 capacitor.config.ts

Created at `vault-kin/app/capacitor.config.ts`:

```typescript
import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.intergist.vaultkin',
  appName: 'Vault Kin',
  webDir: 'dist/public',             // Vite output: vault-kin/app/dist/public/
  android: {
    buildOptions: {
      keystorePath: process.env.ANDROID_KEYSTORE_PATH,
      keystoreAlias: process.env.ANDROID_KEY_ALIAS,
    }
  },
  plugins: {
    CapacitorSQLite: {
      androidIsEncryption: false,
      androidBiometric: {
        biometricAuth: false
      }
    }
  }
};

export default config;
```

### 5.2 package.json Scripts

Add these scripts to `vault-kin/app/package.json`:

```json
{
  "scripts": {
    "build:web": "vite build",
    "cap:sync": "npx cap sync android",
    "cap:build:debug": "cd android && ./gradlew assembleDebug",
    "cap:build:release": "cd android && ./gradlew bundleRelease assembleRelease",
    "mobile:build": "npm run build:web && npm run cap:sync && npm run cap:build:release"
  }
}
```

---

## 6. Capacitor Android Packaging

### 6.1 Initial Setup (one-time, run locally or in CI)

```bash
cd vault-kin/app
npm install @capacitor/core @capacitor/cli @capacitor/android
npx cap add android
```

> **Note:** `npx cap add android` requires the Android SDK. Run this locally or in a
> CI environment with Android SDK available. It generates the `android/` directory
> which should be committed to the repo and updated via `npx cap sync` on each build.

### 6.2 Build Steps (CI)

```bash
# 1. Install dependencies and build web assets
cd vault-kin/app
npm ci
npm run build:web

# 2. Sync into Capacitor Android shell
npx cap sync android

# 3. Build Android release artifacts
cd android
./gradlew bundleRelease   # → .aab for Play Store
./gradlew assembleRelease # → .apk for sideload

# 4. Sign APK (AAB is signed by Play Console on upload, or pre-signed here)
$ANDROID_HOME/build-tools/34.0.0/apksigner sign \
  --ks $KEYSTORE_PATH \
  --ks-key-alias $KEY_ALIAS \
  --ks-pass pass:$KEY_PASSWORD \
  --out app-release-signed.apk \
  app/build/outputs/apk/release/app-release-unsigned.apk
```

### 6.3 android/app/build.gradle Configuration

```groovy
android {
    compileSdk 34
    defaultConfig {
        applicationId "com.intergist.vaultkin"
        minSdk 24          // Android 7.0+; covers ~97% of active devices
        targetSdk 34
        versionCode System.getenv("BUILD_NUMBER")?.toInteger() ?: 1
        versionName System.getenv("APP_VERSION") ?: "1.0.0"
    }
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 7. SQLite / Database Layer Migration

This is the most significant architectural adaptation required. The Express backend
uses `better-sqlite3` which is a Node.js C++ addon — it cannot run inside a
Capacitor WebView on Android. The data layer must be split:

```
Server-side:  better-sqlite3 (unchanged — used by Express API in cloud)
              Located at: vault-kin/app/server/storage.ts
Client-side:  @capacitor-community/sqlite (native Android SQLite via Capacitor plugin)
              Located at: vault-kin/app/client/src/lib/mobile-db.ts (new)
              ↕ sync (when online, encrypted backup only)
```

### 7.1 Installation

```bash
cd vault-kin/app
npm install @capacitor-community/sqlite
npx cap sync android
```

### 7.2 Database Abstraction Layer

Create `vault-kin/app/client/src/lib/mobile-db.ts` — a platform-aware database abstraction:

```typescript
import { Capacitor } from '@capacitor/core';
import { CapacitorSQLite, SQLiteConnection } from '@capacitor-community/sqlite';

let sqlite: SQLiteConnection;

export async function getDb() {
  if (!Capacitor.isNativePlatform()) {
    // Browser / dev fallback — use IndexedDB or mock
    return getBrowserDb();
  }
  if (!sqlite) {
    sqlite = new SQLiteConnection(CapacitorSQLite);
  }
  const db = await sqlite.createConnection(
    'vaultkin_local',  // database name
    false,             // encrypted
    'no-encryption',
    1,                 // version
    false              // readonly
  );
  await db.open();
  return db;
}
```

### 7.3 Schema Migration

Drizzle ORM schema definitions (in `vault-kin/app/shared/schema.ts`) remain the source of truth.
On app startup, run a migration check:

```typescript
import { getDb } from './mobile-db';

export async function runMigrations() {
  const db = await getDb();
  // Apply migrations generated by drizzle-kit
  for (const migration of migrations) {
    await db.execute(migration.sql);
  }
}
```

### 7.4 Seed Data

If the app requires pre-populated data at first install, include a seed JSON file
in `vault-kin/app/client/public/seed/` and load it via the SQLite plugin's `importFromJson` method.

---

## 8. Offline Backup Strategy

The app stores all user data locally in native SQLite. Online connectivity is used
only for encrypted backup/restore. This section specifies that interface.

### 8.1 Backup Trigger Conditions

- Manual: User initiates from app settings
- Automatic: On app resume when online, if local DB was modified since last backup
- Never during initial load or on metered connections (check `Network.getStatus()`)

### 8.2 Backup Format

```typescript
// Export local DB to encrypted JSON blob
const exportResult = await db.exportToJson('full');
const plaintext = JSON.stringify(exportResult.export);

// Encrypt with AES-256-GCM using a user-derived key (PBKDF2)
const encrypted = await encryptWithUserKey(plaintext, userPassphrase);

// Upload to backup endpoint
await fetch('https://api.vaultkin.com/backup', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: encrypted
});
```

### 8.3 Restore Flow

```
App Launch → check local DB → empty? → prompt restore
                                     → user provides passphrase
                                     → download from /backup
                                     → decrypt → importFromJson
```

---

## 9. GitHub Actions CI/CD Pipeline

### 9.1 Trigger Strategy

| Trigger | Resulting Artifacts | Distribution Target |
|---|---|---|
| Push to `main` (vault-kin/ changes) | Debug APK | Internal (artifact download only) |
| Push of `v*` tag (e.g. `v1.2.0`) | Signed APK + AAB | GitHub Release + Google Play (production) |
| `workflow_dispatch` | Signed APK + AAB | GitHub Release (manual) |

### 9.2 Full Workflow File: `.github/workflows/mobile-build.yml`

```yaml
name: "Vault Kin: Mobile Build Pipeline"

on:
  push:
    branches: [main]
    tags: ['v*.*.*']
    paths:
      - 'vault-kin/app/**'
      - '.github/workflows/mobile-build.yml'
  workflow_dispatch:
    inputs:
      release_track:
        description: 'Play Store track'
        default: 'internal'
        type: choice
        options: [internal, alpha, beta, production]

env:
  APP_VERSION: ${{ github.ref_type == 'tag' && github.ref_name || '0.0.0-dev' }}
  BUILD_NUMBER: ${{ github.run_number }}
  BUNDLE_ID: com.intergist.vaultkin
  WORKING_DIR: vault-kin/app

jobs:
  build-web:
    name: Build Web Assets
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ env.WORKING_DIR }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: vault-kin/app/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build Vite frontend
        run: npm run build:web
        env:
          VITE_API_URL: ${{ vars.VITE_API_URL }}

      - name: Upload web dist
        uses: actions/upload-artifact@v4
        with:
          name: web-dist
          path: vault-kin/app/dist/public/
          retention-days: 1

  build-android:
    name: Build Android
    needs: build-web
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ env.WORKING_DIR }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: vault-kin/app/package-lock.json

      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Install dependencies
        run: npm ci

      - name: Download web dist
        uses: actions/download-artifact@v4
        with:
          name: web-dist
          path: vault-kin/app/dist/public/

      - name: Capacitor sync
        run: npx cap sync android

      - name: Decode keystore
        if: startsWith(github.ref, 'refs/tags/v') || github.event_name == 'workflow_dispatch'
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_B64 }}" | base64 -d > android/keystore.jks

      - name: Build debug APK (branch push)
        if: "!startsWith(github.ref, 'refs/tags/v') && github.event_name != 'workflow_dispatch'"
        run: cd android && ./gradlew assembleDebug

      - name: Build release AAB + APK (tag or manual)
        if: startsWith(github.ref, 'refs/tags/v') || github.event_name == 'workflow_dispatch'
        run: cd android && ./gradlew bundleRelease assembleRelease
        env:
          ANDROID_KEYSTORE_PATH: keystore.jks
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          APP_VERSION: ${{ env.APP_VERSION }}
          BUILD_NUMBER: ${{ env.BUILD_NUMBER }}

      - name: Sign APK
        if: startsWith(github.ref, 'refs/tags/v') || github.event_name == 'workflow_dispatch'
        run: |
          $ANDROID_HOME/build-tools/34.0.0/apksigner sign \
            --ks android/keystore.jks \
            --ks-key-alias ${{ secrets.ANDROID_KEY_ALIAS }} \
            --ks-pass pass:${{ secrets.ANDROID_KEY_PASSWORD }} \
            --out android/app/build/outputs/apk/release/app-release-signed.apk \
            android/app/build/outputs/apk/release/app-release-unsigned.apk

      - name: Upload APK artifact
        if: startsWith(github.ref, 'refs/tags/v') || github.event_name == 'workflow_dispatch'
        uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: vault-kin/app/android/app/build/outputs/apk/release/app-release-signed.apk

      - name: Upload AAB artifact
        if: startsWith(github.ref, 'refs/tags/v') || github.event_name == 'workflow_dispatch'
        uses: actions/upload-artifact@v4
        with:
          name: android-aab
          path: vault-kin/app/android/app/build/outputs/bundle/release/app-release.aab

      - name: Upload debug APK artifact
        if: "!startsWith(github.ref, 'refs/tags/v') && github.event_name != 'workflow_dispatch'"
        uses: actions/upload-artifact@v4
        with:
          name: android-debug-apk
          path: vault-kin/app/android/app/build/outputs/apk/debug/app-debug.apk

  publish-github-release:
    name: Publish GitHub Release
    needs: build-android
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: android-apk
          path: release/

      - uses: actions/download-artifact@v4
        with:
          name: android-aab
          path: release/

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: |
            release/app-release-signed.apk
            release/app-release.aab
          generate_release_notes: true
          tag_name: ${{ github.ref_name }}

  publish-play-store:
    name: Publish to Google Play
    needs: build-android
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          sparse-checkout: vault-kin/app/whatsnew

      - uses: actions/download-artifact@v4
        with:
          name: android-aab
          path: release/

      - name: Upload to Google Play
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GP_SERVICE_ACCOUNT }}
          packageName: ${{ env.BUNDLE_ID }}
          releaseFiles: release/app-release.aab
          track: ${{ inputs.release_track || 'production' }}
          whatsNewDirectory: vault-kin/app/whatsnew/
```

---

## 10. Secrets & Environment Variables

All sensitive values must be stored as **GitHub Actions Encrypted Secrets** under
Settings → Secrets and Variables → Actions.

| Secret / Variable | Type | Description |
|---|---|---|
| `ANDROID_KEYSTORE_B64` | Secret | Base64-encoded `.jks` keystore file |
| `ANDROID_KEY_ALIAS` | Secret | Alias of the signing key within the keystore |
| `ANDROID_KEY_PASSWORD` | Secret | Password for both the keystore and key |
| `GP_SERVICE_ACCOUNT` | Secret | Google Play API service account JSON (plain text) |
| `VITE_API_URL` | Variable | Base URL of the Express backend (e.g. `https://api.vaultkin.com`) |

### Keystore Generation (one-time, store securely offline)

```bash
keytool -genkeypair \
  -v \
  -keystore release.jks \
  -alias vaultkin-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Encode for GitHub secret
base64 -i release.jks | pbcopy   # macOS — paste into GitHub secret
```

> WARNING: The keystore file is permanent. If lost, you cannot update the Play
> Store listing. Store the original .jks and passwords in a password manager and
> offline secure storage immediately.

---

## 11. Direct Install (Sideload) Delivery

For installation without the Play Store (beta testers, internal users):

1. Download `app-release-signed.apk` from the GitHub Release page
2. On the Android device, go to **Settings → Apps → Special app access → Install unknown apps**
3. Enable for the browser or file manager being used to open the APK
4. Open the downloaded APK file and tap Install

### QR Code Distribution

Generate a QR code pointing to the APK GitHub Release download URL and share via
messaging or printed materials. Update the QR code with each release.

### Internal Testing via Google Play

As an alternative to direct sideload, upload the AAB to **Google Play Internal Testing**
track — this requires only a Google Play Developer account ($25 one-time fee) and
allows up to 100 internal testers to install via a Play Store link with no public listing.

---

## 12. Google Play Store Submission

### 12.1 One-Time Play Console Setup

1. Register at https://play.google.com/console ($25 one-time fee)
2. Create a new application with bundle ID `com.intergist.vaultkin`
3. Complete store listing: description, screenshots (min 2 phone), feature graphic (1024x500)
4. Set up Google Play Signing (recommended — Play manages the upload key)
5. Create a Service Account under **Setup → API access** and grant release permissions
6. Download the Service Account JSON and save as `GP_SERVICE_ACCOUNT` secret

### 12.2 Per-Release Requirements

- Provide release notes in `vault-kin/app/whatsnew/whatsnew-en-US` (plain text, max 500 chars)
- `targetSdkVersion` must meet current Play Store minimum (API 34 as of 2025)
- Privacy Policy URL must be live and accessible at time of submission
- APK/AAB must be signed with the same keystore for all updates

---

## 13. iOS — Deferred Phase

iOS packaging is architecturally straightforward with the same Capacitor setup,
but requires the following before it can be activated:

- Apple Developer Program enrollment ($99/yr): https://developer.apple.com/programs/
- macOS runner (GitHub-hosted `macos-latest` or self-hosted Mac)
- Apple Distribution Certificate + Provisioning Profile
- Xcode project configuration (auto-generated by `npx cap add ios`)

**When ready**, the iOS job slots into the same pipeline after the `build-web` job,
mirroring the Android job with `runs-on: macos-latest` and `xcodebuild archive`.

---

## 14. Versioning & Release Strategy

### Version Number Scheme

```
vMAJOR.MINOR.PATCH  (e.g. v1.2.0)
```

- `versionName` (Android display name) = git tag name (e.g. `1.2.0`)
- `versionCode` (Android integer, monotonically increasing) = `$GITHUB_RUN_NUMBER`
- Both are injected at build time via Gradle environment variable reads (see §6.3)

### Branching Model

| Branch / Ref | Build Output | Distribution |
|---|---|---|
| `main` (vault-kin/ changes) | Debug APK | Artifact only (no signing required) |
| `v*.*.*` tag | Signed APK + AAB | GitHub Release + Play Store |
| Feature branch | No mobile build | Unit tests only |

### Release Procedure

```bash
# 1. Merge feature branches to main and verify
# 2. Update CHANGELOG.md and whatsnew/whatsnew-en-US
# 3. Bump version in package.json
git commit -am "chore: release v1.2.0"

# 4. Tag to trigger pipeline
git tag v1.2.0
git push origin main --tags
```

---

## 15. Compliance Checklist

### Android / Google Play

- [ ] `manifest.json` complete with name, icons (192, 512, maskable), start_url
- [ ] Service worker registered; all assets cached for offline use
- [ ] Satoshi and Inter fonts self-hosted (not CDN-fetched) for offline mode
- [ ] `targetSdk 34` set in build.gradle
- [ ] App signed with a stored, backed-up keystore
- [ ] Privacy policy URL in Play Console listing
- [ ] App functions fully offline (no blank screen without network)
- [ ] SQLite data persists across app restarts
- [ ] `@capacitor-community/sqlite` replaces all `better-sqlite3` references in client
- [ ] No hardcoded `http://localhost` or Express server URLs in offline code paths
- [ ] `whatsnew/whatsnew-en-US` release notes file committed

### Security

- [ ] Keystore backed up offline and in password manager
- [ ] Backup encryption uses strong key derivation (PBKDF2 / Argon2)
- [ ] No API keys or secrets in client-side bundle (`vite build` output)
- [ ] HTTPS-only for all API and backup calls

---

## 16. Open Risks & Decisions

| # | Risk / Decision | Recommendation |
|---|---|---|
| R1 | Drizzle ORM schema sync between server (better-sqlite3) and client (@capacitor-community/sqlite) may diverge | Maintain a single `vault-kin/app/shared/schema.ts` and generate SQL migrations with `drizzle-kit generate:sqlite`; apply on both sides |
| R2 | TanStack React Query cache vs. local SQLite as source of truth | Local SQLite is the primary store; React Query wraps reads/writes to it; server sync is background-only |
| R3 | Satoshi font from Fontshare CDN and Inter from Google Fonts will fail offline | Self-host font files under `vault-kin/app/client/public/fonts/`; update CSS `@font-face` to local path |
| R4 | Capacitor WebView may render Tailwind/shadcn differently than Chrome | Test on Android 10+ physical device or emulator early; Capacitor uses the system WebView (Chrome-based) |
| R5 | Play Store review may flag WebView-only apps | App must demonstrate unique functionality beyond a plain web wrapper; offline capability, SQLite data, and backup features strengthen the case |
| R6 | iOS deferred — may block user base growth | Consider TestFlight distribution once Apple Developer account is obtained; no App Store review required for TestFlight internal testing |

---

## Changelog

### v1.2.0 (March 24, 2026) — Changes from v1.1.0

- **Fixed all directory paths** to match actual monorepo structure: app root is `vault-kin/app/`, not repo root; frontend is at `vault-kin/app/client/`, not `client/`; shared schema is at `vault-kin/app/shared/schema.ts`, not `shared/schema.ts`
- **Fixed `webDir`** in capacitor.config.ts from `client/dist` to `dist/public` (actual Vite output directory per vite.config.ts)
- **Fixed `appId`** from placeholder `com.perplexitycomputer.app` to `com.intergist.vaultkin`
- **Fixed `appName`** from placeholder `PerplexityApp` to `Vault Kin`
- **Fixed `applicationId`** in build.gradle from `com.perplexitycomputer.app` to `com.intergist.vaultkin`
- **Fixed `BUNDLE_ID`** in CI/CD workflow from `com.perplexitycomputer.app` to `com.intergist.vaultkin`
- **Added Inter font** to self-hosting requirements (v1.1.0 only mentioned Satoshi; the app also loads Inter from Google Fonts CDN)
- **Added `paths` filter** to CI/CD workflow `on.push` to only trigger on `vault-kin/app/` changes
- **Added `working-directory`** defaults to CI/CD jobs for monorepo compatibility
- **Fixed `cache-dependency-path`** in CI/CD to point to `vault-kin/app/package-lock.json`
- **Fixed artifact upload/download paths** in CI/CD to use full monorepo paths
- **Updated build scripts** to work from `vault-kin/app/` context (removed `cd client` since Vite config already sets root)
- **Updated database abstraction** file path from `client/src/lib/db.ts` to `vault-kin/app/client/src/lib/mobile-db.ts`
- **Updated database name** from generic `app_local` to `vaultkin_local`
- **Removed `bundledWebRuntime: false`** from capacitor.config.ts (deprecated in Capacitor 6)
- **Updated version references** to match actual package.json versions (Vite 7.3, Express 5.0.1, React 18.3.1, etc.)
- **Updated status** from "Draft" to "Revised — Corrected for Vault Kin project structure"
