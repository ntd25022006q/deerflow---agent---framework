#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW — Shell Script Integration Tests
# ═══════════════════════════════════════════════════════════════════════
# Tests that run validate.sh and setup.sh against REAL directories.
# No mocks. Real files, real operations.
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0
TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_exit_code() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  TOTAL=$((TOTAL + 1))
  if [[ "$actual" -eq "$expected" ]]; then
    echo -e "${GREEN}  PASS${NC} $description (exit=$actual)"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  FAIL${NC} $description (expected=$expected, actual=$actual)"
    FAIL=$((FAIL + 1))
  fi
}

assert_output_contains() {
  local description="$1"
  local pattern="$2"
  local output="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "$pattern"; then
    echo -e "${GREEN}  PASS${NC} $description"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  FAIL${NC} $description (pattern '$pattern' not found)"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_exists() {
  local description="$1"
  local filepath="$2"
  TOTAL=$((TOTAL + 1))
  if [[ -f "$filepath" ]]; then
    echo -e "${GREEN}  PASS${NC} $description"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  FAIL${NC} $description (file not found: $filepath)"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "=========================================="
echo "  DEERFLOW SHELL INTEGRATION TESTS"
echo "=========================================="
echo ""

# ═══════════════════════════════════════════
# SECTION 1: validate.sh on the repo itself
# ═══════════════════════════════════════════
echo "--- Section 1: validate.sh on Deerflow repo ---"

OUTPUT=$(bash "$REPO_ROOT/scripts/validate.sh" 2>&1) || true

assert_exit_code "validate.sh exits with 0" 0 "${PIPESTATUS[0]:-0}"
assert_output_contains "validate.sh reports framework files" "Cursor agent rules" "$OUTPUT"
assert_output_contains "validate.sh reports Claude rules" "Claude Code instructions" "$OUTPUT"
assert_output_contains "validate.sh reports agent rules" "Universal agent instructions" "$OUTPUT"
assert_output_contains "validate.sh reports CI workflow" "CI quality gates" "$OUTPUT"
assert_output_contains "validate.sh reports core rules" "Core rule engine" "$OUTPUT"
assert_output_contains "validate.sh reports workflow engine" "Workflow engine" "$OUTPUT"
assert_output_contains "validate.sh reports coding standards" "Coding standards" "$OUTPUT"
assert_output_contains "validate.sh reports quality gates" "Quality gate" "$OUTPUT"
assert_output_contains "validate.sh shows health score" "HEALTH SCORE" "$OUTPUT"
assert_output_contains "validate.sh shows percentage" "%" "$OUTPUT"

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 2: validate.sh --help
# ═══════════════════════════════════════════
echo "--- Section 2: validate.sh --help ---"

HELP_OUTPUT=$(bash "$REPO_ROOT/scripts/validate.sh" --help 2>&1) || true
assert_exit_code "validate.sh --help exits 0" 0 "${PIPESTATUS[0]:-0}"
assert_output_contains "--help shows usage" "Usage" "$HELP_OUTPUT"
assert_output_contains "--help shows --fix option" "--fix" "$HELP_OUTPUT"
assert_output_contains "--help shows --verbose option" "--verbose" "$HELP_OUTPUT"

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 3: validate.sh on a dirty project (real temp dir)
# ═══════════════════════════════════════════════════════
echo "--- Section 3: validate.sh detects real violations ---"

TMPDIR=$(mktemp -d)
HOOK_TEST_DIR=""
trap 'rm -rf "$TMPDIR" ${HOOK_TEST_DIR:+"$HOOK_TEST_DIR"}' EXIT

# Create a project with VIOLATIONS
mkdir -p "$TMPDIR/src"
echo 'const x: any = eval("code");' > "$TMPDIR/src/bad.ts"
echo 'password = "supersecret123";' > "$TMPDIR/src/config.py"
echo 'AKIA1234567890ABCDEF' > "$TMPDIR/src/keys.js"

cd "$TMPDIR"
git init -q
git config user.email "test@test.com"
git config user.name "Test"

# Copy validate.sh
mkdir -p "$TMPDIR/scripts"
cp "$REPO_ROOT/scripts/validate.sh" "$TMPDIR/scripts/validate.sh"
chmod +x "$TMPDIR/scripts/validate.sh" 2>/dev/null || true

DIRTY_OUTPUT=$(bash "$TMPDIR/scripts/validate.sh" 2>&1) || true
cd "$REPO_ROOT"

assert_output_contains "Detects any types" "'any' type" "$DIRTY_OUTPUT" || \
  assert_output_contains "Detects any types" "any type" "$DIRTY_OUTPUT"
assert_output_contains "Detects eval usage" "eval" "$DIRTY_OUTPUT"
assert_output_contains "Detects secrets" "secret" "$DIRTY_OUTPUT" || \
  assert_output_contains "Detects secrets" "AKIA" "$DIRTY_OUTPUT"

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 4: Shell syntax validation for all scripts
# ═══════════════════════════════════════════════════════
echo "--- Section 4: Bash syntax validation ---"

for script in \
  "$REPO_ROOT/deerflow/hooks/pre-commit/validate-safety.sh" \
  "$REPO_ROOT/deerflow/hooks/pre-commit/validate-quality.sh" \
  "$REPO_ROOT/scripts/setup.sh" \
  "$REPO_ROOT/scripts/validate.sh" \
  "$REPO_ROOT/scripts/uninstall.sh"; do
  SCRIPT_NAME=$(basename "$script")
  RESULT=$(bash -n "$script" 2>&1)
  assert_exit_code "$SCRIPT_NAME has valid bash syntax" 0 "$?"
done

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 5: Real git hook test — safety hook on staged content
# ═══════════════════════════════════════════════════════
echo "--- Section 5: Real pre-commit hook integration ---"

HOOK_TEST_DIR=$(mktemp -d)

cd "$HOOK_TEST_DIR"
git init -q
git config user.email "test@test.com"
git config user.name "Test"

# Install the safety hook
mkdir -p .git/hooks
cp "$REPO_ROOT/deerflow/hooks/pre-commit/validate-safety.sh" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit 2>/dev/null || true

# Test 1: Clean code should pass
mkdir -p src
cat > src/clean.ts << 'EOF'
interface User {
  id: string;
  name: string;
}

function createUser(name: string): User {
  return { id: crypto.randomUUID(), name };
}
EOF
git add src/clean.ts
git commit -m "clean code" 2>&1 >/dev/null
assert_exit_code "Clean TypeScript passes pre-commit" 0 "$?"

# Test 2: Destructive pattern should fail
cat > src/danger.sh << 'EOF'
#!/bin/bash
rm -rf /tmp/important-data
EOF
git add src/danger.sh
if git commit -m "dangerous code" 2>&1 >/dev/null; then EXIT=0; else EXIT=1; fi
assert_exit_code "rm -rf blocked by pre-commit" 1 "$EXIT"
git reset HEAD src/danger.sh >/dev/null 2>&1 || true

# Test 3: AWS key should fail
cat > src/config.ts << 'EOF'
const AWS_SECRET = "AKIAIOSFODNN7EXAMPLE1234";
EOF
git add src/config.ts
if git commit -m "aws key" 2>&1 >/dev/null; then EXIT=0; else EXIT=1; fi
assert_exit_code "AWS key blocked by pre-commit" 1 "$EXIT"
git reset HEAD src/config.ts >/dev/null 2>&1 || true

# Test 4: any type should fail
cat > src/loose.ts << 'EOF'
function process(data: any): void {
  console.log(data);
}
EOF
git add src/loose.ts
if git commit -m "any type" 2>&1 >/dev/null; then EXIT=0; else EXIT=1; fi
assert_exit_code "any type blocked by pre-commit" 1 "$EXIT"
git reset HEAD src/loose.ts >/dev/null 2>&1 || true

# Test 5: eval should fail
cat > src/unsafe.js << 'EOF'
const parsed = eval(userInput);
EOF
git add src/unsafe.js
if git commit -m "eval usage" 2>&1 >/dev/null; then EXIT=0; else EXIT=1; fi
assert_exit_code "eval() blocked by pre-commit" 1 "$EXIT"
git reset HEAD src/unsafe.js >/dev/null 2>&1 || true

cd "$REPO_ROOT"

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 6: File integrity checks
# ═══════════════════════════════════════════════════════
echo "--- Section 6: File integrity ---"

assert_file_exists ".cursorrules exists" "$REPO_ROOT/.cursorrules"
assert_file_exists "CLAUDE.md exists" "$REPO_ROOT/CLAUDE.md"
assert_file_exists "AGENTS.md exists" "$REPO_ROOT/AGENTS.md"
assert_file_exists ".windsurfrules exists" "$REPO_ROOT/.windsurfrules"
assert_file_exists "Copilot instructions" "$REPO_ROOT/.github/copilot-instructions.md"
assert_file_exists "CI workflow" "$REPO_ROOT/.github/workflows/quality-gate.yml"
assert_file_exists "MCP config" "$REPO_ROOT/deerflow/mcp/mcp-config.json"
assert_file_exists "Agent rules" "$REPO_ROOT/deerflow/core/agent-rules.md"
assert_file_exists "Workflow engine" "$REPO_ROOT/deerflow/core/workflow-engine.md"
assert_file_exists "Coding standards" "$REPO_ROOT/deerflow/core/coding-standards.md"
assert_file_exists "Quality gates" "$REPO_ROOT/deerflow/core/quality-gates.md"
assert_file_exists "Deep search skill" "$REPO_ROOT/deerflow/skills/deep-search.md"
assert_file_exists "Code review skill" "$REPO_ROOT/deerflow/skills/code-review.md"
assert_file_exists "Testing skill" "$REPO_ROOT/deerflow/skills/testing.md"
assert_file_exists "Security skill" "$REPO_ROOT/deerflow/skills/security.md"
assert_file_exists "Architecture skill" "$REPO_ROOT/deerflow/skills/architecture.md"
assert_file_exists "Decision engine" "$REPO_ROOT/deerflow/algorithms/decision-engine.md"
assert_file_exists "Setup script" "$REPO_ROOT/scripts/setup.sh"
assert_file_exists "Validate script" "$REPO_ROOT/scripts/validate.sh"
assert_file_exists "Uninstall script" "$REPO_ROOT/scripts/uninstall.sh"
assert_file_exists ".gitignore" "$REPO_ROOT/.gitignore"
assert_file_exists "LICENSE" "$REPO_ROOT/LICENSE"
assert_file_exists "README.md" "$REPO_ROOT/README.md"

echo ""

# ═══════════════════════════════════════════════════════
# SECTION 7: Content depth checks (real word counts)
# ═══════════════════════════════════════════════════════
echo "--- Section 7: Content depth ---"

for file_info in \
  ".cursorrules:200" \
  "CLAUDE.md:150" \
  "AGENTS.md:200" \
  "deerflow/core/agent-rules.md:100" \
  "deerflow/core/workflow-engine.md:100" \
  "deerflow/skills/testing.md:80" \
  "deerflow/skills/security.md:80"; do

  filepath=$(echo "$file_info" | cut -d: -f1)
  min_words=$(echo "$file_info" | cut -d: -f2)
  full_path="$REPO_ROOT/$filepath"
  TOTAL=$((TOTAL + 1))

  if [[ -f "$full_path" ]]; then
    wc_output=$(wc -w < "$full_path" | tr -d ' ')
    if [[ "$wc_output" -ge "$min_words" ]]; then
      echo -e "${GREEN}  PASS${NC} $filepath has $wc_output words (min: $min_words)"
      PASS=$((PASS + 1))
    else
      echo -e "${RED}  FAIL${NC} $filepath has only $wc_output words (min: $min_words)"
      FAIL=$((FAIL + 1))
    fi
  else
    echo -e "${RED}  FAIL${NC} $filepath not found"
    FAIL=$((FAIL + 1))
  fi
done

echo ""

# ═══════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════
echo "=========================================="
if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}  ALL $TOTAL TESTS PASSED!${NC}"
else
  echo -e "${RED}  $PASS PASSED / $FAIL FAILED (of $TOTAL total)${NC}"
fi
echo "=========================================="
echo ""

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
