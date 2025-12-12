#!/bin/bash
# service_deployment.sh - Deploy and manage systemd services
# Copyright (c) 2025 Example Company
# Usage: ./service_deployment.sh deploy|rollback|status

set -euo pipefail

# Configuration
readonly APP_NAME="myapp"
readonly SERVICE_NAME="${APP_NAME}.service"
readonly INSTALL_DIR="/opt/${APP_NAME}"
readonly BACKUP_DIR="/var/backups/${APP_NAME}"
readonly STATE_FILE="/var/lib/${APP_NAME}/deployment-state.json"
readonly LOG_FILE="/var/log/${APP_NAME}-deploy.log"

# Deployment settings
readonly HEALTH_CHECK_URL="http://localhost:8080/health"
readonly HEALTH_CHECK_TIMEOUT=60
readonly ROLLBACK_ON_FAILURE=true

# Environment
DEBUG="${DEBUG:-false}"

# Logging functions
function log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

function debug() {
    if [[ "$DEBUG" == "true" ]]; then
        log "DEBUG" "$*"
    fi
}

function error() {
    log "ERROR" "$*" >&2
    exit 1
}

# Check if running as root
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Save deployment state
function save_state() {
    local key="$1"
    local value="$2"

    mkdir -p "$(dirname "$STATE_FILE")"

    if [[ -f "$STATE_FILE" ]] && command -v jq &>/dev/null; then
        local temp_file
        temp_file=$(mktemp)
        jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$STATE_FILE" > "$temp_file"
        mv "$temp_file" "$STATE_FILE"
    else
        echo "{\"$key\": \"$value\"}" > "$STATE_FILE"
    fi

    chmod 600 "$STATE_FILE"
}

# Load deployment state
function load_state() {
    local key="$1"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo ""
        return
    fi

    if command -v jq &>/dev/null; then
        jq -r --arg key "$key" '.[$key] // empty' "$STATE_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Create backup of current version
function create_backup() {
    log "INFO" "Creating backup of current version..."

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/${timestamp}"

    mkdir -p "$backup_path"

    # Backup binaries
    if [[ -d "$INSTALL_DIR/bin" ]]; then
        cp -a "$INSTALL_DIR/bin" "$backup_path/"
        log "INFO" "Backed up binaries"
    fi

    # Backup config (if changed)
    if [[ -d "/etc/${APP_NAME}" ]]; then
        cp -a "/etc/${APP_NAME}" "$backup_path/"
        log "INFO" "Backed up configuration"
    fi

    # Save backup location
    save_state "last_backup" "$backup_path"
    save_state "last_backup_timestamp" "$timestamp"

    log "INFO" "✓ Backup created: $backup_path"
    echo "$backup_path"
}

# Check if service exists
function service_exists() {
    systemctl list-unit-files "${SERVICE_NAME}" &>/dev/null
}

# Check if service is active
function service_is_active() {
    systemctl is-active "$SERVICE_NAME" &>/dev/null
}

# Stop service gracefully
function stop_service() {
    log "INFO" "Stopping service: $SERVICE_NAME"

    if ! service_exists; then
        log "WARN" "Service does not exist: $SERVICE_NAME"
        return 0
    fi

    if ! service_is_active; then
        log "INFO" "Service already stopped"
        return 0
    fi

    systemctl stop "$SERVICE_NAME"

    # Wait for service to stop
    local waited=0
    local max_wait=30

    while systemctl is-active "$SERVICE_NAME" &>/dev/null; do
        if [[ $waited -ge $max_wait ]]; then
            error "Service did not stop within ${max_wait}s"
        fi

        sleep 1
        waited=$((waited + 1))
    done

    log "INFO" "✓ Service stopped"
}

# Start service
function start_service() {
    log "INFO" "Starting service: $SERVICE_NAME"

    if ! service_exists; then
        error "Service does not exist: $SERVICE_NAME"
    fi

    if service_is_active; then
        log "INFO" "Service already active"
        return 0
    fi

    systemctl start "$SERVICE_NAME"
    log "INFO" "✓ Service started"
}

# Reload systemd daemon
function reload_systemd() {
    log "INFO" "Reloading systemd daemon..."
    systemctl daemon-reload
    log "INFO" "✓ Systemd daemon reloaded"
}

# Check service health
function check_health() {
    local max_wait="$HEALTH_CHECK_TIMEOUT"
    local waited=0

    log "INFO" "Checking service health..."

    # Wait for service to become active
    while ! service_is_active; do
        if [[ $waited -ge $max_wait ]]; then
            error "Service did not start within ${max_wait}s"
        fi

        sleep 1
        waited=$((waited + 1))
    done

    # Check health endpoint if URL provided
    if [[ -n "$HEALTH_CHECK_URL" ]] && command -v curl &>/dev/null; then
        waited=0

        while true; do
            if curl -sf --max-time 5 "$HEALTH_CHECK_URL" >/dev/null 2>&1; then
                log "INFO" "✓ Health check passed"
                return 0
            fi

            if [[ $waited -ge $max_wait ]]; then
                error "Health check failed after ${max_wait}s"
            fi

            sleep 2
            waited=$((waited + 2))
        done
    else
        log "INFO" "✓ Service is active (no health check URL configured)"
    fi
}

# Rollback to previous version
function rollback() {
    log "INFO" "=== Starting Rollback ==="

    local backup_path
    backup_path=$(load_state "last_backup")

    if [[ -z "$backup_path" ]] || [[ ! -d "$backup_path" ]]; then
        error "No backup found for rollback"
    fi

    log "INFO" "Rolling back to: $backup_path"

    # Stop current service
    stop_service

    # Restore binaries
    if [[ -d "$backup_path/bin" ]]; then
        cp -a "$backup_path/bin/"* "$INSTALL_DIR/bin/"
        log "INFO" "Restored binaries"
    fi

    # Restore config
    if [[ -d "$backup_path/${APP_NAME}" ]]; then
        cp -a "$backup_path/${APP_NAME}/"* "/etc/${APP_NAME}/"
        log "INFO" "Restored configuration"
    fi

    # Start service
    start_service

    # Verify health
    if check_health; then
        log "INFO" "✓ Rollback successful"
        save_state "last_deployment_status" "rolled_back"
        save_state "last_rollback_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    else
        error "Rollback health check failed"
    fi

    log "INFO" "=== Rollback Complete ==="
}

# Deploy new version
function deploy() {
    log "INFO" "=== Starting Deployment ==="

    check_root

    # Create backup
    local backup_path
    backup_path=$(create_backup)

    # Stop service
    stop_service

    # Reload systemd (in case service file changed)
    reload_systemd

    # Start service
    start_service

    # Check health
    if check_health; then
        log "INFO" "✓ Deployment successful"
        save_state "last_deployment_status" "success"
        save_state "last_deployment_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    else
        log "ERROR" "Deployment health check failed"

        if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
            log "WARN" "Initiating automatic rollback..."
            rollback
        else
            save_state "last_deployment_status" "failed"
            error "Deployment failed, automatic rollback disabled"
        fi
    fi

    log "INFO" "=== Deployment Complete ==="
}

# Show service status
function show_status() {
    log "INFO" "=== Service Status ==="

    if ! service_exists; then
        log "INFO" "Service: $SERVICE_NAME (NOT INSTALLED)"
        return
    fi

    # Service state
    local is_enabled
    is_enabled=$(systemctl is-enabled "$SERVICE_NAME" 2>/dev/null || echo "unknown")
    local is_active
    is_active=$(systemctl is-active "$SERVICE_NAME" 2>/dev/null || echo "inactive")

    log "INFO" "Service:  $SERVICE_NAME"
    log "INFO" "Enabled:  $is_enabled"
    log "INFO" "Active:   $is_active"

    # Deployment state
    local last_status
    last_status=$(load_state "last_deployment_status")
    local last_timestamp
    last_timestamp=$(load_state "last_deployment_timestamp")

    if [[ -n "$last_status" ]]; then
        log "INFO" ""
        log "INFO" "Last Deployment:"
        log "INFO" "  Status:    $last_status"
        log "INFO" "  Timestamp: $last_timestamp"
    fi

    # Recent logs
    if service_is_active; then
        log "INFO" ""
        log "INFO" "Recent Logs:"
        journalctl -u "$SERVICE_NAME" -n 5 --no-pager
    fi
}

# Show usage
function show_usage() {
    cat << EOF
Usage: $0 COMMAND

Deploy and manage systemd services.

COMMANDS:
    deploy      Deploy new version (with automatic rollback on failure)
    rollback    Rollback to previous version
    status      Show service status

OPTIONS:
    --debug     Enable debug output

EXAMPLES:
    $0 deploy
    $0 rollback
    $0 status
    DEBUG=true $0 deploy

EOF
}

# Main function
function main() {
    local command="${1:-}"

    if [[ -z "$command" ]]; then
        show_usage
        exit 1
    fi

    case "$command" in
        deploy)
            deploy
            ;;
        rollback)
            check_root
            rollback
            ;;
        status)
            show_status
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown command: $command" >&2
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
