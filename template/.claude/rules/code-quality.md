---
description: Code quality guardrails to prevent technical debt
globs:
  - "src/**/*.{ts,tsx}"
  - "app/**/*.{ts,tsx}"
---

# Code Quality Guardrails

## Anti-Patterns to NEVER Introduce

### 1. Cross-Feature Imports
```typescript
// FORBIDDEN — features importing from each other
import { UserCard } from '@/features/users/components/UserCard';
// Used inside features/messages/components/ChatHeader.tsx
// → Extract UserCard to shared/components/users/UserCard
```

### 2. God Components (> 200 lines)
If a component exceeds 200 lines, split it IMMEDIATELY:
- Extract sub-components
- Move styles to `styles.ts`
- Move types to `types.ts`
- Move complex logic to custom hooks

### 3. Barrel File Chains
Do NOT create barrel files (`index.ts`) that re-export from other barrels.
Import directly from the component's folder.
```typescript
// BAD — barrel chain
export { Button } from './buttons';  // buttons/index.ts re-exports from Button/index.tsx

// GOOD — direct import
import { Button } from '@/design-system/atoms/buttons/Button';
```

### 4. Dead Code Accumulation
- Delete unused imports immediately
- Delete unused components, hooks, services, types
- NEVER comment out code "for later" — use git history
- NEVER leave empty directories

### 5. Naming Collisions
Before creating any file, verify no file with the same name exists elsewhere.
Use unique, descriptive names:
```typescript
// BAD — generic name, collision risk
Card.tsx, Modal.tsx, Button.tsx (in a feature)

// GOOD — descriptive name
BookDetailCard.tsx, ShareModal.tsx, FollowButton.tsx
```

### 6. Business Logic in Design System
`design-system/` components MUST be pure UI:
- NO API calls
- NO store access
- NO business domain types (Book, User, Post)
- ONLY visual props (color, size, variant, label)

### 7. Duplicate Implementations
NEVER create a new version of something that already exists:
- Check atoms before creating a new button/input/card
- Check shared before creating a shared component
- If the existing version is 80% right, modify it — do NOT create a v2

## When Refactoring

- One change per commit — atomic, verifiable
- Run type-check after every structural change
- Update imports immediately when moving files
- Delete empty directories after moving their contents
- Verify zero consumers before deleting anything
