import { useQuery } from "@tanstack/react-query";
import { AppShell } from "@/components/AppShell";
import { SectionCard } from "@/components/SectionCard";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Skeleton } from "@/components/ui/skeleton";

interface Section {
  id: number;
  name: string;
  icon: string;
  description: string;
  sortOrder: number;
}

interface Entry {
  id: number;
  categoryId: number;
  completionStatus: string;
}

interface Category {
  id: number;
  sectionId: number;
}

export default function SectionsPage() {
  const { state } = useVault();
  const vaultId = state.currentVaultId!;

  const { data: sections, isLoading } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
  });

  const { data: allEntries } = useQuery<Entry[]>({
    queryKey: ["/api/entries/vault", String(vaultId)],
  });

  const sectionCategories = useQuery<Record<number, Category[]>>({
    queryKey: ["section-categories-all", String(vaultId)],
    queryFn: async () => {
      if (!sections) return {};
      const result: Record<number, Category[]> = {};
      for (const section of sections) {
        const res = await apiRequest("GET", `/api/categories/${section.id}`);
        result[section.id] = await res.json();
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

  function getSectionStats(sectionId: number) {
    const cats = sectionCategories.data?.[sectionId] || [];
    let entryCount = 0;
    let completedCats = 0;
    for (const cat of cats) {
      const catEntries = entriesByCategory.get(cat.id) || [];
      entryCount += catEntries.length;
      if (catEntries.some(e => e.completionStatus === "complete")) completedCats++;
    }
    return { entryCount, categoryCount: cats.length, completedCategories: completedCats };
  }

  return (
    <AppShell title="All Sections">
      <div className="p-4 md:p-6 max-w-5xl mx-auto">
        {isLoading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-24 rounded-lg" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {sections?.sort((a, b) => a.sortOrder - b.sortOrder).map((section) => {
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
    </AppShell>
  );
}
