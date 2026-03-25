/**
 * Mobile Database Abstraction Layer
 *
 * Platform-aware database abstraction that uses @capacitor-community/sqlite
 * on native Android and falls back to a no-op browser stub in development.
 *
 * On native platforms, this provides a local SQLite database that mirrors
 * the server-side schema (defined in shared/schema.ts). The server-side
 * better-sqlite3 database is NOT modified — this is a client-only layer.
 *
 * Usage:
 *   import { getDb, closeDb } from '@/lib/mobile-db';
 *   const db = await getDb();
 *   const result = await db.query('SELECT * FROM vaults');
 */

import { Capacitor } from '@capacitor/core';
import {
  CapacitorSQLite,
  SQLiteConnection,
  SQLiteDBConnection,
} from '@capacitor-community/sqlite';

const DB_NAME = 'vaultkin_local';
const DB_VERSION = 1;

let sqlite: SQLiteConnection | null = null;
let dbConnection: SQLiteDBConnection | null = null;

/**
 * Returns a SQLite database connection on native platforms,
 * or a browser-compatible stub for development/testing.
 */
export async function getDb(): Promise<SQLiteDBConnection> {
  if (!Capacitor.isNativePlatform()) {
    return getBrowserDb();
  }

  if (dbConnection) {
    return dbConnection;
  }

  if (!sqlite) {
    sqlite = new SQLiteConnection(CapacitorSQLite);
  }

  dbConnection = await sqlite.createConnection(
    DB_NAME,
    false,            // encrypted
    'no-encryption',  // encryption mode
    DB_VERSION,       // version
    false,            // readonly
  );

  await dbConnection.open();
  return dbConnection;
}

/**
 * Close the database connection. Call on app pause/destroy.
 */
export async function closeDb(): Promise<void> {
  if (dbConnection && sqlite) {
    await sqlite.closeConnection(DB_NAME, false);
    dbConnection = null;
  }
}

/**
 * Browser fallback — returns a stub that logs operations.
 * In production web mode, the app uses the Express API instead of local SQLite.
 */
function getBrowserDb(): SQLiteDBConnection {
  const stub = {
    open: async () => {},
    close: async () => {},
    execute: async (sql: string) => {
      console.debug('[mobile-db] Browser stub execute:', sql);
      return { changes: { changes: 0, lastId: 0 } };
    },
    query: async (sql: string) => {
      console.debug('[mobile-db] Browser stub query:', sql);
      return { values: [] };
    },
    run: async (sql: string, values?: unknown[]) => {
      console.debug('[mobile-db] Browser stub run:', sql, values);
      return { changes: { changes: 0, lastId: 0 } };
    },
    isDBOpen: async () => ({ result: true }),
    exportToJson: async () => ({ export: {} }),
  } as unknown as SQLiteDBConnection;

  return stub;
}
