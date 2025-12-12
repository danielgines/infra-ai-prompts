#!/bin/bash
# system_setup.sh - System initialization and application setup
# Copyright (c) 2025 Example Company
# Usage: sudo ./system_setup.sh [--dry-run]

set -euo pipefail

# Configuration
readonly APP_NAME="myapp"
readonly APP_USER="svc-${APP_NAME}"
readonly APP_GROUP="svc-${APP_NAME}"
readonly INSTALL_DIR="/opt/${APP_NAME}"
readonly LOG_DIR="/var/log/${APP_NAME}"
readonly CONFIG_DIR="/etc/${APP_NAME}"
readonly DATA_DIR="/var/lib/${APP_NAME}"
readonly LOG_FILE="/var/log/${APP_NAME}-setup.log"

# Environment
DRY_RUN="${DRY_RUN:-false}"
DEBUG="${DEBUG:-false}"

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --debug)
            DEBUG=true
            ;;
        -h|--help)
            cat << EOF
Usage: $0 [OPTIONS]

System initialization script for ${APP_NAME}.

OPTIONS:
    --dry-run       Show what would be done without doing it
    --debug         Enable debug output
    -h, --help      Show this help message

REQUIREMENTS:
    - Must run as root
    - Ubuntu 22.04 or compatible

EXAMPLES:
    sudo $0
    sudo $0 --dry-run
    sudo DEBUG=true $0

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Logging functions
function log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

function debug() {
    if [[ "$DEBUG" == "true" ]]; then
        log "DEBUG" "$*"
    fi
}

function info() {
    log "INFO" "$*"
}

function warn() {
    log "WARN" "$*" >&2
}

function error() {
    log "ERROR" "$*" >&2
    cleanup
    exit 1
}

# Cleanup function
function cleanup() {
    debug "Cleanup function called"
}

trap cleanup EXIT INT TERM

# Dry-run wrapper
function run_command() {
    local cmd="$*"

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would execute: $cmd"
        return 0
    else
        debug "Executing: $cmd"
        eval "$cmd"
    fi
}

# Privilege check
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo $0"
    fi
}

# Check if command exists
function check_command() {
    local cmd="$1"

    if ! command -v "$cmd" &>/dev/null; then
        error "Required command not found: $cmd"
    fi

    debug "Command available: $cmd"
}

# Validate prerequisites
function check_prerequisites() {
    info "Checking prerequisites..."

    check_command "useradd"
    check_command "groupadd"
    check_command "systemctl"

    # Check OS version
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        debug "OS: $NAME $VERSION"

        if [[ "$ID" == "ubuntu" ]]; then
            local major_version
            major_version=$(echo "$VERSION_ID" | cut -d. -f1)
            if [[ $major_version -lt 22 ]]; then
                warn "Ubuntu version $VERSION_ID is older than 22.04 (recommended)"
            fi
        fi
    fi

    info "✓ Prerequisites check complete"
}

# Create system user
function create_user() {
    info "Creating system user: $APP_USER"

    # Check if user exists
    if id "$APP_USER" &>/dev/null; then
        info "User $APP_USER already exists"
        return 0
    fi

    # Create group first
    if ! getent group "$APP_GROUP" &>/dev/null; then
        run_command "groupadd --system $APP_GROUP"
        info "Created group: $APP_GROUP"
    else
        debug "Group $APP_GROUP already exists"
    fi

    # Create user
    run_command "useradd --system \
                --gid $APP_GROUP \
                --home-dir $INSTALL_DIR \
                --no-create-home \
                --shell /bin/false \
                $APP_USER"

    info "✓ Created system user: $APP_USER"
}

# Create directory structure
function create_directories() {
    info "Creating directory structure..."

    local dirs=(
        "$INSTALL_DIR"
        "$INSTALL_DIR/bin"
        "$INSTALL_DIR/config"
        "$INSTALL_DIR/scripts"
        "$INSTALL_DIR/data"
        "$LOG_DIR"
        "$CONFIG_DIR"
        "$DATA_DIR"
    )

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            debug "Directory exists: $dir"
        else
            run_command "mkdir -p $dir"
            info "Created directory: $dir"
        fi

        # Set ownership
        run_command "chown $APP_USER:$APP_GROUP $dir"

        # Set permissions based on directory type
        case "$dir" in
            *"/config"|*"/etc/"*)
                run_command "chmod 750 $dir"
                debug "Permissions 750: $dir"
                ;;
            *"/log"*)
                run_command "chmod 770 $dir"
                debug "Permissions 770: $dir"
                ;;
            *)
                run_command "chmod 755 $dir"
                debug "Permissions 755: $dir"
                ;;
        esac
    done

    info "✓ Directory structure created"
}

# Create sample configuration file
function create_sample_config() {
    local config_file="$CONFIG_DIR/app.conf"

    info "Creating sample configuration..."

    if [[ -f "$config_file" ]]; then
        info "Configuration file already exists: $config_file"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would create: $config_file"
        return 0
    fi

    cat > "$config_file" << EOF
# ${APP_NAME} Configuration
# Created: $(date '+%Y-%m-%d %H:%M:%S')

# Application Settings
APP_NAME="${APP_NAME}"
APP_PORT=8080
APP_ENV=production

# Logging Settings
LOG_LEVEL=INFO
LOG_FILE="${LOG_DIR}/${APP_NAME}.log"

# Data Directory
DATA_DIR="${DATA_DIR}"
EOF

    chmod 640 "$config_file"
    chown "$APP_USER:$APP_GROUP" "$config_file"

    info "✓ Created sample configuration: $config_file"
}

# Create systemd service template
function create_service_template() {
    local service_file="$INSTALL_DIR/scripts/${APP_NAME}.service.template"

    info "Creating systemd service template..."

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would create: $service_file"
        return 0
    fi

    cat > "$service_file" << 'EOF'
[Unit]
Description=MyApp Service
Documentation=https://docs.example.com/myapp
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=svc-myapp
Group=svc-myapp
WorkingDirectory=/opt/myapp

# Environment
Environment="APP_ENV=production"
EnvironmentFile=/etc/myapp/app.conf

# Execution
ExecStart=/opt/myapp/bin/server
Restart=on-failure
RestartSec=5s
TimeoutStartSec=60s
TimeoutStopSec=30s

# Resource Limits
MemoryLimit=1G
CPUQuota=100%

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/myapp/data /var/log/myapp

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
EOF

    chmod 644 "$service_file"
    chown root:root "$service_file"

    info "✓ Created service template: $service_file"
}

# Validate setup
function validate_setup() {
    info "Validating setup..."

    local errors=0

    # Check user exists
    if ! id "$APP_USER" &>/dev/null; then
        warn "User $APP_USER does not exist"
        errors=$((errors + 1))
    fi

    # Check directories exist
    local required_dirs=(
        "$INSTALL_DIR"
        "$LOG_DIR"
        "$CONFIG_DIR"
        "$DATA_DIR"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            warn "Directory does not exist: $dir"
            errors=$((errors + 1))
        fi
    done

    # Check config file
    local config_file="$CONFIG_DIR/app.conf"
    if [[ ! -f "$config_file" ]]; then
        warn "Configuration file does not exist: $config_file"
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        error "Validation failed with $errors error(s)"
    fi

    info "✓ Validation complete (0 errors)"
}

# Display setup summary
function show_summary() {
    info "Setup Summary:"
    info "  Application: $APP_NAME"
    info "  User:        $APP_USER"
    info "  Group:       $APP_GROUP"
    info "  Install Dir: $INSTALL_DIR"
    info "  Config Dir:  $CONFIG_DIR"
    info "  Log Dir:     $LOG_DIR"
    info "  Data Dir:    $DATA_DIR"
    info ""
    info "Next Steps:"
    info "  1. Place application binary in: $INSTALL_DIR/bin/"
    info "  2. Review configuration: $CONFIG_DIR/app.conf"
    info "  3. Copy service file: $INSTALL_DIR/scripts/${APP_NAME}.service.template"
    info "     to: /etc/systemd/system/${APP_NAME}.service"
    info "  4. Enable and start service:"
    info "     systemctl enable ${APP_NAME}.service"
    info "     systemctl start ${APP_NAME}.service"
}

# Main function
function main() {
    info "=== ${APP_NAME} System Setup ==="

    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY-RUN MODE: No changes will be made"
    fi

    check_root
    check_prerequisites
    create_user
    create_directories
    create_sample_config
    create_service_template
    validate_setup
    show_summary

    info "=== Setup Complete ==="
}

# Execute main function
main "$@"
