/**
 * Offline Backup Service — Stubs
 *
 * Provides encrypted backup and restore of the local SQLite database
 * to a remote server. Data is encrypted client-side with a user-derived
 * key (AES-256-GCM via PBKDF2) before transmission.
 *
 * This file contains the interface and stub implementations.
 * Full implementation will be added when the backup API endpoint is ready.
 */

import { Capacitor } from '@capacitor/core';

/** Result of a backup operation */
export interface BackupResult {
  success: boolean;
  timestamp: string;
  sizeBytes?: number;
  error?: string;
}

/** Result of a restore operation */
export interface RestoreResult {
  success: boolean;
  timestamp: string;
  recordCount?: number;
  error?: string;
}

/** Backup metadata returned by the server */
export interface BackupMetadata {
  lastBackup: string | null;
  sizeBytes: number;
  version: string;
}

/**
 * Create an encrypted backup of the local database and upload it.
 *
 * Stub implementation — logs intent and returns a placeholder result.
 * Will be connected to the backup API endpoint in a future release.
 *
 * @param userPassphrase - Passphrase used to derive the encryption key
 */
export async function createBackup(userPassphrase: string): Promise<BackupResult> {
  if (!Capacitor.isNativePlatform()) {
    console.debug('[backup] Backup not available in browser mode');
    return {
      success: false,
      timestamp: new Date().toISOString(),
      error: 'Backup is only available on native mobile platforms',
    };
  }

  // TODO: Implement when backup API is ready
  // 1. Export local DB via db.exportToJson('full')
  // 2. Encrypt with AES-256-GCM using PBKDF2-derived key from userPassphrase
  // 3. Upload encrypted blob to backup endpoint
  // 4. Return result

  console.log('[backup] createBackup called — stub implementation');
  void userPassphrase; // acknowledged but unused in stub
  return {
    success: false,
    timestamp: new Date().toISOString(),
    error: 'Backup not yet implemented — API endpoint required',
  };
}

/**
 * Download and decrypt a backup, then restore it to the local database.
 *
 * Stub implementation — logs intent and returns a placeholder result.
 *
 * @param userPassphrase - Passphrase used to derive the decryption key
 */
export async function restoreBackup(userPassphrase: string): Promise<RestoreResult> {
  if (!Capacitor.isNativePlatform()) {
    console.debug('[backup] Restore not available in browser mode');
    return {
      success: false,
      timestamp: new Date().toISOString(),
      error: 'Restore is only available on native mobile platforms',
    };
  }

  // TODO: Implement when backup API is ready
  // 1. Download encrypted blob from backup endpoint
  // 2. Decrypt with AES-256-GCM using PBKDF2-derived key from userPassphrase
  // 3. Import into local DB via db.importFromJson(decrypted)
  // 4. Return result

  console.log('[backup] restoreBackup called — stub implementation');
  void userPassphrase; // acknowledged but unused in stub
  return {
    success: false,
    timestamp: new Date().toISOString(),
    error: 'Restore not yet implemented — API endpoint required',
  };
}

/**
 * Check if a backup exists on the server for this device/user.
 *
 * Stub implementation — always returns null (no backup found).
 */
export async function getBackupMetadata(): Promise<BackupMetadata | null> {
  if (!Capacitor.isNativePlatform()) {
    return null;
  }

  // TODO: Implement when backup API is ready
  // 1. Query backup endpoint for latest backup metadata
  // 2. Return metadata or null if none exists

  console.log('[backup] getBackupMetadata called — stub implementation');
  return null;
}

/**
 * Check if the device is online and not on a metered connection.
 * Used to decide whether to trigger automatic backups.
 *
 * Stub — always returns false to prevent automatic backup attempts.
 */
export async function shouldAutoBackup(): Promise<boolean> {
  // TODO: Implement using @capacitor/network
  // 1. Check Network.getStatus() for connectivity
  // 2. Check if connection is metered (avoid backup on mobile data)
  // 3. Check if local DB has been modified since last backup
  return false;
}
