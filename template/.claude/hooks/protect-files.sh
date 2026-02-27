#!/bin/bash
# Pre-tool-use hook: blocks edits to protected files
# Reads tool input from stdin as JSON

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Protected file patterns — customize for your project
PROTECTED_PATTERNS=(
  ".env"
  ".env."
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "bun.lock"
  ".git/"
  "ios/Podfile.lock"
  "android/gradle.properties"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "BLOCKED: Cannot edit $FILE_PATH (matches protected pattern '$pattern'). Ask the user for permission first." >&2
    exit 2
  fi
done

exit 0
