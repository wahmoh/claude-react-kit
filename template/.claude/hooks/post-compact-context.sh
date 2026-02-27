#!/bin/bash
# Post-compaction context re-injection hook
# This runs after every context compaction to ensure critical rules survive

cat << 'CONTEXT'
=== POST-COMPACTION CRITICAL REMINDERS ===

ARCHITECTURE BOUNDARIES (NEVER violate):
- features/ NEVER imports from other features/ → extract to shared/ first
- core/ has ZERO business domain awareness → no Book, User, Post types
- design-system/ is PURE UI → no API calls, no stores, no business logic
- Components NEVER fetch data → receive via props only
- Data fetching happens ONLY at page/route level

BEFORE ANY CODE CHANGE:
1. Check existing code before creating new files
2. Verify the file goes in the correct layer
3. Follow naming conventions (PascalCase for components, kebab-case for features)
4. Components < 200 lines (split if larger)

AFTER ANY CODE CHANGE:
1. Run type-check
2. Verify no cross-feature imports added
3. Delete empty directories
4. No dead code left behind

RE-ORIENT: Run `git status` and `git log --oneline -5` to understand current state.
=== END REMINDERS ===
CONTEXT
