# Enterprise Team Commit Preferences

> **Project**: Enterprise E-Commerce Platform
> **Team**: Backend Development Team
> **Repository**: https://github.com/enterprise/ecommerce-platform
> **Last Updated**: 2025-12-11

---

## Project Information

**Tech Stack**: Node.js, React, PostgreSQL, Redis, Kubernetes
**Team Size**: 15 developers across 3 sub-teams
**Methodology**: Agile/Scrum with 2-week sprints
**Issue Tracker**: Jira
**CI/CD**: GitHub Actions + ArgoCD

---

## Standard Scopes

### Feature Scopes (Domain)

Core business functionality:

- `auth` - Authentication and authorization (JWT, OAuth, SSO)
- `user` - User profile and account management
- `product` - Product catalog and inventory
- `cart` - Shopping cart functionality
- `order` - Order processing and fulfillment
- `payment` - Payment processing (Stripe, PayPal)
- `shipping` - Shipping calculation and tracking
- `notification` - Email and push notifications
- `analytics` - Analytics tracking and reporting
- `admin` - Admin dashboard and tools

### Layer Scopes (Architecture)

Technical layers:

- `api` - REST API endpoints
- `graphql` - GraphQL schema and resolvers
- `ui` - React components and pages
- `db` - Database schema, migrations, queries
- `cache` - Redis caching layer
- `queue` - Job queue processing (Bull/RabbitMQ)
- `websocket` - Real-time WebSocket connections

### Infrastructure Scopes

DevOps and tooling:

- `config` - Application configuration
- `docker` - Docker images and compose files
- `k8s` - Kubernetes manifests and Helm charts
- `ci` - GitHub Actions workflows
- `monitoring` - Prometheus, Grafana, logging
- `security` - Security scanning, secrets management
- `deps` - Dependency updates

### When to Omit Scope

Omit scope when:
- Change affects entire project (e.g., `chore: upgrade Node.js to v20`)
- Root-level documentation (e.g., `docs: update README`)
- Cross-cutting concerns spanning >3 scopes
- Build system changes affecting everything (e.g., `build: migrate to pnpm`)

---

## Commit Types (Standard + Custom)

### Standard Types

Use Conventional Commits standard types:

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting (no logic change)
- `refactor` - Code restructuring
- `perf` - Performance improvement
- `test` - Add/modify tests
- `build` - Build system/dependencies
- `ci` - CI/CD changes
- `chore` - Maintenance tasks
- `revert` - Revert previous commit

### Custom Types (Extended)

Additional types for enterprise needs:

- `security` - Security fixes and updates (CVEs, vulnerabilities)
- `compliance` - Compliance-related changes (GDPR, PCI-DSS, SOC2)
- `a11y` - Accessibility improvements (WCAG compliance)
- `i18n` - Internationalization (translations, locale support)

---

## Header Format Conventions

### Length Requirements

- **Recommended**: ≤50 characters for readability in GitHub UI
- **Maximum**: 72 characters (hard limit, enforced by commitlint)

### Capitalization

- **Type**: lowercase (`feat` not `Feat`)
- **Scope**: lowercase (`auth` not `Auth`)
- **Subject**: Sentence case (`Add login feature` not `add login feature`)

### Punctuation

- **No period** at end of header
- **Colon after scope**: `feat(auth): add login`
- **No special characters** except hyphens in subject

### Emoji Usage

**We DO NOT use emojis** in commit messages. Keep it professional and CLI-friendly.

---

## Body Format Conventions

### When Body is Required

Body is **REQUIRED** for:

1. **Breaking changes** - Must explain migration path
2. **Security fixes** - Describe vulnerability and fix
3. **Performance improvements** - Include before/after metrics
4. **Database changes** - Document migration impact
5. **Large refactorings** - Explain rationale
6. **Commits changing >10 files** - Provide context

Body is **RECOMMENDED** for:

- New features (explain what problem it solves)
- Complex bug fixes (root cause analysis)
- API changes (backward compatibility notes)

### Body Structure

**Required elements**:

1. **What**: Describe the change
2. **Why**: Explain the motivation
3. **Impact**: State affected areas or users
4. **Metrics**: For performance changes (before/after)
5. **Risks**: Document potential issues
6. **Testing**: Mention test coverage

**Format**:
```
feat(payment): add support for Apple Pay

Implements Apple Pay integration for iOS users.
Reduces checkout abandonment by providing preferred payment method.

Impact:
- iOS users can now use Apple Pay
- Reduces checkout steps from 4 to 2
- Expected 15% increase in conversion rate

Testing:
- Unit tests for payment processing
- Integration tests with Apple Pay sandbox
- Manual testing on iPhone 12, 13, 14

Closes ECOM-1234
```

### Line Wrapping

- **Hard wrap at 72 characters**
- Use bullet points for multiple items
- Separate sections with blank lines

---

## Footer Conventions

### Breaking Changes

**Format**:
```
BREAKING CHANGE: API endpoints moved to /v2/ namespace

All API endpoints now require /v2/ prefix.
Example: /users → /v2/users

Migration guide: https://docs.internal.example.com/migration-v2

Affected endpoints:
- /users
- /products
- /orders
- /payments

Deployment requires:
1. Update all API clients to use /v2/ prefix
2. Run database migration: npm run db:migrate
3. Update environment variables (see .env.example)
```

**Requirements**:
- Requires **VP Engineering approval** before merging
- Must include **migration guide** link or inline steps
- Post in **#eng-announcements** Slack channel before deploy
- Update **BREAKING_CHANGES.md** in repository

### Issue References

**Format**: Jira ticket reference (required for all commits to main)

```
Closes ECOM-1234
```

**Multiple issues**:
```
Closes ECOM-1234, Closes ECOM-5678
```

**Reference only (no close)**:
```
Refs ECOM-9999
```

**Requirements**:
- All commits to `main` **MUST** reference a Jira ticket
- Use `Closes` for completed work
- Use `Refs` for partial work or related context
- Ticket must be in "In Progress" status when committing

### Co-Authors

**Required for**:
- Pair programming sessions
- Mob programming
- Significant contributions from multiple developers

**Format**:
```
Co-authored-by: Jane Doe <jane.doe@enterprise.com>
Co-authored-by: John Smith <john.smith@enterprise.com>
```

### Sign-Off

**Required for all production commits** (SOC2 compliance):

```bash
git commit -s
```

**Format**:
```
Signed-off-by: Alice Johnson <alice.johnson@enterprise.com>
```

**Purpose**: Certifies that you wrote the code and have right to contribute it.

### Custom Footers

#### Change-Id (Required for Compliance)

For audit trail and change management:

```
Change-Id: CR-2025-0123
```

**When required**:
- All commits to production branches
- Security-related changes
- Database schema changes
- Infrastructure changes

#### Reviewed-By

For code review attribution:

```
Reviewed-by: Tech Lead <techlead@enterprise.com>
```

**When required**:
- All commits to `main` branch
- Breaking changes
- Security fixes

#### Tested-By

For QA verification:

```
Tested-by: QA Team <qa@enterprise.com>
```

**When required**:
- Features requiring manual QA
- Integration changes
- Payment processing changes

---

## Commit Frequency and Granularity

### Commit Size Preference

**Preferred**: Small atomic commits (one logical change)

**Guidelines**:
- Maximum 15 files per commit (unless refactoring)
- Maximum 300 lines changed per commit (guideline, not hard rule)
- Each commit should leave codebase in working state
- All tests must pass after each commit

### WIP Commits

**Policy**: WIP commits **allowed on feature branches only**

**Format**:
```
WIP(auth): implement OAuth flow - incomplete

TODO: Add error handling
TODO: Write tests
```

**Requirements**:
- **MUST** be squashed before merging to main
- Use interactive rebase: `git rebase -i origin/main`
- Never merge WIP commits to main

### Fixup Commits

**Policy**: Encouraged during code review

**Format**:
```
fixup! feat(auth): add OAuth provider
```

**Workflow**:
1. Make changes based on review feedback
2. Commit with `fixup!` prefix
3. Before merge: `git rebase -i --autosquash origin/main`

---

## Branch-Specific Conventions

### Main Branch

**Requirements**:
- All commits **MUST** pass CI/CD
- All commits **MUST** have passing tests
- All commits **MUST** reference Jira ticket
- All commits **MUST** have PR approval (2 reviewers minimum)
- Commit messages **MUST** be high quality
- Use **squash merge** for PRs (GitHub setting)

### Feature Branches

**Naming**: `feature/ECOM-1234-short-description`

**Commit frequency**: Commit often (save work), clean up before merge

**History cleanup**: **Required before merge**
```bash
git rebase -i origin/main
# Squash WIP commits
# Reword unclear messages
# Ensure logical commit sequence
```

### Release Branches

**Naming**: `release/v2.5.0`

**Allowed commit types**: `fix`, `chore`, `docs` only (no features)

**Special footer**:
```
Release-Notes: Brief description for changelog
```

**Requirements**:
- All commits require release manager approval
- Commit to main first, then cherry-pick to release branch
- Include release notes in footer

---

## Automated Tool Configuration

### commitlint Configuration

`.commitlintrc.json`:
```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [2, "always", [
      "feat", "fix", "docs", "style", "refactor", "perf",
      "test", "build", "ci", "chore", "revert",
      "security", "compliance", "a11y", "i18n"
    ]],
    "scope-enum": [2, "always", [
      "auth", "user", "product", "cart", "order", "payment",
      "shipping", "notification", "analytics", "admin",
      "api", "graphql", "ui", "db", "cache", "queue", "websocket",
      "config", "docker", "k8s", "ci", "monitoring", "security", "deps"
    ]],
    "subject-case": [2, "always", "sentence-case"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 72],
    "body-max-line-length": [2, "always", 72],
    "footer-max-line-length": [0, "always", 100]
  }
}
```

### Conventional Changelog

`.versionrc.json`:
```json
{
  "types": [
    {"type": "feat", "section": "Features"},
    {"type": "fix", "section": "Bug Fixes"},
    {"type": "security", "section": "Security Fixes"},
    {"type": "perf", "section": "Performance Improvements"},
    {"type": "revert", "section": "Reverts"},
    {"type": "docs", "section": "Documentation", "hidden": false},
    {"type": "style", "hidden": true},
    {"type": "chore", "hidden": true},
    {"type": "refactor", "hidden": true},
    {"type": "test", "hidden": true},
    {"type": "build", "hidden": true},
    {"type": "ci", "hidden": true}
  ]
}
```

### Semantic Release

**Not used** - We use manual versioning with release branches.

---

## Team Workflow Integration

### Code Review Requirements

**Commit quality checks by reviewers**:
1. Verify commit message follows conventions
2. Check that each commit is atomic
3. Ensure Jira ticket is referenced
4. Verify no WIP commits on main
5. Confirm breaking changes are documented

**Rebase required if**:
- Commit messages don't follow convention
- Multiple WIP commits present
- Commit history is unclear or messy

**Approval needed for**:
- All commits to main (2 reviewers)
- Breaking changes (VP Engineering)
- Security fixes (Security team)

### CI/CD Integration

**Commit message triggers**:

```
[skip ci] - Skip CI pipeline (use sparingly, requires approval)
[ci deploy staging] - Deploy to staging after merge
[ci deploy prod] - Deploy to production (requires release manager approval)
```

**Automated actions based on commit type**:
- `security:` commits → Trigger security scan + notify security team
- `deps:` commits → Run dependency vulnerability check
- `k8s:` commits → Validate Kubernetes manifests
- `db:` commits → Run database migration tests

### Documentation Generation

**Changelog**: Generated automatically on release
```bash
npm run release:changelog
```

**Release Notes**: Curated from commits with `Release-Notes:` footer

**API Docs**: Updated automatically from code comments (TypeDoc)

---

## Compliance and Audit Requirements

### Audit Trail

**Required for all production commits**:
```
Change-Id: CR-2025-0123
Reviewed-by: Tech Lead <techlead@enterprise.com>
Signed-off-by: Developer <dev@enterprise.com>
```

**Purpose**: SOC2 compliance, change management tracking

### Security-Related Commits

**Type**: Use `security:` not `fix:`

**Requirements**:
- Security team review required
- Private disclosure initially (no public commit until patched)
- Include CVE reference if applicable
- Document vulnerability in commit body

**Example**:
```
security(auth): patch JWT token validation vulnerability

Fixed security issue where expired tokens were accepted.

CVE-2024-12345
CVSS Score: 7.5 (High)

Fix: Added proper expiration time validation.
Impact: No evidence of exploitation in production logs.

Tested-by: Security Team <security@enterprise.com>
Reviewed-by: Security Lead <seclead@enterprise.com>
Signed-off-by: Alice Johnson <alice@enterprise.com>

Change-Id: CR-2025-SEC-001
```

### Data Privacy (GDPR)

**For PII-related changes**:
```
compliance(user): add GDPR data export functionality

Implements user data export as required by GDPR Article 20.
Users can now download all their personal data in JSON format.

Privacy-Impact: HIGH
DPO-Approved: Yes
Legal-Review: Completed 2025-12-10

Closes ECOM-2222
Reviewed-by: DPO <dpo@enterprise.com>
```

---

## Examples

### Example 1: Feature Addition with Breaking Change

```
feat(api): migrate authentication to OAuth2

Replaces custom JWT implementation with OAuth2 standard.
Improves security and enables SSO with corporate identity provider.

Impact:
- All API clients must update authentication flow
- Mobile apps require version 2.5.0+
- Web app requires redeployment

Benefits:
- Centralized user management
- Single Sign-On (SSO) support
- Improved security posture
- Reduced maintenance overhead

BREAKING CHANGE: Authentication endpoints changed.

Old endpoints (deprecated):
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh

New endpoints:
- POST /oauth2/authorize
- POST /oauth2/token
- POST /oauth2/revoke

Migration guide: https://docs.internal.example.com/oauth2-migration

Timeline:
- 2025-12-15: Deploy new endpoints (old ones still work)
- 2026-01-15: Deprecation warning added to old endpoints
- 2026-02-15: Old endpoints removed

Closes ECOM-1111
Reviewed-by: Tech Lead <techlead@enterprise.com>
Reviewed-by: VP Engineering <vp@enterprise.com>
Tested-by: QA Team <qa@enterprise.com>
Signed-off-by: Alice Johnson <alice@enterprise.com>

Change-Id: CR-2025-0456
```

### Example 2: Security Fix

```
security(payment): fix SQL injection in payment history query

Fixed critical SQL injection vulnerability in payment history endpoint.

Vulnerability: User-supplied date parameter was not sanitized.
CVE: CVE-2025-12345
CVSS Score: 9.0 (Critical)

Fix: Implemented parameterized queries using prepared statements.
Impact: No evidence of exploitation found in audit logs.

Testing:
- Penetration testing confirmed vulnerability closed
- All existing tests pass
- Added new tests for SQL injection attempts

Closes ECOM-SEC-789
Reviewed-by: Security Team <security@enterprise.com>
Tested-by: Penetration Testing Team <pentest@enterprise.com>
Signed-off-by: Bob Smith <bob@enterprise.com>

Change-Id: CR-2025-SEC-002
```

### Example 3: Performance Improvement

```
perf(db): add indexes on frequently queried columns

Added composite indexes to improve query performance on user data retrieval.

Indexes added:
- users(email, status)
- orders(user_id, created_at)
- products(category_id, published_at)

Performance impact:
- User list query: 1200ms → 45ms (96% improvement)
- Order history: 800ms → 30ms (96% improvement)
- Product search: 600ms → 25ms (96% improvement)

Database size impact: +50MB (negligible)

Tested with:
- Production data snapshot (5M users, 10M orders)
- Load testing: 1000 concurrent requests
- No query plan regressions detected

Closes ECOM-3333
Reviewed-by: Database Lead <dblead@enterprise.com>
Tested-by: Performance Team <perf@enterprise.com>
Signed-off-by: Charlie Davis <charlie@enterprise.com>

Change-Id: CR-2025-0789
```

### Example 4: Regular Feature

```
feat(cart): add wishlist functionality

Allows users to save products for later purchase.

Features:
- Add/remove products from wishlist
- Move products from wishlist to cart
- Share wishlist via link
- Email reminders for wishlist items on sale

API endpoints:
- GET /api/wishlist
- POST /api/wishlist/items
- DELETE /api/wishlist/items/:id
- POST /api/wishlist/items/:id/move-to-cart

Database changes:
- New table: wishlists
- New table: wishlist_items
- Migration: 20251211120000-create-wishlist-tables

Testing:
- Unit tests: 95% coverage
- Integration tests: All API endpoints
- E2E tests: Full wishlist workflow

Closes ECOM-4444
Reviewed-by: Product Manager <pm@enterprise.com>
Reviewed-by: Tech Lead <techlead@enterprise.com>
Tested-by: QA Team <qa@enterprise.com>
Signed-off-by: Diana Evans <diana@enterprise.com>

Change-Id: CR-2025-1012
```

---

## Quick Reference Card

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENTERPRISE E-COMMERCE COMMIT CONVENTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HEADER: <type>(<scope>): <subject>  [≤72 chars]

TYPES:
  Standard: feat, fix, docs, style, refactor, perf,
            test, build, ci, chore, revert
  Custom:   security, compliance, a11y, i18n

SCOPES:
  Domain: auth, user, product, cart, order, payment,
          shipping, notification, analytics, admin
  Layer:  api, graphql, ui, db, cache, queue, websocket
  Infra:  config, docker, k8s, ci, monitoring, security, deps

BODY: (required for breaking changes, security, perf, >10 files)
  - Wrap at 72 chars
  - Explain what, why, and impact
  - Include metrics for performance changes

FOOTER: (required for commits to main)
  Closes ECOM-1234
  Change-Id: CR-2025-0123
  Reviewed-by: Name <email>
  Signed-off-by: Your Name <you@enterprise.com>

BREAKING CHANGES:
  BREAKING CHANGE: description
  [Must include migration guide]
  [Requires VP Engineering approval]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Additional Notes

### Onboarding New Developers

New team members should:
1. Read this preferences document
2. Install commitlint: `npm install`
3. Configure git template: `git config commit.template .gitmessage`
4. Review last 20 commits for style: `git log --oneline -n 20`
5. Practice with feature branch before committing to main

### Tools Setup

```bash
# Install dependencies
npm install

# Install git hooks
npm run prepare

# Test commitlint
echo "feat(test): test message" | npx commitlint

# Generate changelog
npm run release:changelog
```

### Support and Questions

- **Slack**: #eng-git-conventions
- **Wiki**: https://wiki.internal.example.com/git-conventions
- **Contact**: Tech Lead team for clarifications

---

**Last Updated**: 2025-12-11
**Maintained By**: Engineering Standards Committee
**Review Cycle**: Quarterly
