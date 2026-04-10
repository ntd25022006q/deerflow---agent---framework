#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW PRE-COMMIT HOOK — Code Quality Validator v1.0
# ═══════════════════════════════════════════════════════════════════════
# Runs TypeScript compilation, linting, and tests before commit.
# Install: cp deerflow/hooks/pre-commit/validate-quality.sh .git/hooks/pre-commit-quality
# Or chain with validate-safety.sh
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  DEERFLOW PRE-COMMIT QUALITY VALIDATION v1.0  ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

FAILED=0

# ──────────────────────────────────────────────
# CHECK 1: TypeScript Compilation
# ──────────────────────────────────────────────
echo -e "${CYAN}[1/4] TypeScript Compilation...${NC}"

if command -v npx &> /dev/null && [[ -f "tsconfig.json" ]]; then
  if npx tsc --noEmit 2>/dev/null; then
    echo -e "${GREEN}  ✅ TypeScript compilation passed${NC}"
  else
    echo -e "${RED}  ❌ TypeScript compilation FAILED${NC}"
    FAILED=$((FAILED + 1))
  fi
elif [[ -f "tsconfig.json" ]]; then
  echo -e "${YELLOW}  ⚠️  tsconfig.json found but npx not available${NC}"
else
  echo -e "${YELLOW}  ⚠️  No tsconfig.json found — skipping${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 2: ESLint
# ──────────────────────────────────────────────
echo -e "${CYAN}[2/4] ESLint...${NC}"

if command -v npx &> /dev/null && ( [[ -f ".eslintrc.json" ]] || [[ -f ".eslintrc.js" ]] || [[ -f "eslint.config.js" ]] ); then
  STAGED_JS=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$' || true)
  if [[ -n "$STAGED_JS" ]]; then
    if echo "$STAGED_JS" | xargs npx eslint --max-warnings=0 2>/dev/null; then
      echo -e "${GREEN}  ✅ ESLint passed with zero warnings${NC}"
    else
      echo -e "${RED}  ❌ ESLint FAILED${NC}"
      FAILED=$((FAILED + 1))
    fi
  else
    echo -e "${GREEN}  ✅ No JS/TS files to lint${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠️  ESLint not configured — skipping${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 3: Tests
# ──────────────────────────────────────────────
echo -e "${CYAN}[3/4] Running Tests...${NC}"

if command -v npx &> /dev/null && [[ -f "package.json" ]]; then
  if grep -q '"test"' package.json; then
    if npx npm test -- --passWithNoTests --ci 2>/dev/null; then
      echo -e "${GREEN}  ✅ All tests passed${NC}"
    else
      echo -e "${RED}  ❌ Tests FAILED${NC}"
      FAILED=$((FAILED + 1))
    fi
  else
    echo -e "${YELLOW}  ⚠️  No test script found — skipping${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠️  No package.json found — skipping${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 4: Build Size Verification
# ──────────────────────────────────────────────
echo -e "${CYAN}[4/4] Build Size Check...${NC}"

if [[ -d "dist" || -d ".next" || -d "build" ]]; then
  for build_dir in "dist" ".next" "build"; do
    if [[ -d "$build_dir" ]]; then
      size=$(du -sk "$build_dir" 2>/dev/null | cut -f1)
      size_kb=$((size))
      size_mb=$((size / 1024))

      if [[ $size_kb -lt 10 ]]; then
        echo -e "${RED}  ❌ Build directory '$build_dir' is suspiciously small: ${size_kb}KB${NC}"
        echo -e "${RED}     This suggests missing assets or incomplete build.${NC}"
        FAILED=$((FAILED + 1))
      elif [[ $size_mb -gt 500 ]]; then
        echo -e "${YELLOW}  ⚠️  Build directory '$build_dir' is very large: ${size_mb}MB${NC}"
        echo -e "${YELLOW}     Consider optimizing bundle size.${NC}"
      else
        echo -e "${GREEN}  ✅ Build size reasonable: ${build_dir} = ${size_kb}KB${NC}"
      fi
    fi
  done
else
  echo -e "${YELLOW}  ⚠️  No build directory found — skipping size check${NC}"
fi

# ──────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

if [[ $FAILED -gt 0 ]]; then
  echo -e "${RED}  ❌ ${FAILED} check(s) FAILED${NC}"
  echo -e "${RED}  Commit BLOCKED. Fix issues and try again.${NC}"
  echo ""
  exit 1
else
  echo -e "${GREEN}  ✅ All quality checks passed!${NC}"
  echo ""
  exit 0
fi
