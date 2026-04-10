# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SKILL: ARCHITECTURE & SYSTEM DESIGN v1.0
# ═══════════════════════════════════════════════════════════════════════
# Solves Problem #4: Work is superficial, no theoretical foundation
# Solves Problem #5: Disconnected, fragmented layout
# Solves Problem #22: Code degrades over time
# Solves Problem #24: Suboptimal code structure and algorithms
# ═══════════════════════════════════════════════════════════════════════

## ARCHITECTURE PHILOSOPHY

Good architecture is not about choosing the "right" framework or
the "trendiest" library. It's about making deliberate decisions that
serve the project's goals, are maintainable over time, and can
evolve as requirements change.

## SOLID PRINCIPLES — APPLIED

### S: Single Responsibility
```
One component = One concern
One function = One operation
One file = One module

If you can't describe what a component does in ONE sentence,
it's doing too much. Split it.
```

### O: Open/Closed
```
Extend behavior by adding NEW code, not modifying EXISTING code.
Use composition over inheritance.
Use dependency injection for swappable implementations.
Use plugins/middleware for cross-cutting concerns.
```

### L: Liskov Substitution
```
If S is a subtype of T, then objects of type T may be replaced
with objects of type S without altering correctness.

Applied: Interface-based programming, not concrete classes.
```

### I: Interface Segregation
```
Don't force clients to depend on interfaces they don't use.
Small, focused interfaces > Large, general ones.
```

### D: Dependency Inversion
```
High-level modules should not depend on low-level modules.
Both should depend on abstractions (interfaces).

Applied: Service layer pattern, dependency injection.
```

## ARCHITECTURAL PATTERNS

### Recommended Pattern: Feature-Based Architecture
```
src/
├── features/
│   ├── auth/
│   │   ├── components/      # Auth-specific components
│   │   ├── hooks/           # Auth hooks (useAuth, useLogin)
│   │   ├── services/        # Auth API calls
│   │   ├── types/           # Auth types
│   │   ├── utils/           # Auth utilities
│   │   └── index.ts         # Public exports
│   │
│   ├── dashboard/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types/
│   │   └── index.ts
│   │
│   └── settings/
│       └── ...
│
├── shared/
│   ├── components/          # Reusable UI components
│   ├── hooks/               # Reusable hooks
│   ├── utils/               # Shared utilities
│   ├── types/               # Shared types
│   └── constants/           # App-wide constants
│
├── app/                     # Next.js App Router pages
├── lib/                     # Third-party library configs
└── styles/                  # Global styles, design tokens
```

Benefits:
- Features are self-contained and independent
- Easy to add/remove features
- Clear dependency boundaries
- Team members can work on different features
- Each feature can be tested independently

### Layered Architecture for API
```
Controller Layer → validates input, calls services
  ↓
Service Layer → business logic, orchestrates operations
  ↓
Repository Layer → data access, database operations
  ↓
Database → persistent storage
```

### Error Handling Architecture
```
Error Classification:
├── DomainError      → Business rule violation (400)
├── NotFoundError    → Resource not found (404)
├── ConflictError    → Duplicate resource (409)
├── AuthenticationError → Invalid credentials (401)
├── AuthorizationError → Insufficient permissions (403)
├── RateLimitError   → Too many requests (429)
└── InternalError    → Unexpected server error (500)

Each error type:
- Has a unique code
- Maps to HTTP status
- Includes user-friendly message
- Logs full context for debugging
```

## ANTI-PATTERNS TO AVOID

### ❌ God Component
```typescript
// BAD: Component doing everything
function Dashboard() {
  // Fetches data
  // Manages state
  // Renders charts
  // Handles user input
  // Manages authentication
  // Handles routing
}
```

### ❌ Prop Drilling
```typescript
// BAD: Passing props through 5 levels
function A() {
  return <B theme={theme} user={user} config={config} />;
}
function B({ theme, user, config }) {
  return <C theme={theme} user={user} />;
}
function C({ theme, user }) {
  return <D theme={theme} />;
}
function D({ theme }) {
  return <E theme={theme} />; // Finally uses it!
}
```

### ❌ Spaghetti State
```typescript
// BAD: State scattered everywhere
// Component state, context state, redux state, local storage
// All updating independently, causing race conditions
```

## MAINTAINABILITY STRATEGIES

### 1. Write Code for the Next Developer
- Clear variable names
- Consistent patterns
- Good documentation
- Self-explanatory structure

### 2. Design for Change
- Abstract behind interfaces
- Use configuration over hardcoding
- Plan for feature additions
- Make components composable

### 3. Keep the Codebase Clean
- Regular refactoring sessions
- Remove dead code
- Update dependencies
- Fix warnings immediately

### 4. Technical Debt Management
- Track technical debt explicitly
- Allocate time for debt reduction
- Prioritize by impact
- Document decisions and trade-offs

## ALGORITHM OPTIMIZATION

### Decision Framework
```
Before optimizing:
1. MEASURE first (don't guess)
2. Identify the bottleneck (CPU, memory, I/O, network)
3. Consider algorithmic complexity (Big O)
4. Apply the SIMPLEST optimization that works
5. MEASURE again to verify improvement

Common optimizations by scenario:
- Searching: Binary search O(log n) vs Linear O(n)
- Caching: Memoization for expensive computations
- Batching: Group operations to reduce overhead
- Lazy loading: Load only what's needed
- Pagination: Don't load everything at once
- Indexing: Database indexes for frequent queries
- Connection pooling: Reuse database connections
```

### Code Complexity Rules
```
Maximum cyclomatic complexity per function: 10
Maximum nesting depth: 4 levels
Maximum function length: 50 lines
Maximum file length: 300 lines
Maximum parameters per function: 5

If any limit is exceeded: REFACTOR.
```
