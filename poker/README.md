# Poker Sharp

A mobile-first Progressive Web App (PWA) for practicing Texas Hold'em board-reading skills. Based on Angel Largay's hand-reading drill methodology, Poker Sharp helps players develop rapid hand evaluation and relative hand-strength ranking abilities.

## Overview

Poker Sharp presents timed drills where players must quickly rank poker holdings from strongest to weakest given a community board. The app features equivalence grouping — holdings with identical hand strength (differing only by irrelevant suits) are grouped into equivalence classes, so players rank groups rather than individual hands.

### Key Features

- **Timed Board-Reading Drills** — Configurable drill rounds with adjustable time limits and holding counts
- **Equivalence Grouping** — Intelligent grouping of holdings into equivalence classes based on hand strength, with duplicate-class blocking in the picker UI
- **Detailed Scoring** — Class-based comparison with board texture analysis, speed ratings, and missed-class tracking
- **Dark Casino Theme** — Mobile-optimized dark UI with four-color suit indicators and gold accents
- **PWA Support** — Installable on iOS and Android with offline capability

## Project Structure

```
poker/
├── README.md                 # This file
├── docs/                     # Specifications and analysis
│   ├── poker-sharp-specification-v1.md   # Original specification (v1.0)
│   ├── poker-sharp-specification-v2.md   # Revised specification (v2.0, 12 fixes)
│   ├── spec-analysis.md                  # Critical analysis of v1.0 spec
│   └── cr001-equivalence-grouping.md     # CR-001: Equivalence grouping spec
└── src/                      # Application source code
    ├── client/               # React frontend (Vite + Tailwind + shadcn/ui)
    │   ├── index.html
    │   ├── public/           # PWA icons and manifest
    │   └── src/
    │       ├── App.tsx       # Router and state management
    │       ├── components/   # UI components (shadcn/ui)
    │       ├── hooks/        # Custom React hooks
    │       ├── lib/          # Core logic
    │       │   ├── poker.ts      # Hand evaluator + equivalence grouping engine
    │       │   ├── scoring.ts    # Scoring with group-aware matching
    │       │   ├── gameState.ts  # Types, defaults, stats helpers
    │       │   └── utils.ts      # Utility functions
    │       └── pages/        # Screen components
    │           ├── Home.tsx
    │           ├── DrillConfig.tsx
    │           ├── DrillScreen.tsx
    │           ├── Results.tsx
    │           ├── Stats.tsx
    │           └── Settings.tsx
    ├── server/               # Express server (static file serving)
    ├── shared/               # Shared TypeScript types
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    ├── tailwind.config.ts
    └── postcss.config.js
```

## Tech Stack

- **Frontend**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS + shadcn/ui component library
- **Routing**: Wouter (hash-based routing via `useHashLocation`)
- **Server**: Express (static file serving only — all game logic is client-side)
- **PWA**: Service worker with Web App Manifest for installability

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
cd poker/src
npm install
```

### Development

```bash
npm run dev
```

The app will be available at `http://localhost:5000`. Open it in a mobile browser or use Chrome DevTools device emulation (recommended width: 375–430px).

### Production Build

```bash
npm run build
```

The built assets will be in `dist/public/`.

## Specifications

| Document | Description |
|----------|-------------|
| [Specification v1.0](docs/poker-sharp-specification-v1.md) | Original application specification |
| [Spec Analysis](docs/spec-analysis.md) | Critical analysis identifying 18 issues (1 HIGH, 6 MEDIUM, 6 LOW) |
| [Specification v2.0](docs/poker-sharp-specification-v2.md) | Revised specification addressing 12 issues from the analysis |
| [CR-001: Equivalence Grouping](docs/cr001-equivalence-grouping.md) | Change request for grouping holdings by identical hand strength |

## Design

- **Mobile-first**: Max width 430px, optimized for touch interactions
- **Dark mode**: Casino-inspired dark theme (#1A1A2E background, gold accents)
- **Four-color suits**: ♠ white, ♥ red, ♦ blue, ♣ green for quick visual distinction
- **Typography**: General Sans font family

## License

Private — All rights reserved.
