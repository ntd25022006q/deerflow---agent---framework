#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW UNINSTALL — Clean Removal Script v1.0
# ═══════════════════════════════════════════════════════════════════════
# Usage: bash scripts/uninstall.sh [--force]
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

FORCE=false
for arg in "$@"; do
  case $arg in
    --force|-f) FORCE=true ;;
    --help|-h)
      echo "Usage: bash scripts/uninstall.sh [--force]"
      echo "  --force  Skip confirmation prompt"
      exit 0
      ;;
  esac
done

echo ""
echo -e "${CYAN}🦌 Deerflow Agent Framework — Uninstall${NC}"
echo ""

if [[ "$FORCE" != true ]]; then
  echo -e "${YELLOW}This will remove all Deerflow files from your project:${NC}"
  echo "  - .cursorrules"
  echo "  - .windsurfrules"
  echo "  - CLAUDE.md"
  echo "  - AGENTS.md"
  echo "  - .github/copilot-instructions.md"
  echo "  - .github/workflows/quality-gate.yml"
  echo "  - deerflow/ directory"
  echo "  - Pre-commit hooks"
  echo ""
  read -p "Continue? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

# Remove agent rule files
for file in ".cursorrules" ".windsurfrules" "CLAUDE.md" "AGENTS.md"; do
  if [[ -f "$file" ]]; then
    rm "$file"
    echo -e "${GREEN}  Removed: $file${NC}"
  fi
done

# Remove GitHub files
if [[ -f ".github/copilot-instructions.md" ]]; then
  rm ".github/copilot-instructions.md"
  echo -e "${GREEN}  Removed: .github/copilot-instructions.md${NC}"
fi

if [[ -f ".github/workflows/quality-gate.yml" ]]; then
  rm ".github/workflows/quality-gate.yml"
  echo -e "${GREEN}  Removed: .github/workflows/quality-gate.yml${NC}"
fi

# Remove deerflow directory
if [[ -d "deerflow" ]]; then
  rm -rf "deerflow"
  echo -e "${GREEN}  Removed: deerflow/${NC}"
fi

# Remove pre-commit hooks
if [[ -d ".git/hooks" ]]; then
  if grep -q "deerflow" ".git/hooks/pre-commit" 2>/dev/null; then
    rm ".git/hooks/pre-commit"
    echo -e "${GREEN}  Removed: .git/hooks/pre-commit${NC}"
  fi
  if grep -q "deerflow" ".git/hooks/post-commit" 2>/dev/null; then
    rm ".git/hooks/post-commit"
    echo -e "${GREEN}  Removed: .git/hooks/post-commit${NC}"
  fi
fi

# Restore backups if they exist
for file in ".cursorrules.bak" ".windsurfrules.bak" "CLAUDE.md.bak" "AGENTS.md.bak"; do
  if [[ -f "$file" ]]; then
    original="${file%.bak}"
    mv "$file" "$original"
    echo -e "${GREEN}  Restored: $original${NC}"
  fi
done

echo ""
echo -e "${GREEN}✅ Deerflow Agent Framework has been removed.${NC}"
echo ""
