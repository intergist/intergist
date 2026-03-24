import { useState } from 'react';
import { useLocation } from 'wouter';
import { Layers, Timer, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import type { DrillConfig } from '@/lib/gameState';

interface DrillConfigProps {
  config: DrillConfig;
  onConfigChange: (config: DrillConfig) => void;
  onStartDrill: () => void;
}

const HOLDING_OPTIONS = [5, 10, 15, 20];

export default function DrillConfigPage({ config, onConfigChange, onStartDrill }: DrillConfigProps) {
  const [, navigate] = useLocation();
  const [localConfig, setLocalConfig] = useState<DrillConfig>(config);

  const handleStart = () => {
    onConfigChange(localConfig);
    onStartDrill();
    navigate('/drill');
  };

  return (
    <div className="flex flex-col min-h-full px-4 pt-6 pb-24" data-testid="config-screen">
      <div className="mb-6">
        <h1 className="text-xl font-bold tracking-tight">Configure Drill</h1>
        <p className="text-sm text-muted-foreground mt-1">Set up your board-reading challenge</p>
      </div>

      {/* Holdings Count */}
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4">
          <div className="flex items-center gap-2 mb-3">
            <Layers className="w-4 h-4 text-primary" />
            <span className="text-sm font-semibold">Holdings to Rank</span>
          </div>
          <div className="grid grid-cols-4 gap-2">
            {HOLDING_OPTIONS.map(n => (
              <button
                key={n}
                onClick={() => setLocalConfig(c => ({ ...c, holdingsCount: n }))}
                className={`py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  localConfig.holdingsCount === n
                    ? 'bg-primary text-primary-foreground shadow-md'
                    : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                }`}
                data-testid={`button-holdings-${n}`}
              >
                {n}
              </button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Timer */}
      <Card className="bg-card border-card-border mb-4">
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Timer className="w-4 h-4 text-primary" />
              <div>
                <span className="text-sm font-semibold">Timer</span>
                {localConfig.timerEnabled && (
                  <p className="text-xs text-muted-foreground mt-0.5">
                    Pro target: ~30s for 20 holdings
                  </p>
                )}
              </div>
            </div>
            <Switch
              checked={localConfig.timerEnabled}
              onCheckedChange={(checked) => setLocalConfig(c => ({ ...c, timerEnabled: checked }))}
              data-testid="switch-timer"
            />
          </div>
        </CardContent>
      </Card>

      {/* Board Type */}
      <Card className="bg-card border-card-border mb-8">
        <CardContent className="p-4">
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-[hsl(var(--accent))]" />
            <div>
              <span className="text-sm font-semibold">Board Type</span>
              <p className="text-xs text-muted-foreground mt-0.5">Random board (more options coming soon)</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Deal Button */}
      <Button
        onClick={handleStart}
        className="w-full h-14 text-base font-bold gap-2 bg-[hsl(var(--accent))] text-[hsl(var(--accent-foreground))] hover:bg-[hsl(var(--accent))]/90 shadow-lg"
        size="lg"
        data-testid="button-deal"
      >
        <Sparkles className="w-5 h-5" />
        Deal
      </Button>
    </div>
  );
}
