import { Switch, Route, Router, Redirect } from "wouter";
import { useHashLocation } from "wouter/use-hash-location";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider, useQuery } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { VaultProvider, useVault } from "@/context/VaultContext";
import NotFound from "@/pages/not-found";
import Onboarding from "@/pages/onboarding";
import LockScreen from "@/pages/lock-screen";
import Dashboard from "@/pages/dashboard";
import SectionsPage from "@/pages/sections";
import SectionView from "@/pages/section-view";
import CategoryView from "@/pages/category-view";
import EntryForm from "@/pages/entry-form";
import SearchPage from "@/pages/search";
import BookmarksPage from "@/pages/bookmarks";
import SettingsPage from "@/pages/settings";
import GapFinder from "@/pages/gap-finder";
import { Skeleton } from "@/components/ui/skeleton";

function LandingOrDashboard() {
  const { state } = useVault();

  // Check if any vault exists by trying to get vault 1
  const { data: vault, isLoading, error } = useQuery<any>({
    queryKey: ["/api/vault", "1"],
    retry: false,
  });

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="space-y-4 w-64">
          <Skeleton className="h-16 w-16 rounded-full mx-auto" />
          <Skeleton className="h-4 w-48 mx-auto" />
          <Skeleton className="h-4 w-32 mx-auto" />
        </div>
      </div>
    );
  }

  // No vault exists → onboarding
  if (error || !vault) {
    return <Redirect to="/onboarding" />;
  }

  // Vault exists but not unlocked → lock screen
  if (!state.isUnlocked) {
    return <LockScreen vaultId={vault.id} />;
  }

  // Vault unlocked → dashboard
  return <Redirect to="/dashboard" />;
}

function ProtectedRoute({ component: Component }: { component: React.ComponentType }) {
  const { state } = useVault();

  if (!state.isUnlocked || !state.currentVaultId) {
    return <Redirect to="/" />;
  }

  return <Component />;
}

function AppRouter() {
  return (
    <Switch>
      <Route path="/" component={LandingOrDashboard} />
      <Route path="/onboarding" component={Onboarding} />
      <Route path="/dashboard">{() => <ProtectedRoute component={Dashboard} />}</Route>
      <Route path="/sections">{() => <ProtectedRoute component={SectionsPage} />}</Route>
      <Route path="/section/:id">{() => <ProtectedRoute component={SectionView} />}</Route>
      <Route path="/category/:id">{() => <ProtectedRoute component={CategoryView} />}</Route>
      <Route path="/entry/:id">{() => <ProtectedRoute component={EntryForm} />}</Route>
      <Route path="/entry/new/:categoryId">{() => <ProtectedRoute component={CategoryView} />}</Route>
      <Route path="/search">{() => <ProtectedRoute component={SearchPage} />}</Route>
      <Route path="/bookmarks">{() => <ProtectedRoute component={BookmarksPage} />}</Route>
      <Route path="/settings">{() => <ProtectedRoute component={SettingsPage} />}</Route>
      <Route path="/gap-finder">{() => <ProtectedRoute component={GapFinder} />}</Route>
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Router hook={useHashLocation}>
          <VaultProvider>
            <AppRouter />
          </VaultProvider>
        </Router>
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
