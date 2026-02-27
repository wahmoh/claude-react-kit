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

A set of `CLAUDE.md` + `.claude/` configuration files that work together:

| Layer | What | How |
|-------|------|-----|
| `CLAUDE.md` | Concise root instructions (< 70 lines) | Re-read from disk every session and after compaction |
| `.claude/rules/` | Detailed, path-scoped architecture rules | Loaded contextually per file type |
| `.claude/hooks/` | Deterministic enforcement scripts | Run automatically on every edit |
| `.claude/skills/` | Reusable workflows | Invoked on-demand via `/skill-name` |
| `.claude/settings.json` | Hook wiring + permissions | Connects everything together |

**Key insight**: CLAUDE.md is *advisory* (Claude should follow it). Hooks are *deterministic* (they always run). Critical rules go in both.

## Quick Start

### Interactive setup (recommended)

Run from your project root. Auto-detects your stack (framework, package manager, state management, testing) and customizes every file:

```bash
# From your project root:
bash <(curl -s https://raw.githubusercontent.com/aleolidev/claude-react-kit/main/setup.sh)
```

Or if you have the repo cloned locally:

```bash
cd /path/to/your-project
bash ~/Developer/templates/claude-react-kit/setup.sh
```

The setup will:
1. Detect your framework (Next.js, Vite, Expo, React Native, CRA, Remix, Gatsby)
2. Detect your package manager, state management, testing framework, and styling
3. Let you confirm or override each detection
4. Generate a customized `CLAUDE.md` with your actual build commands
5. Configure `protect-files.sh` with your lock file and framework-specific patterns
6. Update `settings.json` permissions for your package manager
7. Enrich `state-management.md` with patterns for your specific libraries
8. Adapt `architecture.md` route layer for your framework

### Manual setup

```bash
git clone https://github.com/aleolidev/claude-react-kit.git /tmp/crk

cp /tmp/crk/CLAUDE.md ./CLAUDE.md
cp -r /tmp/crk/.claude/ ./.claude/
chmod +x .claude/hooks/*.sh

echo -e ".claude/.checkpoint.md\n.claude/settings.local.json" >> .gitignore

rm -rf /tmp/crk

# Then edit CLAUDE.md with your actual build commands
```

## Architecture Enforced

```
app/pages/routes/  →  src/features/  →  src/shared/  →  src/design-system/  →  src/core/
      ↓                    ↓                 ↓                  ↓                   ↓
  Data fetching      Feature UI +      Cross-feature       UI primitives      App infra
  Route handling     domain logic      reusables           (tokens, atoms)    (auth, net)
```

Each layer can only import from layers to its right. Never left, never sideways between features.

## What's Inside

### Rules (`.claude/rules/`)

| File | Enforces |
|------|----------|
| `architecture.md` | 5-layer import boundaries, what belongs in each layer, when to extract to shared |
| `components.md` | Folder structure, data flow (props-only), size limits (< 200 lines), deduplication |
| `code-quality.md` | 7 anti-patterns: cross-imports, god components, barrel chains, dead code, naming collisions, business logic in design system, duplicate implementations |
| `naming-conventions.md` | PascalCase for components, kebab-case for features, camelCase for hooks |
| `state-management.md` | Pages fetch, components render, stores organized by scope |
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
| `audit-architecture` | `/audit-architecture` | Full codebase audit: cross-imports, oversized files, empty dirs, data fetching in components |
| `scaffold-feature` | `/scaffold-feature user-profile` | Creates standard feature module structure |

## How Compaction Resilience Works

This is the core innovation. When Claude Code compacts context in a long session:

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
        ├── audit-architecture/SKILL.md    # Architecture auditor
        └── scaffold-feature/SKILL.md      # Feature scaffolder
```

## Customization

### Add project-specific rules

```markdown
<!-- .claude/rules/api-patterns.md -->
---
description: API patterns for this project
globs:
  - "src/features/**/services/**"
---

# API Rules
- All services use the shared HTTP client from core/network/
- Service files: `{Verb}{Resource}Service.ts`
```

### Add protected file patterns

Edit `.claude/hooks/protect-files.sh` and add to the `PROTECTED_PATTERNS` array.

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
- Translations

## License

[MIT](LICENSE)

---

**Built with hard-won lessons from production React Native and Next.js projects.**

If this saved you from a painful refactor, consider giving it a star.
