# Enterprise Security Preferences for Shell Script Generation

## Usage

**How to use this preferences file with the base prompt:**

1. **Copy the base generation prompt**:
   - Open `../../Shell_Script_Generation_Instructions.md`
   - Copy the entire content to your AI tool (Claude, ChatGPT, etc.)

2. **Append this preferences file**:
   - Copy this entire file
   - Paste it immediately after the base prompt in the same message

3. **Provide your requirements**:
   - Describe your shell script needs
   - The AI will apply both base patterns AND these enterprise security preferences

4. **Expected behavior**:
   - All scripts will follow maximum security (defense-in-depth)
   - Compliance patterns (SOC 2, ISO 27001, GDPR) will be built-in
   - Paranoid error checking and audit logging included
   - No hardcoded credentials, vault integration enforced

**Example composition**:
```
[Base prompt from Shell_Script_Generation_Instructions.md]

---

[This entire preferences file]

---

My task: Database backup script for production with PCI-DSS compliance
Requirements: Automated daily backups with encrypted storage and audit trail...
```

---

## Security-First Configuration

When generating shell scripts for enterprise environments with strict security requirements, apply these preferences:

### Security Level
- **Level**: Maximum security (defense-in-depth)
- **Compliance**: SOC 2, ISO 27001, GDPR, PCI-DSS compliant patterns
- **Audit**: All privileged operations must be auditable
- **Principle**: Least privilege, fail-secure, defense-in-depth

### Mandatory Script Header

**REQUIRED for ALL scripts**:
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Security context
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_USER="${USER:-$(whoami)}"
readonly SCRIPT_PID=$$

# Audit logging
readonly AUDIT_LOG="${AUDIT_LOG:-/var/log/audit/${SCRIPT_NAME}.log}"
mkdir -p "$(dirname "$AUDIT_LOG")" 2>/dev/null || true
chmod 750 "$(dirname "$AUDIT_LOG")" 2>/dev/null || true

# Audit log function
function audit_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "${timestamp} [${level}] [${SCRIPT_USER}@${HOSTNAME}:${SCRIPT_PID}] ${message}" >> "$AUDIT_LOG"
    chmod 640 "$AUDIT_LOG" 2>/dev/null || true
}

# Log script start
audit_log "INFO" "Script started: ${SCRIPT_NAME} ${*}"

# Trap for cleanup and audit
trap 'audit_log "ERROR" "Script failed at line $LINENO with exit code $?"' ERR
trap 'audit_log "INFO" "Script completed: ${SCRIPT_NAME}"' EXIT
```

### Credential Management

**REQUIRED - NO EXCEPTIONS**:
- ✅ ALL credentials from secure vault (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, CyberArk)
- ✅ NO hardcoded credentials (passwords, API keys, tokens, certificates)
- ✅ NO environment variables for production credentials
- ✅ NO .env files in production (development only)
- ✅ Credential rotation support built-in
- ✅ Audit logging for ALL credential access

**Pattern 1: HashiCorp Vault**:
```bash
# Fetch credentials from Vault
function get_vault_secret() {
    local secret_path="$1"
    local field="$2"

    if ! command -v vault &>/dev/null; then
        audit_log "ERROR" "Vault CLI not found"
        return 1
    fi

    audit_log "INFO" "Accessing vault secret: ${secret_path}"

    local secret
    secret=$(vault kv get -field="${field}" "${secret_path}" 2>/dev/null)

    if [[ -z "$secret" ]]; then
        audit_log "ERROR" "Failed to retrieve secret from ${secret_path}"
        return 1
    fi

    echo "$secret"
}

# Usage
DB_PASSWORD=$(get_vault_secret "secret/prod/database" "password")
```

**Pattern 2: AWS Secrets Manager**:
```bash
# Fetch credentials from AWS Secrets Manager
function get_aws_secret() {
    local secret_id="$1"

    if ! command -v aws &>/dev/null; then
        audit_log "ERROR" "AWS CLI not found"
        return 1
    fi

    audit_log "INFO" "Accessing AWS secret: ${secret_id}"

    local secret
    secret=$(aws secretsmanager get-secret-value \
        --secret-id "${secret_id}" \
        --query SecretString \
        --output text 2>/dev/null)

    if [[ -z "$secret" ]]; then
        audit_log "ERROR" "Failed to retrieve secret ${secret_id}"
        return 1
    fi

    echo "$secret"
}

# Usage with JSON parsing
API_KEY=$(get_aws_secret "prod/api-credentials" | jq -r '.api_key')
```

**Pattern 3: Azure Key Vault**:
```bash
# Fetch credentials from Azure Key Vault
function get_azure_secret() {
    local vault_name="$1"
    local secret_name="$2"

    if ! command -v az &>/dev/null; then
        audit_log "ERROR" "Azure CLI not found"
        return 1
    fi

    audit_log "INFO" "Accessing Azure Key Vault: ${vault_name}/${secret_name}"

    local secret
    secret=$(az keyvault secret show \
        --vault-name "${vault_name}" \
        --name "${secret_name}" \
        --query value \
        --output tsv 2>/dev/null)

    if [[ -z "$secret" ]]; then
        audit_log "ERROR" "Failed to retrieve secret from Azure Key Vault"
        return 1
    fi

    echo "$secret"
}
```

### Input Validation & Sanitization

**REQUIRED for ALL user inputs**:
- ✅ Whitelist validation (NOT blacklist)
- ✅ Regex pattern matching for expected formats
- ✅ Path traversal prevention
- ✅ Command injection prevention
- ✅ SQL injection prevention (for database scripts)
- ✅ Length limits on all inputs
- ✅ Type validation (integer, email, hostname, etc.)

**Pattern: Strict Input Validation**:
```bash
# Validate environment name (whitelist)
function validate_environment() {
    local env="$1"

    if [[ ! "$env" =~ ^(development|staging|production)$ ]]; then
        audit_log "ERROR" "Invalid environment: ${env}"
        echo "Error: Invalid environment '${env}'" >&2
        echo "Allowed values: development, staging, production" >&2
        return 1
    fi

    audit_log "INFO" "Environment validated: ${env}"
    return 0
}

# Validate hostname (prevent command injection)
function validate_hostname() {
    local hostname="$1"

    # Strict RFC 1123 hostname validation
    if [[ ! "$hostname" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$ ]]; then
        audit_log "ERROR" "Invalid hostname format: ${hostname}"
        echo "Error: Invalid hostname '${hostname}'" >&2
        return 1
    fi

    # Length check (max 253 characters per RFC)
    if [[ ${#hostname} -gt 253 ]]; then
        audit_log "ERROR" "Hostname too long: ${hostname}"
        echo "Error: Hostname exceeds 253 characters" >&2
        return 1
    fi

    audit_log "INFO" "Hostname validated: ${hostname}"
    return 0
}

# Validate file path (prevent path traversal)
function validate_path() {
    local path="$1"
    local base_dir="$2"

    # Resolve to absolute path
    local real_path
    real_path=$(realpath -m "$path" 2>/dev/null)

    if [[ -z "$real_path" ]]; then
        audit_log "ERROR" "Invalid path: ${path}"
        return 1
    fi

    # Check if path is within allowed base directory
    if [[ "$real_path" != "$base_dir"* ]]; then
        audit_log "ERROR" "Path traversal attempt: ${path} (outside ${base_dir})"
        echo "Error: Path '${path}' is outside allowed directory" >&2
        return 1
    fi

    audit_log "INFO" "Path validated: ${real_path}"
    return 0
}

# Validate integer
function validate_integer() {
    local value="$1"
    local min="${2:-}"
    local max="${3:-}"

    if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
        audit_log "ERROR" "Not an integer: ${value}"
        echo "Error: Value must be an integer" >&2
        return 1
    fi

    if [[ -n "$min" && "$value" -lt "$min" ]]; then
        audit_log "ERROR" "Value below minimum: ${value} < ${min}"
        echo "Error: Value must be >= ${min}" >&2
        return 1
    fi

    if [[ -n "$max" && "$value" -gt "$max" ]]; then
        audit_log "ERROR" "Value above maximum: ${value} > ${max}"
        echo "Error: Value must be <= ${max}" >&2
        return 1
    fi

    return 0
}
```

### Command Injection Prevention

**REQUIRED**:
- ✅ NEVER use user input directly in command substitution
- ✅ Always quote variables: `"$var"` not `$var`
- ✅ Use arrays for command arguments
- ✅ Validate and sanitize ALL external inputs
- ✅ Use `--` to terminate option processing
- ✅ Prefer built-ins over external commands where possible

**Pattern: Safe Command Execution**:
```bash
# UNSAFE - NEVER DO THIS
function unsafe_command() {
    local user_input="$1"
    eval "ls $user_input"  # DANGEROUS: command injection possible
}

# SAFE - Always do this
function safe_command() {
    local user_input="$1"

    # Validate input first
    if [[ ! "$user_input" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
        audit_log "ERROR" "Invalid input detected"
        return 1
    fi

    # Use array for command arguments
    local -a cmd=(ls -la -- "$user_input")

    # Execute with proper quoting
    "${cmd[@]}"
}

# Safe subprocess with timeout
function safe_subprocess() {
    local -a cmd=("$@")
    local timeout=30

    audit_log "INFO" "Executing: ${cmd[*]}"

    if ! timeout "${timeout}" "${cmd[@]}"; then
        audit_log "ERROR" "Command failed or timed out: ${cmd[*]}"
        return 1
    fi

    audit_log "INFO" "Command completed: ${cmd[*]}"
    return 0
}
```

### File Operations Security

**REQUIRED**:
- ✅ Strict file permissions (600 for secrets, 640 for configs, 750 for executables)
- ✅ Verify file ownership before operations
- ✅ No world-readable/writable files (NO 777 or 666)
- ✅ Atomic file operations (write to temp, then mv)
- ✅ File integrity checks (checksums/signatures)
- ✅ Secure temporary files (`mktemp`)
- ✅ Cleanup temporary files in trap handler

**Pattern: Secure File Operations**:
```bash
# Secure temporary file creation
function create_secure_temp() {
    local template="${1:-tmp.XXXXXXXXXX}"
    local temp_file

    temp_file=$(mktemp "/tmp/${template}")

    if [[ ! -f "$temp_file" ]]; then
        audit_log "ERROR" "Failed to create temporary file"
        return 1
    fi

    # Set restrictive permissions immediately
    chmod 600 "$temp_file"

    audit_log "INFO" "Created secure temporary file: ${temp_file}"
    echo "$temp_file"
}

# Atomic file write with verification
function atomic_write() {
    local target_file="$1"
    local content="$2"
    local expected_owner="${3:-$USER}"
    local expected_perms="${4:-640}"

    # Create temporary file
    local temp_file
    temp_file=$(create_secure_temp "$(basename "$target_file").XXXXXXXXXX")

    # Write content
    echo "$content" > "$temp_file"

    # Set ownership and permissions
    if [[ "$expected_owner" != "$USER" ]]; then
        sudo chown "$expected_owner" "$temp_file"
    fi
    chmod "$expected_perms" "$temp_file"

    # Atomic move
    mv "$temp_file" "$target_file"

    audit_log "INFO" "Atomically wrote file: ${target_file}"
}

# Secure file read with verification
function secure_read() {
    local file="$1"
    local expected_owner="${2:-}"

    # Verify file exists
    if [[ ! -f "$file" ]]; then
        audit_log "ERROR" "File not found: ${file}"
        return 1
    fi

    # Verify ownership if specified
    if [[ -n "$expected_owner" ]]; then
        local actual_owner
        actual_owner=$(stat -c '%U' "$file" 2>/dev/null)

        if [[ "$actual_owner" != "$expected_owner" ]]; then
            audit_log "ERROR" "File ownership mismatch: ${file} (expected ${expected_owner}, got ${actual_owner})"
            return 1
        fi
    fi

    # Verify permissions (no world-readable for sensitive files)
    local perms
    perms=$(stat -c '%a' "$file" 2>/dev/null)
    local world_perms=$((perms % 10))

    if [[ $world_perms -ne 0 ]]; then
        audit_log "WARN" "File has world permissions: ${file} (${perms})"
    fi

    # Read file
    cat "$file"
}

# Cleanup trap
readonly -a TEMP_FILES=()
function cleanup_temp_files() {
    local file
    for file in "${TEMP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            shred -u -n 3 "$file" 2>/dev/null || rm -f "$file"
            audit_log "INFO" "Cleaned up temporary file: ${file}"
        fi
    done
}
trap cleanup_temp_files EXIT
```

### Privileged Operations

**REQUIRED**:
- ✅ Principle of least privilege (run as minimal user)
- ✅ Explicit sudo for privileged operations (no NOPASSWD)
- ✅ Confirmation prompts for destructive operations
- ✅ Audit logging for ALL sudo usage
- ✅ Separate privileged operations into dedicated functions
- ✅ Drop privileges after use (`sudo -u` for lower privilege)

**Pattern: Safe Privileged Operations**:
```bash
# Require explicit confirmation for destructive operations
function require_confirmation() {
    local operation="$1"
    local confirm

    echo "⚠️  WARNING: This operation will ${operation}" >&2
    echo "⚠️  Type 'CONFIRM' to proceed (or Ctrl-C to cancel):" >&2
    read -r confirm

    if [[ "$confirm" != "CONFIRM" ]]; then
        audit_log "INFO" "Operation cancelled by user: ${operation}"
        echo "Operation cancelled." >&2
        return 1
    fi

    audit_log "WARN" "User confirmed destructive operation: ${operation}"
    return 0
}

# Privileged file installation
function install_system_file() {
    local source="$1"
    local destination="$2"
    local owner="${3:-root}"
    local perms="${4:-644}"

    # Validate source exists
    if [[ ! -f "$source" ]]; then
        audit_log "ERROR" "Source file not found: ${source}"
        return 1
    fi

    # Require confirmation
    require_confirmation "install ${destination} as ${owner}:${perms}"

    # Log before sudo
    audit_log "WARN" "Installing system file: ${source} -> ${destination}"

    # Use sudo for installation
    sudo install -o "$owner" -m "$perms" "$source" "$destination"

    audit_log "INFO" "System file installed: ${destination}"
}

# Execute command with specific user (lower privilege)
function run_as_user() {
    local target_user="$1"
    shift
    local -a cmd=("$@")

    audit_log "INFO" "Executing as ${target_user}: ${cmd[*]}"

    sudo -u "$target_user" "${cmd[@]}"
}
```

### Network Operations Security

**REQUIRED**:
- ✅ TLS 1.3+ only (no TLS 1.2 or below)
- ✅ Certificate validation (no --insecure flags)
- ✅ Timeout on ALL network calls
- ✅ Retry with exponential backoff
- ✅ Rate limiting
- ✅ Network operations logged with destination

**Pattern: Secure Network Operations**:
```bash
# Secure HTTP request with retry
function secure_curl() {
    local url="$1"
    local max_attempts=3
    local timeout=30
    local retry_delay=5

    for attempt in $(seq 1 $max_attempts); do
        audit_log "INFO" "HTTP request to ${url} (attempt ${attempt}/${max_attempts})"

        if curl \
            --tlsv1.3 \
            --cacert /etc/ssl/certs/ca-bundle.crt \
            --max-time "$timeout" \
            --fail \
            --silent \
            --show-error \
            "$url"; then

            audit_log "INFO" "HTTP request successful: ${url}"
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            audit_log "WARN" "HTTP request failed, retrying in ${retry_delay}s: ${url}"
            sleep $retry_delay
            retry_delay=$((retry_delay * 2))  # Exponential backoff
        fi
    done

    audit_log "ERROR" "HTTP request failed after ${max_attempts} attempts: ${url}"
    return 1
}
```

### Compliance Requirements

**REQUIRED for SOC 2 / ISO 27001**:
- ✅ Change management documentation in script comments
- ✅ Rollback procedures for all deployments
- ✅ Disaster recovery scripts
- ✅ Incident response runbooks
- ✅ Access control validation
- ✅ Data retention policies enforced

**Pattern: Compliance-Ready Script**:
```bash
#!/usr/bin/env bash
# Production Deployment Script
#
# CHANGE MANAGEMENT:
#   Change Request: CHG-2024-12345
#   Approved By: Security Team, Ops Manager
#   Implementation Date: 2025-12-12
#   Rollback Procedure: See rollback_deployment.sh
#
# COMPLIANCE:
#   SOC 2 Type II: Audit logging enabled
#   ISO 27001: Security controls enforced
#   PCI-DSS: No cardholder data handling
#
# DISASTER RECOVERY:
#   RPO: 15 minutes
#   RTO: 30 minutes
#   Backup Location: /backups/production/
#
# ACCESS CONTROL:
#   Minimum Role: ops-deployer
#   Privileged Operations: Logged and alerted
#   MFA Required: Yes

set -euo pipefail
# ... rest of script
```

## Output Requirements

When generating shell scripts with these preferences:

1. **Always include**:
   - Mandatory security header with audit logging
   - Vault integration for ALL credentials
   - Input validation for ALL external inputs
   - Atomic file operations with secure permissions
   - Confirmation prompts for destructive operations
   - Comprehensive audit logging

2. **Never include**:
   - Hardcoded credentials or secrets
   - Unvalidated user inputs
   - World-readable/writable permissions
   - eval or other dangerous constructs
   - Operations without audit trails

3. **Code style**:
   - Paranoid error checking
   - Defensive programming
   - Explicit over implicit
   - Fail-fast on errors
   - Comprehensive logging

## Validation Checklist

Before accepting generated script:

- [ ] All credentials retrieved from secure vault
- [ ] `set -euo pipefail` in header
- [ ] All user inputs validated with whitelists
- [ ] All privileged operations logged
- [ ] All network calls use TLS 1.3+
- [ ] All files created with secure permissions (≤640)
- [ ] Destructive operations require confirmation
- [ ] Temporary files cleaned up in trap
- [ ] No hardcoded secrets anywhere
- [ ] Change management documentation present

---

**Last Updated**: 2025-12-12
**Compliance**: SOC 2 Type II, ISO 27001, GDPR, PCI-DSS
**Severity Level**: Maximum (Production Enterprise)
