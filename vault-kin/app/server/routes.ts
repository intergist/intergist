import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { seedVaultData } from "./seedData";
import crypto from "crypto";

function hashPassphrase(passphrase: string): string {
  return crypto.createHash("sha256").update(passphrase).digest("hex");
}

export async function registerRoutes(
  httpServer: Server,
  app: Express,
): Promise<Server> {
  // ── Vault ─────────────────────────────────────────────────────────────
  app.post("/api/vault", (req, res) => {
    try {
      const { name, ownerName, dateOfBirth, mode, passphrase } = req.body;

      if (!name || !ownerName || !passphrase) {
        return res.status(400).json({ message: "Name, ownerName, and passphrase are required" });
      }

      const masterPassphraseHash = hashPassphrase(passphrase);

      const vault = storage.createVault({
        name,
        ownerName,
        dateOfBirth: dateOfBirth || null,
        mode: mode || "owner",
        masterPassphraseHash,
      });

      // Seed all sections and categories for this vault
      seedVaultData(vault.id);

      // Don't return the passphrase hash
      const { masterPassphraseHash: _, ...safeVault } = vault;
      res.status(201).json(safeVault);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.post("/api/vault/unlock", (req, res) => {
    try {
      const { vaultId, passphrase } = req.body;

      if (!vaultId || !passphrase) {
        return res.status(400).json({ message: "vaultId and passphrase are required" });
      }

      const vault = storage.getVault(vaultId);
      if (!vault) {
        return res.status(404).json({ message: "Vault not found" });
      }

      const hash = hashPassphrase(passphrase);
      if (hash !== vault.masterPassphraseHash) {
        return res.status(401).json({ message: "Invalid passphrase" });
      }

      const { masterPassphraseHash: _, ...safeVault } = vault;
      res.json(safeVault);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.get("/api/vault/:id", (req, res) => {
    try {
      const vault = storage.getVault(Number(req.params.id));
      if (!vault) {
        return res.status(404).json({ message: "Vault not found" });
      }
      const { masterPassphraseHash: _, ...safeVault } = vault;
      res.json(safeVault);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.put("/api/vault/:id", (req, res) => {
    try {
      const vault = storage.updateVault(Number(req.params.id), req.body);
      if (!vault) {
        return res.status(404).json({ message: "Vault not found" });
      }
      const { masterPassphraseHash: _, ...safeVault } = vault;
      res.json(safeVault);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Sections ──────────────────────────────────────────────────────────
  app.get("/api/sections/:vaultId", (req, res) => {
    try {
      const sectionList = storage.getSectionsByVaultId(Number(req.params.vaultId));
      res.json(sectionList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Categories ────────────────────────────────────────────────────────
  app.get("/api/categories/:sectionId", (req, res) => {
    try {
      const categoryList = storage.getCategoriesBySectionId(Number(req.params.sectionId));
      res.json(categoryList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.get("/api/category/:id", (req, res) => {
    try {
      const category = storage.getCategoryById(Number(req.params.id));
      if (!category) {
        return res.status(404).json({ message: "Category not found" });
      }
      res.json(category);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Entries ───────────────────────────────────────────────────────────
  // Single entry by ID — must be registered before /api/entries/:categoryId
  app.get("/api/entry/:id", (req, res) => {
    try {
      const entry = storage.getEntryById(Number(req.params.id));
      if (!entry) {
        return res.status(404).json({ message: "Entry not found" });
      }
      res.json(entry);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.get("/api/entries/:categoryId", (req, res) => {
    try {
      const vaultId = Number(req.query.vaultId);
      if (!vaultId) {
        return res.status(400).json({ message: "vaultId query parameter is required" });
      }
      const entryList = storage.getEntriesByCategoryId(Number(req.params.categoryId), vaultId);
      res.json(entryList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.get("/api/entries/vault/:vaultId", (req, res) => {
    try {
      const entryList = storage.getEntriesByVaultId(Number(req.params.vaultId));
      res.json(entryList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.post("/api/entries", (req, res) => {
    try {
      const { categoryId, vaultId, title, fields, completionStatus, notes } = req.body;

      if (!categoryId || !vaultId || !title) {
        return res.status(400).json({ message: "categoryId, vaultId, and title are required" });
      }

      const entry = storage.createEntry({
        categoryId,
        vaultId,
        title,
        fields: fields ? (typeof fields === "string" ? fields : JSON.stringify(fields)) : "{}",
        completionStatus: completionStatus || "empty",
        notes: notes || null,
      });

      res.status(201).json(entry);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.put("/api/entries/:id", (req, res) => {
    try {
      const { fields, ...rest } = req.body;
      const data: any = { ...rest };
      if (fields !== undefined) {
        data.fields = typeof fields === "string" ? fields : JSON.stringify(fields);
      }

      const entry = storage.updateEntry(Number(req.params.id), data);
      if (!entry) {
        return res.status(404).json({ message: "Entry not found" });
      }
      res.json(entry);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.delete("/api/entries/:id", (req, res) => {
    try {
      storage.deleteEntry(Number(req.params.id));
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Search ────────────────────────────────────────────────────────────
  app.get("/api/search", (req, res) => {
    try {
      const vaultId = Number(req.query.vaultId);
      const q = String(req.query.q || "");

      if (!vaultId || !q) {
        return res.status(400).json({ message: "vaultId and q query parameters are required" });
      }

      const results = storage.searchEntries(vaultId, q);
      res.json(results);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Progress ──────────────────────────────────────────────────────────
  app.get("/api/progress/:vaultId", (req, res) => {
    try {
      const progress = storage.getVaultProgress(Number(req.params.vaultId));
      res.json(progress);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Bookmarks ─────────────────────────────────────────────────────────
  app.get("/api/bookmarks/:vaultId", (req, res) => {
    try {
      const bookmarkList = storage.getBookmarksByVaultId(Number(req.params.vaultId));
      res.json(bookmarkList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.post("/api/bookmarks", (req, res) => {
    try {
      const { vaultId, targetType, targetId, label } = req.body;

      if (!vaultId || !targetType || !targetId || !label) {
        return res.status(400).json({ message: "vaultId, targetType, targetId, and label are required" });
      }

      const bookmark = storage.createBookmark({ vaultId, targetType, targetId, label });
      res.status(201).json(bookmark);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.delete("/api/bookmarks/:id", (req, res) => {
    try {
      storage.deleteBookmark(Number(req.params.id));
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── Reminders ─────────────────────────────────────────────────────────
  app.get("/api/reminders/:vaultId", (req, res) => {
    try {
      const reminderList = storage.getRemindersByVaultId(Number(req.params.vaultId));
      res.json(reminderList);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.post("/api/reminders", (req, res) => {
    try {
      const { vaultId, entryId, message, scheduledDate } = req.body;

      if (!vaultId || !message || !scheduledDate) {
        return res.status(400).json({ message: "vaultId, message, and scheduledDate are required" });
      }

      const reminder = storage.createReminder({
        vaultId,
        entryId: entryId || null,
        message,
        scheduledDate,
        isCompleted: 0,
      });
      res.status(201).json(reminder);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.put("/api/reminders/:id", (req, res) => {
    try {
      const reminder = storage.updateReminder(Number(req.params.id), req.body);
      if (!reminder) {
        return res.status(404).json({ message: "Reminder not found" });
      }
      res.json(reminder);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.delete("/api/reminders/:id", (req, res) => {
    try {
      storage.deleteReminder(Number(req.params.id));
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  // ── NokList Items ─────────────────────────────────────────────────────
  app.get("/api/noklist/:entryId", (req, res) => {
    try {
      const items = storage.getNokListItemsByEntryId(Number(req.params.entryId));
      res.json(items);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.post("/api/noklist", (req, res) => {
    try {
      const { entryId, text, isChecked, actionLog, dateCompleted } = req.body;

      if (!entryId || !text) {
        return res.status(400).json({ message: "entryId and text are required" });
      }

      const item = storage.createNokListItem({
        entryId,
        text,
        isChecked: isChecked || 0,
        actionLog: actionLog || null,
        dateCompleted: dateCompleted || null,
      });
      res.status(201).json(item);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.put("/api/noklist/:id", (req, res) => {
    try {
      const item = storage.updateNokListItem(Number(req.params.id), req.body);
      if (!item) {
        return res.status(404).json({ message: "NokList item not found" });
      }
      res.json(item);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  app.put("/api/noklist/:id/toggle", (req, res) => {
    try {
      const item = storage.toggleNokListItemCheck(Number(req.params.id));
      if (!item) {
        return res.status(404).json({ message: "NokList item not found" });
      }
      res.json(item);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  });

  return httpServer;
}
