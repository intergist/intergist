import { useState, useCallback } from 'react';
import { Switch, Route, Router, Link, useLocation } from 'wouter';
import { useHashLocation } from 'wouter/use-hash-location';
import { queryClient } from './lib/queryClient';
import { QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from '@/components/ui/toaster';
import { TooltipProvider } from '@/components/ui/tooltip';
import { ThemeProvider } from '@/lib/ThemeProvider';
import { Home as HomeIcon, BarChart3, Settings as SettingsIcon } from 'lucide-react';
import NotFound from '@/pages/not-found';
import HomePage from '@/pages/Home';
import DrillConfigPage from '@/pages/DrillConfig';
import DrillScreen from '@/pages/DrillScreen';
import ResultsPage from '@/pages/Results';
import StatsPage from '@/pages/Stats';
import SettingsPage from '@/pages/Settings';
import { PerplexityAttribution } from '@/components/PerplexityAttribution';
import type { DrillConfig, DrillRecord, AppSettings } from '@/lib/gameState';
import { defaultConfig, defaultSettings, generateId } from '@/lib/gameState';
import type { Card } from '@/lib/poker';
import { dealBoard } from '@/lib/poker';
import { scoreSubmissionGrouped, analyzeBoardTexture } from '@/lib/scoring';
import type { GroupedScoringResult } from '@/lib/scoring';

function BottomNav() {
  const [location] = useLocation();

  // Hide nav during drill and results
  if (location === '/drill' || location === '/results') return null;

  const tabs = [
    { path: '/', icon: HomeIcon, label: 'Home' },
    { path: '/stats', icon: BarChart3, label: 'Stats' },
    { path: '/settings', icon: SettingsIcon, label: 'Settings' },
  ];

  return (
    <nav
      className="fixed bottom-0 left-0 right-0 bg-card/90 backdrop-blur-md border-t border-border z-50"
      style={{ paddingBottom: 'env(safe-area-inset-bottom, 0px)' }}
      data-testid="bottom-nav"
    >
      <div className="flex items-center justify-around h-14 max-w-lg mx-auto">
        {tabs.map(tab => {
          const isActive = location === tab.path;
          const Icon = tab.icon;
          return (
            <Link key={tab.path} href={tab.path}>
              <button
                className={`flex flex-col items-center gap-0.5 px-4 py-1.5 transition-colors ${
                  isActive ? 'text-primary' : 'text-muted-foreground hover:text-foreground'
                }`}
                data-testid={`nav-${tab.label.toLowerCase()}`}
              >
                <Icon className="w-5 h-5" />
                <span className="text-[10px] font-medium">{tab.label}</span>
              </button>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}

function AppContent() {
  const [, navigate] = useLocation();
  const [drillConfig, setDrillConfig] = useState<DrillConfig>(defaultConfig);
  const [settings, setSettings] = useState<AppSettings>(defaultSettings);
  const [drillHistory, setDrillHistory] = useState<DrillRecord[]>([]);
  const [currentBoard, setCurrentBoard] = useState<Card[]>([]);
  const [lastResult, setLastResult] = useState<{
    board: Card[];
    scoringResult: GroupedScoringResult;
    timeTakenMs: number | null;
    targetCount: number;
    hintUsed: boolean;
  } | null>(null);

  const handleStartDrill = useCallback(() => {
    const board = dealBoard();
    setCurrentBoard(board);
  }, []);

  const handleSubmit = useCallback((
    holdings: { cards: [Card, Card] }[],
    timeTakenMs: number | null,
    hintUsed: boolean
  ) => {
    const result = scoreSubmissionGrouped(currentBoard, holdings, drillConfig.holdingsCount);
    const texture = analyzeBoardTexture(currentBoard);

    const record: DrillRecord = {
      id: generateId(),
      date: new Date(),
      board: currentBoard,
      targetCount: drillConfig.holdingsCount,
      timerEnabled: drillConfig.timerEnabled,
      timeTakenMs,
      hintUsed,
      userHoldings: holdings.map((h, i) => ({ ...h, rank: i + 1 })),
      scoringResult: result,
      boardTexture: texture,
      suitSensitive: result.isSuitSensitive,
    };

    setDrillHistory(prev => [...prev, record]);
    setLastResult({
      board: currentBoard,
      scoringResult: result,
      timeTakenMs,
      targetCount: drillConfig.holdingsCount,
      hintUsed,
    });
  }, [currentBoard, drillConfig]);

  const handlePlayAgain = useCallback(() => {
    const board = dealBoard();
    setCurrentBoard(board);
    navigate('/drill');
  }, [navigate]);

  const handleResetStats = useCallback(() => {
    setDrillHistory([]);
  }, []);

  const handleSettingsChange = useCallback((newSettings: AppSettings) => {
    setSettings(newSettings);
    // Sync defaults to drill config
    setDrillConfig(prev => ({
      ...prev,
      holdingsCount: newSettings.defaultHoldingsCount,
      timerEnabled: newSettings.defaultTimerEnabled,
    }));
  }, []);

  return (
    <div className="max-w-[430px] mx-auto min-h-[100dvh] bg-background relative">
      <Switch>
        <Route path="/">
          <HomePage drillHistory={drillHistory} playerName={settings.playerName} />
        </Route>
        <Route path="/config">
          <DrillConfigPage
            config={drillConfig}
            onConfigChange={setDrillConfig}
            onStartDrill={handleStartDrill}
          />
        </Route>
        <Route path="/drill">
          {currentBoard.length === 5 ? (
            <DrillScreen
              board={currentBoard}
              config={drillConfig}
              onSubmit={handleSubmit}
            />
          ) : (
            <div className="flex items-center justify-center min-h-[100dvh]">
              <p className="text-muted-foreground">No board dealt. <Link href="/config" className="text-primary underline">Configure a drill</Link></p>
            </div>
          )}
        </Route>
        <Route path="/results">
          {lastResult ? (
            <ResultsPage
              board={lastResult.board}
              scoringResult={lastResult.scoringResult}
              timeTakenMs={lastResult.timeTakenMs}
              targetCount={lastResult.targetCount}
              hintUsed={lastResult.hintUsed}
              onPlayAgain={handlePlayAgain}
            />
          ) : (
            <div className="flex items-center justify-center min-h-[100dvh]">
              <p className="text-muted-foreground">No results yet. <Link href="/" className="text-primary underline">Go home</Link></p>
            </div>
          )}
        </Route>
        <Route path="/stats">
          <StatsPage drillHistory={drillHistory} />
        </Route>
        <Route path="/settings">
          <SettingsPage
            settings={settings}
            onSettingsChange={handleSettingsChange}
            onResetStats={handleResetStats}
            drillCount={drillHistory.length}
          />
        </Route>
        <Route component={NotFound} />
      </Switch>
      <BottomNav />
    </div>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <ThemeProvider>
          <Router hook={useHashLocation}>
            <AppContent />
          </Router>
        </ThemeProvider>
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
