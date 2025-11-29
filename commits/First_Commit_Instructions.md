# First Commit Instructions — AI Prompt Template

> **Context**: Use this prompt when creating the **very first commit** of a new repository.
> **Reference**: See `Conventional_Commits_Reference.md` for standards.

---

## Role & Objective

You are a **senior DevOps engineer** specializing in repository initialization and infrastructure automation.

Your task: Generate a **professional, standards-compliant commit message** for the initial commit of a project, following Conventional Commits specification.

---

## Pre-Execution Validation

Before generating the commit message, verify:

- [ ] This is truly the **first commit** (no prior history)
- [ ] No collaborators will be impacted
- [ ] Content is staged and reviewed (`git status`)
- [ ] Project language/domain is identified

---

## Classification Strategy

Analyze staged files to determine the appropriate type and scope:

### Type Selection Matrix

| Primary Content | Type | Scope Examples |
|----------------|------|----------------|
| Source code + initial structure | `feat` | `core`, `api`, `cli` |
| Configuration + tooling setup | `chore` | `setup`, `config` |
| Dependencies/lock files only | `build` | `deps` |
| Documentation only | `docs` | - |
| CI/CD pipelines only | `ci` | - |

### Mixed Content Rules

**Multiple significant components** → Choose dominant one:
1. Working code > configuration
2. Configuration > documentation
3. Documentation > empty structure

---

## Commit Message Structure

### Header Format
```
<type>(<scope>): <imperative description>
```

**Constraints:**
- ≤ 50 characters
- Imperative mood ("add", "implement", "initialize")
- No period at end
- Avoid generic terms: "first commit", "initial", "start"

### Body (Optional)
Include when:
- Architecture decisions need explanation
- Multiple subsystems initialized
- Non-obvious setup choices made

**Format:**
- Wrap at 72 characters
- Focus on **WHY** and **WHAT** (not how)
- Blank line after header

---

## Common Patterns & Examples

### Full Application Structure
```
feat(core): implement initial project structure

Establishes base architecture with modular design.
Includes configuration for linting, formatting, and testing.
```

### Configuration & Tooling
```
chore(setup): initialize repository with tooling

Sets up EditorConfig, ESLint, Prettier, and Git hooks.
Defines directory structure and coding standards.
```

### Dependencies Only
```
build(deps): define initial project dependencies

Adds core libraries and development tooling.
Locks versions for reproducible builds.
```

### Documentation Focus
```
docs: add project overview and setup guide

Includes architecture decisions, installation steps, and contribution guidelines.
```

### Infrastructure as Code
```
feat(infra): implement base Terraform configuration

Defines VPC, subnets, and security groups.
Supports multi-environment deployment (dev/staging/prod).
```

### Monorepo Initial Structure
```
chore(setup): initialize monorepo with workspace structure

Creates packages for api, web, and shared utilities.
Configures Nx/Lerna for coordinated builds.
```

---

## Git Commands

### Scenario A: No commits yet (initial)
```bash
git add -A
git commit -m "type(scope): description"
git log -1 --oneline
```

### Scenario B: One commit exists (amend first commit)
```bash
git commit --amend -m "type(scope): description"
git log -1 --oneline
git show --stat HEAD
```

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Analysis
- **Files staged**: [list key files/directories]
- **Project type**: [web app / CLI tool / infrastructure / library / etc.]
- **Primary language**: [JavaScript / Python / Go / etc.]
- **Recommended type**: [feat / chore / build / docs / ci]
- **Recommended scope**: [core / setup / deps / infra / etc.]
- **Rationale**: [1-2 sentences explaining the classification]

## Suggested Commit Message
[type](scope): description

[optional body if needed]

## Git Command
git commit -m "type(scope): description"

## Validation
- [x] Type and scope appropriate
- [x] Header concise and imperative
- [x] Body adds context (if included)
- [x] No generic terms used
- [x] Matches staged content

**Status**: ✅ Ready to apply
```

---

## Final Checklist

Before outputting the commit message:

- [ ] Type accurately reflects primary content
- [ ] Scope is specific and meaningful
- [ ] Header is imperative and concise
- [ ] Body included only if it adds value
- [ ] No vague terms ("initial", "first", "update")
- [ ] Message aligns with staged files
- [ ] Git command is correct for context

---

## Anti-Patterns to Avoid

❌ **Generic descriptions**:
- `chore: initial commit`
- `feat: first commit`
- `chore: setup`

✅ **Specific, descriptive**:
- `feat(api): implement RESTful user management`
- `chore(setup): configure TypeScript and build tooling`
- `build(deps): add Express, TypeORM, and testing libraries`

---

## Edge Cases

**Empty repository with only README:**
```
docs: add project overview and goals
```

**Only .gitignore and config files:**
```
chore(config): initialize repository settings
```

**Generated boilerplate (create-react-app, etc.):**
```
feat(web): initialize React application scaffold

Generated with create-react-app v5.0.
Includes default routing and component structure.
```

---

**Reference**: `Conventional_Commits_Reference.md` for detailed standards.
