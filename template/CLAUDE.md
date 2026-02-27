# CLAUDE.md

## Commands

```bash
# Replace these with your project's actual commands
npm run type-check     # TypeScript verification
npm run lint           # Linting (zero warnings allowed)
npm run test           # Run tests
npm run build          # Production build
```

## Architecture — MANDATORY

This project follows a **layered architecture** with strict import boundaries:

```
app/pages/routes/  →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/
      ↓                    ↓                 ↓                  ↓                   ↓
  Data fetching      Feature UI +      Cross-feature       UI primitives      App infra
  Route handling     domain logic      reusables           (tokens, atoms)    (auth, net, i18n)
```

**Import rules (NEVER violate):**
- Features NEVER import from other features
- `core/` has ZERO business domain awareness
- Components NEVER fetch data — they receive it via props
- Pages/routes are the ONLY place for data fetching

See `@.claude/rules/architecture.md` for full layer definitions.

## Component Rules

- Single responsibility: one component = one job
- Target < 100 lines, hard max 200 lines (split into subfolder)
- Functions: max 20 lines, max 3 parameters
- Use guard clauses (early returns) over nested conditionals

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Component folders | PascalCase | `UserProfile/` |
| Infrastructure folders | lowercase/kebab-case | `hooks/`, `shared/services/` |
| Component files | PascalCase.tsx | `UserCard.tsx` |
| Hook files | camelCase.ts | `useUserData.ts` |
| Type/const files | camelCase.ts | `userTypes.ts` |
| Booleans | `is/has/can/should` prefix | `isLoading`, `hasError` |
| Handlers | `handle` + Subject + Action | `handleFormSubmit` |

## TypeScript

- NEVER use `any` — use proper types or `unknown`
- Use `interface` for objects, `type` for unions/primitives
- Always handle null/undefined explicitly

## Before Finishing Any Task

1. Run type-check: `npm run type-check`
2. Verify zero new errors introduced
3. Confirm no cross-feature imports were added

## Compaction Instructions

IMPORTANT: When context is compacted, always preserve:
- The complete list of files modified and their current state
- Any errors encountered and how they were resolved
- The current task scope and what remains to be done
- Which architectural layer each change belongs to
