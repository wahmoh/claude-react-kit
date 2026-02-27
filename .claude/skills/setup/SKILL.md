---
name: setup
description: Analyze the current project and install claude-react-kit customized for its actual stack, structure, and conventions
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

# claude-react-kit — Setup

You are setting up claude-react-kit in this project. Your job is to analyze the codebase, understand its real stack and conventions, and generate perfectly customized configuration files.

## Phase 1: Deep Analysis

Analyze the project thoroughly. Read and extract information from:

1. **`package.json`** — framework, dependencies, scripts, package manager (check for `packageManager` field too)
2. **Lock file** — which exists? (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lock`, `bun.lockb`)
3. **`tsconfig.json`** — path aliases, strict mode, baseUrl, target
4. **Framework config** — `next.config.*`, `vite.config.*`, `app.json`/`app.config.*` (Expo), `metro.config.*`, `remix.config.*`
5. **Linter/formatter** — `.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `biome.json`
6. **Existing `CLAUDE.md`** — if one exists, read it to preserve any project-specific rules the user already has
7. **Existing `.claude/`** — if it exists, read settings.json and any custom rules to preserve them
8. **Source directory structure** — `ls src/` or equivalent to understand the current architecture (do they already have features/, shared/, core/, design-system/, or different names?)
9. **Routing** — `ls app/` or `ls pages/` or `ls src/screens/` to understand routing structure
10. **State management patterns** — grep for store/slice/atom definitions to understand actual usage
11. **Test setup** — `jest.config.*`, `vitest.config.*`, test file patterns
12. **CI/CD** — `.github/workflows/`, check what checks run

Build a complete mental model of the project before writing anything.

## Phase 2: Ask What You Can't Detect

After analysis, present your findings to the user in a concise summary:

```
Here's what I detected:
- Framework: [X]
- Package manager: [X]
- Source structure: [describe what you found]
- State management: [X]
- Testing: [X]
- Styling: [X]
- Existing CLAUDE.md: [yes/no, summary if yes]
- Path aliases: [X]
```

Then ask ONLY about things you genuinely couldn't determine:
- If the architecture doesn't clearly match the 5-layer model, ask how they want to map their directories
- If there are conventions you noticed but aren't sure if they're intentional
- If there's an existing CLAUDE.md, ask what to keep vs replace
- Any ambiguities in their setup

Do NOT ask about things you already know from reading the code. Be efficient.

## Phase 3: Generate Files

### 3.1: CLAUDE.md

Generate a CLAUDE.md that is:
- Under 70 lines
- Has the REAL commands from their `package.json` scripts (not placeholders)
- Architecture diagram adapted to their ACTUAL directory structure and framework
- References their real path aliases
- If they had an existing CLAUDE.md, merge in any project-specific rules that don't conflict

### 3.2: .claude/settings.json

Generate settings with:
- Permission `allow` list using their ACTUAL package manager and script names
- Permission `deny` list for their sensitive files
- All hooks wired up with correct paths

### 3.3: .claude/rules/architecture.md

Customize based on their ACTUAL structure:
- Use their real directory names (not generic ones)
- If they use `app/` (Next.js/Expo), reference that as the route layer
- If they use `pages/`, `screens/`, or something else, adapt accordingly
- If they have a `lib/` or `utils/` directory, map it into the layer model
- Define boundaries based on what directories ACTUALLY exist

### 3.4: .claude/rules/components.md

Adapt to their conventions:
- If they use CSS Modules → reference `.module.css` files in the component structure
- If they use Tailwind → no separate styles file, mention className patterns
- If they use styled-components → reference `styles.ts` with styled exports
- If they use React Native StyleSheet → reference `styles.ts` with StyleSheet.create
- If they use Storybook → mention story files in component structure
- Detect their actual component size patterns and set realistic limits

### 3.5: .claude/rules/state-management.md

Customize based on what they ACTUALLY use:
- If React Query → add query key conventions, hook patterns from their code
- If Zustand → add store patterns, useShallow if they use it
- If Redux/RTK → add slice conventions, selector patterns
- If Apollo → add fragment/query patterns
- If they use multiple → document how each is used (server state vs client state)

### 3.6: .claude/rules/code-quality.md

Keep this mostly generic but adapt:
- If they use barrel files extensively, don't ban them — warn about deep chains
- If they have a monorepo, add cross-package import rules
- Match their existing lint rules (don't contradict ESLint config)

### 3.7: .claude/rules/naming-conventions.md

Extract from their ACTUAL code:
- Scan a few directories to detect whether they use PascalCase, kebab-case, or camelCase for component folders
- Check if their hooks follow `use` prefix consistently
- Check their service/API file naming
- Document what they ACTUALLY do, not an ideal — unless they ask for a migration

### 3.8: .claude/rules/session-management.md

Keep this generic — it's about Claude Code behavior, not project-specific.

### 3.9: .claude/hooks/

Generate all 4 hooks:
- `validate-architecture.sh` — use their REAL directory names in the boundary checks
- `protect-files.sh` — use their REAL lock file and framework-specific protected paths
- `post-compact-context.sh` — summarize THEIR architecture rules, not generic ones
- `pre-compact-save.sh` — this one is generic, keep as-is

### 3.10: .claude/skills/

Install both skills:
- `audit-architecture/SKILL.md` — adapt grep patterns to their real directory structure
- `scaffold-feature/SKILL.md` — adapt the scaffold to their conventions (CSS approach, test files, etc.)

## Phase 4: Present and Confirm

After generating all files, show the user a summary of what was created:
- List every file with a one-line description of what was customized
- Highlight any decisions you made that they might want to review
- Suggest they run `/audit-architecture` to see their current state

## Important Rules

- NEVER use placeholder values like `YOUR_COMMAND_HERE` — always use real detected values
- NEVER contradict their existing ESLint/Prettier configuration
- NEVER assume a directory exists — check first
- If the project doesn't have a clear layered architecture yet, set up the rules as aspirational but note this in the CLAUDE.md
- Preserve any existing `.claude/settings.local.json` — never touch it
- If `.claude/` already exists, MERGE intelligently — don't overwrite custom rules the user may have added
- Keep CLAUDE.md under 70 lines — move details to .claude/rules/
