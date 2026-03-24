import { useState } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { VaultKinLogo } from "@/components/VaultKinLogo";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Lock } from "lucide-react";

interface LockScreenProps {
  vaultId: number;
}

export default function LockScreen({ vaultId }: LockScreenProps) {
  const [passphrase, setPassphrase] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [, navigate] = useLocation();
  const { unlockVault } = useVault();
  const { toast } = useToast();

  async function handleUnlock(e: React.FormEvent) {
    e.preventDefault();
    if (!passphrase || isSubmitting) return;

    setIsSubmitting(true);
    setError("");

    try {
      const res = await apiRequest("POST", "/api/vault/unlock", {
        vaultId,
        passphrase,
      });
      const vault = await res.json();
      unlockVault(vault.id, vault.ownerName, vault.mode);
      navigate("/dashboard");
    } catch (error: any) {
      if (error.message.includes("401")) {
        setError("Invalid passphrase. Please try again.");
      } else {
        setError("Something went wrong. Please try again.");
        toast({
          title: "Error",
          description: error.message,
          variant: "destructive",
        });
      }
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <div className="w-full max-w-sm text-center space-y-8">
        <div>
          <VaultKinLogo size={64} className="mx-auto text-primary mb-4" />
          <h1 className="text-xl font-bold">VaultKin</h1>
          <p className="text-sm text-muted-foreground mt-1">Enter your passphrase to unlock</p>
        </div>

        <form onSubmit={handleUnlock} className="space-y-4">
          <div className="space-y-2 text-left">
            <Label htmlFor="lock-passphrase">Master Passphrase</Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                id="lock-passphrase"
                type="password"
                value={passphrase}
                onChange={(e) => {
                  setPassphrase(e.target.value);
                  setError("");
                }}
                placeholder="Enter your passphrase..."
                className="pl-9"
                autoFocus
                data-testid="lock-passphrase"
              />
            </div>
            {error && <p className="text-xs text-destructive">{error}</p>}
          </div>

          <Button
            type="submit"
            className="w-full"
            disabled={!passphrase || isSubmitting}
            data-testid="lock-unlock-btn"
          >
            {isSubmitting ? "Unlocking..." : "Unlock Vault"}
          </Button>
        </form>
      </div>
    </div>
  );
}
