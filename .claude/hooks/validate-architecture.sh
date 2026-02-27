#!/bin/bash
# Post-tool-use hook: validates architecture boundaries after file edits
# Checks that the edited file doesn't introduce cross-layer violations

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only check TypeScript/TSX files
case "$FILE_PATH" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

VIOLATIONS=""

# Rule 1: Features must not import from other features
if [[ "$FILE_PATH" == *"/features/"* ]]; then
  FEATURE_NAME=$(echo "$FILE_PATH" | sed -n 's|.*/features/\([^/]*\)/.*|\1|p')
  if [ -n "$FEATURE_NAME" ]; then
    # Check for imports from other features (not the same one)
    CROSS_IMPORTS=$(grep -n "from.*['\"]@/features/" "$FILE_PATH" 2>/dev/null | grep -v "@/features/$FEATURE_NAME" || true)
    if [ -n "$CROSS_IMPORTS" ]; then
      VIOLATIONS="$VIOLATIONS\nCROSS-FEATURE IMPORT VIOLATION in $FILE_PATH:\n$CROSS_IMPORTS\nFeatures must NEVER import from other features. Extract to shared/ first.\n"
    fi
  fi
fi

# Rule 2: design-system must not import from features or shared
if [[ "$FILE_PATH" == *"/design-system/"* ]]; then
  BAD_IMPORTS=$(grep -n "from.*['\"]@/features/\|from.*['\"]@/shared/" "$FILE_PATH" 2>/dev/null || true)
  if [ -n "$BAD_IMPORTS" ]; then
    VIOLATIONS="$VIOLATIONS\nDESIGN-SYSTEM BOUNDARY VIOLATION in $FILE_PATH:\n$BAD_IMPORTS\nDesign system must not import from features/ or shared/.\n"
  fi
fi

# Rule 3: core must not import from features, shared, or design-system (except tokens)
if [[ "$FILE_PATH" == *"/core/"* ]] && [[ "$FILE_PATH" != *"/core/i18n/"* ]]; then
  BAD_IMPORTS=$(grep -n "from.*['\"]@/features/\|from.*['\"]@/shared/" "$FILE_PATH" 2>/dev/null || true)
  if [ -n "$BAD_IMPORTS" ]; then
    VIOLATIONS="$VIOLATIONS\nCORE BOUNDARY VIOLATION in $FILE_PATH:\n$BAD_IMPORTS\nCore must not import from features/ or shared/.\n"
  fi
fi

if [ -n "$VIOLATIONS" ]; then
  echo -e "ARCHITECTURE VIOLATIONS DETECTED:$VIOLATIONS" >&2
  echo "Fix these violations before continuing." >&2
  # Exit 0 to not block, but the message will be visible as feedback
  exit 0
fi

exit 0
