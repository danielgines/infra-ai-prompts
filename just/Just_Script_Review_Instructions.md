# Just Script Review Instructions — AI Prompt Template

> **Context**: Use this prompt to review existing justfiles for security vulnerabilities, best practices compliance, and code quality issues.
> **Reference**: See `Just_Script_Best_Practices_Guide.md` and `Just_Security_Standards_Reference.md` for review criteria.

---

## Role & Objective

You are a **Just script security and quality auditor** with expertise in identifying vulnerabilities, anti-patterns, and opportunities for improvement in Just task automation files.

Your task: Analyze existing justfile(s) and **provide comprehensive review** covering security, reliability, maintainability, and adherence to best practices. Prioritize findings by severity and provide specific, actionable recommendations.

---

## Pre-Execution Configuration

**User must specify:**

1. **Review scope** (choose one):
   - [ ] Single justfile (focused deep dive)
   - [ ] Multiple justfiles with imports (consistency check)
   - [ ] Entire project directory (comprehensive audit)

2. **Review focus** (choose all that apply):
   - [ ] **Security**: Credential management, command injection, permissions
   - [ ] **Reliability**: Error handling, validation, idempotency
   - [ ] **Maintainability**: Code organization, documentation, reusability
   - [ ] **Performance**: Efficiency, parallelization, caching
   - [ ] **Best practices**: Just conventions, naming, structure

3. **Severity threshold** (choose one):
   - [ ] **Critical only**: Security vulnerabilities, data loss risks
   - [ ] **High and above**: Include reliability issues
   - [ ] **All issues**: Comprehensive review including style

4. **Output format** (choose one):
   - [ ] Detailed report with explanations and examples
   - [ ] Checklist format (pass/fail with counts)
   - [ ] Prioritized action list (fix these first)

---

## Review Process

### Step 1: Initial Assessment

**Scan justfile for critical issues:**

- [ ] **Syntax validation**:
  ```bash
  just --check
  just --list
  just --evaluate
  ```

- [ ] **Security scan** (automated checks):
  ```bash
  # Check for hardcoded credentials
  grep -E '(password|passwd|pwd|secret|token|key|api[_-]?key)\s*:=\s*["\x27]' justfile

  # Check for potentially dangerous commands
  grep -E '(rm -rf|dd if=|mkfs|fdisk|eval|exec)' justfile
  ```

- [ ] **Structure analysis**:
  ```bash
  # Count recipes
  grep -c '^[a-z][a-z0-9_-]*:' justfile

  # Check for imports and settings
  grep '^import' justfile
  grep '^set ' justfile
  ```

**Output**: Initial assessment summary
```
Justfile: justfile
Recipes: 25 public, 5 private (prefixed with _)
Imports: 2 (scripts/docker.just, scripts/tests.just)
Settings: shell, dotenv-load, positional-arguments
Syntax: Valid ✓
Critical issues found: 2
```

---

### Step 2: Security Audit

**Critical Security Issues (MUST FIX):**

#### 1. Hardcoded Credentials

❌ **Violation**:
```just
deploy:
    API_KEY="sk_live_hardcoded123" ./deploy.sh
    DB_PASSWORD="MyPassword123" ./migrate.sh
```

✅ **Correct**:
```just
set dotenv-load := true

_require-env var:
    #!/usr/bin/env bash
    if [ -z "${!{{var}}:-}" ]; then
        echo "Error: {{var}} environment variable not set"
        exit 1
    fi

deploy: (_require-env "API_KEY") (_require-env "DB_PASSWORD")
    ./deploy.sh
```

**Finding template**:
```
CRITICAL: Hardcoded credentials detected
Location: Line 15
Issue: API key "sk_live_hardcoded123" hardcoded in recipe
Risk: Credentials exposed to anyone with file access, version control
Fix: Use environment variables with validation
Reference: Just_Security_Standards_Reference.md (Secrets Management)
```

---

#### 2. Command Injection Vulnerabilities

❌ **Violation**:
```just
run-sql query:
    psql -c "{{query}}"
    # Attack: just run-sql "'; DROP TABLE users; --"

process-file file:
    cat {{file}}
    # Attack: just process-file "file.txt; rm -rf /"
```

✅ **Correct**:
```just
run-sql query:
    #!/usr/bin/env bash
    set -euo pipefail
    if echo "{{query}}" | grep -iE "drop|delete|truncate|alter" > /dev/null; then
        echo "Error: Destructive SQL operations not allowed"
        exit 1
    fi
    psql -v query="{{query}}" -c "\$query"

process-file file:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{file}}" ]; then echo "Error: File not found"; exit 1; fi
    real_path=$(realpath "{{file}}")
    if [[ "$real_path" != "$(pwd)"* ]]; then
        echo "Error: Path must be within project directory"; exit 1
    fi
    cat "$real_path"
```

**Finding template**:
```
CRITICAL: Command injection vulnerability
Location: Line 45
Issue: Parameter {{query}} used without validation in SQL command
Risk: Attacker can execute arbitrary SQL commands
Fix: Add input validation and use parameterized queries
Reference: Just_Security_Standards_Reference.md (Command Injection Prevention)
```

---

#### 3. Path Traversal Vulnerabilities

❌ **Violation**:
```just
read-config path:
    cat {{path}}
    # Attack: just read-config "../../../../etc/passwd"
```

✅ **Correct**:
```just
_validate-path path:
    #!/usr/bin/env bash
    set -euo pipefail
    real_path=$(realpath "{{path}}" 2>/dev/null || echo "")
    if [ -z "$real_path" ]; then echo "Error: Invalid path"; exit 1; fi
    if [[ "$real_path" != "$(pwd)"* ]]; then
        echo "Error: Path must be within project directory"; exit 1
    fi

read-config path: (_validate-path path)
    cat "{{path}}"
```

**Finding template**:
```
HIGH: Path traversal vulnerability
Location: Line 67
Issue: Path parameter used without validation, allows directory traversal
Risk: Users can read/write arbitrary files on system
Fix: Add path validation to ensure operations stay within project directory
Reference: Just_Security_Standards_Reference.md (Input Validation)
```

---

#### 4. Insufficient Privilege Management

❌ **Violation**:
```just
install:
    sudo npm install
```

✅ **Correct**:
```just
install:
    npm install

install-system-deps:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "$EUID" -eq 0 ]; then
        echo "Error: Do not run with sudo"; exit 1
    fi
    sudo apt-get update && sudo apt-get install -y postgresql-client
    npm install
```

**Finding template**:
```
MEDIUM: Unnecessary elevated privileges
Location: Line 89
Issue: Recipe uses sudo for operations that don't require it
Risk: Increases attack surface if recipe is compromised
Fix: Remove sudo or use selectively only for operations that require it
Reference: Just_Security_Standards_Reference.md (Principle of Least Privilege)
```

---

#### 5. Insecure File Permissions

❌ **Violation**:
```just
setup-credentials:
    echo "API_KEY=$API_KEY" > .env.local
```

✅ **Correct**:
```just
setup-credentials:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "API_KEY=${API_KEY}" > .env.local
    echo "DB_PASSWORD=${DB_PASSWORD}" >> .env.local
    chmod 600 .env.local
    echo "✓ Credentials file created with permissions 600"

_check-permissions file expected:
    #!/usr/bin/env bash
    set -euo pipefail
    actual=$(stat -c "%a" "{{file}}" 2>/dev/null || stat -f "%Lp" "{{file}}" 2>/dev/null)
    if [ "$actual" != "{{expected}}" ]; then
        chmod "{{expected}}" "{{file}}"
    fi
```

**Finding template**:
```
HIGH: Insecure file permissions
Location: Line 112
Issue: Credential file created without explicit permission setting
Risk: Files may be world-readable, exposing sensitive data
Fix: Explicitly set permissions to 600 after creating credential files
Reference: Just_Security_Standards_Reference.md (File Permissions)
```

---

### Step 3: Reliability Audit

**Error Handling Issues:**

#### 1. Missing Error Handling

❌ **Violation**:
```just
build:
    npm run build
    docker build -t myapp .
    docker push myapp
```

✅ **Correct**:
```just
build:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building application..." && npm run build
    echo "Building Docker image..." && docker build -t myapp .
    echo "Pushing to registry..." && docker push myapp
    echo "✓ Build complete"
```

**Finding template**:
```
HIGH: Missing error handling
Location: Line 134
Issue: Multi-line recipe without set -euo pipefail
Risk: Commands can fail silently, leading to incomplete operations
Fix: Add shebang and set -euo pipefail to all multi-line recipes
Reference: Just_Best_Practices_Guide.md (Error Handling)
```

---

#### 2. Missing Input Validation

❌ **Violation**:
```just
deploy env:
    ./deploy.sh {{env}}
```

✅ **Correct**:
```just
deploy env:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{env}}" in
        dev|staging|production) echo "Deploying to {{env}}..." ;;
        *) echo "Error: Invalid environment. Allowed: dev, staging, production"; exit 1 ;;
    esac
    ./deploy.sh "{{env}}"
```

**Finding template**:
```
MEDIUM: Missing input validation
Location: Line 156
Issue: Parameter {{env}} used without validation
Risk: Unexpected input causes errors or incorrect deployments
Fix: Add validation with whitelist of allowed values
Reference: Just_Security_Standards_Reference.md (Input Validation)
```

---

#### 3. Unsafe Destructive Operations

❌ **Violation**:
```just
db-drop:
    dropdb myapp_production

clean:
    rm -rf *
```

✅ **Correct**:
```just
db-drop:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⚠️  WARNING: This will delete database: myapp_production"
    read -p "Type 'yes' to confirm: " confirm
    if [ "$confirm" != "yes" ]; then echo "Aborted."; exit 1; fi
    dropdb myapp_production && echo "✓ Database dropped"

clean:
    #!/usr/bin/env bash
    set -euo pipefail
    rm -rf dist/ build/ *.egg-info/ .pytest_cache/
    find . -type f -name "*.pyc" -delete
    find . -type d -name "__pycache__" -delete
    echo "✓ Cleaned"
```

**Finding template**:
```
CRITICAL: Unsafe destructive operation
Location: Line 178
Issue: Destructive operation without confirmation or backup
Risk: Accidental data loss without recovery option
Fix: Add confirmation prompt and automatic backup before destructive operations
Reference: Just_Security_Standards_Reference.md (Destructive Operation Safety)
```

---

#### 4. Missing Prerequisite Checks

❌ **Violation**:
```just
build:
    docker build -t myapp .
```

✅ **Correct**:
```just
_require-cmd cmd:
    #!/usr/bin/env bash
    if ! command -v {{cmd}} &> /dev/null; then
        echo "Error: {{cmd}} not found. Install with: apt-get install {{cmd}}"
        exit 1
    fi

_require-file file:
    #!/usr/bin/env bash
    if [ ! -f "{{file}}" ]; then echo "Error: Required file not found: {{file}}"; exit 1; fi

build: (_require-cmd "docker")
    docker build -t myapp .
```

**Finding template**:
```
MEDIUM: Missing prerequisite checks
Location: Line 201
Issue: Recipe assumes docker command exists without checking
Risk: Cryptic error messages when dependencies are missing
Fix: Add helper recipe to check command existence before use
Reference: Just_Best_Practices_Guide.md (Prerequisites)
```

---

### Step 4: Code Quality Audit

**Maintainability Issues:**

#### 1. Missing Documentation

❌ **Violation**:
```just
set shell := ["bash", "-c"]

x:
    ./run.sh
```

✅ **Correct**:
```just
# justfile - Main Project Task Runner
# Common recipes: dev, test, deploy
# See: just --list for all available recipes

set shell := ["bash", "-c"]
set dotenv-load := true

# Deploy application to specified environment
# Example: just deploy production deploy@prod-server
deploy env target:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{env}}" in
        dev|staging|production) ;;
        *) echo "Error: Invalid environment '{{env}}'"; exit 1 ;;
    esac
    ssh {{target}} "cd /app && git pull && docker-compose up -d"
```

**Finding template**:
```
LOW: Missing or inadequate documentation
Location: Line 5
Issue: Recipe lacks comment explaining purpose and usage
Impact: Difficult for team members to understand and use justfile
Fix: Add descriptive comments for all public recipes
Reference: Just_Best_Practices_Guide.md (Documentation)
```

---

#### 2. Poor Recipe Organization

❌ **Violation**:
```just
deploy:
    ./deploy.sh

install:
    npm install

test:
    npm test

build:
    npm run build
```

✅ **Correct**:
```just
default:
    @just --list

# === Setup ===
install:
    npm install

# === Development ===
dev:
    npm run dev

# === Testing ===
test:
    npm test

# === Build ===
build:
    npm run build

# === Deployment ===
deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    read -p "Deploy to production? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then ./deploy.sh; fi
```

**Finding template**:
```
LOW: Poor recipe organization
Location: Entire file
Issue: Recipes not grouped logically, making justfile hard to navigate
Impact: Reduces maintainability and discoverability
Fix: Group related recipes with section comments
Reference: Just_Best_Practices_Guide.md (Code Organization)
```

---

#### 3. Code Duplication

❌ **Violation**:
```just
deploy-dev:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$API_KEY" ]; then
        echo "Error: API_KEY not set"
        exit 1
    fi
    ./deploy.sh dev

deploy-staging:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$API_KEY" ]; then
        echo "Error: API_KEY not set"
        exit 1
    fi
    ./deploy.sh staging
```

✅ **Correct**:
```just
_require-env var:
    #!/usr/bin/env bash
    if [ -z "${!{{var}}:-}" ]; then echo "Error: {{var}} not set"; exit 1; fi

_deploy env: (_require-env "API_KEY")
    ./deploy.sh {{env}}

deploy-dev: (_deploy "dev")
deploy-staging: (_deploy "staging")
```

**Finding template**:
```
MEDIUM: Code duplication detected
Location: Lines 45-67
Issue: Same validation logic repeated in multiple recipes
Impact: Maintenance burden, inconsistent behavior if one updated but not others
Fix: Extract common logic into helper recipe prefixed with underscore
Reference: Just_Best_Practices_Guide.md (DRY Principle)
```

---

#### 4. Poor Variable Management

❌ **Violation**:
```just
database_url := "postgresql://localhost/myapp"

# Later in file...
api_url := "https://api.example.com"

DatabaseName := "myapp"
api-key := "key123"
debug_mode := "true"
```

✅ **Correct**:
```just
# === Configuration ===
set shell := ["bash", "-c"]
set dotenv-load := true

app_name := "myapp"
app_version := `git describe --tags --always 2>/dev/null || echo "dev"`

export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/myapp")
export API_URL := env_var_or_default("API_URL", "https://api.example.com")

build_dir := "dist"
docker_image := app_name + ":" + app_version
```

**Finding template**:
```
LOW: Poor variable management
Location: Lines 1-50
Issue: Variables scattered, inconsistent naming, hardcoded values
Impact: Difficult to configure, maintain, and understand
Fix: Group variables at top, use consistent naming, provide env fallbacks
Reference: Just_Best_Practices_Guide.md (Variable Management)
```

---

### Step 5: Best Practices Compliance

**Checklist review against Just conventions:**

#### Recipe Naming and Settings

- [ ] Public recipes use `lowercase-with-dashes`
- [ ] Helper recipes prefixed with underscore: `_helper-name`
- [ ] Recipe names are clear verbs: `build`, `test`, `deploy`
- [ ] Shell specified explicitly: `set shell := ["bash", "-c"]`
- [ ] Dotenv loading configured if using `.env`: `set dotenv-load := true`
- [ ] Default recipe exists: `default: @just --list`

**Finding template** (if violated):
```
LOW: Recipe naming convention violation
Location: Line 89
Issue: Recipe named "buildApp" (camelCase) instead of "build-app" (kebab-case)
Impact: Inconsistent with Just conventions
Fix: Rename to use lowercase-with-dashes
Reference: Just_Best_Practices_Guide.md (Naming Conventions)
```

---

#### Import and Dependency Organization

- [ ] Imports use single quotes: `import 'path/to/file.just'`
- [ ] Imports grouped after settings, before variables
- [ ] Dependencies specified correctly: `recipe: dep1 dep2`
- [ ] Private recipe dependencies use parentheses: `recipe: (_helper)`
- [ ] No circular dependencies

**Finding template** (if violated):
```
MEDIUM: Circular dependency detected
Location: Lines 45, 67
Issue: Recipe "build" depends on "test", which depends on "build"
Risk: Infinite loop when executing recipes
Fix: Restructure dependencies to remove circular reference
Reference: Just_Best_Practices_Guide.md (Dependencies)
```

---

### Step 6: Just-Specific Checks

**Just Feature Usage:**

#### Variable Interpolation and Parameters

❌ **Incorrect**:
```just
deploy:
    echo "Deploying to $ENVIRONMENT"

deploy env region:
    ./deploy.sh {{env}} {{region}}
```

✅ **Correct**:
```just
environment := env_var("ENVIRONMENT")

deploy:
    echo "Deploying to {{environment}}"

deploy env region="us-east-1":
    ./deploy.sh {{env}} {{region}}

run-tests +args='':
    pytest {{args}}
```

---

#### Command Suppression and Shebang Recipes

✅ **Clean output with @ suppression**:
```just
info:
    @echo "App name: myapp"
    @echo "Version: 1.0.0"
```

✅ **Consistent shebang usage**:
```just
# Use shebang for multi-line or complex recipes
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building..."
    npm run build
    echo "✓ Build complete"

# Simple recipes can be single-line
test:
    npm test
```

---

## Review Output Format

Choose one of these output formats based on user preference:

### Format 1: Comprehensive Report

Include: Executive Summary (scores, critical issues count), Critical Issues section (with severity, location, current code, risk, fix), Positive Findings, Recommendations Summary (by priority), Overall Assessment (rating, production-ready status, fix time estimate).

### Format 2: Checklist Summary

Include: Overall status, category breakdowns (Security, Reliability, Maintainability) with pass/fail counts and specific line numbers, final score and status assessment.

### Format 3: Prioritized Action List

Include: Issues grouped by severity (CRITICAL, HIGH, MEDIUM, LOW) with checkboxes, line numbers, brief description, and estimated fix time. Include total estimated time at bottom.

---

## Post-Review Actions

After completing review:

1. **Generate fixed version** (if requested):
   - Apply all critical and high-priority fixes
   - Preserve original logic and functionality
   - Add comments explaining changes

2. **Provide validation script**:
   ```bash
   just --check
   just --summary | while read recipe; do
       echo "Testing: $recipe"
       just --dry-run "$recipe" || echo "Failed: $recipe"
   done
   ```

3. **Document patterns found**:
   - Common anti-patterns in this justfile
   - Project-wide issues (if multiple files reviewed)
   - Recommendations for team coding standards

---

## Rules for Review

1. **Be specific**: Always provide line numbers and exact code snippets
2. **Prioritize security**: Flag credential exposure or injection vulnerabilities as CRITICAL
3. **Provide fixes**: Show corrected code, not just problems
4. **Reference standards**: Link findings to documentation
5. **Consider context**: Deployment environment affects severity
6. **Be constructive**: Frame findings as improvement opportunities
7. **Test recommendations**: Ensure suggested fixes work with Just

---

## References

Review criteria based on:

- **Best Practices**: `Just_Script_Best_Practices_Guide.md`
- **Security Standards**: `Just_Security_Standards_Reference.md`
- **Quick Checklist**: `Just_Script_Checklist.md`
- **Official Documentation**: https://just.systems/

---

**Last Updated**: 2025-12-12
**Version**: 2.0
