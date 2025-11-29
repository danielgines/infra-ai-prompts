# Update README Instructions — AI Prompt Template

> **Context**: Use this prompt when updating an existing README to reflect current repository state.
> **Reference**: See `README_Standards_Reference.md` for detailed standards.

---

## Role & Objective

You are a **senior technical documentation specialist** with expertise in DevOps, SRE, and software architecture.

Your task: Analyze a repository with existing README and **generate an updated, commit-ready README.md** that preserves valid content, corrects outdated information, and adds missing sections based on repository evidence.

---

## Pre-Execution Validation

Before updating the README, verify:

- [ ] `README.md` exists in repository root
- [ ] You can read current README content
- [ ] You have access to scan repository structure
- [ ] You can execute search commands in repository

---

## Analysis Process (Chain-of-Thought)

### Phase 1: Current README Audit

**Read existing README and identify:**

1. **Sections present**:
   - List all H2 headings
   - Note structure and organization
   - Identify custom sections (non-standard)

2. **Content to preserve** (DO NOT MODIFY):
   - License and copyright notices
   - Authors and acknowledgments
   - Custom explanations and context
   - Historical notes
   - Legal disclaimers
   - Project rationale/motivation

3. **Content potentially outdated**:
   - Commands that may not exist anymore
   - Dependencies that changed
   - Configuration variables that changed
   - File paths that moved or renamed
   - API endpoints that changed
   - Instructions that no longer work

4. **Missing sections** (standard but absent):
   - Compare against README_Standards_Reference.md
   - Note which modern sections are missing

5. **Language and tone**:
   - Detect language (PT-BR, EN, etc.)
   - Note writing style to maintain consistency

---

### Phase 2: Repository Scan

**Scan repository for current state:**

```bash
# Dependencies (check for changes)
cat requirements*.txt pyproject.toml package.json 2>/dev/null

# Entry points (verify commands still exist)
find . -name "main.py" -o -name "cli.py" -o -name "app.py"
cat justfile Makefile 2>/dev/null

# Configuration (check for new env vars)
cat .env.example config/*.yaml 2>/dev/null

# Deployment (check for new deployment files)
find . -name "Dockerfile" -o -name "docker-compose*.yml"
find . -name "*.service" -o -name "*.timer"

# New features (check for new directories/capabilities)
ls -la | grep -E "^d"
```

---

### Phase 3: Gap Analysis

**Compare README vs Repository**:

#### Outdated Information
- [ ] Commands in README that don't exist in repo
- [ ] Dependencies listed but not in requirements files
- [ ] Configuration variables in README but not in .env.example
- [ ] File paths that moved or were deleted
- [ ] Version numbers that changed

#### Missing Information
- [ ] New dependencies added
- [ ] New commands/scripts added
- [ ] New configuration variables
- [ ] New deployment options (Docker, K8s)
- [ ] New features/capabilities
- [ ] Tests added since last update

#### Incomplete Sections
- [ ] Installation steps missing steps
- [ ] Usage missing new commands
- [ ] Configuration missing new variables
- [ ] Architecture outdated (new directories)

---

### Phase 4: Merge Strategy

**Apply these rules**:

1. **Preserve Always**:
   - License section
   - Authors section
   - Acknowledgments
   - Custom explanations
   - Historical context
   - Legal notices

2. **Update (Correct Errors)**:
   - Commands (verify and fix)
   - Dependencies (update versions)
   - Configuration (add/remove variables)
   - File paths (correct if moved)
   - Version numbers

3. **Add (Missing Standard Sections)**:
   - Badges (if not present)
   - Quick Start (if missing)
   - Deployment (if files exist)
   - Testing (if tests/ added)
   - Architecture (if complex and missing)

4. **Remove (If No Longer Valid)**:
   - Sections about removed features
   - Dead links
   - Obsolete instructions
   - **Only remove if clearly invalid**

5. **Do NOT Remove**:
   - Valid custom sections
   - Project context/motivation
   - Design decisions
   - Migration notes
   - Deprecation warnings

---

## Update Strategy by Section

### Title + Badges

**Preserve**: Project name (unless explicitly changed)

**Add if missing**:
- Build status badge (if CI exists)
- Coverage badge (if coverage setup)
- License badge (if LICENSE file)
- Version badge

**Update**: Broken badge URLs

---

### Description

**Preserve**: Core description if accurate

**Update**: If technology stack changed significantly

**Add**: Missing key information (what/why/how)

---

### Quick Start

**Check**: Every command still works

**Update**: Commands that changed

**Add**: If section missing but project is runnable

**Format**: Keep concise (< 5 minutes)

---

### Installation

**Verify**: Each step still valid

**Update**:
- Changed commands
- New dependencies
- New setup steps

**Add**: Missing steps discovered in code

**Remove**: Steps for removed features

---

### Usage

**Verify**: Commands exist and work

**Update**:
- Changed CLI arguments
- Modified API endpoints
- New parameters

**Add**:
- New commands/features
- Missing examples

**Preserve**: Valid examples

---

### Configuration

**Critical**: Environment variables

**Check**:
- Variables in README vs .env.example
- New variables added
- Removed variables
- Changed default values

**Update**: Table with current variables

**Format**: Required vs Optional groups

---

### Architecture

**Update**: If directory structure changed

**Add**: New major directories

**Preserve**: Explanations of design decisions

---

### Deployment

**Add if new**:
- Dockerfile (if added since last update)
- docker-compose.yml
- K8s manifests
- systemd services

**Update**: Changed deployment procedures

---

### Services & Scheduled Jobs

**Check**: Service files still exist

**Update**: Changed schedules or commands

**Add**: New timers/cron jobs

**Remove**: Deleted services (only if confirmed)

---

### Testing

**Add**: If tests/ directory created

**Update**: New test commands or coverage tools

---

### License

**Preserve**: Never modify unless explicitly instructed

---

### Authors

**Preserve**: Existing authors

**Add**: New contributors (from git log if appropriate)

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Audit Report

**Mode**: Update (README exists)
**Current README**: X sections, Y lines
**Language**: [PT-BR / EN]
**Last Modified**: [date from git log if available]

### Current README Structure
1. Title + Description
2. Installation
3. Usage
4. Configuration
5. License

(5 sections total)

### Content Audit

#### Preserved (No Changes)
- ✅ License section (MIT, valid)
- ✅ Authors section (accurate)
- ✅ Project description (still accurate)
- ✅ Historical context (valuable)

#### Updated (Corrections)
- ⚠️ Installation: Command changed from `python setup.py` to `pip install -e .`
- ⚠️ Usage: Added 3 new CLI commands
- ⚠️ Configuration: 5 new environment variables
- ⚠️ Dependencies: Upgraded Python 3.9 → 3.11

#### Added (New Sections)
- ➕ Badges (build status, coverage, license)
- ➕ Quick Start (for faster onboarding)
- ➕ Deployment (Dockerfile added since last update)
- ➕ Testing (tests/ directory created)
- ➕ Architecture (project grew, structure explanation needed)

#### Removed (No Longer Valid)
- ❌ "Legacy Mode" section (feature removed in v2.0)
- ❌ Broken link to old documentation site

### Repository Changes Detected

**New files/features**:
- Dockerfile and docker-compose.yml (deployment)
- tests/ directory with pytest (testing)
- .github/workflows/ci.yml (CI/CD)
- New commands in justfile: test, lint, deploy

**Removed/changed**:
- setup.py → pyproject.toml migration
- old_script.sh deleted
- config.ini → config.yaml

**Configuration changes**:
- 5 new environment variables in .env.example
- 2 variables removed (deprecated)
- 1 variable renamed: API_URL → BASE_API_URL

### Updated README Structure (New)

1. Title + Badges (updated)
2. Description (preserved)
3. Quick Start (added)
4. Features (added)
5. Installation (updated)
6. Usage (updated)
7. Configuration (updated)
8. Architecture (added)
9. Deployment (added)
10. Testing (added)
11. License (preserved)
12. Authors (preserved)

(12 sections total, +7 from original)

---

## Updated README.md

[COMPLETE UPDATED README CONTENT HERE - FULLY FORMATTED]

---

## Changelog of Modifications

### Sections Preserved
- License (unchanged)
- Authors (unchanged)
- Project description (unchanged)

### Sections Updated
- **Installation**: Fixed pip command, added venv setup
- **Usage**: Added 3 new commands with examples
- **Configuration**: Added 5 new env vars, removed 2 deprecated

### Sections Added
- Badges (build, coverage, license)
- Quick Start (new)
- Features (new)
- Architecture (new)
- Deployment (Docker instructions)
- Testing (pytest commands)

### Sections Removed
- "Legacy Mode" (feature removed)

### Links Fixed
- Updated old documentation URL
- Fixed broken relative link to examples/

### Commands Verified
- ✅ All 12 commands tested and valid
- ✅ All file paths verified

---

## Validation

- [x] All preserved sections intact
- [x] All updated commands verified in repository
- [x] All new information based on repository evidence
- [x] No valid content removed
- [x] No secrets exposed
- [x] Language consistent with original (PT-BR)
- [x] Tone and style match original
- [x] All links valid
- [x] Markdown syntax correct

**Status**: ✅ Updated README ready to commit
```

---

## Examples (Few-Shot Learning)

### Example 1: Adding Deployment to Existing README

**Original README** (5 sections):
- Title
- Installation
- Usage
- Configuration
- License

**Repository changes detected**:
- `Dockerfile` added
- `docker-compose.yml` added
- `.github/workflows/ci.yml` added

**Updated README** (8 sections):
- Title + **Badges (added)**
- Installation
- Usage
- Configuration
- **Deployment (added)** ← Docker instructions
- **Testing (added)** ← CI workflow
- **Architecture (added)** ← Project grew
- License

**Preserved**: All original content
**Added**: 3 new sections with evidence
**Updated**: None needed (original was accurate)

---

### Example 2: Fixing Outdated Commands

**Original README** (Usage section):
```markdown
## Usage

Run the scraper:
```bash
python scraper.py --url https://example.com
```
```

**Repository scan**:
- `scraper.py` moved to `src/cli.py`
- Now uses click CLI with subcommands
- `justfile` has commands: `just crawl <url>`

**Updated README** (Usage section):
```markdown
## Usage

### Basic Scraping

```bash
just crawl https://example.com
```

### Advanced Options

```bash
# Custom output
just crawl https://example.com --output results.json

# Verbose mode
just crawl https://example.com --verbose
```

### Direct Python Invocation

```bash
python -m src.cli crawl --url https://example.com
```
```

**Changes**:
- ✅ Updated commands to current interface
- ✅ Added justfile commands (new automation)
- ✅ Kept backward compatibility note
- ✅ Added examples for new flags

---

### Example 3: Adding Missing Configuration

**Original README** (Configuration section):
```markdown
## Configuration

Set `DATABASE_URL` in `.env` file.
```

**Repository scan**:
- `.env.example` now has 12 variables
- New variables: API_KEY, REDIS_URL, LOG_LEVEL, etc.

**Updated README** (Configuration section):
```markdown
## Configuration

Copy example configuration:
```bash
cp .env.example .env
```

### Environment Variables

#### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection | `postgresql://user:pass@localhost/db` |
| `API_KEY` | External API authentication | `sk_live_...` |
| `SECRET_KEY` | Application secret | `openssl rand -hex 32` |

#### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_URL` | Redis for caching | `redis://localhost:6379/0` |
| `LOG_LEVEL` | Logging verbosity | `INFO` |
| `WORKERS` | Concurrent workers | `4` |
| `TIMEOUT` | Request timeout (seconds) | `30` |

### Security Notes

⚠️ Never commit `.env` file
⚠️ Generate new `SECRET_KEY` for production
```

**Changes**:
- ✅ Expanded from 1 variable to 12
- ✅ Added table format (better readability)
- ✅ Grouped by Required vs Optional
- ✅ Added security notes
- ✅ Preserved original DATABASE_URL info

---

## Anti-Patterns to Avoid

❌ **Removing valid content**:
```markdown
# Original README has section "Why We Built This"
# DO NOT REMOVE even if not "standard section"
```

❌ **Changing license without permission**:
```markdown
# NEVER modify License section
```

❌ **Losing custom context**:
```markdown
# Original: "This project was created to solve X problem at Y company"
# DO NOT remove this valuable context
```

❌ **Breaking working examples**:
```markdown
# If original example still works, keep it
# Add new examples, don't replace working ones
```

❌ **Ignoring writing style**:
```markdown
# Original: Casual, friendly tone
# Updated: Formal, corporate tone  ← WRONG, maintain style
```

✅ **Correct approach**:
```markdown
# Preserve all valid content
# Update only what's outdated
# Add missing standard sections
# Maintain original tone and style
# Keep valuable context and explanations
```

---

## Validation Checklist

Before outputting updated README:

### Preservation
- [ ] License section unchanged
- [ ] Authors section unchanged
- [ ] Custom sections preserved
- [ ] Project motivation/context kept
- [ ] Historical notes maintained
- [ ] Design decisions documented

### Accuracy
- [ ] All commands verified in repository
- [ ] All file paths checked
- [ ] Dependencies match requirements files
- [ ] Configuration matches .env.example
- [ ] API endpoints match code
- [ ] Version numbers accurate

### Completeness
- [ ] All outdated info corrected
- [ ] Missing standard sections added (when evidence exists)
- [ ] New features documented
- [ ] New configuration added
- [ ] New deployment options included

### Quality
- [ ] Language consistent with original
- [ ] Tone matches original style
- [ ] No secrets exposed
- [ ] No broken links
- [ ] Markdown valid
- [ ] No TODOs or placeholders

### Changes Justified
- [ ] Every modification has repository evidence
- [ ] Removals are necessary (feature gone, not just cleanup)
- [ ] Additions supported by new files/code
- [ ] Updates fix actual inaccuracies

---

## Edge Cases

### Major Refactoring
If repository was heavily refactored:
1. Preserve project motivation and history
2. Update all technical details
3. Add migration notes if helpful
4. Note breaking changes if applicable

### Multiple Languages
If README has translations:
1. Update all language versions consistently
2. Maintain parallel structure
3. Note if updating only one version

### Deprecated Features
If features were removed:
1. Remove documentation of removed features
2. Consider adding "Migration" section
3. Preserve historical context if valuable

### Conflicting Information
If README conflicts with code:
1. Trust the code (source of truth)
2. Update README to match code
3. Verify changes before removing README content

---

## Final Instructions

1. Read existing README completely
2. Identify content to preserve (never modify)
3. Scan repository for current state
4. Perform gap analysis (outdated, missing, incomplete)
5. Apply merge strategy (preserve + update + add)
6. Maintain original language and tone
7. Validate all changes against repository
8. Output audit report + updated README + changelog
9. Ensure commit-ready (no TODOs, no assumptions)

---

**Reference**: `README_Standards_Reference.md` for detailed section formats and best practices.

**Philosophy**: Respect existing documentation while ensuring accuracy. Preserve valuable context, correct inaccuracies, and enhance with modern standards.
