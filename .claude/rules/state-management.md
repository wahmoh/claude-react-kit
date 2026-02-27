---
description: State management patterns for data fetching, stores, and data flow
globs:
  - "src/**/*.{ts,tsx}"
  - "app/**/*.{ts,tsx}"
---

# State Management Rules

## Data Fetching — Pages Only

```
app/feature/screen.tsx      ← useQuery, useMutation HERE
  └── FeatureScreen         ← receives data, loading, error via props
        └── FeatureList     ← receives items via props
              └── FeatureItem ← receives item via props
```

Pages orchestrate. Components render. NEVER mix these roles.

## Store Access Patterns

### Client State (Zustand/Redux/Jotai)
- Define stores in `src/core/stores/` (app-wide) or `src/features/{feature}/stores/` (feature-specific)
- Cross-feature stores go in `src/shared/stores/`
- Access stores at the page level, pass values as props to components
- Exception: deeply nested components may access stores directly ONLY for performance (e.g., avoiding prop drilling through 5+ levels)

### Server State (React Query/SWR/Apollo)
- ALL queries and mutations at the page/route level
- Create custom hooks in `features/{feature}/hooks/` that wrap useQuery
- Pages call the hooks, pass the data down as props
- NEVER call useQuery inside a component in `components/`

## Hook Organization

| Hook type | Location | Example |
|-----------|----------|---------|
| App infrastructure | `core/hooks/` | `useNavigation`, `useKeyboard`, `useAppState` |
| Feature-specific | `features/{feature}/hooks/` | `useBookSearch`, `useChatMessages` |
| Cross-feature | `shared/hooks/{domain}/` | `shared/hooks/users/useFollowUser` |

## Preventing Store/Hook Spaghetti

- A hook that imports from 2+ features → extract consumed data to `shared/`
- A store accessed by 2+ features → move to `shared/stores/`
- Circular dependencies between hooks = architectural smell → refactor immediately
