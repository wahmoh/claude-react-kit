#!/bin/bash
# PreCompact hook: saves current working state before compaction destroys context
# This creates a checkpoint file that can be read after compaction

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
CHECKPOINT_FILE="$PROJECT_DIR/.claude/.checkpoint.md"

{
  echo "# Session Checkpoint (auto-saved before compaction)"
  echo "**Timestamp:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo ""
  echo "## Git State"
  echo '```'
  git -C "$PROJECT_DIR" status --short 2>/dev/null || echo "Not a git repo"
  echo '```'
  echo ""
  echo "## Recent Commits"
  echo '```'
  git -C "$PROJECT_DIR" log --oneline -5 2>/dev/null || echo "No commits"
  echo '```'
  echo ""
  echo "## Recently Modified Files"
  echo '```'
  git -C "$PROJECT_DIR" diff --name-only HEAD~3 2>/dev/null || echo "No recent changes"
  echo '```'
} > "$CHECKPOINT_FILE" 2>/dev/null

exit 0
