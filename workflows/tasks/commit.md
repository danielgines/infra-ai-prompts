# Smart Commit Workflow — Task Template

> **Context**: Use this workflow to generate commit messages following Conventional Commits specification with infra-ai-prompts standards.
> **Reference**: Reads from `commits/Progress_Commit_Instructions.md` and `commits/Conventional_Commits_Reference.md`.

---

## Role & Objective

You are a **version control specialist** assisting the user to create professional, semantic commit messages.

Your task: Analyze staged changes and generate commit-ready messages following Conventional Commits specification, explaining the "why" not just the "what".

---

## Pre-Execution Validation

Before generating commit:

- [ ] Git repository exists
- [ ] Changes are staged (`git status` shows staged files)
- [ ] This is a commit suggestion (NOT auto-commit)
- [ ] User will approve before execution

---

## Workflow Steps

### Step 1: Check Repository State

```bash
git status
```

If no staged changes, inform user:
```
No staged changes found.
Use: git add <files>
Or: git add -p (interactive staging)
```

---

### Step 2: Analyze Changes

```bash
git diff --staged
```

Identify:
- **Nature**: feat, fix, refactor, docs, style, test, build, ci, chore, perf
- **Scope**: Module/component affected (auth, api, ui, db, config)
- **Impact**: Breaking changes? Performance? Security?
- **Context**: Why was this change needed?

---

### Step 3: Determine Commit Type

**Read and follow:**
- First commit: `@commits/First_Commit_Instructions.md`
- Progress commit (most common): `@commits/Progress_Commit_Instructions.md`
- History rewrite: `@commits/History_Rewrite_Instructions.md`

**Always reference:** `@commits/Conventional_Commits_Reference.md`

---

### Step 4: Generate Commit Message

**Format (required):**

```
type(scope): concise description (max 72 chars)

Detailed body explaining WHY this change was made.
Include context that helps understand the rationale.

BREAKING CHANGE: description if applicable
Closes #issue-number if applicable
```

**Type selection:**
- `feat`: New functionality
- `fix`: Bug correction
- `docs`: Documentation changes
- `style`: Formatting (no logic change)
- `refactor`: Code restructure (no behavior change)
- `perf`: Performance improvements
- `test`: Test additions/corrections
- `build`: Build system/dependencies
- `ci`: CI/CD changes
- `chore`: Maintenance tasks

---

### Step 5: Validate Message

Check:
- ✅ Type matches change nature
- ✅ Scope is specific and appropriate
- ✅ Description is clear (imperative mood: "add" not "added")
- ✅ Body explains "why", not "what"
- ✅ Breaking changes documented with `BREAKING CHANGE:`
- ✅ No period at end of description line
- ✅ Max 72 characters in description

---

### Step 6: Present to User

Show proposed message:

```
type(scope): description

Body text explaining why...

Footer if needed
```

**Ask user:**
```
Proposed commit message above.

Options:
1. Approve and create commit
2. Edit message
3. Cancel

What would you like to do?
```

---

### Step 7: Execute (if approved)

```bash
git commit -m "type(scope): description

Body text here.

Footer if applicable"
```

**After commit:**
```bash
git log -1 --oneline
```

Confirm success and suggest next steps.

---

## Output Format (Required)

```
## Change Analysis

- **Files changed**: [count]
- **Scope identified**: [scope]
- **Type detected**: [type]
- **Breaking changes**: [yes/no]

## Proposed Commit Message

\```
type(scope): concise description

Detailed explanation of why this change was needed.
Context that helps future maintainers understand.

BREAKING CHANGE: if applicable
Closes #123 if applicable
\```

## Validation

- [x] Type correct
- [x] Scope appropriate
- [x] Description clear and concise
- [x] Body explains "why"
- [x] Format follows Conventional Commits

## Next Steps

Options:
1. Approve: I'll create the commit
2. Edit: Modify the message
3. Cancel: Abort commit

**Status**: 📝 Awaiting approval
```

---

## Practical Examples

### Example 1: Feature Addition

**Changes:** New JWT authentication middleware, tests, documentation

**Output:**
```
feat(auth): add JWT authentication middleware

Implements token-based authentication for API endpoints using
jsonwebtoken library. Middleware validates tokens on protected
routes and handles expiration gracefully.

- Validates JWT signature and expiration
- Extracts user info from payload
- Returns 401 for invalid/expired tokens
- Includes tests for success/failure scenarios

Closes #245
```

---

### Example 2: Bug Fix

**Changes:** Fixed null pointer in user registration

**Output:**
```
fix(api): prevent null pointer in user registration

Adds null check before accessing user email field. Previous code
threw exception when email was undefined, blocking valid registrations.

Now returns clear 400 error with message when email is missing.

Fixes #312
```

---

### Example 3: Breaking Change

**Changes:** API signature changed, configuration format updated

**Output:**
```
feat(api): migrate to v2 endpoint structure

Restructures API endpoints for better REST compliance and
consistency. V1 endpoints deprecated but still functional.

BREAKING CHANGE: API endpoints now require JWT authentication.
Update client code to include Authorization header.
Migration guide: docs/api-v2-migration.md
```

---

## Anti-Patterns to Avoid

❌ **Vague descriptions:**
```
fix: bug fix
refactor: improve code
```

❌ **Implementation details in header:**
```
feat: add LoginController class with authenticateUser method
```

❌ **Bundling unrelated changes:**
```
feat: add login + fix typo in footer + update dependencies
```

❌ **Missing "why" in body:**
```
fix(api): change validation

Changed the validation logic.
```

✅ **Clear, contextual commits:**
```
fix(api): validate email format in registration

Adds regex validation to prevent malformed emails.
Previous code accepted invalid formats causing delivery failures.

Regex: RFC 5322 compliant
Fixes #156
```

---

## Validation Checklist

Before completing:

- [ ] All staged files analyzed
- [ ] Type accurately reflects change nature
- [ ] Scope identifies affected area
- [ ] Description is concise (≤72 chars)
- [ ] Body explains "why" not "what"
- [ ] Breaking changes documented
- [ ] Issue references included
- [ ] Format follows Conventional Commits
- [ ] User approval obtained

---

## Troubleshooting

**No staged changes:**
```
Error: No staged changes to commit.

Solution:
1. Stage files: git add <files>
2. Review: git status
3. Retry commit
```

**Merge conflict:**
```
Error: Merge in progress.

Solution:
1. Resolve conflicts first
2. Stage resolved files
3. Continue merge: git commit (no -m flag)
```

**Empty commit:**
```
Error: Changes are whitespace-only.

Check: git diff --staged --ignore-all-space
```

---

**Reference**: See `commits/Progress_Commit_Instructions.md` for detailed commit generation process and `commits/Conventional_Commits_Reference.md` for specification.

**Philosophy**: Commits are documentation. Write for future maintainers who need to understand why changes were made.
