# Just Script Best Practices Guide

> **Purpose**: Comprehensive guide to just script development following industry best practices.
> **Audience**: Developers writing production-ready justfiles.

---

## 1. Structure and Syntax

### File Organization

```just
# justfile for Project Name
# Description of what this justfile does
# Documentation: https://just.systems

# Configuration
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
[global variables here]

# Default recipe
default:
    @just --list

# Public recipes
[user-facing recipes]

# Helper recipes (prefixed with _)
[internal utilities]
```

### Naming Conventions

**Recipes**:
- Use lowercase with dashes: `build-frontend`, `test-integration`
- Use clear verb-noun format: `deploy-service`, `check-dependencies`
- Avoid abbreviations: Use `database` not `db` in recipe names

**Variables**:
- Use lowercase with underscores: `project_dir`, `database_url`
- Export variables needed by child processes: `export VAR := "value"`
- Use UPPERCASE for constants: `MAX_RETRIES := "3"`

**Helper Recipes**:
- Prefix with underscore: `_require`, `_validate-env`
- Not shown in `just --list` output
- Document their purpose clearly

### Suppressing Output

```just
# ❌ BAD - Noisy output
install:
    npm install

# ✅ GOOD - Clean output with @
install:
    @npm install

# ✅ GOOD - Selective suppression
install:
    @echo "Installing dependencies..."
    npm install
    @echo "✓ Installation complete"
```

---

## 2. Variables and Assignments

### Variable Types

```just
# Static variable (evaluated once)
project_dir := justfile_directory()

# Dynamic variable (evaluated on each use)
timestamp := `date +%Y%m%d_%H%M%S`

# Environment variable with default
export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/db")

# Boolean variable
debug_enabled := env_var_or_default("DEBUG", "false")
```

### Variable Expansion

```just
# ✅ GOOD - Always use {{var}}
build:
    npm run build --output={{build_dir}}

# ❌ BAD - Don't use $var (shell variable syntax)
build:
    npm run build --output=$build_dir  # Won't work as expected
```

### Global Variables

```just
# Place at top of file
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
export PORT := env_var_or_default("PORT", "3000")
export LOG_LEVEL := env_var_or_default("LOG_LEVEL", "info")

# Computed variables
timestamp := `date +%Y%m%d_%H%M%S`
git_sha := `git rev-parse --short HEAD`
version := env_var_or_default("VERSION", git_sha)
```

---

## 3. Recipes and Modularity

### Single Responsibility

```just
# ❌ BAD - Too many responsibilities
deploy:
    npm test
    npm run build
    docker build -t app .
    docker push app
    kubectl apply -f k8s/
    ./notify-slack.sh

# ✅ GOOD - Each recipe does one thing
test:
    npm test

build:
    npm run build

docker-build:
    docker build -t app .

docker-push:
    docker push app

k8s-deploy:
    kubectl apply -f k8s/

deploy: test build docker-build docker-push k8s-deploy
    just notify "Deployment complete"
```

### Documentation

```just
# ❌ BAD - No documentation
dr:
    docker-compose restart

# ✅ GOOD - Clear documentation
# Restart all Docker services
# Useful when docker-compose.yml changes
docker-restart:
    docker-compose down
    docker-compose up -d
```

### Recipe Dependencies

```just
# Sequential dependencies (run in order)
deploy: test build
    ./deploy.sh

# Parallel dependencies (can run concurrently)
all: (test) (lint) (type-check)

# Conditional dependencies
deploy: (_check-env "production") test build
    ./deploy.sh
```

### Line Continuation

```just
# ✅ GOOD - Break long commands
docker-build:
    docker build \
        --cache-from myapp:latest \
        --build-arg NODE_ENV=production \
        --build-arg VERSION={{version}} \
        --tag myapp:{{version}} \
        --tag myapp:latest \
        .
```

---

## 4. Error Handling

### Shell Script Header

```just
# ✅ REQUIRED for all multi-line recipes
recipe:
    #!/usr/bin/env bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures

    # Your commands here
```

**What each flag does**:
- `-e`: Exit immediately if any command fails
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Fail if any command in a pipeline fails

### Pre-condition Validation

```just
# Check file existence
process-file file:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "{{file}}" ]; then
        echo "Error: File '{{file}}' not found"
        exit 1
    fi

    ./process.sh "{{file}}"

# Check command availability
_require cmd:
    @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found"; exit 1)

# Use in recipes
deploy: (_require "docker") (_require "kubectl")
    ./deploy.sh
```

### Clear Error Messages

```just
# ✅ GOOD - Helpful error messages
validate-env environment:
    #!/usr/bin/env bash
    set -euo pipefail

    valid_envs=("dev" "staging" "production")

    if [[ ! " ${valid_envs[@]} " =~ " {{environment}} " ]]; then
        echo "Error: Invalid environment '{{environment}}'"
        echo "Valid environments: ${valid_envs[@]}"
        echo "Usage: just deploy <environment>"
        exit 1
    fi
```

### Dedicated Check Recipes

```just
# Create helper for common validations
_check-prereqs:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check commands
    command -v docker >/dev/null || (echo "docker not found"; exit 1)
    command -v kubectl >/dev/null || (echo "kubectl not found"; exit 1)

    # Check files
    [ -f ".env" ] || (echo ".env file missing"; exit 1)

    # Check permissions
    [ -w "/var/log/app" ] || (echo "Cannot write to /var/log/app"; exit 1)

    echo "✓ All prerequisites met"

# Use in critical recipes
deploy: _check-prereqs test build
    ./deploy.sh
```

---

## 5. Execution and Permissions

### Privilege Management

```just
# ❌ BAD - Blindly using sudo
install:
    sudo apt-get install postgresql

# ✅ GOOD - Check if root, provide guidance
install-system-deps:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "$EUID" -eq 0 ]; then
        apt-get update
        apt-get install -y postgresql-client
    else
        echo "Error: This recipe must be run as root"
        echo "Run: sudo -E just install-system-deps"
        exit 1
    fi

# ✅ GOOD - Document privilege requirements
# Install system dependencies (requires root)
# Run with: sudo -E just install-system-deps
install-system-deps:
    apt-get update
    apt-get install -y postgresql-client redis-tools
```

### Syntax Validation

```bash
# Always validate before committing
just --check

# Show all recipes
just --list

# Dry run (show commands without executing)
just --dry-run recipe-name
```

---

## 6. File Operations

### Existence Checks

```just
# ✅ GOOD - Check before operations
copy-file src dest:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check source exists
    if [ ! -f "{{src}}" ]; then
        echo "Error: Source file '{{src}}' not found"
        exit 1
    fi

    # Check destination directory exists
    dest_dir=$(dirname "{{dest}}")
    if [ ! -d "$dest_dir" ]; then
        echo "Error: Destination directory '$dest_dir' not found"
        exit 1
    fi

    cp "{{src}}" "{{dest}}"
```

### Avoid Redundant Operations

```just
# ✅ GOOD - Only copy if different
copy-config src dest:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -f "{{dest}}" ] && cmp -s "{{src}}" "{{dest}}"; then
        echo "File {{dest}} is already up to date"
        exit 0
    fi

    cp "{{src}}" "{{dest}}"
    echo "✓ Copied {{src}} to {{dest}}"
```

### Set Permissions Explicitly

```just
# ✅ GOOD - Explicit permissions
deploy-config:
    #!/usr/bin/env bash
    set -euo pipefail

    # Copy config
    cp config/app.conf /etc/app/app.conf

    # Set ownership and permissions
    chown app:app /etc/app/app.conf
    chmod 640 /etc/app/app.conf

    echo "✓ Config deployed with permissions 640"
```

---

## 7. Integration with External Tools

### Systemd Integration

```just
# ✅ GOOD - Check before acting
start-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    if systemctl is-active "{{service}}" >/dev/null 2>&1; then
        echo "Service {{service}} is already active"
    else
        systemctl start "{{service}}"
        echo "✓ Service {{service}} started"
    fi

# Enable service at boot
enable-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    if systemctl is-enabled "{{service}}" >/dev/null 2>&1; then
        echo "Service {{service}} is already enabled"
    else
        systemctl enable "{{service}}"
        echo "✓ Service {{service}} enabled"
    fi

# Reload daemon after changes
reload-systemd:
    systemctl daemon-reload
```

### Docker Integration

```just
# Check Docker is running
_check-docker:
    @docker info >/dev/null 2>&1 || (echo "Docker is not running"; exit 1)

# Build with checks
docker-build: _check-docker
    #!/usr/bin/env bash
    set -euo pipefail

    docker build \
        --cache-from myapp:latest \
        --tag myapp:{{version}} \
        --tag myapp:latest \
        .

    echo "✓ Image built: myapp:{{version}}"
```

### Kubernetes Integration

```just
# Deploy to Kubernetes
k8s-deploy namespace:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate kubectl available
    command -v kubectl >/dev/null || (echo "kubectl not found"; exit 1)

    # Validate namespace exists
    if ! kubectl get namespace "{{namespace}}" >/dev/null 2>&1; then
        echo "Error: Namespace '{{namespace}}' does not exist"
        exit 1
    fi

    # Apply configurations
    kubectl apply -f k8s/ --namespace={{namespace}}

    # Wait for rollout
    kubectl rollout status deployment/app --namespace={{namespace}}

    echo "✓ Deployed to {{namespace}}"
```

---

## 8. General Best Practices

### Keep Recipes Independent

```just
# ✅ GOOD - Recipes can run independently
test:
    npm test

build:
    npm run build

# Each recipe is self-contained
```

### Use `just --list` During Development

```bash
# See all available recipes
just --list

# Use in default recipe
default:
    @just --list
```

### Support Verbose Mode

```just
export VERBOSE := env_var_or_default("VERBOSE", "false")

build:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "{{VERBOSE}}" = "true" ]; then
        echo "Building with verbose output..."
        npm run build --verbose
    else
        npm run build
    fi
```

### Load Environment Variables

```just
# Enable automatic .env loading
set dotenv-load := true

# Variables will be available from .env file
deploy:
    @echo "Deploying to $ENVIRONMENT"
    ./deploy.sh
```

---

## 9. Security and Reliability

### Input Validation

```just
# ✅ GOOD - Validate parameters
scale replicas:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate numeric input
    if ! [[ "{{replicas}}" =~ ^[0-9]+$ ]]; then
        echo "Error: Replicas must be a number"
        exit 1
    fi

    # Validate range
    if [ {{replicas}} -lt 1 ] || [ {{replicas}} -gt 10 ]; then
        echo "Error: Replicas must be between 1 and 10"
        exit 1
    fi

    kubectl scale deployment app --replicas={{replicas}}
```

### Protect Sensitive Files

```just
# Create credential file with proper permissions
setup-credentials:
    #!/usr/bin/env bash
    set -euo pipefail

    cred_file=".credentials"

    # Create file
    cat > "$cred_file" << EOF
API_KEY=${API_KEY}
DB_PASSWORD=${DB_PASSWORD}
EOF

    # Set restrictive permissions
    chmod 600 "$cred_file"

    echo "✓ Credentials saved with permissions 600"
```

### Test in Controlled Environment

```just
# Test recipe in isolated environment
test-isolated:
    docker run --rm \
        -v $(pwd):/app \
        -w /app \
        ubuntu:22.04 \
        bash -c "apt-get update && apt-get install -y just && just test"
```

### Avoid Dangerous Commands

```just
# ❌ BAD - No confirmation
clean-all:
    rm -rf /

# ✅ GOOD - Require confirmation
clean-all:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "⚠️  WARNING: This will delete all data"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted"
        exit 1
    fi

    rm -rf dist/ node_modules/ .cache/
```

---

## 10. Shell Integration

### Use Bash for Complex Recipes

```just
# Set bash as default shell
set shell := ["bash", "-c"]

# Complex recipe with bash features
process-files:
    #!/usr/bin/env bash
    set -euo pipefail

    # Arrays
    files=("file1.txt" "file2.txt" "file3.txt")

    # Loops
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "Processing $file..."
            ./process.sh "$file"
        fi
    done
```

### Combine with Shell Best Practices

```just
recipe:
    #!/usr/bin/env bash
    set -euo pipefail  # Strict error handling

    # Quote variables
    file_path="/path with spaces/file.txt"
    cat "$file_path"

    # Check exit codes
    if ! command_that_might_fail; then
        echo "Command failed"
        exit 1
    fi
```

### Avoid Unnecessary Subshells

```just
# ❌ BAD - Unnecessary subshell
get-version:
    @echo $(cat VERSION)

# ✅ GOOD - Direct command
get-version:
    @cat VERSION
```

---

## Quick Reference Table

| Aspect | Best Practice |
|--------|---------------|
| **Comments** | Use `#` to document recipes and variables |
| **Variables** | Clear names, lowercase_with_underscores, use `{{var}}` |
| **Recipes** | Small, single responsibility, clear verb-noun names |
| **Dependencies** | Declare explicitly with `recipe: dep1 dep2` |
| **Error Handling** | Use `set -euo pipefail` in multi-line recipes |
| **Permissions** | Check and set with `chmod`/`chown`, validate with `[ -r file ]` |
| **Systemd** | Use `systemctl is-active`/`is-enabled` before acting |
| **Docker** | Check daemon with `docker info`, validate images before use |
| **Logging** | Redirect to logs with timestamps, support verbose mode |
| **Debugging** | Support `VERBOSE` variable, use `--dry-run` for testing |
| **Security** | Validate inputs, protect credentials, require confirmation for destructive ops |

---

## Complete Example

```just
# justfile for Production Application
# Manages build, test, and deployment workflows
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/app")
export VERBOSE := env_var_or_default("VERBOSE", "false")

project_dir := justfile_directory()
timestamp := `date +%Y%m%d_%H%M%S`
version := env_var_or_default("VERSION", `git rev-parse --short HEAD`)

# Default recipe
default:
    @just --list

# Install dependencies
install:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi

    echo "✓ Dependencies installed"

# Run tests
test:
    #!/usr/bin/env bash
    set -euo pipefail

    npm test

    echo "✓ All tests passed"

# Build for production
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building version {{version}}..."

    NODE_ENV=production npm run build

    echo "✓ Build complete"

# Deploy to environment
deploy env: (_validate-env env) test build
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Deploying {{version}} to {{env}}..."

    ./scripts/deploy.sh "{{env}}" "{{version}}"

    echo "✓ Deployed to {{env}}"

# Helper: Validate environment
_validate-env env:
    #!/usr/bin/env bash
    set -euo pipefail

    valid_envs=("dev" "staging" "production")

    if [[ ! " ${valid_envs[@]} " =~ " {{env}} " ]]; then
        echo "Error: Invalid environment '{{env}}'"
        echo "Valid environments: ${valid_envs[@]}"
        exit 1
    fi

# Helper: Check if command exists
_require cmd:
    @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found"; exit 1)
```

---

**Last Updated**: 2025-12-11
