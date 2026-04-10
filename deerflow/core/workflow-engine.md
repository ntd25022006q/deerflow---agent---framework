# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW — AGENTIC WORKFLOW ENGINE v1.0
# ═══════════════════════════════════════════════════════════════════════
# Implements a rigorous multi-phase workflow that AI agents MUST follow.
# Based on the "Plan → Verify → Execute → Validate" paradigm.
# Each phase has mandatory entry/exit conditions.
# ═══════════════════════════════════════════════════════════════════════

## WORKFLOW ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEERFLOW AGENTIC WORKFLOW                        │
│                                                                     │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────────┐  │
│  │  PHASE 1 │───>│   PHASE 2    │───>│       PHASE 3            │  │
│  │ COMPREHEND│    │   ARCHITECT  │    │      EXECUTE             │  │
│  │  & PLAN   │    │   & VERIFY   │    │    & VALIDATE            │  │
│  └──────────┘    └──────────────┘    └──────────────────────────┘  │
│       │                 │                        │                  │
│       ▼                 ▼                        ▼                  │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────────┐  │
│  │ Gate 1:  │    │  Gate 2:     │    │  Gate 3:                 │  │
│  │ Task     │    │  Plan        │    │  Quality                 │  │
│  │ Clarity  │    │  Feasibility │    │  Assurance               │  │
│  └──────────┘    └──────────────┘    └──────────────────────────┘  │
│                                                                     │
│  Each gate MUST pass before proceeding to next phase.               │
│  Gate failure → Return to previous phase → Fix → Retry.            │
└─────────────────────────────────────────────────────────────────────┘
```

## PHASE 1: COMPREHEND & PLAN

### Step 1.1: Task Analysis (MANDATORY)
```
Input: User's task description
Output: Structured task understanding

Actions:
  1. Read the task description THREE times
  2. Identify: What, Why, How, Constraints
  3. List ALL affected files, modules, dependencies
  4. Identify potential risks and edge cases
  5. Write a task summary and get confirmation

Gate 1 Check:
  □ Task is fully understood (can paraphrase back)
  □ All affected files are identified
  □ Dependencies are mapped
  □ Risks are identified
  □ Ambiguities are resolved (ask user if needed)
```

### Step 1.2: Research & Investigation (MANDATORY)
```
Input: Task understanding from Step 1.1
Output: Verified technical approach

Actions:
  1. Read existing codebase (related files, patterns, conventions)
  2. Check official documentation for relevant libraries
  3. Search GitHub for latest API changes/issues
  4. Verify all imports and package names exist
  5. Check for existing solutions in the project

Gate 1.5 Check:
  □ Existing codebase patterns are understood
  □ All libraries are verified to exist and be compatible
  □ Official docs have been consulted
  □ No fabricated information in the plan
```

### Step 1.3: Implementation Plan (MANDATORY)
```
Input: Research findings
Output: Detailed file-by-file implementation plan

Actions:
  1. Create ordered list of files to create/modify
  2. For each file: specify what changes and why
  3. Define function signatures and data flow
  4. Plan test cases for each component
  5. Identify rollback strategy if something goes wrong
  6. Present plan to user for approval

Gate 1 Check (Final):
  □ Plan is detailed and actionable
  □ Every file change is justified
  □ Dependencies between changes are mapped
  □ Rollback strategy exists
  □ User has approved the plan (implicit or explicit)
```

## PHASE 2: ARCHITECT & VERIFY

### Step 2.1: Dependency Verification (MANDATORY)
```
Actions:
  1. Check package.json for existing dependencies
  2. Verify no conflicts with new packages
  3. Run dependency audit (npm audit / pip check)
  4. Test import resolution
  5. Verify TypeScript types are compatible

Gate 2 Check:
  □ No dependency conflicts detected
  □ All packages are verified to exist
  □ Peer dependencies are compatible
  □ Import paths resolve correctly
```

### Step 2.2: Impact Analysis (MANDATORY)
```
Actions:
  1. List all files that import from modified files
  2. Check if type changes break dependent files
  3. Verify API contract changes are backward-compatible
  4. Check if state management is affected
  5. Verify routing changes don't break navigation

Gate 2 Check (Final):
  □ No breaking changes to dependent files
  □ API contracts are maintained or properly versioned
  □ State management remains consistent
  □ All imports will still resolve
```

## PHASE 3: EXECUTE & VALIDATE

### Step 3.1: Implementation (MANDATORY)
```
Actions:
  1. Create/modify files in dependency order
  2. Write complete implementations (no stubs)
  3. Use proper TypeScript types (strict mode)
  4. Include error handling for every operation
  5. Follow existing code patterns
  6. Commit after each logical unit of work
```

### Step 3.2: Testing (MANDATORY)
```
Actions:
  1. Write unit tests for all new functions
  2. Write integration tests for API routes
  3. Write component tests for UI changes
  4. Run ALL tests (not just new ones)
  5. Fix any test failures immediately
  6. Verify edge cases are covered

Gate 3 Pre-Check:
  □ All new code has test coverage
  □ All existing tests still pass
  □ No flaky or skipped tests
  □ Edge cases are covered
```

### Step 3.3: Build Verification (MANDATORY)
```
Actions:
  1. Run type checking (tsc --noEmit)
  2. Run linting (eslint)
  3. Run full build
  4. Verify build output size
  5. Verify static assets are included
  6. Check for console errors
  7. Verify the application runs

Gate 3 Final Check:
  □ TypeScript compiles without errors
  □ ESLint passes with zero warnings
  □ Build succeeds
  □ Build output size is reasonable
  □ All assets are included
  □ No runtime errors
  □ Application runs correctly
```

## ERROR RECOVERY PROTOCOL

```
Error at any phase:
  │
  ├─ Compilation Error
  │   └─ Fix syntax/types → Re-run build → Re-verify
  │
  ├─ Test Failure
  │   └─ Analyze failure → Fix code → Re-run tests → Re-verify
  │
  ├─ Build Failure
  │   └─ Analyze logs → Fix issue → Re-run build → Re-verify
  │
  ├─ Dependency Conflict
  │   └─ Identify conflict → Find compatible versions → Re-install
  │
  ├─ Runtime Error
  │   └─ Debug → Fix root cause → Re-test → Re-build
  │
  └─ Unknown Error
      └─ Log error → Report to user → Await instructions
```

MAXIMUM 3 RETRY ATTEMPTS PER ERROR.
After 3 failures: STOP and report to user with full diagnosis.
