import {
  type Vault, type InsertVault, vaults,
  type Section, sections,
  type Category, categories,
  type Entry, type InsertEntry, entries,
  type Bookmark, type InsertBookmark, bookmarks,
  type Reminder, type InsertReminder, reminders,
  type NokListItem, type InsertNokListItem, nokListItems,
} from "@shared/schema";
import { drizzle } from "drizzle-orm/better-sqlite3";
import Database from "better-sqlite3";
import { eq, and, like, or, sql } from "drizzle-orm";

const sqlite = new Database("data.db");
sqlite.pragma("journal_mode = WAL");

export const db = drizzle(sqlite);

export interface IStorage {
  // Vault
  createVault(vault: InsertVault): Vault;
  getVault(id: number): Vault | undefined;
  updateVault(id: number, data: Partial<InsertVault>): Vault | undefined;

  // Sections
  getSectionsByVaultId(vaultId: number): Section[];
  getSectionById(id: number): Section | undefined;

  // Categories
  getCategoriesBySectionId(sectionId: number): Category[];
  getCategoryById(id: number): Category | undefined;

  // Entries
  getEntriesByCategoryId(categoryId: number, vaultId: number): Entry[];
  getEntriesByVaultId(vaultId: number): Entry[];
  getEntryById(id: number): Entry | undefined;
  createEntry(entry: InsertEntry): Entry;
  updateEntry(id: number, data: Partial<InsertEntry>): Entry | undefined;
  deleteEntry(id: number): void;

  // Bookmarks
  getBookmarksByVaultId(vaultId: number): Bookmark[];
  createBookmark(bookmark: InsertBookmark): Bookmark;
  deleteBookmark(id: number): void;

  // Reminders
  getRemindersByVaultId(vaultId: number): Reminder[];
  createReminder(reminder: InsertReminder): Reminder;
  updateReminder(id: number, data: Partial<InsertReminder>): Reminder | undefined;
  deleteReminder(id: number): void;

  // NokListItems
  getNokListItemsByEntryId(entryId: number): NokListItem[];
  createNokListItem(item: InsertNokListItem): NokListItem;
  updateNokListItem(id: number, data: Partial<InsertNokListItem>): NokListItem | undefined;
  toggleNokListItemCheck(id: number): NokListItem | undefined;

  // Search & Stats
  searchEntries(vaultId: number, query: string): Entry[];
  getVaultProgress(vaultId: number): { total: number; completed: number; partial: number; empty: number; percentage: number };
}

export class DatabaseStorage implements IStorage {
  // ── Vault ───────────────────────────────────────────────────────────────
  createVault(vault: InsertVault): Vault {
    const now = new Date().toISOString();
    return db.insert(vaults).values({
      ...vault,
      createdAt: now,
      updatedAt: now,
    }).returning().get();
  }

  getVault(id: number): Vault | undefined {
    return db.select().from(vaults).where(eq(vaults.id, id)).get();
  }

  updateVault(id: number, data: Partial<InsertVault>): Vault | undefined {
    return db.update(vaults)
      .set({ ...data, updatedAt: new Date().toISOString() })
      .where(eq(vaults.id, id))
      .returning()
      .get();
  }

  // ── Sections ────────────────────────────────────────────────────────────
  getSectionsByVaultId(vaultId: number): Section[] {
    return db.select().from(sections).where(eq(sections.vaultId, vaultId)).all();
  }

  getSectionById(id: number): Section | undefined {
    return db.select().from(sections).where(eq(sections.id, id)).get();
  }

  // ── Categories ──────────────────────────────────────────────────────────
  getCategoriesBySectionId(sectionId: number): Category[] {
    return db.select().from(categories).where(eq(categories.sectionId, sectionId)).all();
  }

  getCategoryById(id: number): Category | undefined {
    return db.select().from(categories).where(eq(categories.id, id)).get();
  }

  // ── Entries ─────────────────────────────────────────────────────────────
  getEntriesByCategoryId(categoryId: number, vaultId: number): Entry[] {
    return db.select().from(entries)
      .where(and(eq(entries.categoryId, categoryId), eq(entries.vaultId, vaultId)))
      .all();
  }

  getEntriesByVaultId(vaultId: number): Entry[] {
    return db.select().from(entries).where(eq(entries.vaultId, vaultId)).all();
  }

  getEntryById(id: number): Entry | undefined {
    return db.select().from(entries).where(eq(entries.id, id)).get();
  }

  createEntry(entry: InsertEntry): Entry {
    const now = new Date().toISOString();
    return db.insert(entries).values({
      ...entry,
      createdAt: now,
      updatedAt: now,
    }).returning().get();
  }

  updateEntry(id: number, data: Partial<InsertEntry>): Entry | undefined {
    return db.update(entries)
      .set({ ...data, updatedAt: new Date().toISOString() })
      .where(eq(entries.id, id))
      .returning()
      .get();
  }

  deleteEntry(id: number): void {
    db.delete(entries).where(eq(entries.id, id)).run();
  }

  // ── Bookmarks ───────────────────────────────────────────────────────────
  getBookmarksByVaultId(vaultId: number): Bookmark[] {
    return db.select().from(bookmarks).where(eq(bookmarks.vaultId, vaultId)).all();
  }

  createBookmark(bookmark: InsertBookmark): Bookmark {
    return db.insert(bookmarks).values({
      ...bookmark,
      createdAt: new Date().toISOString(),
    }).returning().get();
  }

  deleteBookmark(id: number): void {
    db.delete(bookmarks).where(eq(bookmarks.id, id)).run();
  }

  // ── Reminders ───────────────────────────────────────────────────────────
  getRemindersByVaultId(vaultId: number): Reminder[] {
    return db.select().from(reminders).where(eq(reminders.vaultId, vaultId)).all();
  }

  createReminder(reminder: InsertReminder): Reminder {
    return db.insert(reminders).values({
      ...reminder,
      createdAt: new Date().toISOString(),
    }).returning().get();
  }

  updateReminder(id: number, data: Partial<InsertReminder>): Reminder | undefined {
    return db.update(reminders)
      .set(data)
      .where(eq(reminders.id, id))
      .returning()
      .get();
  }

  deleteReminder(id: number): void {
    db.delete(reminders).where(eq(reminders.id, id)).run();
  }

  // ── NokListItems ────────────────────────────────────────────────────────
  getNokListItemsByEntryId(entryId: number): NokListItem[] {
    return db.select().from(nokListItems).where(eq(nokListItems.entryId, entryId)).all();
  }

  createNokListItem(item: InsertNokListItem): NokListItem {
    return db.insert(nokListItems).values(item).returning().get();
  }

  updateNokListItem(id: number, data: Partial<InsertNokListItem>): NokListItem | undefined {
    return db.update(nokListItems)
      .set(data)
      .where(eq(nokListItems.id, id))
      .returning()
      .get();
  }

  toggleNokListItemCheck(id: number): NokListItem | undefined {
    const item = db.select().from(nokListItems).where(eq(nokListItems.id, id)).get();
    if (!item) return undefined;

    const newChecked = item.isChecked ? 0 : 1;
    const dateCompleted = newChecked ? new Date().toISOString() : null;

    return db.update(nokListItems)
      .set({ isChecked: newChecked, dateCompleted })
      .where(eq(nokListItems.id, id))
      .returning()
      .get();
  }

  // ── Search ──────────────────────────────────────────────────────────────
  searchEntries(vaultId: number, query: string): Entry[] {
    const pattern = `%${query}%`;
    return db.select().from(entries)
      .where(
        and(
          eq(entries.vaultId, vaultId),
          or(
            like(entries.title, pattern),
            like(entries.fields, pattern),
            like(entries.notes, pattern),
          ),
        ),
      )
      .all();
  }

  // ── Stats ───────────────────────────────────────────────────────────────
  getVaultProgress(vaultId: number): { total: number; completed: number; partial: number; empty: number; percentage: number } {
    const allCategories = db
      .select({ id: categories.id })
      .from(categories)
      .innerJoin(sections, eq(sections.id, categories.sectionId))
      .where(eq(sections.vaultId, vaultId))
      .all();

    const total = allCategories.length;
    if (total === 0) return { total: 0, completed: 0, partial: 0, empty: 0, percentage: 0 };

    const allEntries = this.getEntriesByVaultId(vaultId);

    const categoryEntries = new Map<number, Entry[]>();
    for (const entry of allEntries) {
      const existing = categoryEntries.get(entry.categoryId) || [];
      existing.push(entry);
      categoryEntries.set(entry.categoryId, existing);
    }

    let completed = 0;
    let partial = 0;
    let empty = 0;

    for (const cat of allCategories) {
      const catEntries = categoryEntries.get(cat.id) || [];
      if (catEntries.length === 0) {
        empty++;
      } else if (catEntries.some(e => e.completionStatus === "complete")) {
        completed++;
      } else {
        partial++;
      }
    }

    const percentage = Math.round((completed / total) * 100);

    return { total, completed, partial, empty, percentage };
  }
}

export const storage = new DatabaseStorage();
