# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW — QUALITY GATES v1.0
# ═══════════════════════════════════════════════════════════════════════
# Automated quality checkpoints enforced at multiple layers.
# No code can pass through without meeting ALL gate criteria.
# ═══════════════════════════════════════════════════════════════════════

## GATE ARCHITECTURE

```
Code Change
  │
  ├─► Gate 0: Pre-Write Safety Check
  │    ├─ File exists? → YES: Read first
  │    ├─ Path correct? → Verify
  │    ├─ Destructive? → HALT if yes
  │    └─ Pass → Continue to write
  │
  ├─► Gate 1: Code Quality (Pre-Commit)
  │    ├─ TypeScript strict compilation
  │    ├─ ESLint zero warnings
  │    ├─ Prettier formatting check
  │    ├─ No console.log in production
  │    ├─ No `any` types
  │    ├─ No TODO/FIXME in new code
  │    └─ Pass → Allow commit
  │
  ├─► Gate 2: Test Coverage (Pre-Commit)
  │    ├─ All new functions have tests
  │    ├─ All existing tests pass
  │    ├─ Coverage threshold met (>80%)
  │    ├─ No skipped tests without justification
  │    └─ Pass → Allow commit
  │
  ├─► Gate 3: Security Scan (CI)
  │    ├─ No hardcoded secrets
  │    ├─ No SQL injection patterns
  │    ├─ No XSS patterns
  │    ├─ No eval() usage
  │    ├─ Dependency vulnerability audit
  │    └─ Pass → Allow merge
  │
  ├─► Gate 4: Build Integrity (CI)
  │    ├─ Build succeeds
  │    ├─ Output size reasonable (>50KB for web apps)
  │    ├─ All assets included
  │    ├─ No missing modules
  │    ├─ No console errors
  │    └─ Pass → Allow deploy
  │
  └─► Gate 5: Integration Check (CI)
       ├─ No dependency conflicts
       ├─ No breaking API changes
       ├─ All routes respond correctly
       ├─ All UI elements render
       └─ Pass → Ready for production
```

## THRESHOLD DEFINITIONS

### Build Size Thresholds
| Project Type | Minimum Size | Warning Size | Target Size |
|-------------|-------------|-------------|-------------|
| Next.js App | 50KB | < 100KB | 500KB - 5MB |
| React SPA | 50KB | < 100KB | 300KB - 3MB |
| Node.js API | 10KB | < 30KB | 100KB - 1MB |
| Full Stack | 100KB | < 200KB | 1MB - 10MB |

### Test Coverage Thresholds
| File Type | Minimum Coverage | Target Coverage |
|-----------|-----------------|-----------------|
| Services | 90% | 95% |
| Components | 80% | 90% |
| Utilities | 95% | 100% |
| Hooks | 85% | 90% |

### Performance Thresholds
| Metric | Maximum | Target |
|--------|---------|--------|
| First Contentful Paint | 1.8s | < 1.2s |
| Largest Contentful Paint | 2.5s | < 2.0s |
| Time to Interactive | 3.8s | < 3.0s |
| Cumulative Layout Shift | 0.1 | < 0.05 |

## QUALITY SCORING

Each gate produces a score from 0-100:

```
Score = (Passed Checks / Total Checks) × 100

┌──────────┬─────────────────────────────────────┐
│ 90-100   │ EXCELLENT — Proceed                  │
│ 80-89    │ GOOD — Proceed with noted warnings   │
│ 70-79    │ ACCEPTABLE — Fix warnings before next │
│ 60-69    │ MARGINAL — Must fix before proceed   │
│ < 60     │ FAILING — Cannot proceed             │
└──────────┴─────────────────────────────────────┘
```

## AUTOMATED ENFORCEMENT

### Pre-Commit (deerflow/hooks/pre-commit/)
Runs automatically on every `git commit`:
- TypeScript compilation check
- ESLint with zero-warning policy
- Test execution
- File safety verification
- Build size preliminary check

### CI/CD (.github/workflows/quality-gate.yml)
Runs automatically on every push and PR:
- Full test suite with coverage
- Security scanning (npm audit)
- Build verification
- Bundle analysis
- Accessibility check (if applicable)
- Performance audit (Lighthouse)

### Runtime (deerflow/mcp/)
MCP server provides on-demand checking:
- Agent can query: "Does this change pass quality gates?"
- Real-time feedback during development
- Rule lookup: "What are the rules for X?"
