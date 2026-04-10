#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW VALIDATE — Comprehensive Project Health Check v1.0
# ═══════════════════════════════════════════════════════════════════════
# Usage: bash scripts/validate.sh [--fix] [--verbose]
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

FIX_MODE=false
VERBOSE=false

for arg in "$@"; do
  case $arg in
    --fix) FIX_MODE=true ;;
    --verbose|-v) VERBOSE=true ;;
    --help|-h)
      echo "Usage: bash scripts/validate.sh [--fix] [--verbose]"
      echo ""
      echo "  --fix      Auto-fix issues where possible"
      echo "  --verbose  Show detailed output"
      exit 0
      ;;
  esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCORE=0
TOTAL_CHECKS=0

echo ""
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     🦌 DEERFLOW PROJECT HEALTH CHECK v1.0               ║"
echo "║     Comprehensive validation for AI-generated code       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ═══════════════════════════════════════════════════
# SECTION 1: Deerflow Framework Installation
# ═══════════════════════════════════════════════════
echo -e "${BOLD}━━━ Section 1: Framework Installation ━━━${NC}"

check_file() {
  local file="$1"
  local description="$2"
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}  ✅ $description${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${RED}  ❌ $description (missing: $file)${NC}"
    if [[ "$FIX_MODE" == true ]]; then
      echo -e "${YELLOW}     Fix: Run setup.sh to install missing files${NC}"
    fi
  fi
}

check_file ".cursorrules" "Cursor agent rules"
check_file "CLAUDE.md" "Claude Code instructions"
check_file "AGENTS.md" "Universal agent instructions"
check_file ".windsurfrules" "Windsurf agent rules"
check_file ".github/copilot-instructions.md" "Copilot instructions"
check_file ".github/workflows/quality-gate.yml" "CI quality gates"
check_file "deerflow/core/agent-rules.md" "Core rule engine"
check_file "deerflow/core/workflow-engine.md" "Workflow engine"
check_file "deerflow/core/coding-standards.md" "Coding standards"
check_file "deerflow/core/quality-gates.md" "Quality gate definitions"

echo ""

# ═══════════════════════════════════════════════════
# SECTION 2: Pre-commit Hooks
# ═══════════════════════════════════════════════════
echo -e "${BOLD}━━━ Section 2: Pre-commit Hooks ━━━${NC}"

if [[ -d ".git" ]]; then
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  if [[ -x ".git/hooks/pre-commit" ]]; then
    echo -e "${GREEN}  ✅ Pre-commit hook installed and executable${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${RED}  ❌ Pre-commit hook not installed${NC}"
  fi

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  if [[ -x ".git/hooks/post-commit" ]]; then
    echo -e "${GREEN}  ✅ Post-commit worklog hook installed${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${YELLOW}  ⚠️  Post-commit worklog hook not installed (optional)${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠️  Not a git repository — skipping hook checks${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════
# SECTION 3: Code Safety
# ═══════════════════════════════════════════════════
echo -e "${BOLD}━━━ Section 3: Code Safety ━━━${NC}"

# Check for 'any' types in TypeScript files
if [[ -d "src" ]]; then
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  ANY_COUNT=$(grep -rE ":\s*any\b" src/ --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v "node_modules" | grep -v ".test." | grep -v ".spec." | wc -l 2>/dev/null) || true
  ANY_COUNT=${ANY_COUNT:-0}
  ANY_COUNT=$(echo "$ANY_COUNT" | tr -d '[:space:]')
  if [[ "$ANY_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ No 'any' types found in source${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${RED}  ❌ $ANY_COUNT 'any' type(s) found in source code${NC}"
    if [[ "$VERBOSE" == true ]]; then
      grep -rE ":\s*any\b" src/ --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v "node_modules" | grep -v ".test." | head -10 || true
    fi
  fi

  # Check for console.log
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  CONSOLE_COUNT=$(grep -rE "console\.(log|debug|info)" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -v "node_modules" | grep -v ".test." | grep -v ".spec." | wc -l 2>/dev/null) || true
  CONSOLE_COUNT=${CONSOLE_COUNT:-0}
  CONSOLE_COUNT=$(echo "$CONSOLE_COUNT" | tr -d '[:space:]')
  if [[ "$CONSOLE_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ No console.log in production code${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${YELLOW}  ⚠️  $CONSOLE_COUNT console.log(s) found${NC}"
  fi

  # Check for eval
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  EVAL_COUNT=$(grep -rE "\beval\s*\(" src/ --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | grep -v "node_modules" | wc -l 2>/dev/null) || true
  EVAL_COUNT=${EVAL_COUNT:-0}
  EVAL_COUNT=$(echo "$EVAL_COUNT" | tr -d '[:space:]')
  if [[ "$EVAL_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ No eval() usage${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${RED}  ❌ $EVAL_COUNT eval() usage(s) found — SECURITY RISK${NC}"
  fi

  # Check for TODO/FIXME
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  TODO_COUNT=$(grep -rE "(TODO|FIXME|HACK|XXX)" src/ --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v "node_modules" | wc -l 2>/dev/null) || true
  TODO_COUNT=${TODO_COUNT:-0}
  TODO_COUNT=$(echo "$TODO_COUNT" | tr -d '[:space:]')
  if [[ "$TODO_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ No TODO/FIXME markers${NC}"
    SCORE=$((SCORE + 1))
  else
    echo -e "${YELLOW}  ⚠️  $TODO_COUNT TODO/FIXME marker(s) found${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠️  No src/ directory found — skipping code checks${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════
# SECTION 4: Build Integrity
# ═══════════════════════════════════════════════════
echo -e "${BOLD}━━━ Section 4: Build Integrity ━━━${NC}"

for build_dir in "dist" ".next" "build" "out"; do
  if [[ -d "$build_dir" ]]; then
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    SIZE_KB=$(du -sk "$build_dir" 2>/dev/null | cut -f1)
    SIZE_MB=$((SIZE_KB / 1024))
    JS_COUNT=$(find "$build_dir" -name "*.js" 2>/dev/null | wc -l)
    CSS_COUNT=$(find "$build_dir" -name "*.css" 2>/dev/null | wc -l)

    echo -e "  📦 Build: $build_dir (${SIZE_KB}KB, ${JS_COUNT} JS, ${CSS_COUNT} CSS)"

    if [[ "$SIZE_KB" -lt 10 ]]; then
      echo -e "${RED}    ❌ Build too small — likely incomplete${NC}"
    elif [[ "$JS_COUNT" -eq 0 ]]; then
      echo -e "${RED}    ❌ No JS files in build — incomplete${NC}"
    else
      echo -e "${GREEN}    ✅ Build appears complete${NC}"
      SCORE=$((SCORE + 1))
    fi
  fi
done

if [[ ! -d "dist" ]] && [[ ! -d ".next" ]] && [[ ! -d "build" ]] && [[ ! -d "out" ]]; then
  echo -e "${YELLOW}  ⚠️  No build directory found — run build first${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════
# SECTION 5: Security
# ═══════════════════════════════════════════════════
echo -e "${BOLD}━━━ Section 5: Security ━━━${NC}"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
SECRET_FOUND=false
SECRET_PATTERNS=("AKIA[0-9A-Z]{16}" "ghp_[A-Za-z0-9]{36}" "sk-[A-Za-z0-9]{20,}" "xox[bposa]-" "-----BEGIN.*PRIVATE KEY-----")

for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -rP "$pattern" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.env*" 2>/dev/null | grep -v "node_modules" | grep -v ".example" | head -1; then
    SECRET_FOUND=true
  fi
done

if [[ "$SECRET_FOUND" == false ]]; then
  echo -e "${GREEN}  ✅ No hardcoded secrets detected${NC}"
  SCORE=$((SCORE + 1))
else
  echo -e "${RED}  ❌ Potential secrets found — remove immediately!${NC}"
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -f ".env" ]] && git ls-files .env 2>/dev/null | grep -q ".env"; then
  echo -e "${RED}  ❌ .env is tracked by git — secrets may be exposed!${NC}"
else
  echo -e "${GREEN}  ✅ .env is not tracked by git${NC}"
  SCORE=$((SCORE + 1))
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -f ".gitignore" ]] && grep -q ".env" .gitignore 2>/dev/null; then
  echo -e "${GREEN}  ✅ .env is in .gitignore${NC}"
  SCORE=$((SCORE + 1))
else
  echo -e "${YELLOW}  ⚠️  .env not in .gitignore — recommend adding it${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════
# FINAL SCORE
# ═══════════════════════════════════════════════════
if [[ $TOTAL_CHECKS -gt 0 ]]; then
  PERCENTAGE=$((SCORE * 100 / TOTAL_CHECKS))
else
  PERCENTAGE=0
fi

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     HEALTH SCORE: ${SCORE}/${TOTAL_CHECKS} (${PERCENTAGE}%)                            "
echo "║                                                           ║"

if [[ $PERCENTAGE -ge 90 ]]; then
  echo "║     Status: ✅ EXCELLENT — Project is well governed      ║"
elif [[ $PERCENTAGE -ge 70 ]]; then
  echo "║     Status: ⚠️  GOOD — Minor improvements needed          ║"
elif [[ $PERCENTAGE -ge 50 ]]; then
  echo "║     Status: ⚠️  FAIR — Significant improvements needed    ║"
else
  echo "║     Status: ❌ POOR — Major issues require attention      ║"
fi

echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

if [[ $PERCENTAGE -lt 70 ]]; then
  echo -e "${BOLD}Recommendations:${NC}"
  echo "  1. Run: bash scripts/setup.sh — to install missing files"
  echo "  2. Run: bash scripts/validate.sh --fix — to auto-fix issues"
  echo "  3. Review agent rules in .cursorrules / CLAUDE.md / AGENTS.md"
  echo ""
fi

exit 0
