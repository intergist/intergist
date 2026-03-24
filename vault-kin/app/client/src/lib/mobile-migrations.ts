/**
 * Mobile SQLite Schema Migrations
 *
 * These migrations create the same table structure as the server-side
 * Drizzle schema (shared/schema.ts) but using raw SQL for the
 * @capacitor-community/sqlite plugin.
 *
 * The server-side better-sqlite3 database is NOT touched by these
 * migrations — they only apply to the on-device mobile database.
 *
 * Add new migrations to the array as the schema evolves. Each migration
 * runs inside a transaction and is tracked by version number.
 */

import type { SQLiteDBConnection } from '@capacitor-community/sqlite';

interface Migration {
  version: number;
  description: string;
  sql: string[];
}

/**
 * Migrations array — append new migrations here.
 * Never modify existing migrations that have been released.
 */
export const migrations: Migration[] = [
  {
    version: 1,
    description: 'Initial schema — mirrors shared/schema.ts',
    sql: [
      // Migration tracking table
      `CREATE TABLE IF NOT EXISTS _migrations (
        version INTEGER PRIMARY KEY,
        applied_at TEXT NOT NULL
      )`,

      // Vaults
      `CREATE TABLE IF NOT EXISTS vaults (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        date_of_birth TEXT,
        mode TEXT NOT NULL DEFAULT 'owner',
        master_passphrase_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Sections
      `CREATE TABLE IF NOT EXISTS sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL REFERENCES vaults(id),
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        description TEXT NOT NULL,
        is_visible INTEGER NOT NULL DEFAULT 1
      )`,

      // Categories
      `CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section_id INTEGER NOT NULL REFERENCES sections(id),
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        guidance_text TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        field_schema TEXT NOT NULL
      )`,

      // Entries
      `CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL REFERENCES categories(id),
        vault_id INTEGER NOT NULL REFERENCES vaults(id),
        title TEXT NOT NULL,
        fields TEXT NOT NULL DEFAULT '{}',
        completion_status TEXT NOT NULL DEFAULT 'empty',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Bookmarks
      `CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL REFERENCES vaults(id),
        target_type TEXT NOT NULL,
        target_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        created_at TEXT NOT NULL
      )`,

      // Reminders
      `CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL REFERENCES vaults(id),
        entry_id INTEGER,
        message TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )`,

      // NOK List Items
      `CREATE TABLE IF NOT EXISTS nok_list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL REFERENCES entries(id),
        text TEXT NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0,
        action_log TEXT,
        date_completed TEXT
      )`,
    ],
  },
];

/**
 * Run all pending migrations against the mobile database.
 * Call this on app startup before any data operations.
 */
export async function runMigrations(db: SQLiteDBConnection): Promise<void> {
  // Ensure migration tracking table exists
  await db.execute(
    `CREATE TABLE IF NOT EXISTS _migrations (
      version INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    )`,
  );

  // Get already-applied versions
  const applied = await db.query('SELECT version FROM _migrations ORDER BY version');
  const appliedVersions = new Set(
    (applied.values ?? []).map((row: Record<string, unknown>) => row.version as number),
  );

  // Apply pending migrations in order
  for (const migration of migrations) {
    if (appliedVersions.has(migration.version)) {
      continue;
    }

    console.log(`[mobile-db] Applying migration v${migration.version}: ${migration.description}`);

    for (const sql of migration.sql) {
      await db.execute(sql);
    }

    await db.run(
      'INSERT INTO _migrations (version, applied_at) VALUES (?, ?)',
      [migration.version, new Date().toISOString()],
    );
  }
}
