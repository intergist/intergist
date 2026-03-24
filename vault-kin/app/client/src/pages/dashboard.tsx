import { useQuery } from "@tanstack/react-query";
import { Link } from "wouter";
import { AppShell } from "@/components/AppShell";
import { ProgressRing } from "@/components/ProgressRing";
import { SectionCard } from "@/components/SectionCard";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Search, Bell, AlertTriangle } from "lucide-react";

interface Section {
  id: number;
  name: string;
  icon: string;
  description: string;
  sortOrder: number;
  vaultId: number;
  isVisible: number;
}

interface Entry {
  id: number;
  categoryId: number;
  vaultId: number;
  title: string;
  completionStatus: string;
  updatedAt: string;
}

interface Category {
  id: number;
  sectionId: number;
  name: string;
  type: string;
}

interface ProgressData {
  total: number;
  completed: number;
  partial: number;
  empty: number;
  percentage: number;
}

export default function Dashboard() {
  const { state } = useVault();
  const vaultId = state.currentVaultId!;

  const { data: sections, isLoading: sectionsLoading } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
  });

  const { data: progress, isLoading: progressLoading } = useQuery<ProgressData>({
    queryKey: ["/api/progress", String(vaultId)],
  });

  const { data: allEntries } = useQuery<Entry[]>({
    queryKey: ["/api/entries/vault", String(vaultId)],
  });

  // Build a map of sectionId -> categories for counting
  const sectionCategories = useQuery<Record<number, Category[]>>({
    queryKey: ["section-categories-all", String(vaultId)],
    queryFn: async () => {
      if (!sections) return {};
      const result: Record<number, Category[]> = {};
      for (const section of sections) {
        const res = await apiRequest("GET", `/api/categories/${section.id}`);
        const cats = await res.json();
        result[section.id] = cats;
      }
      return result;
    },
    enabled: !!sections,
  });

  const entriesByCategory = new Map<number, Entry[]>();
  if (allEntries) {
    for (const entry of allEntries) {
      const existing = entriesByCategory.get(entry.categoryId) || [];
      existing.push(entry);
      entriesByCategory.set(entry.categoryId, existing);
    }
  }

  // Find the most recently updated entry
  const lastEdited = allEntries
    ?.filter(e => e.updatedAt)
    ?.sort((a, b) => b.updatedAt.localeCompare(a.updatedAt))?.[0];

  function getSectionStats(sectionId: number) {
    const cats = sectionCategories.data?.[sectionId] || [];
    let entryCount = 0;
    let completedCats = 0;
    for (const cat of cats) {
      const catEntries = entriesByCategory.get(cat.id) || [];
      entryCount += catEntries.length;
      if (catEntries.some(e => e.completionStatus === "complete")) {
        completedCats++;
      }
    }
    return { entryCount, categoryCount: cats.length, completedCategories: completedCats };
  }

  return (
    <AppShell>
      <div className="p-4 md:p-6 space-y-6 max-w-5xl mx-auto">
        {/* Welcome banner */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-bold">
              Welcome back, {state.ownerName?.split(" ")[0] || "there"}
            </h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              Keep going — every detail you record helps protect your family.
            </p>
          </div>
        </div>

        {/* Progress + quick actions */}
        <div className="flex flex-col sm:flex-row gap-6 items-center">
          {progressLoading ? (
            <Skeleton className="w-[120px] h-[120px] rounded-full" />
          ) : (
            <ProgressRing value={progress?.percentage || 0} />
          )}

          <div className="flex-1 space-y-3 w-full">
            {progress && progress.empty > 0 && (
              <Card className="border-accent/30 bg-accent/5">
                <CardContent className="p-3 flex items-center gap-3">
                  <AlertTriangle className="h-4 w-4 text-accent shrink-0" />
                  <Link href="/gap-finder">
                    <p className="text-sm cursor-pointer hover:underline">
                      You have <strong>{progress.empty}</strong> categories with no entries yet.{" "}
                      <span className="text-accent font-medium">Tap to see gaps.</span>
                    </p>
                  </Link>
                </CardContent>
              </Card>
            )}

            <div className="flex gap-2">
              <Link href="/search">
                <Button variant="outline" size="sm" data-testid="quick-search">
                  <Search className="h-4 w-4 mr-1" /> Search
                </Button>
              </Link>
              <Link href="/settings">
                <Button variant="outline" size="sm" data-testid="quick-reminders">
                  <Bell className="h-4 w-4 mr-1" /> Reminders
                </Button>
              </Link>
            </div>

            {lastEdited && (
              <Link href={`/entry/${lastEdited.id}`}>
                <Button variant="ghost" size="sm" className="text-xs text-muted-foreground" data-testid="continue-editing">
                  Continue editing: {lastEdited.title || "Untitled"} →
                </Button>
              </Link>
            )}
          </div>
        </div>

        {/* Section cards grid */}
        <div>
          <h2 className="text-base font-semibold mb-3">Your Sections</h2>
          {sectionsLoading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {Array.from({ length: 6 }).map((_, i) => (
                <Skeleton key={i} className="h-24 rounded-lg" />
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {sections
                ?.sort((a, b) => a.sortOrder - b.sortOrder)
                .map((section) => {
                  const stats = getSectionStats(section.id);
                  return (
                    <SectionCard
                      key={section.id}
                      section={section}
                      entryCount={stats.entryCount}
                      categoryCount={stats.categoryCount}
                      completedCategories={stats.completedCategories}
                    />
                  );
                })}
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}
