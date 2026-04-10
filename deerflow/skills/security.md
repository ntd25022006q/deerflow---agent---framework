# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW SKILL: SECURITY AUDIT v1.0
# ═══════════════════════════════════════════════════════════════════════
# Solves Problem #23: Extremely poor security
# ═══════════════════════════════════════════════════════════════════════

## SECURITY IS NON-NEGOTIABLE

Every piece of code you write MUST be secure by default.
Security is not something you "add later" — it's built into every
decision from the start.

## MANDATORY SECURITY CHECKLIST

### 1. Secrets Management
```
❌ FORBIDDEN:
  - Hardcoded API keys, tokens, passwords
  - Secrets in client-side code
  - Secrets in git commits
  - .env files committed to repository

✅ REQUIRED:
  - All secrets in environment variables
  - .env.example with placeholder values
  - .env in .gitignore
  - Secret rotation strategy documented
```

### 2. Input Validation
```
EVERY external input must be validated:
  - Form submissions
  - URL parameters
  - API request bodies
  - File uploads
  - WebSocket messages
  - Headers and cookies

Validation must happen on BOTH sides:
  - Client: immediate feedback, UX
  - Server: security, data integrity (NEVER trust client)

Use Zod, Yup, or Joi for schema validation.
```

### 3. Authentication & Authorization
```
□ Password hashing: bcrypt with minimum 12 rounds
□ JWT tokens: RS256 algorithm, short expiry, refresh tokens
□ Session management: secure, httpOnly cookies
□ Rate limiting on auth endpoints
□ Account lockout after failed attempts
□ MFA support for sensitive operations
□ Role-based access control (RBAC)
□ Principle of least privilege
```

### 4. Common Vulnerability Prevention

#### SQL Injection
```typescript
// ❌ VULNERABLE
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// ✅ SECURE: Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```

#### Cross-Site Scripting (XSS)
```typescript
// ❌ VULNERABLE
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ SECURE: Use text content or sanitize
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{
  __html: DOMPurify.sanitize(userInput, { ALLOWED_TAGS: [] })
}} />
// Better: just use textContent
<p>{userInput}</p>
```

#### Cross-Site Request Forgery (CSRF)
```typescript
// ✅ SECURE: CSRF token validation
import { csrfToken, validateCsrf } from '@/lib/csrf';

// In API route:
app.post('/api/action', (req, res) => {
  if (!validateCsrf(req.headers['x-csrf-token'], req.session.csrfToken)) {
    return res.status(403).json({ error: 'Invalid CSRF token' });
  }
  // ... proceed
});
```

#### Security Headers
```typescript
// ✅ SECURE: Content Security Policy
const cspHeader = `
  default-src 'self';
  script-src 'self' 'nonce-{nonce}';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
`;
```

### 5. Dependency Security
```
□ Run `npm audit` / `pip audit` regularly
□ Review dependency changelogs for security fixes
□ Use `npm audit fix` for automatic fixes
□ Lock dependency versions (package-lock.json)
□ Review new dependencies before adding them
□ Remove unused dependencies
```

### 6. Data Protection
```
□ Encrypt sensitive data at rest (AES-256)
□ Use HTTPS/TLS for all communications
□ Implement field-level encryption for PII
□ Data masking in logs (never log passwords, tokens, PII)
□ Secure file uploads (type validation, size limits, virus scan)
□ Implement data retention policies
```

### 7. Error Handling (Security-Safe)
```typescript
// ❌ INSECURE: Exposing internals
catch (error) {
  return res.status(500).json({
    error: error.message,        // May expose internals
    stack: error.stack           // Definitely exposes internals
  });
}

// ✅ SECURE: Safe error responses
catch (error) {
  logger.error('Internal error', { error, requestId });
  return res.status(500).json({
    error: 'An internal error occurred',
    requestId: req.id  // For support reference
  });
}
```

## SECURITY AUDIT CHECKLIST

Run this checklist on EVERY code change:

```
AUTHENTICATION:
□ Auth is required for protected routes
□ Tokens are validated server-side
□ Session management is secure

AUTHORIZATION:
□ Users can only access their own data
□ Role checks are in place
□ Admin actions require admin role

INPUT VALIDATION:
□ All inputs are validated on server
□ No raw SQL queries with user input
□ No eval() or Function() with user input

OUTPUT ENCODING:
□ No unescaped user content in HTML
□ No user content in URLs without encoding
□ Content-Security-Policy headers set

DATA PROTECTION:
□ No secrets in code or commits
□ Sensitive data encrypted at rest
□ HTTPS enforced

DEPENDENCIES:
□ No known vulnerabilities
□ Dependencies are up to date
□ No unnecessary dependencies
```
