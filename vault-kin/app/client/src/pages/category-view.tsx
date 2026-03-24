import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Link, useLocation, useParams } from "wouter";
import { AppShell } from "@/components/AppShell";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { useToast } from "@/hooks/use-toast";
import { Plus, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";

interface Category {
  id: number;
  sectionId: number;
  name: string;
  type: string;
  guidanceText: string;
  iconName: string;
  sortOrder: number;
  fieldSchema: string;
}

interface Section {
  id: number;
  name: string;
  icon: string;
  vaultId: number;
}

interface Entry {
  id: number;
  categoryId: number;
  vaultId: number;
  title: string;
  fields: string;
  completionStatus: string;
  notes: string | null;
  createdAt: string;
  updatedAt: string;
}

export default function CategoryView() {
  const params = useParams<{ id: string }>();
  const categoryId = Number(params.id);
  const { state } = useVault();
  const vaultId = state.currentVaultId!;
  const [, navigate] = useLocation();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [guidanceExpanded, setGuidanceExpanded] = useState(false);

  const { data: category, isLoading: catLoading } = useQuery<Category>({
    queryKey: ["/api/category", String(categoryId)],
  });

  const { data: entries, isLoading: entriesLoading } = useQuery<Entry[]>({
    queryKey: ["/api/entries", String(categoryId), "vault", String(vaultId)],
    queryFn: async () => {
      const res = await apiRequest("GET", `/api/entries/${categoryId}?vaultId=${vaultId}`);
      return res.json();
    },
  });

  // Get parent section for breadcrumb
  const { data: allSections } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
    enabled: !!category,
  });
  const section = category ? allSections?.find((s) => s.id === category.sectionId) : undefined;

  const createEntryMutation = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", "/api/entries", {
        categoryId,
        vaultId,
        title: `New ${category?.name || "Entry"}`,
        fields: "{}",
        completionStatus: "empty",
      });
      return res.json();
    },
    onSuccess: (entry: Entry) => {
      queryClient.invalidateQueries({ queryKey: ["/api/entries", String(categoryId)] });
      queryClient.invalidateQueries({ queryKey: ["/api/entries/vault", String(vaultId)] });
      navigate(`/entry/${entry.id}`);
    },
    onError: (error: any) => {
      toast({ title: "Error", description: error.message, variant: "destructive" });
    },
  });

  const isLoading = catLoading || entriesLoading;

  // Parse fieldSchema to count fields
  const fieldSchema = category?.fieldSchema ? JSON.parse(category.fieldSchema) : null;
  const totalFields = fieldSchema?.groups?.reduce(
    (sum: number, g: any) => sum + g.fields.length,
    0
  ) || 0;

  function getFilledFieldCount(fieldsJson: string): number {
    try {
      const fields = JSON.parse(fieldsJson);
      return Object.values(fields).filter((v) => v !== "" && v !== null && v !== undefined && v !== false).length;
    } catch {
      return 0;
    }
  }

  function getFieldPreview(fieldsJson: string): string {
    try {
      const fieldData = JSON.parse(fieldsJson);
      const values = Object.values(fieldData)
        .filter((v) => v && typeof v === "string" && v.trim())
        .slice(0, 3);
      return values.join(" · ");
    } catch {
      return "";
    }
  }

  // For single-entry categories, auto-create and redirect to the entry
  if (!isLoading && category?.type === "single" && entries) {
    if (entries.length === 0) {
      // Auto-create entry for single-entry category
      if (!createEntryMutation.isPending) {
        createEntryMutation.mutate();
      }
      return (
        <AppShell title={category?.name}>
          <div className="p-4 flex items-center justify-center h-64">
            <p className="text-muted-foreground">Setting up...</p>
          </div>
        </AppShell>
      );
    }
    if (entries.length === 1) {
      navigate(`/entry/${entries[0].id}`, { replace: true });
      return null;
    }
  }

  return (
    <AppShell title={category?.name}>
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
        {/* Breadcrumb */}
        <Breadcrumb>
          <BreadcrumbList>
            <BreadcrumbItem>
              <BreadcrumbLink asChild><Link href="/dashboard">Home</Link></BreadcrumbLink>
            </BreadcrumbItem>
            <BreadcrumbSeparator />
            {section && (
              <>
                <BreadcrumbItem>
                  <BreadcrumbLink asChild><Link href={`/section/${section.id}`}>{section.name}</Link></BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
              </>
            )}
            <BreadcrumbItem>{category?.name || "..."}</BreadcrumbItem>
          </BreadcrumbList>
        </Breadcrumb>

        {isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-20 rounded-lg" />
            ))}
          </div>
        ) : (
          <>
            {/* Category guidance */}
            {category?.guidanceText && (
              <div>
                <button
                  onClick={() => setGuidanceExpanded(!guidanceExpanded)}
                  className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground"
                  data-testid="toggle-guidance"
                >
                  {guidanceExpanded ? "Hide guidance" : "Show guidance"}
                  {guidanceExpanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
                </button>
                {guidanceExpanded && (
                  <p className="text-sm text-muted-foreground mt-2 p-3 bg-muted/50 rounded-lg">{category.guidanceText}</p>
                )}
              </div>
            )}

            {/* Entry cards */}
            <div className="space-y-2">
              {entries?.map((entry) => {
                const filledCount = getFilledFieldCount(entry.fields);
                const isComplete = entry.completionStatus === "complete";

                return (
                  <Link key={entry.id} href={`/entry/${entry.id}`}>
                    <Card className="cursor-pointer hover:border-primary/30 transition-colors" data-testid={`entry-card-${entry.id}`}>
                      <CardContent className="p-4">
                        <div className="flex items-center justify-between">
                          <div className="min-w-0 flex-1">
                            <h3 className="font-medium text-sm truncate">{entry.title || "Untitled"}</h3>
                            {getFieldPreview(entry.fields) && (
                              <p className="text-xs text-muted-foreground mt-0.5 truncate">{getFieldPreview(entry.fields)}</p>
                            )}
                            <p className="text-xs text-muted-foreground mt-0.5">
                              {filledCount} of {totalFields} fields · Updated {new Date(entry.updatedAt).toLocaleDateString()}
                            </p>
                          </div>
                          {isComplete ? (
                            <Badge className="bg-green-600 text-white shrink-0">Complete</Badge>
                          ) : filledCount > 0 ? (
                            <Badge variant="outline" className="text-accent-foreground border-accent shrink-0">In Progress</Badge>
                          ) : (
                            <Badge variant="secondary" className="shrink-0">Empty</Badge>
                          )}
                        </div>
                      </CardContent>
                    </Card>
                  </Link>
                );
              })}

              {entries?.length === 0 && (
                <div className="text-center py-12 text-muted-foreground">
                  <p className="text-sm">No entries yet.</p>
                  <p className="text-xs mt-1">Tap the button below to add your first entry.</p>
                </div>
              )}
            </div>

            {/* Add entry button */}
            <Button
              onClick={() => createEntryMutation.mutate()}
              className="w-full"
              disabled={createEntryMutation.isPending}
              data-testid="add-entry-btn"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add {category?.name || "Entry"}
            </Button>
          </>
        )}
      </div>
    </AppShell>
  );
}
