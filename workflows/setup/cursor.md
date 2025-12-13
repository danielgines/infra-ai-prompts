# Cursor IDE Setup Instructions — Workflow Template

> **Module Type**: Part of `workflows/` META-MODULE
> **Context**: Use this workflow to configure Cursor IDE in infrastructure projects, integrating infra-ai-prompts standards via `.cursorrules` file.
> **Reference**: Orchestrates standards from `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` content modules.

---

## Role & Objective

You are a **development environment configurator** assisting the user to set up Cursor IDE with infra-ai-prompts standards integration.

Your task: Create `.cursorrules` file and supporting documentation that enables Cursor to automatically apply commit standards, documentation patterns, and code review protocols.

---

## Pre-Execution Validation

Before configuring, verify:

- [ ] Cursor IDE is installed
- [ ] Current directory is target project root
- [ ] User has write permissions
- [ ] infra-ai-prompts repository path is known

---

## Configuration Workflow

### Step 1: Create .cursorrules File

Create `.cursorrules` in project root:

```markdown
# Project Rules — Infrastructure Standards

This project uses technical standards from infra-ai-prompts repository.

**Standards location**: [IDENTIFY_PATH_TO_INFRA_AI_PROMPTS]

## Technologies

[ANALYZE_AND_IDENTIFY:]
- Primary language: Python 3.11+ / Go / etc.
- Framework: FastAPI / Django / etc.
- Database: PostgreSQL / MySQL / etc.
- Infrastructure: Terraform / Ansible / Kubernetes

## Commands

[PROJECT_SPECIFIC_COMMANDS:]
- Tests: `pytest tests/ -v`
- Lint: `ruff check .`
- Build: `just build`
- Deploy: `terraform plan`

## Commit Standards

Always follow Conventional Commits: @commits/Commits_Message_Reference.md

When generating commits:
1. Analyze: `git diff --staged`
2. Follow: @commits/Commits_Message_Generation_Progress_Instructions.md
3. Format: `type(scope): description`
4. Validate against checklist

## Python Documentation

When documenting Python:
- Follow: @python/Python_Docstring_Standards_Reference.md
- Style: Google Style docstrings
- Include: Args, Returns, Raises, Examples
- Check: @python/preferences/examples/ for project overrides

## Shell Scripts

When creating/modifying shell scripts:
- Follow: @shell/Shell_Script_Best_Practices_Guide.md
- Validate: @shell/Shell_Script_Checklist.md
- Always use: `set -euo pipefail`

## Just Scripts

When creating/modifying justfiles:
- Follow: @just/Just_Script_Best_Practices_Guide.md
- Validate: @just/Just_Script_Checklist.md

## SQLAlchemy Models

When documenting models:
- Follow: @sqlalchemy/SQLAlchemy_Model_Documentation_Standards_Reference.md
- Include: Class docstrings, column comments, examples
- Use: Real data examples when possible

## Code Review Checklist

When reviewing code:
1. **Security** (CRITICAL): No credentials, injection vulnerabilities, insecure permissions
2. **Standards** (HIGH): Follows project and module standards
3. **Quality** (MEDIUM): Maintainable, tested, documented
4. **Documentation** (LOW): Complete and accurate

## Security Rules

⚠️ NEVER:
- Generate credentials in code
- Suggest committing .env files
- Use permissions 777
- Disable security validations

✅ ALWAYS:
- Use environment variables for secrets
- Validate user inputs
- Apply least privilege principle
- Document security requirements
```

**Instructions for AI:**
1. Replace `[IDENTIFY_PATH_TO_INFRA_AI_PROMPTS]` with actual path
2. Replace `[ANALYZE_AND_IDENTIFY:]` with detected technologies
3. Replace `[PROJECT_SPECIFIC_COMMANDS:]` with real commands
4. Keep under 500 lines (Cursor has size limits)

---

### Step 2: Configure .gitignore

Add to `.gitignore`:

```gitignore
# Cursor IDE
.cursor/
.cursorrules.local

# DO commit .cursorrules for team
```

---

### Step 3: Test Configuration

Test workflows with Cursor chat:

**Test commit:**
```
Generate commit message for staged changes
```

**Test documentation:**
```
Document this Python function following our standards
```

**Test review:**
```
Review this code for security and standards compliance
```

---

### Step 4: User Notification

```
✅ Cursor IDE configuration complete!

Created:
- .cursorrules (project standards integration)
- .gitignore updated

Cursor now automatically:
- Applies Conventional Commits format
- Uses Google Style docstrings
- Follows security checklists
- References infra-ai-prompts standards

Test with natural language:
- "generate commit message"
- "document this function"
- "review this code"

Next steps:
1. Review .cursorrules and adjust if needed
2. Test workflows in Cursor chat
3. Commit .cursorrules to share with team

Documentation: @workflows/README.md
```

---

## Output Format (Required)

```
## Configuration Summary

**Project**: [name]
**Standards path**: [path]
**Technologies**: [list]

## Files Created

### .cursorrules
- Technologies detected and documented
- Project commands configured
- Standards modules referenced
- Security rules defined

### .gitignore
- Excluded .cursorrules.local
- Preserved .cursorrules for team

## Validation

- [x] .cursorrules created with project specifics
- [x] Standards paths configured
- [x] .gitignore updated
- [x] Test workflows verified

## Usage

Try in Cursor chat:
- "generate commit message"
- "document this function"
- "review this code"

**Status**: ✅ Configuration ready
```

---

## Practical Examples

### Example: FastAPI Project

```markdown
# Project Rules — FastAPI API

Standards from: ~/infra-ai-prompts

## Technologies
- Python 3.11+ with FastAPI
- PostgreSQL with SQLAlchemy 2.0
- pytest for testing
- ruff for linting

## Commands
- Run: `uvicorn app.main:app --reload`
- Tests: `pytest tests/ -v --cov`
- Lint: `ruff check . && mypy .`

[... standards references ...]
```

---

## Anti-Patterns to Avoid

❌ **Hardcoded paths**:
```markdown
Follow: /home/user/repos/infra-ai-prompts/commits/...
```

✅ **Relative references**:
```markdown
Follow: @commits/...
```

❌ **Generic without project context**:
```markdown
This project follows standards.
```

✅ **Specific and actionable**:
```markdown
Tests: pytest tests/ -v --cov
Deploy: just deploy staging
```

---

## Validation Checklist

- [ ] `.cursorrules` created
- [ ] Standards path configured
- [ ] Project specifics added
- [ ] `.gitignore` updated
- [ ] Test workflows verified

---

**Reference**: See `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` modules.

**Philosophy**: Configure once in `.cursorrules`, Cursor applies automatically in all interactions.
