# Claude Code Setup Instructions — Workflow Template

> **Context**: Use this workflow to configure Claude Code CLI in infrastructure projects, auto-integrating commit standards, documentation patterns, and code review checklists from infra-ai-prompts repository.
> **Reference**: Reads from `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` modules.

---

## Role & Objective

You are a **development environment configurator** assisting the user to set up Claude Code with infra-ai-prompts standards integration.

Your task: Create `.claude/` directory structure with CLAUDE.md memory file, custom slash commands, and security-focused permissions for infrastructure development.

---

## Pre-Execution Validation

Before configuring, verify:

- [ ] Claude Code is installed and accessible
- [ ] Current directory is target project root
- [ ] User has write permissions in current directory
- [ ] Git repository exists (optional but recommended)
- [ ] infra-ai-prompts repository path is known

---

## Configuration Workflow

### Step 1: Create Directory Structure

```bash
mkdir -p .claude/commands
```

Creates:
- `.claude/` - Main configuration directory
- `.claude/commands/` - Custom slash commands

---

### Step 2: Create CLAUDE.md Memory File

Create `.claude/CLAUDE.md` with project-specific configuration:

```markdown
# Project Configuration

This project uses technical standards from infra-ai-prompts repository.

**Repository location**: [IDENTIFY_PATH_TO_INFRA_AI_PROMPTS]

## Available Standards Modules

- **commits/** - Conventional Commits standards
- **python/** - Python docstring standards (Google Style)
- **readme/** - README documentation patterns
- **sqlalchemy/** - SQLAlchemy model documentation
- **shell/** - Shell script best practices
- **just/** - Just script best practices

## Project Commands

[ANALYZE_PROJECT_AND_IDENTIFY_MAIN_COMMANDS]

Examples:
- Build: `just build` or `make build`
- Tests: `pytest` or `npm test`
- Lint: `ruff check` or `eslint .`
- Deploy: `terraform apply` or `ansible-playbook deploy.yml`

## Code Standards

[ANALYZE_PROJECT_AND_IDENTIFY_STANDARDS]

Examples:
- Language: Python 3.11+
- Style: PEP 8, Google Style docstrings
- Tools: ruff, black, mypy
- Framework: FastAPI, SQLAlchemy 2.0

## Automatic Workflows

### Commits
Reference: @[INFRA_AI_PROMPTS_PATH]/commits/Commits_Message_Generation_Progress_Instructions.md

### Python Documentation
Reference: @[INFRA_AI_PROMPTS_PATH]/python/Python_Documentation_Generation_Instructions.md

### README Updates
Reference: @[INFRA_AI_PROMPTS_PATH]/readme/README_Update_Instructions.md

## Security Policy

⚠️ NEVER commit:
- Files matching `.env*`
- Credentials in code
- Private keys (*.pem, *.key)
- Hardcoded API tokens
- Secrets in configuration files
```

**Instructions for AI:**
1. Replace `[IDENTIFY_PATH_TO_INFRA_AI_PROMPTS]` with actual repository path
2. Replace `[ANALYZE_PROJECT_AND_IDENTIFY_MAIN_COMMANDS]` with real project commands
3. Replace `[ANALYZE_PROJECT_AND_IDENTIFY_STANDARDS]` with detected standards
4. Replace `[INFRA_AI_PROMPTS_PATH]` with relative or absolute path to repository
5. Keep file concise (under 200 lines)

---

### Step 3: Create Custom Slash Commands

#### Command: `/commit`

File: `.claude/commands/commit.md`

```markdown
Generate commit message following workflow:

1. Execute: `git diff --staged`
2. Follow instructions: @commits/Commits_Message_Generation_Progress_Instructions.md
3. Reference standards: @commits/Commits_Message_Reference.md
4. Generate commit message in Conventional Commits format
5. Ask user approval before committing

IMPORTANT: Never execute git commit automatically. Always require user confirmation.
```

#### Command: `/doc-python`

File: `.claude/commands/doc-python.md`

```markdown
Document Python code following standards:

1. Read: @python/Python_Documentation_Generation_Instructions.md
2. Apply: @python/Python_Docstring_Standards_Reference.md
3. Check preferences: @python/preferences/examples/ (if available)
4. Apply standards to selected or specified code
5. Show diff before applying changes

Use Google Style docstrings with complete Args, Returns, Raises sections.
```

#### Command: `/update-readme`

File: `.claude/commands/update-readme.md`

```markdown
Update project README following standards:

1. Read: @readme/README_Update_Instructions.md
2. Apply: @readme/README_Standards_Reference.md
3. Analyze current project (dependencies, structure, entry points)
4. Update README preserving valid existing content
5. Show proposed changes before applying

Focus on accuracy: verify all commands, paths, and examples.
```

#### Command: `/review`

File: `.claude/commands/review.md`

```markdown
Execute technical code review:

**Python code**: Apply @python/ standards
**Shell scripts**: Use checklist @shell/Shell_Script_Checklist.md
**Just scripts**: Use checklist @just/Just_Script_Checklist.md
**SQLAlchemy**: Apply @sqlalchemy/ standards

Review layers:
1. Security (CRITICAL): credentials, injections, permissions
2. Best practices (HIGH): standards compliance
3. Code quality (MEDIUM): maintainability
4. Documentation (LOW): completeness

Report findings with severity levels: CRITICAL/HIGH/MEDIUM/LOW.
```

**Note:** All `@` references use relative paths from project root to infra-ai-prompts repository. Claude Code resolves these automatically when configured correctly in CLAUDE.md.

---

### Step 4: Create Security-Focused Settings

File: `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(ls -la*)",
      "Bash(cat *)",
      "Bash(terraform validate)",
      "Bash(terraform plan)",
      "Bash(ansible-lint*)",
      "Bash(pytest*)",
      "Bash(ruff check*)",
      "Bash(make test)",
      "Bash(just --list)",
      "Read(**/*.py)",
      "Read(**/*.md)",
      "Read(**/*.tf)",
      "Read(**/*.yml)",
      "Read(**/*.yaml)",
      "Read(**/justfile)",
      "Read(**/Makefile)"
    ],
    "deny": [
      "Bash(git push*)",
      "Bash(terraform apply*)",
      "Bash(terraform destroy*)",
      "Bash(ansible-playbook*)",
      "Bash(kubectl delete*)",
      "Bash(kubectl apply*)",
      "Bash(rm -rf*)",
      "Bash(sudo *)",
      "Read(**/.env*)",
      "Read(**/*credentials*)",
      "Read(**/*secret*)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/secrets/**)",
      "Write(**/.env*)"
    ]
  }
}
```

**Adapt permissions based on project tech stack:**
- Add allowed commands for project-specific tools
- Add deny rules for destructive operations
- Maintain principle of least privilege

---

### Step 5: Configure .gitignore

Add to project `.gitignore`:

```gitignore
# Claude Code - local configurations only
.claude/CLAUDE.local.md
.claude/settings.local.json

# DO commit these for team sharing:
# .claude/CLAUDE.md
# .claude/commands/
# .claude/settings.json
```

**Important**:
- `.local` files are personal overrides (not committed)
- Base configuration should be committed for team consistency

---

### Step 6: Test Configuration

Execute test commands to verify setup:

```
> /commit
> /doc-python
> /update-readme
> /review
```

**Expected behavior:**
- Commands load without errors
- Prompts reference infra-ai-prompts modules correctly
- Permissions allow read operations, deny destructive ones

**If errors occur:**
- Verify infra-ai-prompts path in CLAUDE.md
- Check @ reference paths in commands
- Validate settings.json JSON syntax

---

### Step 7: User Notification

Inform user:

```
✅ Claude Code configuration complete!

Created:
- .claude/CLAUDE.md (project memory)
- .claude/commands/*.md (4 custom commands)
- .claude/settings.json (security permissions)
- .gitignore updated

Available commands:
- /commit            → Smart commits with Conventional Commits
- /doc-python       → Document Python code with Google Style
- /update-readme    → Update README with standards
- /review           → Technical code review with security focus

Next steps:
1. Review .claude/CLAUDE.md and adjust project-specific details
2. Test commands: /commit, /review, etc.
3. Commit .claude/ to repository for team sharing
4. Optional: Add more custom commands in .claude/commands/

Documentation: @workflows/README.md
```

---

## Output Format (Required)

Structure your response:

```
## Configuration Summary

**Project**: [project name or path]
**infra-ai-prompts path**: [detected or specified path]

## Files Created

### .claude/CLAUDE.md
[Show key sections configured]

### .claude/commands/
- commit.md (smart commits)
- doc-python.md (Python documentation)
- update-readme.md (README updates)
- review.md (code review)

### .claude/settings.json
- Allowed: [count] safe operations
- Denied: [count] destructive operations

### .gitignore
- Added .local exclusions
- Preserved base config for team

## Validation

- [x] Directory structure created
- [x] CLAUDE.md configured with project specifics
- [x] Custom commands created
- [x] Security settings applied
- [x] .gitignore updated
- [x] Test commands validated

## Usage

Try these commands:
```
> /commit
> /doc-python
> /review
```

**Status**: ✅ Configuration ready for use
```

---

## Practical Examples

### Example 1: Python FastAPI Project

**Detected:**
- Language: Python 3.11
- Framework: FastAPI
- Tools: pytest, ruff, mypy
- Entry point: `uvicorn app.main:app`

**CLAUDE.md excerpt:**
```markdown
## Project Commands

- Run server: `uvicorn app.main:app --reload`
- Tests: `pytest tests/ -v`
- Lint: `ruff check . && mypy .`
- Format: `ruff format .`

## Code Standards

- Python 3.11+ with type hints
- FastAPI for API endpoints
- Pydantic v2 for validation
- Google Style docstrings
- 100% test coverage on business logic
```

---

### Example 2: Terraform Infrastructure Project

**Detected:**
- Tool: Terraform 1.5+
- Provider: AWS
- Tools: tflint, checkov
- Entry point: `main.tf`

**CLAUDE.md excerpt:**
```markdown
## Project Commands

- Init: `terraform init`
- Plan: `terraform plan`
- Validate: `terraform validate && tflint`
- Security: `checkov -d .`
- Format: `terraform fmt -recursive`

## Code Standards

- Terraform 1.5+ with AWS provider
- All resources tagged: environment, project, managed_by
- Variables have descriptions
- Outputs documented
- Modules versioned
```

**Custom settings.json:**
```json
{
  "permissions": {
    "allow": [
      "Bash(terraform init)",
      "Bash(terraform plan)",
      "Bash(terraform validate)",
      "Bash(tflint*)",
      "Bash(checkov*)",
      "Read(**/*.tf)"
    ],
    "deny": [
      "Bash(terraform apply*)",
      "Bash(terraform destroy*)"
    ]
  }
}
```

---

## Anti-Patterns to Avoid

❌ **Hardcoding infra-ai-prompts path in commands**:
```markdown
# Bad - breaks when repo moves
Use @/home/user/repos/infra-ai-prompts/commits/...
```

✅ **Use relative paths from CLAUDE.md**:
```markdown
# Good - portable
Use @commits/...
```

❌ **Overly permissive settings**:
```json
{
  "permissions": {
    "allow": ["Bash(*)", "Write(**/*)", "Read(**)"]
  }
}
```

✅ **Principle of least privilege**:
```json
{
  "permissions": {
    "allow": ["Bash(git status)", "Bash(terraform plan)"],
    "deny": ["Bash(rm *)", "Bash(terraform destroy*)"]
  }
}
```

❌ **Generic CLAUDE.md without project specifics**:
```markdown
# Bad - no actionable information
This project follows standards.
```

✅ **Project-specific and actionable**:
```markdown
# Good - clear and specific
- Tests: `pytest tests/ -v --cov`
- Deploy: `just deploy staging`
- Logs: `kubectl logs -f deployment/api`
```

---

## Validation Checklist

Before completing:

- [ ] `.claude/` directory created
- [ ] `CLAUDE.md` exists with project-specific content
- [ ] infra-ai-prompts path correctly referenced
- [ ] 4 custom commands created (commit, doc-python, update-readme, review)
- [ ] `settings.json` has safe defaults
- [ ] `.gitignore` excludes `.local` files
- [ ] Test commands execute without errors
- [ ] User informed of next steps

---

## Troubleshooting

**Commands not found:**
- Verify `.claude/commands/` directory exists
- Check command files have `.md` extension
- Restart Claude Code session

**@ references not resolving:**
- Verify infra-ai-prompts path in CLAUDE.md
- Use absolute path if relative fails
- Check path syntax (forward slashes)

**Permission denied:**
- Review `settings.json` allow/deny rules
- Add specific allowed patterns
- Remove overly broad deny patterns

---

**Reference**: See `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` modules for detailed standards that these workflows integrate.

**Philosophy**: One-time configuration investment for long-term consistency and productivity gains.
