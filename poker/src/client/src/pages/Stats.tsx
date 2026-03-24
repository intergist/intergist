import { BarChart3, Flame, Target, Trophy, Calendar, Award, Droplets } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import type { DrillRecord } from '@/lib/gameState';
import { getStats, getSuitSensitivity } from '@/lib/gameState';
import { cardToString } from '@/lib/poker';
import { PerplexityAttribution } from '@/components/PerplexityAttribution';

interface StatsProps {
  drillHistory: DrillRecord[];
}

export default function Stats({ drillHistory }: StatsProps) {
  const stats = getStats(drillHistory);
  const suitSensitivity = getSuitSensitivity(drillHistory);

  return (
    <div className="flex flex-col min-h-full px-4 pt-6 pb-24" data-testid="stats-screen">
      <div className="mb-6">
        <h1 className="text-xl font-bold tracking-tight">Statistics</h1>
        <p className="text-sm text-muted-foreground mt-1">Track your progress</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        <Card className="bg-card border-card-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <BarChart3 className="w-4 h-4 text-primary" />
              <span className="text-xs text-muted-foreground uppercase tracking-wider">Total Drills</span>
            </div>
            <p className="text-2xl font-bold font-mono" data-testid="text-total-drills">{stats.totalDrills}</p>
          </CardContent>
        </Card>
        <Card className="bg-card border-card-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Flame className="w-4 h-4 text-orange-500" />
              <span className="text-xs text-muted-foreground uppercase tracking-wider">Streak</span>
            </div>
            <p className="text-2xl font-bold font-mono" data-testid="text-stats-streak">
              {stats.streak} day{stats.streak !== 1 ? 's' : ''}
            </p>
          </CardContent>
        </Card>
        <Card className="bg-card border-card-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Target className="w-4 h-4 text-primary" />
              <span className="text-xs text-muted-foreground uppercase tracking-wider">Best (7d)</span>
            </div>
            <p className="text-2xl font-bold font-mono" data-testid="text-stats-best">{stats.bestAccuracy}%</p>
          </CardContent>
        </Card>
        <Card className="bg-card border-card-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Award className="w-4 h-4 text-[hsl(var(--accent))]" />
              <span className="text-xs text-muted-foreground uppercase tracking-wider">Longest</span>
            </div>
            <p className="text-2xl font-bold font-mono" data-testid="text-longest-streak">
              {stats.longestStreak} day{stats.longestStreak !== 1 ? 's' : ''}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Suit Sensitivity Card */}
      <div className="mb-6">
        <h2 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-3 flex items-center gap-2">
          <Droplets className="w-4 h-4 text-blue-400" />
          Suit Sensitivity
        </h2>
        <Card className="bg-card border-card-border" data-testid="suit-sensitivity-card">
          <CardContent className="p-4">
            {drillHistory.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center">
                Complete drills to see suit sensitivity stats
              </p>
            ) : (
              <div className="space-y-3">
                <p className="text-xs text-muted-foreground">
                  Accuracy on suit-sensitive boards (3+ of a suit) vs standard boards
                </p>
                <div className="grid grid-cols-2 gap-3">
                  {/* Suit-Sensitive */}
                  <div className="text-center">
                    <div className="text-xs text-blue-400 font-semibold mb-1 uppercase tracking-wide">
                      Suit-Sensitive
                    </div>
                    {suitSensitivity.sensitiveCount > 0 ? (
                      <>
                        <p
                          className={`text-2xl font-bold font-mono ${
                            (suitSensitivity.sensitiveAvg ?? 0) >= 80 ? 'text-green-500' :
                            (suitSensitivity.sensitiveAvg ?? 0) >= 50 ? 'text-yellow-500' :
                            'text-red-500'
                          }`}
                          data-testid="text-sensitive-avg"
                        >
                          {suitSensitivity.sensitiveAvg}%
                        </p>
                        <p className="text-[10px] text-muted-foreground mt-0.5">
                          {suitSensitivity.sensitiveCount} drill{suitSensitivity.sensitiveCount !== 1 ? 's' : ''}
                        </p>
                      </>
                    ) : (
                      <p className="text-sm text-muted-foreground">—</p>
                    )}
                  </div>

                  {/* Non-Sensitive */}
                  <div className="text-center">
                    <div className="text-xs text-muted-foreground font-semibold mb-1 uppercase tracking-wide">
                      Standard
                    </div>
                    {suitSensitivity.nonSensitiveCount > 0 ? (
                      <>
                        <p
                          className={`text-2xl font-bold font-mono ${
                            (suitSensitivity.nonSensitiveAvg ?? 0) >= 80 ? 'text-green-500' :
                            (suitSensitivity.nonSensitiveAvg ?? 0) >= 50 ? 'text-yellow-500' :
                            'text-red-500'
                          }`}
                          data-testid="text-non-sensitive-avg"
                        >
                          {suitSensitivity.nonSensitiveAvg}%
                        </p>
                        <p className="text-[10px] text-muted-foreground mt-0.5">
                          {suitSensitivity.nonSensitiveCount} drill{suitSensitivity.nonSensitiveCount !== 1 ? 's' : ''}
                        </p>
                      </>
                    ) : (
                      <p className="text-sm text-muted-foreground">—</p>
                    )}
                  </div>
                </div>

                {/* Comparison insight */}
                {suitSensitivity.sensitiveAvg !== null && suitSensitivity.nonSensitiveAvg !== null && (
                  <div className="pt-2 border-t border-border">
                    {suitSensitivity.sensitiveAvg < suitSensitivity.nonSensitiveAvg ? (
                      <p className="text-xs text-muted-foreground">
                        You score{' '}
                        <span className="text-red-400 font-semibold">
                          {suitSensitivity.nonSensitiveAvg - suitSensitivity.sensitiveAvg}% lower
                        </span>{' '}
                        on suit-sensitive boards — practice reading flushes.
                      </p>
                    ) : suitSensitivity.sensitiveAvg > suitSensitivity.nonSensitiveAvg ? (
                      <p className="text-xs text-muted-foreground">
                        You score{' '}
                        <span className="text-green-400 font-semibold">
                          {suitSensitivity.sensitiveAvg - suitSensitivity.nonSensitiveAvg}% higher
                        </span>{' '}
                        on suit-sensitive boards — great suit awareness!
                      </p>
                    ) : (
                      <p className="text-xs text-muted-foreground">
                        Equal accuracy on both board types — consistent performance!
                      </p>
                    )}
                  </div>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Drill History */}
      <div>
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-3 flex items-center gap-2">
          <Calendar className="w-4 h-4" />
          Drill History
        </h2>
        {drillHistory.length === 0 ? (
          <Card className="bg-card border-card-border">
            <CardContent className="p-6 text-center">
              <p className="text-muted-foreground text-sm">Complete a drill to see your history</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-2">
            {[...drillHistory].reverse().map((drill) => (
              <Card key={drill.id} className="bg-card border-card-border">
                <CardContent className="p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-mono text-muted-foreground">
                      {drill.board.map(cardToString).join(' ')}
                    </span>
                    <div className="flex items-center gap-1.5">
                      {drill.suitSensitive && (
                        <span className="text-[9px] px-1 py-0.5 rounded bg-blue-500/15 text-blue-400 font-medium">
                          Suit
                        </span>
                      )}
                      <span className={`text-sm font-bold font-mono ${
                        drill.scoringResult.percentage >= 80 ? 'text-green-500' :
                        drill.scoringResult.percentage >= 50 ? 'text-yellow-500' :
                        'text-red-500'
                      }`}>
                        {drill.scoringResult.percentage}%
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-muted-foreground">
                    <span>{drill.targetCount} holdings</span>
                    <span>{drill.scoringResult.totalPoints}/{drill.scoringResult.maxPoints} pts</span>
                    {drill.timeTakenMs && (
                      <span className="font-mono">
                        {Math.floor(drill.timeTakenMs / 60000)}:{String(Math.floor((drill.timeTakenMs % 60000) / 1000)).padStart(2, '0')}
                      </span>
                    )}
                    {drill.hintUsed && (
                      <span className="text-[9px] px-1 py-0.5 rounded bg-[hsl(var(--accent))]/15 text-[hsl(var(--accent))] font-medium">
                        Assisted
                      </span>
                    )}
                    <span className="ml-auto">
                      {new Date(drill.date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                    </span>
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
