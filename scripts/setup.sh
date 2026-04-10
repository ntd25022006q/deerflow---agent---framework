#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SETUP — One-Command Installation v1.0
# ═══════════════════════════════════════════════════════════════════════
# Usage: bash <(curl -sL https://raw.githubusercontent.com/YOUR_USER/deerflow-agent-framework/main/scripts/setup.sh)
# Or:    cd your-project && cp -r /path/to/deerflow/. . && bash scripts/setup.sh
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🦌 DEERFLOW AGENT FRAMEWORK v1.0                     ║"
echo "║     Universal AI Agent Governance & Quality Assurance    ║"
echo "║                                                           ║"
echo "║     One-command setup for any project type                ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ──────────────────────────────────────────────
# STEP 1: Verify prerequisites
# ──────────────────────────────────────────────
echo -e "${CYAN}[1/6] Verifying prerequisites...${NC}"

PREREQS_OK=true

if ! command -v git &> /dev/null; then
  echo -e "${RED}  ❌ git is not installed${NC}"
  PREREQS_OK=false
fi

if ! command -v node &> /dev/null; then
  echo -e "${YELLOW}  ⚠️  Node.js is not installed (optional for JS projects)${NC}"
fi

if ! command -v python3 &> /dev/null; then
  echo -e "${YELLOW}  ⚠️  Python 3 is not installed (optional for Python projects)${NC}"
fi

if [[ "$PREREQS_OK" == true ]]; then
  echo -e "${GREEN}  ✅ Prerequisites verified${NC}"
else
  echo -e "${RED}  ❌ Missing required prerequisites. Install them and try again.${NC}"
  exit 1
fi

# ──────────────────────────────────────────────
# STEP 2: Detect project type
# ──────────────────────────────────────────────
echo -e "${CYAN}[2/6] Detecting project type...${NC}"

PROJECT_TYPE="unknown"

if [[ -f "package.json" ]]; then
  PROJECT_TYPE="node"
  if grep -q '"next"' package.json 2>/dev/null; then
    PROJECT_TYPE="nextjs"
  elif grep -q '"react"' package.json 2>/dev/null; then
    PROJECT_TYPE="react"
  fi
  echo -e "${GREEN}  ✅ Detected: ${PROJECT_TYPE} (package.json)${NC}"
elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
  PROJECT_TYPE="python"
  echo -e "${GREEN}  ✅ Detected: Python${NC}"
elif [[ -f "go.mod" ]]; then
  PROJECT_TYPE="go"
  echo -e "${GREEN}  ✅ Detected: Go${NC}"
elif [[ -f "Cargo.toml" ]]; then
  PROJECT_TYPE="rust"
  echo -e "${GREEN}  ✅ Detected: Rust${NC}"
else
  echo -e "${YELLOW}  ⚠️  Could not detect project type. Will install generic rules.${NC}"
fi

# ──────────────────────────────────────────────
# STEP 3: Install agent rule files
# ──────────────────────────────────────────────
echo -e "${CYAN}[3/6] Installing agent rule files...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEERFLOW_DIR="$(dirname "$SCRIPT_DIR")"

# Copy universal agent rules
FILES_TO_COPY=(
  ".cursorrules"
  "CLAUDE.md"
  "AGENTS.md"
  ".windsurfrules"
)

for file in "${FILES_TO_COPY[@]}"; do
  src="$DEERFLOW_DIR/$file"
  if [[ -f "$src" ]]; then
    if [[ -f "$file" ]]; then
      echo -e "${YELLOW}  ⚠️  $file already exists — backing up as ${file}.bak${NC}"
      cp "$file" "${file}.bak"
    fi
    cp "$src" "$file"
    echo -e "${GREEN}  ✅ Installed: $file${NC}"
  fi
done

# Copy GitHub Copilot instructions
if [[ -d ".github" ]]; then
  mkdir -p .github
fi
if [[ -f "$DEERFLOW_DIR/.github/copilot-instructions.md" ]]; then
  cp "$DEERFLOW_DIR/.github/copilot-instructions.md" ".github/copilot-instructions.md"
  echo -e "${GREEN}  ✅ Installed: .github/copilot-instructions.md${NC}"
fi

# Copy GitHub Actions workflow
if [[ -f "$DEERFLOW_DIR/.github/workflows/quality-gate.yml" ]]; then
  mkdir -p .github/workflows
  cp "$DEERFLOW_DIR/.github/workflows/quality-gate.yml" ".github/workflows/quality-gate.yml"
  echo -e "${GREEN}  ✅ Installed: .github/workflows/quality-gate.yml${NC}"
fi

# Copy core rules directory
if [[ -d "$DEERFLOW_DIR/deerflow" ]]; then
  cp -r "$DEERFLOW_DIR/deerflow" "./deerflow"
  echo -e "${GREEN}  ✅ Installed: deerflow/ directory${NC}"
fi

# ──────────────────────────────────────────────
# STEP 4: Install pre-commit hooks
# ──────────────────────────────────────────────
echo -e "${CYAN}[4/6] Installing pre-commit hooks...${NC}"

if [[ -d ".git" ]]; then
  HOOKS_DIR=".git/hooks"

  # Install safety hook
  if [[ -f "deerflow/hooks/pre-commit/validate-safety.sh" ]]; then
    chmod +x deerflow/hooks/pre-commit/validate-safety.sh
    # Create a combined hook
    cat > "$HOOKS_DIR/pre-commit" << 'HOOK_EOF'
#!/usr/bin/env bash
# Combined Deerflow pre-commit hooks
# Safety first, then quality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Run safety check
if [ -f "$PROJECT_ROOT/deerflow/hooks/pre-commit/validate-safety.sh" ]; then
  bash "$PROJECT_ROOT/deerflow/hooks/pre-commit/validate-safety.sh"
  if [ $? -ne 0 ]; then
    echo "Safety check failed. Commit blocked."
    exit 1
  fi
fi

# Run quality check
if [ -f "$PROJECT_ROOT/deerflow/hooks/pre-commit/validate-quality.sh" ]; then
  bash "$PROJECT_ROOT/deerflow/hooks/pre-commit/validate-quality.sh"
  if [ $? -ne 0 ]; then
    echo "Quality check failed. Commit blocked."
    exit 1
  fi
fi

exit 0
HOOK_EOF
    chmod +x "$HOOKS_DIR/pre-commit"
    echo -e "${GREEN}  ✅ Installed: pre-commit hook (safety + quality)${NC}"
  fi

  # Install post-commit worklog hook
  mkdir -p deerflow/logs
  cat > "$HOOKS_DIR/post-commit" << 'HOOK2_EOF'
#!/usr/bin/env bash
# Log commit to Deerflow worklog
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WORKLOG="deerflow/logs/worklog.md"

echo "" >> "$WORKLOG"
echo "---" >> "$WORKLOG"
echo "**[$TIMESTAMP]** Commit: \`$COMMIT_HASH\`" >> "$WORKLOG"
echo "$COMMIT_MSG" >> "$WORKLOG"
echo "" >> "$WORKLOG"
HOOK2_EOF
  chmod +x "$HOOKS_DIR/post-commit"
  echo -e "${GREEN}  ✅ Installed: post-commit worklog hook${NC}"

  # Create initial worklog
  if [[ ! -f "deerflow/logs/worklog.md" ]]; then
    echo "# Deerflow Worklog" > deerflow/logs/worklog.md
    echo "" >> deerflow/logs/worklog.md
    echo "Auto-generated commit log by Deerflow pre-commit hooks." >> deerflow/logs/worklog.md
    echo "" >> deerflow/logs/worklog.md
  fi
else
  echo -e "${YELLOW}  ⚠️  Not a git repository. Skipping hook installation.${NC}"
  echo -e "${YELLOW}     Run 'git init' first, then re-run this script.${NC}"
fi

# ──────────────────────────────────────────────
# STEP 5: Project-specific configuration
# ──────────────────────────────────────────────
echo -e "${CYAN}[5/6] Configuring for ${PROJECT_TYPE}...${NC}"

if [[ "$PROJECT_TYPE" == "nextjs" || "$PROJECT_TYPE" == "react" || "$PROJECT_TYPE" == "node" ]]; then
  # Install recommended dev dependencies
  if [[ -f "package.json" ]]; then
    echo -e "${YELLOW}  ℹ️  Recommended dev dependencies:${NC}"
    echo "     - typescript, @types/node, @types/react"
    echo "     - eslint, @typescript-eslint/*"
    echo "     - vitest or jest (testing)"
    echo "     - zod (runtime validation)"
    echo ""
    echo -e "${CYAN}  Run to install: npm install -D typescript @types/node eslint vitest zod${NC}"
  fi
fi

# ──────────────────────────────────────────────
# STEP 6: Verify installation
# ──────────────────────────────────────────────
echo -e "${CYAN}[6/6] Verifying installation...${NC}"

INSTALLED=0
EXPECTED_FILES=(".cursorrules" "CLAUDE.md" "AGENTS.md" "deerflow/core/agent-rules.md")

for file in "${EXPECTED_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}  ✅ $file${NC}"
    INSTALLED=$((INSTALLED + 1))
  else
    echo -e "${RED}  ❌ $file — NOT FOUND${NC}"
  fi
done

if [[ -f ".github/workflows/quality-gate.yml" ]]; then
  echo -e "${GREEN}  ✅ .github/workflows/quality-gate.yml${NC}"
  INSTALLED=$((INSTALLED + 1))
fi

if [[ -f ".git/hooks/pre-commit" ]]; then
  echo -e "${GREEN}  ✅ .git/hooks/pre-commit${NC}"
  INSTALLED=$((INSTALLED + 1))
fi

# ──────────────────────────────────────────────
# DONE
# ──────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✅ DEERFLOW AGENT FRAMEWORK INSTALLED!                ║"
echo "║                                                           ║"
echo "║     $INSTALLED/7 components active                           "
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${BOLD}What happens now:${NC}"
echo "  1. AI agents will read .cursorrules / CLAUDE.md / AGENTS.md automatically"
echo "  2. Git commits are validated by pre-commit hooks"
echo "  3. Pushes to GitHub trigger quality gate CI pipeline"
echo "  4. All code changes must pass safety + quality checks"
echo ""
echo -e "${BOLD}Agent compatibility:${NC}"
echo "  ✅ Cursor IDE (.cursorrules)"
echo "  ✅ Claude Code (CLAUDE.md)"
echo "  ✅ GitHub Copilot (.github/copilot-instructions.md)"
echo "  ✅ Windsurf (.cursorrules)"
echo "  ✅ Aider (AGENTS.md)"
echo "  ✅ Continue (.cursorrules)"
echo "  ✅ Augment Code (.cursorrules)"
echo "  ✅ Gemini Code Assist (AGENTS.md)"
echo "  ✅ Amazon Q Developer (AGENTS.md)"
echo "  ✅ Tabnine (.cursorrules)"
echo ""
echo -e "${BOLD}To uninstall:${NC}"
echo "  bash scripts/uninstall.sh"
echo ""
