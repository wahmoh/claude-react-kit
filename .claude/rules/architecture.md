---
description: Enforces layered architecture boundaries for all source code
globs:
  - "src/**/*.{ts,tsx}"
  - "app/**/*.{ts,tsx}"
---

# Architecture Boundaries — MANDATORY

## Layer Definitions

### 1. `src/core/` — App Infrastructure (ZERO domain awareness)

Contains ONLY:
- Auth (login, tokens, session)
- Networking (HTTP client, interceptors, error handling)
- i18n (locale loading, translation provider)
- Navigation (router config, tab definitions)
- Providers (React context providers for app-level concerns)
- App-wide stores (theme, splash, deep link — NOT domain stores)
- App-wide hooks (keyboard, dimensions, app state — NOT domain hooks)

**RULE: If a file imports a domain type (Book, User, Post, etc.) it does NOT belong in core/.**

### 2. `src/design-system/` — UI Primitives (ZERO business logic)

Contains:
- `tokens/` — Colors, Typography, Spacing, Fonts
- `icons/` — SVG icon components (pure, no logic)
- `atoms/` — Reusable UI primitives (Button, Input, Card, Modal, etc.)
- `containers/` — Layout wrappers (Footer, Topbar, Wrapper)
- `assets/` — Shared images/fonts
- `locales/` — Design system translations

**RULE: Atoms are PURE UI. No API calls, no stores, no business logic. Only visual props (color, size, variant).**

### 3. `src/shared/` — Cross-Feature Reusables

For code used by 2+ features. Organized by type:
- `components/` — Shared UI grouped by domain (`books/`, `users/`, `sheets/`, etc.)
- `hooks/` — Cross-feature hooks grouped by domain
- `services/` — Cross-feature API services
- `types/` — Cross-feature TypeScript types
- `constants/` — Cross-feature constants (endpoints, query keys, screens)
- `stores/` — Cross-feature Zustand stores
- `assets/` — Cross-feature images/media

### 4. `src/features/{feature}/` — Feature Modules (INDEPENDENT)

Each feature is a self-contained module:
```
features/{feature}/
├── components/     # Feature-specific UI
│   └── {Screen}/   # Grouped by screen
├── hooks/          # Feature-specific hooks
├── services/       # Feature-specific API calls
├── types/          # Feature-specific types
├── constants/      # Feature-specific constants
├── stores/         # Feature-specific stores
├── locales/        # Feature translations (en.json, es.json)
└── assets/         # Feature-specific images
```

### 5. `app/` (or `pages/`) — Route Handlers

The ONLY place where:
- Data is fetched (useQuery, useMutation)
- Stores are accessed
- Props are assembled and passed to feature components

## Import Direction (NEVER violate)

```
app/ → features/ → shared/ → design-system/ → core/
 ↓         ↓          ↓            ↓              ↓
Can import everything below it. NEVER import from same level or above.
```

**Specifically:**
- `features/A/` NEVER imports from `features/B/` — extract to `shared/` first
- `shared/` NEVER imports from `features/`
- `design-system/` NEVER imports from `shared/` or `features/`
- `core/` NEVER imports from any other layer

## When to Move Code to `shared/`

Move to shared when:
- A type, hook, service, or component is needed by 2+ features
- You are tempted to import from another feature

NEVER create a "junk drawer" — always place shared code in a domain subdirectory:
```
shared/components/books/       NOT  shared/BookPicture/
shared/hooks/users/            NOT  shared/useFollowUser.ts (flat)
```
