# Shell Security Standards Reference

> **Purpose**: Comprehensive security standards for shell script development.
> **Audience**: Developers writing production shell scripts handling sensitive data or operations.

---

## 1. Credential Management

### 1.1 Environment Variables (Recommended)

**✅ SECURE**:
```bash
#!/bin/bash
set -euo pipefail

# Load credentials from environment
DB_PASSWORD="${DB_PASSWORD:?ERROR: DB_PASSWORD not set}"
API_KEY="${API_KEY:?ERROR: API_KEY not set}"

# Use credentials
mysql -u user -p"$DB_PASSWORD" -e "SELECT 1"
```

**❌ INSECURE**:
```bash
# Hardcoded credentials
DB_PASSWORD="MyPassword123"
API_KEY="sk_live_abc123xyz"

# Credentials exposed in process list
mysql -u user -pMyPassword123  # Visible in 'ps aux'
```

### 1.2 Credential Files

**✅ SECURE**:
```bash
#!/bin/bash
set -euo pipefail

readonly CRED_FILE="/etc/myapp/credentials"

# Validate file permissions before loading
function validate_credential_file() {
    local file="$1"

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Credential file not found: $file" >&2
        exit 1
    fi

    # Check permissions (must be 400 or 600)
    local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file")
    if [[ "$perms" != "400" ]] && [[ "$perms" != "600" ]]; then
        echo "ERROR: Insecure permissions on $file: $perms (must be 400 or 600)" >&2
        exit 1
    fi

    # Check ownership (must be current user or root)
    local owner=$(stat -c "%U" "$file" 2>/dev/null || stat -f "%Su" "$file")
    if [[ "$owner" != "$(whoami)" ]] && [[ "$owner" != "root" ]]; then
        echo "ERROR: Credential file owned by different user: $owner" >&2
        exit 1
    fi
}

validate_credential_file "$CRED_FILE"

# Load credentials
set -a
source "$CRED_FILE"
set +a
```

**Credential file format** (`/etc/myapp/credentials`):
```bash
# Credentials for myapp
# Permissions: chmod 400 credentials
# Owner: chown myapp:myapp credentials

export DB_PASSWORD="SecurePassword123"
export API_KEY="sk_live_abc123xyz"
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

### 1.3 SSH Keys and Certificates

**✅ SECURE**:
```bash
#!/bin/bash
set -euo pipefail

readonly SSH_KEY="/home/myuser/.ssh/id_ed25519"

# Validate key permissions
function validate_ssh_key() {
    local key_file="$1"

    if [[ ! -f "$key_file" ]]; then
        echo "ERROR: SSH key not found: $key_file" >&2
        exit 1
    fi

    local perms=$(stat -c "%a" "$key_file")
    if [[ "$perms" != "400" ]] && [[ "$perms" != "600" ]]; then
        echo "ERROR: SSH key has insecure permissions: $perms" >&2
        echo "Fix with: chmod 600 $key_file" >&2
        exit 1
    fi
}

validate_ssh_key "$SSH_KEY"

# Use SSH key securely
ssh -i "$SSH_KEY" \
    -o StrictHostKeyChecking=yes \
    -o UserKnownHostsFile=/home/myuser/.ssh/known_hosts \
    user@server "command"
```

### 1.4 Secrets Never in Logs

**✅ SECURE**:
```bash
# Redact credentials in logs
function log_safe() {
    local message="$1"

    # Redact common credential patterns
    message=$(echo "$message" | sed -E \
        -e 's/(password|passwd|pwd|secret|token|key)=[^ ]*/\1=***REDACTED***/gi' \
        -e 's/(Bearer|Basic) [^ ]*/\1 ***REDACTED***/gi')

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

# ✅ GOOD
log_safe "Connecting to database with password=$DB_PASSWORD"
# Output: "Connecting to database with password=***REDACTED***"

# ❌ BAD - Credentials in logs
echo "Connecting with password=$DB_PASSWORD" >> "$LOG_FILE"
```

---

## 2. Input Validation

### 2.1 Validate All External Inputs

**✅ SECURE**:
```bash
function validate_username() {
    local username="$1"

    # Allow only alphanumeric, dash, underscore (3-32 chars)
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]{3,32}$ ]]; then
        echo "ERROR: Invalid username format: $username" >&2
        return 1
    fi

    # Reject reserved names
    local reserved=("root" "admin" "system" "nobody")
    for name in "${reserved[@]}"; do
        if [[ "$username" == "$name" ]]; then
            echo "ERROR: Reserved username: $username" >&2
            return 1
        fi
    done

    return 0
}

# Validate before use
if ! validate_username "$USER_INPUT"; then
    exit 1
fi
```

**❌ INSECURE**:
```bash
# No validation - command injection risk
username="$1"
useradd "$username"

# Attacker input: "; rm -rf / #"
# Executed as: useradd ; rm -rf / #
```

### 2.2 File Path Validation

**✅ SECURE**:
```bash
function validate_file_path() {
    local path="$1"
    local base_dir="$2"

    # Resolve to absolute path
    local abs_path=$(readlink -f "$path")

    # Check for directory traversal
    if [[ ! "$abs_path" =~ ^"$base_dir" ]]; then
        echo "ERROR: Path outside allowed directory: $abs_path" >&2
        return 1
    fi

    # Check for dangerous patterns
    if [[ "$abs_path" =~ \.\. ]]; then
        echo "ERROR: Path contains .. (directory traversal attempt)" >&2
        return 1
    fi

    return 0
}

# Usage
readonly ALLOWED_DIR="/var/data/uploads"
user_file="$1"

if ! validate_file_path "$user_file" "$ALLOWED_DIR"; then
    exit 1
fi

# Now safe to use
cat "$user_file"
```

**❌ INSECURE**:
```bash
# Directory traversal vulnerability
file="$1"
cat "$file"

# Attacker input: "../../../../etc/passwd"
# Reads: /etc/passwd
```

### 2.3 Numeric Input Validation

**✅ SECURE**:
```bash
function validate_port() {
    local port="$1"

    # Check if numeric
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Port must be numeric: $port" >&2
        return 1
    fi

    # Check range
    if [[ $port -lt 1 ]] || [[ $port -gt 65535 ]]; then
        echo "ERROR: Port must be between 1-65535: $port" >&2
        return 1
    fi

    return 0
}

# Validate before use
if ! validate_port "$USER_PORT"; then
    exit 1
fi

netstat -tuln | grep ":$USER_PORT"
```

### 2.4 Command Injection Prevention

**✅ SECURE**:
```bash
# Use arrays to prevent word splitting
files=("file1.txt" "file with spaces.txt" "file3.txt")

for file in "${files[@]}"; do
    # Quotes prevent injection
    cat "$file"
done

# Parameterized commands
grep -F -- "$user_search" "$file"  # -F treats as literal string, -- prevents option injection
```

**❌ INSECURE**:
```bash
# Command injection via variable expansion
search="'; rm -rf / #"
grep "$search" file.txt  # Executes: grep ''; rm -rf / # file.txt

# Command injection via eval
user_cmd="ls; rm -rf /"
eval "$user_cmd"  # NEVER use eval with user input!
```

---

## 3. Privilege Management

### 3.1 Principle of Least Privilege

**✅ SECURE**:
```bash
#!/bin/bash
set -euo pipefail

function check_privileges() {
    # Check if root is actually needed
    if [[ $EUID -eq 0 ]]; then
        echo "WARN: Running as root. Is this necessary?" >&2
    fi
}

# Drop privileges after critical operations
function drop_privileges() {
    local target_user="$1"

    if [[ $EUID -eq 0 ]]; then
        # Execute as non-privileged user
        su - "$target_user" -c "$(cat <<'EOF'
# Continue script as non-root
echo "Now running as: $(whoami)"
EOF
)"
    fi
}

# Escalate only when needed
function privileged_operation() {
    if [[ $EUID -ne 0 ]]; then
        echo "This operation requires root privileges" >&2
        exec sudo "$0" "$@"
    fi

    # Do privileged operation
    systemctl restart myservice

    # Drop back to normal user
    drop_privileges "$SUDO_USER"
}
```

**❌ INSECURE**:
```bash
#!/bin/bash
# Entire script runs as root unnecessarily
# (should only elevate for specific operations)

if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

# All operations run as root, even ones that don't need it
cat /var/log/app.log | grep ERROR
systemctl restart myservice  # This needs root
cat /var/log/app.log | grep WARN  # This doesn't
```

### 3.2 Sudo Usage

**✅ SECURE**:
```bash
# Check if sudo is configured for this operation
function can_sudo() {
    local command="$1"

    # Non-interactive check
    if sudo -n "$command" true 2>/dev/null; then
        return 0
    fi

    return 1
}

# Validate sudo access before prompting
if ! can_sudo systemctl; then
    echo "ERROR: Sudo access required for systemctl" >&2
    echo "Configure in /etc/sudoers:" >&2
    echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl" >&2
    exit 1
fi

# Use sudo selectively
sudo systemctl restart myservice
```

**Sudoers configuration** (`/etc/sudoers.d/myapp`):
```
# Allow myapp user to restart service without password
myapp ALL=(ALL) NOPASSWD: /bin/systemctl restart myservice.service
myapp ALL=(ALL) NOPASSWD: /bin/systemctl stop myservice.service
myapp ALL=(ALL) NOPASSWD: /bin/systemctl start myservice.service
myapp ALL=(ALL) NOPASSWD: /bin/systemctl status myservice.service

# Deny everything else
```

### 3.3 SUID/SGID Risks

**✅ SECURE**:
```bash
# Audit for SUID/SGID binaries
function audit_suid_binaries() {
    echo "Scanning for SUID/SGID binaries..."

    # Find SUID binaries
    find / -type f -perm -4000 -ls 2>/dev/null

    # Find SGID binaries
    find / -type f -perm -2000 -ls 2>/dev/null
}

# Remove unnecessary SUID bit
chmod u-s /path/to/binary
```

**❌ INSECURE**:
```bash
# NEVER set SUID on shell scripts (shell ignores it for security)
chmod u+s script.sh  # Won't work and shouldn't be attempted

# Setting SUID on interpreters is dangerous
chmod u+s /bin/bash  # NEVER do this!
```

---

## 4. File Operations Security

### 4.1 Secure Temporary Files

**✅ SECURE**:
```bash
# Create temporary file securely
temp_file=$(mktemp)
chmod 600 "$temp_file"  # Readable/writable only by owner

# Ensure cleanup
trap "rm -f '$temp_file'" EXIT

# Write sensitive data
echo "$SECRET_DATA" > "$temp_file"

# Use temporary directory
temp_dir=$(mktemp -d)
chmod 700 "$temp_dir"
trap "rm -rf '$temp_dir'" EXIT
```

**❌ INSECURE**:
```bash
# Predictable filename - race condition
temp_file="/tmp/myapp_$$"
echo "$SECRET_DATA" > "$temp_file"

# World-readable temporary file
temp_file=$(mktemp)
# Missing chmod - default umask might be 022 (world-readable)
echo "$SECRET_DATA" > "$temp_file"

# No cleanup - sensitive data left on disk
```

### 4.2 File Permission Management

**✅ SECURE**:
```bash
# Set permissions explicitly
function create_secure_file() {
    local file="$1"
    local owner="$2"
    local group="$3"

    # Create with restrictive permissions
    touch "$file"
    chmod 600 "$file"
    chown "$owner:$group" "$file"

    echo "Created $file with permissions 600, owner $owner:$group"
}

# Configuration files: 640 (owner read/write, group read)
chmod 640 /etc/myapp/config.ini

# Credential files: 400 or 600 (owner read only, or read/write)
chmod 400 /etc/myapp/credentials

# Executable scripts: 750 (owner all, group read/execute, no world)
chmod 750 /opt/myapp/start.sh

# Log files: 640 or 660 (owner/group read/write)
chmod 640 /var/log/myapp.log
```

**Permission Reference**:
```
400: -r--------  (read only by owner)
600: -rw-------  (read/write by owner)
640: -rw-r-----  (read/write owner, read group)
644: -rw-r--r--  (read/write owner, read all)
700: -rwx------  (all permissions owner only)
750: -rwxr-x---  (all owner, read/execute group)
755: -rwxr-xr-x  (all owner, read/execute all)
```

### 4.3 Symbolic Link Attacks

**✅ SECURE**:
```bash
# Check if file is a symbolic link before using
function safe_file_operation() {
    local file="$1"

    # Reject symbolic links
    if [[ -L "$file" ]]; then
        echo "ERROR: Symbolic links not allowed: $file" >&2
        return 1
    fi

    # Verify file is regular file
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Not a regular file: $file" >&2
        return 1
    fi

    # Safe to operate on file
    cat "$file"
}

# Use -P flag to avoid following symlinks
cp -P source dest
```

**❌ INSECURE**:
```bash
# Race condition: attacker can replace file with symlink
if [[ -f "$file" ]]; then
    # Time window for attack here
    cat "$file"  # Might now be a symlink to /etc/passwd
fi
```

### 4.4 Race Conditions (TOCTOU)

**✅ SECURE**:
```bash
# Atomic file creation
function create_file_atomic() {
    local target="$1"
    local content="$2"

    # Write to temp file first
    local temp_file=$(mktemp)
    chmod 600 "$temp_file"
    echo "$content" > "$temp_file"

    # Atomic rename
    mv "$temp_file" "$target"
}

# Check and use in single operation
function safe_read() {
    local file="$1"

    # Try to read, handle error
    if ! cat "$file" 2>/dev/null; then
        echo "ERROR: Cannot read file: $file" >&2
        return 1
    fi
}
```

**❌ INSECURE**:
```bash
# TOCTOU: Time Of Check, Time Of Use
if [[ -f "$file" ]]; then
    # File could be deleted or changed here
    cat "$file"
fi

# Race condition in file creation
if [[ ! -f "$lock_file" ]]; then
    # Another process could create lock_file here
    touch "$lock_file"
fi
```

---

## 5. Process and Signal Handling

### 5.1 Secure Signal Handling

**✅ SECURE**:
```bash
#!/bin/bash
set -euo pipefail

# Cleanup function
function cleanup() {
    local exit_code=$?

    echo "Cleaning up (exit code: $exit_code)..."

    # Remove temporary files
    rm -f "$TEMP_FILE"

    # Kill child processes
    jobs -p | xargs -r kill 2>/dev/null || true

    # Close file descriptors
    exec 3>&- 2>/dev/null || true

    exit $exit_code
}

# Register cleanup for all exit scenarios
trap cleanup EXIT
trap cleanup INT  # Ctrl+C
trap cleanup TERM # kill command
trap cleanup HUP  # Terminal closed
```

### 5.2 Background Process Management

**✅ SECURE**:
```bash
# Track background processes
declare -a BG_PIDS=()

function start_background_task() {
    local command="$1"

    # Start in background
    $command &
    local pid=$!

    # Track PID
    BG_PIDS+=("$pid")

    echo "Started background task (PID: $pid)"
}

function kill_background_tasks() {
    for pid in "${BG_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Killing background task (PID: $pid)"
            kill "$pid" 2>/dev/null || true
        fi
    done
}

trap kill_background_tasks EXIT
```

---

## 6. Logging Security

### 6.1 Secure Log Files

**✅ SECURE**:
```bash
readonly LOG_FILE="/var/log/myapp.log"

# Create log file with secure permissions
function init_logging() {
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"

    # Create log file if it doesn't exist
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 640 "$LOG_FILE"  # Owner read/write, group read
        chown myapp:myapp "$LOG_FILE"
    fi
}

# Log with sanitization
function log_secure() {
    local level="$1"
    shift
    local message="$*"

    # Redact sensitive patterns
    message=$(echo "$message" | sed -E \
        's/(password|token|key|secret)=\S+/\1=***REDACTED***/gi')

    # Prevent log injection
    message=$(echo "$message" | tr '\n' ' ' | tr '\r' ' ')

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}
```

### 6.2 Log Injection Prevention

**✅ SECURE**:
```bash
function log_user_input() {
    local user_input="$1"

    # Remove newlines and carriage returns (prevent log injection)
    user_input=$(echo "$user_input" | tr -d '\n\r')

    # Limit length
    if [[ ${#user_input} -gt 200 ]]; then
        user_input="${user_input:0:200}..."
    fi

    echo "[$(date)] User input: $user_input" >> "$LOG_FILE"
}
```

**❌ INSECURE**:
```bash
# Log injection vulnerability
echo "[$(date)] User input: $user_input" >> "$LOG_FILE"

# Attacker input: "test\n[CRITICAL] System compromised"
# Creates fake log entry:
# [2024-12-12] User input: test
# [CRITICAL] System compromised
```

---

## 7. Network Security

### 7.1 Secure API Calls

**✅ SECURE**:
```bash
function call_api() {
    local endpoint="$1"
    local token="$2"

    # Use HTTPS
    # Set timeouts
    # Validate certificate
    curl --fail --silent --show-error \
         --max-time 30 \
         --connect-timeout 10 \
         --cacert /etc/ssl/certs/ca-certificates.crt \
         -H "Authorization: Bearer $token" \
         -H "User-Agent: myapp/1.0" \
         "https://api.example.com/$endpoint"
}
```

**❌ INSECURE**:
```bash
# Insecure: HTTP instead of HTTPS
curl "http://api.example.com/endpoint"

# Insecure: Disable certificate verification
curl -k "https://api.example.com/endpoint"

# Insecure: No timeouts (can hang forever)
curl "https://api.example.com/endpoint"
```

---

## 8. Security Checklist

**Before deploying shell scripts to production:**

- [ ] **Credentials**
  - [ ] No hardcoded passwords, API keys, or secrets
  - [ ] Credentials loaded from environment or secure files
  - [ ] Credential files have 400 or 600 permissions
  - [ ] Credentials never logged or printed

- [ ] **Input Validation**
  - [ ] All user inputs validated before use
  - [ ] File paths checked for directory traversal
  - [ ] Numeric inputs validated as numbers
  - [ ] No use of `eval` with user input

- [ ] **Privileges**
  - [ ] Script doesn't run as root unnecessarily
  - [ ] Sudo used only for specific operations
  - [ ] No SUID bits on scripts

- [ ] **File Operations**
  - [ ] Temporary files created with `mktemp`
  - [ ] File permissions set explicitly
  - [ ] No symbolic link vulnerabilities
  - [ ] Cleanup registered with `trap`

- [ ] **Error Handling**
  - [ ] Script uses `set -euo pipefail`
  - [ ] Critical operations check exit codes
  - [ ] Errors logged with context

- [ ] **Logging**
  - [ ] Log files have secure permissions (640)
  - [ ] Sensitive data redacted from logs
  - [ ] Log injection prevented

- [ ] **Network**
  - [ ] HTTPS used for API calls
  - [ ] Certificates validated
  - [ ] Timeouts configured

---

**Last Updated**: 2025-12-12
