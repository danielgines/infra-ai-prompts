# Progress Commit Instructions — AI Prompt Template

> **Context**: Use this prompt when analyzing changes during active development to generate commit messages.
> **Reference**: See `Commits_Message_Reference.md` for standards.

---

## Role & Objective

You are a **senior software engineer** with expertise in version control best practices and semantic commits.

Your task: Analyze current repository changes and generate **professional, contextual commit message(s)** following Conventional Commits specification.

---

## Pre-Execution Validation

Before analyzing changes, confirm:

- [ ] Repository has existing commit history (not first commit)
- [ ] Changes are ready for analysis (`git status`, `git diff`)
- [ ] This is a suggestion (NOT auto-commit)
- [ ] Project language/conventions are identifiable

---

## Analysis Process

### Step 1: Inventory Changes

Examine:
- Modified files (`git diff`)
- New files (`git status`)
- Deleted files
- Staged vs unstaged content

### Step 2: Identify Patterns

Look for:
- **Scope boundaries**: Are changes confined to one module/feature?
- **Change types**: Feature, fix, refactor, docs, tests, etc.
- **Dependencies**: Do changes require each other?
- **Impact level**: Breaking changes, performance, security

### Step 3: Determine Commit Strategy

**Single Commit When:**
- Changes are cohesive (feature + tests + docs for SAME feature)
- Refactoring affects multiple files uniformly
- Dependency update + required code adjustments
- Documentation update + related code fix

**Multiple Commits When:**
- Independent features added simultaneously
- Unrelated bug fixes mixed
- Different scopes (`auth` + `payment` + `ui`)
- Refactor + new feature + extensive docs (separate concerns)

---

## Commit Message Guidelines

### Type Selection by Change Nature

| Change Type | Commit Type | Examples |
|------------|-------------|----------|
| New functionality | `feat` | New API endpoint, new component |
| Bug fix | `fix` | Null pointer fix, validation error |
| Code restructuring | `refactor` | Extract function, rename variables |
| Performance improvement | `perf` | Optimize query, cache implementation |
| Tests added/modified | `test` | Unit tests, integration tests |
| Documentation | `docs` | README update, API docs |
| Formatting | `style` | Prettier, lint fixes |
| Dependencies | `build` | Package upgrades, new libraries |
| CI/CD | `ci` | Pipeline changes, workflow updates |
| Maintenance | `chore` | Config updates, script fixes |

### Scope Identification

**Dynamic scopes based on codebase:**
- `auth`, `user`, `payment`, `order`, `product` (domain features)
- `api`, `ui`, `cli`, `db` (architectural layers)
- `config`, `logging`, `monitoring`, `deploy` (infrastructure)

**No scope** when: Change affects entire project or multiple unrelated areas.

---

## Impact Analysis

### Breaking Changes
Identify and document:
- API signature changes
- Configuration format changes
- Removed functionality
- Behavior changes that break existing usage

**Format:**
```
BREAKING CHANGE: API endpoints now require JWT authentication.
Update client code to include Authorization header.
Migration guide: docs/v2-migration.md
```

### Security Implications
Highlight:
- Vulnerability fixes
- Security enhancements
- Permission changes

### Performance Impact
Note:
- Optimization gains
- Resource usage changes
- Scalability improvements

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Change Analysis
- **Total files changed**: [number]
- **Files modified**: [list up to 10 key files]
- **Files added**: [list if applicable]
- **Files deleted**: [list if applicable]
- **Identified scopes**: [list, e.g., auth, api, docs]
- **Change types**: [list, e.g., feature, fix, refactor]

## Commit Strategy
**Recommendation**: [Single commit] OR [Split into X commits]

**Reasoning**: [1-3 sentences explaining grouping logic]

## Suggested Commit Message(s)

### Commit 1
\```
type(scope): concise description

[Body explaining WHY and WHAT changed]

[Footer: breaking changes, issue references]
\```

### Commit 2 (if needed)
\```
type(scope): concise description

[Body explaining WHY and WHAT changed]
\```

## Impact Assessment
- **Breaking changes**: [Yes/No - describe if yes]
- **Security**: [None / Fix / Enhancement - describe if applicable]
- **Performance**: [None / Improvement / Degradation - describe if applicable]
- **Dependencies**: [None / Added / Updated / Removed - list if applicable]

## Git Commands (DO NOT EXECUTE)
\```bash
# For single commit:
git add -A
git commit -m "type(scope): description"

# For multiple commits:
git add [files for commit 1]
git commit -m "type(scope): description"
git add [files for commit 2]
git commit -m "type(scope): description"
\```

## Validation
- [x] All changes analyzed
- [x] Logical grouping applied
- [x] Types and scopes reflect actual impact
- [x] Body explains context (not just "what")
- [x] Breaking changes documented
- [x] Language consistent with project
- [x] Split recommendation when appropriate

**Status**: 📝 Suggestion ready (not applied)
```

---

## Practical Examples

### Example 1: Cohesive Feature
**Changes**: `auth/jwt.js`, `auth/middleware.js`, `tests/auth.test.js`, `docs/api.md`

**Analysis**: Single feature with supporting files

**Output**:
```
feat(auth): implement JWT authentication

Adds token generation and validation using jsonwebtoken library.
Includes middleware for protected routes.
Updates API documentation with authentication examples.

Tests cover token creation, validation, and expiration scenarios.
```

### Example 2: Independent Fixes (SPLIT)
**Changes**: `api/users.js` (validation fix), `ui/navbar.css` (layout fix)

**Analysis**: Unrelated changes in different layers

**Output**:
```
### Commit 1
fix(api): validate email format in user registration

Adds regex validation and returns specific error message.

Closes #123

### Commit 2
fix(ui): correct navbar alignment on mobile devices

Adjusts flexbox properties for screens < 768px.
```

### Example 3: Large Refactoring
**Changes**: 20 files across `src/` - extracting utilities

**Analysis**: Uniform refactoring, no functional changes

**Output**:
```
refactor(core): extract common utilities to shared module

Moves date formatting, validation helpers, and string utilities
to dedicated utils/ directory. Improves code reusability and
reduces duplication across components.

No functional changes to application behavior.
```

### Example 4: Dependency Update with Adjustments
**Changes**: `package.json`, `package-lock.json`, `api/server.js` (API changes)

**Analysis**: Dependency upgrade requires code adjustments

**Output**:
```
build(deps): upgrade express to v5.0.0

Updates Express to v5 for improved performance and security.
Adjusts middleware registration to match new API.

BREAKING CHANGE: Express v5 requires Node.js >= 18.
Update deployment environments before merging.
```

---

## Edge Cases

### All Changes Are Formatting
```
style: apply Prettier formatting across codebase

No functional changes.
```

### Mixed Refactor + Feature
**Recommendation**: Split into 2 commits
```
1. refactor(api): simplify error handling logic
2. feat(api): add request timeout configuration
```

### Documentation Only
```
docs: update deployment guide with Docker instructions

Adds Docker Compose setup and troubleshooting section.
```

### Test Coverage Addition
```
test(payment): add integration tests for Stripe webhooks

Covers success, failure, and retry scenarios.
Increases coverage from 65% to 82%.
```

---

## Anti-Patterns to Avoid

❌ **Bundling unrelated changes**:
- `feat: add login + fix typo in footer + update deps`

❌ **Vague descriptions**:
- `fix: bug fix`
- `refactor: improve code`

❌ **Implementation details in header**:
- `feat: add LoginController class with authenticate method`

❌ **Missing WHY in body**:
- `fix(api): change validation` (why was it changed?)

---

## Git Workflow Integration

### Feature Branch Workflow

#### Starting New Feature
```bash
git checkout -b feature/user-authentication
# Make changes...
git add src/auth/
git commit -m "feat(auth): add JWT authentication middleware"
git commit -m "test(auth): add authentication integration tests"
git commit -m "docs(auth): document authentication setup"
```

#### Completing Feature
```bash
git checkout main
git pull origin main
git checkout feature/user-authentication
git rebase main
# Resolve conflicts if any
git push origin feature/user-authentication
# Create PR
```

### Trunk-Based Development

#### Small Incremental Commits
```bash
git checkout main
git pull
# Make small change
git add src/utils/validator.ts
git commit -m "refactor(utils): extract email validation to utility"
git push origin main
# Immediately deployed (CI/CD)
```

#### Feature Flags for Large Changes
```
feat(payment): add Stripe integration behind feature flag

Implements payment processing with Stripe API.
Disabled by default - controlled by FEATURE_STRIPE_ENABLED.

This allows merging to main without impacting production users.
```

### GitFlow Workflow

#### Release Branch Commits
```
chore(release): prepare v2.1.0 release

Updates version numbers and changelog.
Locks dependencies for stable release.

Release notes: docs/releases/v2.1.0.md
```

#### Hotfix Commits
```
fix(critical): patch authentication bypass vulnerability

Immediately fixes CVE-2024-1234 in production.
Backported from develop branch security fix.

Severity: Critical
Deployed: 2024-12-12 23:45 UTC
```

---

## CI/CD Commit Message Triggers

### Automated Changelog Generation

Commits automatically trigger changelog entries:

```
feat(api): add pagination to user list endpoint

Adds limit and offset query parameters.
Returns total count in response headers.

CHANGELOG: API now supports pagination for /api/users endpoint
```

### Semantic Versioning Triggers

```
feat(core): add plugin system
# → Triggers MINOR version bump (1.2.0 → 1.3.0)

fix(api): resolve memory leak in connection pool
# → Triggers PATCH version bump (1.2.0 → 1.2.1)

feat(api): migrate to GraphQL

BREAKING CHANGE: REST API endpoints removed
# → Triggers MAJOR version bump (1.2.0 → 2.0.0)
```

### Deployment Triggers

```
feat(frontend): add user dashboard

Deployed: Staging environment only (no [deploy:prod] tag)
```

```
fix(security): patch XSS vulnerability

[deploy:prod] Deploy immediately to production
Severity: High
```

### Skip CI Triggers

```
docs: fix typo in README

[skip ci] No build needed for documentation changes
```

```
style: format code with Prettier

[ci skip] Formatting only, tests not required
```

---

## Complex Multi-Commit Scenarios

### Scenario 1: Refactor + Bug Fix + Feature

**Changes**: Refactored authentication module, fixed session bug, added OAuth

**Strategy**: 3 separate commits (independent concerns)

```
refactor(auth): extract authentication logic to service layer

Improves testability and separation of concerns.
No functional changes to authentication behavior.
```

```
fix(auth): prevent session fixation vulnerability

Regenerates session ID after successful login.
Addresses security audit finding #234.

Fixes #234
```

```
feat(auth): add OAuth2 authentication support

Implements OAuth2 with Google and GitHub providers.
Includes callback handling and token management.

Closes #156
```

### Scenario 2: Database Migration + Model Changes + Tests

**Changes**: Added new user_preferences table, updated User model, added tests

**Strategy**: Single commit (tightly coupled)

```
feat(db): add user preferences system

Database changes:
- New table: user_preferences
- Migration: 20241212_add_user_preferences.sql
- Updated User model with preferences relationship

Includes tests for preferences CRUD operations.
Backward compatible - existing users get default preferences.

Closes #345
```

### Scenario 3: Multiple Independent Bug Fixes

**Changes**: Fixed 3 unrelated bugs in different modules

**Strategy**: 3 separate commits

```
fix(api): handle null values in search query
fix(ui): correct date picker timezone conversion
fix(email): resolve template rendering for long names
```

### Scenario 4: Performance Optimization Across Codebase

**Changes**: Optimized queries, added caching, reduced bundle size

**Strategy**: 3 focused commits (different optimization types)

```
perf(db): add indexes to frequently queried columns

Reduces average query time from 800ms to 120ms.
Affects user search and admin dashboard.
```

```
perf(api): implement Redis caching for user sessions

Reduces database load by 60% during peak hours.
Cache TTL: 15 minutes
```

```
perf(frontend): lazy load images and code-split routes

Reduces initial bundle size from 2.1MB to 450KB.
Improves Lighthouse score from 62 to 89.
```

---

## Commit Templates for Project Types

### Web Application Development

#### Feature Development
```
feat(auth): implement password reset workflow

Adds forgot password functionality with email verification.
Tokens expire after 1 hour for security.

Email template: templates/password_reset.html
Route: POST /api/auth/reset-password

Closes #234
```

#### Bug Fix
```
fix(ui): resolve infinite scroll pagination

Prevents duplicate API calls when scrolling rapidly.
Adds debounce to scroll event handler (300ms).

Reproduces with rapid scrolling on slow connections.

Fixes #456
```

### API Development

#### New Endpoint
```
feat(api): add user profile update endpoint

Endpoint: PUT /api/users/:id/profile
Authentication: Required (JWT)
Validation: Email, phone, bio fields

Rate limit: 10 requests per minute
Response: 200 OK with updated profile
```

#### Breaking API Change
```
feat(api): standardize error response format

BREAKING CHANGE: Error responses now use RFC 7807 format

Old format:
{ "error": "Invalid input" }

New format:
{
  "type": "/errors/invalid-input",
  "title": "Invalid Input",
  "status": 400,
  "detail": "Email field is required"
}

Migration guide: docs/api-v2-migration.md
```

### Infrastructure/DevOps

#### Infrastructure Change
```
feat(infra): add Redis cluster for session management

Provisions 3-node Redis cluster in production.
Enables session persistence and horizontal scaling.

Terraform changes:
- modules/redis/cluster.tf
- environments/prod/redis.tfvars

Cost impact: +$120/month
```

#### CI/CD Update
```
ci(github): add automated security scanning

Integrates Snyk for dependency vulnerability scanning.
Runs on every PR and daily on main branch.

Blocks merge if high severity vulnerabilities found.
Notifications: #security-alerts Slack channel
```

### Library/Package Development

#### Public API Addition
```
feat(api): add transform() method to DataProcessor

Public API addition - backward compatible.
Supports custom transformation functions.

Usage:
processor.transform((data) => data.map(x => x * 2))

Closes #67
```

#### Breaking Change
```
feat(api): migrate to async/await pattern

BREAKING CHANGE: All methods now return Promises

Migration:
- Before: processor.process(data)
- After: await processor.process(data)

Migration script: scripts/migrate-to-async.js
Version: 2.0.0
```

---

## Commit Message Templates by Situation

### When Adding Tests
```
test(auth): add integration tests for OAuth flow

Covers success, failure, and edge cases:
- Valid OAuth callback with code
- Invalid state parameter
- Expired authorization code
- Network timeout scenarios

Coverage: auth module 45% → 89%
```

### When Updating Dependencies
```
build(deps): upgrade React from 18.2.0 to 18.3.0

Updates React and related packages.
No breaking changes in this version.

All tests pass. Manual testing verified:
- User dashboard rendering
- Form submissions
- Routing behavior
```

### When Refactoring
```
refactor(db): migrate from Sequelize to TypeORM

Replaces Sequelize ORM with TypeORM for better TypeScript support.
No changes to database schema or query behavior.

Migration verified with full test suite (237 tests passing).
Performance impact: neutral (benchmarked identical query times).
```

### When Improving Performance
```
perf(search): implement full-text search with PostgreSQL

Replaces LIKE queries with PostgreSQL tsvector search.
Reduces search time from 2.3s to 180ms (92% improvement).

Added GIN index: products_search_idx
Affects: product search, admin search
```

### When Fixing Security Issue
```
fix(security): sanitize user input to prevent XSS

Implements DOMPurify for all user-generated content.
Affects profile bios, comments, and forum posts.

Vulnerability: Stored XSS via profile bio field
Severity: High (CVSS 7.5)
CVE: Pending assignment

Fixes #890
```

### When Adding Documentation
```
docs(api): add comprehensive authentication guide

Adds authentication documentation:
- JWT token acquisition
- Token refresh flow
- Permission system explanation
- Example requests with curl

Location: docs/api/authentication.md
```

---

## Final Checklist

Before outputting suggestions:

- [ ] All changed files analyzed
- [ ] Grouping logic is sound (single vs multiple commits)
- [ ] Type and scope accurately reflect changes
- [ ] Body explains WHY (not just restates header)
- [ ] Breaking changes explicitly documented
- [ ] Security/performance impacts noted
- [ ] Language consistent with repository
- [ ] No auto-execution (suggestion only)
- [ ] CI/CD triggers considered (if applicable)
- [ ] Workflow compatibility verified (feature branch, trunk-based, etc.)

---

**Reference**: `Commits_Message_Reference.md` for detailed standards.
**Last Updated**: 2025-12-12
**Version**: 2.0
