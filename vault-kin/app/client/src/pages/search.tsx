import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Link } from "wouter";
import { AppShell } from "@/components/AppShell";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Search as SearchIcon } from "lucide-react";

interface Entry {
  id: number;
  categoryId: number;
  vaultId: number;
  title: string;
  fields: string;
  notes: string | null;
  updatedAt: string;
}

export default function SearchPage() {
  const { state } = useVault();
  const vaultId = state.currentVaultId!;
  const [query, setQuery] = useState("");

  const { data: results, isLoading } = useQuery<Entry[]>({
    queryKey: ["/api/search", String(vaultId), query],
    queryFn: async () => {
      if (!query.trim() || query.trim().length < 2) return [];
      const res = await apiRequest("GET", `/api/search?vaultId=${vaultId}&q=${encodeURIComponent(query.trim())}`);
      return res.json();
    },
    enabled: query.trim().length >= 2,
  });

  function getSnippet(entry: Entry): string {
    const q = query.toLowerCase();
    // Check title
    if (entry.title.toLowerCase().includes(q)) return entry.title;
    // Check fields
    try {
      const fields = JSON.parse(entry.fields);
      for (const val of Object.values(fields)) {
        const str = String(val || "");
        if (str.toLowerCase().includes(q)) {
          const idx = str.toLowerCase().indexOf(q);
          const start = Math.max(0, idx - 20);
          const end = Math.min(str.length, idx + q.length + 20);
          return (start > 0 ? "..." : "") + str.slice(start, end) + (end < str.length ? "..." : "");
        }
      }
    } catch { /* ignore */ }
    // Check notes
    if (entry.notes?.toLowerCase().includes(q)) {
      const idx = entry.notes.toLowerCase().indexOf(q);
      const start = Math.max(0, idx - 20);
      const end = Math.min(entry.notes.length, idx + q.length + 20);
      return (start > 0 ? "..." : "") + entry.notes.slice(start, end) + (end < entry.notes.length ? "..." : "");
    }
    return entry.title;
  }

  return (
    <AppShell title="Search">
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
        <div className="relative">
          <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search your vault..."
            className="pl-9"
            autoFocus
            data-testid="search-input"
          />
        </div>

        {query.trim().length < 2 && (
          <p className="text-sm text-muted-foreground text-center py-8">
            Type at least 2 characters to search across all your entries.
          </p>
        )}

        {isLoading && query.trim().length >= 2 && (
          <p className="text-sm text-muted-foreground text-center py-8">Searching...</p>
        )}

        {results && results.length === 0 && query.trim().length >= 2 && (
          <p className="text-sm text-muted-foreground text-center py-8">
            No results found for "{query}"
          </p>
        )}

        {results && results.length > 0 && (
          <div className="space-y-2">
            <p className="text-xs text-muted-foreground">
              {results.length} {results.length === 1 ? "result" : "results"}
            </p>
            {results.map((entry) => (
              <Link key={entry.id} href={`/entry/${entry.id}`}>
                <Card className="cursor-pointer hover:border-primary/30 transition-colors" data-testid={`search-result-${entry.id}`}>
                  <CardContent className="p-3">
                    <h3 className="font-medium text-sm">{entry.title || "Untitled"}</h3>
                    <p className="text-xs text-muted-foreground mt-0.5 truncate">
                      {getSnippet(entry)}
                    </p>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}
