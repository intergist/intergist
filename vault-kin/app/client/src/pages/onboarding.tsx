import { useState } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { VaultKinLogo } from "@/components/VaultKinLogo";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Shield, Lock, User, ArrowRight, ArrowLeft, Check } from "lucide-react";

export default function Onboarding() {
  const [step, setStep] = useState(1);
  const [passphrase, setPassphrase] = useState("");
  const [confirmPassphrase, setConfirmPassphrase] = useState("");
  const [name, setName] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [mode, setMode] = useState<"owner" | "executor">("owner");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [, navigate] = useLocation();
  const { unlockVault } = useVault();
  const { toast } = useToast();

  const totalSteps = 5;
  const progressValue = (step / totalSteps) * 100;

  const passphraseStrength = getPassphraseStrength(passphrase);
  const canProceedStep3 = passphrase.length >= 12 && passphrase === confirmPassphrase;

  async function handleComplete() {
    if (isSubmitting) return;
    setIsSubmitting(true);

    try {
      const res = await apiRequest("POST", "/api/vault", {
        name: `${name}'s Vault`,
        ownerName: name,
        dateOfBirth: dateOfBirth || null,
        mode,
        passphrase,
      });
      const vault = await res.json();
      unlockVault(vault.id, vault.ownerName, vault.mode || mode);
      navigate("/dashboard");
    } catch (error: any) {
      toast({
        title: "Error creating vault",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <div className="w-full max-w-md">
        <Progress value={progressValue} className="mb-6 h-1" />

        {step === 1 && (
          <div className="text-center space-y-6" data-testid="onboarding-step-1">
            <VaultKinLogo size={80} className="mx-auto text-primary" />
            <div>
              <h1 className="text-xl font-bold">Welcome to VaultKin</h1>
              <p className="text-muted-foreground mt-2">
                Organize your life. Protect your family.
              </p>
            </div>
            <p className="text-sm text-muted-foreground">
              VaultKin helps you document everything your loved ones would need to know — finances, legal documents,
              medical information, and personal wishes — all in one secure place.
            </p>
            <Button onClick={() => setStep(2)} className="w-full" data-testid="onboarding-next">
              Get Started <ArrowRight className="ml-2 h-4 w-4" />
            </Button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6" data-testid="onboarding-step-2">
            <div className="text-center">
              <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <Shield className="h-8 w-8 text-primary" />
              </div>
              <h2 className="text-xl font-bold">Your Privacy Matters</h2>
              <p className="text-muted-foreground mt-2 text-sm">
                Your data stays on this server and is protected by your master passphrase.
                We never share, sell, or access your personal information.
              </p>
            </div>
            <Card>
              <CardContent className="p-4 space-y-3 text-sm">
                <div className="flex items-start gap-2">
                  <Check className="h-4 w-4 text-green-600 mt-0.5 shrink-0" />
                  <span>All data is encrypted with your passphrase</span>
                </div>
                <div className="flex items-start gap-2">
                  <Check className="h-4 w-4 text-green-600 mt-0.5 shrink-0" />
                  <span>No tracking, no analytics, no ads</span>
                </div>
                <div className="flex items-start gap-2">
                  <Check className="h-4 w-4 text-green-600 mt-0.5 shrink-0" />
                  <span>You control who has access</span>
                </div>
              </CardContent>
            </Card>
            <div className="flex gap-3">
              <Button variant="outline" onClick={() => setStep(1)} data-testid="onboarding-back">
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <Button onClick={() => setStep(3)} className="flex-1" data-testid="onboarding-next">
                Continue <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6" data-testid="onboarding-step-3">
            <div className="text-center">
              <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <Lock className="h-8 w-8 text-primary" />
              </div>
              <h2 className="text-xl font-bold">Set Master Passphrase</h2>
              <p className="text-muted-foreground mt-2 text-sm">
                Choose a strong passphrase to protect your vault. Minimum 12 characters.
              </p>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="passphrase">Master Passphrase</Label>
                <Input
                  id="passphrase"
                  type="password"
                  value={passphrase}
                  onChange={(e) => setPassphrase(e.target.value)}
                  placeholder="Enter a strong passphrase..."
                  data-testid="onboarding-passphrase"
                />
                {passphrase && (
                  <div className="space-y-1">
                    <div className="flex gap-1">
                      {[1, 2, 3, 4].map((level) => (
                        <div
                          key={level}
                          className={`h-1 flex-1 rounded-full transition-colors ${
                            level <= passphraseStrength.level
                              ? passphraseStrength.color
                              : "bg-muted"
                          }`}
                        />
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">{passphraseStrength.label}</p>
                  </div>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="confirm-passphrase">Confirm Passphrase</Label>
                <Input
                  id="confirm-passphrase"
                  type="password"
                  value={confirmPassphrase}
                  onChange={(e) => setConfirmPassphrase(e.target.value)}
                  placeholder="Confirm your passphrase..."
                  data-testid="onboarding-confirm-passphrase"
                />
                {confirmPassphrase && confirmPassphrase !== passphrase && (
                  <p className="text-xs text-destructive">Passphrases do not match</p>
                )}
              </div>
            </div>
            <div className="flex gap-3">
              <Button variant="outline" onClick={() => setStep(2)} data-testid="onboarding-back">
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <Button
                onClick={() => setStep(4)}
                className="flex-1"
                disabled={!canProceedStep3}
                data-testid="onboarding-next"
              >
                Continue <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-6" data-testid="onboarding-step-4">
            <div className="text-center">
              <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <User className="h-8 w-8 text-primary" />
              </div>
              <h2 className="text-xl font-bold">Quick Profile</h2>
              <p className="text-muted-foreground mt-2 text-sm">
                Tell us a bit about yourself. You can always update this later.
              </p>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name">Full Name</Label>
                <Input
                  id="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Your full name"
                  data-testid="onboarding-name"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="dob">Date of Birth (optional)</Label>
                <Input
                  id="dob"
                  type="date"
                  value={dateOfBirth}
                  onChange={(e) => setDateOfBirth(e.target.value)}
                  data-testid="onboarding-dob"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <Button variant="outline" onClick={() => setStep(3)} data-testid="onboarding-back">
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <Button
                onClick={() => setStep(5)}
                className="flex-1"
                disabled={!name.trim()}
                data-testid="onboarding-next"
              >
                Continue <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
          </div>
        )}

        {step === 5 && (
          <div className="space-y-6" data-testid="onboarding-step-5">
            <div className="text-center">
              <h2 className="text-xl font-bold">Choose Your Path</h2>
              <p className="text-muted-foreground mt-2 text-sm">
                How will you be using VaultKin?
              </p>
            </div>
            <div className="space-y-3">
              <Card
                className={`cursor-pointer transition-colors ${
                  mode === "owner" ? "border-primary ring-2 ring-primary/20" : "hover:border-primary/30"
                }`}
                onClick={() => setMode("owner")}
                data-testid="onboarding-mode-owner"
              >
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className={`w-5 h-5 rounded-full border-2 mt-0.5 flex items-center justify-center shrink-0 ${
                      mode === "owner" ? "border-primary bg-primary" : "border-muted-foreground"
                    }`}>
                      {mode === "owner" && <Check className="h-3 w-3 text-primary-foreground" />}
                    </div>
                    <div>
                      <h3 className="font-semibold text-sm">I'm organizing my own life</h3>
                      <p className="text-xs text-muted-foreground mt-1">
                        Owner mode — document your personal, financial, and legal information for your loved ones.
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
              <Card
                className={`cursor-pointer transition-colors ${
                  mode === "executor" ? "border-primary ring-2 ring-primary/20" : "hover:border-primary/30"
                }`}
                onClick={() => setMode("executor")}
                data-testid="onboarding-mode-executor"
              >
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className={`w-5 h-5 rounded-full border-2 mt-0.5 flex items-center justify-center shrink-0 ${
                      mode === "executor" ? "border-primary bg-primary" : "border-muted-foreground"
                    }`}>
                      {mode === "executor" && <Check className="h-3 w-3 text-primary-foreground" />}
                    </div>
                    <div>
                      <h3 className="font-semibold text-sm">I'm managing someone else's estate</h3>
                      <p className="text-xs text-muted-foreground mt-1">
                        Executor mode — manage and track progress through another person's documented life information.
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
            <div className="flex gap-3">
              <Button variant="outline" onClick={() => setStep(4)} data-testid="onboarding-back">
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <Button
                onClick={handleComplete}
                className="flex-1"
                disabled={isSubmitting}
                data-testid="onboarding-complete"
              >
                {isSubmitting ? "Creating Vault..." : "Create My Vault"}
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function getPassphraseStrength(passphrase: string): { level: number; label: string; color: string } {
  if (passphrase.length === 0) return { level: 0, label: "", color: "" };
  if (passphrase.length < 8) return { level: 1, label: "Weak — too short", color: "bg-destructive" };
  if (passphrase.length < 12) return { level: 2, label: "Fair — needs to be longer", color: "bg-orange-500" };

  let score = 2;
  if (/[A-Z]/.test(passphrase) && /[a-z]/.test(passphrase)) score++;
  if (/[0-9]/.test(passphrase)) score++;
  if (/[^A-Za-z0-9]/.test(passphrase)) score++;
  if (passphrase.length >= 16) score++;

  if (score >= 5) return { level: 4, label: "Strong", color: "bg-green-600" };
  if (score >= 4) return { level: 3, label: "Good", color: "bg-blue-500" };
  return { level: 2, label: "Fair", color: "bg-orange-500" };
}
