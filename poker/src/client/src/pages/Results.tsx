import { useState } from 'react';
import { Link, useLocation } from 'wouter';
import { Home, RotateCcw, Settings, ChevronDown, ChevronUp, Clock, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { PerplexityAttribution } from '@/components/PerplexityAttribution';
import type { Card as PokerCard } from '@/lib/poker';
import { cardToString, SUIT_SYMBOLS, RANK_NAMES, cardKey } from '@/lib/poker';
import type { GroupedScoringResult } from '@/lib/scoring';
import { analyzeBoardTexture, getSpeedRating } from '@/lib/scoring';

interface ResultsProps {
  board: PokerCard[];
  scoringResult: GroupedScoringResult;
  timeTakenMs: number | null;
  targetCount: number;
  hintUsed: boolean;
  onPlayAgain: () => void;
}

function getSuitColorClass(suit: number): string {
  switch (suit) {
    case 0: return 'text-foreground';
    case 1: return 'text-red-500';
    case 2: return 'text-blue-400';
    case 3: return 'text-green-500';
    default: return '';
  }
}

function CardChip({ card }: { card: PokerCard }) {
  return (
    <span className={`text-xs font-mono font-bold ${getSuitColorClass(card.suit)}`}>
      {cardToString(card)}
    </span>
  );
}

function ScoreRing({ percentage }: { percentage: number }) {
  const radius = 50;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (percentage / 100) * circumference;

  const getColor = () => {
    if (percentage >= 80) return 'hsl(var(--primary))';
    if (percentage >= 50) return 'hsl(var(--accent))';
    return 'hsl(var(--destructive))';
  };

  return (
    <div className="relative w-32 h-32 mx-auto">
      <svg className="w-full h-full -rotate-90" viewBox="0 0 120 120">
        <circle
          cx="60" cy="60" r={radius}
          fill="none"
          stroke="hsl(var(--muted))"
          strokeWidth="8"
        />
        <circle
          cx="60" cy="60" r={radius}
          fill="none"
          stroke={getColor()}
          strokeWidth="8"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          className="score-ring-animate"
          style={{
            '--ring-circumference': circumference,
            '--ring-offset': offset,
          } as React.CSSProperties}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-2xl font-bold font-mono" data-testid="text-score">{percentage}%</span>
      </div>
    </div>
  );
}

function SpeedStars({ rating }: { rating: number }) {
  return (
    <span className="text-xs" data-testid="text-speed-rating">
      {Array.from({ length: 5 }, (_, i) => (
        <span key={i} className={i < rating ? 'text-[hsl(var(--accent))]' : 'text-muted-foreground/30'}>★</span>
      ))}
    </span>
  );
}

export default function Results({ board, scoringResult, timeTakenMs, targetCount, hintUsed, onPlayAgain }: ResultsProps) {
  const [expandedRow, setExpandedRow] = useState<number | null>(null);
  const [, navigate] = useLocation();
  const boardTexture = analyzeBoardTexture(board);
  const speedRating = timeTakenMs ? getSpeedRating(timeTakenMs, targetCount) : null;

  const formatTime = (ms: number) => {
    const minutes = Math.floor(ms / 60000);
    const seconds = Math.floor((ms % 60000) / 1000);
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  };

  const getTimeColor = (ms: number) => {
    const secPerHolding = ms / 1000 / targetCount;
    if (secPerHolding <= 3) return 'text-green-500';
    if (secPerHolding <= 6) return 'text-yellow-500';
    return 'text-red-500';
  };

  const getStatusBg = (status: string) => {
    switch (status) {
      case 'exact': return 'bg-green-500/10 border-green-500/30';
      case 'partial': return 'bg-yellow-500/10 border-yellow-500/30';
      case 'wrong': return 'bg-red-500/10 border-red-500/30';
      case 'missing': return 'bg-muted border-muted';
      default: return 'bg-card border-card-border';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'exact': return '✓';
      case 'partial': return '~';
      case 'wrong': return '✕';
      case 'missing': return '—';
      default: return '';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'exact': return 'text-green-500';
      case 'partial': return 'text-yellow-500';
      case 'wrong': return 'text-red-500';
      case 'missing': return 'text-muted-foreground';
      default: return '';
    }
  };

  const exactCount = scoringResult.perPosition.filter(h => h.status === 'exact').length;

  return (
    <div className="flex flex-col min-h-full pb-8" data-testid="results-screen">
      {/* Board replay */}
      <div className="bg-card/50 border-b border-border px-3 py-3">
        <div className="flex justify-center gap-1.5">
          {board.map((card, i) => (
            <div
              key={cardKey(card)}
              className="poker-card bg-card border-card-border w-[48px] h-[67px]"
            >
              <span className={`text-[10px] font-bold font-mono ${getSuitColorClass(card.suit)}`}>
                {RANK_NAMES[card.rank]}
              </span>
              <span className={`text-base ${getSuitColorClass(card.suit)}`}>
                {SUIT_SYMBOLS[card.suit]}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="px-4 pt-4">
        {/* Score Summary */}
        <div className="text-center mb-4">
          <ScoreRing percentage={scoringResult.percentage} />
          <p className="text-sm text-muted-foreground mt-2">
            {exactCount} of {targetCount} exact matches
          </p>
          <p className="text-xs text-muted-foreground">
            {scoringResult.totalPoints}/{scoringResult.maxPoints} points
          </p>
          {timeTakenMs && (
            <div className="flex items-center justify-center gap-2 mt-2">
              <div className={`flex items-center gap-1 text-sm ${getTimeColor(timeTakenMs)}`}>
                <Clock className="w-3.5 h-3.5" />
                <span className="font-mono">{formatTime(timeTakenMs)}</span>
              </div>
              {speedRating && <SpeedStars rating={speedRating} />}
            </div>
          )}
          {hintUsed && (
            <span className="inline-block mt-2 text-[10px] px-2 py-0.5 rounded-full bg-[hsl(var(--accent))]/15 text-[hsl(var(--accent))] font-medium" data-testid="badge-assisted">
              Assisted
            </span>
          )}
          {scoringResult.isSuitSensitive && (
            <span className="inline-block mt-2 ml-1 text-[10px] px-2 py-0.5 rounded-full bg-blue-500/15 text-blue-400 font-medium">
              Suit-Sensitive Board
            </span>
          )}
        </div>

        {/* Comparison Table — one row per equivalence class */}
        <div className="mb-4">
          <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2">
            Your Ranking vs Correct
          </h2>
          <div className="space-y-1.5">
            {scoringResult.perPosition.map((row, i) => {
              const isExpanded = expandedRow === i;
              const cls = row.correctClass;
              return (
                <div key={i}>
                  <button
                    className={`w-full rounded-lg border p-2.5 text-left transition-colors ${getStatusBg(row.status)}`}
                    onClick={() => setExpandedRow(isExpanded ? null : i)}
                    data-testid={`result-row-${i}`}
                  >
                    <div className="flex items-center gap-2">
                      {/* Status icon */}
                      <span className={`text-sm font-bold w-5 text-center ${getStatusColor(row.status)}`}>
                        {getStatusIcon(row.status)}
                      </span>

                      {/* Rank number */}
                      <span className="text-xs font-mono text-muted-foreground w-4">
                        #{i + 1}
                      </span>

                      {/* User's holding (what they submitted) */}
                      <div className="flex-1 min-w-0">
                        {row.userHolding ? (
                          <div className="flex items-center gap-1">
                            <CardChip card={row.userHolding.cards[0]} />
                            <CardChip card={row.userHolding.cards[1]} />
                          </div>
                        ) : (
                          <span className="text-xs text-muted-foreground italic">Missing</span>
                        )}
                      </div>

                      {/* Correct class label */}
                      <span className="text-xs font-mono font-bold text-foreground/80 shrink-0">
                        {cls.label}
                      </span>

                      {/* Member count badge (only for multi-member classes) */}
                      {cls.memberCount > 1 && (
                        <span className="text-[9px] px-1 py-0.5 rounded bg-primary/10 text-primary font-mono shrink-0">
                          ×{cls.memberCount}
                        </span>
                      )}

                      {/* Points */}
                      <span className={`text-[10px] font-mono font-bold w-4 text-right ${getStatusColor(row.status)}`}>
                        {row.points}
                      </span>

                      {/* Expand icon */}
                      {isExpanded ? (
                        <ChevronUp className="w-3.5 h-3.5 text-muted-foreground" />
                      ) : (
                        <ChevronDown className="w-3.5 h-3.5 text-muted-foreground" />
                      )}
                    </div>
                  </button>

                  {/* Expanded detail */}
                  {isExpanded && (
                    <div className="mt-1 mx-2 p-2 bg-card rounded-lg border border-card-border text-xs space-y-1.5">
                      {/* Hand description */}
                      <p className="text-muted-foreground">
                        <span className="font-semibold text-foreground">Hand:</span>{' '}
                        {cls.description}
                      </p>

                      {/* Best 5 cards */}
                      <p className="text-muted-foreground">
                        <span className="font-semibold text-foreground">Best 5:</span>{' '}
                        {cls.fiveCards.map(c => cardToString(c)).join(' ')}
                      </p>

                      {/* All members of this class */}
                      {cls.memberCount > 1 && (
                        <div>
                          <span className="font-semibold text-foreground">All combos ({cls.memberCount}):</span>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {cls.members.map((pair, mi) => (
                              <span
                                key={mi}
                                className="text-[10px] font-mono px-1 py-0.5 rounded bg-secondary text-secondary-foreground"
                              >
                                {cardToString(pair[0])}{cardToString(pair[1])}
                              </span>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* User's submitted hand if it differs */}
                      {row.userHolding && row.status !== 'exact' && (
                        <p className="text-muted-foreground">
                          <span className="font-semibold text-foreground">Your hand:</span>{' '}
                          {row.userHolding.handResult.description}
                        </p>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Missed Classes */}
        {scoringResult.missedClasses.length > 0 && (
          <div className="mb-4">
            <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2 flex items-center gap-1.5">
              <AlertCircle className="w-3.5 h-3.5" />
              Missed Classes
            </h2>
            <Card className="bg-card border-card-border">
              <CardContent className="p-3 space-y-2">
                {scoringResult.missedClasses.slice(0, 5).map((cls, i) => (
                  <div key={i} className="flex items-center gap-2 text-xs">
                    <span className="font-mono text-muted-foreground w-4">#{cls.rank}</span>
                    <span className="font-mono font-bold">{cls.label}</span>
                    {cls.memberCount > 1 && (
                      <span className="text-[9px] px-1 py-0.5 rounded bg-primary/10 text-primary font-mono">
                        ×{cls.memberCount}
                      </span>
                    )}
                    <span className="text-muted-foreground truncate">{cls.description}</span>
                  </div>
                ))}
                {scoringResult.missedClasses.length > 5 && (
                  <p className="text-[10px] text-muted-foreground">
                    +{scoringResult.missedClasses.length - 5} more
                  </p>
                )}
              </CardContent>
            </Card>
          </div>
        )}

        {/* Board Texture Note */}
        <div className="mb-6">
          <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-2">
            Board Texture
          </h2>
          <Card className="bg-card border-card-border">
            <CardContent className="p-3">
              <p className="text-xs text-muted-foreground leading-relaxed" data-testid="text-board-texture">
                {boardTexture.description}
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Action Buttons */}
        <div className="space-y-2 mb-4">
          <Button
            onClick={onPlayAgain}
            className="w-full h-12 font-semibold gap-2 bg-[hsl(var(--accent))] text-[hsl(var(--accent-foreground))] hover:bg-[hsl(var(--accent))]/90"
            data-testid="button-play-again"
          >
            <RotateCcw className="w-4 h-4" />
            Play Again
          </Button>
          <div className="flex gap-2">
            <Link href="/config" className="flex-1">
              <Button
                variant="secondary"
                className="w-full h-10 text-sm font-semibold gap-2"
                data-testid="button-new-settings"
              >
                <Settings className="w-4 h-4" />
                New Settings
              </Button>
            </Link>
            <Link href="/" className="flex-1">
              <Button
                variant="secondary"
                className="w-full h-10 text-sm font-semibold gap-2"
                data-testid="button-home"
              >
                <Home className="w-4 h-4" />
                Home
              </Button>
            </Link>
          </div>
        </div>

        <PerplexityAttribution />
      </div>
    </div>
  );
}
