# Enterprise Security Preferences for Just Script Generation

## Usage

**How to use this preferences file with the base prompt:**

1. **Copy the base generation prompt**:
   - Open `/data/Projetos/infra-ai-prompts/just/Just_Script_Generation_Instructions.md`
   - Copy the entire content to your AI tool (Claude, ChatGPT, etc.)

2. **Append this preferences file**:
   - Copy this entire file
   - Paste it immediately after the base prompt in the same message

3. **Provide your requirements**:
   - Describe your project type and needs
   - The AI will apply both base patterns AND these enterprise security preferences

4. **Expected behavior**:
   - All recipes will include enterprise security patterns (vault credentials, audit logging, input validation)
   - Compliance requirements (SOC 2, ISO 27001) will be followed
   - Paranoid error checking and confirmation prompts will be included

**Example composition**:
```
[Base prompt from Just_Script_Generation_Instructions.md]

---

[This entire preferences file]

---

My project: Internal API deployment system
Requirements: Deploy to production with strict audit trail...
```

---

## Security-First Configuration

When generating justfiles for enterprise environments with strict security requirements, apply these preferences:

### Security Level
- **Level**: Maximum security (defense-in-depth)
- **Compliance**: SOC 2, ISO 27001, GDPR-compliant patterns
- **Audit**: All operations must be auditable

### Credential Management

**REQUIRED**:
- ✅ ALL credentials from secure vault (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault)
- ✅ NO environment variables for production credentials
- ✅ NO .env files in production (dev only)
- ✅ Credential rotation support
- ✅ Audit logging for credential access

**Example Pattern**:
```just
# Use vault for credentials
db-password := `vault kv get -field=password secret/prod/database`
api-key := `aws secretsmanager get-secret-value --secret-id prod/api-key --query SecretString --output text`
```

### Command Execution Security

**REQUIRED**:
- ✅ `set -euo pipefail` in ALL bash recipes
- ✅ Explicit error handling with try/catch patterns
- ✅ Input validation for ALL parameters
- ✅ Sanitize user inputs (prevent injection)
- ✅ Timeout limits on all network operations
- ✅ Resource limits (memory, CPU) where applicable

**Example Pattern**:
```just
# Secure command execution
deploy environment:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate input
    if [[ ! "{{environment}}" =~ ^(staging|production)$ ]]; then
        echo "Error: Invalid environment '{{environment}}'"
        echo "Allowed: staging, production"
        exit 1
    fi

    # Audit log
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Deploy initiated by $USER to {{environment}}" >> /var/log/deploy-audit.log

    # Execute with timeout
    timeout 300s ./scripts/deploy.sh "{{environment}}"
```

### File Operations Security

**REQUIRED**:
- ✅ Strict file permissions (600 for secrets, 640 for configs, 750 for scripts)
- ✅ Verify file ownership before operations
- ✅ No world-readable/writable files
- ✅ Atomic file operations (temp file + mv)
- ✅ File integrity checks (checksums)

**Example Pattern**:
```just
# Secure config deployment
deploy-config:
    #!/usr/bin/env bash
    set -euo pipefail

    config_file="/etc/app/config.yml"
    temp_file=$(mktemp)

    # Generate config
    ./scripts/generate-config.sh > "$temp_file"

    # Verify checksum
    expected_checksum="abc123..."
    actual_checksum=$(sha256sum "$temp_file" | awk '{print $1}')

    if [ "$expected_checksum" != "$actual_checksum" ]; then
        rm "$temp_file"
        echo "Error: Config checksum mismatch"
        exit 1
    fi

    # Set permissions before moving
    chmod 640 "$temp_file"
    chown app:app "$temp_file"

    # Atomic move
    mv "$temp_file" "$config_file"

    echo "✓ Config deployed securely"
```

### Network Operations Security

**REQUIRED**:
- ✅ TLS 1.3+ only (no TLS 1.2 or below)
- ✅ Certificate validation (no --insecure flags)
- ✅ Timeout on all network calls
- ✅ Retry with exponential backoff
- ✅ Rate limiting
- ✅ Network operations logged

**Example Pattern**:
```just
# Secure API call
api-call endpoint:
    #!/usr/bin/env bash
    set -euo pipefail

    api_key=$(vault kv get -field=key secret/api)

    # TLS 1.3 only, with timeout and retry
    curl \
        --tlsv1.3 \
        --cacert /etc/ssl/certs/ca-bundle.crt \
        --max-time 30 \
        --retry 3 \
        --retry-delay 5 \
        -H "Authorization: Bearer $api_key" \
        -H "X-Request-ID: $(uuidgen)" \
        "https://api.example.com/{{endpoint}}"

    # Log (without credentials)
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] API call to {{endpoint}}" >> /var/log/api-audit.log
```

### Secrets Scanning

**REQUIRED**:
- ✅ Pre-commit hooks to scan for secrets
- ✅ git-secrets or truffleHog integration
- ✅ Fail builds if secrets detected
- ✅ Regular secret rotation

**Example Pattern**:
```just
# Pre-commit secret scan
pre-commit:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Scanning for secrets..."

    if command -v git-secrets &> /dev/null; then
        git secrets --scan
    fi

    if command -v trufflehog &> /dev/null; then
        trufflehog filesystem . --only-verified
    fi

    echo "✓ No secrets detected"
```

### Audit Logging

**REQUIRED**:
- ✅ Log ALL privileged operations
- ✅ Include timestamp, user, action, result
- ✅ Structured logging (JSON preferred)
- ✅ Tamper-proof log storage
- ✅ Log retention policy (90+ days)

**Example Pattern**:
```just
# Audit logging function
_audit-log action details:
    #!/usr/bin/env bash
    log_file="/var/log/audit/justfile-audit.log"

    jq -n \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg user "$USER" \
        --arg action "{{action}}" \
        --arg details "{{details}}" \
        --arg hostname "$(hostname)" \
        '{timestamp: $timestamp, user: $user, action: $action, details: $details, hostname: $hostname}' \
        >> "$log_file"

    chmod 640 "$log_file"
```

### Privileged Operations

**REQUIRED**:
- ✅ Principle of least privilege
- ✅ sudo operations require approval/confirmation
- ✅ No NOPASSWD sudo
- ✅ Privileged operations in separate recipes
- ✅ Audit trail for all sudo usage

**Example Pattern**:
```just
# Privileged operation with confirmation
system-upgrade:
    #!/usr/bin/env bash
    set -euo pipefail

    # Require explicit confirmation
    read -p "This will upgrade system packages. Type 'CONFIRM' to proceed: " confirm

    if [ "$confirm" != "CONFIRM" ]; then
        echo "Aborted."
        exit 1
    fi

    # Log before sudo
    just _audit-log "system-upgrade" "User $USER initiated system upgrade"

    # Execute with sudo (will prompt for password)
    sudo apt-get update
    sudo apt-get upgrade -y

    # Log completion
    just _audit-log "system-upgrade" "System upgrade completed successfully"
```

### Code Signing and Verification

**REQUIRED**:
- ✅ Verify signatures of downloaded binaries
- ✅ Checksum verification for all artifacts
- ✅ GPG signing of releases
- ✅ Trusted artifact registries only

**Example Pattern**:
```just
# Secure binary download
download-tool version:
    #!/usr/bin/env bash
    set -euo pipefail

    url="https://releases.example.com/tool-{{version}}.tar.gz"
    checksum_url="https://releases.example.com/tool-{{version}}.tar.gz.sha256"

    # Download
    curl -f "$url" -o "tool-{{version}}.tar.gz"
    curl -f "$checksum_url" -o "tool-{{version}}.tar.gz.sha256"

    # Verify checksum
    sha256sum -c "tool-{{version}}.tar.gz.sha256"

    # Extract and verify signature if available
    if [ -f "tool-{{version}}.tar.gz.sig" ]; then
        gpg --verify "tool-{{version}}.tar.gz.sig" "tool-{{version}}.tar.gz"
    fi

    echo "✓ Tool downloaded and verified"
```

### Compliance Requirements

**REQUIRED for SOC 2 / ISO 27001**:
- ✅ Change management documentation
- ✅ Rollback procedures for all deployments
- ✅ Disaster recovery recipes
- ✅ Incident response runbooks
- ✅ Access control matrix

**Example Pattern**:
```just
# Production deployment with change management
prod-deploy ticket:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate change ticket
    if [[ ! "{{ticket}}" =~ ^CHG-[0-9]+$ ]]; then
        echo "Error: Invalid change ticket format. Expected: CHG-12345"
        exit 1
    fi

    # Verify ticket approval (example: check JIRA)
    approval_status=$(curl -s "https://jira.example.com/api/ticket/{{ticket}}/status")

    if [ "$approval_status" != "APPROVED" ]; then
        echo "Error: Change ticket {{ticket}} not approved"
        exit 1
    fi

    # Create backup before deployment
    just backup-create

    # Log deployment start
    just _audit-log "prod-deploy" "Deployment initiated with ticket {{ticket}}"

    # Deploy
    if just _deploy-production; then
        just _audit-log "prod-deploy" "Deployment successful for ticket {{ticket}}"
    else
        # Automatic rollback on failure
        just _audit-log "prod-deploy" "Deployment failed, initiating rollback"
        just rollback-execute
        exit 1
    fi
```

## Output Requirements

When generating justfiles with these preferences:

1. **Always include**:
   - Security-first error handling
   - Audit logging for all operations
   - Input validation
   - Credential management via vault
   - Confirmation prompts for destructive operations

2. **Never include**:
   - Hardcoded credentials or secrets
   - Insecure curl flags (--insecure, -k)
   - World-readable file permissions
   - Unvalidated user inputs
   - Operations without audit trails

3. **Code style**:
   - Paranoid error checking
   - Defensive programming
   - Explicit over implicit
   - Fail-fast on errors
   - Comprehensive logging

## Validation Checklist

Before accepting generated justfile:

- [ ] All credentials retrieved from secure vault
- [ ] All bash recipes use `set -euo pipefail`
- [ ] All user inputs validated
- [ ] All privileged operations logged
- [ ] All network calls use TLS 1.3+
- [ ] All files created with secure permissions
- [ ] Destructive operations require confirmation
- [ ] Rollback procedures included
- [ ] No hardcoded secrets anywhere
- [ ] Change management compliance met

---

**Last Updated**: 2025-12-12
**Compliance**: SOC 2 Type II, ISO 27001, GDPR
**Severity Level**: Maximum (Production Enterprise)
