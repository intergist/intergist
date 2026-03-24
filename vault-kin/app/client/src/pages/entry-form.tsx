import { useState, useEffect, useRef, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Link, useLocation, useParams } from "wouter";
import { AppShell } from "@/components/AppShell";
import { FieldRenderer } from "@/components/FieldRenderer";
import { useVault } from "@/context/VaultContext";
import { apiRequest } from "@/lib/queryClient";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { useToast } from "@/hooks/use-toast";
import { Trash2, Check, Save } from "lucide-react";

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

interface Category {
  id: number;
  sectionId: number;
  name: string;
  type: string;
  guidanceText: string;
  fieldSchema: string;
}

interface Section {
  id: number;
  name: string;
  icon: string;
  vaultId: number;
}

interface FieldGroup {
  id: string;
  label: string;
  fields: Array<{
    id: string;
    label: string;
    type: string;
    priority: string;
    helpText?: string;
    placeholder?: string;
    options?: string[];
  }>;
}

export default function EntryForm() {
  const params = useParams<{ id: string }>();
  const entryId = Number(params.id);
  const { state } = useVault();
  const vaultId = state.currentVaultId!;
  const [, navigate] = useLocation();
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const [fields, setFields] = useState<Record<string, any>>({});
  const [title, setTitle] = useState("");
  const [notes, setNotes] = useState("");
  const [saveStatus, setSaveStatus] = useState<"saved" | "saving" | "unsaved">("saved");
  const saveTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const initialLoadRef = useRef(true);

  const { data: entry, isLoading: entryLoading } = useQuery<Entry>({
    queryKey: ["/api/entry", String(entryId)],
  });

  const { data: category } = useQuery<Category>({
    queryKey: ["/api/category", String(entry?.categoryId)],
    enabled: !!entry?.categoryId,
  });

  const { data: allSections } = useQuery<Section[]>({
    queryKey: ["/api/sections", String(vaultId)],
    enabled: !!category,
  });
  const section = category ? allSections?.find((s) => s.id === category.sectionId) : undefined;

  // Initialize fields from entry data
  useEffect(() => {
    if (entry && initialLoadRef.current) {
      initialLoadRef.current = false;
      try {
        setFields(JSON.parse(entry.fields || "{}"));
      } catch {
        setFields({});
      }
      setTitle(entry.title || "");
      setNotes(entry.notes || "");
    }
  }, [entry]);

  const saveMutation = useMutation({
    mutationFn: async (data: { title: string; fields: Record<string, any>; notes: string; completionStatus?: string }) => {
      setSaveStatus("saving");
      const res = await apiRequest("PUT", `/api/entries/${entryId}`, {
        title: data.title,
        fields: data.fields,
        notes: data.notes,
        completionStatus: data.completionStatus,
      });
      return res.json();
    },
    onSuccess: () => {
      setSaveStatus("saved");
      queryClient.invalidateQueries({ queryKey: ["/api/entry", String(entryId)] });
      queryClient.invalidateQueries({ queryKey: ["/api/entries"] });
      queryClient.invalidateQueries({ queryKey: ["/api/progress"] });
    },
    onError: (error: any) => {
      setSaveStatus("unsaved");
      toast({ title: "Save failed", description: error.message, variant: "destructive" });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async () => {
      await apiRequest("DELETE", `/api/entries/${entryId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/entries"] });
      queryClient.invalidateQueries({ queryKey: ["/api/entries/vault"] });
      queryClient.invalidateQueries({ queryKey: ["/api/progress"] });
      toast({ title: "Entry deleted" });
      if (category) {
        navigate(`/category/${category.id}`, { replace: true });
      } else {
        navigate("/dashboard", { replace: true });
      }
    },
    onError: (error: any) => {
      toast({ title: "Delete failed", description: error.message, variant: "destructive" });
    },
  });

  // Debounced auto-save
  const scheduleAutoSave = useCallback(
    (newFields: Record<string, any>, newTitle: string, newNotes: string) => {
      setSaveStatus("unsaved");
      if (saveTimerRef.current) clearTimeout(saveTimerRef.current);
      saveTimerRef.current = setTimeout(() => {
        saveMutation.mutate({ title: newTitle, fields: newFields, notes: newNotes });
      }, 2000);
    },
    [saveMutation]
  );

  // Parse field schema
  const fieldSchema = category?.fieldSchema ? JSON.parse(category.fieldSchema) : null;
  const groups: FieldGroup[] = fieldSchema?.groups || [];

  // Find the first required text field for auto-title derivation
  const firstRequiredTextField = groups.flatMap((g) => g.fields).find(
    (f) => f.priority === "required" && (f.type === "text" || f.type === "email")
  );

  function handleFieldChange(fieldId: string, value: any) {
    const newFields = { ...fields, [fieldId]: value };
    setFields(newFields);

    // Auto-derive title from first required field when title is still the default
    let newTitle = title;
    if (firstRequiredTextField && fieldId === firstRequiredTextField.id && value) {
      const defaultPrefix = "New ";
      if (!title || title.startsWith(defaultPrefix)) {
        newTitle = String(value);
        setTitle(newTitle);
      }
    }

    scheduleAutoSave(newFields, newTitle, notes);
  }

  function handleTitleChange(newTitle: string) {
    setTitle(newTitle);
    scheduleAutoSave(fields, newTitle, notes);
  }

  function handleNotesChange(newNotes: string) {
    setNotes(newNotes);
    scheduleAutoSave(fields, title, newNotes);
  }

  function handleMarkComplete() {
    if (saveTimerRef.current) clearTimeout(saveTimerRef.current);
    saveMutation.mutate({
      title,
      fields,
      notes,
      completionStatus: entry?.completionStatus === "complete" ? "partial" : "complete",
    });
  }

  // Calculate completion
  const totalFields = groups.reduce((sum, g) => sum + g.fields.length, 0);
  const filledFields = Object.values(fields).filter(
    (v) => v !== "" && v !== null && v !== undefined && v !== false
  ).length;

  const isLoading = entryLoading;

  if (isLoading) {
    return (
      <AppShell>
        <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-full" />
          <Skeleton className="h-64 w-full" />
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <div className="p-4 md:p-6 max-w-3xl mx-auto space-y-4">
        {/* Breadcrumb */}
        <Breadcrumb>
          <BreadcrumbList>
            <BreadcrumbItem>
              <BreadcrumbLink asChild><Link href="/dashboard">Home</Link></BreadcrumbLink>
            </BreadcrumbItem>
            {section && (
              <>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbLink asChild><Link href={`/section/${section.id}`}>{section.name}</Link></BreadcrumbLink>
                </BreadcrumbItem>
              </>
            )}
            {category && (
              <>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbLink asChild><Link href={`/category/${category.id}`}>{category.name}</Link></BreadcrumbLink>
                </BreadcrumbItem>
              </>
            )}
            <BreadcrumbSeparator />
            <BreadcrumbItem className="truncate max-w-[120px]">{title || "Entry"}</BreadcrumbItem>
          </BreadcrumbList>
        </Breadcrumb>

        {/* Header */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex-1 min-w-0">
            <Input
              value={title}
              onChange={(e) => handleTitleChange(e.target.value)}
              className="text-lg font-semibold border-0 px-0 focus-visible:ring-0 shadow-none"
              placeholder="Entry title..."
              data-testid="entry-title"
            />
          </div>
          <div className="flex items-center gap-2 shrink-0">
            {/* Save indicator */}
            <Badge
              variant="outline"
              className={`text-xs ${
                saveStatus === "saved"
                  ? "text-green-600 border-green-200"
                  : saveStatus === "saving"
                  ? "text-muted-foreground"
                  : "text-accent border-accent/30"
              }`}
            >
              {saveStatus === "saved" && <><Check className="h-3 w-3 mr-1" /> Saved</>}
              {saveStatus === "saving" && <><Save className="h-3 w-3 mr-1 animate-pulse" /> Saving...</>}
              {saveStatus === "unsaved" && "Unsaved"}
            </Badge>

            {/* Delete */}
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button variant="ghost" size="icon" className="text-destructive" data-testid="delete-entry-btn">
                  <Trash2 className="h-4 w-4" />
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Delete this entry?</AlertDialogTitle>
                  <AlertDialogDescription>
                    This action cannot be undone. All data in this entry will be permanently deleted.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction
                    onClick={() => deleteMutation.mutate()}
                    className="bg-destructive text-destructive-foreground"
                    data-testid="confirm-delete"
                  >
                    Delete
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        </div>

        {/* Completion info */}
        <p className="text-xs text-muted-foreground">
          {filledFields} of {totalFields} fields completed
          {entry?.updatedAt && ` · Last saved ${new Date(entry.updatedAt).toLocaleString()}`}
        </p>

        {/* Field groups */}
        {groups.length > 0 && (
          <Accordion type="multiple" defaultValue={groups.map((g) => g.id)} className="space-y-2">
            {groups.map((group) => (
              <AccordionItem key={group.id} value={group.id} className="border rounded-lg px-4">
                <AccordionTrigger className="py-3 text-sm font-semibold hover:no-underline" data-testid={`group-${group.id}`}>
                  {group.label}
                </AccordionTrigger>
                <AccordionContent>
                  <div className="space-y-4 pb-2">
                    {group.fields.map((field) => (
                      <FieldRenderer
                        key={field.id}
                        field={field}
                        value={fields[field.id]}
                        onChange={(value) => handleFieldChange(field.id, value)}
                      />
                    ))}
                  </div>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        )}

        {/* Notes */}
        <div className="space-y-2">
          <Label htmlFor="entry-notes" className="text-sm font-semibold">Notes</Label>
          <Textarea
            id="entry-notes"
            value={notes}
            onChange={(e) => handleNotesChange(e.target.value)}
            placeholder="Add any additional notes..."
            rows={3}
            data-testid="entry-notes"
          />
        </div>

        {/* Mark complete button */}
        <Button
          onClick={handleMarkComplete}
          variant={entry?.completionStatus === "complete" ? "outline" : "default"}
          className="w-full"
          data-testid="mark-complete-btn"
        >
          {entry?.completionStatus === "complete" ? (
            <>Mark as Incomplete</>
          ) : (
            <><Check className="h-4 w-4 mr-2" /> Mark as Complete</>
          )}
        </Button>
      </div>
    </AppShell>
  );
}
