import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Link } from "wouter";
import { AppShell } from "@/components/AppShell";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useToast } from "@/hooks/use-toast";
import { Bookmark, X } from "lucide-react";

interface BookmarkItem {
  id: number;
  vaultId: number;
  targetType: string;
  targetId: number;
  label: string;
  createdAt: string;
}

export default function BookmarksPage() {
  const { state } = useVault();
  const vaultId = state.currentVaultId!;
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: bookmarks, isLoading } = useQuery<BookmarkItem[]>({
    queryKey: ["/api/bookmarks", String(vaultId)],
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      await apiRequest("DELETE", `/api/bookmarks/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/bookmarks", String(vaultId)] });
      toast({ title: "Bookmark removed" });
    },
  });

  function getHref(bookmark: BookmarkItem): string {
    switch (bookmark.targetType) {
      case "entry": return `/entry/${bookmark.targetId}`;
      case "category": return `/category/${bookmark.targetId}`;
      case "section": return `/section/${bookmark.targetId}`;
      default: return "/dashboard";
    }
  }

  return (
    <AppShell title="Bookmarks">
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-16 rounded-lg" />
            ))}
          </div>
        ) : bookmarks && bookmarks.length > 0 ? (
          <div className="space-y-2">
            {bookmarks.map((bookmark) => (
              <Card key={bookmark.id} data-testid={`bookmark-${bookmark.id}`}>
                <CardContent className="p-3 flex items-center justify-between gap-2">
                  <Link href={getHref(bookmark)}>
                    <div className="flex items-center gap-3 cursor-pointer hover:text-primary transition-colors">
                      <Bookmark className="h-4 w-4 text-accent shrink-0" />
                      <div>
                        <p className="text-sm font-medium">{bookmark.label}</p>
                        <p className="text-xs text-muted-foreground capitalize">{bookmark.targetType}</p>
                      </div>
                    </div>
                  </Link>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="shrink-0"
                    onClick={() => deleteMutation.mutate(bookmark.id)}
                    data-testid={`remove-bookmark-${bookmark.id}`}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <Bookmark className="h-12 w-12 text-muted-foreground/30 mx-auto mb-3" />
            <p className="text-sm text-muted-foreground">No bookmarks yet.</p>
            <p className="text-xs text-muted-foreground mt-1">
              Bookmark entries, categories, or sections for quick access.
            </p>
          </div>
        )}
      </div>
    </AppShell>
  );
}
