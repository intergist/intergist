# Vault Kin

A local-first mobile application for estate planning and life organization. Vault Kin replaces paper checksheets with a guided, section-by-section experience that lets users capture, revisit, and update every aspect of their personal, financial, and legal life — all from their phone.

All data lives on the device. No accounts, no cloud dependency, no telemetry. The app works fully offline from day one, with optional encrypted backup.

## Core Principles

| Principle | Description |
|---|---|
| **Local-First** | All data lives on the device. No accounts, no cloud dependency, no servers. |
| **Privacy by Design** | Data never leaves the device unless the user explicitly initiates an encrypted backup. No telemetry or analytics. |
| **Guided Simplicity** | Walk through each life category step by step — no overwhelming tables or walls of fields. |
| **Living Document** | Gentle reminders and gap-finding encourage ongoing updates. |
| **Shareable Security** | Encrypted exports use passphrase-based encryption so trusted family members can decrypt without account infrastructure. |

## Features

- **17 Life Sections** — Getting Started, Home, Vehicles, Banking, Insurance, Investments, Credit & Debt, Income, Assets, People, Life Story, Health, Digital Life, Legal & Taxes, End of Life, Protected Documents, and a dedicated Next-of-Kin guide
- **Owner & Executor Modes** — The owner organizes their life; the executor follows guided checklists during a difficult time
- **Master Passphrase** — Vault-level passphrase protection with SHA-256 hashing
- **Progress Tracking** — Visual completion indicators across all sections and categories
- **Gap Finder** — Identifies empty or incomplete areas and helps users prioritize
- **Bookmarks** — Pin important entries for quick access
- **Reminders** — Schedule follow-ups for entries that need periodic review
- **Search** — Full-text search across all vault entries
- **NokList Checklists** — Step-by-step action checklists for next-of-kin
- **Dark Mode** — Theme toggle support
- **PWA + Android** — Runs as a progressive web app in any browser, and packages as a native Android app via Capacitor

## Tech Stack

### Frontend

| Layer | Technology |
|---|---|
| Framework | React 18 + TypeScript |
| Styling | Tailwind CSS 3 |
| UI Components | shadcn/ui (Radix UI primitives) |
| Routing | Wouter (hash-based, WebView-compatible) |
| Server State | TanStack React Query |
| Forms | React Hook Form + Zod validation |
| Animations | Framer Motion |
| Charts | Recharts |
| Icons | Lucide React |
| Fonts | Satoshi + Inter (self-hosted woff2 for offline) |
| Date Utilities | date-fns |
| Build Tool | Vite 7 |
| PWA | vite-plugin-pwa (Workbox service worker) |

### Backend

| Layer | Technology |
|---|---|
| Runtime | Node.js |
| Framework | Express 5 |
| ORM | Drizzle ORM |
| Database | better-sqlite3 (server-side) |
| Schema Validation | Zod + drizzle-zod |

### Mobile

| Layer | Technology |
|---|---|
| Container | Capacitor 8 |
| Native DB | @capacitor-community/sqlite |
| Android Build | Gradle |
| CI/CD | GitHub Actions |
| Signing | Android Keystore (apksigner) |
| Distribution | GitHub Releases (APK) + Google Play (AAB) |

## Project Structure

```
vault-kin/
├── README.md
├── doc/
│   ├── vaultkin-app-specification.md        # Full product specification
│   ├── pwa-mobile-packaging-spec-v1.1.0.md  # Mobile packaging spec (draft)
│   └── pwa-mobile-packaging-spec-v1.2.0.md  # Mobile packaging spec (corrected)
└── app/
    ├── client/                   # React frontend
    │   ├── index.html
    │   ├── public/
    │   │   ├── fonts/            # Self-hosted Satoshi + Inter (woff2)
    │   │   └── icons/            # PWA icons (192, 512, 512-maskable)
    │   └── src/
    │       ├── App.tsx           # Root component, routing
    │       ├── main.tsx          # Entry point
    │       ├── index.css         # Global styles
    │       ├── components/       # App components + shadcn/ui
    │       ├── context/          # VaultContext (app state)
    │       ├── hooks/            # Custom hooks
    │       ├── lib/              # Utilities, query client, mobile DB, backup
    │       └── pages/            # Route pages
    ├── server/                   # Express API
    │   ├── index.ts              # Server entry point
    │   ├── routes.ts             # REST API routes
    │   ├── storage.ts            # Database access layer
    │   ├── seedData.ts           # Initial vault data seeder
    │   ├── static.ts             # Static file serving (production)
    │   └── vite.ts               # Vite dev server middleware
    ├── shared/
    │   └── schema.ts             # Drizzle ORM schema (source of truth)
    ├── capacitor.config.ts       # Capacitor Android configuration
    ├── vite.config.ts            # Vite + PWA plugin configuration
    ├── drizzle.config.ts         # Drizzle Kit configuration
    ├── tailwind.config.ts
    ├── tsconfig.json
    ├── package.json
    ├── CHANGELOG.md
    └── whatsnew/
        └── whatsnew-en-US        # Play Store release notes
```

## Data Model

Seven tables managed by Drizzle ORM (`shared/schema.ts`):

| Table | Purpose |
|---|---|
| `vaults` | Top-level vault with owner name, passphrase hash, mode |
| `sections` | Life categories grouped into sections (17 total) |
| `categories` | Sub-categories within sections, each with a JSON field schema |
| `entries` | User-created records within categories (the core data) |
| `bookmarks` | Pinned entries for quick access |
| `reminders` | Scheduled follow-ups tied to entries |
| `nok_list_items` | Checklist items for the Next-of-Kin action guide |

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/vault` | Create a new vault |
| `POST` | `/api/vault/unlock` | Unlock vault with passphrase |
| `GET` | `/api/vault/:id` | Get vault details |
| `PUT` | `/api/vault/:id` | Update vault |
| `GET` | `/api/sections/:vaultId` | List sections for a vault |
| `GET` | `/api/categories/:sectionId` | List categories in a section |
| `GET` | `/api/category/:id` | Get single category |
| `GET` | `/api/entries/:categoryId?vaultId=` | List entries in a category |
| `GET` | `/api/entries/vault/:vaultId` | List all entries in a vault |
| `GET` | `/api/entry/:id` | Get single entry |
| `POST` | `/api/entries` | Create entry |
| `PUT` | `/api/entries/:id` | Update entry |
| `DELETE` | `/api/entries/:id` | Delete entry |
| `GET` | `/api/search?vaultId=&q=` | Full-text search |
| `GET` | `/api/progress/:vaultId` | Vault completion progress |
| `GET/POST/DELETE` | `/api/bookmarks/...` | Bookmark CRUD |
| `GET/POST/PUT/DELETE` | `/api/reminders/...` | Reminder CRUD |
| `GET/POST/PUT` | `/api/noklist/...` | NokList item CRUD |
| `PUT` | `/api/noklist/:id/toggle` | Toggle NokList item check |

## Getting Started

### Prerequisites

- Node.js 20+
- npm

### Development

```bash
cd vault-kin/app

# Install dependencies
npm install

# Start dev server (Express + Vite HMR)
npm run dev
```

The app starts at `http://localhost:5000` with hot module replacement.

### Production Build

```bash
# Build frontend + backend
npm run build

# Start production server
npm start
```

### Database

The SQLite database is created automatically on first run. To push schema changes:

```bash
npm run db:push
```

## Mobile Build (Android)

### One-Time Setup

Before the first Android build, generate the Capacitor android directory. This requires the [Android SDK](https://developer.android.com/studio):

```bash
cd vault-kin/app
npx cap add android
```

Commit the generated `android/` directory.

### Build Commands

```bash
# Build web assets only
npm run build:web

# Sync web assets into Android shell
npm run cap:sync

# Debug APK (no signing required)
npm run cap:build:debug

# Release APK + AAB (requires keystore)
npm run cap:build:release

# Full pipeline: build → sync → release
npm run mobile:build
```

### Keystore

Generate a signing keystore (one-time, store securely):

```bash
keytool -genkeypair \
  -v \
  -keystore release.jks \
  -alias app-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> **Warning:** The keystore is permanent. If lost, you cannot update the Play Store listing. Back it up in a password manager and offline secure storage immediately.

### Sideload Install

1. Download `app-release-signed.apk` from the [GitHub Releases](https://github.com/intergist/intergist/releases) page
2. On Android: Settings → Apps → Special app access → Install unknown apps
3. Enable for the browser or file manager used to open the APK
4. Open the downloaded APK and tap Install

## CI/CD

The GitHub Actions workflow (`.github/workflows/mobile-build.yml`) automates builds:

| Trigger | Output | Distribution |
|---|---|---|
| Push to `main` (vault-kin/app changes) | Debug APK | Artifact download only |
| Push `v*.*.*` tag | Signed APK + AAB | GitHub Release + Google Play |
| Manual `workflow_dispatch` | Signed APK + AAB | GitHub Release |

### Required Secrets

| Name | Description |
|---|---|
| `ANDROID_KEYSTORE_B64` | Base64-encoded `.jks` keystore file |
| `ANDROID_KEY_ALIAS` | Signing key alias |
| `ANDROID_KEY_PASSWORD` | Keystore and key password |
| `GP_SERVICE_ACCOUNT` | Google Play API service account JSON |

### Required Variables

| Name | Description |
|---|---|
| `VITE_API_URL` | Base URL of the Express backend |

### Release Procedure

```bash
# 1. Update CHANGELOG.md and whatsnew/whatsnew-en-US
# 2. Commit changes
git commit -am "chore: release v1.1.0"

# 3. Tag to trigger the pipeline
git tag v1.1.0
git push origin main --tags
```

## Documentation

Detailed specifications are in the `doc/` folder:

- **[App Specification](doc/vaultkin-app-specification.md)** — Full product spec with personas, information architecture, screen flows, data model, security architecture, and field catalog
- **[Mobile Packaging Spec v1.2.0](doc/pwa-mobile-packaging-spec-v1.2.0.md)** — Capacitor Android packaging, CI/CD pipeline, SQLite migration, and offline backup strategy (corrected for project structure)
- **[Mobile Packaging Spec v1.1.0](doc/pwa-mobile-packaging-spec-v1.1.0.md)** — Original draft specification

## License

MIT
