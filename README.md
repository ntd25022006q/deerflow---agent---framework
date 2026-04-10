<p align="center">
  <h1 align="center">🦌 Deerflow Agent Framework</h1>
  <p align="center">
    <strong>Universal AI Agent Governance & Quality Assurance</strong>
  </p>
  <p align="center">
    <em>One repository to rule them all. One <code>git clone</code> to enforce production-grade standards on EVERY AI coding agent.</em>
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
    <img src="https://img.shields.io/badge/agents-15+-purple" alt="Compatible Agents">
    <img src="https://img.shields.io/badge/quality_gates-7-orange" alt="Quality Gates">
  </p>
</p>

---

## 🎯 What Is This?

**Deerflow** is a universal governance framework that forces ALL AI coding agents to follow strict, production-grade standards. It addresses 31 critical problems with current AI-assisted development — from code quality issues to security vulnerabilities, from fabricated information to broken builds.

**One command to install. Zero tolerance for bad code.**

```bash
cd your-project
git clone https://github.com/YOUR_USER/deerflow-agent-framework.git /tmp/deerflow
cp -r /tmp/deerflow/. .
rm -rf /tmp/deerflow
bash scripts/setup.sh
```

That's it. Now EVERY AI agent that works on your project is bound by Deerflow rules.

---

## 🤖 Compatible AI Agents (15+)

| Agent | Rule File | Status |
|-------|-----------|--------|
| **Cursor IDE** | `.cursorrules` | ✅ Full |
| **Claude Code** (Anthropic) | `CLAUDE.md` | ✅ Full |
| **GitHub Copilot** | `.github/copilot-instructions.md` | ✅ Full |
| **Windsurf** (Codeium) | `.windsurfrules` | ✅ Full |
| **Aider** | `AGENTS.md` | ✅ Full |
| **Continue** | `.cursorrules` | ✅ Full |
| **Augment Code** | `.cursorrules` | ✅ Full |
| **Cline** | `.cursorrules` | ✅ Full |
| **Gemini Code Assist** | `AGENTS.md` | ✅ Full |
| **Amazon Q Developer** | `AGENTS.md` | ✅ Full |
| **Tabnine** | `.cursorrules` | ✅ Full |
| **OpenAI Codex** | `AGENTS.md` | ✅ Full |
| **Supermaven** | `.cursorrules` | ✅ Full |
| **Zed AI** | `.cursorrules` | ✅ Full |
| **Any LLM via IDE** | `AGENTS.md` | ✅ Full |

---

## 🏗️ Architecture

```
deerflow-agent-framework/
├── .cursorrules                          # Cursor IDE rules (PRIMARY)
├── CLAUDE.md                             # Claude Code rules
├── AGENTS.md                             # Universal agent rules
├── .windsurfrules                        # Windsurf rules
├── .github/
│   ├── copilot-instructions.md           # GitHub Copilot rules
│   └── workflows/
│       └── quality-gate.yml              # CI/CD quality pipeline
├── deerflow/
│   ├── core/
│   │   ├── agent-rules.md                # Rule classification engine (P0-P3)
│   │   ├── workflow-engine.md            # Agentic Workflow (9-phase pipeline)
│   │   ├── coding-standards.md           # Language-agnostic coding standards
│   │   └── quality-gates.md              # Quality gate definitions & thresholds
│   ├── skills/
│   │   ├── deep-search.md                # Research & verification protocol
│   │   ├── code-review.md                # Self-audit & anti-domino review
│   │   ├── testing.md                    # Testing framework & patterns
│   │   ├── security.md                   # Security audit checklist
│   │   └── architecture.md               # System design & patterns
│   ├── hooks/
│   │   └── pre-commit/
│   │       ├── validate-safety.sh        # File safety validator
│   │       └── validate-quality.sh       # Code quality validator
│   ├── algorithms/
│   │   └── decision-engine.md            # Agent decision algorithms
│   ├── mcp/
│   │   └── mcp-config.json               # MCP server configuration
│   ├── templates/
│   │   └── worklog-template.md           # Session worklog template
│   └── logs/                             # Auto-generated worklogs
├── scripts/
│   ├── setup.sh                          # One-command installation
│   ├── validate.sh                       # Project health check
│   └── uninstall.sh                      # Clean removal
└── docs/
    └── (documentation)
```

---

## 🚀 Quick Start

### Option 1: Clone & Copy (Recommended)

```bash
# 1. Navigate to your project
cd your-existing-project

# 2. Clone Deerflow to a temp directory
git clone https://github.com/YOUR_USER/deerflow-agent-framework.git /tmp/deerflow

# 3. Copy all Deerflow files into your project
cp /tmp/deerflow/.cursorrules .
cp /tmp/deerflow/CLAUDE.md .
cp /tmp/deerflow/AGENTS.md .
cp /tmp/deerflow/.windsurfrules .
cp -r /tmp/deerflow/.github .
cp -r /tmp/deerflow/deerflow .
cp -r /tmp/deerflow/scripts .

# 4. Run setup to install hooks and verify
bash scripts/setup.sh

# 5. Clean up
rm -rf /tmp/deerflow

# 6. Verify installation
bash scripts/validate.sh
```

### Option 2: One-Liner

```bash
cd your-project && \
git clone https://github.com/YOUR_USER/deerflow-agent-framework.git /tmp/deerflow && \
cp -r /tmp/deerflow/. . && \
rm -rf /tmp/deerflow/.git && \
bash scripts/setup.sh && \
rm -rf /tmp/deerflow && \
bash scripts/validate.sh
```

### Option 3: Git Submodule

```bash
cd your-project
git submodule add https://github.com/YOUR_USER/deerflow-agent-framework.git deerflow-framework
cp deerflow-framework/.cursorrules .
cp deerflow-framework/CLAUDE.md .
cp deerflow-framework/AGENTS.md .
cp -r deerflow-framework/.github .
cp -r deerflow-framework/deerflow .
cp -r deerflow-framework/scripts .
bash scripts/setup.sh
```

---

## 🛡️ The 5-Layer Enforcement System

Deerflow doesn't rely on a single mechanism. It uses **5 layers** of enforcement to ensure compliance:

### Layer 1: Agent Self-Governance
Rules are injected via `.cursorrules`, `CLAUDE.md`, `AGENTS.md`. Agents read these files automatically and MUST follow them. The rules are comprehensive (300+ lines) and cover every aspect of development.

### Layer 2: Pre-Commit Hooks
Before every `git commit`, automated shell scripts check for:
- Destructive patterns (`rm -rf`, `git reset --hard`)
- Hardcoded secrets (API keys, tokens, passwords)
- Forbidden `any` types in TypeScript
- Empty catch blocks
- `console.log` in production code
- `eval()` and unsafe patterns
- TODO/FIXME markers

### Layer 3: CI/CD Pipeline (GitHub Actions)
On every push and PR, GitHub Actions run:
- **Gate 1**: Safety analysis (destructive patterns, secrets)
- **Gate 2**: Code quality (TypeScript strict, ESLint, any-type scan)
- **Gate 3**: Test suite (all tests + coverage report)
- **Gate 4**: Build integrity (size check, asset verification)
- **Gate 5**: Dependency audit (vulnerabilities, conflicts)

### Layer 4: MCP Server (Runtime Validation)
The included MCP server configuration provides on-demand validation tools that agents can call during development:
- `check_rule_violation` — Check code against Deerflow rules
- `verify_library` — Verify npm/pypi packages exist
- `verify_import` — Verify import paths are valid
- `file_safety_check` — Validate file operations before execution
- `quality_gate_check` — Run quality gates on demand
- `log_work` — Maintain session worklog

### Layer 5: Decision Algorithms
7 deterministic algorithms that govern agent decision-making:
1. **Task Classification** — Route tasks to correct approach
2. **Strategy Selection** — Choose best implementation strategy
3. **Dependency Resolution** — Prevent conflicts
4. **Context Management** — Prevent context decay
5. **Quality Evaluation** — Score code changes
6. **Anti-Fabrication** — Verify technical claims
7. **Error Recovery** — Systematic error handling

---

## 📋 The 31 Problems Solved

| # | Problem | Solution |
|---|---------|----------|
| 1 | AI describes UI differently than what it codes | Rule 3: UI/UX Consistency + Code Review Skill |
| 2 | Deletes important directories/files | Rule 1: Data Safety + Pre-commit Hook |
| 3 | Incomplete bug fixes cause more errors | Testing Skill + Quality Gates |
| 4 | Work is superficial, no theoretical foundation | Workflow Engine Phase 1-3 + Architecture Skill |
| 5 | Disconnected, fragmented layout | Architecture Skill + Feature-Based Pattern |
| 6 | Uses mock data instead of real implementation | Rule 2.1: No Mock Data in Production |
| 7 | Infinite loops and unbounded recursion | Rule 2.2: No Infinite Loops + Testing |
| 8 | Code doesn't work after completion | Rule 2.4: No Broken Code + Build Verification |
| 9 | Ugly UI | Coding Standards: Design Token System + A11y |
| 10 | Fix one thing, breaks another (domino) | Code Review: Integration Analysis + Impact Matrix |
| 11 | Library conflicts, screen flashing | Dependency Management + Pre-commit Hook |
| 12 | Fabricates info, doesn't check GitHub | Deep Search Skill + Anti-Fabrication Algorithm |
| 13 | Missing testing tools and MCP | Full testing framework + MCP server config |
| 14 | Build output too small (missing assets) | Build Verification Gate + Size Thresholds |
| 15 | Missing tools for proper operation | Setup script + dependency recommendations |
| 16 | No Agent Skills for accuracy | 5 specialized skills defined |
| 17 | No constraints on agent behavior | P0-P3 Rule Classification + Zero Tolerance |
| 18 | Misunderstands user requirements | Workflow Step 1: Comprehend (3x reading) |
| 19 | No deep search for accurate info | Deep Search Skill + Mandatory Research Protocol |
| 20 | Takes shortcuts instead of best methods | Strategy Selection Algorithm + Anti-Shortcut Rule |
| 21 | Lacks deep thinking (theory to practice) | Architecture Skill + Coding Standards |
| 22 | Code degrades over time | Maintainability Strategies + Quality Gates |
| 23 | Extremely poor security | Security Skill + Pre-commit Security Scan |
| 24 | Suboptimal algorithms | Algorithm Decision Engine + Complexity Rules |
| 25 | Poor code logic | Code Review Skill + Quality Scoring |
| 26 | Makes up answers, irrelevant responses | Rule 10: Communication + Anti-Fabrication |
| 27 | Loses proxy/VPN/VPS connection | Infrastructure checks in validation |
| 28 | Long context causes forgetting | Context Decay Prevention Algorithm + Worklog |
| 29 | Wastes massive amounts of tokens | Token Efficiency Rules + Context Management |
| 30 | No framework for standards | Deerflow Workflow Engine (the framework itself) |
| 31 | No quality gate for output | 5-Gate Quality Pipeline (CI/CD + Pre-commit) |

---

## 🔧 The Deerflow Workflow

Every task MUST follow this 9-phase pipeline:

```
1. COMPREHEND  → Read task 3×, paraphrase, confirm understanding
2. INVESTIGATE → Read codebase, search docs, verify everything
3. PLAN        → Detailed file-by-file implementation plan
4. CROSS-CHECK → Verify no breakage, dependency compatibility
5. IMPLEMENT   → Write production-quality code following all rules
6. TEST        → Write + run tests, fix all failures
7. VALIDATE    → Lint, type-check, build, size check, asset check
8. INTEGRATE   → Verify no regressions, update documentation
9. REPORT      → Summarize changes with evidence
```

Each phase has mandatory entry/exit conditions. Skipping any phase is a violation.

---

## 📊 Quality Gates

| Gate | What It Checks | Blocking? |
|------|---------------|-----------|
| Safety | No destructive patterns, no secrets | 🔴 YES |
| Types | No `any`, strict TypeScript | 🔴 YES |
| Lint | Zero ESLint warnings | 🟡 WARN |
| Tests | All tests pass, coverage threshold | 🔴 YES |
| Build | Success, reasonable size, assets included | 🔴 YES |
| Security | No vulnerabilities, no hardcoded secrets | 🔴 YES |
| Dependencies | No conflicts, no critical vulnerabilities | 🟡 WARN |

---

## 📜 License

MIT License — Use freely in any project, personal or commercial.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-improvement`
3. Run `bash scripts/validate.sh` before committing
4. All PRs must pass CI quality gates
5. Submit PR with description of changes

---

## ⭐ Star This Repo

If Deerflow saves your projects from AI-generated chaos, give it a star! It helps other developers discover a better way to work with AI agents.

---

<p align="center">
  <em>Built for developers who demand production-grade quality from AI agents.</em><br>
  <strong>Not a sandbox. Not a playground. Real standards for real projects.</strong>
</p>
