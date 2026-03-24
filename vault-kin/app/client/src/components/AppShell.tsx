import { type ReactNode } from "react";
import { Link, useLocation } from "wouter";
import { Home, LayoutList, Search, Bookmark, Settings } from "lucide-react";
import { useIsMobile } from "@/hooks/use-mobile";
import { VaultKinLogo } from "@/components/VaultKinLogo";
import { ThemeToggle } from "@/components/ThemeToggle";
import { PerplexityAttribution } from "@/components/PerplexityAttribution";
import { cn } from "@/lib/utils";

const tabs = [
  { href: "/dashboard", icon: Home, label: "Home" },
  { href: "/sections", icon: LayoutList, label: "Sections" },
  { href: "/search", icon: Search, label: "Search" },
  { href: "/bookmarks", icon: Bookmark, label: "Bookmarks" },
  { href: "/settings", icon: Settings, label: "Settings" },
];

interface AppShellProps {
  children: ReactNode;
  title?: string;
}

export function AppShell({ children, title }: AppShellProps) {
  const isMobile = useIsMobile();
  const [location] = useLocation();

  if (isMobile) {
    return (
      <div className="flex flex-col h-screen">
        {title && (
          <header className="flex items-center justify-between px-4 py-3 border-b bg-card">
            <h1 className="text-lg font-semibold truncate">{title}</h1>
            <ThemeToggle />
          </header>
        )}
        <main className="flex-1 overflow-y-auto">
          {children}
          <PerplexityAttribution />
        </main>
        <nav className="flex items-center justify-around border-t bg-card py-2 shrink-0" data-testid="bottom-tab-bar">
          {tabs.map((tab) => {
            const isActive = location === tab.href || (tab.href === "/dashboard" && location === "/");
            return (
              <Link key={tab.href} href={tab.href}>
                <button
                  className={cn(
                    "flex flex-col items-center gap-0.5 px-3 py-1 rounded-lg transition-colors",
                    isActive ? "text-primary" : "text-muted-foreground hover:text-foreground"
                  )}
                  data-testid={`tab-${tab.label.toLowerCase()}`}
                >
                  <tab.icon className="h-5 w-5" />
                  <span className="text-xs">{tab.label}</span>
                </button>
              </Link>
            );
          })}
        </nav>
      </div>
    );
  }

  // Desktop: sidebar + content
  return (
    <div className="flex h-screen">
      <aside className="w-64 border-r bg-card flex flex-col shrink-0" data-testid="sidebar">
        <div className="flex items-center gap-2 px-4 py-4 border-b">
          <VaultKinLogo size={32} />
          <span className="font-semibold text-lg">VaultKin</span>
        </div>
        <nav className="flex-1 py-2">
          {tabs.map((tab) => {
            const isActive = location === tab.href || (tab.href === "/dashboard" && location === "/");
            return (
              <Link key={tab.href} href={tab.href}>
                <div
                  className={cn(
                    "flex items-center gap-3 px-4 py-2.5 mx-2 rounded-lg transition-colors cursor-pointer",
                    isActive
                      ? "bg-primary text-primary-foreground"
                      : "text-muted-foreground hover:bg-muted hover:text-foreground"
                  )}
                  data-testid={`nav-${tab.label.toLowerCase()}`}
                >
                  <tab.icon className="h-5 w-5" />
                  <span className="text-sm font-medium">{tab.label}</span>
                </div>
              </Link>
            );
          })}
        </nav>
        <div className="border-t p-2">
          <ThemeToggle />
        </div>
      </aside>
      <div className="flex-1 flex flex-col overflow-hidden">
        {title && (
          <header className="flex items-center px-6 py-4 border-b bg-card shrink-0">
            <h1 className="text-lg font-semibold">{title}</h1>
          </header>
        )}
        <main className="flex-1 overflow-y-auto">
          {children}
          <PerplexityAttribution />
        </main>
      </div>
    </div>
  );
}
