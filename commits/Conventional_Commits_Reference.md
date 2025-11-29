# Conventional Commits Reference

> **Purpose**: Shared reference for commit message standards. Use this as foundation for all commit-related prompts.

---

## Format Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Rules

- **Header** ≤ 50 characters
- Use **imperative mood** ("add" not "added" or "adds")
- No period at end of header
- **Body** wraps at 72 characters
- Separate header from body with blank line
- Footer for breaking changes and issue references

---

## Commit Types

| Type | Purpose | Examples |
|------|---------|----------|
| `feat` | New feature | `feat(auth): add JWT authentication` |
| `fix` | Bug fix | `fix(api): handle null pointer in user lookup` |
| `docs` | Documentation only | `docs: update API authentication guide` |
| `style` | Formatting (no logic change) | `style: format code with prettier` |
| `refactor` | Code restructuring | `refactor(db): simplify query builder logic` |
| `perf` | Performance improvement | `perf(parser): optimize regex compilation` |
| `test` | Add/modify tests | `test(auth): add JWT expiration tests` |
| `build` | Build system/dependencies | `build(deps): upgrade express to 4.18.0` |
| `ci` | CI/CD changes | `ci: add automated security scanning` |
| `chore` | Maintenance tasks | `chore: update gitignore patterns` |
| `revert` | Revert previous commit | `revert: revert "feat(api): add rate limiting"` |

---

## Common Scopes

**Infrastructure/DevOps:**
- `core`, `config`, `setup`, `deps`, `db`, `api`, `cli`, `ci`, `docker`, `k8s`

**Application:**
- `auth`, `user`, `payment`, `ui`, `router`, `middleware`, `validation`

**Tooling:**
- `scripts`, `build`, `deploy`, `monitoring`, `logging`

---

## Body Guidelines

**Focus on WHY and WHAT (not HOW)**

✅ Good:
```
feat(cache): implement Redis-backed session storage

Replaces in-memory sessions to support horizontal scaling.
Adds automatic cleanup of expired sessions.
```

❌ Bad:
```
feat(cache): add Redis

Changed code to use Redis instead of memory.
```

---

## Footer Conventions

### Breaking Changes
```
BREAKING CHANGE: API endpoints now require authentication header.
Migration guide: https://docs.example.com/v2-migration
```

### Issue References
```
Closes #123
Fixes #456, #789
Refs #101
```

---

## Multi-Commit Guidelines

**Create SINGLE commit when:**
- Changes are tightly coupled (feature + tests + docs)
- Refactoring affects multiple files uniformly
- Dependency update + necessary code adjustments

**Create MULTIPLE commits when:**
- Independent features added
- Unrelated bug fixes
- Different scopes (e.g., `api` + `docs` + `ci`)
- Mix of refactor + new feature + extensive docs

---

## Language Consistency

- Use **project's primary language** for commit messages
- English: technical projects, open source, multinational teams
- Portuguese: local teams, internal tools, explicit preference
- **Be consistent** within the repository

---

## Examples by Context

### Feature with Tests
```
feat(payment): implement Stripe integration

Adds payment processing using Stripe API v2.
Includes webhook handler for payment confirmations.
Supports one-time and subscription payments.

Tests cover success, failure, and timeout scenarios.
```

### Bug Fix with Impact
```
fix(auth): prevent token reuse after logout

Adds token to blacklist on logout to prevent replay attacks.
Tokens expire from blacklist after their natural TTL.

Closes #234
```

### Refactoring
```
refactor(database): extract query builder to separate module

Improves testability and reduces coupling.
No functional changes to query behavior.
```

### Breaking Change
```
feat(api): migrate to GraphQL

Replaces REST endpoints with GraphQL API.
Provides better flexibility for frontend queries.

BREAKING CHANGE: REST API v1 endpoints removed.
Migration guide: docs/graphql-migration.md

Closes #567
```

---

## Anti-Patterns to Avoid

❌ Vague descriptions:
- `fix: bug fix`
- `update: changes`
- `chore: stuff`

❌ Implementation details in header:
- `feat: add UserController class with methods`

❌ Multiple unrelated changes:
- `feat: add auth + fix ui bug + update deps`

❌ Missing context:
- `fix: resolve issue` (which issue? where?)

---

## Validation Checklist

- [ ] Type accurately reflects change nature
- [ ] Scope is appropriate (if used)
- [ ] Header is imperative, concise, no period
- [ ] Body explains WHY when non-obvious
- [ ] Breaking changes documented in footer
- [ ] Issue references included when applicable
- [ ] Language consistent with repository
- [ ] No multiple unrelated changes bundled

---

**Reference**: https://www.conventionalcommits.org/
