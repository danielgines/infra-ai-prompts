# Shell Script Best Practices Guide

> **Purpose**: Comprehensive guide to shell script development following industry best practices.
> **Audience**: Developers writing production-ready Bash scripts.

---

## 1. Structure and Syntax

### Shebang and Error Handling

```bash
#!/bin/bash
# Script name and description
# Usage: ./script.sh [options]

set -euo pipefail  # Strict mode for safety

# Alternative: Set flags individually
# set -e  # Exit on error
# set -u  # Exit on undefined variable
# set -o pipefail  # Exit if any command in pipeline fails
```

**What each flag does**:
- `-e`: Exit immediately if any command fails
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Fail if any command in a pipeline fails

### Variable Expansion

```bash
# ❌ BAD - Unquoted variables (word splitting, glob expansion)
for file in $FILES; do
    cat $file
done

# ✅ GOOD - Quoted variables (safe)
for file in "$FILES"; do
    cat "$file"
done

# ✅ GOOD - Arrays for lists
files=("file1.txt" "file2.txt" "file with spaces.txt")
for file in "${files[@]}"; do
    cat "$file"
done
```

### Local Variables in Functions

```bash
# ❌ BAD - Global variables pollute namespace
function calculate() {
    result=$(( $1 + $2 ))
    echo "$result"
}

# ✅ GOOD - Local variables contained
function calculate() {
    local num1="$1"
    local num2="$2"
    local result=$(( num1 + num2 ))
    echo "$result"
}
```

### Avoiding Unnecessary Subshells

```bash
# ❌ BAD - Subshell for simple assignment
var=$(echo "value")

# ✅ GOOD - Direct assignment
var="value"

# ❌ BAD - Subshell in pipeline
cat file.txt | $(grep pattern)

# ✅ GOOD - Direct pipeline
cat file.txt | grep pattern

# Subshells ARE needed when:
# - Capturing command output: var=$(command)
# - Changing directory temporarily: (cd /tmp && do_work)
```

---

## 2. Variables and Assignments

### Naming Conventions

```bash
# ✅ GOOD - Clear, descriptive names
readonly SYSTEMD_DIR="/etc/systemd/system"
readonly LOG_DIR="/var/log/myapp"
readonly APP_USER="myapp"
readonly APP_GROUP="myapp"

# Use UPPERCASE for constants
readonly MAX_RETRIES=3
readonly TIMEOUT=30

# Use lowercase for regular variables
service_name="myapp.service"
config_file="/etc/myapp/config.ini"

# Use readonly for constants to prevent modification
readonly DATABASE_URL="postgresql://localhost/mydb"
```

### Dynamic Path Construction

```bash
# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get project root (parent of script directory)
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Construct paths relative to script
CONFIG_FILE="$SCRIPT_DIR/config.ini"
LOG_FILE="$SCRIPT_DIR/logs/app.log"

# Alternative using justfile_directory equivalent
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
```

### Arrays for Lists

```bash
# ✅ GOOD - Use arrays for lists
services=(
    "web.service"
    "api.service"
    "worker.service"
)

# Iterate over array
for service in "${services[@]}"; do
    systemctl status "$service"
done

# Array length
echo "Total services: ${#services[@]}"

# Check if array contains element
if [[ " ${services[*]} " =~ " web.service " ]]; then
    echo "Found web.service"
fi
```

### Boolean Variables

```bash
# ❌ BAD - String comparisons
DEBUG="true"
if [ "$DEBUG" = "true" ]; then
    echo "Debug mode"
fi

# ✅ GOOD - Boolean logic
DEBUG=true  # or false
if $DEBUG; then
    echo "Debug mode"
fi

# ✅ GOOD - Check for truthiness
if [[ "$VERBOSE" == "true" ]] || [[ "$VERBOSE" == "1" ]]; then
    echo "Verbose mode"
fi
```

---

## 3. Functions and Modularity

### Single Responsibility Principle

```bash
# ❌ BAD - Function does too much
function deploy() {
    check_prerequisites
    build_application
    run_tests
    create_backup
    stop_service
    deploy_files
    start_service
    verify_deployment
    send_notification
}

# ✅ GOOD - Each function does one thing
function check_prerequisites() {
    check_command "systemctl"
    check_command "rsync"
    check_user "$APP_USER"
}

function build_application() {
    log "INFO" "Building application..."
    npm run build
}

function deploy() {
    check_prerequisites
    build_application
    run_tests
    perform_deployment
}
```

### Descriptive Function Names

```bash
# ❌ BAD - Unclear names
function do_stuff() { ... }
function proc() { ... }
function x() { ... }

# ✅ GOOD - Clear verb-noun format
function validate_config_file() { ... }
function create_backup() { ... }
function restart_service() { ... }
function check_service_health() { ... }
```

### Return Status

```bash
# ✅ GOOD - Functions return meaningful status
function create_user() {
    local username="$1"

    if id "$username" &>/dev/null; then
        log "INFO" "User $username already exists"
        return 0  # Success (idempotent)
    fi

    if useradd --system "$username"; then
        log "INFO" "Created user $username"
        return 0  # Success
    else
        log "ERROR" "Failed to create user $username"
        return 1  # Failure
    fi
}

# Usage
if create_user "myapp"; then
    echo "User created or already exists"
else
    echo "Failed to create user"
    exit 1
fi
```

### Function Documentation

```bash
# ✅ GOOD - Document complex functions
# Creates a system user for the application
# Arguments:
#   $1 - Username
#   $2 - Group name (optional, defaults to username)
#   $3 - Home directory (optional, defaults to /opt/username)
# Returns:
#   0 - Success
#   1 - Failure
function create_system_user() {
    local username="$1"
    local group="${2:-$username}"
    local home_dir="${3:-/opt/$username}"

    # Check if user exists
    if id "$username" &>/dev/null; then
        return 0
    fi

    # Create group if needed
    if ! getent group "$group" &>/dev/null; then
        groupadd --system "$group" || return 1
    fi

    # Create user
    useradd --system \
            --gid "$group" \
            --home-dir "$home_dir" \
            --no-create-home \
            --shell /bin/false \
            "$username" || return 1

    return 0
}
```

---

## 4. Error Handling

### Centralized Error Function

```bash
# ✅ GOOD - Central error handling function
function error() {
    local message="$1"
    local exit_code="${2:-1}"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $message" >&2

    # Send notification
    notify_admin "Error: $message"

    # Cleanup
    cleanup

    exit "$exit_code"
}

# Usage
if [ ! -f "$CONFIG_FILE" ]; then
    error "Configuration file not found: $CONFIG_FILE"
fi

if ! systemctl start myapp.service; then
    error "Failed to start myapp.service" 2
fi
```

### Exit Codes

```bash
# Use standard exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_MISUSE=2
readonly EXIT_CONFIG_ERROR=3
readonly EXIT_PERMISSION_DENIED=4

function validate_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        error "Config file not found" $EXIT_CONFIG_ERROR
    fi

    if [ ! -r "$CONFIG_FILE" ]; then
        error "Cannot read config file" $EXIT_PERMISSION_DENIED
    fi
}
```

### Trap Handlers for Cleanup

```bash
#!/bin/bash
set -euo pipefail

# Cleanup function
function cleanup() {
    local exit_code=$?

    echo "Cleaning up..."

    # Remove temporary files
    rm -f "$TEMP_FILE" 2>/dev/null || true

    # Kill background processes
    jobs -p | xargs -r kill 2>/dev/null || true

    # Restore original state
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$ORIGINAL_FILE"
    fi

    echo "Cleanup complete (exit code: $exit_code)"
    exit $exit_code
}

# Register cleanup on exit
trap cleanup EXIT INT TERM

# Your script code here
```

---

## 5. Execution and Permissions

### Privilege Checking

```bash
# Check if running as root
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root. Use: sudo $0"
    fi
}

# Check if NOT running as root
function check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        error "This script should NOT be run as root"
    fi
}

# Check if sudo is available
function check_sudo() {
    if ! command -v sudo &>/dev/null; then
        error "sudo command not found"
    fi

    # Check if user can sudo without password (for automation)
    if ! sudo -n true 2>/dev/null; then
        echo "Note: This script will prompt for sudo password"
    fi
}

# Use at start of script
check_root
```

### Avoiding Redundant Sudo

```bash
# ❌ BAD - Script already running as root
if [ "$EUID" -eq 0 ]; then
    sudo systemctl start myapp.service  # Unnecessary sudo
fi

# ✅ GOOD - Only use sudo if not root
if [ "$EUID" -ne 0 ]; then
    sudo systemctl start myapp.service
else
    systemctl start myapp.service
fi

# ✅ BETTER - Re-execute as root if needed
if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

# Now running as root, no sudo needed
systemctl start myapp.service
```

### User and Group Validation

```bash
# Check if user exists
function check_user() {
    local username="$1"

    if ! id "$username" &>/dev/null; then
        error "User '$username' does not exist"
    fi
}

# Check if group exists
function check_group() {
    local group="$1"

    if ! getent group "$group" &>/dev/null; then
        error "Group '$group' does not exist"
    fi
}

# Usage
check_user "$APP_USER"
check_group "$APP_GROUP"
```

### Explicit Permission Setting

```bash
# ✅ GOOD - Set permissions explicitly
function create_directory() {
    local dir="$1"
    local owner="$2"
    local group="$3"
    local mode="$4"

    mkdir -p "$dir"
    chown "$owner:$group" "$dir"
    chmod "$mode" "$dir"

    echo "Created $dir with permissions $mode, owner $owner:$group"
}

# Usage
create_directory "/var/log/myapp" "$APP_USER" "$APP_GROUP" "750"
create_directory "/etc/myapp" "root" "root" "755"
```

---

## 6. File Operations

### Existence Checks

```bash
# Check file existence before use
function process_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        error "File not found: $file"
    fi

    # Process file
    cat "$file"
}

# Check directory existence
function check_directory() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        error "Directory not found: $dir"
    fi
}

# Check if file is readable
function check_readable() {
    local file="$1"

    if [ ! -r "$file" ]; then
        error "File not readable: $file"
    fi
}

# Check if file is writable
function check_writable() {
    local file="$1"

    if [ ! -w "$file" ]; then
        error "File not writable: $file"
    fi
}
```

### Avoiding Redundant Operations

```bash
# ✅ GOOD - Only copy if files are different
function copy_if_different() {
    local src="$1"
    local dest="$2"

    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        echo "File $dest already up to date"
        return 0
    fi

    cp "$src" "$dest"
    echo "Copied $src to $dest"
}

# ✅ GOOD - Only create directory if needed
function ensure_directory() {
    local dir="$1"

    if [ -d "$dir" ]; then
        return 0
    fi

    mkdir -p "$dir"
    echo "Created directory: $dir"
}
```

### Validating Critical Files

```bash
# Validate sudoers file before installing
function install_sudoers() {
    local sudoers_file="$1"

    if ! visudo -c -f "$sudoers_file"; then
        error "Invalid sudoers syntax in $sudoers_file"
    fi

    cp "$sudoers_file" /etc/sudoers.d/
    chmod 440 /etc/sudoers.d/"$(basename "$sudoers_file")"
}

# Validate systemd unit file syntax
function validate_service_file() {
    local service_file="$1"

    if ! systemd-analyze verify "$service_file" 2>/dev/null; then
        log "WARN" "Service file may have issues: $service_file"
    fi
}

# Validate JSON configuration
function validate_json() {
    local json_file="$1"

    if ! jq empty "$json_file" 2>/dev/null; then
        error "Invalid JSON syntax in $json_file"
    fi
}
```

---

## 7. Systemd Integration

### Daemon Reload After Changes

```bash
# ✅ GOOD - Always reload after unit file changes
function install_service_file() {
    local service_file="$1"
    local dest="/etc/systemd/system/$(basename "$service_file")"

    copy_if_different "$service_file" "$dest"
    chmod 644 "$dest"

    # Reload systemd daemon
    systemctl daemon-reload

    echo "Installed service: $dest"
}
```

### Idempotent Service Management

```bash
# ✅ GOOD - Check before enabling
function enable_service() {
    local service="$1"

    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "Service $service already enabled"
        return 0
    fi

    systemctl enable "$service"
    echo "Enabled service: $service"
}

# ✅ GOOD - Check before starting
function start_service() {
    local service="$1"

    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "Service $service already active"
        return 0
    fi

    systemctl start "$service"
    echo "Started service: $service"
}

# Combined: enable and start
function enable_and_start_service() {
    local service="$1"

    enable_service "$service"
    start_service "$service"

    # Verify service started successfully
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        error "Service $service failed to start"
    fi

    echo "✓ Service $service is active"
}
```

### Service Status Feedback

```bash
# Provide clear feedback on service status
function show_service_status() {
    local service="$1"

    echo "Service: $service"
    echo "  Enabled: $(systemctl is-enabled "$service" 2>/dev/null || echo "unknown")"
    echo "  Active:  $(systemctl is-active "$service" 2>/dev/null || echo "unknown")"

    # Show recent logs
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo ""
        echo "Recent logs:"
        journalctl -u "$service" -n 5 --no-pager
    fi
}
```

### Service Health Verification

```bash
# Wait for service to become healthy
function wait_for_service() {
    local service="$1"
    local max_wait="${2:-30}"  # Default 30 seconds
    local waited=0

    echo "Waiting for $service to become active..."

    while [ $waited -lt $max_wait ]; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            echo "✓ Service $service is active"
            return 0
        fi

        sleep 1
        waited=$((waited + 1))
        echo -n "."
    done

    echo ""
    error "Service $service failed to become active within ${max_wait}s"
}

# Usage
enable_and_start_service "myapp.service"
wait_for_service "myapp.service" 60
```

---

## 8. General Best Practices

### Avoid Repetition (DRY Principle)

```bash
# ❌ BAD - Repetitive code
systemctl enable web.service
echo "Enabled web.service"
systemctl start web.service
echo "Started web.service"

systemctl enable api.service
echo "Enabled api.service"
systemctl start api.service
echo "Started api.service"

# ✅ GOOD - Function eliminates repetition
function setup_service() {
    local service="$1"

    enable_and_start_service "$service"
}

setup_service "web.service"
setup_service "api.service"
```

### Clear and Consistent Messages

```bash
# ✅ GOOD - Timestamped, leveled messages
function log() {
    local level="$1"
    shift
    local message="$*"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
}

log "INFO" "Starting deployment"
log "WARN" "No backup found"
log "ERROR" "Deployment failed"

# ✅ GOOD - Progress indicators
echo "Installing dependencies..."
for dep in "${DEPENDENCIES[@]}"; do
    install_dependency "$dep"
    echo "  ✓ $dep installed"
done
echo "✓ All dependencies installed"
```

### Debug Mode Support

```bash
# Enable debug mode via environment variable
DEBUG="${DEBUG:-false}"

function debug() {
    if [ "$DEBUG" = "true" ]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Usage
debug "Variable value: $VAR"
debug "Entering function: ${FUNCNAME[0]}"

# Alternative: Use set -x for full tracing
if [ "$DEBUG" = "true" ]; then
    set -x
fi
```

### Script Self-Documentation

```bash
#!/bin/bash
# deploy.sh - Deploy application to production
# Usage: ./deploy.sh [environment]
# Environments: staging, production
# Requirements: systemctl, rsync, sudo access

set -euo pipefail

function show_usage() {
    cat << EOF
Usage: $0 [environment]

Deploy application to specified environment.

Arguments:
    environment    Target environment (staging|production)

Options:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
    --dry-run      Show what would be done without doing it

Examples:
    $0 staging
    $0 production --verbose
    $0 staging --dry-run

EOF
    exit 0
}

# Parse arguments
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    show_usage
fi
```

---

## 9. Security and Reliability

### Input Validation

```bash
# ✅ GOOD - Validate all external inputs
function validate_environment() {
    local env="$1"
    local valid_envs=("staging" "production")

    for valid_env in "${valid_envs[@]}"; do
        if [ "$env" = "$valid_env" ]; then
            return 0
        fi
    done

    error "Invalid environment: $env (valid: ${valid_envs[*]})"
}

# Validate before use
validate_environment "$1"
ENVIRONMENT="$1"
```

### Secure File Permissions

```bash
# ✅ GOOD - Protect sensitive files
function create_credential_file() {
    local cred_file="$1"

    # Create with restrictive permissions
    touch "$cred_file"
    chmod 600 "$cred_file"  # Read/write by owner only
    chown "$APP_USER:$APP_GROUP" "$cred_file"

    # Write credentials
    cat > "$cred_file" << EOF
DB_PASSWORD="$DB_PASSWORD"
API_KEY="$API_KEY"
EOF

    echo "Created credential file: $cred_file (permissions: 600)"
}

# Verify permissions before using
function verify_file_permissions() {
    local file="$1"
    local expected_perms="$2"

    local actual_perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file")

    if [ "$actual_perms" != "$expected_perms" ]; then
        error "Insecure permissions on $file: $actual_perms (expected: $expected_perms)"
    fi
}
```

### Test and Validate Syntax

```bash
# Validate script syntax before deployment
function validate_script() {
    local script="$1"

    # Check syntax
    if ! bash -n "$script"; then
        error "Syntax error in $script"
    fi

    # Run shellcheck if available
    if command -v shellcheck &>/dev/null; then
        if ! shellcheck "$script"; then
            log "WARN" "ShellCheck found issues in $script"
        fi
    fi
}

# Validate before copying to production
validate_script "deploy.sh"
```

---

## Quick Reference Table

| Aspect | Best Practice |
|--------|---------------|
| **Shebang** | `#!/bin/bash` |
| **Fail Fast** | `set -euo pipefail` |
| **Variables** | Always quote: `"$VAR"` |
| **Local Variables** | Use `local` in functions |
| **Functions** | Small, single responsibility, descriptive names |
| **Error Handling** | Centralized error function, trap cleanup |
| **Permissions** | Check privileges, set explicitly with `chmod`/`chown` |
| **Files** | Check existence, avoid redundant operations |
| **Systemd** | Use `is-active`/`is-enabled`, reload daemon after changes |
| **Messages** | Timestamped, leveled (INFO/WARN/ERROR) |
| **Debug** | Support DEBUG variable/flag |
| **Security** | Validate inputs, protect sensitive files |

---

## Complete Example Script

```bash
#!/bin/bash
# deploy-app.sh - Deploy application with systemd integration
# Usage: ./deploy-app.sh <environment>

set -euo pipefail

# Configuration
readonly APP_NAME="myapp"
readonly APP_USER="myapp"
readonly APP_GROUP="myapp"
readonly APP_HOME="/opt/myapp"
readonly LOG_FILE="/var/log/myapp-deploy.log"

# Enable debug mode
DEBUG="${DEBUG:-false}"

# Logging function
function log() {
    local level="$1"
    shift
    local message="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

function debug() {
    if [ "$DEBUG" = "true" ]; then
        log "DEBUG" "$*"
    fi
}

# Error handling
function error() {
    log "ERROR" "$*"
    exit 1
}

# Cleanup
function cleanup() {
    debug "Cleanup function called"
}

trap cleanup EXIT

# Privilege check
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root"
    fi
}

# Create system user
function create_user() {
    if id "$APP_USER" &>/dev/null; then
        log "INFO" "User $APP_USER already exists"
        return 0
    fi

    useradd --system \
            --gid "$APP_GROUP" \
            --home-dir "$APP_HOME" \
            --no-create-home \
            --shell /bin/false \
            "$APP_USER"

    log "INFO" "Created user $APP_USER"
}

# Create directories
function create_directories() {
    local dirs=(
        "$APP_HOME"
        "$APP_HOME/bin"
        "$APP_HOME/config"
        "$APP_HOME/logs"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            chown "$APP_USER:$APP_GROUP" "$dir"
            chmod 750 "$dir"
            log "INFO" "Created directory: $dir"
        fi
    done
}

# Install service file
function install_service() {
    local service_file="$APP_NAME.service"

    if [ ! -f "$service_file" ]; then
        error "Service file not found: $service_file"
    fi

    cp "$service_file" "/etc/systemd/system/"
    chmod 644 "/etc/systemd/system/$service_file"

    systemctl daemon-reload
    log "INFO" "Installed service file"
}

# Enable and start service
function start_service() {
    if ! systemctl is-enabled "$APP_NAME.service" >/dev/null 2>&1; then
        systemctl enable "$APP_NAME.service"
        log "INFO" "Enabled $APP_NAME.service"
    fi

    if systemctl is-active "$APP_NAME.service" >/dev/null 2>&1; then
        systemctl restart "$APP_NAME.service"
        log "INFO" "Restarted $APP_NAME.service"
    else
        systemctl start "$APP_NAME.service"
        log "INFO" "Started $APP_NAME.service"
    fi

    # Verify service started
    if ! systemctl is-active "$APP_NAME.service" >/dev/null 2>&1; then
        error "Service failed to start"
    fi

    log "INFO" "✓ Service is active"
}

# Main deployment
function main() {
    log "INFO" "=== Starting deployment ==="

    check_root
    create_user
    create_directories
    install_service
    start_service

    log "INFO" "=== Deployment complete ==="
}

main "$@"
```

---

**Last Updated**: 2025-12-12
