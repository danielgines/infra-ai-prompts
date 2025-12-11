# Commit Message Examples

> **Purpose**: Practical examples demonstrating good vs bad commit messages and real-world scenarios.

---

## Available Examples

### 1. before_after_commit_messages.md

**Purpose**: Side-by-side comparison of poor commit messages and their improved versions.

**Covers**:
- Common mistakes and how to fix them
- Vague vs specific messages
- Missing vs comprehensive context
- Format violations vs correct format
- Multiple changes vs atomic commits
- Missing vs proper breaking change documentation

**Usage**: Use this as a learning tool or reference when writing commit messages.

---

## Learning Path

### For Beginners

1. **Start with format basics**:
   - Read `before_after_commit_messages.md` examples 1-5
   - Focus on header format (type, scope, subject)
   - Practice writing headers in imperative mood

2. **Move to body and footer**:
   - Study examples 6-10 in `before_after_commit_messages.md`
   - Learn when body is needed
   - Understand footer conventions

3. **Practice with real commits**:
   - Review your own commit history: `git log --oneline -n 20`
   - Identify improvements using examples as reference
   - Rewrite one commit message as practice

### For Intermediate Users

1. **Master atomic commits**:
   - Study examples 11-15
   - Learn to split complex changes
   - Practice logical commit organization

2. **Breaking changes and migrations**:
   - Study examples 16-20
   - Understand breaking change documentation
   - Learn migration guide best practices

3. **Advanced scenarios**:
   - Monorepo commits
   - Security fixes
   - Performance optimizations with metrics

### For Code Reviewers

Use these examples to:
- Identify commit message quality issues
- Provide specific feedback with references
- Set team standards and expectations
- Train new team members

---

## Real-World Scenarios

### Scenario 1: Bug Fix After User Report

**Context**: User reports login fails with email containing `+` character.

**❌ Poor commit**:
```
fix bug
```

**✅ Good commit**:
```
fix(auth): handle special characters in email addresses

Email validation now properly handles all RFC 5322 compliant characters.
Adds URL encoding before API requests.

Root cause: Email addresses with '+' were being rejected by backend validation.
Impact: Users with gmail aliases (e.g., user+label@gmail.com) can now log in.

Closes #1234
```

**Reference**: See `before_after_commit_messages.md` Example 7

---

### Scenario 2: Adding New Feature

**Context**: Implementing user profile editing functionality.

**❌ Poor commit sequence**:
```
feat: add stuff
fix: fix bug
update: more changes
final commit
```

**✅ Good commit sequence**:
```
Commit 1:
feat(user): add profile editing form component

Creates reusable ProfileForm component with validation.
Supports updating name, email, and avatar.

Closes #5678

---

Commit 2:
feat(api): add profile update endpoint

POST /api/users/:id/profile endpoint.
Validates input and updates database.
Returns updated user object.

---

Commit 3:
test(user): add profile update tests

Unit tests for ProfileForm component.
Integration tests for profile API endpoint.
Covers validation edge cases and error handling.
```

**Reference**: See `before_after_commit_messages.md` Examples 11-13

---

### Scenario 3: Breaking Change

**Context**: Migrating API from v1 to v2 with URL structure changes.

**❌ Missing documentation**:
```
refactor(api): update endpoints
```

**✅ Comprehensive documentation**:
```
feat(api): migrate to REST API v2

Reorganizes API structure for better resource modeling.
Adds versioning to support gradual client migration.

BREAKING CHANGE: API endpoints moved to /v2/ namespace.

Migration guide: https://docs.example.com/migration-v2

Changes:
- /users → /v2/users
- /products → /v2/products
- /orders → /v2/orders

Timeline:
- 2025-12-15: v2 endpoints available (v1 still works)
- 2026-01-15: v1 deprecated (warnings added)
- 2026-02-15: v1 removed

Client updates required:
1. Update base URL to include /v2/
2. Update response parsing (new field names)
3. Test with sandbox environment before production

Closes #9999
```

**Reference**: See `before_after_commit_messages.md` Example 16

---

### Scenario 4: Security Fix

**Context**: SQL injection vulnerability discovered in search endpoint.

**❌ Insecure disclosure**:
```
fix(api): fix security issue in search

There was an SQL injection in /search endpoint.
Now using prepared statements.
```

**✅ Proper security disclosure**:
```
security(api): fix SQL injection in search endpoint

Fixed critical SQL injection vulnerability in product search.

Vulnerability: User search query was concatenated into SQL.
Impact: Could allow unauthorized database access.
Fix: Implemented parameterized queries using prepared statements.

No evidence of exploitation found in audit logs (past 90 days).

CVE: Pending
Severity: High (CVSS 8.5)

Testing:
- Penetration testing confirmed vulnerability closed
- All existing tests pass
- Added tests for SQL injection attempts

Closes SEC-456
Reviewed-by: Security Team <security@example.com>
```

**Reference**: See `before_after_commit_messages.md` Example 18

---

## Common Patterns

### Pattern 1: Feature + Tests + Docs

When adding a new feature, make 3 separate commits:

```
1. feat(scope): add feature implementation
2. test(scope): add tests for new feature
3. docs(scope): add documentation for feature
```

**Why separate?**
- Easier to revert if needed
- Clear history of what was added when
- Easier code review (reviewers can focus on each aspect)

### Pattern 2: Bug Fix + Regression Test

When fixing a bug, always add a test:

```
1. test(scope): add test reproducing bug #123
2. fix(scope): resolve issue causing bug #123
```

**Why this order?**
- Proves the test fails before the fix
- Ensures the fix actually works
- Prevents future regressions

### Pattern 3: Refactoring Series

When refactoring, break into logical steps:

```
1. refactor(scope): extract function X to separate file
2. refactor(scope): rename variables for clarity
3. refactor(scope): simplify logic in module Y
4. test(scope): update tests for refactored code
```

**Why multiple commits?**
- Each commit is reviewable and understandable
- Can bisect to find if refactoring introduced bugs
- Easier to revert specific changes if needed

---

## Troubleshooting

### Problem: "My commits are always too large"

**Solution**: Commit more frequently

**Practice**:
- Commit after completing each logical unit
- Use `git add -p` to stage partial files
- Remember: You can always squash commits later

### Problem: "I don't know what to write in the body"

**Solution**: Ask yourself these questions:

1. **What** changed? (If not obvious from header)
2. **Why** was this change needed?
3. **How** does this solve the problem? (briefly)
4. **What** is the impact on users/system?
5. **Are there** any risks or caveats?

### Problem: "My headers are always too long"

**Solution**: Move details to body

**Examples**:
```
❌ feat(api): implement comprehensive JWT-based authentication system with refresh tokens and expiration handling
(94 characters)

✅ feat(auth): add JWT authentication with refresh tokens
(53 characters)

[Details in body]
```

### Problem: "I committed with wrong message"

**Solutions**:

**Last commit (not pushed)**:
```bash
git commit --amend
```

**Older commit (not pushed)**:
```bash
git rebase -i HEAD~3  # For last 3 commits
# Mark commit for 'reword'
```

**Already pushed (dangerous)**:
```bash
# Only if you're the only one on the branch
git commit --amend
git push --force-with-lease
```

---

## Additional Resources

- [Conventional Commits Reference](../Conventional_Commits_Reference.md)
- [Commit Best Practices Guide](../Commit_Best_Practices_Guide.md)
- [First Commit Instructions](../First_Commit_Instructions.md)
- [Progress Commit Instructions](../Progress_Commit_Instructions.md)
- [Commit Review Instructions](../Commit_Review_Instructions.md)
- [Commit Message Checklist](../Commit_Message_Checklist.md)

---

## Contributing Examples

If you have good examples of commit messages to add:

1. Follow the before/after format
2. Include context explaining the scenario
3. Explain why the "after" version is better
4. Add to appropriate section in `before_after_commit_messages.md`

---

**Last Updated**: 2025-12-11
