import { useState } from 'react';
import { Moon, Sun, Info, User, Layers, Timer, Trash2 } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import { Input } from '@/components/ui/input';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { useTheme } from '@/lib/ThemeProvider';
import { PerplexityAttribution } from '@/components/PerplexityAttribution';
import type { AppSettings } from '@/lib/gameState';

interface SettingsProps {
  settings: AppSettings;
  onSettingsChange: (s: AppSettings) => void;
  onResetStats: () => void;
  drillCount: number;
}

const HOLDING_OPTIONS = [5, 10, 15, 20];

export default function Settings({ settings, onSettingsChange, onResetStats, drillCount }: SettingsProps) {
  const { dark, toggle } = useTheme();
  const [showResetDialog, setShowResetDialog] = useState(false);

  const updateSetting = <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => {
    onSettingsChange({ ...settings, [key]: value });
  };

  const handleResetConfirm = () => {
    onResetStats();
    setShowResetDialog(false);
  };

  return (
    <div className="flex flex-col min-h-full px-4 pt-6 pb-24" data-testid="settings-screen">
      <div className="mb-6">
        <h1 className="text-xl font-bold tracking-tight">Settings</h1>
        <p className="text-sm text-muted-foreground mt-1">Customize your experience</p>
      </div>

      {/* Player Name */}
      <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Profile</h2>
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <User className="w-4 h-4 text-primary flex-shrink-0" />
            <div className="flex-1">
              <label className="text-sm font-semibold block mb-1.5">Player Name</label>
              <Input
                value={settings.playerName}
                onChange={e => updateSetting('playerName', e.target.value || 'Player')}
                placeholder="Player"
                className="h-9 text-sm"
                data-testid="input-player-name"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Appearance */}
      <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Appearance</h2>
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {dark ? <Moon className="w-4 h-4 text-primary" /> : <Sun className="w-4 h-4 text-[hsl(var(--accent))]" />}
              <div>
                <span className="text-sm font-semibold">{dark ? 'Dark Mode' : 'Light Mode'}</span>
                <p className="text-xs text-muted-foreground">
                  {dark ? 'Casino felt table aesthetic' : 'Light theme for daytime use'}
                </p>
              </div>
            </div>
            <Switch
              checked={dark}
              onCheckedChange={toggle}
              data-testid="switch-dark-mode"
            />
          </div>
        </CardContent>
      </Card>

      {/* Defaults */}
      <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Drill Defaults</h2>
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4 space-y-4">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Layers className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold">Default Holdings Count</span>
            </div>
            <div className="grid grid-cols-4 gap-2">
              {HOLDING_OPTIONS.map(n => (
                <button
                  key={n}
                  onClick={() => updateSetting('defaultHoldingsCount', n)}
                  className={`py-2 rounded-lg text-sm font-semibold transition-all ${
                    settings.defaultHoldingsCount === n
                      ? 'bg-primary text-primary-foreground shadow-md'
                      : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                  }`}
                  data-testid={`button-default-holdings-${n}`}
                >
                  {n}
                </button>
              ))}
            </div>
          </div>

          <div className="flex items-center justify-between pt-2 border-t border-border">
            <div className="flex items-center gap-2">
              <Timer className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold">Timer On by Default</span>
            </div>
            <Switch
              checked={settings.defaultTimerEnabled}
              onCheckedChange={v => updateSetting('defaultTimerEnabled', v)}
              data-testid="switch-default-timer"
            />
          </div>
        </CardContent>
      </Card>

      {/* Data */}
      <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Data</h2>
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4">
          <button
            onClick={() => drillCount > 0 && setShowResetDialog(true)}
            disabled={drillCount === 0}
            className="flex items-center gap-3 w-full text-left disabled:opacity-40"
            data-testid="button-reset-stats"
          >
            <Trash2 className="w-4 h-4 text-destructive" />
            <div>
              <span className="text-sm font-semibold text-destructive">Reset All Stats</span>
              <p className="text-xs text-muted-foreground">
                {drillCount > 0 ? `${drillCount} drill${drillCount !== 1 ? 's' : ''} will be cleared` : 'No data to clear'}
              </p>
            </div>
          </button>
        </CardContent>
      </Card>

      {/* About */}
      <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">About</h2>
      <Card className="bg-card border-card-border mb-6">
        <CardContent className="p-4">
          <div className="flex items-start gap-3">
            <Info className="w-4 h-4 text-muted-foreground mt-0.5" />
            <div>
              <p className="text-sm font-semibold">Poker Sharp v1.0</p>
              <p className="text-xs text-muted-foreground mt-1">
                Board-reading drill app based on Angel Largay's
                <em> No-Limit Texas Hold'em: A Complete Course</em>.
              </p>
              <p className="text-xs text-muted-foreground mt-2">
                All hand evaluation runs locally. No data leaves your device.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="mt-auto">
        <PerplexityAttribution />
      </div>

      {/* Reset confirmation dialog */}
      <AlertDialog open={showResetDialog} onOpenChange={setShowResetDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Reset all statistics?</AlertDialogTitle>
            <AlertDialogDescription>
              This will permanently delete all {drillCount} drill records. This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleResetConfirm} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Reset
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
