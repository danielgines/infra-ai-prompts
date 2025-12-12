# Makefile to Justfile Migration Guide

> **Purpose**: Guide the migration from Makefile to Justfile following best practices.
> **Audience**: Developers migrating existing Make-based workflows to Just.

This guide provides a systematic approach to migrating a `Makefile` to a `justfile`, incorporating lessons learned from common issues such as compound commands, output formatting, and best practices from both `just` (https://just.systems/man/en/introduction.html) and shell scripting.

---

## 1. Migration Planning

- **Analyze the Makefile**: Identify variables, targets, dependencies, functions, and compound commands (e.g., `make service action`).
- **Map functionality**: Convert targets to recipes and compound commands to parameterized recipes.
- **Preserve semantics**: Maintain the logic and behavior of the `Makefile`, adapting to Just syntax.
- **Prioritize key commands**: Focus on targets like `help`, `default`, and critical workflows (e.g., `start`, `stop`).

---

## 2. Structure and Syntax

### File Header

```just
# justfile for Project Name
# Documentation: https://just.systems
```

### Settings

```just
# Configuration
set shell := ["bash", "-c"]
set dotenv-load := true
```

### Error Handling

```just
# All multi-line recipes should use this header
recipe:
    #!/usr/bin/env bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures

    # Your commands here
```

### Default Recipe

```just
# Show available commands when running `just` without args
default:
    @just --list
```

---

## 3. Variable Conversion

### From Makefile to Just

**Makefile**:
```make
VAR = value
VAR2 := static value
```

**Justfile**:
```just
# Dynamic variable (evaluated on use)
var := `pwd`

# Static variable
var2 := "value"

# Environment variable with default
export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/db")
```

### Naming Conventions

- Use lowercase with underscores: `project_dir`, `config_dir`
- Export variables needed by child processes: `export VAR := "value"`
- Document each variable with a comment

### Variable Expansion

Always use `{{var}}` syntax for variable expansion:

```just
build_dir := "dist"

clean:
    rm -rf {{build_dir}}
```

---

## 4. Target to Recipe Conversion

### Simple Targets

**Makefile**:
```make
.PHONY: build
build:
	npm run build
```

**Justfile**:
```just
# Build for production
build:
    npm run build
```

### Targets with Dependencies

**Makefile**:
```make
.PHONY: deploy
deploy: test build
	./deploy.sh
```

**Justfile**:
```just
# Deploy to production
deploy: test build
    ./deploy.sh
```

### Compound Commands

**Makefile**:
```make
.PHONY: service
service:
	@if [ "$(ACTION)" = "start" ]; then \
		systemctl start $(NAME); \
	elif [ "$(ACTION)" = "stop" ]; then \
		systemctl stop $(NAME); \
	fi
```

**Justfile**:
```just
# Manage service (start/stop/restart)
service name action:
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{action}}" in
        start)
            systemctl start "{{name}}"
            ;;
        stop)
            systemctl stop "{{name}}"
            ;;
        restart)
            systemctl restart "{{name}}"
            ;;
        *)
            echo "Error: Invalid action '{{action}}'"
            echo "Usage: just service <name> <start|stop|restart>"
            exit 1
            ;;
    esac
```

---

## 5. Function and Conditional Logic Conversion

### Makefile Functions

**Makefile**:
```make
check-service = $(shell systemctl is-active $(1))

service-status:
	@echo "Service status: $(call check-service,myservice)"
```

**Justfile**:
```just
# Check service status
service-status name:
    #!/usr/bin/env bash
    set -euo pipefail

    if systemctl is-active "{{name}}" >/dev/null 2>&1; then
        echo "Service {{name}} is active"
    else
        echo "Service {{name}} is inactive"
    fi
```

### Reusable Validation

Create helper recipes for common validations:

```just
# Validate service name
_validate-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    valid_services=("web" "api" "worker")

    if [[ ! " ${valid_services[@]} " =~ " {{service}} " ]]; then
        echo "Error: Invalid service '{{service}}'"
        echo "Valid services: ${valid_services[@]}"
        exit 1
    fi

# Use in public recipes
start-service service: (_validate-service service)
    systemctl start "{{service}}"
```

---

## 6. Error Handling

### Prerequisites Checking

```just
# Check if command exists
_require cmd:
    @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found"; exit 1)

# Use in recipes
deploy: (_require "docker") (_require "aws")
    ./deploy.sh
```

### File Validation

```just
# Check if file exists before processing
process-file file:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "{{file}}" ]; then
        echo "Error: File '{{file}}' not found"
        exit 1
    fi

    ./process.sh "{{file}}"
```

### Error Messages

Always include:
- Timestamp
- Clear description of error
- Suggested fix or usage example

```just
validate-env environment:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{environment}}" != "dev" ]] && [[ "{{environment}}" != "staging" ]] && [[ "{{environment}}" != "production" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Invalid environment '{{environment}}'"
        echo "Valid environments: dev, staging, production"
        echo "Usage: just deploy <environment>"
        exit 1
    fi
```

---

## 7. Permission Management

### Checking Privileges

```just
# Check if running as root
_check-root:
    #!/usr/bin/env bash
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This recipe must be run as root"
        exit 1
    fi

# Use when needed
install-system-deps: _check-root
    apt-get update
    apt-get install -y postgresql-client
```

### Setting Permissions

```just
# Copy config with proper permissions
deploy-config:
    #!/usr/bin/env bash
    set -euo pipefail

    cp config/app.conf /etc/app/app.conf
    chmod 644 /etc/app/app.conf
    chown root:root /etc/app/app.conf

    echo "✓ Config deployed with permissions 644"
```

---

## 8. File Operations

### Checking Before Overwriting

```just
# Copy only if different
copy-config src dest:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -f "{{dest}}" ] && cmp -s "{{src}}" "{{dest}}"; then
        echo "File {{dest}} is already up to date"
        exit 0
    fi

    cp "{{src}}" "{{dest}}"
    chmod 644 "{{dest}}"

    echo "✓ Copied {{src}} to {{dest}}"
```

### Backup Before Destructive Operations

```just
# Backup before replacing
update-config:
    #!/usr/bin/env bash
    set -euo pipefail

    config_file="/etc/app/config.ini"

    if [ -f "$config_file" ]; then
        backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        echo "Backup created: $backup_file"
    fi

    cp new-config.ini "$config_file"
```

---

## 9. Systemd and Kubernetes Integration

### Systemd Operations

```just
# Start service (idempotent)
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

# Reload daemon after unit file changes
reload-daemon:
    systemctl daemon-reload
```

### Kubernetes Operations

```just
# Deploy to Kubernetes
k8s-deploy namespace:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate kubectl is available
    command -v kubectl >/dev/null || (echo "kubectl not found"; exit 1)

    # Apply configurations
    kubectl apply -f k8s/ --namespace={{namespace}}

    # Wait for rollout
    kubectl rollout status deployment/app --namespace={{namespace}}

    echo "✓ Deployed to namespace {{namespace}}"
```

---

## 10. Logging and Output

### Structured Logging

```just
export VERBOSE := env_var_or_default("VERBOSE", "false")

# Build with logging
build:
    #!/usr/bin/env bash
    set -euo pipefail

    log_file="logs/build_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p logs

    if [ "{{VERBOSE}}" = "true" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting build" | tee -a "$log_file"
        npm run build 2>&1 | tee -a "$log_file"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting build" >> "$log_file"
        npm run build >> "$log_file" 2>&1
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Build complete" | tee -a "$log_file"
```

### Colored Output

Use `tput` for portable colors:

```just
# Success message with color
_success message:
    @echo "$(tput setaf 2)✓ {{message}}$(tput sgr0)"

# Error message with color
_error message:
    @echo "$(tput setaf 1)✗ {{message}}$(tput sgr0)" >&2

# Use in recipes
deploy:
    just _success "Deployment started"
    ./deploy.sh
    just _success "Deployment complete"
```

---

## 11. Argument Handling

### Parameterized Recipes

```just
# Scale deployment
scale replicas:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate numeric input
    if ! [[ "{{replicas}}" =~ ^[0-9]+$ ]]; then
        echo "Error: Replicas must be a number"
        exit 1
    fi

    kubectl scale deployment app --replicas={{replicas}}
    echo "✓ Scaled to {{replicas}} replicas"
```

### Optional Parameters

```just
# Deploy to environment (defaults to staging)
deploy env='staging':
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Deploying to {{env}}..."
    ./deploy.sh {{env}}
```

### Variadic Parameters

```just
# Run tests with optional arguments
test *args='':
    npm test {{args}}

# Usage: just test --watch --verbose
```

---

## 12. Testing and Validation

### Syntax Validation

```bash
# Check justfile syntax
just --check

# Show all recipes
just --list

# Dry run (show commands without executing)
just --dry-run recipe-name
```

### Test Environment

Always test recipes in a controlled environment before production use:

```just
# Test in Docker container
test-recipe:
    docker run --rm -v $(pwd):/app -w /app ubuntu:22.04 bash -c "
        apt-get update && apt-get install -y just
        just recipe-name
    "
```

---

## 13. General Best Practices

### Simplicity

```just
# ❌ BAD - Too complex
deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    # 50 lines of bash...

# ✅ GOOD - Break into smaller recipes
deploy: build push update-k8s notify
    @echo "✓ Deployment complete"
```

### Dependencies

```just
# ❌ BAD - Manual orchestration
deploy:
    just test
    just build
    ./deploy.sh

# ✅ GOOD - Automatic dependencies
deploy: test build
    ./deploy.sh
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

---

## 14. Migration Example

### Original Makefile

```make
VARIABLE = value
PROJECT_DIR = $(shell pwd)

.PHONY: default
default:
	@echo "Available targets: build, test, deploy"

.PHONY: build
build:
	@echo "Building..."
	npm run build

.PHONY: deploy
deploy: build
	@echo "Deploying..."
	./deploy.sh
```

### Migrated Justfile

```just
# justfile for Project
set shell := ["bash", "-c"]

# Variables
project_dir := justfile_directory()

# Default recipe
default:
    @just --list

# Build for production
build:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Building..."
    npm run build
    echo "✓ Build complete"

# Deploy to production
deploy: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deploying..."
    ./deploy.sh
    echo "✓ Deployment complete"
```

---

## 15. Migration Checklist

- [ ] Convert Makefile variables to Just syntax with `:=` or `=`
- [ ] Map `.PHONY` targets to recipes, preserving dependencies
- [ ] Support compound commands with parameterized recipes
- [ ] Replace Makefile functions with shell scripts using `set -euo pipefail`
- [ ] Add prerequisite checks (files, commands, permissions)
- [ ] Implement logging with timestamps and verbose mode
- [ ] Avoid raw ANSI codes; use `tput` or simple formatting
- [ ] Validate arguments and external inputs
- [ ] Test justfile with `just --check`
- [ ] Ensure clear and consistent messages
- [ ] Document all recipes and variables
- [ ] Remove `.PHONY` declarations (not needed in Just)
- [ ] Test all recipes in clean environment
- [ ] Update CI/CD to use `just` instead of `make`

---

## 16. AI Prompt for Migration

Create a `justfile` that:

1. Converts all Makefile variables to Just variables with clear names and expansions via `{{var}}`
2. Maps `.PHONY` targets to recipes, preserving dependencies
3. Supports compound commands (e.g., `make service action`) with parameterized recipes (e.g., `service action:`) using `case` or `if` statements
4. Replaces Makefile functions with shell scripts using `set -euo pipefail` and error checks
5. Includes a `default` recipe that executes `just --list`
6. Adds prerequisite checks (e.g., files, commands, permissions)
7. Supports logging with timestamps, redirecting output to a file with `tee -a` (verbose mode) or `>>` (silent mode)
8. Includes verbose mode with variable `export VERBOSE := "false"`
9. Avoids raw ANSI escape codes; uses `tput` for colors or simple formatting
10. Validates command-line arguments and external inputs
11. Uses `set shell := ["bash", "-c"]` for consistency
12. Documents all recipes and variables with clear comments
13. Tests syntax with `just --check` before finalizing

---

**Last Updated**: 2025-12-11
