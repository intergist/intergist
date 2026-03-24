import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import { CalendarIcon } from "lucide-react";
import { SecureField } from "@/components/SecureField";
import { format } from "date-fns";
import { cn } from "@/lib/utils";

interface FieldDef {
  id: string;
  label: string;
  type: string;
  priority: string;
  helpText?: string;
  placeholder?: string;
  options?: string[];
}

interface FieldRendererProps {
  field: FieldDef;
  value: any;
  onChange: (value: any) => void;
}

export function FieldRenderer({ field, value, onChange }: FieldRendererProps) {
  const isRequired = field.priority === "required";
  const isMuted = field.priority === "optional";

  const labelClass = cn(
    "text-sm",
    isRequired && "font-semibold",
    isMuted && "text-muted-foreground"
  );

  return (
    <div className="space-y-1.5" data-testid={`field-${field.id}`}>
      {field.type !== "toggle" && (
        <Label htmlFor={field.id} className={labelClass}>
          {field.label}
          {isRequired && <span className="text-destructive ml-1">*</span>}
        </Label>
      )}

      {renderInput(field, value, onChange)}

      {field.helpText && (
        <p className="text-xs text-muted-foreground">{field.helpText}</p>
      )}
    </div>
  );
}

function renderInput(field: FieldDef, value: any, onChange: (value: any) => void) {
  switch (field.type) {
    case "text":
      return (
        <Input
          id={field.id}
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder}
          data-testid={`input-${field.id}`}
        />
      );

    case "secureText":
      return (
        <SecureField
          id={field.id}
          value={value || ""}
          onChange={onChange}
          placeholder={field.placeholder}
          data-testid={`input-${field.id}`}
        />
      );

    case "number":
      return (
        <Input
          id={field.id}
          type="number"
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder}
          data-testid={`input-${field.id}`}
        />
      );

    case "currency":
      return (
        <div className="relative">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground text-sm">$</span>
          <Input
            id={field.id}
            type="number"
            value={value || ""}
            onChange={(e) => onChange(e.target.value)}
            placeholder={field.placeholder || "0.00"}
            className="pl-7"
            step="0.01"
            data-testid={`input-${field.id}`}
          />
        </div>
      );

    case "date":
      return <DatePickerField field={field} value={value} onChange={onChange} />;

    case "dropdown":
      return (
        <Select value={value || ""} onValueChange={onChange}>
          <SelectTrigger id={field.id} data-testid={`input-${field.id}`}>
            <SelectValue placeholder={field.placeholder || "Select..."} />
          </SelectTrigger>
          <SelectContent>
            {(field.options || []).map((opt) => (
              <SelectItem key={opt} value={opt}>{opt}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      );

    case "toggle":
      return (
        <div className="flex items-center justify-between">
          <Label htmlFor={field.id} className="text-sm cursor-pointer">
            {field.label}
          </Label>
          <Switch
            id={field.id}
            checked={!!value}
            onCheckedChange={onChange}
            data-testid={`input-${field.id}`}
          />
        </div>
      );

    case "multiline":
      return (
        <Textarea
          id={field.id}
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder}
          rows={4}
          data-testid={`input-${field.id}`}
        />
      );

    case "phone":
      return (
        <Input
          id={field.id}
          type="tel"
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder || "(555) 123-4567"}
          data-testid={`input-${field.id}`}
        />
      );

    case "email":
      return (
        <Input
          id={field.id}
          type="email"
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder || "email@example.com"}
          data-testid={`input-${field.id}`}
        />
      );

    case "url":
      return (
        <Input
          id={field.id}
          type="url"
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder || "https://"}
          data-testid={`input-${field.id}`}
        />
      );

    default:
      return (
        <Input
          id={field.id}
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
          placeholder={field.placeholder}
          data-testid={`input-${field.id}`}
        />
      );
  }
}

function DatePickerField({ field, value, onChange }: { field: FieldDef; value: any; onChange: (val: any) => void }) {
  const [open, setOpen] = useState(false);
  const dateValue = value ? new Date(value) : undefined;

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          id={field.id}
          variant="outline"
          className={cn(
            "w-full justify-start text-left font-normal",
            !value && "text-muted-foreground"
          )}
          data-testid={`input-${field.id}`}
        >
          <CalendarIcon className="mr-2 h-4 w-4" />
          {dateValue ? format(dateValue, "PPP") : (field.placeholder || "Pick a date")}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0" align="start">
        <Calendar
          mode="single"
          selected={dateValue}
          onSelect={(date) => {
            onChange(date ? date.toISOString().split("T")[0] : "");
            setOpen(false);
          }}
          initialFocus
        />
      </PopoverContent>
    </Popover>
  );
}
