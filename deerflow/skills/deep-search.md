# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SKILL: DEEP SEARCH & VERIFICATION v1.0
# ═══════════════════════════════════════════════════════════════════════
# Solves Problem #12: AI fabricates info instead of verifying
# Solves Problem #19: No deep search/web search for accurate info
# Solves Problem #20: Takes shortcuts instead of best methods
# Solves Problem #21: Lacks deep thinking — theory into practice
# ═══════════════════════════════════════════════════════════════════════

## SKILL OVERVIEW

This skill enforces a rigorous research methodology that prevents
AI agents from fabricating information and ensures they always use
verified, up-to-date technical information.

## MANDATORY RESEARCH PROTOCOL

### Rule: VERIFY BEFORE YOU CODE

Before using ANY library, API, function, or configuration:

```
Step 1: IDENTIFY what you need to verify
  - Library/package name
  - API endpoint or function signature
  - Configuration option
  - Code pattern or best practice

Step 2: SEARCH for authoritative sources
  Priority order:
    1. Official documentation (docs.{library}.com)
    2. GitHub repository (README, API docs, examples)
    3. Stack Overflow (highest voted answers)
    4. npm/pypi package page
    5. Developer blogs (verified authors)

Step 3: CROSS-REFERENCE multiple sources
  - Minimum 2 sources for any claim
  - If sources conflict: use the official one
  - If unsure: default to the most recent source

Step 4: VERIFY current version
  - Check latest version on npm/pypi
  - Check changelog for breaking changes
  - Check GitHub issues for known problems

Step 5: DOCUMENT findings
  - Record the source URL
  - Record the version verified
  - Record any caveats or limitations
```

### Deep Search Checklist

Before implementing any technical decision, verify:

□ The library/package exists on the registry
□ The version is compatible with project requirements
□ The API you're using exists in the current version
□ The import path is correct
□ Peer dependencies are compatible
□ There are no known critical issues
□ The approach is recommended by the library maintainers
□ There's no better alternative available

### Web Search Protocol

When searching for information:
1. Use specific, technical search queries
2. Include version numbers in searches (e.g., "next.js 15 app router")
3. Check the date of the article/resource
4. Prefer official sources over blogs
5. Verify information by testing in code when possible
6. Never assume — always confirm

## VERIFICATION TEMPLATES

### Library Verification Template
```markdown
## Library Verification: [Library Name]

**Source**: [URL]
**Version**: [Latest version verified]
**Last Checked**: [Date]

### API Verified:
- `functionName(param1: Type, param2: Type): ReturnType`
  - Source: [URL to API docs]
  - Available since: [version]
  - Status: ✅ Verified / ❌ Not found

### Import Verified:
- `import { X } from 'package/subpath'`
  - Source: [URL to package page]
  - Status: ✅ Works / ❌ Incorrect path

### Compatibility:
- Node.js: [min version]
- React: [min version]
- TypeScript: [min version]
- Peer Dependencies: [list]

### Known Issues:
- [Issue description and link]
```

### Technical Decision Template
```markdown
## Technical Decision: [Decision Name]

**Context**: What problem are we solving?
**Options Considered**:
1. Option A — Pros: [...], Cons: [...]
2. Option B — Pros: [...], Cons: [...]
3. Option C — Pros: [...], Cons: [...]

**Decision**: Option [X]
**Rationale**: Why this is the best choice
**Evidence**: Links to supporting documentation
**Risks**: Potential downsides and mitigations
```

## ANTI-FABRICATION RULES

### ABSOLUTELY FORBIDDEN:
- ❌ Inventing function names that don't exist in a library
- ❌ Assuming API parameters without checking documentation
- ❌ Creating import paths based on naming conventions
- ❌ Stating "this library supports X" without verification
- ❌ Citing non-existent configuration options
- ❌ Assuming version compatibility without checking
- ❌ Using deprecated APIs without noting deprecation

### REQUIRED ACTIONS:
- ✅ Search before you code (every time)
- ✅ Verify against official documentation
- ✅ Check GitHub for latest API changes
- ✅ Test in code when uncertain
- ✅ Provide source URLs for technical claims
- ✅ Acknowledge uncertainty honestly

## BEST METHOD SELECTION (Anti-Shortcut)

When choosing between approaches:
1. Evaluate ALL reasonable options (minimum 3)
2. Score each on: correctness, maintainability, performance, simplicity
3. Choose the HIGHEST SCORING option, not the easiest to implement
4. Document why other options were rejected
5. Consider long-term implications (6 months, 1 year, 5 years)
