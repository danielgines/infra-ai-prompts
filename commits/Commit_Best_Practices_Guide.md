# Commit Best Practices Guide

> **Purpose**: Comprehensive guide for writing effective, clear, and maintainable commit messages following industry best practices.

**Official Reference**: [Conventional Commits Specification](https://www.conventionalcommits.org/)

---

## Table of Contents

1. [Introduction to Commit Messages](#introduction-to-commit-messages)
2. [The Anatomy of a Good Commit](#the-anatomy-of-a-good-commit)
3. [Conventional Commits Format](#conventional-commits-format)
4. [Writing Effective Commit Messages](#writing-effective-commit-messages)
5. [When to Commit](#when-to-commit)
6. [Commit Message Anti-Patterns](#commit-message-anti-patterns)
7. [Team Collaboration Guidelines](#team-collaboration-guidelines)
8. [Commit History Hygiene](#commit-history-hygiene)
9. [Automated Tooling](#automated-tooling)
10. [Real-World Examples](#real-world-examples)

---

## Introduction to Commit Messages

### Why Commit Messages Matter

Commit messages serve multiple critical purposes:

1. **Communication**: Explain changes to future developers (including yourself)
2. **Documentation**: Provide searchable history of project evolution
3. **Automation**: Enable changelog generation, semantic versioning, CI/CD triggers
4. **Review**: Help reviewers understand intent without reading all code
5. **Debugging**: Aid in identifying when and why bugs were introduced (`git bisect`)
6. **Onboarding**: Help new team members understand project history

### The Cost of Poor Commit Messages

Bad commit messages lead to:

- **Lost context**: "What was I thinking?" moments months later
- **Review friction**: PRs take longer when commits are unclear
- **Broken automation**: Changelog tools and semantic versioning fail
- **Difficult debugging**: `git blame` and `git bisect` become useless
- **Team frustration**: Developers waste time deciphering cryptic messages

**Example of the problem**:
```bash
$ git log --oneline
abc1234 fix stuff
def5678 update
ghi9012 wip
jkl3456 asdfasdf
mno7890 final fix
pqr4567 final fix for real
stu8901 ok now it works
```

This history is useless for understanding what changed or why.

---

## The Anatomy of a Good Commit

### The Three Components

A well-structured commit message has three parts:

```
<header>
[blank line]
[body]
[blank line]
[footer]
```

### 1. Header (Required)

**Format**: `<type>(<scope>): <subject>`

- **Type**: Category of change (feat, fix, docs, etc.)
- **Scope**: Module/area affected (optional but recommended)
- **Subject**: Brief description in imperative mood

**Rules**:
- Maximum 50 characters (hard limit: 72)
- Lowercase type and scope
- No period at end
- Imperative mood ("add" not "added")

**Examples**:
```
feat(auth): add JWT authentication
fix(api): handle null pointer in user lookup
docs(readme): update installation instructions
```

### 2. Body (Optional but Recommended)

**When to include**:
- Change is not obvious from header
- Multiple files affected
- Complex logic changes
- Breaking changes need explanation

**Guidelines**:
- Wrap at 72 characters
- Explain **what** and **why**, not **how**
- Use bullet points for multiple items
- Separate from header with blank line

**Example**:
```
feat(cache): implement Redis-backed session storage

Replaces in-memory sessions to support horizontal scaling.
Sessions now persist across server restarts.
Adds automatic cleanup of expired sessions.

Performance impact:
- Session lookup: 5ms → 1ms average
- Memory usage: reduced by 60%
```

### 3. Footer (Optional)

**When to include**:
- Breaking changes (BREAKING CHANGE:)
- Issue/ticket references (Closes #123)
- Co-authors (Co-authored-by:)
- Sign-offs (Signed-off-by:)

**Examples**:
```
BREAKING CHANGE: API endpoints moved to /v2/ namespace.

Closes #1234, Closes #5678

Co-authored-by: Jane Doe <jane@example.com>
```

---

## Conventional Commits Format

### Standard Commit Types

| Type | Purpose | Changelog | Semver |
|------|---------|-----------|--------|
| `feat` | New feature | Yes | Minor |
| `fix` | Bug fix | Yes | Patch |
| `docs` | Documentation only | No | None |
| `style` | Formatting (no logic) | No | None |
| `refactor` | Code restructuring | No | None |
| `perf` | Performance improvement | Yes | Patch |
| `test` | Add/modify tests | No | None |
| `build` | Build system/dependencies | No | None |
| `ci` | CI/CD changes | No | None |
| `chore` | Maintenance tasks | No | None |
| `revert` | Revert previous commit | Yes | Depends |

### Type Selection Decision Tree

```
Did you add new functionality?
├─ Yes → feat
└─ No
   └─ Did you fix a bug?
      ├─ Yes → fix
      └─ No
         └─ Did you change code structure without adding features or fixing bugs?
            ├─ Yes → refactor
            └─ No
               └─ Did you improve performance?
                  ├─ Yes → perf
                  └─ No
                     └─ Did you only change documentation?
                        ├─ Yes → docs
                        └─ No
                           └─ Did you only change formatting/whitespace?
                              ├─ Yes → style
                              └─ No → chore (or more specific type)
```

### Scope Guidelines

**Dynamic scopes based on project architecture**:

- **Domain/Feature**: `auth`, `user`, `payment`, `product`, `order`
- **Layer**: `api`, `ui`, `db`, `cli`, `sdk`
- **Infrastructure**: `config`, `docker`, `k8s`, `deploy`, `monitoring`
- **Tooling**: `build`, `test`, `ci`, `deps`

**Scope best practices**:
- Use consistent naming (pick "auth" OR "authentication", not both)
- Avoid overly broad scopes ("backend", "frontend")
- Omit scope when change affects entire project
- Document standard scopes in CONTRIBUTING.md

**Examples**:
```
Good scopes:
feat(auth): add OAuth provider
fix(payment): resolve transaction timeout
docs(api): update endpoint specifications

Poor scopes:
feat(backend): add stuff
fix(code): fix issue
docs(everything): update docs
```

---

## Writing Effective Commit Messages

### The Imperative Mood

**Rule**: Write as if completing the sentence "This commit will..."

**✅ Correct (imperative)**:
```
feat(api): add user registration endpoint
fix(ui): correct button alignment
docs(readme): update installation guide
```

**❌ Incorrect (past tense/gerund)**:
```
feat(api): added user registration endpoint
fix(ui): fixing button alignment
docs(readme): updated installation guide
```

### Be Specific, Not Vague

**❌ Vague**:
```
fix(api): fix bug
feat(ui): improve UI
refactor(db): update code
```

**✅ Specific**:
```
fix(api): handle null pointer in user validation
feat(ui): add loading states to async operations
refactor(db): extract query builder to separate class
```

### Focus on "Why" and "What", Not "How"

The diff shows "how". Your message should explain "what" and "why".

**❌ Describes implementation**:
```
feat(cache): use Redis.setex with 3600 TTL

Added import for Redis client.
Created connection pool with max 10 connections.
Wrapped cache operations in try-catch blocks.
```

**✅ Describes purpose**:
```
feat(cache): add session caching with 1-hour TTL

Caches user sessions in Redis to reduce database load.
Sessions expire automatically after 1 hour of inactivity.
Improves session lookup from 50ms to 5ms average.
```

### One Logical Change Per Commit

**Principle**: Each commit should be a single logical change.

**❌ Multiple unrelated changes**:
```
feat(user): add profile page, fix login bug, update README
```

**✅ Separate commits**:
```
feat(user): add profile page component
fix(auth): resolve login validation error
docs(readme): add user profile documentation
```

### Atomic Commits

**Definition**: A commit is atomic if it:
1. Represents a single, complete change
2. Leaves the codebase in a working state
3. Can be reverted without side effects

**✅ Atomic**:
```
Commit 1: feat(payment): add Stripe integration
- Working code, tests pass
- Can be reverted cleanly

Commit 2: feat(payment): add PayPal integration
- Working code, tests pass
- Can be reverted without affecting Stripe
```

**❌ Non-atomic**:
```
Commit 1: feat(payment): add Stripe integration (part 1)
- Code incomplete, tests fail
- Missing configuration

Commit 2: feat(payment): add Stripe integration (part 2)
- Completes previous commit
- Can't revert commit 1 without breaking commit 2
```

---

## When to Commit

### Commit Frequency Guidelines

**Commit early, commit often** — but make commits meaningful.

**Good times to commit**:
- ✅ After completing a logical unit of work
- ✅ After fixing a single bug
- ✅ After adding a single feature (even if small)
- ✅ After refactoring a single module/function
- ✅ Before taking a break (with clear WIP message if needed)
- ✅ After tests pass for the change

**Bad times to commit**:
- ❌ In the middle of implementing a feature
- ❌ With failing tests (except for WIP commits on feature branches)
- ❌ With commented-out code or debug statements
- ❌ With unrelated changes bundled together

### WIP (Work in Progress) Commits

**When to use WIP commits**:
- Switching context before work is complete
- Saving progress on long-running feature branches
- Backing up work before risky refactoring

**WIP commit format**:
```
WIP: [feat(auth)] implement OAuth flow

Implemented provider registration and token exchange.
TODO: Add token refresh logic
TODO: Add error handling
```

**Important**: Rebase/squash WIP commits before merging to main:
```bash
# Interactive rebase to clean up WIP commits
git rebase -i origin/main

# In editor, squash WIP commits into feature commit
pick abc1234 feat(auth): implement OAuth flow
squash def5678 WIP: [feat(auth)] add token refresh
squash ghi9012 WIP: [feat(auth)] add error handling
```

---

## Commit Message Anti-Patterns

### 1. The Useless Message

**❌ Examples**:
```
fix stuff
update
asdfasdf
final fix
ok now it works
```

**Why it's bad**: Provides zero information about what changed.

**✅ Fix**:
```
fix(auth): resolve session timeout issue
refactor(ui): simplify component structure
fix(api): handle edge case in user validation
```

### 2. The Novel

**❌ Example**:
```
feat(api): add user registration endpoint and also I updated the database schema to support email verification and changed the password hashing algorithm from bcrypt to argon2 because it's more secure and I also added rate limiting to prevent brute force attacks and updated the tests to cover the new functionality and fixed a bug in the login endpoint that was causing issues with special characters in passwords
```

**Why it's bad**: Header exceeds 50 characters, mixes multiple changes.

**✅ Fix**: Split into multiple commits
```
feat(auth): add user registration endpoint
feat(auth): add email verification system
refactor(auth): migrate to Argon2 password hashing
feat(auth): add rate limiting to login endpoints
fix(auth): handle special characters in passwords
```

### 3. The Past Tense

**❌ Examples**:
```
feat(api): added new endpoint
fixed bug in authentication
updated documentation
```

**Why it's bad**: Violates imperative mood convention.

**✅ Fix**:
```
feat(api): add new endpoint
fix(auth): resolve authentication bug
docs: update installation guide
```

### 4. The Vague Scope

**❌ Examples**:
```
feat(backend): add feature
fix(code): fix issue
docs(files): update docs
```

**Why it's bad**: Scope is too broad to be useful.

**✅ Fix**:
```
feat(api): add user profile endpoint
fix(auth): resolve token expiration issue
docs(api): update authentication guide
```

### 5. The Missing Context

**❌ Example**:
```
refactor(db): optimize queries

(No body, 200 lines changed across 8 files)
```

**Why it's bad**: Complex changes need explanation.

**✅ Fix**:
```
refactor(db): optimize queries for user data retrieval

Replaced N+1 queries with single JOIN query.
Added database indexes on user.email and user.created_at.
Reduced average query time from 500ms to 50ms.

Performance impact:
- User list endpoint: 10x faster
- Search functionality: 8x faster
```

### 6. The Bundle

**❌ Example**:
```
feat(user): add profile page, fix logout bug, update README

Files changed:
- src/components/Profile.tsx (new feature)
- src/auth/Logout.tsx (bug fix)
- README.md (documentation)
```

**Why it's bad**: Mixes feature, fix, and docs. Can't revert selectively.

**✅ Fix**: Three separate commits
```
feat(user): add profile page component
fix(auth): resolve logout session clearing bug
docs(readme): add user profile documentation
```

---

## Team Collaboration Guidelines

### Commit Message Template

Create `.gitmessage` in project root:

```
# <type>(<scope>): <subject>
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Closes #23

# --- COMMIT END ---
# Type can be
#    feat     (new feature)
#    fix      (bug fix)
#    refactor (refactoring code)
#    style    (formatting, missing semi colons, etc; no code change)
#    docs     (changes to documentation)
#    test     (adding or refactoring tests; no production code change)
#    chore    (updating build tasks, package manager configs, etc; no production code change)
# --------------------
# Remember to:
#   - Use the imperative mood in the subject line
#   - Do not end the subject line with a period
#   - Capitalize the subject line and each paragraph
#   - Separate subject from body with a blank line
#   - Use the body to explain what and why vs. how
#   - Wrap the body at 72 characters
```

Configure for repository:
```bash
git config commit.template .gitmessage
```

### Code Review and Commits

**Before requesting review**:
1. Review your own commits: `git log origin/main..HEAD`
2. Ensure each commit has clear message
3. Squash WIP/fixup commits
4. Ensure commits are logically organized

**Addressing review feedback**:

**Option 1: Fixup commits during review**
```bash
# Make changes based on feedback
git add .
git commit -m "fixup! feat(auth): add OAuth flow"

# After approval, squash before merge
git rebase -i --autosquash origin/main
```

**Option 2: Amend last commit (if feedback is for latest commit)**
```bash
git add .
git commit --amend --no-edit
git push --force-with-lease
```

**Option 3: New commits (for clear audit trail)**
```bash
git commit -m "refactor(auth): address code review feedback"
```

### Commit Conventions Document

Create `COMMIT_CONVENTIONS.md` in repository:

```markdown
# Commit Conventions

## Standard Scopes

- `auth` - Authentication and authorization
- `api` - REST API endpoints
- `ui` - User interface components
- `db` - Database schema and queries
- `config` - Configuration files
- `deps` - Dependencies
- `ci` - CI/CD pipelines

## Breaking Changes

Always document breaking changes with BREAKING CHANGE: footer.

## Commit Frequency

- Commit after each logical unit of work
- All tests must pass before committing to main
- WIP commits allowed on feature branches

## Tools

- commitlint: Enforces conventional commits format
- husky: Pre-commit hooks
- conventional-changelog: Generates changelog from commits
```

---

## Commit History Hygiene

### Interactive Rebase for Clean History

**Before merging feature branch to main**:

```bash
# Rebase on latest main
git fetch origin
git rebase origin/main

# Interactive rebase to clean up commits
git rebase -i origin/main
```

**In interactive rebase, you can**:
- `pick` - Keep commit as-is
- `reword` - Change commit message
- `squash` - Combine with previous commit
- `fixup` - Combine with previous, discard message
- `drop` - Remove commit
- `edit` - Stop and edit commit

**Example workflow**:
```
Initial history:
- feat(auth): add OAuth flow
- WIP: fix tests
- WIP: add error handling
- fix typo
- feat(auth): add token refresh

After interactive rebase:
- feat(auth): add OAuth authentication with token refresh
  (squashed all related commits)
```

### Squash vs Rebase vs Merge

**Squash merge** (GitHub/GitLab):
```bash
git merge --squash feature-branch
git commit -m "feat(auth): add OAuth authentication"
```
- **Pros**: Clean linear history, single commit per feature
- **Cons**: Loses granular commit history

**Rebase and merge**:
```bash
git rebase origin/main
git checkout main
git merge --ff-only feature-branch
```
- **Pros**: Preserves individual commits, linear history
- **Cons**: Requires clean commits on feature branch

**Merge commit**:
```bash
git merge --no-ff feature-branch
```
- **Pros**: Preserves full history, shows branch relationships
- **Cons**: Cluttered history with merge commits

**Recommendation**: Use squash for small features, rebase for larger features with logical commit sequence.

---

## Automated Tooling

### 1. commitlint

**Purpose**: Enforce commit message format

**Installation**:
```bash
npm install --save-dev @commitlint/{cli,config-conventional}

echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
```

**Configuration** (`.commitlintrc.json`):
```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [2, "always", [
      "feat", "fix", "docs", "style", "refactor",
      "perf", "test", "build", "ci", "chore", "revert"
    ]],
    "scope-enum": [2, "always", [
      "auth", "api", "ui", "db", "config", "deps", "ci"
    ]],
    "subject-case": [2, "always", "sentence-case"],
    "header-max-length": [2, "always", 72]
  }
}
```

### 2. husky

**Purpose**: Git hooks for automation

**Installation**:
```bash
npm install --save-dev husky
npx husky init

echo "npx commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/commit-msg
```

### 3. conventional-changelog

**Purpose**: Generate changelog from commits

**Installation**:
```bash
npm install --save-dev conventional-changelog-cli

# Generate changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

**Example output**:
```markdown
## [2.1.0](2025-12-11)

### Features
- **auth**: add OAuth authentication ([abc1234](link))
- **api**: add rate limiting ([def5678](link))

### Bug Fixes
- **ui**: resolve button alignment issue ([ghi9012](link))
```

### 4. semantic-release

**Purpose**: Automate versioning based on commits

**Installation**:
```bash
npm install --save-dev semantic-release
```

**How it works**:
- `feat:` commits → Minor version bump (1.0.0 → 1.1.0)
- `fix:` commits → Patch version bump (1.0.0 → 1.0.1)
- `BREAKING CHANGE:` → Major version bump (1.0.0 → 2.0.0)

---

## Real-World Examples

### Example 1: Adding New Feature

**Scenario**: Add user profile editing functionality

**Good commit sequence**:
```
feat(user): add profile editing form component

Creates reusable ProfileForm component with validation.
Supports updating name, email, and avatar.

---

feat(api): add profile update endpoint

POST /api/users/:id/profile endpoint.
Validates input and updates database.
Returns updated user object.

Closes #1234

---

test(user): add profile update tests

Unit tests for ProfileForm component.
Integration tests for profile API endpoint.
Covers validation edge cases.
```

### Example 2: Fixing Critical Bug

**Scenario**: Login fails for users with special characters in email

**Good commit**:
```
fix(auth): handle special characters in email addresses

Email validation regex now properly escapes special chars.
Adds URL encoding before API requests.

Root cause: Email addresses with '+' were causing 400 errors.
Now supports all RFC 5322 compliant email addresses.

Fixes #5678
```

### Example 3: Refactoring

**Scenario**: Extract duplicate code into shared utility

**Good commit**:
```
refactor(utils): extract date formatting logic to shared utility

Creates formatDate() utility function used by:
- UserProfile component
- OrderList component
- Analytics dashboard

Reduces code duplication from 3 implementations to 1.
Makes date format changes easier (single source of truth).

No functional changes.
```

### Example 4: Breaking Change

**Scenario**: Change API authentication from cookies to JWT

**Good commit**:
```
feat(auth): migrate to JWT-based authentication

Replaces cookie-based sessions with JWT tokens.
Tokens expire after 1 hour, refresh tokens valid for 30 days.

BREAKING CHANGE: API authentication method changed.

Migration guide:
1. Update API clients to send Authorization: Bearer <token> header
2. Replace cookie handling with JWT token management
3. Implement token refresh flow for long-lived sessions

See docs/authentication.md for detailed migration steps.

Closes #9876
```

---

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Git Commit Best Practices (Chris Beams)](https://chris.beams.io/posts/git-commit/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit)

---

**Last Updated**: 2025-12-11
