# Shell Script Examples

> **Purpose**: Production-ready shell script examples demonstrating best practices.
> **Audience**: Developers learning shell scripting patterns for real-world use cases.

---

## Overview

This directory contains complete, working shell scripts that follow all best practices from the Shell module. Each script demonstrates patterns for common operational tasks.

---

## Examples

### 1. `system_setup.sh`
**Purpose**: System initialization and user/service account setup

**Demonstrates**:
- User and group creation
- Directory structure creation
- Permission management
- Idempotent operations
- Error handling

**Use Case**: Initial server provisioning, application user setup

---

### 2. `service_deployment.sh`
**Purpose**: Deploy and manage systemd services

**Demonstrates**:
- Systemd service file installation
- Service state management
- Health check verification
- Rollback on failure
- Logging and monitoring integration

**Use Case**: Application deployment, service updates

---

### 3. `backup_automation.sh`
**Purpose**: Automated backup with rotation and validation

**Demonstrates**:
- Lock file management (prevent concurrent runs)
- Backup creation and verification
- Rotation policy implementation
- Error notification
- State persistence

**Use Case**: Daily/weekly backups, disaster recovery preparation

---

### 4. `health_check_monitor.sh`
**Purpose**: Continuous service health monitoring

**Demonstrates**:
- HTTP health check polling
- Retry logic with exponential backoff
- Alert notification (multiple channels)
- Metrics collection
- Background execution patterns

**Use Case**: Service monitoring, alerting automation

---

## Running the Examples

### Prerequisites

All examples require:
- Bash 4.0+ (check: `bash --version`)
- Ubuntu/Debian Linux (tested on Ubuntu 22.04)
- systemd (for service examples)

### Testing Safely

**DO NOT run examples directly on production systems!**

Test in a safe environment:

```bash
# Option 1: Docker container
docker run --rm -it -v $(pwd):/examples ubuntu:22.04 bash
cd /examples
./system_setup.sh --dry-run

# Option 2: Virtual machine
# Create a VM with Ubuntu 22.04
# Copy examples to VM
# Test with --dry-run first
```

### Syntax Validation

Validate scripts before running:

```bash
# Check syntax
bash -n system_setup.sh

# Run shellcheck (install: apt-get install shellcheck)
shellcheck system_setup.sh

# Dry run (shows what would happen without doing it)
./system_setup.sh --dry-run
```

---

## Example Modifications

### Customizing for Your Environment

Each script includes configuration variables at the top:

```bash
# Configuration (modify these for your environment)
readonly APP_NAME="myapp"
readonly APP_USER="svc-myapp"
readonly INSTALL_DIR="/opt/myapp"
```

Common customizations:
- Change application name and paths
- Adjust log locations
- Modify notification methods (email, Slack, PagerDuty)
- Update health check endpoints
- Customize backup retention periods

### Adding Features

Each script is modular - add new functions easily:

```bash
# Add new function
function send_slack_notification() {
    local message="$1"
    local webhook_url="${SLACK_WEBHOOK_URL:-}"

    if [[ -n "$webhook_url" ]]; then
        curl -X POST -H 'Content-type: application/json' \
             --data "{\"text\": \"$message\"}" \
             "$webhook_url"
    fi
}

# Use in existing error handler
function error() {
    log "ERROR" "$*"
    send_slack_notification "❌ Error: $*"
    exit 1
}
```

---

## Learning Path

### Beginner

Start with `system_setup.sh`:
1. Read through the entire script
2. Understand the error handling pattern
3. Run with `--dry-run` to see what it would do
4. Modify configuration for a test application
5. Run in Docker container

### Intermediate

Move to `service_deployment.sh`:
1. Understand systemd service management
2. Learn health check patterns
3. Study rollback implementation
4. Modify for your service type

### Advanced

Study `backup_automation.sh` and `health_check_monitor.sh`:
1. Learn lock file management
2. Understand state persistence
3. Implement notification systems
4. Build monitoring dashboards

---

## Pattern Reference

### Error Handling Pattern
```bash
#!/bin/bash
set -euo pipefail

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] ${*:2}"
}

function error() {
    log "ERROR" "$*" >&2
    cleanup
    exit 1
}

function cleanup() {
    # Cleanup code here
    :
}

trap cleanup EXIT INT TERM
```

### Idempotency Pattern
```bash
function ensure_user() {
    local username="$1"

    if id "$username" &>/dev/null; then
        log "INFO" "User $username already exists"
        return 0
    fi

    useradd --system "$username"
    log "INFO" "Created user $username"
}
```

### Configuration Loading Pattern
```bash
readonly CONFIG_FILE="/etc/myapp/config"

function load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Config file not found: $CONFIG_FILE"
    fi

    # Validate permissions
    local perms=$(stat -c "%a" "$CONFIG_FILE")
    if [[ "$perms" != "644" ]] && [[ "$perms" != "640" ]]; then
        error "Insecure permissions on $CONFIG_FILE: $perms"
    fi

    source "$CONFIG_FILE"
}
```

### Health Check Pattern
```bash
function wait_for_healthy() {
    local service="$1"
    local max_wait="${2:-60}"
    local waited=0

    while [[ $waited -lt $max_wait ]]; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            log "INFO" "Service $service is healthy"
            return 0
        fi

        sleep 1
        waited=$((waited + 1))
    done

    error "Service $service did not become healthy within ${max_wait}s"
}
```

---

## Testing Checklist

Before deploying modified examples:

- [ ] Syntax validated: `bash -n script.sh`
- [ ] Shellcheck passes: `shellcheck script.sh`
- [ ] Dry run tested: `./script.sh --dry-run`
- [ ] Tested in Docker/VM (not production)
- [ ] Error cases tested (missing files, wrong permissions)
- [ ] Idempotency tested (run twice, same result)
- [ ] Cleanup verified (temp files removed)
- [ ] Logs reviewed for clarity
- [ ] Notifications working
- [ ] Documentation updated

---

## Troubleshooting

### Script Won't Execute

```bash
# Make script executable
chmod +x script.sh

# Check shebang
head -1 script.sh
# Should be: #!/bin/bash
```

### Permission Denied Errors

```bash
# Check if script needs root
./script.sh
# Error: This script must be run as root

# Run with sudo
sudo ./script.sh
```

### Syntax Errors

```bash
# Validate syntax
bash -n script.sh

# Check for common issues:
# - Missing quotes around variables
# - Unclosed brackets
# - Wrong number of arguments to test commands
```

### Script Hangs

```bash
# Run with debugging
bash -x script.sh

# Check for:
# - Infinite loops
# - Waiting for user input
# - Network timeouts without limits
```

---

## Additional Resources

### Documentation
- Shell_Script_Generation_Instructions.md - Creating new scripts
- Shell_Script_Best_Practices_Guide.md - Coding standards
- Shell_Security_Standards_Reference.md - Security patterns
- Shell_Script_Checklist.md - Pre-deployment validation

### Tools
- **shellcheck**: Static analysis tool for shell scripts
- **BATS**: Bash Automated Testing System
- **shfmt**: Shell script formatter

### External Resources
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [systemd Documentation](https://www.freedesktop.org/software/systemd/man/)

---

**Last Updated**: 2025-12-12
