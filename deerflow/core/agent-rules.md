# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW CORE — AGENT RULES ENGINE v1.0
# ═══════════════════════════════════════════════════════════════════════
# This is the authoritative rule engine for the Deerflow framework.
# All agent behavior is governed by these rules.
# Priority: CRITICAL > HIGH > MEDIUM > LOW > INFO
# ═══════════════════════════════════════════════════════════════════════

## RULE CLASSIFICATION

### P0 — CRITICAL (Violation = Immediate Halt + Revert)
These rules have ZERO tolerance. Any violation requires immediate stop,
revert of all changes, and re-evaluation before continuing.

| ID | Rule | Applies To |
|----|------|------------|
| P0-01 | NEVER delete files/directories without explicit user permission | File Ops |
| P0-02 | NEVER use destructive git operations (reset --hard, clean -fdx) | Git |
| P0-03 | NEVER hardcode secrets, API keys, or credentials | Security |
| P0-04 | NEVER use eval(), innerHTML, dangerouslySetInnerHTML | Security |
| P0-05 | NEVER fabricate library APIs, import paths, or package names | Integrity |
| P0-06 | NEVER commit code that doesn't compile or fails type checking | Quality |
| P0-07 | NEVER skip the Deerflow Pipeline workflow | Process |
| P0-08 | NEVER write production code with mock/hardcoded data | Quality |
| P0-09 | NEVER create infinite loops or unbounded recursions | Safety |
| P0-10 | NEVER ignore test failures or skip tests without justification | Testing |

### P1 — HIGH (Violation = Warning + Must Fix Before Continue)

| ID | Rule | Applies To |
|----|------|------------|
| P1-01 | Always use strict TypeScript — no `any` type allowed | Types |
| P1-02 | Always verify npm packages exist before installing | Dependencies |
| P1-03 | Always check peer dependency compatibility | Dependencies |
| P1-04 | Always include proper error handling for all operations | Errors |
| P1-05 | Always verify build output size is reasonable | Build |
| P1-06 | Always ensure all static assets are in build output | Build |
| P1-07 | Always test UI in multiple viewport sizes | UI/UX |
| P1-08 | Always use web search to verify uncertain technical details | Research |
| P1-09 | Always maintain session worklog of all changes | Tracking |
| P1-10 | Always verify no regressions after changes | Integration |

### P2 — MEDIUM (Violation = Log + Fix In Next Iteration)

| ID | Rule | Applies To |
|----|------|------------|
| P2-01 | Use design tokens instead of hardcoded values | UI/UX |
| P2-02 | Write JSDoc comments for all public functions | Documentation |
| P2-03 | Follow existing code patterns and conventions | Consistency |
| P2-04 | Optimize for readability before performance | Code Quality |
| P2-05 | Include accessibility attributes (ARIA, semantic HTML) | Accessibility |

### P3 — LOW (Best Practice — Encouraged)

| ID | Rule | Applies To |
|----|------|------------|
| P3-01 | Use meaningful variable/function names | Naming |
| P3-02 | Keep functions under 50 lines | Structure |
| P3-03 | Prefer composition over inheritance | Architecture |
| P3-04 | Use early returns to reduce nesting | Style |
| P3-05 | Document WHY, not just WHAT | Documentation |

## ENFORCEMENT MECHANISM

### Layer 1: Agent Self-Governance
- Rules are injected via .cursorrules, CLAUDE.md, AGENTS.md
- Agent must self-check before every action
- Agent must report violations in worklog

### Layer 2: Pre-Commit Hooks
- Automated checks before every git commit
- Blocks commits that violate rules
- See: deerflow/hooks/pre-commit/

### Layer 3: CI/CD Pipeline
- Quality gates enforced on every push/PR
- Blocks merge if any gate fails
- See: .github/workflows/quality-gate.yml

### Layer 4: Runtime Validation
- MCP server provides real-time rule checking
- Agent can query rule status at any time
- See: deerflow/mcp/mcp-config.json

## VIOLATION HANDLING

```
Violation Detected
  │
  ├─ P0 (Critical)
  │   └─ IMMEDIATE HALT → Revert Changes → Log → Re-evaluate
  │
  ├─ P1 (High)
  │   └─ WARNING → Fix Before Continue → Log
  │
  ├─ P2 (Medium)
  │   └─ LOG → Schedule Fix → Continue with awareness
  │
  └─ P3 (Low)
      └─ NOTE → Encourage improvement → No block
```

## TOKEN EFFICIENCY RULES

To address token waste (Problem #29):
- Agents must plan before acting (reduces back-and-forth)
- Agents must batch related changes (reduces context switches)
- Agents must use surgical edits, not full file rewrites
- Agents must track what they've already done (avoid re-reading)
- Context summaries every 10 actions to prevent context bloat
- Maximum 3 attempts per task before escalating to user
