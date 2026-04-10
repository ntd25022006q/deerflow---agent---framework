# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SKILL: CODE REVIEW & SELF-AUDIT v1.0
# ═══════════════════════════════════════════════════════════════════════
# Solves Problem #1: Describes UI one way, codes another
# Solves Problem #3: Incomplete bug fixes causing more errors
# Solves Problem #10: Fixing one thing breaks another (domino effect)
# Solves Problem #25: Poor code logic
# ═══════════════════════════════════════════════════════════════════════

## MANDATORY SELF-REVIEW PROTOCOL

After writing ANY code, you MUST perform a self-review using this checklist
BEFORE submitting or claiming the task is complete.

## PHASE 1: REQUIREMENT TRACEABILITY

```
For each requirement in the task description:
  □ Is it implemented? (Yes/No/Partial)
  □ Where is it implemented? (File:Line)
  □ Is the implementation complete or stubbed?
  □ Does it match the EXACT specification?

If ANY requirement is "No" or "Partial":
  → STOP — Complete the implementation
```

## PHASE 2: CODE CORRECTNESS

### Logic Review
```
□ No infinite loops (every loop has termination)
□ No unbounded recursion (base case exists)
□ No off-by-one errors
□ No null/undefined access without checking
□ No race conditions in async code
□ No memory leaks (cleanup in useEffect, event listeners)
□ No unreachable code
□ No dead code paths
□ Error conditions are handled, not ignored
□ Edge cases are considered (empty, null, boundary)
```

### Type Safety Review
```
□ No `any` type usage
□ All function parameters are typed
□ All return values are typed
□ Generic constraints are proper
□ Type assertions (as) are minimized and justified
□ Discriminated unions are used correctly
□ Optional chaining is used appropriately
```

### API Contract Review
```
□ Function signatures match their usage
□ Parameters are in the correct order
□ Return types match what callers expect
□ No breaking changes to existing APIs
□ Backward compatibility is maintained
□ Error types are consistent
```

## PHASE 3: INTEGRATION REVIEW (Anti-Domino)

### Dependency Chain Analysis
```
For EVERY file you modified:

1. IMPORT ANALYSIS
   □ List all files that import FROM this file
   □ For each importer: does the change break them?
   □ If type changed: do all consumers handle new type?

2. EXPORT ANALYSIS
   □ List all exports that were changed
   □ For each changed export: who uses it?
   □ Are all consumers updated?

3. STATE ANALYSIS
   □ If state shape changed: are all consumers updated?
   □ If API response changed: are all handlers updated?
   □ If config changed: are all readers updated?
```

### Change Impact Matrix
```
| File Modified | Imports From | Exports To | Impact Level | Verified |
|---------------|-------------|------------|-------------|----------|
| fileA.ts      | fileB.ts    | fileC.ts   | LOW         | ✅       |
| fileD.ts      | fileA.ts    | fileE.ts   | HIGH        | ⚠️       |
```

If ANY impact is HIGH: re-verify the affected consumer files.

## PHASE 4: REQUIREMENT MATCHING (Anti-Mismatch)

### UI/UX Matching
```
□ Does the implementation match the described UI EXACTLY?
□ Same layout structure?
□ Same component hierarchy?
□ Same styling approach?
□ Same interactive behavior?
□ Same responsive breakpoints?
□ Same content and labels?
□ Same accessibility features?

If ANY mismatch: fix it. Not "close enough" — EXACT.
```

### Functional Matching
```
□ Does the implementation do what was described?
□ All features implemented, not just some?
□ Same data flow as specified?
□ Same error handling as specified?
□ Same edge case behavior?
```

## PHASE 5: QUALITY SCORING

Score your changes:

| Category | Weight | Score (0-10) | Weighted |
|----------|--------|-------------|----------|
| Correctness | 30% | __ | __ |
| Completeness | 25% | __ | __ |
| Type Safety | 15% | __ | __ |
| Error Handling | 10% | __ | __ |
| Integration | 10% | __ | __ |
| Performance | 10% | __ | __ |
| **TOTAL** | **100%** | | __ |

Minimum passing score: **7.0/10**
If below 7.0: Identify weakest areas and improve before submitting.

## PHASE 6: DOCUMENTATION CHECK

```
□ JSDoc comments on public functions
□ README updated if public API changed
□ CHANGELOG entry if significant change
□ Inline comments for complex logic
□ Type documentation for complex types
```

## REVIEW OUTPUT TEMPLATE

```markdown
## Self-Review Report

**Task**: [Description]
**Files Modified**: [List]
**Review Score**: [X.X/10]

### Changes Summary:
- [What was changed]

### Verification:
- ✅ All requirements implemented
- ✅ All tests pass
- ✅ No regressions detected
- ✅ Integration verified
- ✅ Build succeeds

### Remaining Concerns:
- [None, or list of minor items]
```
