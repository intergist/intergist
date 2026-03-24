import { useState, useEffect, useCallback, useRef, useMemo } from 'react';
import { useLocation } from 'wouter';
import { Undo2, Trash2, Send, ChevronUp, ChevronDown, X, Lightbulb, ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
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
import { useToast } from '@/hooks/use-toast';
import type { Card } from '@/lib/poker';
import { RANK_NAMES, SUIT_SYMBOLS, cardToString, cardKey, getHandName, evaluateBestHand } from '@/lib/poker';
import { rankAllHoldings, groupIntoEquivalenceClasses, findEquivalenceClassForHolding } from '@/lib/poker';
import type { EquivalenceClass } from '@/lib/poker';
import type { DrillConfig } from '@/lib/gameState';

interface DrillScreenProps {
  board: Card[];
  config: DrillConfig;
  onSubmit: (holdings: { cards: [Card, Card] }[], timeTakenMs: number | null, hintUsed: boolean) => void;
}

interface Holding {
  cards: [Card, Card];
  handName: string;
}

type UndoAction =
  | { type: 'add'; index: number }
  | { type: 'remove'; holding: Holding; index: number }
  | { type: 'reorder'; fromIndex: number; toIndex: number }
  | { type: 'clear'; holdings: Holding[] };

const RANK_ROW_1 = [12, 11, 10, 9, 8, 7, 6]; // A K Q J T 9 8
const RANK_ROW_2 = [5, 4, 3, 2, 1, 0]; // 7 6 5 4 3 2
const SUITS = [0, 1, 2, 3]; // ♠ ♥ ♦ ♣

function getSuitColorClass(suit: number): string {
  switch (suit) {
    case 0: return 'text-foreground'; // spade — black in light, white in dark
    case 1: return 'text-red-500';
    case 2: return 'text-blue-400';
    case 3: return 'text-green-500';
    default: return '';
  }
}

function getSuitBgClass(suit: number): string {
  switch (suit) {
    case 0: return 'bg-foreground/10';
    case 1: return 'bg-red-500/15';
    case 2: return 'bg-blue-400/15';
    case 3: return 'bg-green-500/15';
    default: return '';
  }
}

function BoardCard({ card, index }: { card: Card; index: number }) {
  return (
    <div
      className="poker-card bg-card border-card-border w-[54px] h-[76px] card-flip-in"
      style={{ animationDelay: `${index * 0.1}s` }}
      data-testid={`board-card-${index}`}
    >
      <span className={`text-xs font-bold font-mono ${getSuitColorClass(card.suit)}`}>
        {RANK_NAMES[card.rank]}
      </span>
      <span className={`text-lg ${getSuitColorClass(card.suit)}`}>
        {SUIT_SYMBOLS[card.suit]}
      </span>
      <span className={`text-xs font-bold font-mono ${getSuitColorClass(card.suit)}`}>
        {RANK_NAMES[card.rank]}
      </span>
    </div>
  );
}

export default function DrillScreen({ board, config, onSubmit }: DrillScreenProps) {
  const [, navigate] = useLocation();
  const { toast } = useToast();
  const [holdings, setHoldings] = useState<Holding[]>([]);
  const [selectedRank, setSelectedRank] = useState<number | null>(null);
  const [firstCard, setFirstCard] = useState<Card | null>(null);
  const [undoStack, setUndoStack] = useState<UndoAction[]>([]);
  const [startTime] = useState(Date.now());
  const [elapsed, setElapsed] = useState(0);
  const [hintUsed, setHintUsed] = useState(false);
  const [hintText, setHintText] = useState<string | null>(null);
  const [showSubmitDialog, setShowSubmitDialog] = useState(false);
  const [showClearDialog, setShowClearDialog] = useState(false);
  const [showLeaveDialog, setShowLeaveDialog] = useState(false);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Pre-compute equivalence classes when board changes
  const equivalenceClasses = useMemo<EquivalenceClass[]>(() => {
    if (board.length !== 5) return [];
    return groupIntoEquivalenceClasses(board, config.holdingsCount);
  }, [board, config.holdingsCount]);

  // Timer
  useEffect(() => {
    if (config.timerEnabled) {
      timerRef.current = setInterval(() => {
        setElapsed(Date.now() - startTime);
      }, 1000);
      return () => {
        if (timerRef.current) clearInterval(timerRef.current);
      };
    }
  }, [config.timerEnabled, startTime]);

  // Set of used card keys (board + holdings + first card in progress)
  const usedCards = new Set<number>([
    ...board.map(cardKey),
    ...holdings.flatMap(h => h.cards.map(cardKey)),
    ...(firstCard ? [cardKey(firstCard)] : []),
  ]);

  // Check if all 4 suits for a rank are used
  const isRankExhausted = (rank: number): boolean => {
    return SUITS.every(suit => usedCards.has(suit * 13 + rank));
  };

  // Get available suits for a rank
  const getAvailableSuits = (rank: number): number[] => {
    return SUITS.filter(suit => !usedCards.has(suit * 13 + rank));
  };

  // Handle rank tap
  const handleRankTap = useCallback((rank: number) => {
    if (isRankExhausted(rank)) return;

    const available = getAvailableSuits(rank);
    if (available.length === 0) return;

    // Auto-select if only one suit available
    if (available.length === 1) {
      handleSuitTap(available[0], rank);
      return;
    }

    setSelectedRank(rank);
  }, [usedCards, firstCard, holdings, board]);

  // Get the label to display for a holding in the list
  const getHoldingDisplayLabel = useCallback((holding: Holding): string | null => {
    if (equivalenceClasses.length === 0) return null;
    const cls = findEquivalenceClassForHolding(holding.cards, board, equivalenceClasses);
    if (cls && cls.memberCount > 1) {
      return cls.label;
    }
    return null; // show specific cards
  }, [equivalenceClasses, board]);

  // Handle suit tap
  const handleSuitTap = useCallback((suit: number, overrideRank?: number) => {
    const rank = overrideRank ?? selectedRank;
    if (rank === null) return;

    const newCard: Card = { rank, suit };

    if (!firstCard) {
      // First card selected
      setFirstCard(newCard);
      setSelectedRank(null);
    } else {
      // Second card selected — create holding
      const holding: [Card, Card] = [firstCard, newCard];

      // Check for duplicate equivalence class
      if (equivalenceClasses.length > 0) {
        const sevenCards = [...board, ...holding];
        const newHandResult = evaluateBestHand(sevenCards);
        const newStrength = newHandResult.strength;

        // Find if any existing holding shares the same equivalence class
        for (let i = 0; i < holdings.length; i++) {
          const existingCards = [...board, ...holdings[i].cards] as Card[];
          const existingResult = evaluateBestHand(existingCards);
          if (existingResult.strength === newStrength) {
            // Find the class label and position
            const cls = findEquivalenceClassForHolding(holding, board, equivalenceClasses);
            const label = cls ? cls.label : `${cardToString(holding[0])}${cardToString(holding[1])}`;
            toast({
              title: 'Duplicate class',
              description: `${label} already ranked at #${i + 1}.`,
              variant: 'destructive',
            });
            setFirstCard(null);
            setSelectedRank(null);
            return;
          }
        }
      }

      const handName = getHandName(board, holding);
      const newHolding: Holding = { cards: holding, handName };

      setHoldings(prev => {
        const newHoldings = [...prev, newHolding];
        return newHoldings;
      });
      setUndoStack(prev => [...prev.slice(-19), { type: 'add', index: holdings.length }]);
      setFirstCard(null);
      setSelectedRank(null);

      // Show toast if this holding belongs to a multi-member equivalence class
      if (equivalenceClasses.length > 0) {
        const cls = findEquivalenceClassForHolding(holding, board, equivalenceClasses);
        if (cls && cls.memberCount > 1) {
          toast({
            title: 'Equivalent combos accepted',
            description: 'All equivalent suit combos accepted.',
          });
        }
      }
    }
  }, [selectedRank, firstCard, board, holdings, equivalenceClasses, toast]);

  // Undo (max 20 steps)
  const handleUndo = useCallback(() => {
    if (undoStack.length === 0) return;
    const action = undoStack[undoStack.length - 1];
    setUndoStack(prev => prev.slice(0, -1));

    switch (action.type) {
      case 'add':
        setHoldings(prev => prev.filter((_, i) => i !== action.index));
        break;
      case 'remove':
        setHoldings(prev => {
          const next = [...prev];
          next.splice(action.index, 0, action.holding);
          return next;
        });
        break;
      case 'reorder':
        setHoldings(prev => {
          const next = [...prev];
          [next[action.fromIndex], next[action.toIndex]] = [next[action.toIndex], next[action.fromIndex]];
          return next;
        });
        break;
      case 'clear':
        setHoldings(action.holdings);
        break;
    }
  }, [undoStack]);

  // Clear all
  const handleClearAll = () => {
    setUndoStack(prev => [...prev.slice(-19), { type: 'clear', holdings: [...holdings] }]);
    setHoldings([]);
    setFirstCard(null);
    setSelectedRank(null);
    setShowClearDialog(false);
  };

  // Remove holding
  const handleRemoveHolding = (index: number) => {
    const removed = holdings[index];
    setUndoStack(prev => [...prev.slice(-19), { type: 'remove', holding: removed, index }]);
    setHoldings(prev => prev.filter((_, i) => i !== index));
  };

  // Move holding up/down
  const handleMoveHolding = (index: number, direction: 'up' | 'down') => {
    const newIndex = direction === 'up' ? index - 1 : index + 1;
    if (newIndex < 0 || newIndex >= holdings.length) return;

    setUndoStack(prev => [...prev.slice(-19), { type: 'reorder', fromIndex: index, toIndex: newIndex }]);
    setHoldings(prev => {
      const next = [...prev];
      [next[index], next[newIndex]] = [next[newIndex], next[index]];
      return next;
    });
  };

  // Hint
  const handleHint = useCallback(() => {
    if (!hintText) {
      const allRanked = rankAllHoldings(board);
      const bestCategory = allRanked[0]?.handResult.categoryName || 'Unknown';
      setHintText(`Best possible: ${bestCategory}`);
    }
    setHintUsed(true);
  }, [board, hintText]);

  // Submit
  const handleSubmitAttempt = () => {
    if (holdings.length === 0) return;
    if (holdings.length < config.holdingsCount) {
      setShowSubmitDialog(true);
    } else {
      doSubmit();
    }
  };

  const doSubmit = () => {
    const timeTaken = config.timerEnabled ? Date.now() - startTime : null;
    if (timerRef.current) clearInterval(timerRef.current);
    onSubmit(holdings.map(h => ({ cards: h.cards })), timeTaken, hintUsed);
    navigate('/results');
  };

  // Cancel first card selection
  const cancelFirstCard = () => {
    setFirstCard(null);
    setSelectedRank(null);
  };

  // Leave drill
  const handleLeave = () => {
    if (timerRef.current) clearInterval(timerRef.current);
    navigate('/');
    setShowLeaveDialog(false);
  };

  const minutes = Math.floor(elapsed / 60000);
  const seconds = Math.floor((elapsed % 60000) / 1000);

  // Prompt text
  const getPromptText = () => {
    if (firstCard) return 'Select second card';
    if (selectedRank !== null) return `Now pick suit for ${RANK_NAMES[selectedRank]}`;
    return 'Select first card';
  };

  return (
    <div className="flex flex-col h-[100dvh] overflow-hidden" data-testid="drill-screen">
      {/* Top bar: Back + Timer + Toolbar */}
      <div className="flex-shrink-0 bg-card/50 backdrop-blur-sm border-b border-border px-3 pt-2 pb-2">
        <div className="flex items-center justify-between mb-2">
          <button
            onClick={() => setShowLeaveDialog(true)}
            className="p-1.5 rounded-md hover:bg-secondary transition-colors"
            data-testid="button-back"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>

          {config.timerEnabled && (
            <span className="font-mono text-sm text-muted-foreground tabular-nums" data-testid="text-timer">
              {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
            </span>
          )}

          <div className="flex gap-1">
            <button
              onClick={handleUndo}
              disabled={undoStack.length === 0}
              className="p-1.5 rounded-md hover:bg-secondary disabled:opacity-30 transition-colors"
              data-testid="button-undo"
              title="Undo"
            >
              <Undo2 className="w-4 h-4" />
            </button>
            <button
              onClick={() => holdings.length > 0 && setShowClearDialog(true)}
              disabled={holdings.length === 0}
              className="p-1.5 rounded-md hover:bg-secondary disabled:opacity-30 transition-colors"
              data-testid="button-clear"
              title="Clear All"
            >
              <Trash2 className="w-4 h-4" />
            </button>
            <button
              onClick={handleHint}
              className={`p-1.5 rounded-md transition-colors ${hintUsed ? 'text-[hsl(var(--accent))]' : 'hover:bg-secondary'}`}
              data-testid="button-hint"
              title="Hint"
            >
              <Lightbulb className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Board Cards */}
        <div className="flex justify-center gap-1.5">
          {board.map((card, i) => (
            <BoardCard key={cardKey(card)} card={card} index={i} />
          ))}
        </div>

        {/* Hint display */}
        {hintText && (
          <div className="mt-2 text-center">
            <span className="text-xs px-2 py-1 rounded-full bg-[hsl(var(--accent))]/15 text-[hsl(var(--accent))] font-medium">
              💡 {hintText}
            </span>
          </div>
        )}
      </div>

      {/* Middle: Card Picker + Holdings list */}
      <div className="flex-1 overflow-y-auto min-h-0">
        {/* Card Picker */}
        <div className="px-3 pt-3 pb-2">
          {/* Status prompt */}
          <div className="flex items-center justify-between mb-2">
            <div className="text-xs text-muted-foreground">
              {firstCard ? (
                <span className="flex items-center gap-1">
                  <span className={`font-mono font-bold ${getSuitColorClass(firstCard.suit)}`}>
                    {cardToString(firstCard)}
                  </span>
                  <span>selected — pick 2nd card</span>
                  <button onClick={cancelFirstCard} className="ml-1 text-destructive hover:text-destructive/80">
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ) : selectedRank !== null ? (
                <span>Pick suit for <span className="font-mono font-bold">{RANK_NAMES[selectedRank]}</span></span>
              ) : (
                <span>{getPromptText()} ({holdings.length}/{config.holdingsCount})</span>
              )}
            </div>
          </div>

          {/* Rank Buttons (always visible) */}
          <div className="space-y-1.5 mb-2">
            <div className="grid grid-cols-7 gap-1">
              {RANK_ROW_1.map(rank => {
                const exhausted = isRankExhausted(rank);
                const isSelected = selectedRank === rank;
                return (
                  <button
                    key={rank}
                    onClick={() => handleRankTap(rank)}
                    disabled={exhausted}
                    className={`h-12 rounded-lg font-mono font-bold text-sm transition-all ${
                      exhausted
                        ? 'opacity-40 bg-muted cursor-not-allowed'
                        : isSelected
                        ? 'bg-primary text-primary-foreground glow-primary scale-105'
                        : 'bg-secondary text-secondary-foreground hover:bg-secondary/70 active:scale-95'
                    }`}
                    data-testid={`button-rank-${RANK_NAMES[rank]}`}
                  >
                    {RANK_NAMES[rank]}
                  </button>
                );
              })}
            </div>
            <div className="grid grid-cols-7 gap-1">
              {RANK_ROW_2.map(rank => {
                const exhausted = isRankExhausted(rank);
                const isSelected = selectedRank === rank;
                return (
                  <button
                    key={rank}
                    onClick={() => handleRankTap(rank)}
                    disabled={exhausted}
                    className={`h-12 rounded-lg font-mono font-bold text-sm transition-all ${
                      exhausted
                        ? 'opacity-40 bg-muted cursor-not-allowed'
                        : isSelected
                        ? 'bg-primary text-primary-foreground glow-primary scale-105'
                        : 'bg-secondary text-secondary-foreground hover:bg-secondary/70 active:scale-95'
                    }`}
                    data-testid={`button-rank-${RANK_NAMES[rank]}`}
                  >
                    {RANK_NAMES[rank]}
                  </button>
                );
              })}
              <div /> {/* Empty 7th slot */}
            </div>
          </div>

          {/* Suit Picker (shown after rank selection) */}
          {selectedRank !== null && (
            <div className="mb-2 p-3 bg-card rounded-xl border border-border animate-in slide-in-from-bottom-2 duration-200">
              <p className="text-xs text-muted-foreground text-center mb-2">
                Pick suit for <span className="font-mono font-bold">{RANK_NAMES[selectedRank]}</span>
              </p>
              <div className="grid grid-cols-2 gap-2 max-w-[200px] mx-auto">
                {SUITS.map(suit => {
                  const isUsed = usedCards.has(suit * 13 + selectedRank);
                  return (
                    <button
                      key={suit}
                      onClick={() => !isUsed && handleSuitTap(suit)}
                      disabled={isUsed}
                      className={`h-[72px] rounded-xl text-3xl font-bold transition-all ${
                        isUsed
                          ? 'opacity-20 bg-muted cursor-not-allowed'
                          : `${getSuitBgClass(suit)} ${getSuitColorClass(suit)} hover:scale-105 active:scale-95 border border-border`
                      }`}
                      data-testid={`button-suit-${SUIT_SYMBOLS[suit]}`}
                    >
                      {SUIT_SYMBOLS[suit]}
                    </button>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        {/* Holdings List */}
        <div className="px-3 pb-3">
          {holdings.length > 0 && (
            <div className="space-y-1">
              {holdings.map((holding, index) => {
                const classLabel = getHoldingDisplayLabel(holding);
                return (
                  <div
                    key={`${cardKey(holding.cards[0])}-${cardKey(holding.cards[1])}`}
                    className="flex items-center gap-2 bg-card rounded-lg border border-card-border p-2 slide-in-right"
                    style={{ animationDelay: '0s' }}
                    data-testid={`holding-${index}`}
                  >
                    {/* Rank number */}
                    <span className="text-xs font-bold text-muted-foreground w-5 text-center font-mono">
                      #{index + 1}
                    </span>

                    {/* Cards or class label */}
                    {classLabel ? (
                      <span className="text-xs font-mono font-bold px-1.5 py-0.5 rounded bg-primary/10 text-primary">
                        {classLabel}
                      </span>
                    ) : (
                      <div className="flex gap-1">
                        {holding.cards.map((card, ci) => (
                          <span
                            key={ci}
                            className={`text-xs font-mono font-bold px-1.5 py-0.5 rounded ${getSuitBgClass(card.suit)} ${getSuitColorClass(card.suit)}`}
                          >
                            {cardToString(card)}
                          </span>
                        ))}
                      </div>
                    )}

                    {/* Hand name */}
                    <span className="text-xs text-muted-foreground flex-1 truncate">
                      {holding.handName}
                    </span>

                    {/* Controls */}
                    <div className="flex items-center gap-0.5 flex-shrink-0">
                      <button
                        onClick={() => handleMoveHolding(index, 'up')}
                        disabled={index === 0}
                        className="p-1 rounded hover:bg-secondary disabled:opacity-20 transition-colors"
                        data-testid={`button-move-up-${index}`}
                      >
                        <ChevronUp className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleMoveHolding(index, 'down')}
                        disabled={index === holdings.length - 1}
                        className="p-1 rounded hover:bg-secondary disabled:opacity-20 transition-colors"
                        data-testid={`button-move-down-${index}`}
                      >
                        <ChevronDown className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleRemoveHolding(index)}
                        className="p-1 rounded hover:bg-destructive/20 text-destructive transition-colors"
                        data-testid={`button-remove-${index}`}
                      >
                        <X className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Submit Button - fixed at bottom */}
      <div
        className="flex-shrink-0 px-3 pb-3 pt-2 border-t border-border bg-background/80 backdrop-blur-sm"
        style={{ paddingBottom: 'max(12px, env(safe-area-inset-bottom, 12px))' }}
      >
        <Button
          onClick={handleSubmitAttempt}
          disabled={holdings.length === 0}
          className="w-full h-12 font-semibold gap-2"
          data-testid="button-submit"
        >
          <Send className="w-4 h-4" />
          Submit {holdings.length} Holding{holdings.length !== 1 ? 's' : ''} ✓
        </Button>
      </div>

      {/* Submit confirmation dialog */}
      <AlertDialog open={showSubmitDialog} onOpenChange={setShowSubmitDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Submit early?</AlertDialogTitle>
            <AlertDialogDescription>
              You've ranked {holdings.length} of {config.holdingsCount} holdings. Submit anyway?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Keep Going</AlertDialogCancel>
            <AlertDialogAction onClick={doSubmit}>Submit</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Clear all confirmation dialog */}
      <AlertDialog open={showClearDialog} onOpenChange={setShowClearDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Clear all holdings?</AlertDialogTitle>
            <AlertDialogDescription>
              This will remove all {holdings.length} holdings. You can undo this action.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleClearAll}>Clear All</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Leave drill confirmation dialog (spec 8.4) */}
      <AlertDialog open={showLeaveDialog} onOpenChange={setShowLeaveDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Leave drill?</AlertDialogTitle>
            <AlertDialogDescription>
              Your progress will be lost. Are you sure you want to leave?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Stay</AlertDialogCancel>
            <AlertDialogAction onClick={handleLeave}>Leave</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
