# Just Security Standards Reference

> **Purpose**: Security standards and patterns for just scripts.
> **Audience**: Developers writing justfiles that handle sensitive operations.

---

## Security Principles

### Principle 1: Secrets Management

**NEVER hardcode credentials in justfiles.**

```just
# ❌ BAD - Hardcoded credentials
deploy:
    API_KEY="sk_live_hardcoded123" ./deploy.sh
    DB_PASSWORD="MyPassword123" ./migrate.sh

# ✅ GOOD - Environment variables
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate required secrets
    : "${API_KEY:?Error: API_KEY not set}"
    : "${DB_PASSWORD:?Error: DB_PASSWORD not set}"

    ./deploy.sh
```

**Secret validation pattern:**

```just
# Check if environment variable is set
_require-env var:
    #!/usr/bin/env bash
    if [ -z "${!{{var}}:-}" ]; then
        echo "Error: {{var}} environment variable not set"
        exit 1
    fi

# Use in recipes
deploy: (_require-env "API_KEY") (_require-env "DEPLOY_TOKEN")
    ./deploy.sh
```

---

### Principle 2: Command Injection Prevention

**Always validate and sanitize user inputs.**

```just
# ❌ BAD - Unvalidated input (command injection risk)
run-sql query:
    psql -c "{{query}}"
    # Attack: just run-sql "'; DROP TABLE users; --"

# ✅ GOOD - Input validation
run-sql query:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate query doesn't contain dangerous patterns
    if echo "{{query}}" | grep -iE "drop|delete|truncate|alter" > /dev/null; then
        echo "Error: Destructive SQL operations not allowed"
        echo "Use dedicated recipes: db-drop, db-reset"
        exit 1
    fi

    # Use parameterized queries when possible
    psql -v query="{{query}}" -c "SELECT \$query"
```

**Path traversal prevention:**

```just
# ❌ BAD - Path traversal vulnerability
read-file path:
    cat {{path}}
    # Attack: just read-file "../../../../etc/passwd"

# ✅ GOOD - Path validation
read-file path:
    #!/usr/bin/env bash
    set -euo pipefail

    # Ensure path is within project directory
    real_path=$(realpath "{{path}}" 2>/dev/null || echo "")
    project_dir=$(pwd)

    if [[ "$real_path" != "$project_dir"* ]]; then
        echo "Error: Path must be within project directory"
        exit 1
    fi

    cat "$real_path"
```

---

### Principle 3: Principle of Least Privilege

**Avoid running commands with elevated privileges unless absolutely necessary.**

```just
# ❌ BAD - Unnecessary sudo
install:
    sudo npm install

# ✅ GOOD - Use user-level install
install:
    npm install

# ✅ ACCEPTABLE - Sudo only when needed, with validation
install-system-deps:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "$EUID" -eq 0 ]; then
        echo "Error: Do not run with sudo. Recipe will prompt when needed."
        exit 1
    fi

    # Install system packages (requires sudo)
    sudo apt-get update
    sudo apt-get install -y postgresql-client redis-tools

    # Install project dependencies (no sudo)
    npm install
```

---

### Principle 4: File Permissions

**Set strict permissions on sensitive files.**

```just
# Create credential file with correct permissions
setup-credentials:
    #!/usr/bin/env bash
    set -euo pipefail

    CRED_FILE=".env.local"

    # Create file
    cat > "$CRED_FILE" << EOF
API_KEY=${API_KEY}
DB_PASSWORD=${DB_PASSWORD}
EOF

    # Set restrictive permissions (owner read/write only)
    chmod 600 "$CRED_FILE"

    echo "✓ Credentials file created with permissions 600"

# Check file permissions
_check-permissions file expected:
    #!/usr/bin/env bash
    set -euo pipefail

    actual=$(stat -c "%a" "{{file}}" 2>/dev/null || stat -f "%Lp" "{{file}}" 2>/dev/null)

    if [ "$actual" != "{{expected}}" ]; then
        echo "Warning: {{file}} has permissions $actual (expected {{expected}})"
        exit 1
    fi

# Validate permissions before deployment
deploy: (_check-permissions ".env.production" "600")
    ./deploy.sh
```

---

## Credential Management Patterns

### Pattern 1: Environment Variables

**Standard approach for CI/CD and development.**

```just
# Load from .env file
set dotenv-load := true

# Variables with defaults
export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/app_dev")
export API_KEY := env_var_or_default("API_KEY", "")

# Recipe with validation
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "$API_KEY" ]; then
        echo "Error: API_KEY not set"
        echo "Set it with: export API_KEY=your_key"
        exit 1
    fi

    ./deploy.sh
```

### Pattern 2: Credential Files

**For local development with multiple secrets.**

```just
# Check if credential file exists
_check-credentials:
    #!/usr/bin/env bash
    set -euo pipefail

    CRED_FILE=".credentials"

    if [ ! -f "$CRED_FILE" ]; then
        echo "Error: $CRED_FILE not found"
        echo "Create it with: just setup-credentials"
        exit 1
    fi

    # Check permissions
    perms=$(stat -c "%a" "$CRED_FILE" 2>/dev/null || stat -f "%Lp" "$CRED_FILE")
    if [ "$perms" != "600" ]; then
        echo "Error: $CRED_FILE must have 600 permissions"
        echo "Fix with: chmod 600 $CRED_FILE"
        exit 1
    fi

# Load credentials from file
deploy: _check-credentials
    #!/usr/bin/env bash
    set -euo pipefail

    # Source credentials
    source .credentials

    # Validate required variables
    : "${DEPLOY_KEY:?Error: DEPLOY_KEY not set in .credentials}"

    ./deploy.sh
```

### Pattern 3: Secret Management Tools

**Integration with external secret managers.**

```just
# AWS Secrets Manager
get-secret name:
    #!/usr/bin/env bash
    set -euo pipefail

    aws secretsmanager get-secret-value \
        --secret-id "{{name}}" \
        --query SecretString \
        --output text

# HashiCorp Vault
get-vault-secret path:
    #!/usr/bin/env bash
    set -euo pipefail

    vault kv get -field=value "{{path}}"

# Deploy with secrets from vault
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    # Fetch secrets
    export API_KEY=$(just get-vault-secret "app/api-key")
    export DB_PASSWORD=$(just get-vault-secret "app/db-password")

    # Deploy
    ./deploy.sh

    # Clear secrets from memory
    unset API_KEY DB_PASSWORD
```

---

## Input Validation Patterns

### Pattern 1: Whitelist Validation

```just
# Validate environment parameter
deploy env:
    #!/usr/bin/env bash
    set -euo pipefail

    # Whitelist allowed environments
    case "{{env}}" in
        dev|staging|production)
            echo "Deploying to {{env}}..."
            ;;
        *)
            echo "Error: Invalid environment '{{env}}'"
            echo "Allowed: dev, staging, production"
            exit 1
            ;;
    esac

    ./deploy.sh "{{env}}"
```

### Pattern 2: Format Validation

```just
# Validate version number format
release version:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate semver format (e.g., 1.2.3)
    if ! echo "{{version}}" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "Error: Invalid version format '{{version}}'"
        echo "Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3)"
        exit 1
    fi

    git tag "v{{version}}"
    git push origin "v{{version}}"
```

### Pattern 3: File Existence Validation

```just
# Validate file exists before processing
process-file file:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "{{file}}" ]; then
        echo "Error: File '{{file}}' not found"
        exit 1
    fi

    # Validate file is not empty
    if [ ! -s "{{file}}" ]; then
        echo "Error: File '{{file}}' is empty"
        exit 1
    fi

    ./process.sh "{{file}}"
```

---

## Destructive Operation Safety

### Pattern 1: Confirmation Prompts

```just
# Destructive operation with confirmation
db-drop:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "⚠️  WARNING: This will delete the database!"
    echo "Database: $DATABASE_URL"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi

    dropdb app_development
    echo "✓ Database dropped"

# Force flag to skip confirmation (use with caution)
db-drop-force:
    dropdb --if-exists app_development
```

### Pattern 2: Dry Run Mode

```just
# Dry run flag
dry_run := env_var_or_default("DRY_RUN", "false")

# Deploy with dry run support
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "{{dry_run}}" = "true" ]; then
        echo "[DRY RUN] Would deploy to production"
        echo "[DRY RUN] Would run: ./deploy.sh"
        exit 0
    fi

    ./deploy.sh

# Usage: DRY_RUN=true just deploy
```

### Pattern 3: Backup Before Destructive Operations

```just
# Always backup before destructive operations
db-reset: db-backup db-drop db-create db-migrate db-seed

# Automatic backup
db-backup:
    #!/usr/bin/env bash
    set -euo pipefail

    backup_dir="backups"
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$backup_dir/db_backup_$timestamp.sql"

    mkdir -p "$backup_dir"

    pg_dump $DATABASE_URL > "$backup_file"

    echo "✓ Backup created: $backup_file"

# Restore from backup
db-restore file:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "{{file}}" ]; then
        echo "Error: Backup file not found: {{file}}"
        exit 1
    fi

    psql $DATABASE_URL < "{{file}}"
    echo "✓ Database restored from {{file}}"
```

---

## Audit Logging

### Pattern: Log All Sensitive Operations

```just
# Log file location
log_file := ".just-audit.log"

# Log helper
_log action:
    #!/usr/bin/env bash
    timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    user=$(whoami)
    echo "[$timestamp] $user: {{action}}" >> {{log_file}}

# Deploy with audit logging
deploy: (_log "deploy to production started")
    #!/usr/bin/env bash
    set -euo pipefail

    ./deploy.sh

    just _log "deploy to production completed"

# View audit log
audit-log lines='50':
    tail -n {{lines}} {{log_file}}

# Clear old logs (keep last 1000 lines)
audit-log-rotate:
    #!/usr/bin/env bash
    tail -n 1000 {{log_file}} > {{log_file}}.tmp
    mv {{log_file}}.tmp {{log_file}}
```

---

## Network Security

### Pattern 1: TLS/SSL Validation

```just
# Download file with SSL verification
download-artifact url:
    #!/usr/bin/env bash
    set -euo pipefail

    # Enforce HTTPS
    if [[ ! "{{url}}" =~ ^https:// ]]; then
        echo "Error: Only HTTPS URLs allowed"
        exit 1
    fi

    # Download with certificate validation
    curl --fail --location --show-error \
         --cacert /etc/ssl/certs/ca-certificates.crt \
         "{{url}}" -o artifact.tar.gz
```

### Pattern 2: Rate Limiting

```just
# Rate-limited API calls
api-call endpoint:
    #!/usr/bin/env bash
    set -euo pipefail

    rate_limit_file=".api_rate_limit"
    current_time=$(date +%s)

    # Check last call time
    if [ -f "$rate_limit_file" ]; then
        last_call=$(cat "$rate_limit_file")
        elapsed=$((current_time - last_call))

        if [ $elapsed -lt 1 ]; then
            sleep_time=$((1 - elapsed))
            echo "Rate limiting: sleeping ${sleep_time}s..."
            sleep $sleep_time
        fi
    fi

    # Make API call
    curl -H "Authorization: Bearer $API_KEY" \
         "https://api.example.com/{{endpoint}}"

    # Update rate limit file
    echo "$current_time" > "$rate_limit_file"
```

---

## Container Security

### Pattern: Docker Security Best Practices

```just
# Build Docker image with security scanning
docker-build-secure:
    #!/usr/bin/env bash
    set -euo pipefail

    # Build image
    docker build -t myapp:latest .

    # Scan for vulnerabilities
    docker scan myapp:latest

    # Check if scan passed
    if [ $? -ne 0 ]; then
        echo "Error: Security vulnerabilities detected"
        exit 1
    fi

    echo "✓ Docker image built and scanned"

# Run container with security options
docker-run-secure:
    docker run \
        --read-only \
        --tmpfs /tmp \
        --tmpfs /var/run \
        --cap-drop=ALL \
        --cap-add=NET_BIND_SERVICE \
        --security-opt=no-new-privileges \
        --user 1000:1000 \
        myapp:latest
```

---

## Dependency Security

### Pattern: Dependency Vulnerability Scanning

```just
# Check for vulnerable dependencies
security-scan:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Scanning dependencies for vulnerabilities..."

    # Node.js
    if [ -f "package.json" ]; then
        npm audit --audit-level=high
    fi

    # Python
    if [ -f "requirements.txt" ]; then
        pip install safety
        safety check --file requirements.txt
    fi

    # Ruby
    if [ -f "Gemfile" ]; then
        bundle audit check --update
    fi

    echo "✓ Security scan complete"

# Fix vulnerabilities automatically
security-fix:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -f "package.json" ]; then
        npm audit fix
    fi

    if [ -f "Gemfile" ]; then
        bundle update --conservative
    fi
```

---

## Security Checklist for Justfiles

- [ ] No hardcoded credentials (API keys, passwords, tokens)
- [ ] All secrets loaded from environment variables
- [ ] Input validation for all user-provided parameters
- [ ] Path traversal prevention for file operations
- [ ] Confirmation prompts for destructive operations
- [ ] Strict file permissions (600 for credentials, 700 for scripts)
- [ ] Error handling with `set -euo pipefail`
- [ ] Audit logging for sensitive operations
- [ ] TLS/SSL verification for network operations
- [ ] Dependency vulnerability scanning
- [ ] No `eval` or `exec` with user input
- [ ] No `shell=True` equivalent (command injection risk)
- [ ] Container security (minimal privileges, read-only filesystem)
- [ ] Regular security audits of recipes

---

## Common Vulnerabilities

### 1. Command Injection

**Vulnerability:**
```just
# User input directly in shell command
run-command cmd:
    sh -c "{{cmd}}"
    # Attack: just run-command "ls; rm -rf /"
```

**Fix:**
```just
# Whitelist allowed commands
run-command cmd:
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{cmd}}" in
        ls|pwd|whoami)
            {{cmd}}
            ;;
        *)
            echo "Error: Command not allowed"
            exit 1
            ;;
    esac
```

### 2. Information Disclosure

**Vulnerability:**
```just
# Secrets in output
deploy:
    @echo "Deploying with API_KEY=$API_KEY"
    ./deploy.sh
```

**Fix:**
```just
# Never print secrets
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "$API_KEY" ]; then
        echo "Error: API_KEY not set"
        exit 1
    fi

    @echo "Deploying to production..."
    ./deploy.sh
```

### 3. Insufficient Access Control

**Vulnerability:**
```just
# Anyone can deploy
deploy:
    ./deploy.sh
```

**Fix:**
```just
# Require specific user
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    allowed_users=("alice" "bob")
    current_user=$(whoami)

    if [[ ! " ${allowed_users[@]} " =~ " ${current_user} " ]]; then
        echo "Error: User $current_user not authorized to deploy"
        exit 1
    fi

    ./deploy.sh
```

---

## Security Resources

- **Just Security Guide**: https://just.systems/security
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CIS Benchmarks**: https://www.cisecurity.org/cis-benchmarks/
- **Docker Security**: https://docs.docker.com/engine/security/

---

**Last Updated**: 2025-12-11
