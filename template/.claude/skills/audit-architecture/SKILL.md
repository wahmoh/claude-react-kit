---
name: audit-architecture
description: Audit the codebase for architecture violations and organizational issues
user-invocable: true
allowed-tools: Read, Bash, Grep, Glob, Task
---

# Architecture Audit

Perform a comprehensive audit of the codebase architecture. Check for:

## 1. Cross-Feature Imports

Search for any feature importing from another feature:
```bash
grep -rn "from.*@/features/" src/features/ --include="*.ts" --include="*.tsx" | while read line; do
  FILE=$(echo "$line" | cut -d: -f1)
  FEATURE=$(echo "$FILE" | sed -n 's|.*/features/\([^/]*\)/.*|\1|p')
  IMPORT=$(echo "$line" | grep -o "@/features/[^/]*" | sed 's|@/features/||')
  if [ "$FEATURE" != "$IMPORT" ]; then
    echo "VIOLATION: $line"
  fi
done
```

## 2. Core Domain Leakage

Check if core/ imports from features/ or shared/:
```bash
grep -rn "from.*@/features/\|from.*@/shared/" src/core/ --include="*.ts" --include="*.tsx"
```

## 3. Design System Purity

Check if design-system/ has business logic imports:
```bash
grep -rn "from.*@/features/\|from.*@/shared/" src/design-system/ --include="*.ts" --include="*.tsx"
```

## 4. Oversized Files

Find files exceeding 200 lines:
```bash
find src/ -name "*.tsx" -o -name "*.ts" | xargs wc -l | sort -rn | head -20
```

## 5. Empty Directories

```bash
find src/ -type d -empty
```

## 6. Duplicate Naming

Search for potential duplicate folders/files with different casings.

## 7. Components Fetching Data

Search for useQuery/useMutation inside component directories (not pages):
```bash
grep -rn "useQuery\|useMutation" src/features/*/components/ src/shared/components/ src/design-system/ --include="*.tsx"
```

Report all violations found with specific file paths and recommended fixes.
