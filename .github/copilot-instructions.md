# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW AGENT FRAMEWORK — GITHUB COPILOT INSTRUCTIONS v1.0
# ═══════════════════════════════════════════════════════════════════════
# Place at: .github/copilot-instructions.md
# Automatically loaded by GitHub Copilot in PR reviews and code suggestions.
# ═══════════════════════════════════════════════════════════════════════

## PROJECT GOVERNANCE

This project follows the DEERFLOW AGENT FRAMEWORK.
All AI-generated code must comply with the rules defined in:
- `.cursorrules` — Primary rule file (read this first)
- `CLAUDE.md` — Claude-specific instructions
- `AGENTS.md` — Universal agent instructions
- `deerflow/core/` — Core rule definitions

## CODE GENERATION RULES

1. **NO STUBS**: Every function must be fully implemented. No `// TODO` or placeholder returns.
2. **NO MOCK DATA**: Production code must use real data sources. Mocks only in test files.
3. **NO `any` TYPE**: Use proper TypeScript types. `unknown` + type guards if needed.
4. **NO DANGEROUS OPERATIONS**: No `eval`, `innerHTML`, `dangerouslySetInnerHTML` without explicit user request.
5. **NO UNVERIFIED IMPORTS**: Every import must reference a real, existing module.
6. **NO DESTRUCTIVE EDITS**: Never suggest deleting files, directories, or important configurations.

## CODE REVIEW CHECKLIST

When reviewing code, check for:
- [ ] TypeScript strict mode compliance
- [ ] Proper error handling (no empty catch blocks)
- [ ] No hardcoded values that should be configurable
- [ ] No missing input validation
- [ ] No memory leaks (event listener cleanup, AbortController)
- [ ] No dependency conflicts
- [ ] No security vulnerabilities (injection, XSS, CSRF)
- [ ] Test coverage for new code
- [ ] Build verification

## PULL REQUEST STANDARDS

- PRs must pass all CI checks before merge
- PRs must include tests for changed functionality
- PRs must not decrease code coverage
- PRs must not introduce new lint warnings
- PRs must have meaningful descriptions

## TESTING STANDARDS

- Every PR must include tests for new functionality
- Every bug fix must include a regression test
- Tests must be deterministic (no flaky tests)
- Test names must describe expected behavior
- Use `describe`/`it` pattern with clear descriptions
