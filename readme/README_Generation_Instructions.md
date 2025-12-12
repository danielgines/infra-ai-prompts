# New README Instructions — AI Prompt Template

> **Context**: Use this prompt when creating a README from scratch for a repository without documentation.
> **Reference**: See `README_Standards_Reference.md` for detailed standards.

---

## Role & Objective

You are a **senior technical documentation specialist** with expertise in DevOps, SRE, and software architecture.

Your task: Analyze a repository and **generate a comprehensive, commit-ready README.md from scratch** based solely on repository evidence, following modern documentation standards.

---

## Pre-Execution Validation

Before generating the README, verify:

- [ ] No `README.md` exists in repository root
- [ ] Repository has actual code/configuration (not empty)
- [ ] You have access to scan repository structure
- [ ] You can execute search commands in repository

---

## Analysis Process (Chain-of-Thought)

### Phase 1: Project Discovery

**Scan repository to identify:**

1. **Project type** (determine primary purpose):
   ```bash
   # Check for indicators
   ls -la | grep -E "setup.py|pyproject.toml|package.json|go.mod|Cargo.toml"
   find . -name "*.service" -o -name "Dockerfile" -o -name "justfile"
   ```

   - CLI Tool: argparse/click/typer, main.py with CLI
   - Web Application: FastAPI/Flask/Django, API routes
   - Library: setup.py/pyproject.toml with library structure
   - Scraper/Bot: Scrapy spiders, bot frameworks
   - Infrastructure: Terraform, Ansible, K8s manifests
   - Script Collection: Multiple .sh/.py scripts

2. **Technology stack** (languages, frameworks, tools):
   ```bash
   # Dependencies
   cat requirements*.txt pyproject.toml package.json go.mod 2>/dev/null

   # Configuration files
   find . -name "*.toml" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" | head -20
   ```

3. **Entry points** (how to run):
   ```bash
   # Python entry points
   grep -r "if __name__ == '__main__'" --include="*.py"
   grep -r "argparse\|click\|typer" --include="*.py"

   # Scripts
   find . -name "*.sh" -type f -executable
   ls -la bin/ scripts/ 2>/dev/null
   ```

4. **Orchestration** (automation):
   ```bash
   # Task runners
   cat justfile Makefile 2>/dev/null

   # Docker
   cat Dockerfile docker-compose*.yml 2>/dev/null
   ```

5. **Configuration** (environment variables):
   ```bash
   # Configuration files
   cat .env.example config/*.yaml settings.py 2>/dev/null

   # Find env vars in code
   grep -r "os.getenv\|os.environ" --include="*.py" | head -20
   ```

---

### Phase 2: Evidence Collection

For each potential README section, collect evidence:

#### Dependencies (REQUIRED)
- [ ] `requirements.txt`, `requirements-dev.txt`
- [ ] `pyproject.toml` with dependencies
- [ ] `package.json`, `go.mod`, `Cargo.toml`
- [ ] System dependencies in Dockerfile or docs

#### Installation Steps (REQUIRED)
- [ ] Setup scripts: `setup.py`, `setup.sh`
- [ ] Virtual environment: Python, Node, etc.
- [ ] Database setup: migrations/, SQL files
- [ ] Service initialization commands

#### Usage Examples (REQUIRED)
- [ ] CLI help text: `--help` output
- [ ] API routes: FastAPI/Flask route decorators
- [ ] Code examples: docstrings, comments
- [ ] Scripts: what each script does

#### Configuration (IF .env.example EXISTS)
- [ ] Environment variables with descriptions
- [ ] Config files: settings.yaml, config.json
- [ ] Default values in code

#### Deployment (IF DEPLOYMENT FILES EXIST)
- [ ] Dockerfile: container instructions
- [ ] docker-compose.yml: multi-container setup
- [ ] k8s/: Kubernetes manifests
- [ ] systemd/: service files
- [ ] Cloud configs: AWS, GCP, Azure

#### Services/Timers (IF MANIFESTS VERSIONED)
- [ ] systemd: *.service, *.timer files
- [ ] cron: crontab files in repo
- [ ] K8s: CronJob manifests
- [ ] CI/CD: scheduled workflows

#### Tests (IF tests/ EXISTS)
- [ ] Test directory structure
- [ ] Test framework: pytest, unittest, jest
- [ ] CI configuration: .github/workflows/

#### Architecture (IF COMPLEX)
- [ ] Directory structure with > 5 top-level dirs
- [ ] Multiple modules/packages
- [ ] Clear separation of concerns

---

### Phase 3: Decision Matrix

For each section, apply rules:

| Evidence Level | Action |
|----------------|--------|
| **COMPLETE** | Include full section with all details |
| **PARTIAL** | Include section with available information only |
| **MISSING** | Omit section entirely (no placeholders) |

**Examples**:
- Deployment files exist → Include Deployment section
- No tests/ directory → Omit Testing section
- .env.example partial → Include Configuration with caveat

---

## Classification Strategy

### Project Type Detection

Based on analysis, classify as:

1. **CLI Tool**:
   - Indicators: argparse/click, `if __name__ == '__main__'`
   - Focus: Usage commands, arguments, examples

2. **Web Application**:
   - Indicators: FastAPI/Flask/Django, API routes
   - Focus: API endpoints, deployment, configuration

3. **Library/Package**:
   - Indicators: setup.py, importable modules
   - Focus: Installation, API reference, examples

4. **Scraper/Bot**:
   - Indicators: Scrapy spiders, bot frameworks
   - Focus: Configuration, spiders, pipelines

5. **Infrastructure**:
   - Indicators: Terraform, Ansible, systemd
   - Focus: Deployment, services, orchestration

---

## README Structure (Required)

Generate sections in this order:

### Always Include:

1. **Title + Badges**
   - Extract name from repo folder or pyproject.toml
   - Add relevant badges (see README_Standards_Reference.md)

2. **Description** (2-4 sentences)
   - What problem does it solve?
   - What technology does it use?
   - Key feature/benefit

3. **Quick Start** (< 5 minutes to run)
   - Clone command
   - Setup command (venv, install deps)
   - Run command
   - Verify command

4. **Features** (4-8 bullet points)
   - Key capabilities from code analysis
   - Quantify when possible

### Include When Evidence Found:

5. **Table of Contents** (if README will be > 150 lines)

6. **Requirements**
   - Python/Node/Go version from config files
   - System dependencies from Dockerfile
   - External services from code

7. **Installation** (detailed)
   - Step-by-step from analysis
   - Real commands only

8. **Usage**
   - CLI: commands with examples
   - API: endpoints with curl examples
   - Library: import examples

9. **Configuration**
   - Environment variables from .env.example
   - Config files explanation
   - Table format (Required vs Optional)

10. **Architecture** (if complex project)
    - Directory tree with explanations
    - Component relationships

11. **Deployment** (if deployment files exist)
    - Docker instructions
    - Kubernetes instructions
    - Systemd instructions

12. **Services & Scheduled Jobs** (if manifests exist)
    - Table with schedules, commands, logs

13. **Development** (if contributing is possible)
    - Setup dev environment
    - Code style (from .editorconfig, .pylintrc)
    - Workflow

14. **Testing** (if tests/ exists)
    - How to run tests
    - Coverage commands

15. **Monitoring & Logs** (if logging configured)
    - Log locations
    - Monitoring endpoints

16. **License** (if LICENSE file exists)
    - License type and link

17. **Authors** (extract from git log or code)

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Analysis Report

**Mode**: Creation (no README exists)
**Language**: [PT-BR / EN based on repo context]
**Project Type**: [CLI Tool / Web App / Library / Scraper / Infrastructure]

### Technology Stack
- **Language**: Python 3.11
- **Frameworks**: Scrapy 2.11, FastAPI 0.104
- **Database**: PostgreSQL 14
- **Tools**: Docker, just

### Evidence Collected

**Entry Points**:
- src/cli.py (click CLI)
- src/main.py (FastAPI app)

**Dependencies**:
- requirements.txt: 15 packages
- requirements-dev.txt: 8 dev packages

**Configuration**:
- .env.example: 12 environment variables
- config/settings.yaml: application settings

**Deployment**:
- Dockerfile: production container
- docker-compose.yml: local development
- k8s/: Kubernetes manifests

**Tests**:
- tests/: pytest test suite
- .github/workflows/ci.yml: CI pipeline

**Services**:
- systemd/myapp.service: main application
- systemd/myapp.timer: daily job at 3 AM

### Sections Included (17)
1. ✅ Title + Badges (build, coverage, license, python)
2. ✅ Description
3. ✅ Table of Contents
4. ✅ Quick Start
5. ✅ Features
6. ✅ Requirements
7. ✅ Installation
8. ✅ Usage (CLI + API)
9. ✅ Configuration (12 env vars)
10. ✅ Architecture
11. ✅ Deployment (Docker + K8s)
12. ✅ Services & Timers
13. ✅ Development
14. ✅ Testing
15. ✅ Monitoring
16. ✅ License
17. ✅ Authors

### Sections Omitted (7)
- ❌ Troubleshooting (no FAQ documented)
- ❌ Examples (no examples/ directory)
- ❌ Performance (no benchmarks)
- ❌ Security (no SECURITY.md)
- ❌ Support (no support channels)
- ❌ Related Projects (none documented)
- ❌ Changelog (no CHANGELOG.md)

---

## Generated README.md

[COMPLETE README CONTENT HERE - FULLY FORMATTED]

---

## Validation

- [x] All commands exist in repository (verified via grep/find)
- [x] All file paths referenced exist
- [x] No secrets or credentials exposed
- [x] No TODO or placeholder text
- [x] All links are valid (relative paths checked)
- [x] Markdown syntax validated
- [x] Language consistent (PT-BR throughout)
- [x] Badges generated only with verifiable data

**Status**: ✅ README ready to commit
```

---

## Examples (Few-Shot Learning)

### Example 1: Scrapy Project

**Repository scan results**:
- `scrapy.cfg` present
- Spiders in `src/spiders/`
- `requirements.txt` with scrapy, sqlalchemy
- `justfile` with commands: install, crawl, test
- `.env.example` with DATABASE_URL, USER_AGENT
- No tests/ directory

**Generated README includes**:
- Title: "E-Commerce Price Monitor"
- Description: Scrapy-based scraper for tracking product prices
- Quick Start: `just install && just crawl products`
- Features: Automatic retry, rate limiting, database storage
- Configuration: Table with DATABASE_URL, USER_AGENT, DOWNLOAD_DELAY
- Usage: `just crawl <spider-name>` with spider list
- Architecture: spiders/, items.py, pipelines/, settings.py
- **Omits**: Testing (no tests/), Deployment (no Docker)

---

### Example 2: FastAPI Service

**Repository scan results**:
- `main.py` with FastAPI app
- `pyproject.toml` with fastapi, uvicorn, sqlalchemy
- `Dockerfile` and `docker-compose.yml`
- `.env.example` with 15 variables
- `tests/` with pytest
- `.github/workflows/ci.yml`
- `k8s/` directory with manifests

**Generated README includes**:
- Title: "User Management API"
- Badges: Build status, coverage, license, Python 3.11+
- Description: RESTful API for user CRUD with JWT auth
- Quick Start: `docker-compose up`
- Features: JWT auth, PostgreSQL, async, OpenAPI docs
- API Usage: curl examples for /users endpoints
- Configuration: Table with all 15 env vars (required vs optional)
- Deployment: Docker + Kubernetes instructions
- Testing: `pytest` and coverage commands
- Architecture: app/, models/, routes/, schemas/

---

### Example 3: CLI Tool

**Repository scan results**:
- `cli.py` with click commands
- `pyproject.toml` with click, rich, pydantic
- No Dockerfile
- `.env.example` with API_KEY only
- `README.md` does NOT exist (confirmed)
- `tests/` with unit tests
- No deployment files

**Generated README includes**:
- Title: "Data Validator CLI"
- Description: Command-line tool for validating CSV/JSON data
- Quick Start: `pip install . && validator --help`
- Usage: Detailed command examples with all flags
- Configuration: API_KEY for external validation service
- Testing: `pytest` commands
- **Omits**: Deployment (no containers), Services (no background jobs)

---

## Anti-Patterns to Avoid

❌ **Generic placeholder**:
```markdown
## Installation
TODO: Add installation instructions
```

❌ **Assumed commands without evidence**:
```markdown
Run the application:
```bash
python app.py  # ← app.py doesn't exist!
```
```

❌ **Exposing secrets found in repo**:
```markdown
API_KEY=sk_live_abc123xyz  # ← Found in old commit, DO NOT INCLUDE
```

❌ **Inventing features not in code**:
```markdown
Features:
- Real-time notifications  # ← Not found in codebase
- Machine learning predictions  # ← No ML code exists
```

✅ **Evidence-based, accurate**:
```markdown
## Quick Start

```bash
# Clone repository
git clone https://github.com/user/repo.git
cd repo

# Create virtual environment (Python 3.11+)
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run setup (initializes config and database)
just setup

# Start application
just run
```

Access at: http://localhost:8000
API docs: http://localhost:8000/docs
```

---

## Validation Checklist

Before outputting README:

### Content Accuracy
- [ ] Every command verified in repo (scripts/, justfile, Makefile)
- [ ] Every file/directory reference exists
- [ ] CLI arguments match code (argparse/click definitions)
- [ ] API endpoints match routes in code
- [ ] Environment variables from .env.example or code
- [ ] Dependencies match requirements files

### Completeness
- [ ] Quick Start is actionable (< 5 min)
- [ ] Installation steps complete (nothing missing)
- [ ] Usage covers main use cases
- [ ] Configuration documents all required vars

### Security
- [ ] No secrets exposed (passwords, keys, tokens)
- [ ] Sensitive vars shown as placeholders: `<YOUR_API_KEY>`
- [ ] No credentials from git history

### Formatting
- [ ] Markdown syntax valid
- [ ] Code blocks have language specified
- [ ] Links are relative and valid
- [ ] Tables formatted correctly
- [ ] Heading hierarchy logical (H1 → H2 → H3)

### Quality
- [ ] Description is technical but accessible
- [ ] Features are specific and verifiable
- [ ] No marketing fluff or vague claims
- [ ] Language consistent (PT-BR or EN)
- [ ] No TODOs or placeholders

---

## Edge Cases

### Monorepo
If repository contains multiple projects:
1. Identify primary project (most code, entry point)
2. Note in README: "This is a monorepo containing X, Y, Z"
3. Link to sub-project READMEs if they exist
4. Focus main README on primary project or orchestration

### Legacy Code
If dependencies are outdated or deprecated:
1. Document actual versions found
2. Add note: "⚠️ Dependencies may be outdated"
3. Do not suggest updates (out of scope)

### No Entry Point
If no clear way to "run" the project:
1. Check if it's a library (installation only)
2. Check if it's infrastructure (deployment instructions)
3. Document what can be done (e.g., "Import as library")

### Minimal Project
If very simple (single file, no deps):
1. Simplify README accordingly
2. Omit unnecessary sections
3. Focus on Quick Start and basic Usage

---

## Final Instructions

1. Execute repository scan commands
2. Collect all evidence systematically
3. Classify project type
4. Apply decision matrix for sections
5. Generate README with verified information only
6. Validate all commands and references
7. Output analysis report + complete README
8. Ensure commit-ready (no TODOs, no assumptions)

---

**Reference**: `README_Standards_Reference.md` for detailed section formats and best practices.

**Philosophy**: Generate accurate, complete documentation based solely on what exists in the repository. No assumptions, no placeholders, no TODOs.
