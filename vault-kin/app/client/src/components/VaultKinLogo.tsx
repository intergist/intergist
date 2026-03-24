interface VaultKinLogoProps {
  size?: number;
  className?: string;
}

export function VaultKinLogo({ size = 48, className = "" }: VaultKinLogoProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 48 48"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-label="VaultKin logo"
    >
      {/* Shield shape */}
      <path
        d="M24 4L6 12V22C6 33.1 13.6 43.2 24 46C34.4 43.2 42 33.1 42 22V12L24 4Z"
        fill="currentColor"
        opacity="0.1"
      />
      <path
        d="M24 4L6 12V22C6 33.1 13.6 43.2 24 46C34.4 43.2 42 33.1 42 22V12L24 4Z"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      {/* Keyhole */}
      <circle
        cx="24"
        cy="22"
        r="4"
        stroke="currentColor"
        strokeWidth="2"
        fill="none"
      />
      <path
        d="M22 26L21 34H27L26 26"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}
