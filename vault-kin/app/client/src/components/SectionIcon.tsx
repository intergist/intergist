import {
  Rocket, Home, Car, Landmark, Shield, TrendingUp, CreditCard,
  Briefcase, Building2, Users, BookOpen, Heart, Globe, Scale,
  Sunset, FileKey, HandHeart, type LucideProps, HelpCircle,
  HeartPulse, FolderLock, Gem,
} from "lucide-react";

const iconMap: Record<string, React.FC<LucideProps>> = {
  Rocket,
  Home,
  Car,
  Landmark,
  Shield,
  TrendingUp,
  CreditCard,
  Briefcase,
  Building2,
  Users,
  BookOpen,
  Heart,
  HeartPulse,
  Globe,
  Scale,
  Sunset,
  FileKey,
  FolderLock,
  HandHeart,
  Gem,
  HelpCircle,
};

interface SectionIconProps extends LucideProps {
  icon: string;
}

export function SectionIcon({ icon, ...props }: SectionIconProps) {
  const IconComponent = iconMap[icon] || HelpCircle;
  return <IconComponent {...props} />;
}
