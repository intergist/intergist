# VaultKin — Mobile Application Specification

**Version:** 1.0  
**Date:** March 24, 2026  
**Status:** Draft  
**Platforms:** Android (API 26+) · iOS (15.0+)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Vision & Personas](#2-product-vision--personas)
3. [Information Architecture](#3-information-architecture)
4. [User Experience & Screen Flows](#4-user-experience--screen-flows)
5. [Data Model](#5-data-model)
6. [Security Architecture](#6-security-architecture)
7. [Cloud Backup & Family Sharing](#7-cloud-backup--family-sharing)
8. [Navigation & Progress Tracking](#8-navigation--progress-tracking)
9. [Password Manager Integration](#9-password-manager-integration)
10. [Notifications & Reminders](#10-notifications--reminders)
11. [Additional Features](#11-additional-features)
12. [Accessibility & Internationalization](#12-accessibility--internationalization)
13. [Platform & Technical Requirements](#13-platform--technical-requirements)
14. [Adaptive Layout for Larger Form Factors](#adaptive-layout-for-larger-form-factors)
15. [Appendix A — Full Field Catalog](#appendix-a--full-field-catalog)
16. [Appendix B — Encryption Technical Detail](#appendix-b--encryption-technical-detail)
17. [Appendix C — Glossary](#appendix-c--glossary)

---

## 1. Executive Summary

**VaultKin** is a local-first mobile application that digitizes and modernizes the estate-planning and life-organization systems. It replaces paper checksheets with a guided, section-by-section mobile experience that allows users to capture, revisit, and update every aspect of their personal, financial, and legal life — all from their phone.

### Core Principles

| Principle | Description |
|---|---|
| **Local-First** | All data lives on the device. No accounts, no cloud dependency, no servers. The app works fully offline from day one. |
| **Privacy by Design** | Data never leaves the device unless the user explicitly initiates an encrypted backup. There is no telemetry, no analytics on user content, and no server-side processing. |
| **Guided Simplicity** | The app walks users through each life category step by step — no overwhelming tables or walls of fields. Users add entries one at a time and can always come back. |
| **Living Document** | The app encourages ongoing updates with gentle reminders and makes it easy to jump to any section, find gaps, and pick up where you left off. |
| **Shareable Security** | Encrypted exports use a passphrase-based scheme so that trusted family members can decrypt backups without any account infrastructure or key servers. |

### What VaultKin Is Not

- It is **not a password manager** (but it integrates with them)
- It is **not a legal document** (but it organizes references to them)
- It is **not a financial tool** (but it records financial information for estate purposes)
- It is **not a cloud service** (but it supports encrypted cloud backup)

---

## 2. Product Vision & Personas

### Vision Statement

*VaultKin empowers every adult to organize their life in one secure place on their phone, so that the people they love are never left guessing.*

### Target Personas

#### Persona 1 — "The Planner" (Primary)
- **Age:** 45–70
- **Profile:** Responsible adult thinking proactively about estate organization. May have purchased a physical NOKbox and wants a digital companion, or prefers to go digital-only.
- **Motivation:** Peace of mind. Wants everything documented so their family is not burdened.
- **Concerns:** Privacy and security of sensitive data. Ease of use — not tech-savvy. Wants to work at their own pace.
- **Device:** Mid-range Android or iPhone. Moderate comfort with apps.

#### Persona 2 — "The Executor" (Secondary)
- **Age:** 30–60
- **Profile:** Adult child, spouse, or friend who has been designated as someone's Next of Kin or executor. May be using the app after a loss.
- **Motivation:** Needs to find and manage information efficiently during a difficult time.
- **Concerns:** Speed of access. Clarity of what has been documented vs. what is missing. Needs to track their own progress through the NokList.
- **Device:** Any modern smartphone. Comfortable with apps.

#### Persona 3 — "The Couple" (Tertiary)
- **Age:** 35–65
- **Profile:** Partners who want to organize together. Each has their own vault but may share access.
- **Motivation:** Mutual preparedness. Doing this together makes it less daunting.
- **Concerns:** How to share data securely between two devices.

---

## 3. Information Architecture

VaultKin organizes information into **Sections**, each containing one or more **Categories**, each containing user-created **Entries**. This three-level hierarchy eliminates rigid paper tables in favor of dynamic, repeatable entry forms.

### Section Map

| # | Section | Categories | Entry Type |
|---|---|---|---|
| 1 | **Getting Started** | Welcome & Guided Setup, Crucial Information, Letter to NOK | Single-entry |
| 2 | **Your Home** | Primary Residence, Utilities & HOA, Maintenance Log, People & Access, Home Inventory | Mixed |
| 3 | **Vehicles** | Vehicle (repeatable) | Multi-entry |
| 4 | **Banking & Money** | Bank Accounts, Debit Cards, Money Apps | Multi-entry |
| 5 | **Insurance** | Insurance Policies | Multi-entry |
| 6 | **Investments** | Investment Accounts | Multi-entry |
| 7 | **Credit & Debt** | Major Credit Cards, Retail Credit Cards, Student Debt, Personal Loans, Medical Debt | Multi-entry |
| 8 | **Income & Employment** | Current Employment, Side Income, Social Security, Retirement Income, Other Income | Mixed |
| 9 | **Assets & Properties** | Tangible Assets, Additional Properties (each property is a sub-vault) | Multi-entry |
| 10 | **Your People** | Dependents, Pets, Friends & Social Circles | Multi-entry |
| 11 | **Your Life Story** | Education & Transcripts, Past Employment, Military Service, Ancestry, Sentimental Items | Mixed |
| 12 | **Health & Medical** | Current Medical, Past Medical, Healthcare Providers, Medicare/Medicaid | Mixed |
| 13 | **Digital Life** | Communities & Organizations, Subscriptions & Memberships, Social Media, Other Online Accounts | Multi-entry |
| 14 | **Legal & Taxes** | Tax Records, Legal Documents, Will/Trust, Medical Directives, Financial POA, Guardianship | Mixed |
| 15 | **End of Life** | Disposition & Funeral Wishes, Memorial Service Preferences, Pre-Arrangements, Letters & Recordings | Mixed |
| 16 | **Protected Documents** | Document checklist, Key System log | Mixed |
| 17 | **For Your Next of Kin** | NOK Action Guide, Immediate Steps Checklist, Section-by-section NokLists | Read + checklist |

**Multi-entry** categories allow the user to tap "Add Another" to create unlimited entries (e.g., add another bank account, another pet, another insurance policy). **Single-entry** and **Mixed** categories have a fixed set of fields but may contain repeatable sub-sections.

---

## 4. User Experience & Screen Flows

### 4.1 Onboarding Flow

```
[Welcome Screen]
    "Organize your life. Protect your family."
    ↓
[Privacy Promise Screen]
    "Your data never leaves this device unless you choose to back it up."
    → Continue
    ↓
[Set Master Passphrase]
    Create a strong passphrase (min 12 chars or 4-word passphrase)
    + Enable biometric unlock (Face ID / fingerprint)
    ↓
[Quick Profile]
    Full name, Date of birth (minimal — optional at this stage)
    ↓
[Choose Your Path]
    ○ "I'm organizing my own life" → Owner Mode
    ○ "I'm managing someone else's estate" → Executor Mode
    ↓
[Home Dashboard]
```

### 4.2 Home Dashboard

The dashboard is the app's central hub. It displays:

- **Welcome banner** with the user's name and a motivational nudge
- **Progress ring** — overall completion percentage across all sections
- **Section cards** — one card per section (scrollable grid or list), each showing:
  - Section icon and name
  - Mini progress bar (e.g., "3 of 7 categories started")
  - "Continue" badge if the user has incomplete entries
  - "New" badge for sections not yet visited
- **Quick Actions bar:**
  - 🔍 Search (full-text search across all entered data)
  - 📷 Scan Document (camera shortcut)
  - 🔔 Reminders
  - ⚙️ Settings
- **Gap Alert banner** (if enabled): "You have 4 sections with no entries yet. Tap to see."

### 4.3 Section View

Tapping a section card opens the **Section View**:

- **Section header** with description and guidance text (collapsible)
- **Category list** — each category shows:
  - Name and icon
  - Entry count (e.g., "2 bank accounts")
  - Completion indicator (empty / in progress / complete)
  - Tap to open

### 4.4 Category View — Multi-Entry

For categories like "Bank Accounts" or "Insurance Policies":

```
[Category Header]
    Brief guidance: "Record each bank you use. Include account details 
    and beneficiary information."

[Entry Cards — scrollable list]
    ┌─────────────────────────────┐
    │ 🏦 Chase Bank               │
    │ Checking ••••4521           │
    │ 6 of 11 fields completed   │
    │ Last updated: Jan 15, 2026 │
    └─────────────────────────────┘
    ┌─────────────────────────────┐
    │ 🏦 Wells Fargo              │
    │ Savings ••••8890            │
    │ 11 of 11 fields ✓ Complete │
    └─────────────────────────────┘

[+ Add Another Bank Account]  ← Floating action button or bottom button
```

### 4.5 Entry Form — Detail View

Tapping an entry card opens the **Entry Form**. This is the core data-entry experience.

**Design Principles:**
- Fields are organized in **collapsible groups** (e.g., "Account Details," "Access Information," "Beneficiary," "Notes for NOK")
- Only the current group is expanded; others show a summary line
- Fields use appropriate input types: text, number, date picker, dropdown, toggle, secure (masked) text for passwords
- Every field has subtle **help text** explaining what belongs there and why
- An **"I'll do this later"** option marks a field as intentionally skipped (different from empty)
- A **notes field** is always available at the bottom for free-form text
- **Attachments:** Users can attach photos (camera or gallery) to any entry — e.g., a photo of a statement, an insurance card, a policy document. Attachments are stored locally and included in encrypted backups.

**Entry Form Example — Bank Account:**

```
┌──────────────────────────────────┐
│ ← Back              🗑️ Delete   │
│                                  │
│ Chase Bank                       │
│ Last saved: 2 min ago (auto)     │
│                                  │
│ ▼ Bank Details                   │
│   Bank Name: [Chase            ] │
│   Website:   [chase.com        ] │
│   Branch:    [San Jose Main    ] │
│                                  │
│ ▼ Account Details                │
│   Account #: [••••••4521       ] │
│   Type:      [Checking ▾       ] │
│   Name/DBA:  [Personal         ] │
│   Opened:    [2018    ▾        ] │
│                                  │
│ ▶ Online Access (2 of 3 filled)  │
│ ▶ Debit Cards (1 card added)     │
│ ▶ Beneficiary & POA (incomplete) │
│ ▶ Auto-Payments (3 entries)      │
│ ▶ Attachments (1 photo)          │
│ ▶ Notes for NOK                  │
│                                  │
│ ──── NokList ────                │
│ ▶ Instructions for your NOK      │
│   (read-only guidance text with  │
│    checkboxes for the executor)  │
│                                  │
│         [Mark as Complete ✓]     │
└──────────────────────────────────┘
```

### 4.6 NokList View

Each category includes a **NokList** — the executor-facing checklist. In Owner Mode, this appears as a collapsible read-only section at the bottom of each entry ("Here's what your NOK will need to do with this item"). In Executor Mode, NokList items become interactive checkboxes with space for the executor to log actions taken, dates, and notes.

### 4.7 Document Scanner

A built-in camera-based document scanner allows users to:

1. Photograph a document (statement, card, policy, receipt)
2. Auto-crop and enhance (perspective correction, contrast adjustment)
3. Attach the image to the current entry or choose a section/category
4. Optionally run on-device OCR to extract text (no data sent to any server)

### 4.8 Search

**Global search** across all entered data:
- Searches field values, notes, and attachment OCR text
- Results grouped by section → category → entry
- Tap a result to jump directly to that entry
- Search is performed entirely on-device against the local database

---

## 5. Data Model

### 5.1 Entity-Relationship Overview

```
User (1)
  ├── Profile
  ├── CrucialInfo
  ├── NOKLetter
  │
  ├── Section (17)
  │     ├── name, icon, sortOrder, description
  │     ├── Category (1..n)
  │     │     ├── name, type (single|multi), schema, guidanceText
  │     │     ├── Entry (0..n)
  │     │     │     ├── id (UUID)
  │     │     │     ├── categoryId
  │     │     │     ├── fields: JSON (key-value, flexible schema)
  │     │     │     ├── attachments: [Attachment]
  │     │     │     ├── nokListStatus: JSON (checklist state)
  │     │     │     ├── completionStatus: enum (empty|partial|complete|skipped)
  │     │     │     ├── createdAt, updatedAt
  │     │     │     └── notes: String
  │     │     └── NokListTemplate (guidance + checklist items)
  │     └── progress (computed)
  │
  ├── Attachment (0..n)
  │     ├── id, entryId, filePath (local), mimeType
  │     ├── ocrText (nullable)
  │     └── createdAt
  │
  ├── Bookmark (0..n)
  │     ├── id, targetType (section|category|entry), targetId
  │     └── createdAt
  │
  ├── Reminder (0..n)
  │     ├── id, targetType, targetId, scheduledDate, message
  │     └── isCompleted
  │
  └── BackupMetadata
        ├── lastBackupDate, backupDestination
        └── encryptionKeyFingerprint
```

### 5.2 Storage Engine

| Concern | Technology |
|---|---|
| **Primary database** | SQLCipher (encrypted SQLite) — all data encrypted at rest with AES-256-CBC via the user's master key |
| **Attachment storage** | Encrypted files in app-private storage (Android: internal storage; iOS: app container with NSFileProtectionComplete) |
| **Schema flexibility** | Entry field data stored as encrypted JSON blobs, allowing schema evolution without migrations for user data |
| **Cross-platform** | Kotlin Multiplatform (KMP) or Flutter with platform-specific secure storage hooks |

### 5.3 Field Schema System

Rather than hard-coding every form, VaultKin uses a **declarative field schema** for each category. This enables:

- Adding new fields in app updates without data migration
- Different field types: `text`, `secureText`, `number`, `currency`, `date`, `dropdown`, `toggle`, `multiline`, `phone`, `email`, `url`
- Grouping fields into collapsible sections
- Marking fields as `required`, `recommended`, or `optional`
- Attaching help text and placeholder examples to each field

**Example schema (JSON) for a Bank Account entry:**

```json
{
  "categoryId": "bank_account",
  "groups": [
    {
      "id": "bank_details",
      "label": "Bank Details",
      "fields": [
        {"id": "bank_name", "label": "Bank Name", "type": "text", "priority": "required"},
        {"id": "website", "label": "Website", "type": "url", "priority": "recommended"},
        {"id": "branch", "label": "Branch / Location", "type": "text", "priority": "optional"}
      ]
    },
    {
      "id": "account_details",
      "label": "Account Details",
      "fields": [
        {"id": "account_number", "label": "Account Number", "type": "secureText", "priority": "required"},
        {"id": "account_type", "label": "Account Type", "type": "dropdown",
         "options": ["Checking", "Savings", "Money Market", "CD", "Other"], "priority": "required"},
        {"id": "account_name", "label": "Account Name / DBA", "type": "text", "priority": "recommended"},
        {"id": "beneficiary", "label": "Beneficiary", "type": "text", "priority": "required",
         "helpText": "Most accounts can have a Payable on Death beneficiary to avoid probate."}
      ]
    },
    {
      "id": "online_access",
      "label": "Online Access",
      "fields": [
        {"id": "username", "label": "Username", "type": "text", "priority": "recommended"},
        {"id": "password", "label": "Password", "type": "secureText", "priority": "recommended",
         "helpText": "Or use a password manager and note that here."}
      ]
    }
  ]
}
```

---

## 6. Security Architecture

### 6.1 Threat Model

| Threat | Mitigation |
|---|---|
| Device theft / loss | Master passphrase + biometric unlock required. SQLCipher encrypts all data at rest. iOS/Android secure enclave protects key material. |
| Shoulder surfing | Secure fields masked by default. App lock on background (configurable timeout). |
| Cloud backup interception | End-to-end encryption with XChaCha20-Poly1305 before upload. Cloud provider never sees plaintext. |
| Brute-force passphrase attack | Argon2id key derivation with high memory cost makes offline attacks extremely expensive. |
| Malicious app / screen capture | FLAG_SECURE (Android) / screen capture prevention (iOS) on sensitive screens. No clipboard for secure fields unless user explicitly copies. |
| Compromised cloud storage | Encryption is independent of cloud provider. Even full access to Google Drive yields only ciphertext. |
| Family sharing risk | Passphrase-based scheme: anyone with the passphrase can decrypt. No keys stored on servers. User controls who receives the passphrase. |

### 6.2 Master Key Derivation

```
User Passphrase
       │
       ▼
   Argon2id(passphrase, salt, m=256MB, t=4, p=2)
       │
       ▼
   Master Key (256-bit)
       │
       ├──▶ SQLCipher database encryption key
       ├──▶ File encryption key (for attachments)
       └──▶ Backup encryption key (derived via HKDF for domain separation)
```

**Argon2id Parameters (recommended defaults):**

| Parameter | Value | Rationale |
|---|---|---|
| Memory (m) | 256 MB | High memory cost defeats GPU/ASIC attacks. Mobile devices from 2020+ have ≥4 GB RAM. Adjustable downward for older devices. |
| Iterations (t) | 4 | Balances security with ~1.5 second derivation time on mid-range devices |
| Parallelism (p) | 2 | Matches typical mobile CPU core count |
| Salt | 32 bytes, random | Generated on first setup, stored unencrypted alongside database |
| Output | 32 bytes (256-bit key) | Sufficient for XChaCha20-Poly1305 |

### 6.3 Data-at-Rest Encryption

- **Database:** SQLCipher 4.x with AES-256 in CBC mode (SQLCipher's native encryption). The master key from Argon2id is used as the SQLCipher key.
- **Attachments:** Each file encrypted individually with XChaCha20-Poly1305 using a per-file random nonce (24 bytes). The file encryption key is derived from the master key via HKDF with the context string `"vaultkin-attachment"`.
- **Key storage:** On Android, the Argon2id salt and encrypted key verification token are stored in Android Keystore-backed EncryptedSharedPreferences. On iOS, they are stored in the Secure Enclave-backed Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

### 6.4 Biometric Unlock

- After initial passphrase entry, the master key is wrapped (encrypted) using a hardware-backed biometric key (Android Keystore / iOS Secure Enclave).
- On subsequent opens, biometric authentication unwraps the master key without re-entering the passphrase.
- The user must re-enter the passphrase after: 72 hours of inactivity, device restart, 3 failed biometric attempts, or any change to enrolled biometrics.

### 6.5 App Lock

- App locks immediately when backgrounded (or after configurable delay: 0s, 15s, 1min, 5min)
- Unlock via biometric or passphrase
- Panic / duress: optional "decoy passphrase" that opens an empty vault (advanced feature for high-risk users)

### 6.6 Secure Display

- Screens containing sensitive data (passwords, SSN, account numbers) use:
  - `FLAG_SECURE` on Android (prevents screenshots and screen recording)
  - Screen capture prevention APIs on iOS
- Secure fields show `••••••••` by default with a tap-to-reveal toggle (auto-hides after 10 seconds)
- Clipboard auto-clears after 30 seconds if a secure field is copied

---

## 7. Cloud Backup & Family Sharing

### 7.1 Backup Architecture

VaultKin treats cloud storage as a **dumb encrypted file store**. The app never authenticates to a cloud account for anything other than file upload/download.

```
Local Vault (SQLCipher DB + encrypted attachments)
       │
       ▼
   Export: serialize entire vault to a single binary blob
       │
       ▼
   Compress (zstd)
       │
       ▼
   Encrypt (XChaCha20-Poly1305, key derived from backup passphrase via Argon2id)
       │
       ▼
   Write as: VaultKin_Backup_2026-03-24.vaultkin
       │
       ▼
   Upload to connected cloud storage
```

### 7.2 Backup File Format (`.vaultkin`)

```
Bytes 0-7:    Magic number: "VKBK0001" (8 bytes, ASCII)
Bytes 8-11:   Format version (uint32, little-endian)
Bytes 12-15:  Argon2id memory parameter (uint32)
Bytes 16-17:  Argon2id iterations (uint16)
Bytes 18:     Argon2id parallelism (uint8)
Bytes 19-50:  Salt (32 bytes)
Bytes 51-74:  Nonce (24 bytes, for XChaCha20-Poly1305)
Bytes 75+:    Ciphertext (compressed vault data + 16-byte Poly1305 auth tag)
```

This self-contained format means the file includes everything needed to decrypt it (except the passphrase). No external key server, no account, no app-specific infrastructure.

### 7.3 Supported Cloud Providers

| Provider | Integration Method | Notes |
|---|---|---|
| **Google Drive** | Google Drive API (Android) / REST API (iOS) | User authenticates via OAuth 2.0. App requests access only to its own app folder (`appDataFolder` or a user-visible folder). |
| **iCloud Drive** | CloudKit / iCloud Documents (iOS native) | Seamless for iOS users. |
| **Dropbox** | Dropbox API v2 | Cross-platform option. |
| **Local / Manual** | Export to Files app / Share sheet | User can save the `.vaultkin` file anywhere — USB, email, AirDrop, etc. |

### 7.4 Automatic Backup

- User can enable **automatic backup** on a schedule (daily, weekly, monthly)
- Backup occurs only on Wi-Fi (configurable) and when plugged in (configurable)
- App retains the last N backups (default: 5) on cloud, auto-deleting older ones
- A notification confirms each successful backup

### 7.5 Family Sharing Protocol

**Scenario:** Alice organizes her VaultKin. She wants her daughter, Beth, to be able to access her vault if needed.

1. Alice creates (or uses) a **Backup Passphrase** — this can be the same as her master passphrase or a separate, dedicated sharing passphrase
2. Alice exports an encrypted `.vaultkin` backup to Google Drive
3. Alice shares the passphrase with Beth through a secure channel (in person, on paper in a sealed envelope, via a password manager's secure sharing feature, etc.)
4. Beth installs VaultKin, taps **"Restore from Backup,"** selects the `.vaultkin` file, and enters the passphrase
5. Beth now has a **read-only copy** of Alice's vault on her own device (or full read-write if Alice intends her to manage it)

**No accounts. No servers. No key exchange protocols.** The passphrase *is* the key.

### 7.6 Backup Passphrase vs. Master Passphrase

Users may optionally set a **separate backup passphrase** for sharing purposes. This way:
- The master passphrase (used daily with biometrics) can be complex and personal
- The backup passphrase (shared with family) can be a memorable phrase or set of words
- Changing the master passphrase does not invalidate existing backups
- Revoking family access = create a new backup with a new backup passphrase

---

## 8. Navigation & Progress Tracking

### 8.1 Navigation Architecture

VaultKin uses a **tab + drawer** navigation model:

**Bottom Tab Bar (persistent):**

| Tab | Function |
|---|---|
| 🏠 Home | Dashboard with section cards and progress ring |
| 📋 Sections | Full section list with expandable categories |
| 🔍 Search | Global search across all data |
| 📌 Bookmarks | Saved bookmarks and "Continue where I left off" |
| ⚙️ Settings | App settings, backup, security, about |

**Section Drawer (swipe from left or tap hamburger):**
- Full tree: Section → Category → Entries
- Tap any node to jump directly

### 8.2 "Continue Where I Left Off"

- The app automatically bookmarks the **last entry** the user was editing
- A persistent "Continue" button on the dashboard returns to this exact entry and field group
- If the user was in the middle of typing, the form state is preserved (auto-saved every 5 seconds)

### 8.3 Progress Tracking

**Per-Entry:** Each entry has a completion status calculated from its field schema:
- **Empty:** No fields filled
- **In Progress:** Some required or recommended fields filled
- **Complete:** All required fields filled (recommended fields contribute to a "thoroughness" score)
- **Skipped:** User explicitly marked as "Not applicable"

**Per-Category:** Aggregated from entries. Displays: `"3 of 5 accounts complete"`

**Per-Section:** Aggregated from categories. Displayed as a progress ring on each section card.

**Overall:** A single progress ring on the dashboard showing total completion.

### 8.4 Gap Detection

The **Gap Finder** is accessible from the dashboard and from the Sections tab. It shows:

1. **Empty sections** — Sections with zero entries (highest priority)
2. **Incomplete entries** — Entries missing required fields
3. **Stale entries** — Entries not updated in over 12 months (configurable)
4. **Missing NokList items** — Categories where the NokList template has not been reviewed

Each gap is tappable and navigates directly to the relevant entry or section.

### 8.5 Section Jump

From any screen, the user can:
- Tap the **section breadcrumb** at the top to jump up the hierarchy
- Use the **section drawer** to jump to any section/category/entry
- Use **Search** to find any data and jump to it
- Use the **Bookmarks** tab to jump to saved locations

### 8.6 Bookmarks

Users can bookmark any section, category, or entry for quick access. Bookmarks appear in the dedicated Bookmarks tab and can be reordered or removed.

---

## 9. Password Manager Integration

### 9.1 Strategy

VaultKin is **not a password manager** and does not attempt to replace one. Instead, it integrates with the user's existing password manager to:

1. **Auto-fill credentials** — When the user taps a username or password field in VaultKin, the device's autofill framework surfaces credentials from the user's password manager
2. **Import credentials** — Users can optionally import a CSV export from their password manager to pre-populate account usernames/passwords across VaultKin entries
3. **Reference, don't duplicate** — For users who prefer not to store passwords in VaultKin at all, each credential field offers a toggle: *"Stored in my password manager"* — which records that fact (and optionally the entry name in the password manager) without storing the actual password

### 9.2 Platform Integration

**Android:**
- Integrate with the **Credential Manager API** (Android 14+) and the legacy **Autofill Framework** (Android 8+)
- When a `secureText` field gains focus, the system autofill UI appears with credentials from the user's configured password manager (1Password, Bitwarden, Google Password Manager, etc.)
- VaultKin declares its autofill-eligible fields using `importantForAutofill` hints

**iOS:**
- Integrate with **Password AutoFill** via Associated Domains or the AutoFill Credential Provider extension
- `secureText` fields use `.textContentType(.password)` or `.textContentType(.username)` to trigger QuickType bar suggestions from iCloud Keychain, 1Password, Bitwarden, etc.
- No additional work needed for apps that already use standard UITextField/SecureField — the OS handles the rest

### 9.3 Supported Password Managers

VaultKin works with **any password manager** that supports the platform autofill framework. This includes but is not limited to:

- 1Password
- Bitwarden
- LastPass
- Dashlane
- Google Password Manager
- Apple Keychain / Passwords app
- KeePass (via compatible autofill plugins)
- Proton Pass

### 9.4 CSV Import

For bulk population, VaultKin supports importing a standard CSV export (as produced by most password managers). The import wizard:

1. Reads the CSV and maps columns (url, username, password, notes)
2. Presents a preview of matched entries
3. Allows the user to assign each imported credential to a VaultKin category (bank, insurance, social media, etc.)
4. Populates the appropriate fields in new or existing entries

The CSV is processed entirely on-device and deleted after import.

---

## 10. Notifications & Reminders

### 10.1 Built-In Reminders

| Reminder | Default Schedule | Configurable? |
|---|---|---|
| **Review nudge** | Every 6 months: "Time to review your VaultKin! Anything changed?" | Yes (3/6/12 months or off) |
| **Gap reminder** | Monthly, if empty sections exist: "You have 3 sections waiting for you." | Yes |
| **Backup reminder** | If no backup in 30 days: "Your last backup was 32 days ago." | Yes |
| **Stale entry alert** | If any entry >12 months old: "5 entries haven't been updated in over a year." | Yes |

### 10.2 Custom Reminders

Users can set custom reminders on any entry:
- "Renew auto insurance" → reminder on a specific date
- "Update tax return" → annual reminder
- "Review investment beneficiaries" → after life events

### 10.3 Life Event Prompts

When the user updates certain entries, VaultKin may suggest related updates:
- Added a new dependent → "Would you like to review your guardianship documents?"
- Changed address → "Don't forget to update your utilities, voter registration, and insurance."
- Added a new bank account → "Would you like to set up a beneficiary?"

---

## 11. Additional Features

### 11.1 Document Photo Capture & OCR

- Built-in camera with auto-crop, perspective correction, and contrast enhancement
- On-device OCR (ML Kit on Android, Vision framework on iOS) — no network calls
- OCR text is searchable via global search
- Attach photos to any entry

### 11.2 PDF Export

- Export the entire vault (or selected sections) as a formatted, printable PDF
- PDF includes all entered data, organized by section and category
- PDF can be encrypted with a passphrase (PDF encryption) or exported as plaintext for printing
- Useful for: sharing with an attorney, placing a paper copy in a safe, or printing a physical NOKbox equivalent

### 11.3 Emergency Card Widget

- A home screen widget (Android) or Lock Screen widget (iOS) showing:
  - Emergency contact name and phone number
  - Medical alert information (allergies, conditions, blood type)
  - "In case of emergency, my VaultKin is located on this device"
- Widget content is configurable and does **not** require unlocking the vault
- Only user-selected, non-sensitive information is displayed

### 11.4 Dual-Vault Mode (Couples)

- A single VaultKin installation can host **two vaults** — one for each partner
- Each vault has its own passphrase and encryption
- Users switch between vaults from the lock screen
- Backups are separate files

### 11.5 Executor Mode

When restoring from a backup (or toggling in settings), the user can enter **Executor Mode**:

- NokList checklists become interactive (checkboxes, action log, date stamps)
- A dedicated "Executor Dashboard" shows:
  - Prioritized action items (immediate, within 30 days, ongoing)
  - Progress through NokList items
  - Financial summary (accounts, balances, recurring payments identified)
- Entries can be annotated by the executor without modifying the original owner's data

### 11.6 Guided Walkthrough ("Getting Started" Wizard)

For new users who feel overwhelmed:
- A step-by-step wizard walks through the 5 most critical items first:
  1. Crucial Information sheet
  2. Letter to NOK
  3. One bank account
  4. One insurance policy
  5. Will/Trust status
- Completing this "Quick Start" takes ~15 minutes and gives the user immediate value

### 11.7 Dark Mode & Theming

- Full dark mode support
- Optional: color-coded sections matching the physical NOKbox folder colors (for users migrating from paper)

### 11.8 Accessibility

- VoiceOver (iOS) and TalkBack (Android) full support
- Dynamic type / font scaling
- High-contrast mode
- All interactive elements have minimum 48dp touch targets
- No information conveyed by color alone

### 11.9 Data Portability

- **Export:** JSON (structured), PDF (human-readable), CSV (for spreadsheet use)
- **Import:** CSV (from password managers), `.vaultkin` backup files
- **Migration from physical NOKbox:** Guided section-by-section workflow with prompts matched to the physical folder labels

---

## 12. Accessibility & Internationalization

### 12.1 Accessibility Standards

- WCAG 2.1 Level AA compliance
- Screen reader support with meaningful labels for all form fields and navigation elements
- Haptic feedback for confirmations and errors
- Voice input support for form fields (system dictation)
- Minimum font size: 14sp (Android) / 14pt (iOS), with Dynamic Type scaling up to 200%

### 12.2 Internationalization

- **Launch language:** English (US)
- **Architecture:** All strings externalized for localization. Date, currency, and number formats respect device locale.
- **Future languages:** Spanish, French, German, Portuguese (based on market demand)
- **RTL support:** Layout system supports right-to-left languages from v1.0 architecture

---

## 13. Platform & Technical Requirements

### 13.1 Supported Platforms

| Platform | Minimum Version | Target Version |
|---|---|---|
| Android | API 26 (Android 8.0 Oreo) | API 35 (Android 15) |
| iOS | 15.0 | 18.x |

### 13.2 Development Approach

| Option | Description | Recommendation |
|---|---|---|
| **Flutter** | Single codebase (Dart), excellent UI toolkit, strong crypto library ecosystem (pointycastle, flutter_secure_storage), SQLCipher via sqflite_sqlcipher | **Recommended** for v1.0 — fastest path to feature parity on both platforms |
| **Kotlin Multiplatform** | Shared business logic (Kotlin), native UI (Jetpack Compose / SwiftUI) | Strong alternative if native UI fidelity is prioritized |
| **Fully Native** | Separate Android (Kotlin) and iOS (Swift) codebases | Highest fidelity but doubles development effort |

### 13.3 Key Libraries & Dependencies

| Concern | Android | iOS | Cross-Platform (Flutter) |
|---|---|---|---|
| Database | SQLCipher (Room + SQLCipher driver) | SQLCipher (GRDB + SQLCipher) | sqflite_sqlcipher |
| Encryption | Tink (Google) / libsodium-jni | CryptoKit / libsodium | flutter_sodium / pointycastle |
| Argon2id | argon2kt | Swift-Argon2 | dargon2_flutter |
| Secure storage | AndroidKeystore + EncryptedSharedPreferences | Keychain Services | flutter_secure_storage |
| Biometrics | BiometricPrompt API | LocalAuthentication (LAContext) | local_auth |
| Camera/OCR | CameraX + ML Kit | AVFoundation + Vision | camera + google_mlkit_text_recognition |
| Cloud APIs | Google Drive API, Dropbox SDK | CloudKit, Google Drive REST, Dropbox SDK | googleapis, dropbox_client |
| Autofill | Autofill Framework / Credential Manager | Password AutoFill (UITextField) | Platform channels |
| PDF Generation | iText / Android PDF | PDFKit | pdf (dart package) |
| Compression | zstd-jni | libcompression (zstd) | archive |

### 13.4 Performance Requirements

| Metric | Target |
|---|---|
| Cold start to lock screen | < 2 seconds |
| Unlock (biometric) to dashboard | < 500ms |
| Unlock (passphrase + Argon2id) to dashboard | < 3 seconds |
| Search query response | < 200ms for vaults with up to 500 entries |
| Backup export (typical vault, ~50MB with photos) | < 30 seconds |
| Backup upload | Network-dependent; progress indicator shown |
| Auto-save latency | < 100ms (background write) |

### 13.5 Storage Estimates

| Component | Estimated Size |
|---|---|
| App binary | ~30-50 MB |
| Empty database | ~1 MB |
| Typical vault (200 entries, 50 photos) | ~50-150 MB |
| Large vault (500 entries, 200 photos) | ~300-500 MB |
| Encrypted backup (compressed) | ~40-60% of vault size |

---

## 14. Adaptive Layout for Larger Form Factors

VaultKin must treat screen size as a continuum — not a binary phone-vs-tablet distinction. The same app binary adapts its layout based on the **available window width**, not the device type. This ensures correct behavior on iPads (full-screen, Split View, Slide Over), Android tablets, foldables in various postures, and even ChromeOS windowed mode.

### 14.1 Window Size Classes

VaultKin adopts a three-tier breakpoint model aligned with both Apple Human Interface Guidelines and Android's `WindowSizeClass` system:

| Size Class | Window Width | Typical Contexts | Layout Strategy |
|---|---|---|---|
| **Compact** | < 600 dp | Phones, iPad 1/3 Split View, foldable cover screen | Single-pane. Bottom tab bar. Full-screen forms. |
| **Medium** | 600 – 1023 dp | iPad portrait, iPad 2/3 Split View, small Android tablets, foldable inner display | Two-pane master–detail. Navigation rail replaces bottom tabs. Side-by-side entry list + form. |
| **Expanded** | ≥ 1024 dp | iPad landscape (full-screen), large Android tablets, desktop/ChromeOS | Three-pane with persistent sidebar. Section tree + category list + entry detail all visible simultaneously. |

> **Critical rule:** Never check `if (device == iPad)`. Always branch on the current window's width. An iPad in 1/3 Split View is narrower than many phones — it must receive the Compact layout.

### 14.2 Layout Configurations

#### Compact Layout (Phone)

This is the baseline layout described in Section 4 of this specification:

```
┌──────────────────────┐
│ App Bar / Breadcrumb  │
│                       │
│   Single content pane │
│   (section list, OR   │
│    category list, OR  │
│    entry form)        │
│                       │
│                       │
├───────────────────────┤
│ 🏠  📋  🔍  📌  ⚙️   │  ← Bottom tab bar
└───────────────────────┘
```

Navigation is stack-based: Dashboard → Section → Category → Entry, each pushing onto the navigation stack. The user taps Back to return up the hierarchy.

#### Medium Layout (Tablet Portrait / Foldable)

The bottom tab bar is replaced by a **navigation rail** on the leading edge. The main area splits into a **master list** and **detail pane**:

```
┌──┬────────────┬────────────────────────┐
│  │ Section /  │                        │
│🏠│ Category   │   Entry Detail Form    │
│  │ List       │                        │
│📋│            │   (or section welcome  │
│  │ Bank Accts │    when no entry is    │
│🔍│  ▸ Chase   │    selected)           │
│  │  ▸ Wells F │                        │
│📌│  ▸ + Add   │                        │
│  │            │                        │
│⚙️│            │                        │
└──┴────────────┴────────────────────────┘
     Navigation   Master pane              Detail pane
     rail         (~320 dp)                (remaining width)
```

**Behavior:**
- Tapping a section in the rail updates the master pane with that section's categories and entries
- Tapping an entry in the master pane opens its form in the detail pane — no navigation push, no screen transition
- The master list remains visible and scrollable while the user edits the detail form
- Adding a new entry opens the blank form in the detail pane immediately
- The Gap Finder and Search results appear in the master pane; tapping a result loads the detail pane

**Benefit:** Users can rapidly switch between entries (e.g., reviewing all bank accounts) without repeatedly navigating back and forth. This alone transforms the tablet experience.

#### Expanded Layout (iPad Landscape / Large Tablet)

A full **three-pane** layout with a persistent sidebar:

```
┌─────────────┬────────────┬──────────────────────────────┐
│  VaultKin   │            │                              │
│             │ Category   │                              │
│ ▾ Home      │ List       │   Entry Detail Form          │
│   Residence │            │                              │
│   Utilities │ Bank Accts │   Chase Bank                 │
│   Repairs   │  ▸ Chase ● │   ─────────────────          │
│   People    │  ▸ Wells   │   ▼ Bank Details             │
│   Inventory │  ▸ BofA    │     Name: [Chase           ] │
│             │            │     Website: [chase.com    ] │
│ ▾ Finances  │ Money Apps │                              │
│   Banking ● │  ▸ Venmo   │   ▶ Account Details (3/4)   │
│   Money Apps│  ▸ PayPal  │   ▶ Online Access            │
│   Insurance │            │   ▶ Debit Cards (1)          │
│   Investing │ Insurance  │   ▶ Beneficiary & POA        │
│   Credit    │  ▸ State F │   ▶ Auto-Payments (3)        │
│   Debt      │  ▸ Allstat │   ▶ Attachments (1 photo)   │
│             │  ▸ + Add   │   ▶ Notes for NOK            │
│ ▾ Income    │            │                              │
│   ...       │            │   [Mark as Complete ✓]       │
│             │            │                              │
│ ─────────── │            │                              │
│ 🔍 Search   │            │                              │
│ 📌 Bookmarks│            │                              │
│ ⚙️ Settings │            │                              │
└─────────────┴────────────┴──────────────────────────────┘
  Sidebar        Master pane     Detail pane
  (~240 dp)      (~300 dp)       (remaining width)
```

**Behavior:**
- The **sidebar** shows the full section → category tree with disclosure triangles. It replaces both the dashboard grid and the bottom tabs. Progress indicators (● dots or mini rings) appear next to each category.
- The **master pane** shows the entries within the selected category, with completion badges and last-updated dates.
- The **detail pane** shows the entry form with generous spacing, wider fields, and the ability to display two field groups side by side when appropriate.
- Search, Bookmarks, and Settings are accessed from the sidebar footer — not from a separate tab.
- The sidebar can be collapsed (toggled) to give more room to the master + detail panes.

**Benefit:** The entire hierarchy — all sections, all categories, all entries — is navigable without a single screen transition. The user can scan their progress at a glance and drill into any entry with two taps.

### 14.3 Tablet-Optimized Entry Forms

On Compact screens, entry forms use a single-column layout with collapsible field groups. On Medium and Expanded screens, forms gain density and spatial efficiency:

| Enhancement | Medium (≥ 600 dp) | Expanded (≥ 1024 dp) |
|---|---|---|
| **Field layout** | Single column, but wider fields with inline labels (label left, input right) | Two-column grid for short fields (e.g., "City" and "State" side by side) |
| **Group expansion** | Multiple groups can be expanded simultaneously | All groups expanded by default; scrollable |
| **Attachments** | Thumbnail strip below entry | Thumbnail grid in a side panel |
| **NokList** | Collapsible at bottom | Displayed in a fixed panel alongside the entry form, or in a right-side column |
| **Action buttons** | Bottom of form | Sticky toolbar at top of detail pane |
| **Keyboard** | On-screen keyboard pushes form up | Hardware keyboard support with Tab-key field traversal and keyboard shortcuts |

### 14.4 Drag and Drop

On iPad and Android tablets, VaultKin supports drag and drop for:

- **Reordering entries** within a category (e.g., moving a bank account to the top of the list)
- **Moving entries between categories** (e.g., reclassifying a retail credit card as a major credit card)
- **Importing photos** — drag an image from Files or Photos into the entry form to add it as an attachment
- **Multi-window workflows** — drag a `.vaultkin` backup file from Files into VaultKin to initiate a restore

### 14.5 Pointer and Keyboard Support

Tablet users often have a keyboard case, Apple Pencil, or Bluetooth mouse. VaultKin supports:

- **Hover states** on all interactive elements (visual feedback on pointer hover)
- **Right-click / long-press context menus** on entries (Edit, Delete, Bookmark, Mark Complete)
- **Keyboard shortcuts:**

| Shortcut | Action |
|---|---|
| `⌘ + F` / `Ctrl + F` | Open global search |
| `⌘ + N` / `Ctrl + N` | New entry in current category |
| `⌘ + S` / `Ctrl + S` | Force save (though auto-save is continuous) |
| `⌘ + B` / `Ctrl + B` | Bookmark current entry |
| `⌘ + \\` / `Ctrl + \\` | Toggle sidebar (Expanded layout) |
| `Tab` / `Shift + Tab` | Move between form fields |
| `Escape` | Close detail pane / go back |
| `⌘ + ,` / `Ctrl + ,` | Open Settings |

- **Apple Pencil / stylus support** — handwriting input in text fields via Scribble (iPadOS) or stylus input (Android)

### 14.6 Foldable Device Support

For Android foldable devices (Samsung Galaxy Z Fold series, Google Pixel Fold, etc.):

| Posture | Behavior |
|---|---|
| **Folded (cover screen)** | Compact layout. Optimized for quick glance — dashboard and search only. |
| **Unfolded (flat)** | Medium or Expanded layout based on inner display width. Seamless state continuity — the entry being edited on the cover screen appears in the detail pane on unfold. |
| **Tabletop (half-folded)** | Upper half: entry form. Lower half: category list or NokList. Useful for propping the device on a table while organizing papers. |
| **Book posture** | Left pane: master list. Right pane: detail form. Natural for reading and data entry. |

VaultKin uses the Jetpack WindowManager API (Android) to detect hinge position and posture, and avoids placing interactive elements or text across the hinge/fold seam.

### 14.7 Multi-Window and Stage Manager

| Platform Feature | VaultKin Support |
|---|---|
| **iPadOS Stage Manager** | Full support for resizable windows. Layout adapts fluidly as the window is resized. Minimum supported window size: 320 × 480 pt (Compact layout). |
| **iPadOS Split View / Slide Over** | Layout responds to the 16 possible width configurations. Slide Over uses Compact layout. |
| **Android Multi-Window** | Supports split-screen and freeform windowing. Handles `onConfigurationChanged` without activity recreation. |
| **Android Picture-in-Picture** | Not applicable (VaultKin has no media content). |

### 14.8 Implementation Approach (Flutter)

For the recommended Flutter framework, adaptive layouts are implemented using:

```dart
class AdaptiveScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return ExpandedLayout();   // Three-pane
        } else if (constraints.maxWidth >= 600) {
          return MediumLayout();     // Two-pane + nav rail
        } else {
          return CompactLayout();    // Single-pane + bottom tabs
        }
      },
    );
  }
}
```

Key Flutter packages and patterns:

- **`flutter_adaptive_scaffold`** (official Material package) — provides `AdaptiveScaffold` with built-in breakpoints, navigation rail/bar switching, and pane management
- **`LayoutBuilder`** — branches on actual constraints, not device type
- **`NavigationRail`** ↔ **`NavigationBar`** — automatic switching at breakpoint
- **`MediaQuery.sizeOf(context)`** — cached, efficient access to window dimensions
- **`ViewThatFits`** (Compose-inspired pattern) — tries larger layouts first, falls back gracefully
- **Platform channels** for Jetpack WindowManager (foldable posture detection on Android)

### 14.9 Testing Matrix

All three layout configurations must be tested across the following representative contexts:

| Context | Width Class | Test Scenarios |
|---|---|---|
| iPhone SE | Compact | Smallest supported phone |
| iPhone 16 Pro Max | Compact | Largest phone |
| iPad Mini (portrait) | Medium | Smallest tablet |
| iPad Air (portrait) | Medium | Standard tablet |
| iPad Pro 12.9" (landscape) | Expanded | Maximum real estate |
| iPad — 1/3 Split View | Compact | Narrowest iPad context |
| iPad — 1/2 Split View | Medium | Mid-width iPad |
| iPad — Stage Manager (various sizes) | All three | Resizable window |
| Samsung Galaxy Z Fold (cover) | Compact | Narrow foldable |
| Samsung Galaxy Z Fold (inner, unfolded) | Medium | Wide foldable |
| Samsung Galaxy Z Fold (tabletop) | Medium | Hinge-aware posture |
| Pixel Tablet | Medium / Expanded | Android tablet |
| ChromeOS (windowed) | All three | Resizable desktop window |

---
---

## Appendix A — Full Field Catalog

The complete field catalog for all 17 sections and their categories is defined in the companion document: `VaultKin_Field_Catalog.json`. This catalog is the source of truth for form generation and is versioned with the app.

**Summary statistics:**
- 17 sections
- 47 categories
- ~320 unique field definitions
- 31 multi-entry (repeatable) categories
- 16 single-entry / mixed categories

Each field definition includes: `id`, `label`, `type`, `priority` (required/recommended/optional), `helpText`, `placeholder`, `group`, `validationRules`, and `nokListRelevance` (whether this field appears in the NokList view).

---

## Appendix B — Encryption Technical Detail

### B.1 Algorithm Selection Rationale

| Algorithm | Purpose | Why Selected |
|---|---|---|
| **XChaCha20-Poly1305** | Symmetric encryption + authentication (backup files, attachments) | RFC 8439 standardized. 192-bit nonce eliminates nonce-collision risk for random nonces. 3× faster than AES-GCM on devices without AES-NI hardware (common on older/budget Android). Side-channel resistant (ARX construction, no lookup tables). Integrated authentication (Poly1305) prevents tampering. Widely adopted: used by TLS 1.3, WireGuard, Cloudflare, Signal. |
| **Argon2id** | Key derivation from passphrase | Winner of the Password Hashing Competition (2015). Recommended by OWASP, endorsed by NIST. Memory-hard: defeats GPU/ASIC brute-force attacks. Argon2**id** variant combines data-independent (side-channel resistant) and data-dependent (GPU-resistant) passes. Tunable parameters (memory, iterations, parallelism) allow balancing security with mobile performance. |
| **SQLCipher (AES-256-CBC)** | Database encryption at rest | Industry standard for encrypted SQLite. Used by Signal, 1Password, and major banking apps. Hardware-accelerated AES on most modern devices. Transparent to the application layer — no code changes vs. standard SQLite. |
| **HKDF-SHA256** | Domain separation (deriving sub-keys from master key) | RFC 5869 standardized. Deterministic: same master key yields same sub-keys. Used to derive separate keys for database, attachments, and backups from a single master key. |

### B.2 Why Not AES-GCM?

AES-GCM is an excellent algorithm and the most widely deployed AEAD cipher. However, for VaultKin's specific use case:

1. **Nonce management:** AES-GCM's 96-bit nonce creates a real collision risk (~50% at 2^48 encryptions with the same key). XChaCha20's 192-bit nonce is safe with random generation — critical for an app that encrypts many individual files.
2. **Software performance:** On ARM devices without ARMv8 Crypto Extensions (budget Android phones), ChaCha20 is significantly faster than AES. VaultKin targets API 26+, which includes many devices without hardware AES.
3. **Implementation safety:** AES-GCM is brittle — nonce reuse catastrophically breaks authentication and leaks the authentication key. XChaCha20-Poly1305 is more forgiving of implementation variations.

### B.3 Quantum Resistance Considerations

Neither AES-GCM nor XChaCha20-Poly1305 is quantum-proof against Grover's algorithm (which halves effective key length). However:

- 256-bit symmetric keys provide 128-bit post-quantum security — widely considered sufficient for the foreseeable future
- VaultKin's backup files are **not long-lived public targets** (they're in personal cloud storage, not on public servers)
- When NIST post-quantum standards mature for symmetric authenticated encryption, VaultKin can migrate via a format version bump in the `.vaultkin` file header

### B.4 Key Lifecycle

```
┌────────────────────────────────────────────────┐
│                 SETUP                           │
│  User creates passphrase                        │
│  → Generate random 32-byte salt                 │
│  → Argon2id(passphrase, salt) → Master Key      │
│  → HKDF(MK, "db") → DB Key                     │
│  → HKDF(MK, "files") → File Encryption Key     │
│  → HKDF(MK, "backup") → Backup Key             │
│  → Store salt in app preferences                │
│  → Wrap MK with biometric key → secure storage  │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│              DAILY USE                           │
│  Biometric → unwrap MK → derive sub-keys        │
│  All DB reads/writes use DB Key (via SQLCipher)  │
│  Attachment reads/writes use File Key            │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│          PASSPHRASE CHANGE                      │
│  Verify old passphrase                          │
│  → Generate new salt                            │
│  → Argon2id(new_passphrase, new_salt) → New MK  │
│  → Re-wrap with biometric key                   │
│  → Re-encrypt DB key with new MK                │
│  → Existing backups remain decryptable with      │
│    their original backup passphrase              │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│             BACKUP EXPORT                       │
│  If separate backup passphrase configured:      │
│  → Argon2id(backup_passphrase, new_salt) → BK   │
│  Else: use Backup Key from MK derivation        │
│  → Serialize + compress vault                   │
│  → XChaCha20-Poly1305(BK, random_nonce, data)   │
│  → Write .vaultkin file                         │
└────────────────────────────────────────────────┘
```

---

## Appendix C — Glossary

| Term | Definition |
|---|---|
| **NOK** | Next of Kin — the person(s) designated to manage your affairs |
| **NokList** | The executor-facing checklist for each category, guiding them through managing that item |
| **VaultKin** | This mobile application |
| **Vault** | The complete set of a user's data within VaultKin |
| **Entry** | A single record within a category (e.g., one bank account, one pet, one insurance policy) |
| **Section** | A top-level organizational grouping (e.g., "Your Finances") |
| **Category** | A sub-grouping within a section (e.g., "Bank Accounts") |
| **Master Passphrase** | The primary passphrase used to encrypt and access the vault |
| **Backup Passphrase** | An optional separate passphrase used to encrypt cloud backups for family sharing |
| **SQLCipher** | An encrypted version of SQLite, used for on-device database storage |
| **XChaCha20-Poly1305** | A modern authenticated encryption algorithm used for backup files and attachments |
| **Argon2id** | A memory-hard key derivation function used to convert passphrases into encryption keys |
| **HKDF** | HMAC-based Key Derivation Function, used to derive multiple sub-keys from a single master key |
| **Gap Finder** | A feature that identifies incomplete or missing sections in the vault |
| **Executor Mode** | An app mode designed for the person managing someone else's estate |

---

*VaultKin — Secure your legacy. Empower your next of kin.*

*Specification v1.0 — March 2026*
