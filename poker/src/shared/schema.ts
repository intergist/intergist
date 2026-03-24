// No database tables needed — this is a client-only app
// Keep minimal imports so the template build doesn't break
import { pgTable, text, varchar } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

// Placeholder table to satisfy template requirements
export const users = pgTable("users", {
  id: varchar("id").primaryKey(),
  username: text("username").notNull(),
});

export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
});

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;
