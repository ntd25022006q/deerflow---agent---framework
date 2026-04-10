#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW PRE-COMMIT HOOK — File Safety Validator v1.0
# ═══════════════════════════════════════════════════════════════════════
# This hook runs before every git commit to prevent dangerous operations.
# Install: cp deerflow/hooks/pre-commit/validate-safety.sh .git/hooks/pre-commit
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  DEERFLOW PRE-COMMIT SAFETY VALIDATION v1.0   ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

VIOLATIONS=0
WARNINGS=0

# ──────────────────────────────────────────────
# CHECK 1: Forbidden destructive patterns in staged files
# ──────────────────────────────────────────────
echo -e "${CYAN}[1/8] Checking for destructive patterns...${NC}"

FORBIDDEN_PATTERNS=(
  "rm -rf"
  "rimraf"
  "fs.rmSync.*recursive"
  "fs.rmdirSync.*recursive"
  "del /s /q"
  "git reset --hard"
  "git clean -fdx"
  "git push --force"
)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  matches=$(git diff --cached -U0 | grep -E "^\+" | grep -i "$pattern" || true)
  if [[ -n "$matches" ]]; then
    echo -e "${RED}  ❌ FORBIDDEN pattern found: '$pattern'${NC}"
    echo -e "${RED}     $matches${NC}"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

if [[ $VIOLATIONS -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No destructive patterns detected${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 2: Hardcoded secrets detection
# ──────────────────────────────────────────────
echo -e "${CYAN}[2/8] Checking for hardcoded secrets...${NC}"

SECRET_PATTERNS=(
  "api_key\s*[:=]\s*['\"][^'\"]+['\"]"
  "apikey\s*[:=]\s*['\"][^'\"]+['\"]"
  "secret\s*[:=]\s*['\"][^'\"]{10,}['\"]"
  "password\s*[:=]\s*['\"][^'\"]+['\"]"
  "token\s*[:=]\s*['\"][A-Za-z0-9._-]{20,}['\"]"
  "AKIA[0-9A-Z]{16}"
  "ghp_[A-Za-z0-9]{36}"
  "gho_[A-Za-z0-9]{36}"
  "sk-[A-Za-z0-9]{48}"
  "xox[bposa]-[A-Za-z0-9-]+"
)

SECRET_COUNT=0
for pattern in "${SECRET_PATTERNS[@]}"; do
  matches=$(git diff --cached -U0 | grep -E "^\+" | grep -iP "$pattern" || true)
  if [[ -n "$matches" ]]; then
    echo -e "${RED}  ❌ POTENTIAL SECRET detected!${NC}"
    echo -e "${RED}     Pattern: $pattern${NC}"
    echo -e "${RED}     Match: $matches${NC}"
    SECRET_COUNT=$((SECRET_COUNT + 1))
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

if [[ $SECRET_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No hardcoded secrets detected${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 3: TypeScript 'any' type usage
# ──────────────────────────────────────────────
echo -e "${CYAN}[3/8] Checking for forbidden 'any' types...${NC}"

ANY_COUNT=0
for file in $STAGED_FILES; do
  if [[ "$file" == *.ts || "$file" == *.tsx ]]; then
    count=$(git show ":$file" 2>/dev/null | grep -cE ":\s*any\b" || true)
    if [[ $count -gt 0 ]]; then
      echo -e "${RED}  ❌ Found ${count} 'any' type(s) in: $file${NC}"
      ANY_COUNT=$((ANY_COUNT + count))
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  fi
done

if [[ $ANY_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No 'any' types detected${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 4: TODO/FIXME/HACK in new code
# ──────────────────────────────────────────────
echo -e "${CYAN}[4/8] Checking for incomplete code markers...${NC}"

TODO_COUNT=0
for file in $STAGED_FILES; do
  if git diff --cached "$file" | grep -E "^\+" | grep -qE "(TODO|FIXME|HACK|XXX)"; then
    count=$(git diff --cached "$file" | grep -E "^\+" | grep -cE "(TODO|FIXME|HACK|XXX)" || true)
    echo -e "${YELLOW}  ⚠️  Found ${count} TODO/FIXME/HACK in: $file${NC}"
    TODO_COUNT=$((TODO_COUNT + count))
    WARNINGS=$((WARNINGS + 1))
  fi
done

if [[ $TODO_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No incomplete code markers${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 5: console.log in production code
# ──────────────────────────────────────────────
echo -e "${CYAN}[5/8] Checking for console.log statements...${NC}"

CONSOLE_COUNT=0
for file in $STAGED_FILES; do
  if [[ "$file" == *.ts || "$file" == *.tsx || "$file" == *.js || "$file" == *.jsx ]]; then
    # Skip test files
    if [[ "$file" != *.test.* && "$file" != *.spec.* && "$file" != *__tests__* ]]; then
      count=$(git show ":$file" 2>/dev/null | grep -cE "console\.(log|warn|error|debug|info)" || true)
      if [[ $count -gt 0 ]]; then
        echo -e "${RED}  ❌ Found ${count} console.log(s) in: $file${NC}"
        CONSOLE_COUNT=$((CONSOLE_COUNT + count))
        VIOLATIONS=$((VIOLATIONS + 1))
      fi
    fi
  fi
done

if [[ $CONSOLE_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No console.log statements${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 6: eval() and dangerouslySetInnerHTML
# ──────────────────────────────────────────────
echo -e "${CYAN}[6/8] Checking for unsafe code patterns...${NC}"

UNSAFE_COUNT=0
UNSAFE_PATTERNS=("eval\(" "new Function\(" "dangerouslySetInnerHTML")

for file in $STAGED_FILES; do
  for pattern in "${UNSAFE_PATTERNS[@]}"; do
    if git show ":$file" 2>/dev/null | grep -qE "$pattern"; then
      echo -e "${RED}  ❌ Unsafe pattern '$pattern' found in: $file${NC}"
      UNSAFE_COUNT=$((UNSAFE_COUNT + 1))
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done
done

if [[ $UNSAFE_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No unsafe code patterns${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 7: Empty catch blocks
# ──────────────────────────────────────────────
echo -e "${CYAN}[7/8] Checking for empty error handling...${NC}"

EMPTY_CATCH_COUNT=0
for file in $STAGED_FILES; do
  if [[ "$file" == *.ts || "$file" == *.tsx || "$file" == *.js || "$file" == *.jsx ]]; then
    # Check for catch blocks with empty body or just console.log
    if git show ":$file" 2>/dev/null | grep -qP "catch\s*\([^)]*\)\s*\{\s*\}"; then
      echo -e "${RED}  ❌ Empty catch block found in: $file${NC}"
      EMPTY_CATCH_COUNT=$((EMPTY_CATCH_COUNT + 1))
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  fi
done

if [[ $EMPTY_CATCH_COUNT -eq 0 ]]; then
  echo -e "${GREEN}  ✅ No empty error handling${NC}"
fi

# ──────────────────────────────────────────────
# CHECK 8: File size sanity check
# ──────────────────────────────────────────────
echo -e "${CYAN}[8/8] Checking file sizes...${NC}"

OVERSIZED=0
for file in $STAGED_FILES; do
  if [[ -f "$file" ]]; then
    lines=$(wc -l < "$file")
    if [[ $lines -gt 500 ]]; then
      echo -e "${YELLOW}  ⚠️  Large file (${lines} lines): $file${NC}"
      OVERSIZED=$((OVERSIZED + 1))
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done

if [[ $OVERSIZED -eq 0 ]]; then
  echo -e "${GREEN}  ✅ All files within size limits${NC}"
fi

# ──────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  RESULTS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

if [[ $VIOLATIONS -gt 0 ]]; then
  echo -e "${RED}  ❌ ${VIOLATIONS} violation(s) found${NC}"
  echo -e "${RED}  Commit BLOCKED. Fix violations and try again.${NC}"
  echo -e "${RED}  Run: git commit -n (to bypass — NOT recommended)${NC}"
  echo ""
  exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo -e "${YELLOW}  ⚠️  ${WARNINGS} warning(s) found${NC}"
  echo -e "${YELLOW}  Commit allowed but please address warnings.${NC}"
else
  echo -e "${GREEN}  ✅ All checks passed! Committing...${NC}"
fi

echo ""
exit 0
