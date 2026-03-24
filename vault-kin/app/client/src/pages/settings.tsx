import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { AppShell } from "@/components/AppShell";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { ThemeToggle } from "@/components/ThemeToggle";
import { VaultKinLogo } from "@/components/VaultKinLogo";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Switch } from "@/components/ui/switch";
import { useToast } from "@/hooks/use-toast";
import { Lock, Download, User, Shield } from "lucide-react";

interface Vault {
  id: number;
  name: string;
  ownerName: string;
  dateOfBirth: string | null;
  mode: string;
  createdAt: string;
  updatedAt: string;
}

export default function SettingsPage() {
  const { state, dispatch, lockVault } = useVault();
  const vaultId = state.currentVaultId!;
  const [, navigate] = useLocation();
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const [editName, setEditName] = useState("");
  const [editDob, setEditDob] = useState("");
  const [nameInitialized, setNameInitialized] = useState(false);

  const { data: vault } = useQuery<Vault>({
    queryKey: ["/api/vault", String(vaultId)],
  });

  // Initialize edit fields from vault data
  if (vault && !nameInitialized) {
    setEditName(vault.ownerName);
    setEditDob(vault.dateOfBirth || "");
    setNameInitialized(true);
  }

  const updateProfileMutation = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("PUT", `/api/vault/${vaultId}`, {
        ownerName: editName,
        dateOfBirth: editDob || null,
      });
      return res.json();
    },
    onSuccess: (updated: Vault) => {
      dispatch({ type: "SET_OWNER_NAME", payload: updated.ownerName });
      queryClient.invalidateQueries({ queryKey: ["/api/vault", String(vaultId)] });
      toast({ title: "Profile updated" });
    },
    onError: (error: any) => {
      toast({ title: "Error", description: error.message, variant: "destructive" });
    },
  });

  function handleExport() {
    // Fetch all data and download as JSON
    Promise.all([
      apiRequest("GET", `/api/vault/${vaultId}`).then(r => r.json()),
      apiRequest("GET", `/api/sections/${vaultId}`).then(r => r.json()),
      apiRequest("GET", `/api/entries/vault/${vaultId}`).then(r => r.json()),
      apiRequest("GET", `/api/bookmarks/${vaultId}`).then(r => r.json()),
      apiRequest("GET", `/api/reminders/${vaultId}`).then(r => r.json()),
    ]).then(([vault, sections, entries, bookmarks, reminders]) => {
      const exportData = { vault, sections, entries, bookmarks, reminders, exportDate: new Date().toISOString() };
      const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: "application/json" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `vaultkin-export-${new Date().toISOString().split("T")[0]}.json`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      toast({ title: "Export complete", description: "Your vault data has been downloaded." });
    }).catch((error) => {
      toast({ title: "Export failed", description: error.message, variant: "destructive" });
    });
  }

  function handleLock() {
    lockVault();
    navigate("/");
  }

  function handleModeToggle() {
    const newMode = state.vaultMode === "owner" ? "executor" : "owner";
    dispatch({ type: "SET_MODE", payload: newMode });
    apiRequest("PUT", `/api/vault/${vaultId}`, { mode: newMode }).catch(() => {
      // Revert on failure
      dispatch({ type: "SET_MODE", payload: state.vaultMode });
    });
  }

  return (
    <AppShell title="Settings">
      <div className="p-4 md:p-6 max-w-2xl mx-auto space-y-6">
        {/* Profile */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base flex items-center gap-2">
              <User className="h-4 w-4" /> Profile
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="settings-name">Full Name</Label>
              <Input
                id="settings-name"
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                data-testid="settings-name"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="settings-dob">Date of Birth</Label>
              <Input
                id="settings-dob"
                type="date"
                value={editDob}
                onChange={(e) => setEditDob(e.target.value)}
                data-testid="settings-dob"
              />
            </div>
            <Button
              onClick={() => updateProfileMutation.mutate()}
              disabled={updateProfileMutation.isPending}
              size="sm"
              data-testid="save-profile-btn"
            >
              Save Changes
            </Button>
          </CardContent>
        </Card>

        {/* App Mode */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base flex items-center gap-2">
              <Shield className="h-4 w-4" /> App Mode
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">Executor Mode</p>
                <p className="text-xs text-muted-foreground">
                  {state.vaultMode === "executor"
                    ? "You are managing someone else's estate"
                    : "Switch to manage someone else's estate"}
                </p>
              </div>
              <Switch
                checked={state.vaultMode === "executor"}
                onCheckedChange={handleModeToggle}
                data-testid="mode-toggle"
              />
            </div>
          </CardContent>
        </Card>

        {/* Appearance */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Appearance</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">Dark Mode</p>
                <p className="text-xs text-muted-foreground">Toggle between light and dark themes</p>
              </div>
              <ThemeToggle />
            </div>
          </CardContent>
        </Card>

        {/* Data */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base flex items-center gap-2">
              <Download className="h-4 w-4" /> Data
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="outline" onClick={handleExport} className="w-full" data-testid="export-btn">
              <Download className="h-4 w-4 mr-2" /> Export Vault as JSON
            </Button>
          </CardContent>
        </Card>

        {/* Security */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base flex items-center gap-2">
              <Lock className="h-4 w-4" /> Security
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button variant="destructive" onClick={handleLock} className="w-full" data-testid="lock-vault-btn">
              <Lock className="h-4 w-4 mr-2" /> Lock Vault
            </Button>
          </CardContent>
        </Card>

        {/* About */}
        <Card>
          <CardContent className="p-4 flex items-center gap-3">
            <VaultKinLogo size={32} className="text-primary" />
            <div>
              <p className="text-sm font-semibold">VaultKin</p>
              <p className="text-xs text-muted-foreground">Version 1.0.0 — Estate Planning PWA</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppShell>
  );
}
