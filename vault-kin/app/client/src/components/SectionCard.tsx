import { Link } from "wouter";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { SectionIcon } from "@/components/SectionIcon";

interface SectionCardProps {
  section: {
    id: number;
    name: string;
    icon: string;
    description: string;
    sortOrder: number;
  };
  entryCount: number;
  categoryCount: number;
  completedCategories: number;
}

export function SectionCard({ section, entryCount, categoryCount, completedCategories }: SectionCardProps) {
  const progressPercent = categoryCount > 0 ? Math.round((completedCategories / categoryCount) * 100) : 0;
  const isNew = entryCount === 0;

  return (
    <Link href={`/section/${section.id}`}>
      <Card
        className="cursor-pointer hover:border-primary/30 transition-colors"
        data-testid={`section-card-${section.id}`}
      >
        <CardContent className="p-4">
          <div className="flex items-start gap-3">
            <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
              <SectionIcon icon={section.icon} className="h-5 w-5" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h3 className="font-semibold text-sm truncate">{section.name}</h3>
                {isNew && (
                  <Badge variant="secondary" className="text-xs shrink-0">New</Badge>
                )}
                {!isNew && progressPercent < 100 && (
                  <Badge variant="outline" className="text-xs shrink-0 text-accent-foreground border-accent bg-accent/10">Continue</Badge>
                )}
              </div>
              <p className="text-xs text-muted-foreground mt-1 line-clamp-1">{section.description}</p>
              <div className="mt-2">
                <Progress value={progressPercent} className="h-1.5" />
                <p className="text-xs text-muted-foreground mt-1">
                  {entryCount} {entryCount === 1 ? "entry" : "entries"}
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
