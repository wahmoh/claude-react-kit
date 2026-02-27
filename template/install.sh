#!/bin/bash
# claude-react-kit installer
# Run from your project root: bash <(curl -s https://raw.githubusercontent.com/YOUR_USERNAME/claude-react-kit/main/template/install.sh)

set -euo pipefail

echo "Installing claude-react-kit..."

# Check if we're in a project directory
if [ ! -f "package.json" ]; then
  echo "Error: No package.json found. Run this from your project root."
  exit 1
fi

# Check for existing CLAUDE.md
if [ -f "CLAUDE.md" ]; then
  echo "Warning: CLAUDE.md already exists. Backing up to CLAUDE.md.backup"
  cp CLAUDE.md CLAUDE.md.backup
fi

# Download template files
REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/claude-react-kit/main/template"

echo "Downloading CLAUDE.md..."
curl -sL "$REPO_URL/CLAUDE.md" -o CLAUDE.md

echo "Downloading .claude/ configuration..."
mkdir -p .claude/rules .claude/hooks .claude/skills/audit-architecture .claude/skills/scaffold-feature

# Rules
for rule in architecture components code-quality naming-conventions session-management state-management; do
  curl -sL "$REPO_URL/.claude/rules/$rule.md" -o ".claude/rules/$rule.md"
done

# Hooks
for hook in post-compact-context pre-compact-save protect-files validate-architecture; do
  curl -sL "$REPO_URL/.claude/hooks/$hook.sh" -o ".claude/hooks/$hook.sh"
  chmod +x ".claude/hooks/$hook.sh"
done

# Settings
curl -sL "$REPO_URL/.claude/settings.json" -o ".claude/settings.json"

# Skills
curl -sL "$REPO_URL/.claude/skills/audit-architecture/SKILL.md" -o ".claude/skills/audit-architecture/SKILL.md"
curl -sL "$REPO_URL/.claude/skills/scaffold-feature/SKILL.md" -o ".claude/skills/scaffold-feature/SKILL.md"

# Add to .gitignore
if [ -f ".gitignore" ]; then
  if ! grep -q ".claude/.checkpoint.md" .gitignore 2>/dev/null; then
    echo -e "\n# claude-react-kit\n.claude/.checkpoint.md\n.claude/settings.local.json" >> .gitignore
  fi
fi

echo ""
echo "Done! claude-react-kit installed successfully."
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — replace ## Commands with your actual build commands"
echo "  2. Edit .claude/hooks/protect-files.sh — add your protected file patterns"
echo "  3. Start a Claude Code session and test with: /audit-architecture"
echo ""
