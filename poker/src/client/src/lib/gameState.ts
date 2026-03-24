// Poker Sharp — Game State Management
// All state is in-memory (React state), no localStorage per sandbox constraints

import type { Card } from './poker';
import type { ScoringResult, BoardTexture, GroupedScoringResult } from './scoring';

export interface DrillConfig {
  holdingsCount: number; // 5, 10, 15, 20
  timerEnabled: boolean;
}

export interface DrillRecord {
  id: string;
  date: Date;
  board: Card[];
  targetCount: number;
  timerEnabled: boolean;
  timeTakenMs: number | null;
  hintUsed: boolean;
  userHoldings: { cards: [Card, Card]; rank: number }[];
  scoringResult: ScoringResult | GroupedScoringResult;
  boardTexture?: BoardTexture;
  suitSensitive: boolean; // was this a suit-sensitive board?
}

export interface AppSettings {
  darkMode: boolean;
  playerName: string;
  defaultHoldingsCount: number;
  defaultTimerEnabled: boolean;
}

export const defaultConfig: DrillConfig = {
  holdingsCount: 10,
  timerEnabled: true,
};

export const defaultSettings: AppSettings = {
  darkMode: true, // dark mode is primary for poker feel
  playerName: 'Player',
  defaultHoldingsCount: 10,
  defaultTimerEnabled: true,
};

// Generate a unique ID
export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
}

// Stats calculation helpers
export function getStats(history: DrillRecord[]) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const drillsToday = history.filter(d => {
    const drillDate = new Date(d.date);
    drillDate.setHours(0, 0, 0, 0);
    return drillDate.getTime() === today.getTime();
  }).length;

  // Current streak (consecutive days with at least 1 drill)
  let streak = 0;
  const dayMs = 86400000;
  let checkDate = new Date(today);

  while (true) {
    const hasForDay = history.some(d => {
      const drillDate = new Date(d.date);
      drillDate.setHours(0, 0, 0, 0);
      return drillDate.getTime() === checkDate.getTime();
    });
    if (hasForDay) {
      streak++;
      checkDate = new Date(checkDate.getTime() - dayMs);
    } else {
      break;
    }
  }

  // Longest streak
  let longestStreak = 0;
  if (history.length > 0) {
    const allDates = [...new Set(history.map(d => {
      const dt = new Date(d.date);
      dt.setHours(0, 0, 0, 0);
      return dt.getTime();
    }))].sort((a, b) => a - b);

    let currentRun = 1;
    let maxRun = 1;
    for (let i = 1; i < allDates.length; i++) {
      if (allDates[i] - allDates[i - 1] === dayMs) {
        currentRun++;
        maxRun = Math.max(maxRun, currentRun);
      } else {
        currentRun = 1;
      }
    }
    longestStreak = maxRun;
  }

  // Best accuracy (last 7 days)
  const weekAgo = new Date(today.getTime() - 7 * dayMs);
  const recentDrills = history.filter(d => new Date(d.date) >= weekAgo);
  const bestAccuracy = recentDrills.length > 0
    ? Math.max(...recentDrills.map(d => d.scoringResult.percentage))
    : 0;

  const totalDrills = history.length;

  return { drillsToday, streak, longestStreak, bestAccuracy, totalDrills };
}

/**
 * Calculate accuracy comparison between suit-sensitive and non-suit-sensitive boards.
 * Returns { sensitiveAvg, nonSensitiveAvg, sensitiveCount, nonSensitiveCount }
 * so Stats.tsx can display the comparison.
 */
export function getSuitSensitivity(history: DrillRecord[]) {
  const sensitive = history.filter(d => d.suitSensitive);
  const nonSensitive = history.filter(d => !d.suitSensitive);

  const avg = (records: DrillRecord[]) =>
    records.length === 0
      ? null
      : Math.round(records.reduce((sum, d) => sum + d.scoringResult.percentage, 0) / records.length);

  return {
    sensitiveAvg: avg(sensitive),
    nonSensitiveAvg: avg(nonSensitive),
    sensitiveCount: sensitive.length,
    nonSensitiveCount: nonSensitive.length,
  };
}
