# Before/After Commit Message Examples

> **Purpose**: Learn from real-world examples of poor commit messages transformed into professional, standards-compliant versions.

---

## Table of Contents

1. [Format Violations](#format-violations)
2. [Vague Messages](#vague-messages)
3. [Missing Context](#missing-context)
4. [Wrong Commit Type](#wrong-commit-type)
5. [Non-Atomic Commits](#non-atomic-commits)
6. [Missing Breaking Change Documentation](#missing-breaking-change-documentation)
7. [Poor Bug Fix Messages](#poor-bug-fix-messages)
8. [Inadequate Feature Descriptions](#inadequate-feature-descriptions)
9. [Refactoring Without Context](#refactoring-without-context)
10. [Performance Improvements](#performance-improvements)

---

## Format Violations

### Example 1: Missing Type Prefix

**❌ BEFORE**:
```
add login feature
```

**Problems**:
- No type prefix (feat, fix, etc.)
- No scope
- Not following Conventional Commits format

**✅ AFTER**:
```
feat(auth): add user login functionality

Implements email/password authentication.
Users can now log in to access protected resources.

Includes:
- Login form component
- JWT token generation
- Session management

Closes #123
```

**Why better**: Clear type, scope, and complete context about what was added.

---

### Example 2: Using Wrong Type

**❌ BEFORE**:
```
update(api): change authentication
```

**Problems**:
- "update" is not a valid Conventional Commits type
- Doesn't specify if it's a feature, fix, or refactor

**✅ AFTER**:
```
refactor(api): migrate authentication to OAuth2

Replaces custom JWT implementation with OAuth2 standard.
Improves security and enables SSO integration.

No breaking changes - backward compatible with existing tokens.
```

**Why better**: Uses correct type "refactor" and explains the change clearly.

---

### Example 3: Past Tense

**❌ BEFORE**:
```
feat(ui): added dark mode support
```

**Problems**:
- Uses past tense "added" instead of imperative "add"
- Violates convention

**✅ AFTER**:
```
feat(ui): add dark mode support

Implements dark theme for improved accessibility.
Users can toggle between light and dark modes in settings.

Includes:
- Dark theme color palette
- Theme switcher component
- Persistent theme preference

Closes #456
```

**Why better**: Uses imperative mood "add" and provides context.

---

### Example 4: Header Too Long

**❌ BEFORE**:
```
feat(auth): implement comprehensive JWT-based authentication system with refresh tokens, expiration handling, and automatic token rotation for improved security
```

**Problems**:
- 147 characters (way over 72 limit)
- Too much detail in header

**✅ AFTER**:
```
feat(auth): add JWT authentication with token rotation

Implements secure JWT-based authentication system.

Features:
- Access tokens (1 hour expiration)
- Refresh tokens (30 day expiration)
- Automatic token rotation on refresh
- Secure storage in httpOnly cookies

Security improvements:
- Prevents token theft
- Limits attack window
- Enables graceful token revocation

Closes #789
```

**Why better**: Concise header (53 chars), details in body.

---

### Example 5: Wrong Capitalization

**❌ BEFORE**:
```
Feat(API): Add Endpoint For User Registration
```

**Problems**:
- "Feat" should be lowercase
- "API" scope should be lowercase
- Title case subject (should be sentence case)

**✅ AFTER**:
```
feat(api): add user registration endpoint

POST /api/users endpoint for new user registration.
Validates email uniqueness and password strength.
Sends verification email upon successful registration.

Closes #234
```

**Why better**: Follows lowercase convention for type and scope.

---

## Vague Messages

### Example 6: Generic "Fix Bug"

**❌ BEFORE**:
```
fix: fix bug
```

**Problems**:
- Doesn't explain what bug was fixed
- No scope
- No context
- Useless for git log

**✅ AFTER**:
```
fix(auth): resolve session timeout on page reload

Fixed bug where users were logged out on page refresh.

Root cause: Session token was not persisted to localStorage.
Solution: Store JWT in localStorage with automatic refresh.

Impact: Users maintain session across page reloads.

Fixes #567
```

**Why better**: Specific about what bug, root cause, and solution.

---

### Example 7: Generic "Update Code"

**❌ BEFORE**:
```
update code
```

**Problems**:
- No type, no scope
- "update" is meaningless
- Doesn't say what was updated or why

**✅ AFTER**:
```
refactor(api): simplify error handling middleware

Extracts duplicate error handling logic into centralized middleware.
Reduces code duplication across 15 endpoint handlers.

Benefits:
- Consistent error response format
- Easier to maintain
- 200 lines of code removed

No functional changes.
```

**Why better**: Specific about what changed and why it's beneficial.

---

### Example 8: Generic "Improve Performance"

**❌ BEFORE**:
```
improve performance
```

**Problems**:
- No type, no scope
- Doesn't explain what was improved or by how much
- No metrics

**✅ AFTER**:
```
perf(db): add indexes on frequently queried columns

Added composite indexes to improve query performance.

Indexes added:
- users(email, status)
- orders(user_id, created_at)
- products(category_id, published)

Performance improvements:
- User lookup: 800ms → 12ms (98% faster)
- Order history: 1200ms → 45ms (96% faster)
- Product search: 600ms → 25ms (96% faster)

Database size impact: +50MB (negligible)

Closes #890
```

**Why better**: Specific changes with measurable before/after metrics.

---

## Missing Context

### Example 9: No Explanation for Complex Change

**❌ BEFORE**:
```
refactor(api): update endpoints
```

**Problems**:
- Doesn't explain what changed
- No body with context
- 150 lines changed across 8 files - needs explanation

**✅ AFTER**:
```
refactor(api): restructure endpoints for REST compliance

Reorganizes API to follow RESTful conventions.

Changes:
- Groups related resources under /api/v1/
- Uses standard HTTP methods (GET, POST, PUT, DELETE)
- Implements consistent URL structure

Before:
/getUsers → GET /api/v1/users
/createUser → POST /api/v1/users
/updateUser/123 → PUT /api/v1/users/123
/deleteUser/123 → DELETE /api/v1/users/123

Benefits:
- More intuitive API structure
- Easier to document
- Standard HTTP semantics
- Prepares for future versioning

No breaking changes - old endpoints still work (deprecated).
```

**Why better**: Explains rationale, shows specific changes, notes compatibility.

---

### Example 10: Missing "Why"

**❌ BEFORE**:
```
feat(ui): add loading spinner
```

**Problems**:
- Doesn't explain why spinner was added
- What problem does it solve?

**✅ AFTER**:
```
feat(ui): add loading spinner during data fetch

Adds visual feedback while API requests are in progress.

Problem solved:
Users were clicking submit multiple times because there was
no indication that the request was being processed.

Impact:
- Reduces duplicate submissions by 85%
- Improves perceived performance
- Better user experience

Implementation:
- Shows spinner on all async operations
- Disables form during submission
- Auto-hides after 30 seconds (timeout)

Closes #345
```

**Why better**: Explains the problem being solved and the impact.

---

## Wrong Commit Type

### Example 11: Feature Labeled as Fix

**❌ BEFORE**:
```
fix(user): add profile picture upload
```

**Problems**:
- This is a new feature, not a bug fix
- Should use "feat" not "fix"

**✅ AFTER**:
```
feat(user): add profile picture upload

Allows users to upload and display profile pictures.

Features:
- Image upload with drag-and-drop
- Automatic resize to 200x200px
- Supports JPG, PNG, WEBP formats
- 5MB file size limit
- Stores in AWS S3

Closes #678
```

**Why better**: Correct type "feat" for new functionality.

---

### Example 12: Refactor Labeled as Feature

**❌ BEFORE**:
```
feat(auth): change password hashing algorithm
```

**Problems**:
- Not adding new functionality
- Changing implementation = refactor
- Should note if breaking

**✅ AFTER**:
```
refactor(auth): migrate to Argon2 for password hashing

Replaces bcrypt with Argon2 for improved security.

Security improvements:
- Resistant to GPU/ASIC attacks
- Better memory hardness
- Modern algorithm (2015 Password Hashing Competition winner)

Migration:
- Existing bcrypt hashes still work
- New registrations use Argon2
- Passwords automatically rehashed on next login

No user action required.
```

**Why better**: Uses "refactor" and explains migration strategy.

---

## Non-Atomic Commits

### Example 13: Multiple Unrelated Changes

**❌ BEFORE**:
```
feat(user): add profile page, fix logout bug, update README

Files changed:
- src/components/Profile.tsx (new feature)
- src/auth/Logout.tsx (bug fix)
- README.md (documentation)
```

**Problems**:
- Three unrelated changes in one commit
- Can't revert selectively
- Confusing history

**✅ AFTER (Split into 3 commits)**:

**Commit 1**:
```
feat(user): add profile page component

Implements user profile page with editable fields.

Features:
- Display user information
- Edit name and email
- Upload profile picture
- View account history

Closes #901
```

**Commit 2**:
```
fix(auth): clear session on logout

Fixed bug where session data persisted after logout.

Root cause: localStorage wasn't being cleared.
Solution: Explicitly clear all auth data on logout.

Fixes #902
```

**Commit 3**:
```
docs: add user profile documentation to README

Documents new profile page feature.
Includes screenshots and usage examples.
```

**Why better**: Each commit is focused and can be reverted independently.

---

### Example 14: WIP Commit on Main Branch

**❌ BEFORE**:
```
WIP: working on feature (on main branch)
```

**Problems**:
- WIP commits should never be on main
- Incomplete work
- No real message

**✅ AFTER (Squashed)**:
```
feat(payment): add Stripe payment integration

Implements credit card payments using Stripe API.

Features:
- Payment form with card validation
- Secure token generation
- Payment confirmation
- Receipt email

Stripe integration:
- Test mode for development
- Production keys via environment variables
- Webhook for payment status updates

Testing:
- Unit tests for payment processing
- Integration tests with Stripe sandbox
- Manual testing with test credit cards

Closes #123
```

**Why better**: Complete, squashed commit with full context.

---

## Missing Breaking Change Documentation

### Example 15: Breaking Change Without Footer

**❌ BEFORE**:
```
refactor(api): change authentication endpoints

Changed /auth/login to /v2/auth/login
```

**Problems**:
- Breaking change not marked
- No migration guide
- Clients will break unexpectedly

**✅ AFTER**:
```
refactor(api): migrate authentication to v2 endpoints

Moves authentication endpoints to versioned namespace.

BREAKING CHANGE: Authentication endpoints moved to /v2/ namespace.

Affected endpoints:
- /auth/login → /v2/auth/login
- /auth/logout → /v2/auth/logout
- /auth/refresh → /v2/auth/refresh
- /auth/verify → /v2/auth/verify

Migration guide:
1. Update API base URL to include /v2/
2. Update client libraries to use new endpoints
3. Test with staging environment
4. Deploy client updates before server

Timeline:
- 2025-12-15: Deploy new endpoints (old ones still work)
- 2026-01-15: Old endpoints return deprecation warnings
- 2026-02-15: Old endpoints removed

Documentation: https://docs.example.com/migration-v2

Closes #567
```

**Why better**: Clear BREAKING CHANGE marker, migration guide, timeline.

---

## Poor Bug Fix Messages

### Example 16: No Root Cause Analysis

**❌ BEFORE**:
```
fix(api): fix error
```

**Problems**:
- What error?
- What caused it?
- How was it fixed?

**✅ AFTER**:
```
fix(api): handle null pointer in user lookup

Fixed NullPointerException when looking up deleted users.

Root cause:
User deletion only set 'deleted' flag but didn't handle
null references in related tables (orders, cart).

Solution:
- Added null checks in user lookup
- Return 404 for deleted users
- Cascade delete related records properly

Impact:
- Prevents 500 errors
- Better error messages for clients
- Improved database consistency

Added tests:
- Test user lookup after deletion
- Test cascade delete behavior
- Test null reference handling

Fixes #789
```

**Why better**: Explains problem, root cause, solution, and impact.

---

### Example 17: Security Fix Without Proper Disclosure

**❌ BEFORE**:
```
fix(auth): fix security issue

There was a vulnerability in login.
Fixed by adding validation.
```

**Problems**:
- Too vague about vulnerability
- Missing severity information
- No testing details

**✅ AFTER**:
```
security(auth): fix SQL injection in login endpoint

Fixed critical SQL injection vulnerability in authentication.

Vulnerability:
Username parameter was concatenated directly into SQL query.
Allowed arbitrary SQL execution via crafted usernames.

CVE: CVE-2025-12345
CVSS Score: 9.0 (Critical)
Attack Vector: Network
Complexity: Low

Fix:
Implemented parameterized queries using prepared statements.
All user input now properly sanitized.

Impact Assessment:
- Reviewed logs: No evidence of exploitation (90 days)
- Affected versions: v1.0.0 to v1.5.2
- Fixed in: v1.5.3

Testing:
- Penetration testing confirmed vulnerability closed
- Added automated security tests
- All existing tests pass

Closes SEC-001
Reviewed-by: Security Team <security@example.com>
Signed-off-by: Developer <dev@example.com>
```

**Why better**: Proper security disclosure with all relevant details.

---

## Inadequate Feature Descriptions

### Example 18: Feature Without Context

**❌ BEFORE**:
```
feat(cart): add wishlist
```

**Problems**:
- No explanation of what wishlist does
- No details about implementation
- No user benefit stated

**✅ AFTER**:
```
feat(cart): add wishlist functionality

Allows users to save products for later purchase.

User Benefits:
- Save products without purchasing immediately
- Share wishlist with friends/family
- Receive notifications when items go on sale
- Easy move from wishlist to cart

Features:
- Add/remove products from wishlist
- Multiple wishlists per user
- Privacy settings (public/private)
- Share wishlist via unique URL

Implementation:
- New database tables: wishlists, wishlist_items
- REST API endpoints: /api/wishlists
- React components: WishlistView, WishlistButton
- Email notifications for price drops

Testing:
- Unit tests: 95% coverage
- E2E tests: Full user workflows
- Load tested with 10,000 wishlists

Business Impact:
- Expected 20% increase in return visits
- Reduced cart abandonment
- Improved customer engagement

Closes #890
```

**Why better**: Complete feature description with benefits and implementation details.

---

## Refactoring Without Context

### Example 19: Mysterious Refactoring

**❌ BEFORE**:
```
refactor: update code
```

**Problems**:
- What code?
- Why refactor?
- What changed?

**✅ AFTER**:
```
refactor(api): extract validation logic to middleware

Consolidates duplicate validation code across 20 endpoints.

Problem:
Each endpoint had its own validation logic copy-pasted.
Inconsistent error messages and validation rules.

Solution:
Created reusable validation middleware using express-validator.
Centralized validation schemas in /validators directory.

Benefits:
- Single source of truth for validation rules
- Consistent error messages
- Easier to add new validations
- Reduced code by 500 lines

Changes:
- Created ValidationMiddleware class
- Moved schemas to /api/validators/
- Updated all endpoints to use middleware
- Added comprehensive tests

No functional changes - all tests pass.
```

**Why better**: Explains motivation, solution, and benefits clearly.

---

## Performance Improvements

### Example 20: Performance Without Metrics

**❌ BEFORE**:
```
perf: make it faster
```

**Problems**:
- What is "it"?
- How much faster?
- No metrics

**✅ AFTER**:
```
perf(db): implement query result caching with Redis

Adds Redis caching layer for frequently accessed data.

Cached queries:
- User profile lookups (30 minute TTL)
- Product catalog (10 minute TTL)
- Category listings (1 hour TTL)

Performance improvements:
- User profile: 150ms → 5ms (97% faster)
- Product search: 800ms → 20ms (97% faster)
- Category list: 200ms → 2ms (99% faster)

Cache strategy:
- Cache-aside pattern
- Automatic invalidation on updates
- Cache warming on deployment

Load testing results:
- Baseline: 100 req/sec
- With cache: 1000 req/sec (10x improvement)
- 95th percentile: 50ms → 8ms

Infrastructure:
- Redis Cluster (3 nodes)
- 2GB memory allocation
- Persistent cache across restarts

Monitoring:
- Cache hit rate dashboards
- Automatic alerts for low hit rates
- Performance metrics in Datadog

Closes #345
```

**Why better**: Detailed metrics, strategy explanation, infrastructure notes.

---

## Summary

Good commit messages have these characteristics:

1. **Format**: Follow Conventional Commits (`<type>(<scope>): <subject>`)
2. **Clarity**: Specific, not vague ("add user auth" not "update code")
3. **Context**: Explain what, why, and impact
4. **Atomicity**: One logical change per commit
5. **Completeness**: Include body and footer when needed
6. **Breaking Changes**: Always document with BREAKING CHANGE footer
7. **Metrics**: Include before/after numbers for performance
8. **Testing**: Mention test coverage and approaches
9. **Security**: Proper disclosure for vulnerabilities
10. **References**: Link to issues, tickets, documentation

---

**Last Updated**: 2025-12-11
