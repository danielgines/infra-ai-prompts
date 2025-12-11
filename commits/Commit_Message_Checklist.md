# Commit Message Checklist

> **Purpose**: Quick reference checklist for writing standards-compliant, clear, and effective commit messages.

---

## Before Committing

- [ ] **Stage only related changes** - `git add` only files for this logical change
- [ ] **Review staged changes** - `git diff --staged` to verify what will be committed
- [ ] **Run tests** - Ensure tests pass for the changes
- [ ] **Remove debug code** - No console.log, print statements, or commented code
- [ ] **Check for secrets** - No API keys, passwords, or credentials in diff

---

## Commit Message Structure

### Header Line

- [ ] **Starts with type** - `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- [ ] **Includes scope** (if applicable) - `feat(auth):` not `feat:`
- [ ] **Uses imperative mood** - "add" not "added" or "adds"
- [ ] **Is specific** - "add user authentication" not "add feature"
- [ ] **No period at end** - `feat(api): add endpoint` not `feat(api): add endpoint.`
- [ ] **≤50 characters** (recommended) or ≤72 characters (maximum)
- [ ] **Lowercase type and scope** - `feat(auth):` not `Feat(Auth):`

---

## Type Selection

### New Functionality
- [ ] **feat** - Adding new feature/capability that didn't exist before

### Bug Fixes
- [ ] **fix** - Correcting incorrect behavior or errors

### Documentation
- [ ] **docs** - Only changes to documentation (README, API docs, comments)

### Code Quality
- [ ] **style** - Formatting only (whitespace, semicolons, no logic change)
- [ ] **refactor** - Code restructuring without adding features or fixing bugs

### Performance
- [ ] **perf** - Performance improvements (optimization, caching, etc.)

### Testing
- [ ] **test** - Adding, modifying, or fixing tests (no production code change)

### Build System
- [ ] **build** - Build system, dependencies, package updates

### CI/CD
- [ ] **ci** - CI/CD pipeline changes (GitHub Actions, Jenkins, etc.)

### Maintenance
- [ ] **chore** - Maintenance tasks (config, tooling, no production code change)

### Reverting
- [ ] **revert** - Reverting a previous commit

---

## Scope Guidelines

- [ ] **Scope is specific** - `auth` not `backend`, `ui` not `frontend`
- [ ] **Scope is consistent** - Use same name as previous commits (check `git log`)
- [ ] **Scope matches files** - Changes in `src/auth/*` use `(auth)` scope
- [ ] **Omit scope if affects entire project** - `docs:` not `docs(all):`
- [ ] **Use project-defined scopes** - Check CONTRIBUTING.md for standard scopes

**Common scopes by project type**:
- **Features**: `auth`, `user`, `payment`, `product`, `order`, `search`
- **Layers**: `api`, `ui`, `db`, `cli`, `sdk`
- **Infrastructure**: `config`, `docker`, `k8s`, `monitoring`, `deploy`
- **Tooling**: `build`, `test`, `ci`, `deps`, `lint`

---

## Subject Line Quality

### Clarity
- [ ] **Describes what changed** - Not "update code" but "add email validation"
- [ ] **Explains user-facing change** - "fix login timeout" not "fix bug"
- [ ] **Avoids generic verbs** - Not "update", "fix", "change" alone

### Specificity
- [ ] **Names affected component** - "fix UserProfile crash" not "fix crash"
- [ ] **Identifies error type** - "handle null pointer" not "fix error"
- [ ] **States the improvement** - "optimize query performance" not "improve db"

### Examples

**❌ Too vague**:
```
fix bug
update code
improve performance
```

**✅ Specific and clear**:
```
fix(auth): handle null pointer in token validation
refactor(api): extract duplicate validation logic
perf(db): add index on user.email for faster lookups
```

---

## Body (When to Include)

### Required for:
- [ ] **Breaking changes** - Must explain what broke and how to migrate
- [ ] **Complex changes** - Multiple files or non-obvious logic
- [ ] **Performance improvements** - Include metrics (before/after)
- [ ] **Security fixes** - Explain vulnerability and mitigation
- [ ] **Refactoring** - Explain why restructuring was needed

### Optional but recommended for:
- [ ] **New features** - Explain what problem it solves
- [ ] **Bug fixes** - Describe root cause and solution
- [ ] **Configuration changes** - Document new settings

### Body Guidelines

- [ ] **Blank line after header** - Required separator
- [ ] **Wrapped at 72 characters** - For readability in various tools
- [ ] **Explains "why" not "how"** - The diff shows "how"
- [ ] **Uses bullet points** - For multiple items or changes
- [ ] **Includes metrics** - For performance/optimization changes
- [ ] **Provides context** - Why this change was necessary

**Example**:
```
feat(cache): implement Redis-backed session storage

Replaces in-memory sessions to support horizontal scaling.
Sessions now persist across server restarts.
Adds automatic cleanup of expired sessions.

Performance impact:
- Session lookup: 50ms → 5ms average
- Memory usage: reduced by 60%
- Supports 10x more concurrent users
```

---

## Footer (When to Include)

### Breaking Changes (Required)
- [ ] **Starts with "BREAKING CHANGE:"** - Exact text, all caps
- [ ] **Explains what broke** - What no longer works
- [ ] **Provides migration path** - How to update code
- [ ] **Links to migration guide** - If detailed steps needed

**Example**:
```
BREAKING CHANGE: Authentication endpoints moved to /v2/ namespace.

Update API calls from /auth/* to /v2/auth/*.
See docs/migration-v2.md for detailed migration guide.
```

### Issue References
- [ ] **Uses "Closes #123" format** - For auto-closing issues
- [ ] **Multiple issues separated** - `Closes #123, Closes #456`
- [ ] **Uses correct keyword** - Closes, Fixes, Resolves

**Keywords that close issues**:
- `Closes #123` (preferred)
- `Fixes #123`
- `Resolves #123`

**Keywords for reference only**:
- `Refs #123`
- `See #123`
- `Related to #123`

### Co-Authors
- [ ] **Uses "Co-authored-by:" format** - With name and email
- [ ] **Includes all co-authors** - Everyone who contributed

**Example**:
```
Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>
```

---

## One Commit = One Logical Change

- [ ] **Single purpose** - Commit does one thing
- [ ] **Related changes only** - All changes serve same goal
- [ ] **No unrelated fixes** - Don't mix feature + bug fix
- [ ] **Can be reverted cleanly** - Removing commit doesn't break related features

**❌ Multiple changes (should be 3 commits)**:
```
feat(user): add profile page, fix logout bug, update README

Files:
- src/components/Profile.tsx (new feature)
- src/auth/Logout.tsx (bug fix)
- README.md (documentation)
```

**✅ Separate commits**:
```
Commit 1: feat(user): add profile page component
Commit 2: fix(auth): resolve logout session clearing bug
Commit 3: docs(readme): add user profile documentation
```

---

## Commit Atomicity

- [ ] **Codebase works after commit** - Tests pass, no broken functionality
- [ ] **Changes are complete** - Not a partial implementation
- [ ] **No "Part 1" or "WIP" commits** - Unless on feature branch (clean before merge)

---

## Consistency Checks

### With Project History
- [ ] **Matches team style** - Check `git log` for conventions
- [ ] **Uses same scopes** - Don't introduce new scope names
- [ ] **Follows same format** - Header length, punctuation style
- [ ] **Aligns with commit frequency** - Not too granular or too bundled

### With Automated Tools
- [ ] **Passes commitlint** (if configured)
- [ ] **Passes pre-commit hooks**
- [ ] **Generates correct changelog entry**
- [ ] **Triggers correct CI/CD actions**

---

## Common Mistakes to Avoid

### Format Mistakes
- [ ] **No missing type prefix** - Not "add feature" but "feat: add feature"
- [ ] **No invalid types** - Not "update" or "enhancement"
- [ ] **No uppercase in type/scope** - Not "Feat(API):" but "feat(api):"
- [ ] **No period in header** - Not "feat(api): add endpoint."
- [ ] **No past tense** - Not "added" but "add"

### Content Mistakes
- [ ] **No vague messages** - Not "fix bug" or "update code"
- [ ] **No implementation details in header** - Not "change Redis.setex TTL to 3600"
- [ ] **No omitting "why"** - Always explain motivation if not obvious
- [ ] **No bundling unrelated changes** - Split into separate commits

### History Mistakes
- [ ] **No "WIP" commits on main** - Clean up before merging
- [ ] **No merge commits from PRs** - Use squash or rebase
- [ ] **No commit message typos** - Proofread before committing
- [ ] **No force pushes to shared branches** - Only force push feature branches

---

## Quick Command Reference

### Review Before Committing
```bash
# See what will be committed
git diff --staged

# See commit history for style reference
git log --oneline -n 10

# Check if branch is clean
git status
```

### Committing
```bash
# Commit with message
git commit -m "feat(auth): add OAuth provider"

# Commit with body
git commit -m "feat(auth): add OAuth provider" -m "Supports Google and GitHub OAuth."

# Amend last commit (if not pushed)
git commit --amend

# Amend without changing message
git commit --amend --no-edit
```

### Fixing Mistakes

```bash
# Change last commit message (if not pushed)
git commit --amend -m "new message"

# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Undo last commit (keep changes unstaged)
git reset HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Interactive rebase to fix multiple commits
git rebase -i HEAD~3
```

---

## Pre-Commit Validation Script

Create `.git/hooks/commit-msg`:

```bash
#!/bin/sh

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Check format
if ! echo "$COMMIT_MSG" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+"; then
    echo "ERROR: Commit message doesn't follow Conventional Commits format"
    echo "Format: <type>(<scope>): <subject>"
    echo "Example: feat(auth): add OAuth provider"
    exit 1
fi

# Check header length
HEADER=$(echo "$COMMIT_MSG" | head -n 1)
if [ ${#HEADER} -gt 72 ]; then
    echo "ERROR: Commit header exceeds 72 characters (${#HEADER} chars)"
    echo "Keep it under 50 characters (recommended) or 72 (maximum)"
    exit 1
fi

# Check imperative mood (simple check for common violations)
if echo "$HEADER" | grep -qE "(added|fixed|updated|changed|created|removed|ing\b)"; then
    echo "WARNING: Use imperative mood (add, not added/adding)"
    echo "Write as if completing 'This commit will...'"
fi

exit 0
```

Make executable:
```bash
chmod +x .git/hooks/commit-msg
```

---

## Commit Message Template

Create `.gitmessage` in project root:

```
# <type>(<scope>): <subject> (max 50 chars)
# |<----  Using a Maximum Of 50 Characters  ---->|


# Body: Explain *what* and *why* (not *how*). Wrap at 72 chars.
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|


# Footer: Breaking changes, issue references, co-authors
# BREAKING CHANGE: Description
# Closes #123
# Co-authored-by: Name <email@example.com>


# --- COMMIT END ---
# Type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Remember:
#   - Imperative mood (add, not added)
#   - No period at end of subject
#   - Separate subject from body with blank line
#   - Explain what and why, not how
```

Configure:
```bash
git config commit.template .gitmessage
```

---

## Self-Review Checklist

Before finalizing commit, ask yourself:

1. **Format**: Does it follow `<type>(<scope>): <subject>` format?
2. **Clarity**: Will I understand this in 6 months?
3. **Specificity**: Does it clearly state what changed?
4. **Atomicity**: Does it represent one logical change?
5. **Completeness**: Does codebase work after this commit?
6. **Testing**: Do all tests pass?
7. **Context**: Is there enough context in body (if needed)?
8. **Breaking**: Are breaking changes documented?
9. **References**: Are issues closed/referenced?
10. **Consistency**: Does it match project conventions?

---

## Additional Resources

- [Conventional Commits Reference](./Conventional_Commits_Reference.md)
- [Commit Best Practices Guide](./Commit_Best_Practices_Guide.md)
- [First Commit Instructions](./First_Commit_Instructions.md)
- [Progress Commit Instructions](./Progress_Commit_Instructions.md)
- [Commit Review Instructions](./Commit_Review_Instructions.md)

---

**Last Updated**: 2025-12-11
