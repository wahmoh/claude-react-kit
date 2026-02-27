---
description: Rules for maintaining quality across long Claude Code sessions and after context compaction
---

# Session Management & Compaction Resilience

## After Every Compaction

YOU MUST re-orient yourself:
1. Re-read this file and all active .claude/rules/
2. Check git status to understand current state
3. Check the task tracking document (if any) for progress
4. Verify which files were recently modified: `git diff --name-only HEAD~3`
5. Resume from where you left off — do NOT restart completed work

## Long Session Rules

### Checkpoint Every Major Change
After completing a logical unit of work:
1. Run type-check to verify everything compiles
2. Commit the change with a descriptive message
3. Update any tracking documents

### Use Subagents for Research
When you need to explore the codebase extensively:
- Use Task tool with Explore agent to search files
- This keeps research results out of the main context window
- Only bring back the summary, not all the raw file contents

### One Task at a Time
- Complete one atomic task before starting the next
- Never leave files in a half-modified state
- If you must pause, commit current work first

### Proactive Context Management
- If the conversation is getting long, suggest using `/compact` with a focus message
- If starting a clearly different task, suggest `/clear`
- Keep responses concise — verbose explanations consume context

## Quality Invariants (Must Hold After EVERY Change)

These MUST be true at all times, regardless of session length or compaction:

1. Zero cross-feature imports (features/ never imports from other features/)
2. core/ has zero domain-specific imports
3. design-system/ has zero business logic
4. All components receive data via props (never fetch directly)
5. No files > 200 lines without being split
6. No empty directories
7. No duplicate components with different names
8. Type-check passes with zero new errors
