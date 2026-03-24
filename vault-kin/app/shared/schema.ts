import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

// ── Vaults ──────────────────────────────────────────────────────────────────
export const vaults = sqliteTable("vaults", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  name: text("name").notNull(),
  ownerName: text("owner_name").notNull(),
  dateOfBirth: text("date_of_birth"),
  mode: text("mode").notNull().default("owner"),
  masterPassphraseHash: text("master_passphrase_hash").notNull(),
  createdAt: text("created_at").notNull(),
  updatedAt: text("updated_at").notNull(),
});

export const insertVaultSchema = createInsertSchema(vaults).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
export type InsertVault = z.infer<typeof insertVaultSchema>;
export type Vault = typeof vaults.$inferSelect;

// ── Sections ────────────────────────────────────────────────────────────────
export const sections = sqliteTable("sections", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  vaultId: integer("vault_id").notNull().references(() => vaults.id),
  name: text("name").notNull(),
  icon: text("icon").notNull(),
  sortOrder: integer("sort_order").notNull(),
  description: text("description").notNull(),
  isVisible: integer("is_visible").notNull().default(1),
});

export const insertSectionSchema = createInsertSchema(sections).omit({ id: true });
export type InsertSection = z.infer<typeof insertSectionSchema>;
export type Section = typeof sections.$inferSelect;

// ── Categories ──────────────────────────────────────────────────────────────
export const categories = sqliteTable("categories", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  sectionId: integer("section_id").notNull().references(() => sections.id),
  name: text("name").notNull(),
  type: text("type").notNull(), // 'single' or 'multi'
  guidanceText: text("guidance_text").notNull(),
  iconName: text("icon_name").notNull(),
  sortOrder: integer("sort_order").notNull(),
  fieldSchema: text("field_schema").notNull(), // JSON string
});

export const insertCategorySchema = createInsertSchema(categories).omit({ id: true });
export type InsertCategory = z.infer<typeof insertCategorySchema>;
export type Category = typeof categories.$inferSelect;

// ── Entries ──────────────────────────────────────────────────────────────────
export const entries = sqliteTable("entries", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  categoryId: integer("category_id").notNull().references(() => categories.id),
  vaultId: integer("vault_id").notNull().references(() => vaults.id),
  title: text("title").notNull(),
  fields: text("fields").notNull().default("{}"), // JSON string
  completionStatus: text("completion_status").notNull().default("empty"),
  notes: text("notes"),
  createdAt: text("created_at").notNull(),
  updatedAt: text("updated_at").notNull(),
});

export const insertEntrySchema = createInsertSchema(entries).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
export type InsertEntry = z.infer<typeof insertEntrySchema>;
export type Entry = typeof entries.$inferSelect;

// ── Bookmarks ───────────────────────────────────────────────────────────────
export const bookmarks = sqliteTable("bookmarks", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  vaultId: integer("vault_id").notNull().references(() => vaults.id),
  targetType: text("target_type").notNull(),
  targetId: integer("target_id").notNull(),
  label: text("label").notNull(),
  createdAt: text("created_at").notNull(),
});

export const insertBookmarkSchema = createInsertSchema(bookmarks).omit({
  id: true,
  createdAt: true,
});
export type InsertBookmark = z.infer<typeof insertBookmarkSchema>;
export type Bookmark = typeof bookmarks.$inferSelect;

// ── Reminders ───────────────────────────────────────────────────────────────
export const reminders = sqliteTable("reminders", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  vaultId: integer("vault_id").notNull().references(() => vaults.id),
  entryId: integer("entry_id"),
  message: text("message").notNull(),
  scheduledDate: text("scheduled_date").notNull(),
  isCompleted: integer("is_completed").notNull().default(0),
  createdAt: text("created_at").notNull(),
});

export const insertReminderSchema = createInsertSchema(reminders).omit({
  id: true,
  createdAt: true,
});
export type InsertReminder = z.infer<typeof insertReminderSchema>;
export type Reminder = typeof reminders.$inferSelect;

// ── NOK List Items ──────────────────────────────────────────────────────────
export const nokListItems = sqliteTable("nok_list_items", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  entryId: integer("entry_id").notNull().references(() => entries.id),
  text: text("text").notNull(),
  isChecked: integer("is_checked").notNull().default(0),
  actionLog: text("action_log"),
  dateCompleted: text("date_completed"),
});

export const insertNokListItemSchema = createInsertSchema(nokListItems).omit({ id: true });
export type InsertNokListItem = z.infer<typeof insertNokListItemSchema>;
export type NokListItem = typeof nokListItems.$inferSelect;
