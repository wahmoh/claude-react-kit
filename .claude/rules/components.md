---
description: Component structure, data flow, and organization rules
globs:
  - "src/**/components/**/*.{ts,tsx}"
  - "src/design-system/**/*.{ts,tsx}"
---

# Component Rules — MANDATORY

## Folder Structure

Every component with > 1 file MUST use folder structure:

```
ComponentName/
├── index.tsx       # Main component (< 100 lines target)
├── types.ts        # Props & types
├── styles.ts       # StyleSheet / styled-components / CSS modules
├── SubComponent.tsx # Sub-components if needed
└── assets/         # Local assets (optional)
```

Single-file components (< 50 lines with no styles) MAY remain as standalone `.tsx` files.

## Data Architecture — NEVER VIOLATE

Components NEVER fetch data. Components ONLY receive data via props.

```typescript
// FORBIDDEN in components
const Component = () => {
  const { data } = useQuery(['key'], fetchData);   // NO
  const mutation = useMutation(postData);           // NO
  const state = useStore(s => s.data);              // NO
};

// REQUIRED — receive via props
interface ComponentProps {
  data: Data[];
  isLoading?: boolean;
  error?: Error;
  onRefresh?: () => void;
  onItemPress?: (item: Item) => void;
}
```

Data fetching happens ONLY at the page/route level (`app/` or `pages/`).

## Size Limits

| Type | Target | Hard Maximum | Action at Maximum |
|------|--------|-------------|-------------------|
| Component | < 100 lines | 200 lines | Split into subfolder |
| Function | < 20 lines | 20 lines | Extract helper |
| Parameters | ≤ 3 | 3 | Use options object |

## Prop Design

- Pass specific props, NOT entire objects
- Boolean props: `isActive`, NOT `active`
- Callbacks: `onItemPress`, NOT `pressHandler`
- Always define explicit TypeScript interface for props

## Preventing Duplication

BEFORE creating any new component:
1. Search for existing components with similar names or purpose
2. Check `design-system/atoms/` for UI primitives
3. Check `shared/components/` for cross-feature components
4. If > 70% similar to existing, extend or wrap it — do NOT duplicate

## Preventing "Junk Drawer" Directories

Components that belong to a specific feature go in `features/{feature}/components/`.
Components used by 2+ features go in `shared/components/{domain}/`.
Pure UI atoms with no business logic go in `design-system/atoms/{category}/`.

NEVER put components at the root of `shared/` without a domain subdirectory.
