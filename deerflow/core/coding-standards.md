# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW — CODING STANDARDS & BEST PRACTICES v1.0
# ═══════════════════════════════════════════════════════════════════════

## LANGUAGE STANDARDS

### TypeScript (Primary)
```typescript
// ✅ CORRECT: Strict typing, no shortcuts
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
  timestamp: Date;
}

async function fetchUsers(
  params: UserQueryParams
): Promise<ApiResponse<User[]>> {
  try {
    const response = await api.get<User[]>('/users', { params });
    return {
      data: response.data,
      status: response.status,
      message: 'Success',
      timestamp: new Date()
    };
  } catch (error) {
    throw new AppError(
      'FETCH_USERS_FAILED',
      `Failed to fetch users: ${error instanceof Error ? error.message : 'Unknown'}`
    );
  }
}

// ❌ FORBIDDEN: any type, loose typing
function fetchUsers(params: any): any { ... }
```

### Naming Conventions
```
Components:    PascalCase     (UserProfileCard, NavigationBar)
Functions:     camelCase      (fetchUserData, validateEmail)
Constants:     UPPER_SNAKE    (MAX_RETRY_COUNT, API_BASE_URL)
Types:         PascalCase     (User, ApiResponse, QueryParams)
Files:         kebab-case     (user-profile-card.tsx)
Directories:   kebab-case     (components/ui, hooks/auth)
Test Files:    *.test.ts      (user-service.test.ts)
```

### File Structure Convention
```
src/
├── components/          # React components
│   ├── ui/              # Base UI components (Button, Input, etc.)
│   ├── layout/          # Layout components (Header, Footer, etc.)
│   └── features/        # Feature-specific components
├── hooks/               # Custom React hooks
├── services/            # API service layer
├── stores/              # State management
├── types/               # TypeScript type definitions
├── utils/               # Utility functions
├── constants/           # App-wide constants
├── styles/              # Global styles and design tokens
└── __tests__/           # Test files (co-located with source)
```

## ARCHITECTURE PATTERNS

### Component Architecture
```
Page Component (Container)
  └── Smart Component (Business Logic)
        ├── Dumb Component (Presentation)
        └── Dumb Component (Presentation)
```

Rules:
- Page components: handle routing and data fetching
- Smart components: contain business logic, use hooks
- Dumb components: pure presentation, receive props
- Maximum nesting depth: 4 levels
- Maximum props per component: 7 (use object if more)

### State Management
```
Server State → TanStack Query (React Query)
  └── Cached, synced, background refetch
Client State → Zustand / Jotai
  └── Minimal, derived when possible
Form State → React Hook Form + Zod
  └── Validated, performant
URL State → Nuqs / useSearchParams
  └── Shareable, bookmarkable
```

### API Design
```
// Service Layer Pattern
class UserService {
  async getById(id: string): Promise<User> { ... }
  async create(data: CreateUserDTO): Promise<User> { ... }
  async update(id: string, data: UpdateUserDTO): Promise<User> { ... }
  async delete(id: string): Promise<void> { ... }
  async list(params: QueryParams): Promise<PaginatedResponse<User>> { ... }
}
```

### Error Handling Pattern
```typescript
// Custom error classes
class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode: number = 500,
    public details?: unknown
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// Error boundary for React
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };
  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

## PERFORMANCE STANDARDS

### React Performance
- Use React.memo() for expensive components
- Use useMemo() for expensive computations
- Use useCallback() for event handlers passed to children
- Lazy load routes with React.lazy() + Suspense
- Virtualize long lists (react-window, @tanstack/virtual)
- Prefer CSS animations over JavaScript animations
- Debounce/throttle rapid user input (search, resize)

### Bundle Size
- Code splitting per route
- Tree-shake unused exports
- Analyze bundle with: @next/bundle-analyzer
- Max initial bundle: 200KB gzipped
- Use dynamic imports for heavy dependencies

### Data Fetching
- Prefer server-side rendering for initial data
- Implement optimistic updates for mutations
- Use stale-while-revalidate pattern
- Cancel in-flight requests on unmount

## ACCESSIBILITY STANDARDS

Minimum requirements:
- All images have alt text
- All interactive elements are keyboard accessible
- Color contrast ratio: minimum 4.5:1 (WCAG AA)
- All form inputs have associated labels
- Focus indicators are visible
- ARIA landmarks for page structure
- Skip-to-content link on every page
- Screen reader announcements for dynamic content

## DESIGN TOKEN SYSTEM

```css
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-secondary: #64748b;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;

  /* Spacing */
  --space-xs: 0.25rem;   /* 4px */
  --space-sm: 0.5rem;    /* 8px */
  --space-md: 1rem;      /* 16px */
  --space-lg: 1.5rem;    /* 24px */
  --space-xl: 2rem;      /* 32px */
  --space-2xl: 3rem;     /* 48px */

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;

  /* Borders */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
}
```
