---
description: Enforces consistent naming across the entire codebase
globs:
  - "src/**"
  - "app/**"
---

# Naming Conventions — MANDATORY

## Directory Names

| Type | Convention | Examples |
|------|-----------|---------|
| Component directories | PascalCase | `UserProfile/`, `BookCard/`, `SearchBar/` |
| Feature modules | kebab-case | `features/book-view/`, `features/edit-profile/` |
| Infrastructure dirs | lowercase | `hooks/`, `services/`, `types/`, `stores/`, `constants/` |
| Domain groupings | lowercase | `shared/components/books/`, `shared/hooks/users/` |
| Design system categories | lowercase | `atoms/buttons/`, `atoms/inputs/` |

## File Names

| Type | Convention | Examples |
|------|-----------|---------|
| Components | PascalCase.tsx | `UserCard.tsx`, `BookList.tsx` |
| Hooks | camelCase.ts (use prefix) | `useUserData.ts`, `useBookSearch.ts` |
| Services | PascalCase.ts | `GetUserService.ts`, `CreateBookService.ts` |
| Types/interfaces | camelCase.ts | `userTypes.ts`, `bookTypes.ts` |
| Constants | PascalCase.ts | `UserEndpoints.ts`, `BookQueryKeys.ts` |
| Stores | camelCase.ts (use prefix) | `useBookStore.ts`, `useAuthStore.ts` |
| Utilities | camelCase.ts | `formatDate.ts`, `validateEmail.ts` |
| Styles | styles.ts | Always `styles.ts` inside component folders |
| Barrel exports | index.ts/index.tsx | Only in component folders |

## Preventing Naming Chaos

BEFORE creating any new directory or file:
1. Check existing naming patterns in the target directory
2. Follow the convention already established there
3. If no convention exists, apply the rules above
4. NEVER mix camelCase and kebab-case in the same directory level
5. NEVER create duplicate folders with different casings (e.g., `mostAlive/` and `most-alive/`)

## Variable & Function Naming

| Type | Convention | Examples |
|------|-----------|---------|
| Booleans | `is/has/can/should` prefix | `isLoading`, `hasError`, `canSubmit` |
| Event handlers | `handle` + Subject + Action | `handleFormSubmit`, `handleUserPress` |
| Callbacks (props) | `on` + Subject + Action | `onItemPress`, `onFormSubmit` |
| Async functions | Descriptive verb | `fetchUsers`, `createBook`, `deleteComment` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| Enums | PascalCase | `UserRole`, `BookStatus` |
