#!/bin/bash
# claude-react-kit — Interactive Setup
# Detects your stack and customizes all config files for your project.
#
# Usage:
#   From your project root:
#     bash <(curl -s https://raw.githubusercontent.com/aleolidev/claude-react-kit/main/setup.sh)
#   Or clone and run:
#     bash ~/Developer/templates/claude-react-kit/setup.sh

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}$1${NC}\n"; }

ask() {
  local prompt="$1" default="$2" var_name="$3"
  if [ -n "$default" ]; then
    read -rp "$(echo -e "${BOLD}$prompt${NC} [${default}]: ")" input
    eval "$var_name=\"${input:-$default}\""
  else
    read -rp "$(echo -e "${BOLD}$prompt${NC}: ")" input
    eval "$var_name=\"$input\""
  fi
}

pick() {
  local prompt="$1" var_name="$2"
  shift 2
  local options=("$@")
  echo -e "${BOLD}$prompt${NC}"
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}"
  done
  while true; do
    read -rp "$(echo -e "${BOLD}→${NC} ")" choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
      eval "$var_name=\"${options[$((choice-1))]}\""
      return
    fi
    echo "  Invalid choice. Enter 1-${#options[@]}."
  done
}

pick_multi() {
  local prompt="$1" var_name="$2"
  shift 2
  local options=("$@")
  echo -e "${BOLD}$prompt${NC} (comma-separated, e.g., 1,3,4)"
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}"
  done
  read -rp "$(echo -e "${BOLD}→${NC} ")" choices
  local result=""
  IFS=',' read -ra selected <<< "$choices"
  for idx in "${selected[@]}"; do
    idx=$(echo "$idx" | tr -d ' ')
    if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#options[@]}" ]; then
      [ -n "$result" ] && result="$result,"
      result="$result${options[$((idx-1))]}"
    fi
  done
  eval "$var_name=\"$result\""
}

# ─── Detect source location ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

# If running from within the template repo itself, ask for target
if [ -f "$SCRIPT_DIR/README.md" ] && grep -q "claude-react-kit" "$SCRIPT_DIR/README.md" 2>/dev/null; then
  if [ "$SCRIPT_DIR" = "$PROJECT_DIR" ]; then
    error "Don't run setup inside the template repo. Run it from your project root:\n  cd /path/to/your-project && bash $SCRIPT_DIR/setup.sh"
  fi
  SOURCE_DIR="$SCRIPT_DIR"
else
  # Running via curl — download to temp
  SOURCE_DIR=$(mktemp -d)
  info "Downloading claude-react-kit..."
  git clone --quiet --depth 1 https://github.com/aleolidev/claude-react-kit.git "$SOURCE_DIR" 2>/dev/null || {
    error "Failed to clone. Check your internet connection."
  }
  trap "rm -rf '$SOURCE_DIR'" EXIT
fi

# ─── Pre-flight checks ──────────────────────────────────────────────────────
header "🔧 claude-react-kit setup"
echo "Project directory: $PROJECT_DIR"
echo ""

if [ ! -f "$PROJECT_DIR/package.json" ]; then
  warn "No package.json found. Are you in the right directory?"
  ask "Continue anyway? (y/n)" "n" CONTINUE
  [ "$CONTINUE" != "y" ] && exit 0
fi

if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
  warn "CLAUDE.md already exists."
  ask "Overwrite? (y/n)" "n" OVERWRITE_CLAUDE
  [ "$OVERWRITE_CLAUDE" != "y" ] && info "Keeping existing CLAUDE.md. Other files will still be installed."
fi

# ─── Auto-detect from package.json ──────────────────────────────────────────
header "Detecting your stack..."

PKG="$PROJECT_DIR/package.json"
DETECTED_PM="npm"
DETECTED_FRAMEWORK="unknown"
DETECTED_STATE=""
DETECTED_TEST=""
DETECTED_CSS=""
DETECTED_PLATFORM="web"

if [ -f "$PKG" ]; then
  PKG_CONTENT=$(cat "$PKG")

  # Package manager
  [ -f "$PROJECT_DIR/bun.lock" ] || [ -f "$PROJECT_DIR/bun.lockb" ] && DETECTED_PM="bun"
  [ -f "$PROJECT_DIR/pnpm-lock.yaml" ] && DETECTED_PM="pnpm"
  [ -f "$PROJECT_DIR/yarn.lock" ] && DETECTED_PM="yarn"
  [ -f "$PROJECT_DIR/package-lock.json" ] && DETECTED_PM="npm"

  # Framework
  echo "$PKG_CONTENT" | grep -q '"next"' && DETECTED_FRAMEWORK="nextjs"
  echo "$PKG_CONTENT" | grep -q '"expo"' && DETECTED_FRAMEWORK="expo"
  echo "$PKG_CONTENT" | grep -q '"react-native"' && [ "$DETECTED_FRAMEWORK" = "unknown" ] && DETECTED_FRAMEWORK="react-native"
  echo "$PKG_CONTENT" | grep -q '"vite"' && [ "$DETECTED_FRAMEWORK" = "unknown" ] && DETECTED_FRAMEWORK="vite"
  echo "$PKG_CONTENT" | grep -q '"remix"' && DETECTED_FRAMEWORK="remix"
  echo "$PKG_CONTENT" | grep -q '"gatsby"' && DETECTED_FRAMEWORK="gatsby"
  echo "$PKG_CONTENT" | grep -q '"react-scripts"' && DETECTED_FRAMEWORK="cra"

  # Platform
  case "$DETECTED_FRAMEWORK" in
    expo|react-native) DETECTED_PLATFORM="mobile" ;;
    *) DETECTED_PLATFORM="web" ;;
  esac

  # State management
  STATES=()
  echo "$PKG_CONTENT" | grep -q '"@tanstack/react-query"\|"react-query"' && STATES+=("react-query")
  echo "$PKG_CONTENT" | grep -q '"zustand"' && STATES+=("zustand")
  echo "$PKG_CONTENT" | grep -q '"@reduxjs/toolkit"\|"redux"' && STATES+=("redux")
  echo "$PKG_CONTENT" | grep -q '"jotai"' && STATES+=("jotai")
  echo "$PKG_CONTENT" | grep -q '"@apollo/client"' && STATES+=("apollo")
  echo "$PKG_CONTENT" | grep -q '"mobx"' && STATES+=("mobx")
  DETECTED_STATE=$(IFS=','; echo "${STATES[*]}")

  # Testing
  echo "$PKG_CONTENT" | grep -q '"vitest"' && DETECTED_TEST="vitest"
  echo "$PKG_CONTENT" | grep -q '"jest"' && [ -z "$DETECTED_TEST" ] && DETECTED_TEST="jest"
  echo "$PKG_CONTENT" | grep -q '"@testing-library"' && DETECTED_TEST="${DETECTED_TEST:+$DETECTED_TEST+}testing-library"

  # CSS
  echo "$PKG_CONTENT" | grep -q '"tailwindcss"' && DETECTED_CSS="tailwind"
  echo "$PKG_CONTENT" | grep -q '"styled-components"' && DETECTED_CSS="styled-components"
  echo "$PKG_CONTENT" | grep -q '"@emotion"' && DETECTED_CSS="emotion"
  echo "$PKG_CONTENT" | grep -q '"nativewind"' && DETECTED_CSS="nativewind"
  [ "$DETECTED_PLATFORM" = "mobile" ] && [ -z "$DETECTED_CSS" ] && DETECTED_CSS="stylesheet"
fi

success "Package manager: $DETECTED_PM"
success "Framework: $DETECTED_FRAMEWORK"
success "Platform: $DETECTED_PLATFORM"
[ -n "$DETECTED_STATE" ] && success "State: $DETECTED_STATE"
[ -n "$DETECTED_TEST" ] && success "Testing: $DETECTED_TEST"
[ -n "$DETECTED_CSS" ] && success "Styling: $DETECTED_CSS"

# ─── Confirm / override detections ──────────────────────────────────────────
header "Confirm your stack"

ask "Package manager" "$DETECTED_PM" PM
ask "Framework (nextjs/vite/expo/react-native/cra/remix/gatsby)" "$DETECTED_FRAMEWORK" FRAMEWORK
ask "Platform (web/mobile)" "$DETECTED_PLATFORM" PLATFORM

if [ -z "$DETECTED_STATE" ]; then
  pick_multi "State management (select all that apply)" STATE \
    "react-query" "zustand" "redux" "jotai" "apollo" "mobx" "none"
else
  ask "State management" "$DETECTED_STATE" STATE
fi

if [ -z "$DETECTED_TEST" ]; then
  ask "Testing framework (vitest/jest/none)" "vitest" TEST
else
  ask "Testing framework" "$DETECTED_TEST" TEST
fi

if [ -z "$DETECTED_CSS" ]; then
  ask "Styling (tailwind/css-modules/styled-components/emotion/stylesheet/nativewind)" "css-modules" CSS
else
  ask "Styling" "$DETECTED_CSS" CSS
fi

ask "Source directory (src/app/lib)" "src" SRC_DIR
ask "TypeScript? (y/n)" "y" USE_TS

# ─── Build the commands ──────────────────────────────────────────────────────
header "Generating configuration..."

RUN="$PM run"
[ "$PM" = "bun" ] && RUN="bun run"

# Type check command
TYPE_CMD=""
if [ "$USE_TS" = "y" ]; then
  case "$FRAMEWORK" in
    nextjs) TYPE_CMD="$RUN type-check 2>/dev/null || npx tsc --noEmit" ;;
    *)      TYPE_CMD="$RUN type-check 2>/dev/null || npx tsc --noEmit" ;;
  esac
fi

# Lint command
LINT_CMD="$RUN lint"

# Test command
TEST_CMD=""
case "$TEST" in
  vitest)  TEST_CMD="$RUN test" ;;
  jest)    TEST_CMD="$RUN test" ;;
  *)       TEST_CMD="" ;;
esac

# Build command
BUILD_CMD="$RUN build"

# Dev command
case "$FRAMEWORK" in
  nextjs)       DEV_CMD="$RUN dev" ;;
  vite)         DEV_CMD="$RUN dev" ;;
  expo)         DEV_CMD="npx expo start" ;;
  react-native) DEV_CMD="$RUN start" ;;
  cra)          DEV_CMD="$RUN start" ;;
  remix)        DEV_CMD="$RUN dev" ;;
  gatsby)       DEV_CMD="$RUN develop" ;;
  *)            DEV_CMD="$RUN dev" ;;
esac

# Protected files
LOCK_FILE="package-lock.json"
[ "$PM" = "yarn" ] && LOCK_FILE="yarn.lock"
[ "$PM" = "pnpm" ] && LOCK_FILE="pnpm-lock.yaml"
[ "$PM" = "bun" ] && LOCK_FILE="bun.lock"

EXTRA_PROTECTED=""
[ "$FRAMEWORK" = "expo" ] || [ "$FRAMEWORK" = "react-native" ] && EXTRA_PROTECTED='"ios/Podfile.lock"\n  "android/gradle.properties"'
[ "$FRAMEWORK" = "nextjs" ] && EXTRA_PROTECTED='".next/"'

# ─── Copy files ──────────────────────────────────────────────────────────────
header "Installing files..."

# Copy .claude directory
if [ -d "$PROJECT_DIR/.claude" ]; then
  warn ".claude/ directory exists. Merging (existing files preserved)."
  cp -rn "$SOURCE_DIR/.claude/" "$PROJECT_DIR/.claude/" 2>/dev/null || true
  # Overwrite rules and hooks (these are the kit's value)
  cp -r "$SOURCE_DIR/.claude/rules/" "$PROJECT_DIR/.claude/rules/"
  cp -r "$SOURCE_DIR/.claude/hooks/" "$PROJECT_DIR/.claude/hooks/"
  cp -r "$SOURCE_DIR/.claude/skills/" "$PROJECT_DIR/.claude/skills/"
  # Only overwrite settings if it doesn't exist
  [ ! -f "$PROJECT_DIR/.claude/settings.json" ] && cp "$SOURCE_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
else
  cp -r "$SOURCE_DIR/.claude" "$PROJECT_DIR/.claude"
fi
success ".claude/ directory installed"

# Copy CLAUDE.md
if [ "${OVERWRITE_CLAUDE:-y}" = "y" ]; then
  cp "$SOURCE_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
  success "CLAUDE.md installed"
fi

# Make hooks executable
chmod +x "$PROJECT_DIR/.claude/hooks/"*.sh
success "Hooks made executable"

# ─── Customize CLAUDE.md ────────────────────────────────────────────────────
header "Customizing for your stack..."

CLAUDE_FILE="$PROJECT_DIR/CLAUDE.md"

if [ "${OVERWRITE_CLAUDE:-y}" = "y" ]; then
  # Build commands section
  COMMANDS="## Commands\n\n\`\`\`bash"
  COMMANDS="$COMMANDS\n$DEV_CMD"
  [ -n "$TYPE_CMD" ] && COMMANDS="$COMMANDS\n$TYPE_CMD"
  COMMANDS="$COMMANDS\n$LINT_CMD"
  [ -n "$TEST_CMD" ] && COMMANDS="$COMMANDS\n$TEST_CMD"
  COMMANDS="$COMMANDS\n$BUILD_CMD"
  COMMANDS="$COMMANDS\n\`\`\`"

  # Replace the commands section in CLAUDE.md
  # Use a temp file approach for multi-line sed
  TEMP_CLAUDE=$(mktemp)

  awk -v cmds="$COMMANDS" '
    /^## Commands/ { found=1; next }
    /^## / && found { found=0; print; next }
    found { next }
    !found { print }
    NR==3 && !printed { printf "%b\n\n", cmds; printed=1 }
  ' "$CLAUDE_FILE" > "$TEMP_CLAUDE"

  # Simpler approach: just rebuild the file
  cat > "$CLAUDE_FILE" << CLAUDEEOF
# CLAUDE.md

## Commands

\`\`\`bash
$DEV_CMD
$([ -n "$TYPE_CMD" ] && echo "$TYPE_CMD")
$LINT_CMD
$([ -n "$TEST_CMD" ] && echo "$TEST_CMD")
$BUILD_CMD
\`\`\`

## Architecture — MANDATORY

This project follows a **layered architecture** with strict import boundaries:

\`\`\`
$(if [ "$FRAMEWORK" = "nextjs" ]; then
  echo "app/              →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/"
  echo "      ↓                    ↓                 ↓                  ↓                   ↓"
  echo "  Route handlers     Feature UI +      Cross-feature       UI primitives      App infra"
  echo "  Server actions     domain logic      reusables           (tokens, atoms)    (auth, net)"
elif [ "$FRAMEWORK" = "expo" ]; then
  echo "app/              →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/"
  echo "      ↓                    ↓                 ↓                  ↓                   ↓"
  echo "  Route screens      Feature UI +      Cross-feature       UI primitives      App infra"
  echo "  Data fetching      domain logic      reusables           (tokens, atoms)    (auth, net)"
elif [ "$FRAMEWORK" = "react-native" ]; then
  echo "screens/          →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/"
  echo "      ↓                    ↓                 ↓                  ↓                   ↓"
  echo "  Screen handlers    Feature UI +      Cross-feature       UI primitives      App infra"
  echo "  Data fetching      domain logic      reusables           (tokens, atoms)    (auth, net)"
else
  echo "pages/routes/     →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/"
  echo "      ↓                    ↓                 ↓                  ↓                   ↓"
  echo "  Data fetching      Feature UI +      Cross-feature       UI primitives      App infra"
  echo "  Route handling     domain logic      reusables           (tokens, atoms)    (auth, net)"
fi)
\`\`\`

**Import rules (NEVER violate):**
- Features NEVER import from other features
- \`core/\` has ZERO business domain awareness
- Components NEVER fetch data — they receive it via props
- Pages/routes are the ONLY place for data fetching

See \`@.claude/rules/architecture.md\` for full layer definitions.

## Component Rules

- Single responsibility: one component = one job
- Target < 100 lines, hard max 200 lines (split into subfolder)
- Functions: max 20 lines, max 3 parameters
- Use guard clauses (early returns) over nested conditionals

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Component folders | PascalCase | \`UserProfile/\` |
| Infrastructure folders | lowercase/kebab-case | \`hooks/\`, \`services/\` |
| Component files | PascalCase.tsx | \`UserCard.tsx\` |
| Hook files | camelCase.ts | \`useUserData.ts\` |
| Booleans | \`is/has/can/should\` prefix | \`isLoading\`, \`hasError\` |
| Handlers | \`handle\` + Subject + Action | \`handleFormSubmit\` |

## TypeScript

- NEVER use \`any\` — use proper types or \`unknown\`
- Use \`interface\` for objects, \`type\` for unions/primitives
- Always handle null/undefined explicitly

## Before Finishing Any Task

1. Run type-check$([ -n "$TYPE_CMD" ] && echo ": \`$TYPE_CMD\`")
2. Verify zero new errors introduced
3. Confirm no cross-feature imports were added

## Compaction Instructions

IMPORTANT: When context is compacted, always preserve:
- The complete list of files modified and their current state
- Any errors encountered and how they were resolved
- The current task scope and what remains to be done
- Which architectural layer each change belongs to
CLAUDEEOF

  rm -f "$TEMP_CLAUDE"
  success "CLAUDE.md customized for $FRAMEWORK + $PM"
fi

# ─── Customize protect-files.sh ──────────────────────────────────────────────
PROTECT_FILE="$PROJECT_DIR/.claude/hooks/protect-files.sh"
cat > "$PROTECT_FILE" << 'PROTECTEOF'
#!/bin/bash
# Pre-tool-use hook: blocks edits to protected files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

PROTECTED_PATTERNS=(
  ".env"
  ".env."
PROTECTEOF

# Add lock file
echo "  \"$LOCK_FILE\"" >> "$PROTECT_FILE"

# Add framework-specific
if [ -n "$EXTRA_PROTECTED" ]; then
  echo -e "  $EXTRA_PROTECTED" >> "$PROTECT_FILE"
fi

cat >> "$PROTECT_FILE" << 'PROTECTEOF2'
  ".git/"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "BLOCKED: Cannot edit $FILE_PATH (matches protected pattern '$pattern'). Ask the user for permission first." >&2
    exit 2
  fi
done

exit 0
PROTECTEOF2

chmod +x "$PROTECT_FILE"
success "protect-files.sh customized ($LOCK_FILE + framework-specific)"

# ─── Customize settings.json permissions ─────────────────────────────────────
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  # Update permission commands based on package manager
  if [ "$PM" != "npm" ]; then
    sed -i '' "s|npm run|$PM run|g" "$SETTINGS_FILE" 2>/dev/null || true
  fi
  if [ "$FRAMEWORK" = "expo" ]; then
    # Add expo-specific permissions
    TEMP_SETTINGS=$(mktemp)
    jq '.permissions.allow += ["Bash(npx expo start *)"]' "$SETTINGS_FILE" > "$TEMP_SETTINGS" 2>/dev/null && mv "$TEMP_SETTINGS" "$SETTINGS_FILE" || true
  fi
  success "settings.json permissions updated for $PM"
fi

# ─── Customize architecture rule based on framework ──────────────────────────
ARCH_RULE="$PROJECT_DIR/.claude/rules/architecture.md"
if [ -f "$ARCH_RULE" ]; then
  # Update the route layer description based on framework
  case "$FRAMEWORK" in
    nextjs)
      sed -i '' 's|app/pages/routes/|app/|g' "$ARCH_RULE" 2>/dev/null || true
      sed -i '' 's|Route handling|Server components + route handlers|g' "$ARCH_RULE" 2>/dev/null || true
      ;;
    expo)
      sed -i '' 's|app/pages/routes/|app/|g' "$ARCH_RULE" 2>/dev/null || true
      sed -i '' 's|Route handling|Expo Router screens|g' "$ARCH_RULE" 2>/dev/null || true
      ;;
    react-native)
      sed -i '' 's|app/pages/routes/|screens/|g' "$ARCH_RULE" 2>/dev/null || true
      sed -i '' 's|Route handling|Screen navigation|g' "$ARCH_RULE" 2>/dev/null || true
      ;;
  esac
  success "architecture.md customized for $FRAMEWORK"
fi

# ─── Add state management specifics to state-management.md ───────────────────
STATE_RULE="$PROJECT_DIR/.claude/rules/state-management.md"
if [ -f "$STATE_RULE" ] && [ -n "$STATE" ] && [ "$STATE" != "none" ]; then
  # Append framework-specific state patterns
  IFS=',' read -ra STATE_LIBS <<< "$STATE"
  ADDITIONS=""

  for lib in "${STATE_LIBS[@]}"; do
    case "$lib" in
      react-query)
        ADDITIONS="$ADDITIONS\n## React Query Patterns\n\n- Custom query hooks go in \`features/{feature}/hooks/\` or \`shared/hooks/{domain}/\`\n- Always define query keys as constants in \`constants/\`\n- Mutations at page level, pass callbacks to components\n- Use \`queryClient.invalidateQueries\` over manual refetch\n" ;;
      zustand)
        ADDITIONS="$ADDITIONS\n## Zustand Patterns\n\n- Use \`useShallow\` when selecting multiple values from a store\n- Use Immer middleware for stores with nested state\n- Feature stores in \`features/{feature}/stores/\`, shared in \`shared/stores/\`\n" ;;
      redux)
        ADDITIONS="$ADDITIONS\n## Redux Patterns\n\n- Feature slices in \`features/{feature}/store/\`\n- Shared slices in \`shared/store/\`\n- Use RTK Query for API calls, not raw thunks\n- Selectors colocated with their slice\n" ;;
      apollo)
        ADDITIONS="$ADDITIONS\n## Apollo Patterns\n\n- GraphQL queries/mutations in \`features/{feature}/graphql/\`\n- Shared fragments in \`shared/graphql/fragments/\`\n- Use code generation for typed hooks\n" ;;
    esac
  done

  if [ -n "$ADDITIONS" ]; then
    echo -e "$ADDITIONS" >> "$STATE_RULE"
    success "state-management.md enriched with $(echo $STATE | tr ',' ' ') patterns"
  fi
fi

# ─── Update .gitignore ──────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/.gitignore" ]; then
  if ! grep -q ".claude/.checkpoint.md" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    echo -e "\n# claude-react-kit\n.claude/.checkpoint.md\n.claude/settings.local.json" >> "$PROJECT_DIR/.gitignore"
    success ".gitignore updated"
  fi
else
  echo -e "# claude-react-kit\n.claude/.checkpoint.md\n.claude/settings.local.json" > "$PROJECT_DIR/.gitignore"
  success ".gitignore created"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
header "Setup complete!"

echo -e "  ${GREEN}CLAUDE.md${NC}           → Root instructions customized for ${BOLD}$FRAMEWORK${NC}"
echo -e "  ${GREEN}.claude/rules/${NC}      → 6 architecture rules (path-scoped)"
echo -e "  ${GREEN}.claude/hooks/${NC}      → 4 enforcement hooks (${BOLD}$LOCK_FILE${NC} protected)"
echo -e "  ${GREEN}.claude/skills/${NC}     → 2 reusable skills"
echo -e "  ${GREEN}.claude/settings.json${NC} → Permissions for ${BOLD}$PM${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Review CLAUDE.md and adjust commands if needed"
echo "  2. Start Claude Code and try: /audit-architecture"
echo "  3. Commit the new files: git add CLAUDE.md .claude/ && git commit -m 'chore: add claude-react-kit'"
echo ""
echo -e "${CYAN}Tip: If rules feel too strict or too loose, edit .claude/rules/ — that's the point!${NC}"
