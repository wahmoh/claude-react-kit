---
name: scaffold-feature
description: Create a new feature module with the standard directory structure
user-invocable: true
allowed-tools: Bash, Write
---

# Scaffold Feature

Create a new feature module at `src/features/$ARGUMENTS/` with the standard structure:

```bash
mkdir -p src/features/$ARGUMENTS/{components,hooks,services,types,constants,stores,locales,assets}
```

Create starter files:

1. `src/features/$ARGUMENTS/locales/en.json` — empty i18n object `{}`
2. `src/features/$ARGUMENTS/locales/es.json` — empty i18n object `{}`
3. `src/features/$ARGUMENTS/types/index.ts` — empty types file
4. `src/features/$ARGUMENTS/constants/index.ts` — feature endpoints and query keys

Use kebab-case for the feature directory name.
Confirm the feature name doesn't conflict with existing features.
After creation, remind the user to register the locale files in the i18n aggregator.
