# Contributing to claude-react-kit

Thanks for your interest in improving this kit! Here's how to contribute.

## How to Contribute

### Reporting Issues

- Check existing issues first to avoid duplicates
- Include your Claude Code version, OS, and a minimal reproduction
- For rule suggestions, explain the anti-pattern it prevents

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Test with a real project (drop the files in, run Claude Code, verify hooks fire)
5. Submit a pull request with a clear description

### What We're Looking For

**New rules** (`.claude/rules/`):
- Must prevent a specific, documented anti-pattern
- Must include path-scoping via frontmatter globs
- Must be framework-agnostic (React-specific is fine, but not Next.js-only)

**New hooks** (`.claude/hooks/`):
- Must be deterministic (same input = same output)
- Must fail gracefully (exit 0 on unexpected input)
- Must not require external dependencies beyond standard Unix tools + jq

**New skills** (`.claude/skills/`):
- Must solve a repeatable workflow
- Must include clear usage instructions

**Framework adaptations**:
- Vue.js, Svelte, Angular versions are welcome
- Create a separate directory: `templates/vue/`, `templates/svelte/`, etc.

### Code Style

- Shell scripts: use `#!/bin/bash`, `set -euo pipefail` where appropriate
- Markdown: keep lines under 120 characters
- Rules: use tables and code blocks for clarity, avoid walls of text
- CLAUDE.md: keep under 80 lines — brevity is the whole point

### Testing

There's no automated test suite (yet). To test:

1. Copy the template files into a real React project
2. Start a Claude Code session
3. Ask Claude to create a component that violates architecture rules
4. Verify the hook catches the violation
5. Ask Claude to compact (`/compact`) and verify post-compaction reminders fire

## Code of Conduct

Be kind, be constructive, be helpful.
