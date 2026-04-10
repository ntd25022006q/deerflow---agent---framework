# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW AGENT FRAMEWORK — CLAUDE CODE INSTRUCTIONS v1.0
# ═══════════════════════════════════════════════════════════════════════
# This file enforces strict governance for Claude Code (Anthropic) agents.
# These instructions are loaded automatically when Claude Code operates
# in any repository containing this file. They CANNOT be overridden.
# ═══════════════════════════════════════════════════════════════════════

## MANDATORY: Read deerflow/core/agent-rules.md BEFORE any code action
You MUST read and fully internalize the core rules before beginning work.
If that file doesn't exist, read .cursorrules as fallback.

## CRITICAL SAFETY CONSTRAINTS

### File Safety Protocol
1. NEVER execute `rm -rf`, `rimraf`, `del /s /q`, or any recursive deletion
2. NEVER use write_file to overwrite an existing file — use Edit/MultiEdit
3. NEVER modify files outside the designated project directory
4. Before ANY file write: verify the target path exists and is correct
5. Maintain a session log of ALL file operations performed

### Code Generation Protocol
1. NEVER generate mock/hardcoded data for production components
2. NEVER create stub functions that just `return null` or `// TODO`
3. NEVER use `any` type in TypeScript — use proper types
4. NEVER leave console.log statements in production code
5. NEVER commit code that doesn't compile or fails type checking
6. EVERY function must have: purpose, parameters, return type, error handling
7. EVERY component must be fully wired — no dead UI elements

### Research Protocol
1. When using a library/API: verify against official docs FIRST
2. When uncertain: use web_search tool to verify current API
3. NEVER assume an npm package API — check npmjs.com or GitHub
4. NEVER fabricate import paths — verify they exist
5. When citing statistics or benchmarks: provide sources

### Testing Protocol
1. EVERY new function requires a corresponding test
2. EVERY bug fix requires a regression test
3. Tests must be runnable with a single command
4. Tests must pass before any commit
5. No skipped tests without documented justification

## DEERFLOW WORKFLOW — EXECUTE IN ORDER

```
Step 1: ANALYZE
  - Read task carefully (3 times minimum)
  - Identify all affected files and dependencies
  - List assumptions and verify them against codebase

Step 2: PLAN
  - Create detailed implementation plan
  - Include file paths, function signatures, data flow
  - Identify potential risks and mitigations
  - Get implicit/explicit approval before proceeding

Step 3: IMPLEMENT
  - Write code following all rules above
  - Use proper TypeScript types (strict mode)
  - Include error handling for every operation
  - Ensure proper async/await usage

Step 4: VERIFY
  - Run type checking: npx tsc --noEmit
  - Run linting: npm run lint
  - Run tests: npm test
  - Run build: npm run build
  - Verify build output size is reasonable
  - Check for console errors

Step 5: DOCUMENT
  - Update JSDoc comments for modified functions
  - Update README if public API changed
  - Log changes in CHANGELOG if applicable
```

## QUALITY CHECKLIST (MUST PASS ALL)

Before marking any task complete, verify every item:

- [ ] No accidental file deletions or modifications
- [ ] All existing tests still pass
- [ ] New code has test coverage
- [ ] TypeScript compiles without errors
- [ ] ESLint passes with zero warnings
- [ ] Build succeeds with reasonable output
- [ ] No dependency conflicts (npm ls clean)
- [ ] No hardcoded secrets or credentials
- [ ] No mock data in production code
- [ ] No `any` types in TypeScript
- [ ] All functions have proper error handling
- [ ] All UI elements are fully functional
- [ ] Security best practices followed
- [ ] Code follows existing patterns in the project

## CONTEXT MANAGEMENT

When working on large tasks:
1. Keep a running summary of changes made
2. Before each new subtask, re-read the current state
3. If context is becoming overwhelming: consolidate and summarize
4. NEVER "forget" earlier requirements — track them explicitly
5. Use the worklog file to maintain continuity

## FORBIDDEN PATTERNS

These patterns are absolutely forbidden:

```typescript
// ❌ FORBIDDEN: Mock data in production
const users = [{ name: 'John' }, { name: 'Jane' }];

// ❌ FORBIDDEN: Unbounded loops
while (true) { /* no break condition */ }

// ❌ FORBIDDEN: Any type
function process(data: any) { ... }

// ❌ FORBIDDEN: Empty error handling
catch (e) { }
catch (e) { console.log(e); }

// ❌ FORBIDDEN: Uncleaned side effects
useEffect(() => { setInterval(...) }); // no cleanup

// ❌ FORBIDDEN: Fabricated imports
import { magicalFunction } from 'nonexistent-package';
```

## RECOMMENDED PATTERNS

```typescript
// ✅ Proper error handling
try {
  const result = await api.fetchData(params);
  if (!result.success) throw new Error(result.message);
  return result.data;
} catch (error) {
  logger.error('Failed to fetch data', { params, error });
  throw new AppError('DATA_FETCH_FAILED', 'Unable to load data');
}

// ✅ Proper cleanup
useEffect(() => {
  const controller = new AbortController();
  fetchData(controller.signal);
  return () => controller.abort();
}, []);

// ✅ Proper typing
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

// ✅ Proper validation
function validateInput(input: unknown): User {
  if (!input || typeof input !== 'object') {
    throw new ValidationError('Input must be an object');
  }
  // ... detailed validation
}
```
