# claude-react-kit

> Drop-in Claude Code configuration that enforces clean architecture, prevents technical debt, and survives context compaction — for any React project.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-blueviolet)](https://claude.ai/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## The Problem

Claude Code writes great code — until it doesn't. In long sessions:

- **Context compaction loses your rules** — Claude "forgets" architecture decisions after compacting
- **No boundary enforcement** — features import from each other, business logic leaks into UI primitives, `core/` becomes a junk drawer
- **Duplicate code accumulates** — new components get created instead of reusing existing ones
- **Naming conventions drift** — camelCase, kebab-case, and PascalCase mixed in the same directory
- **Quality degrades silently** — no type-check verification, no architectural validation

This kit was born from a **160+ commit, 4,377-file architectural refactor** where every one of these anti-patterns was encountered and painfully resolved. We packaged the lessons so you never have to do the same.

## The Solution

`CLAUDE.md` + `.claude/` configuration files that work together:

| Layer | What | How |
|-------|------|-----|
| `CLAUDE.md` | Concise root instructions (< 70 lines) | Re-read from disk every session and after compaction |
| `.claude/rules/` | Detailed, path-scoped architecture rules | Loaded contextually per file type |
| `.claude/hooks/` | Deterministic enforcement scripts | Run automatically on every edit |
| `.claude/skills/` | Reusable workflows | Invoked on-demand via `/skill-name` |
| `.claude/settings.json` | Hook wiring + permissions | Connects everything together |

**Key insight**: CLAUDE.md is *advisory* (Claude should follow it). Hooks are *deterministic* (they always run). Critical rules go in both.

## Setup

### 1. Copy the kit into your project

```bash
git clone https://github.com/aleolidev/claude-react-kit.git /tmp/crk
cp /tmp/crk/CLAUDE.md ./CLAUDE.md
cp -r /tmp/crk/.claude/ ./.claude/
chmod +x .claude/hooks/*.sh
echo -e "\n.claude/.checkpoint.md\n.claude/settings.local.json" >> .gitignore
rm -rf /tmp/crk
```

### 2. Run the setup skill

Open Claude Code in your project and run:

```
/setup
```

Claude will:
1. **Analyze your project** — reads `package.json`, `tsconfig.json`, framework configs, source directory structure, existing lint/format rules, state management patterns, and any existing `CLAUDE.md`
2. **Present what it found** — framework, package manager, directory structure, state management, testing, styling
3. **Ask only what it can't detect** — ambiguous conventions, architecture mapping preferences, what to keep from existing config
4. **Generate customized files** — every rule, hook, and config file adapted to your real project:
   - `CLAUDE.md` with your actual build commands and real directory structure
   - `architecture.md` with your actual layer names and import boundaries
   - `components.md` adapted to your styling approach (Tailwind, CSS Modules, StyleSheet, styled-components)
   - `state-management.md` with patterns for your actual libraries
   - `naming-conventions.md` extracted from your actual code conventions
   - `validate-architecture.sh` using your real directory names
   - `protect-files.sh` with your lock file and framework-specific patterns
   - `settings.json` with permissions for your package manager
   - `audit-architecture/SKILL.md` with grep patterns matching your structure
   - `scaffold-feature/SKILL.md` adapted to your conventions

No placeholders, no manual editing. Everything matches your project as it actually is.

## Architecture Enforced

```
app/pages/routes/  →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/
      ↓                    ↓                 ↓                  ↓                   ↓
  Data fetching      Feature UI +      Cross-feature       UI primitives      App infra
  Route handling     domain logic      reusables           (tokens, atoms)    (auth, net)
```

Each layer can only import from layers to its right. Never left, never sideways between features.

The `/setup` skill adapts this to your actual structure — if you use `app/` (Next.js/Expo), `pages/`, `screens/`, or something else entirely.

## What's Inside

### Rules (`.claude/rules/`)

| File | Enforces |
|------|----------|
| `architecture.md` | Layer import boundaries, what belongs where, when to extract to shared |
| `components.md` | Folder structure, data flow (props-only), size limits, deduplication |
| `code-quality.md` | 7 anti-patterns: cross-imports, god components, barrel chains, dead code, naming collisions, business logic in design system, duplicate implementations |
| `naming-conventions.md` | Consistent naming per file/directory type |
| `state-management.md` | Data fetching at page level, stores by scope, library-specific patterns |
| `session-management.md` | Post-compaction re-orientation protocol, quality invariants |

All rules support **path-scoping** via frontmatter globs — they only activate when Claude edits matching files.

### Hooks (`.claude/hooks/`)

| Hook | Trigger | Action |
|------|---------|--------|
| `validate-architecture.sh` | After every file edit | Catches cross-feature imports, design-system impurity, core boundary leaks |
| `post-compact-context.sh` | After context compaction | Re-injects critical architecture rules Claude would otherwise forget |
| `pre-compact-save.sh` | Before compaction | Saves git state checkpoint (branch, commits, modified files) |
| `protect-files.sh` | Before file edits | Blocks edits to `.env`, lock files, and configurable patterns |
| Stop hook (prompt) | Before Claude finishes | Blocks completion if code changed but type-check wasn't run |

### Skills (`.claude/skills/`)

| Skill | Usage | Action |
|-------|-------|--------|
| `setup` | `/setup` | Analyze project and customize all config files for the real stack |
| `audit-architecture` | `/audit-architecture` | Full codebase audit: cross-imports, oversized files, empty dirs, data fetching violations |
| `scaffold-feature` | `/scaffold-feature user-profile` | Create a new feature module with the standard structure |

## How Compaction Resilience Works

When Claude Code compacts context in a long session:

```
1. PreCompact hook     →  Saves git state to .checkpoint.md
2. Context compacted   →  Conversation history summarized (detail lost)
3. CLAUDE.md re-read   →  Root instructions survive verbatim (from disk)
4. .claude/rules/      →  All detailed rules survive (from disk)
5. SessionStart hook   →  Fires on "compact" event, injects critical reminders:
                           • Architecture boundaries (5 rules that must never break)
                           • Pre/post change checklist
                           • Re-orientation: git status + git log
```

Result: consistent quality even after multiple compactions in marathon sessions.

## What Gets Installed

```
your-project/
├── CLAUDE.md                              # Root instructions (< 70 lines)
└── .claude/
    ├── settings.json                      # Hooks + permissions
    ├── rules/
    │   ├── architecture.md                # Layer boundaries
    │   ├── components.md                  # Component patterns
    │   ├── code-quality.md                # Anti-patterns
    │   ├── naming-conventions.md          # Naming rules
    │   ├── state-management.md            # Data flow
    │   └── session-management.md          # Compaction resilience
    ├── hooks/
    │   ├── post-compact-context.sh        # Post-compaction re-injection
    │   ├── pre-compact-save.sh            # Pre-compaction checkpoint
    │   ├── protect-files.sh               # File protection
    │   └── validate-architecture.sh       # Import boundary validation
    └── skills/
        ├── setup/SKILL.md                 # Project analyzer + customizer
        ├── audit-architecture/SKILL.md    # Architecture auditor
        └── scaffold-feature/SKILL.md      # Feature scaffolder
```

## Customization

### Add project-specific rules

Create new `.md` files in `.claude/rules/` with path-scoped frontmatter:

```markdown
---
description: API patterns for this project
globs:
  - "src/features/**/services/**"
---

# API Rules
- All services use the shared HTTP client from core/network/
- Service files: `{Verb}{Resource}Service.ts`
```

### Personal overrides

Create `.claude/settings.local.json` (gitignored) for personal preferences.

## Best Practices for Long Sessions

1. **One task per session** — don't context-switch mid-session
2. **`/clear` between tasks** — fresh context > bloated context
3. **Manual compact at 70%**: `/compact Focus on [specific task]`
4. **Subagents for research** — keeps exploration out of main context
5. **Commit after each logical unit** — atomic checkpoints
6. **Never give verbal rules** — if you repeat it, add it to `.claude/rules/`

## Compatibility

| | Supported |
|---|---|
| **React Web** | Next.js, Vite, CRA, Remix, Gatsby |
| **React Native** | Expo, React Native CLI |
| **Package Managers** | npm, yarn, pnpm, bun |
| **State Management** | React Query, Zustand, Redux, Jotai, Apollo, MobX |
| **TypeScript** | Required (type-check enforcement) |
| **Claude Code** | v1.0+ |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Areas where help is needed:

- Vue.js / Svelte / Angular adaptations
- Backend rule sets (Node.js, Python, Go)
- Additional hooks for CI/CD patterns

## License

[MIT](LICENSE)

---

**Built with hard-won lessons from production React Native and Next.js projects.**

If this saved you from a painful refactor, consider giving it a star.
