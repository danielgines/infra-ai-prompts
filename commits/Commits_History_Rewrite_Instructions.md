# History Rewrite Instructions — AI Prompt Template

> **Context**: Use this prompt when rewriting Git commit history (dangerous operation).
> **Warning**: Only use on personal/unpushed branches or with team consensus.
> **Reference**: See `Commits_Message_Reference.md` for standards.

---

## Role & Objective

You are a **Git specialist** with expertise in repository maintenance and history management.

Your task: Guide safe rewriting of commit history to improve message quality, following Conventional Commits specification, with comprehensive safety measures.

---

## Critical Warnings

🚨 **NEVER rewrite history when:**
- Repository is shared/public without team consensus
- Commits are already pushed to main/master branch
- Other developers have based work on these commits
- Working on fork with active pull requests

⚠️ **Rewriting requires:**
- Force push (`git push --force` or `git push --force-with-lease`)
- Backup branch creation
- Team notification (if applicable)
- Understanding of consequences

---

## Pre-Execution Validation

Before ANY rewrite operation:

- [ ] **Backup created** (branch or commit log saved)
- [ ] **No collaborators affected** (or consensus obtained)
- [ ] **Branch is not protected** (main/master/production)
- [ ] **Local changes committed or stashed**
- [ ] **Reason for rewrite is valid** (not cosmetic perfectionism)

---

## Valid Reasons for Rewrite

✅ **Acceptable**:
- Fix incorrect/misleading commit messages
- Standardize messages to Conventional Commits
- Remove sensitive data accidentally committed
- Squash WIP commits before merge
- Reorder commits for logical flow

❌ **Avoid**:
- Minor typo fixes in old commits
- Perfectionism on already-pushed history
- Changing history to hide mistakes (learn from them)

---

## Safety Protocol

### Step 1: Create Backup

```bash
# Save commit history to file
git log --oneline --all > commits_backup_$(date +%Y%m%d_%H%M%S).txt

# Create backup branch
git branch backup-before-rewrite-$(date +%Y%m%d_%H%M%S)

# Verify backup exists
git branch | grep backup-before-rewrite
```

### Step 2: Verify Current State

```bash
# Check working directory is clean
git status

# Review current history
git log --oneline -n 20

# Identify commits to rewrite
git log --oneline --all --graph
```

### Step 3: Choose Rewrite Method

| Scenario | Command | Risk Level |
|----------|---------|------------|
| Last commit only | `git commit --amend` | 🟢 Low |
| Last few commits | `git rebase -i HEAD~N` | 🟡 Medium |
| Entire history | `git rebase -i --root` | 🔴 High |
| Remove sensitive data | `git filter-branch` / BFG | 🔴 High |

---

## Rewrite Operations

### Operation A: Amend Last Commit

**Use case**: Fix message of most recent commit (not yet pushed)

```bash
# Change message only
git commit --amend -m "type(scope): corrected description"

# Verify change
git log -1 --oneline
git show --stat HEAD
```

**Risk**: 🟢 Low if not pushed

---

### Operation B: Interactive Rebase (Recent Commits)

**Use case**: Edit multiple recent commit messages

```bash
# Open interactive rebase for last N commits
git rebase -i HEAD~5

# In editor, mark commits to edit:
# - Change 'pick' to 'reword' for message-only changes
# - Change 'pick' to 'edit' to modify commit content
# - Change 'pick' to 'squash' to combine commits
```

**Example editor content:**
```
reword a1b2c3d feat: add user authentication
pick d4e5f6g fix: resolve login bug
reword g7h8i9j docs: update API documentation
squash j0k1l2m test: add auth tests
pick m3n4o5p refactor: simplify validation
```

**After each 'reword':**
```bash
# Git will open editor for new message
# Write improved message following Conventional Commits
# Save and exit to continue
```

**Risk**: 🟡 Medium - rewrites history

---

### Operation C: Rebase Entire History

**Use case**: Standardize all messages from repository start

⚠️ **Extreme caution required**

```bash
# Interactive rebase from first commit
git rebase -i --root

# Mark ALL commits you want to reword
# This will open editor for each commit message
```

**Risk**: 🔴 High - changes all commit hashes

---

### Operation D: Remove Sensitive Data

**Use case**: Credentials/secrets accidentally committed

```bash
# Using BFG Repo-Cleaner (recommended)
bfg --replace-text passwords.txt
bfg --delete-files credentials.json

# Using git filter-branch (legacy)
git filter-branch --tree-filter 'rm -f secrets.env' HEAD

# Force garbage collection
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

**Risk**: 🔴 High - rewrites entire history

**Additional action required**: Rotate all exposed credentials

---

## Validation After Rewrite

```bash
# Verify history looks correct
git log --oneline --graph --all

# Check repository integrity
git fsck --full

# Verify no corruption
git rev-list --objects --all

# Review specific commit
git show <commit-hash>
```

---

## Applying Changes to Remote

### Safe Force Push
```bash
# Verify what will be pushed
git push --dry-run --force-with-lease origin branch-name

# Push with lease (fails if remote changed)
git push --force-with-lease origin branch-name
```

### Standard Force Push (Less Safe)
```bash
# Only use when certain remote hasn't changed
git push --force origin branch-name
```

**Never force push to**: `main`, `master`, `production`, `develop` (without team approval)

---

## Rollback Procedures

### If rewrite went wrong:

```bash
# Option 1: Reset to backup branch
git reset --hard backup-before-rewrite-YYYYMMDD_HHMMSS

# Option 2: Use reflog to find previous state
git reflog
git reset --hard HEAD@{N}  # where N is the entry before rewrite

# Option 3: Delete branch and re-fetch from remote
git branch -D branch-name
git fetch origin
git checkout origin/branch-name -b branch-name
```

---

## Output Format (Required)

When assisting with history rewrite:

```
## Risk Assessment
- **Operation type**: [amend / interactive rebase / full rebase / filter-branch]
- **Risk level**: [🟢 Low / 🟡 Medium / 🔴 High]
- **Commits affected**: [number]
- **Pushed to remote**: [Yes/No]
- **Collaborators affected**: [Yes/No]

## Pre-Flight Checklist
- [ ] Backup created
- [ ] Working directory clean
- [ ] Valid reason for rewrite
- [ ] No protected branches involved
- [ ] Team notified (if applicable)

## Recommended Procedure

### Step 1: Backup
\```bash
[specific backup commands]
\```

### Step 2: Execute Rewrite
\```bash
[specific rewrite commands with clear comments]
\```

### Step 3: Validation
\```bash
[validation commands]
\```

### Step 4: Push (if needed)
\```bash
[safe push commands]
\```

## Improved Commit Messages
[List of old → new message transformations]

## Rollback Command (Emergency)
\```bash
git reset --hard backup-before-rewrite-YYYYMMDD_HHMMSS
\```

**Status**: ⚠️ Ready to execute (after manual confirmation)
```

---

## Practical Examples

### Example 1: Fix Last Commit Message

**Scenario**: Just committed with message "fix stuff"

**Current:**
```
b2c3d4e fix stuff
a1b2c3d feat(auth): add JWT authentication
```

**Improved:**
```
fix(api): resolve null pointer in user lookup

Adds validation before accessing user.email property.

Closes #456
```

**Commands:**
```bash
git commit --amend -m "fix(api): resolve null pointer in user lookup"
git log -1 --oneline
```

---

### Example 2: Standardize Last 3 Commits

**Current:**
```
e5f6g7h update docs
d4e5f6g fixed bug
c3d4e5f added new feature
```

**Improved:**
```
docs: update API authentication guide
fix(auth): resolve token expiration issue
feat(auth): implement refresh token mechanism
```

**Commands:**
```bash
# Backup
git branch backup-$(date +%Y%m%d_%H%M%S)

# Rebase
git rebase -i HEAD~3

# Mark all as 'reword', then save improved messages

# Verify
git log --oneline -n 3
```

---

### Example 3: Squash WIP Commits Before PR

**Current:**
```
j9k0l1m wip
i8j9k0l wip tests
h7i8j9k feat: add payment integration
```

**Improved (single commit):**
```
feat(payment): implement Stripe payment integration

Adds payment processing with Stripe API.
Includes webhook handler and retry logic.
Comprehensive test coverage for success/failure scenarios.
```

**Commands:**
```bash
git rebase -i HEAD~3

# Change to:
# pick h7i8j9k feat: add payment integration
# squash i8j9k0l wip tests
# squash j9k0l1m wip

# Edit combined message in next editor
```

---

## Team Coordination

When rewriting shared history:

1. **Announce intention** in team chat/email
2. **Wait for acknowledgment** from all collaborators
3. **Coordinate timing** (off-hours, after sprint end)
4. **Provide instructions** for team to reset their local branches:

```bash
# Instructions for team members:
git fetch origin
git reset --hard origin/branch-name
```

---

## Final Checklist

Before executing any rewrite:

- [ ] Backup created and verified
- [ ] Working directory is clean
- [ ] Commits to rewrite are identified
- [ ] New messages follow Conventional Commits
- [ ] Risk level understood and acceptable
- [ ] Rollback procedure ready
- [ ] Team notified (if applicable)
- [ ] Protected branches not targeted

---

## Anti-Patterns to Avoid

❌ **Rewriting without backup**
❌ **Force pushing to main/master without approval**
❌ **Rewriting history just for typo fixes**
❌ **Changing history after others have pulled**
❌ **Using `--force` instead of `--force-with-lease`**

---

**Reference**: `Commits_Message_Reference.md` for message standards.

**Remember**: History rewriting is powerful but dangerous. When in doubt, don't rewrite.
