import { Link } from 'wouter';
import { Zap, Flame, Target, ChevronRight, Play } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import type { DrillRecord } from '@/lib/gameState';
import { PerplexityAttribution } from '@/components/PerplexityAttribution';
import { getStats } from '@/lib/gameState';
import { cardToString } from '@/lib/poker';

interface HomeProps {
  drillHistory: DrillRecord[];
  playerName: string;
}

export default function Home({ drillHistory, playerName }: HomeProps) {
  const stats = getStats(drillHistory);
  const recentDrills = drillHistory.slice(-3).reverse();

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <div className="flex flex-col min-h-full px-4 pt-6 pb-24" data-testid="home-screen">
      {/* Header */}
      <div className="mb-6">
        <p className="text-muted-foreground text-sm mb-1">{getGreeting()}, {playerName}</p>
        <h1 className="text-xl font-bold tracking-tight">Poker Sharp</h1>
        <p className="text-sm text-muted-foreground mt-1">Drills That Make You Dangerous</p>
      </div>

      {/* Start Drill CTA - Gold accent per spec */}
      <Link href="/config">
        <Button
          className="w-full h-14 text-base font-bold gap-2 mb-6 bg-[hsl(var(--accent))] text-[hsl(var(--accent-foreground))] hover:bg-[hsl(var(--accent))]/90 shadow-lg"
          size="lg"
          data-testid="button-start-drill"
        >
          <Play className="w-5 h-5" />
          Start Drill
        </Button>
      </Link>

      {/* Mini Stats Row */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <Card className="bg-card border-card-border">
          <CardContent className="p-3 text-center">
            <Zap className="w-4 h-4 mx-auto mb-1 text-[hsl(var(--accent))]" />
            <p className="text-lg font-bold font-mono" data-testid="text-drills-today">{stats.drillsToday}</p>
            <p className="text-[10px] text-muted-foreground uppercase tracking-wider">Today</p>
          </CardContent>
        </Card>
        <Card className="bg-card border-card-border">
          <CardContent className="p-3 text-center">
            <Flame className="w-4 h-4 mx-auto mb-1 text-orange-500" />
            <p className="text-lg font-bold font-mono" data-testid="text-streak">{stats.streak}</p>
            <p className="text-[10px] text-muted-foreground uppercase tracking-wider">Streak</p>
          </CardContent>
        </Card>
        <Card className="bg-card border-card-border">
          <CardContent className="p-3 text-center">
            <Target className="w-4 h-4 mx-auto mb-1 text-primary" />
            <p className="text-lg font-bold font-mono" data-testid="text-best-accuracy">{stats.bestAccuracy}%</p>
            <p className="text-[10px] text-muted-foreground uppercase tracking-wider">Best (7d)</p>
          </CardContent>
        </Card>
      </div>

      {/* Recent Drills */}
      <div>
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-3">Recent Drills</h2>
        {recentDrills.length === 0 ? (
          <Card className="bg-card border-card-border">
            <CardContent className="p-6 text-center">
              <p className="text-muted-foreground text-sm">No drills yet. Start your first drill!</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-2">
            {recentDrills.map((drill) => (
              <Card key={drill.id} className="bg-card border-card-border">
                <CardContent className="p-3">
                  <div className="flex items-center justify-between">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-xs font-mono text-muted-foreground">
                          {drill.board.map(cardToString).join(' ')}
                        </span>
                        {drill.hintUsed && (
                          <span className="text-[9px] px-1.5 py-0.5 rounded bg-[hsl(var(--accent))]/15 text-[hsl(var(--accent))] font-medium">
                            Assisted
                          </span>
                        )}
                      </div>
                      <div className="flex items-center gap-3 text-xs text-muted-foreground">
                        <span>{drill.targetCount} holdings</span>
                        <span className={`font-semibold ${
                          drill.scoringResult.percentage >= 80 ? 'text-green-500' :
                          drill.scoringResult.percentage >= 50 ? 'text-yellow-500' :
                          'text-red-500'
                        }`}>
                          {drill.scoringResult.percentage}%
                        </span>
                        {drill.timeTakenMs && (
                          <span className="font-mono">
                            {Math.floor(drill.timeTakenMs / 60000)}:{String(Math.floor((drill.timeTakenMs % 60000) / 1000)).padStart(2, '0')}
                          </span>
                        )}
                      </div>
                    </div>
                    <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0" />
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>

      <div className="mt-auto pt-6">
        <PerplexityAttribution />
      </div>
    </div>
  );
}
