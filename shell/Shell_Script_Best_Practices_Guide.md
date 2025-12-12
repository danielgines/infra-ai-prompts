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

## 10. Advanced Debugging Techniques

> **Note**: This section provides detailed debugging methods and tool usage. For a quick debugging workflow, see `Shell_Script_Debugging_Instructions.md`.

### Basic Debugging Techniques

#### Technique 1: Echo Debugging

```bash
# Simple variable inspection
echo "DEBUG: Variable value: [$VAR]"

# Show special characters
printf "DEBUG: VAR=[%s]\n" "$VAR"

# Dump all variables at a point
declare -p | grep -E '^declare -[^-]*x'  # Exported variables only
```

#### Technique 2: Set -x Tracing

```bash
# Enable for entire script
#!/bin/bash
set -x

# Enable with custom prompt
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

# Output example:
# +(script.sh:42): main(): echo "Processing file"
```

#### Technique 3: Trap Command for Error Context

```bash
# Basic error trap
trap 'echo "Error on line $LINENO"' ERR

# Enhanced error trap with context
trap 'echo "Error: Command failed with exit code $?"
      echo "  Line: $LINENO"
      echo "  Command: $BASH_COMMAND"
      echo "  Function: ${FUNCNAME[*]}"' ERR

# Trap all exits for cleanup
trap 'echo "Exiting with code $?"; cleanup_function' EXIT
```

#### Technique 4: Log File Analysis

```bash
# Create log with timestamps
exec 1> >(ts '[%Y-%m-%d %H:%M:%S]' > /var/log/script.log)
exec 2>&1

# Or manually add timestamps
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a /var/log/script.log
}

log "Starting process"
```

---

### Advanced Debugging Techniques

#### Technique 5: BASH_XTRACEFD for Trace Redirection

**Problem**: `set -x` output mixes with regular output, making it hard to read.

**Solution**: Redirect trace to separate file descriptor.

```bash
#!/bin/bash

# Open FD 19 for trace output
exec 19>/var/log/script_trace.log

# Send all trace output to FD 19
BASH_XTRACEFD=19

# Enable tracing
set -x

# Regular output goes to stdout, trace goes to FD 19
echo "This goes to stdout"
cat /etc/hostname  # Command and output separated

# Close trace FD when done
exec 19>&-
```

#### Technique 6: Function Call Stack with caller

```bash
#!/bin/bash
shopt -s extdebug  # Required for caller to work properly

# Print full call stack
print_stack() {
    local frame=0
    echo "=== Call Stack ===" >&2
    while caller $frame; do
        ((frame++))
    done | while read line func file; do
        echo "  at $func() in $file:$line" >&2
    done
    echo "=================" >&2
}

# Use in error handler
trap 'echo "Error at line $LINENO"; print_stack; exit 1' ERR

function level3() {
    false  # This will trigger error
}

function level2() {
    level3
}

function level1() {
    level2
}

level1
```

**Output:**
```
Error at line 14
=== Call Stack ===
  at level3() in script.sh:14
  at level2() in script.sh:18
  at level1() in script.sh:22
  at main() in script.sh:25
=================
```

#### Technique 7: BASH_SOURCE and LINENO for Context

```bash
# Add context to every log message
log_with_context() {
    local msg="$1"
    echo "[${BASH_SOURCE[1]}:${BASH_LINENO[0]}] ${FUNCNAME[1]}: $msg" >&2
}

function process_data() {
    log_with_context "Starting data processing"
    # ... processing ...
    log_with_context "Data processing complete"
}
```

#### Technique 8: Subshell Debugging

**Problem**: Subshells inherit variables but changes don't propagate back.

```bash
# Demonstrate subshell issue
VAR="initial"
echo "Before: VAR=$VAR"

(
    VAR="changed_in_subshell"
    echo "Inside subshell: VAR=$VAR"
)

echo "After: VAR=$VAR"  # Still "initial"

# Debug subshells with explicit markers
(
    echo ">>> ENTERING SUBSHELL $$" >&2
    # subshell code
    echo "<<< EXITING SUBSHELL $$" >&2
) 2>&1 | sed 's/^/[SUBSHELL] /'
```

#### Technique 9: Pipe Failure Detection (PIPESTATUS)

```bash
# Problem: Only last command's exit code is captured
cat nonexistent.txt | grep pattern | wc -l
echo "Exit code: $?"  # Only shows wc exit code!

# Solution: Use PIPESTATUS array
cat nonexistent.txt | grep pattern | wc -l
echo "Pipe statuses: ${PIPESTATUS[@]}"
# Output: Pipe statuses: 1 1 0

# Proper error checking
cat file.txt | grep pattern | wc -l
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo "ERROR: cat failed"
elif [[ ${PIPESTATUS[1]} -ne 0 ]]; then
    echo "ERROR: grep failed"
fi

# Or use pipefail for automatic failure
set -o pipefail
cat nonexistent.txt | grep pattern | wc -l
echo "Exit code: $?"  # Now shows first failure!
```

#### Technique 10: Process Substitution Debugging

```bash
# Process substitution creates temporary FIFOs
# Debug by showing them explicitly

# See the FIFO
echo "FIFO: $(echo <(echo test))"
# Output: FIFO: /dev/fd/63

# Debug process substitution
diff <(ssh host1 'cat /etc/config') <(ssh host2 'cat /etc/config') || {
    echo "Configs differ"
    echo "Host1:" >&2
    ssh host1 'cat /etc/config' >&2
    echo "Host2:" >&2
    ssh host2 'cat /etc/config' >&2
}
```

#### Technique 11: Signal Handling Debugging

```bash
# Show signal handling setup
trap -p

# Debug signal handlers
trap 'echo "Received SIGTERM"; cleanup; exit 143' TERM
trap 'echo "Received SIGINT"; cleanup; exit 130' INT
trap 'echo "Received SIGHUP"; reload_config' HUP

# Test signal handling
kill -TERM $$ &  # Send signal to self

# Ignore signals during critical section
trap '' TERM INT  # Ignore TERM and INT
critical_operation
trap - TERM INT   # Restore default handlers
```

---

### Tool-Specific Debugging

#### Tool 1: ShellCheck (Static Analysis)

**Purpose**: Find bugs before running the script.

```bash
# Install ShellCheck
sudo apt-get install shellcheck  # Debian/Ubuntu
sudo dnf install ShellCheck      # Fedora/RHEL

# Basic usage
shellcheck script.sh

# Strict checking
shellcheck -s bash -o all script.sh

# Exclude specific warnings
shellcheck -e SC2034,SC2154 script.sh

# JSON output for automated processing
shellcheck -f json script.sh
```

**Common issues found:**
- SC2086: Variable not quoted (word splitting)
- SC2181: Checking exit code in wrong way
- SC2164: cd without checking if it succeeded
- SC2046: Unquoted command substitution
- SC2068: Array expanded incorrectly

#### Tool 2: Bashdb (Interactive Debugger)

**Purpose**: Step through script line by line.

```bash
# Install bashdb
sudo apt-get install bashdb  # Debian/Ubuntu

# Run script under debugger
bashdb script.sh

# Common bashdb commands:
# s         - Step (into functions)
# n         - Next (over functions)
# c         - Continue until breakpoint
# l         - List source code
# p VAR     - Print variable
# b 42      - Set breakpoint at line 42
# d 1       - Delete breakpoint 1
# bt        - Show backtrace (call stack)
# q         - Quit debugger
```

**Example session:**
```bash
$ bashdb script.sh
bashdb<0> b 42      # Set breakpoint at line 42
bashdb<1> c         # Continue to breakpoint
bashdb<2> p $VAR    # Print VAR value
bashdb<3> s         # Step into function
bashdb<4> bt        # Show call stack
bashdb<5> q         # Quit
```

---

#### Tool 3: strace (System Call Tracing)

**Purpose**: See exactly what system calls the script makes.

```bash
# Basic usage
strace ./script.sh

# Write trace to file
strace -o trace.log ./script.sh

# Follow forked processes
strace -f ./script.sh

# Only show specific system calls
strace -e trace=file ./script.sh      # File operations only
strace -e trace=process ./script.sh   # Process operations
strace -e trace=network ./script.sh   # Network operations
strace -e trace=open,read,write ./script.sh  # Specific calls

# Show timestamps
strace -t ./script.sh           # Time of day
strace -tt ./script.sh          # Microsecond precision
strace -r ./script.sh           # Relative time between calls

# Show call duration
strace -T ./script.sh

# Attach to running process
strace -p $(pgrep -f script.sh)

# Trace with full string output (no truncation)
strace -s 4096 ./script.sh
```

**Common debugging scenarios:**

```bash
# Find which config files are being read
strace -e trace=open,openat ./script.sh 2>&1 | grep -E '\.conf|\.cfg'

# Find why file isn't found
strace -e trace=file ./script.sh 2>&1 | grep ENOENT

# Find permission denials
strace -e trace=file ./script.sh 2>&1 | grep EACCES

# Find what command is being executed
strace -e trace=execve ./script.sh

# See environment passed to child processes
strace -e trace=execve -v ./script.sh
```

**Reading strace output:**

```
open("/etc/config.conf", O_RDONLY)      = -1 ENOENT (No such file or directory)
```

- `ENOENT`: File not found
- `EACCES`: Permission denied
- `EINVAL`: Invalid argument
- `EAGAIN`: Resource temporarily unavailable

---

#### Tool 4: ltrace (Library Call Tracing)

**Purpose**: Trace library function calls (libc, etc.).

```bash
# Install ltrace
sudo apt-get install ltrace  # Debian/Ubuntu

# Basic usage
ltrace ./script.sh

# Follow child processes
ltrace -f ./script.sh

# Show timestamps
ltrace -t ./script.sh

# Write to file
ltrace -o trace.log ./script.sh

# Count calls and show summary
ltrace -c ./script.sh

# Filter specific functions
ltrace -e malloc,free ./script.sh
ltrace -e '*alloc*' ./script.sh  # All allocation functions
```

**Use cases:**

```bash
# Debug memory allocation issues
ltrace -e malloc,calloc,realloc,free ./script.sh

# Debug string operations
ltrace -e 'str*' ./script.sh

# Debug file operations
ltrace -e '*file*' ./script.sh
```

---

#### Tool 5: lsof (List Open Files)

**Purpose**: Debug file descriptor leaks and see what files are open.

```bash
# Install lsof
sudo apt-get install lsof  # Debian/Ubuntu

# Show all files opened by script
lsof -p $(pgrep -f script.sh)

# Show only regular files (no pipes, sockets)
lsof -p $$ -a -d 0-9999 -a -t f

# Monitor file descriptors in real-time
watch -n 1 "lsof -p $(pgrep -f script.sh) | wc -l"

# Find scripts with too many open files
for pid in $(pgrep bash); do
    count=$(lsof -p $pid 2>/dev/null | wc -l)
    if [[ $count -gt 100 ]]; then
        echo "PID $pid has $count open files"
        ps -p $pid -o cmd=
    fi
done

# Debug file descriptor leak
cat > fd_test.sh <<'EOF'
#!/bin/bash
echo "Open FDs at start: $(ls /proc/$$/fd | wc -l)"

# Open files without closing
for i in {1..100}; do
    exec {fd}< /etc/hostname
    # BUG: Never closed!
done

echo "Open FDs after loop: $(ls /proc/$$/fd | wc -l)"
ls -la /proc/$$/fd
EOF
```

---

#### Tool 6: ps and pstree (Process Analysis)

```bash
# Show process tree
pstree -p $$

# Show process with full command
ps -p $$ -f

# Show all bash processes
ps aux | grep bash

# Show process environment
cat /proc/$$/environ | tr '\0' '\n'

# Show process limits
cat /proc/$$/limits

# Monitor process resources
watch -n 1 "ps -p $(pgrep -f script.sh) -o pid,ppid,vsz,rss,%cpu,%mem,etime,cmd"

# Find zombie processes
ps aux | awk '$8 ~ /Z/ {print}'

# Find parent of zombies
ps -ef | grep defunct
```

---

#### Tool 7: netstat/ss (Network Debugging)

```bash
# Show network connections by script
lsof -i -a -p $(pgrep -f script.sh)

# Show listening ports
ss -tlnp | grep bash

# Monitor network activity
watch -n 1 "ss -s"

# Check if specific port is in use
if ss -tln | grep -q ':8080 '; then
    echo "Port 8080 already in use"
fi

# Find which process is using a port
lsof -i :8080
```

---

### Performance Profiling

#### Profiling Technique 1: Time Command

```bash
# Simple timing
time ./script.sh

# Detailed timing
/usr/bin/time -v ./script.sh

# Output includes:
#   - Real (wall clock) time
#   - User CPU time
#   - System CPU time
#   - Memory usage
#   - I/O operations
#   - Context switches

# Time specific sections
TIMEFORMAT='Section took %R seconds'
time {
    expensive_operation
}
```

---

#### Profiling Technique 2: Set -x with Timestamps

```bash
# Add timestamps to debug output
PS4='+ $(date "+%Y-%m-%d %H:%M:%S.%3N"): '
set -x

# Or with relative timing
START_TIME=$SECONDS
PS4='+ [$(($SECONDS - $START_TIME))s]: '
set -x

# Output shows how long each command takes:
# + [0s]: command1
# + [2s]: command2  # Took 2 seconds
# + [5s]: command3  # Took 3 seconds
```

---

#### Profiling Technique 3: Identifying Bottlenecks

```bash
# Profile each function
profile_function() {
    local func_name="$1"
    shift
    local start=$(date +%s%N)

    "$func_name" "$@"
    local result=$?

    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))  # Convert to milliseconds

    echo "[PROFILE] $func_name took ${duration}ms" >&2
    return $result
}

# Use it
profile_function slow_operation arg1 arg2

# Automatic profiling with trap
profile_all_commands() {
    trap 'echo "[CMD] $BASH_COMMAND"' DEBUG
    SECONDS=0
}

# Find slow external commands
strace -c ./script.sh  # Shows system call counts and time
```

---

#### Profiling Technique 4: Subprocess Overhead Detection

```bash
# Count subprocess invocations
PS4='+ $(echo "SUBPROC" >&2; exit): '
set -x
./script.sh 2>&1 | grep -c SUBPROC

# Inefficient: Subprocess in loop
for file in *.txt; do
    basename "$file"  # External command!
done

# Efficient: Use parameter expansion
for file in *.txt; do
    echo "${file##*/}"  # Built-in string operation
done

# Measure difference
time for file in *.txt; do basename "$file" > /dev/null; done
time for file in *.txt; do echo "${file##*/}" > /dev/null; done
```

---

#### Profiling Technique 5: External Command Optimization

```bash
# Inefficient: Multiple external commands
for file in *.log; do
    if grep -q ERROR "$file"; then
        echo "$file" >> error_files.txt
    fi
done

# Efficient: Single grep with multiple files
grep -l ERROR *.log > error_files.txt

# Inefficient: Repeated sed calls
for file in *.txt; do
    sed -i 's/old/new/' "$file"
done

# Efficient: Parallel execution
parallel sed -i 's/old/new/' ::: *.txt

# Or xargs
printf '%s\n' *.txt | xargs -P 4 -I {} sed -i 's/old/new/' {}
```

---

### Memory Debugging

#### Memory Technique 1: Detecting Memory Leaks

```bash
# Monitor memory usage over time
monitor_memory() {
    local pid=$1
    local interval=${2:-1}

    while kill -0 "$pid" 2>/dev/null; do
        ps -p "$pid" -o pid,vsz,rss,%mem,etime,cmd
        sleep "$interval"
    done
}

# Use it
./long_running_script.sh &
monitor_memory $! 5 > memory_log.txt

# Check for growing memory
awk '{if (NR>1) print $3}' memory_log.txt |
    gnuplot -e "set terminal dumb; plot '-' with lines"
```

---

#### Memory Technique 2: Process Memory Monitoring

```bash
# Show memory map
pmap -x $$

# Show detailed memory info
cat /proc/$$/status | grep -E '^Vm|^Rss'

# Monitor memory in real-time
watch -n 1 "ps -p $$ -o pid,vsz,rss,%mem,cmd"

# Find memory-intensive operations
/usr/bin/time -v ./script.sh |& grep -E 'Maximum resident set size|Average resident set size'
```

---

#### Memory Technique 3: Large Array/Variable Management

```bash
# Problem: Large arrays consume memory
declare -a huge_array
for i in {1..1000000}; do
    huge_array+=("item_$i")
done

# Solution: Process data in chunks
process_in_chunks() {
    local chunk_size=1000
    local chunk=()

    while read -r line; do
        chunk+=("$line")

        if [[ ${#chunk[@]} -ge $chunk_size ]]; then
            # Process chunk
            process_chunk "${chunk[@]}"
            chunk=()  # Clear
        fi
    done < input.txt

    # Process remaining
    if [[ ${#chunk[@]} -gt 0 ]]; then
        process_chunk "${chunk[@]}"
    fi
}

# Or use streaming with pipes
grep pattern huge_file.txt | while read -r line; do
    process "$line"
done  # No large array needed
```

---

#### Memory Technique 4: Temporary File Accumulation

```bash
# Problem: Temp files not cleaned up
process_data() {
    local temp=$(mktemp)
    # Process data
    # BUG: temp file never removed if function fails
}

# Solution: Trap cleanup
process_data() {
    local temp=$(mktemp)
    trap "rm -f '$temp'" RETURN  # Clean up on function return

    # Process data

    # Explicit cleanup
    rm -f "$temp"
    trap - RETURN
}

# Check for temp file leaks
watch -n 5 "ls -lh /tmp | wc -l"

# Clean up old temp files
find /tmp -name "myapp.*" -mtime +1 -delete
```

---

### Debugging Examples

#### Example 1: Debugging a Hanging Script

**Problem**: Script hangs indefinitely with no output.

```bash
#!/bin/bash
# hanging_script.sh

while read -r line; do
    echo "Processing: $line"
done

echo "Done"
```

**Debugging process:**

```bash
# Step 1: Run with timeout to confirm hang
timeout 5 ./hanging_script.sh
echo "Exit code: $?"  # 124 = timeout occurred

# Step 2: Identify where it hangs
bash -x hanging_script.sh &
SCRIPT_PID=$!
sleep 2
kill -QUIT $SCRIPT_PID  # Print stack trace

# Step 3: Analyze - Script is waiting for input from stdin!
# The 'while read' has no input source

# Solution: Provide input or redirect from /dev/null
while read -r line; do
    echo "Processing: $line"
done < /dev/null

echo "Done"
```

---

#### Example 2: Debugging Systemd Service Failures

**Problem**: Script works manually but fails in systemd.

```bash
#!/bin/bash
# systemd_service.sh

echo "Starting service..."
cd /opt/myapp
./process_data.sh
```

**Debugging:**

```bash
# Step 1: Check service status
systemctl status myapp.service

# Output shows:
# Main PID: 12345 (code=exited, status=1/FAILURE)
# cd: /opt/myapp: Permission denied

# Step 2: Check systemd user
systemctl show myapp.service | grep User
# User=myappuser

# Step 3: Check directory permissions
ls -ld /opt/myapp
# drwxr-x--- root root /opt/myapp
# Problem: myappuser can't access!

# Step 4: Fix ownership
sudo chown -R myappuser:myappuser /opt/myapp

# Step 5: Verify manually as service user
sudo -u myappuser bash -x /opt/myapp/systemd_service.sh
```

---

#### Example 3: Debugging Performance Issues

**Problem**: Script takes 10 minutes to process 100 files, used to take 1 minute.

```bash
#!/bin/bash
# slow_script.sh

for file in *.txt; do
    # Process each file
    grep -o 'ERROR' "$file" | wc -l > "${file}.count"
done
```

**Debugging:**

```bash
# Step 1: Profile with time
time ./slow_script.sh

# Step 2: Profile with detailed timing
/usr/bin/time -v ./slow_script.sh
# Shows:
#   - User time: 0.5s
#   - System time: 9.5s  # High! Excessive I/O
#   - File system operations: 10000

# Step 3: Identify bottleneck - Creating small files in loop
# Solution: Parallelize or batch operations

# Fix 1: Parallel processing
export -f process_file
parallel process_file ::: *.txt

# Fix 2: Reduce I/O operations
{
    for file in *.txt; do
        count=$(grep -co 'ERROR' "$file")
        echo "${file}.count:$count"
    done
} | while IFS=: read file count; do
    echo "$count" > "$file"
done

# Result: 10 minutes → 30 seconds
```

---

**Last Updated**: 2025-12-12
