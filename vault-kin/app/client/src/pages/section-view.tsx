import { useQuery } from "@tanstack/react-query";
import { Link, useParams } from "wouter";
import { AppShell } from "@/components/AppShell";
import { SectionIcon } from "@/components/SectionIcon";
import { useVault } from "@/context/VaultContext";
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbSeparator } from "@/components/ui/breadcrumb";
import { ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";

interface Section {
  id: number;
  name: string;
  icon: string;
  description: string;
  sortOrder: number;
}

interface Category {
  id: number;
  sectionId: number;
  name: string;
  type: string;
  guidanceText: string;
  iconName: string;
  sortOrder: number;
}

interface Entry {
  id: number;
  categoryId: number;
  completionStatus: string;
}

export default function SectionView() {
  const params = useParams<{ id: string }>();
  const sectionId = Number(params.id);
  const { state } = useVault();
  const vaultId = state.currentVaultId!;
  const [descExpanded, setDescExpanded] = useState(false);

  const { data: allSections, isLoading: sectionLoading } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
  });
  const section = allSections?.find((s) => s.id === sectionId);

  const { data: categories, isLoading: catsLoading } = useQuery<Category[]>({
    queryKey: ["/api/categories", String(sectionId)],
  });

  const { data: allEntries } = useQuery<Entry[]>({
    queryKey: ["/api/entries/vault", String(vaultId)],
  });

  const entriesByCategory = new Map<number, Entry[]>();
  if (allEntries) {
    for (const entry of allEntries) {
      const existing = entriesByCategory.get(entry.categoryId) || [];
      existing.push(entry);
      entriesByCategory.set(entry.categoryId, existing);
    }
  }

  const isLoading = sectionLoading || catsLoading;

  return (
    <AppShell title={section?.name}>
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
        {/* Breadcrumb */}
        <Breadcrumb>
          <BreadcrumbList>
            <BreadcrumbItem>
              <BreadcrumbLink asChild><Link href="/dashboard">Home</Link></BreadcrumbLink>
            </BreadcrumbItem>
            <BreadcrumbSeparator />
            <BreadcrumbItem>
              <BreadcrumbLink asChild><Link href="/sections">Sections</Link></BreadcrumbLink>
            </BreadcrumbItem>
            <BreadcrumbSeparator />
            <BreadcrumbItem>{section?.name || "..."}</BreadcrumbItem>
          </BreadcrumbList>
        </Breadcrumb>

        {isLoading ? (
          <div className="space-y-3">
            <Skeleton className="h-16 rounded-lg" />
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-20 rounded-lg" />
            ))}
          </div>
        ) : (
          <>
            {/* Section header */}
            {section && (
              <div className="flex items-start gap-3">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary shrink-0">
                  <SectionIcon icon={section.icon} className="h-6 w-6" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-bold">{section.name}</h2>
                  <button
                    onClick={() => setDescExpanded(!descExpanded)}
                    className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground mt-1"
                    data-testid="toggle-description"
                  >
                    {descExpanded ? "Hide description" : "Show description"}
                    {descExpanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
                  </button>
                  {descExpanded && (
                    <p className="text-sm text-muted-foreground mt-2">{section.description}</p>
                  )}
                </div>
              </div>
            )}

            {/* Category list */}
            <div className="space-y-2">
              {categories?.sort((a, b) => a.sortOrder - b.sortOrder).map((cat) => {
                const catEntries = entriesByCategory.get(cat.id) || [];
                const entryCount = catEntries.length;
                const hasComplete = catEntries.some(e => e.completionStatus === "complete");
                const hasPartial = catEntries.some(e => e.completionStatus === "partial");

                let statusColor = "bg-muted";
                let statusLabel = "Empty";
                if (hasComplete) {
                  statusColor = "bg-green-500";
                  statusLabel = "Complete";
                } else if (hasPartial || entryCount > 0) {
                  statusColor = "bg-accent";
                  statusLabel = "In Progress";
                }

                return (
                  <Link key={cat.id} href={`/category/${cat.id}`}>
                    <Card className="cursor-pointer hover:border-primary/30 transition-colors" data-testid={`category-card-${cat.id}`}>
                      <CardContent className="p-4">
                        <div className="flex items-center gap-3">
                          <div className={`w-2 h-2 rounded-full shrink-0 ${statusColor}`} />
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <h3 className="font-medium text-sm truncate">{cat.name}</h3>
                              <Badge variant="outline" className="text-xs shrink-0">
                                {cat.type === "single" ? "Single" : "Multi"}
                              </Badge>
                            </div>
                            <p className="text-xs text-muted-foreground mt-0.5">
                              {entryCount === 0
                                ? "No entries yet"
                                : `${entryCount} ${entryCount === 1 ? "entry" : "entries"} — ${statusLabel}`}
                            </p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </Link>
                );
              })}
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}
