# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SKILL: TESTING FRAMEWORK v1.0
# ═══════════════════════════════════════════════════════════════════════
# Solves Problem #3: Incomplete bug fixes
# Solves Problem #7: Infinite loops and runtime errors
# Solves Problem #8: Code that doesn't work
# Solves Problem #13: Missing testing tools
# ═══════════════════════════════════════════════════════════════════════

## TESTING PHILOSOPHY

Testing is not optional. Testing is not "nice to have."
Testing is a MANDATORY part of the development process.
Code without tests is incomplete code. Period.

## TESTING PYRAMID

```
          ┌─────────┐
          │   E2E   │  ← Few, slow, high confidence
          │  Tests   │     (Playwright / Cypress)
         ┌┴─────────┴┐
         │Integration │  ← Moderate count, medium speed
         │  Tests     │     (API tests, component integration)
        ┌┴───────────┴┐
        │  Unit Tests  │  ← Many, fast, focused
        │              │     (Jest / Vitest)
        └──────────────┘
```

## MANDATORY TEST REQUIREMENTS

### Rule: Every Code Change Requires Tests

| Change Type | Required Tests |
|------------|---------------|
| New function | Unit test with all branches |
| New component | Component test + accessibility test |
| New API route | Integration test + error scenario test |
| Bug fix | Regression test + affected path tests |
| Refactor | Existing tests must still pass |
| Config change | Verify behavior with new config |

### Test Quality Criteria

Every test MUST be:
1. **Deterministic**: Same result every time (no random failures)
2. **Independent**: No dependency on other tests or execution order
3. **Fast**: Unit tests < 100ms, integration tests < 1s
4. **Descriptive**: Test name describes expected behavior
5. **Complete**: Covers happy path + error paths + edge cases

## TESTING PATTERNS

### Unit Test Pattern
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      const data = { name: 'John', email: 'john@example.com' };
      const result = await userService.createUser(data);
      expect(result).toMatchObject({
        id: expect.any(String),
        name: data.name,
        email: data.email,
        createdAt: expect.any(Date)
      });
    });

    it('should throw validation error for invalid email', async () => {
      const data = { name: 'John', email: 'invalid' };
      await expect(userService.createUser(data))
        .rejects.toThrow(ValidationError);
    });

    it('should throw conflict error for duplicate email', async () => {
      const data = { name: 'John', email: 'existing@example.com' };
      await expect(userService.createUser(data))
        .rejects.toThrow(new AppError('EMAIL_EXISTS'));
    });

    it('should handle database connection error gracefully', async () => {
      mockDb.throwOnNextCall(new DatabaseError());
      await expect(userService.createUser(validData))
        .rejects.toThrow(AppError);
    });
  });
});
```

### Component Test Pattern
```typescript
describe('UserProfileCard', () => {
  it('renders user information correctly', () => {
    const user = { name: 'John', email: 'john@example.com' };
    render(<UserProfileCard user={user} />);
    expect(screen.getByText('John')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('shows loading state', () => {
    render(<UserProfileCard isLoading />);
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });

  it('shows error state', () => {
    render(<UserProfileCard error="Failed to load" />);
    expect(screen.getByText('Failed to load')).toBeInTheDocument();
  });

  it('handles click events', async () => {
    const onEdit = jest.fn();
    render(<UserProfileCard user={mockUser} onEdit={onEdit} />);
    await userEvent.click(screen.getByRole('button', { name: /edit/i }));
    expect(onEdit).toHaveBeenCalledWith(mockUser);
  });
});
```

### API Integration Test Pattern
```typescript
describe('POST /api/users', () => {
  it('creates a user and returns 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201);
    expect(response.body).toMatchObject({
      id: expect.any(String),
      name: 'John'
    });
  });

  it('returns 400 for missing required fields', async () => {
    await request(app)
      .post('/api/users')
      .send({ name: 'John' }) // missing email
      .expect(400);
  });

  it('returns 409 for duplicate email', async () => {
    await createUser({ email: 'existing@example.com' });
    await request(app)
      .post('/api/users')
      .send({ name: 'Jane', email: 'existing@example.com' })
      .expect(409);
  });

  it('returns 429 for rate limiting', async () => {
    for (let i = 0; i < 100; i++) {
      await request(app).post('/api/users').send(validData);
    }
    await request(app)
      .post('/api/users')
      .send(validData)
      .expect(429);
  });
});
```

## EDGE CASE CHECKLIST

For every function/component, test:
- [ ] Normal case (happy path)
- [ ] Empty input (`""`, `[]`, `{}`, `null`)
- [ ] Invalid input (wrong types, malformed data)
- [ ] Boundary values (0, -1, MAX_SAFE_INTEGER, empty string)
- [ ] Timeout handling (if async)
- [ ] Concurrent execution (if applicable)
- [ ] Permission/authorization (if applicable)
- [ ] Internationalization (if applicable)

## TEST EXECUTION RULES

1. Run tests BEFORE every commit
2. Run tests AFTER every dependency change
3. Run tests AFTER every refactoring
4. Run ALL tests, not just the ones you wrote
5. If ANY test fails: fix it before proceeding
6. NEVER skip tests without a documented reason
7. NEVER mark tests as `.skip()` or `.only()` in commits

## COVERAGE REQUIREMENTS

| Path | Minimum | Target |
|------|---------|--------|
| Services | 90% | 95% |
| Components | 80% | 90% |
| Utilities | 95% | 100% |
| Hooks | 85% | 90% |
| Overall | 80% | 90% |
