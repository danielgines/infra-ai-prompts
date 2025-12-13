# Conventional Commits Reference

> **Purpose**: Comprehensive reference for commit message standards. Use this as foundation for all commit-related prompts.

---

## Table of Contents

1. [Format Structure](#format-structure)
2. [Commit Types](#commit-types)
3. [Scope Guidelines](#scope-guidelines)
4. [Description Best Practices](#description-best-practices)
5. [Body Guidelines](#body-guidelines)
6. [Footer Conventions](#footer-conventions)
7. [Multi-Commit Guidelines](#multi-commit-guidelines)
8. [Type Selection Decision Tree](#type-selection-decision-tree)
9. [Scope Selection Patterns](#scope-selection-patterns)
10. [Language Consistency](#language-consistency)
11. [Tool Integration](#tool-integration)
12. [Examples by Context](#examples-by-context)
13. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)
14. [Validation Checklist](#validation-checklist)
15. [Advanced Patterns](#advanced-patterns)

---

## Format Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Core Rules

- **Header** ≤ 50 characters (hard limit: 72 characters)
- Use **imperative mood** ("add" not "added" or "adds")
- No period at end of header
- **Body** wraps at 72 characters
- Separate header from body with blank line
- Footer for breaking changes and issue references
- Blank line between body and footer

### Format Validation

✅ **Valid**:
```
feat(api): add user registration endpoint

Implements POST /api/users with email validation.
Sends confirmation email via SendGrid.

Closes #123
```

❌ **Invalid** (period in header):
```
feat(api): add user registration endpoint.
```

❌ **Invalid** (missing blank line):
```
feat(api): add user registration endpoint
Implements POST /api/users
```

---

## Commit Types

### Development Types

#### `feat` - New Feature

**Purpose**: Introduces new functionality or capability

**When to use**:
- Adding new user-facing feature
- Adding new API endpoint
- Adding new CLI command
- Adding new configuration option

**Examples**:

```
feat(auth): add OAuth2 authentication support

feat(api): implement GraphQL subscriptions

feat(cli): add --verbose flag for debugging

feat(ui): add dark mode toggle

feat(payment): integrate Stripe payment gateway
```

**When NOT to use**:
- Enhancement to existing feature (use `refactor` or `perf`)
- Internal code improvements without user impact (use `refactor`)

---

#### `fix` - Bug Fix

**Purpose**: Resolves defect or error in existing functionality

**When to use**:
- Fixing broken functionality
- Resolving crashes or errors
- Correcting incorrect behavior
- Addressing security vulnerabilities

**Examples**:

```
fix(auth): prevent token reuse after logout

fix(api): handle null pointer in user lookup

fix(db): resolve connection pool exhaustion

fix(ui): correct date picker timezone handling

fix(security): sanitize user input to prevent XSS
```

**Severity Indicators** (optional in description):
```
fix(critical): prevent SQL injection in search query
fix(api): resolve race condition in payment processing
fix(minor): correct typo in error message
```

---

#### `docs` - Documentation Only

**Purpose**: Changes to documentation with no code modifications

**When to use**:
- README updates
- API documentation
- Code comments (if standalone commit)
- Docstring additions/corrections
- Wiki or external documentation

**Examples**:

```
docs: update API authentication guide

docs(readme): add installation instructions for Windows

docs(api): document rate limiting behavior

docs: fix broken links in contributing guide

docs(setup): clarify environment variable requirements
```

**When NOT to use**:
- Documentation changes bundled with code changes (use primary type: `feat`, `fix`, etc.)

---

#### `style` - Code Formatting

**Purpose**: Changes that don't affect code meaning (whitespace, formatting, semicolons)

**When to use**:
- Running code formatters (Prettier, Black, gofmt)
- Fixing indentation
- Removing trailing whitespace
- Adjusting line breaks

**Examples**:

```
style: format code with Prettier

style(js): apply ESLint auto-fixes

style: remove trailing whitespace

style(css): organize properties alphabetically

style: fix indentation in config files
```

**When NOT to use**:
- Renaming variables (use `refactor`)
- Restructuring code (use `refactor`)

---

#### `refactor` - Code Restructuring

**Purpose**: Code changes that neither fix bugs nor add features

**When to use**:
- Extracting functions/methods
- Renaming variables/functions for clarity
- Simplifying complex logic
- Removing code duplication
- Reorganizing file structure

**Examples**:

```
refactor(db): extract query builder to separate module

refactor(auth): simplify token validation logic

refactor: rename ambiguous variable names

refactor(api): consolidate duplicate error handling

refactor(utils): extract date formatting to helper
```

---

#### `perf` - Performance Improvement

**Purpose**: Code changes that improve performance

**When to use**:
- Optimizing algorithms
- Reducing database queries
- Implementing caching
- Reducing bundle size
- Improving render performance

**Examples**:

```
perf(parser): optimize regex compilation

perf(db): add index to frequently queried columns

perf(api): implement response caching

perf(ui): lazy load images below fold

perf(build): reduce webpack bundle size by 40%
```

**Include metrics when possible**:
```
perf(search): reduce query time from 2s to 200ms

perf(api): decrease memory usage by 50%
```

---

#### `test` - Test Changes

**Purpose**: Adding or modifying tests (no production code changes)

**When to use**:
- Adding missing tests
- Fixing flaky tests
- Improving test coverage
- Refactoring test code

**Examples**:

```
test(auth): add JWT expiration tests

test(api): cover edge cases in validation

test: increase coverage to 90%

test(integration): add end-to-end payment flow test

test(unit): mock external API dependencies
```

---

### Operational Types

#### `build` - Build System/Dependencies

**Purpose**: Changes to build process or external dependencies

**When to use**:
- Updating dependencies
- Changing build configuration
- Modifying package manager files
- Adjusting compilation settings

**Examples**:

```
build(deps): upgrade express to 4.18.0

build: migrate from webpack to vite

build(npm): update all minor versions

build(docker): optimize image build layers

build: add TypeScript compilation step
```

**Dependency updates format**:
```
build(deps): bump lodash from 4.17.20 to 4.17.21
```

---

#### `ci` - CI/CD Changes

**Purpose**: Changes to continuous integration/deployment configuration

**When to use**:
- Modifying CI pipeline configuration
- Adding/removing CI jobs
- Changing deployment scripts
- Updating GitHub Actions/GitLab CI

**Examples**:

```
ci: add automated security scanning

ci(github): enable dependabot for security updates

ci: parallelize test execution

ci(deploy): add blue-green deployment strategy

ci: configure automatic preview deployments
```

---

#### `chore` - Maintenance Tasks

**Purpose**: Routine tasks and housekeeping (no production code impact)

**When to use**:
- Updating gitignore
- Modifying editor configuration
- Adjusting linter rules
- License updates
- Routine maintenance

**Examples**:

```
chore: update gitignore patterns

chore(lint): adjust ESLint rules

chore: bump copyright year to 2025

chore(git): configure pre-commit hooks

chore: update LICENSE file
```

---

#### `revert` - Revert Previous Commit

**Purpose**: Reverts a previous commit

**Format**: Include original commit hash and reason

**Examples**:

```
revert: revert "feat(api): add rate limiting"

This reverts commit a1b2c3d4. Rate limiting caused
unexpected 429 errors in production.

revert: revert "perf(db): add composite index"

Composite index degraded write performance by 40%.
Need to investigate alternative optimization.
```

---

## Scope Guidelines

### What is a Scope?

Scope indicates the **section/component/module** affected by the change.

### Common Scope Categories

#### Infrastructure/Backend
- `core` - Core application logic
- `config` - Configuration files/management
- `setup` - Initial setup/bootstrap
- `deps` - Dependencies management
- `db` - Database layer
- `api` - API layer
- `cli` - Command-line interface
- `ci` - CI/CD pipelines
- `docker` - Docker configuration
- `k8s` - Kubernetes manifests

#### Application Features
- `auth` - Authentication/Authorization
- `user` - User management
- `payment` - Payment processing
- `ui` - User interface (general)
- `router` - Routing logic
- `middleware` - Middleware components
- `validation` - Input validation
- `email` - Email functionality
- `search` - Search functionality
- `cache` - Caching layer

#### Frontend Specific
- `components` - React/Vue/Angular components
- `pages` - Page-level components
- `styles` - CSS/styling
- `state` - State management (Redux, Vuex)
- `hooks` - React hooks
- `utils` - Utility functions

#### Tooling/DevOps
- `scripts` - Build/utility scripts
- `build` - Build configuration
- `deploy` - Deployment scripts
- `monitoring` - Monitoring/observability
- `logging` - Logging infrastructure

### Monorepo Scopes

For monorepos, use package/workspace names:

```
feat(web): add user dashboard
feat(api): implement GraphQL endpoint
feat(mobile): add push notifications
feat(shared): extract common utilities
```

### When to Omit Scope

Omit scope when change affects entire project:

```
docs: update README
chore: update LICENSE
build(deps): upgrade all dependencies
```

---

## Description Best Practices

### Imperative Mood

**Correct**: "add", "fix", "update", "remove"
**Incorrect**: "added", "fixed", "updating", "removes"

Think: "This commit will **[description]**"

✅ `feat(auth): add password reset functionality`
❌ `feat(auth): added password reset functionality`

### Length Guidelines

- **Target**: 50 characters
- **Maximum**: 72 characters (hard limit)
- **Minimum**: 20 characters (avoid too vague)

### Capitalization

**Lowercase first letter** (after colon):

✅ `feat(api): add user registration`
❌ `feat(api): Add user registration`

### Specificity

Be specific about what changed:

✅ `fix(api): prevent SQL injection in search endpoint`
❌ `fix(api): security fix`

✅ `feat(payment): integrate Stripe payment gateway`
❌ `feat(payment): add payment stuff`

### Action Verbs

**Strong verbs**:
- `add` - introduce new capability
- `implement` - complete feature implementation
- `fix` - repair defect
- `resolve` - address issue
- `prevent` - stop undesired behavior
- `update` - modify existing
- `remove` - delete/deprecate
- `refactor` - restructure
- `optimize` - improve performance
- `extract` - separate concerns
- `migrate` - move to new system

**Weak verbs to avoid**:
- `change` (too vague)
- `update` (when more specific verb exists)
- `improve` (too subjective)
- `modify` (too generic)

---

## Body Guidelines

### When to Include Body

**Always include body for**:
- Non-obvious changes
- Complex bug fixes
- Breaking changes
- Performance optimizations
- Security fixes
- Refactoring decisions

**Optional for**:
- Simple dependency updates
- Obvious typo fixes
- Trivial style changes

### Body Structure

**Focus on WHY and WHAT (not HOW)**

**Template**:
```
[Type](scope): [description]

[Why was this change necessary?]
[What does this change accomplish?]
[Any important side effects or considerations?]

[Footer if needed]
```

### Body Examples

#### Example 1: Feature with Context

```
feat(cache): implement Redis-backed session storage

Replaces in-memory sessions to support horizontal scaling.
Adds automatic cleanup of expired sessions (TTL: 24 hours).

Sessions are now persistent across server restarts, improving
user experience during deployments.
```

#### Example 2: Bug Fix with Impact

```
fix(auth): prevent token reuse after logout

Adds token to blacklist on logout to prevent replay attacks.
Tokens expire from blacklist after their natural TTL (15 min).

This fixes a security vulnerability where logged-out users
could continue using cached tokens for API access.

Closes #234
```

#### Example 3: Performance Optimization

```
perf(search): add full-text search index

Reduces average search query time from 2.3s to 180ms.
Implements PostgreSQL GIN index on product descriptions.

The previous sequential scan was causing timeout issues
for users with large catalogs (>10k products).
```

#### Example 4: Refactoring with Rationale

```
refactor(database): extract query builder to separate module

Improves testability by isolating database logic.
Reduces coupling between business logic and persistence.
No functional changes to query behavior.

This enables easier migration to alternative databases
in the future and simplifies unit testing.
```

### Body Formatting

- Wrap at 72 characters
- Use blank lines to separate paragraphs
- Use bullet points for lists
- Keep paragraphs focused (one idea per paragraph)

---

## Footer Conventions

### Breaking Changes

**Format**:
```
BREAKING CHANGE: <description>
```

**Full Example**:
```
feat(api): migrate to GraphQL

Replaces REST endpoints with GraphQL API.
Provides better flexibility for frontend queries.

BREAKING CHANGE: REST API v1 endpoints removed.

All clients must migrate to GraphQL. See migration guide:
https://docs.example.com/v2-migration

Endpoints removed:
- GET /api/users
- POST /api/users
- PUT /api/users/:id
- DELETE /api/users/:id

GraphQL equivalent: query { users { ... } }

Closes #567
```

### Issue References

**Formats**:

```
Closes #123
Fixes #456
Resolves #789
Refs #101
See #202
```

**Multiple issues**:
```
Closes #123, #124, #125
Fixes #456 and #789
```

**GitHub special keywords**:
- `Closes` - closes issue
- `Fixes` - closes issue (bug fix context)
- `Resolves` - closes issue
- `Refs` - references without closing
- `See` - references without closing

**Full example**:
```
fix(api): handle race condition in payment processing

Adds database-level locking to prevent duplicate charges.
Implements idempotency keys for payment requests.

Fixes #789
Closes #790
Refs #654
```

### Co-Authors

```
Co-authored-by: Name <email@example.com>
Co-authored-by: Another Dev <dev@example.com>
```

### Sign-off (for DCO compliance)

```
Signed-off-by: Developer Name <dev@example.com>
```

---

## Multi-Commit Guidelines

### When to Create Single Commit

**Tightly coupled changes**:
- Feature implementation + tests + documentation
- Refactoring affecting multiple files uniformly
- Dependency update + necessary code adjustments
- Bug fix + regression test

**Example**:
```
feat(payment): implement Stripe integration

Adds payment processing using Stripe API v2.
Includes webhook handler for payment confirmations.
Supports one-time and subscription payments.

Tests cover success, failure, and timeout scenarios.
Documentation added to docs/payment-integration.md
```

### When to Create Multiple Commits

**Independent changes**:
- Unrelated bug fixes
- Different scopes (e.g., `api` + `docs` + `ci`)
- Mix of refactor + new feature + extensive docs
- Separate features that can be deployed independently

**Bad** (bundled unrelated changes):
```
feat: add auth + fix ui bug + update deps
```

**Good** (separate commits):
```
feat(auth): add JWT authentication
fix(ui): correct date picker timezone handling
build(deps): upgrade express to 4.18.0
```

---

## Type Selection Decision Tree

### Is it user-facing?

**YES** → Is it new functionality?
  - **YES** → `feat`
  - **NO** → Is it broken?
    - **YES** → `fix`
    - **NO** → `refactor` or `perf`

**NO** → Does it affect build/deploy?
  - **YES** → Is it dependencies?
    - **YES** → `build`
    - **NO** → `ci`
  - **NO** → Is it tests only?
    - **YES** → `test`
    - **NO** → Is it documentation only?
      - **YES** → `docs`
      - **NO** → `chore`

### Common Confusion

#### `feat` vs `refactor`

- **feat**: Adds new capability users can access
- **refactor**: Restructures code without changing external behavior

```
feat(api): add pagination to user list endpoint    ✅ New capability
refactor(api): simplify pagination implementation  ✅ Internal improvement
```

#### `fix` vs `refactor`

- **fix**: Repairs broken functionality
- **refactor**: Improves working code

```
fix(auth): prevent null pointer on logout         ✅ Was broken
refactor(auth): simplify logout logic             ✅ Was working, now better
```

#### `perf` vs `refactor`

- **perf**: Improves performance with measurable impact
- **refactor**: Restructures without performance focus

```
perf(db): add index reducing query time by 80%    ✅ Measurable improvement
refactor(db): extract query logic to repository   ✅ Better structure
```

---

## Scope Selection Patterns

### Project Type Patterns

#### Web Application
- `frontend` / `backend` / `api`
- `components` / `pages` / `layouts`
- `auth` / `user` / `admin`
- `database` / `cache` / `queue`

#### CLI Tool
- `cli` / `commands` / `flags`
- `config` / `core` / `utils`
- `output` / `parser` / `formatter`

#### Library/Package
- `core` / `api` / `types`
- `utils` / `helpers` / `validators`
- `exports` / `index` / `main`

#### Microservices
- Service names: `auth-service`, `payment-service`, `user-service`
- `gateway` / `proxy` / `router`
- `messaging` / `events` / `queue`

### Monorepo Patterns

#### Workspace-based
```
feat(@web/ui): add user dashboard
fix(@api/graphql): resolve query performance
build(@shared/utils): export common types
```

#### Package-based
```
feat(packages/frontend): implement dark mode
fix(packages/backend): handle CORS properly
docs(packages/sdk): add integration examples
```

---

## Language Consistency

### Choosing Language

**Use English when**:
- Open source projects
- International teams
- Technical infrastructure
- Libraries/packages for public use
- Projects with external contributors

**Use native language when**:
- Internal tools for local team
- Company explicitly requires it
- All team members share native language
- Domain-specific terminology in native language

### Mixed Language Anti-Pattern

❌ **Bad** (inconsistent):
```
feat(auth): add login functionality
fix(api): corrigir validação de senha
docs: actualizar documentación
```

✅ **Good** (consistent):
```
feat(auth): add login functionality
fix(api): fix password validation
docs: update documentation
```

---

## Tool Integration

### commitlint

**Installation**:
```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

**Configuration** (commitlint.config.js):
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert'
    ]],
    'scope-case': [2, 'always', 'kebab-case'],
    'subject-case': [2, 'never', ['upper-case']],
    'subject-max-length': [2, 'always', 50]
  }
};
```

### Husky + commitlint

**Setup commit-msg hook**:
```bash
npx husky install
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

### semantic-release

**Configuration** (.releaserc.json):
```json
{
  "branches": ["main", "master"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github"
  ]
}
```

**Version bumps**:
- `fix:` → patch release (1.0.0 → 1.0.1)
- `feat:` → minor release (1.0.0 → 1.1.0)
- `BREAKING CHANGE:` → major release (1.0.0 → 2.0.0)

### conventional-changelog

**Generate changelog**:
```bash
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

**Automated in package.json**:
```json
{
  "scripts": {
    "changelog": "conventional-changelog -p angular -i CHANGELOG.md -s -r 0"
  }
}
```

---

## Examples by Context

### Feature with Tests

```
feat(payment): implement Stripe integration

Adds payment processing using Stripe API v2.
Includes webhook handler for payment confirmations.
Supports one-time and subscription payments.

Tests cover success, failure, and timeout scenarios.
Integration tests use Stripe test mode.

Closes #345
```

### Bug Fix with Impact

```
fix(auth): prevent token reuse after logout

Adds token to blacklist on logout to prevent replay attacks.
Tokens expire from blacklist after their natural TTL (15 min).

This fixes CVE-2024-1234 where logged-out users could
continue accessing the API using cached tokens.

Fixes #234
Refs #567 (security audit)
```

### Refactoring

```
refactor(database): extract query builder to separate module

Moves SQL query construction to dedicated QueryBuilder class.
Improves testability and reduces coupling with business logic.
No functional changes to query behavior or results.

This enables easier migration to alternative databases
and simplifies unit testing of query logic in isolation.
```

### Breaking Change

```
feat(api): migrate to GraphQL

Replaces REST endpoints with GraphQL API.
Provides better flexibility for complex frontend queries
and reduces over-fetching of data.

BREAKING CHANGE: REST API v1 endpoints removed.

All clients must migrate to GraphQL. Migration guide:
https://docs.example.com/v2-migration

Removed endpoints:
- GET /api/users
- POST /api/users
- PUT /api/users/:id
- DELETE /api/users/:id

GraphQL equivalent:
query { users { id name email } }
mutation { createUser(input: {...}) { id } }

Closes #567
```

### Performance Optimization

```
perf(search): implement full-text search with PostgreSQL

Replaces LIKE queries with PostgreSQL full-text search (tsvector).
Reduces average search time from 2.3s to 180ms (92% improvement).

Implements GIN index on product names and descriptions.
Adds ts_rank for relevance scoring.

This resolves timeout issues for users with large catalogs
(>10,000 products) and improves search result quality.

Closes #789
```

### Security Fix

```
fix(security): sanitize user input to prevent XSS

Implements DOMPurify for HTML sanitization before rendering.
Escapes special characters in user-generated content.
Adds Content-Security-Policy header to all responses.

This fixes XSS vulnerability where malicious scripts could
be injected via profile bio fields (CVE-2024-5678).

Severity: High
CVSS Score: 7.5

Fixes #890
```

### Dependency Update

```
build(deps): upgrade express from 4.17.1 to 4.18.2

Updates Express to address security vulnerabilities:
- CVE-2022-24999 (high severity)
- CVE-2022-24999 (medium severity)

No breaking changes in Express 4.18.x.
All tests pass with new version.
```

### CI/CD Enhancement

```
ci(github): add automated dependency updates

Configures Dependabot for automatic dependency PRs.
Adds workflow to auto-merge passing security updates.

Schedule: daily for security, weekly for other dependencies
Auto-merge: enabled for patch and minor updates with passing tests

This reduces manual dependency maintenance burden.
```

### Documentation Update

```
docs(api): add rate limiting documentation

Documents rate limit policies for all API endpoints.
Includes examples of handling 429 responses.
Adds retry strategy recommendations.

Rate limits:
- Authenticated: 1000 req/hour
- Unauthenticated: 60 req/hour
```

---

## Anti-Patterns to Avoid

### ❌ Vague Descriptions

```
fix: bug fix
update: changes
chore: stuff
refactor: improvements
```

### ❌ Implementation Details in Header

```
feat: add UserController class with getUserById, createUser, and updateUser methods
```

Should be:
```
feat(user): add user management endpoints
```

### ❌ Multiple Unrelated Changes

```
feat: add auth + fix ui bug + update deps + refactor database
```

Should be 4 separate commits:
```
feat(auth): add JWT authentication
fix(ui): correct date picker timezone
build(deps): upgrade Express to 4.18.0
refactor(db): extract query builder
```

### ❌ Missing Context

```
fix: resolve issue
update: fix problem
change: modify code
```

Should include what/where:
```
fix(api): prevent null pointer in user lookup
update(docs): clarify authentication requirements
refactor(auth): simplify token validation logic
```

### ❌ Past Tense

```
feat(api): added user registration
fix(ui): fixed date picker bug
```

Should be imperative:
```
feat(api): add user registration
fix(ui): fix date picker bug
```

### ❌ Meaningless Footers

```
Closes #123
Refs #124
See #125
Fixes #126
```

Only reference truly related issues.

---

## Validation Checklist

Before committing, verify:

- [ ] **Type** accurately reflects change nature
- [ ] **Scope** is appropriate (or intentionally omitted)
- [ ] **Description** is imperative mood, concise, no period
- [ ] **Description** is specific (not vague like "fix bug")
- [ ] **Description** is ≤50 characters (max 72)
- [ ] **Body** explains WHY when non-obvious
- [ ] **Body** wraps at 72 characters
- [ ] **Body** separated from header with blank line
- [ ] **Breaking changes** documented in footer with BREAKING CHANGE:
- [ ] **Issue references** included when applicable
- [ ] **Language** consistent with repository
- [ ] **No multiple unrelated changes** bundled together
- [ ] **Commit passes** commitlint if configured

---

## Advanced Patterns

### Squash Commit Messages

When squashing, preserve meaningful history:

```
feat(auth): implement OAuth2 authentication

- Add OAuth2 provider configuration
- Implement authorization code flow
- Add token refresh mechanism
- Create user session management
- Add OAuth2 callback handler

Tests added for all flows including error scenarios.

Closes #234, #235, #236
```

### Monorepo Commits

Cross-workspace changes:

```
refactor(shared): extract common validation utilities

Moves email and phone validation from @web/api and @mobile/app
to @shared/utils for reuse across all workspaces.

Affected packages:
- @web/api
- @mobile/app
- @shared/utils

No breaking changes to existing validation behavior.
```

### Hotfix Pattern

Urgent production fixes:

```
fix(critical): patch SQL injection vulnerability in search

Immediately sanitizes user input in search queries.
Temporary fix until full query parameterization (scheduled for v2.1).

Severity: Critical
Production: Deployed 2024-12-12 23:45 UTC

Refs #999 (long-term solution)
```

---

**Reference**: https://www.conventionalcommits.org/
**Last Updated**: 2025-12-12
**Version**: 2.0
