import { useQuery } from "@tanstack/react-query";
import { Link } from "wouter";
import { AppShell } from "@/components/AppShell";
import { SectionIcon } from "@/components/SectionIcon";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle, CheckCircle2 } from "lucide-react";

interface Section {
  id: number;
  name: string;
  icon: string;
  sortOrder: number;
}

interface Category {
  id: number;
  sectionId: number;
  name: string;
  type: string;
  fieldSchema: string;
}

interface Entry {
  id: number;
  categoryId: number;
  title: string;
  fields: string;
  completionStatus: string;
}

interface Gap {
  type: "empty_category" | "incomplete_entry";
  sectionName: string;
  sectionIcon: string;
  categoryName: string;
  categoryId: number;
  entryId?: number;
  entryTitle?: string;
  missingRequired: string[];
}

export default function GapFinder() {
  const { state } = useVault();
  const vaultId = state.currentVaultId!;

  const { data: sections } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
  });

  const { data: allEntries } = useQuery<Entry[]>({
    queryKey: ["/api/entries/vault", String(vaultId)],
  });

  // Fetch all categories for all sections
  const { data: allCategories, isLoading } = useQuery<Category[]>({
    queryKey: ["all-categories", String(vaultId)],
    queryFn: async () => {
      if (!sections) return [];
      const results: Category[] = [];
      for (const section of sections) {
        const res = await apiRequest("GET", `/api/categories/${section.id}`);
        const cats = await res.json();
        results.push(...cats);
      }
      return results;
    },
    enabled: !!sections,
  });

  // Build gaps
  const gaps: Gap[] = [];
  if (sections && allCategories && allEntries) {
    const sectionMap = new Map(sections.map(s => [s.id, s]));
    const entriesByCategory = new Map<number, Entry[]>();
    for (const entry of allEntries) {
      const existing = entriesByCategory.get(entry.categoryId) || [];
      existing.push(entry);
      entriesByCategory.set(entry.categoryId, existing);
    }

    for (const cat of allCategories) {
      const section = sectionMap.get(cat.sectionId);
      if (!section) continue;
      const catEntries = entriesByCategory.get(cat.id) || [];

      if (catEntries.length === 0) {
        gaps.push({
          type: "empty_category",
          sectionName: section.name,
          sectionIcon: section.icon,
          categoryName: cat.name,
          categoryId: cat.id,
          missingRequired: [],
        });
      } else {
        // Check for incomplete entries with missing required fields
        let schema: any;
        try { schema = JSON.parse(cat.fieldSchema); } catch { continue; }
        const requiredFields = schema.groups?.flatMap((g: any) =>
          g.fields.filter((f: any) => f.priority === "required").map((f: any) => f)
        ) || [];

        for (const entry of catEntries) {
          let fields: Record<string, any> = {};
          try { fields = JSON.parse(entry.fields); } catch { /* ignore */ }

          const missing = requiredFields.filter((f: any) => {
            const val = fields[f.id];
            return val === undefined || val === null || val === "" || val === false;
          });

          if (missing.length > 0) {
            gaps.push({
              type: "incomplete_entry",
              sectionName: section.name,
              sectionIcon: section.icon,
              categoryName: cat.name,
              categoryId: cat.id,
              entryId: entry.id,
              entryTitle: entry.title,
              missingRequired: missing.map((f: any) => f.label),
            });
          }
        }
      }
    }
  }

  const emptyGaps = gaps.filter(g => g.type === "empty_category");
  const incompleteGaps = gaps.filter(g => g.type === "incomplete_entry");

  return (
    <AppShell title="Gap Finder">
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-6">
        {isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-16 rounded-lg" />
            ))}
          </div>
        ) : gaps.length === 0 ? (
          <div className="text-center py-12">
            <CheckCircle2 className="h-12 w-12 text-green-600 mx-auto mb-3" />
            <h2 className="text-lg font-semibold">No Gaps Found</h2>
            <p className="text-sm text-muted-foreground mt-1">
              All categories have entries and all required fields are filled.
            </p>
          </div>
        ) : (
          <>
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-accent" />
              <h2 className="text-base font-semibold">
                {gaps.length} {gaps.length === 1 ? "gap" : "gaps"} found
              </h2>
            </div>

            {/* Empty categories */}
            {emptyGaps.length > 0 && (
              <div className="space-y-2">
                <h3 className="text-sm font-semibold text-muted-foreground">
                  Categories with no entries ({emptyGaps.length})
                </h3>
                {emptyGaps.map((gap, i) => (
                  <Link key={i} href={`/category/${gap.categoryId}`}>
                    <Card className="cursor-pointer hover:border-primary/30 transition-colors" data-testid={`gap-empty-${gap.categoryId}`}>
                      <CardContent className="p-3 flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center shrink-0">
                          <SectionIcon icon={gap.sectionIcon} className="h-4 w-4 text-muted-foreground" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{gap.categoryName}</p>
                          <p className="text-xs text-muted-foreground">{gap.sectionName}</p>
                        </div>
                        <Badge variant="secondary" className="shrink-0">Empty</Badge>
                      </CardContent>
                    </Card>
                  </Link>
                ))}
              </div>
            )}

            {/* Incomplete entries */}
            {incompleteGaps.length > 0 && (
              <div className="space-y-2">
                <h3 className="text-sm font-semibold text-muted-foreground">
                  Entries missing required fields ({incompleteGaps.length})
                </h3>
                {incompleteGaps.map((gap, i) => (
                  <Link key={i} href={`/entry/${gap.entryId}`}>
                    <Card className="cursor-pointer hover:border-primary/30 transition-colors" data-testid={`gap-incomplete-${gap.entryId}`}>
                      <CardContent className="p-3 flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-accent/10 flex items-center justify-center shrink-0">
                          <SectionIcon icon={gap.sectionIcon} className="h-4 w-4 text-accent" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{gap.entryTitle || "Untitled"}</p>
                          <p className="text-xs text-muted-foreground">
                            {gap.categoryName} · Missing: {gap.missingRequired.slice(0, 3).join(", ")}
                            {gap.missingRequired.length > 3 && ` +${gap.missingRequired.length - 3} more`}
                          </p>
                        </div>
                        <Badge variant="outline" className="shrink-0 text-accent-foreground border-accent">
                          {gap.missingRequired.length} missing
                        </Badge>
                      </CardContent>
                    </Card>
                  </Link>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}
