#!/bin/bash
# backup_automation.sh - Automated backup with rotation
# Copyright (c) 2025 Example Company
# Usage: ./backup_automation.sh [--dry-run]

set -euo pipefail

# Configuration
readonly APP_NAME="myapp"
readonly BACKUP_SOURCE="/opt/${APP_NAME}/data"
readonly BACKUP_DEST="/var/backups/${APP_NAME}"
readonly LOG_FILE="/var/log/${APP_NAME}-backup.log"
readonly LOCK_FILE="/var/lock/${APP_NAME}-backup.lock"
readonly STATE_FILE="/var/lib/${APP_NAME}/backup-state.json"

# Backup settings
readonly RETENTION_DAYS=30
readonly RETENTION_WEEKLY=8  # Keep 8 weeks of weekly backups
readonly RETENTION_MONTHLY=12  # Keep 12 months of monthly backups

# Notifications
readonly SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
readonly ADMIN_EMAIL="${ADMIN_EMAIL:-root@localhost}"

# Environment
DRY_RUN="${DRY_RUN:-false}"
DEBUG="${DEBUG:-false}"

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --debug) DEBUG=true ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# Logging
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
    send_notification "❌ Backup failed: $*"
    cleanup
    exit 1
}

# Lock management
readonly LOCK_FD=200

function acquire_lock() {
    eval "exec $LOCK_FD>$LOCK_FILE"

    if ! flock -n $LOCK_FD; then
        error "Another backup instance is already running (lock: $LOCK_FILE)"
    fi

    echo $$ >&$LOCK_FD
    debug "Lock acquired (PID: $$)"
}

function release_lock() {
    flock -u $LOCK_FD 2>/dev/null || true
    rm -f "$LOCK_FILE"
    debug "Lock released"
}

# Cleanup
function cleanup() {
    debug "Cleanup started"
    release_lock
    debug "Cleanup complete"
}

trap cleanup EXIT INT TERM

# Send notification
function send_notification() {
    local message="$1"

    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" ]] && command -v curl &>/dev/null; then
        curl -X POST -H 'Content-type: application/json' \
             --data "{\"text\": \"[${APP_NAME}] $message\"}" \
             "$SLACK_WEBHOOK_URL" \
             --silent --max-time 5 || true
    fi

    # Email notification (if mail command available)
    if command -v mail &>/dev/null; then
        echo "$message" | mail -s "[${APP_NAME}] Backup Notification" "$ADMIN_EMAIL" || true
    fi
}

# Save state
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

# Load state value from state file
function load_state() {
    local key="$1"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo ""
        return 1
    fi

    if command -v jq &>/dev/null; then
        jq -r --arg key "$key" '.[$key] // ""' "$STATE_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Check if source exists
function validate_source() {
    if [[ ! -d "$BACKUP_SOURCE" ]]; then
        error "Backup source does not exist: $BACKUP_SOURCE"
    fi

    if [[ ! -r "$BACKUP_SOURCE" ]]; then
        error "Backup source is not readable: $BACKUP_SOURCE"
    fi

    debug "Source validated: $BACKUP_SOURCE"
}

# Create backup
function create_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DEST/backup-${timestamp}.tar.gz"

    log "INFO" "Creating backup: $backup_file"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would create backup: $backup_file"
        return 0
    fi

    # Create backup directory
    mkdir -p "$BACKUP_DEST"

    # Create backup
    local start_time
    start_time=$(date +%s)

    tar -czf "$backup_file" -C "$(dirname "$BACKUP_SOURCE")" "$(basename "$BACKUP_SOURCE")" 2>&1 | tee -a "$LOG_FILE"

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Get backup size
    local size
    size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file")
    local size_mb=$((size / 1024 / 1024))

    log "INFO" "✓ Backup created: $backup_file ($size_mb MB, ${duration}s)"

    # Save state
    save_state "last_backup_file" "$backup_file"
    save_state "last_backup_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    save_state "last_backup_size" "$size"
    save_state "last_backup_duration" "$duration"

    echo "$backup_file"
}

# Verify backup integrity
function verify_backup() {
    local backup_file="$1"

    log "INFO" "Verifying backup integrity..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would verify: $backup_file"
        return 0
    fi

    # Test archive
    if tar -tzf "$backup_file" >/dev/null 2>&1; then
        log "INFO" "✓ Backup verification successful"
        save_state "last_verification_status" "success"
        return 0
    else
        error "Backup verification failed: $backup_file"
    fi
}

# Rotate old backups
function rotate_backups() {
    log "INFO" "Rotating old backups (retention: ${RETENTION_DAYS} days)..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would rotate backups"
        return 0
    fi

    local deleted_count=0

    # Delete daily backups older than retention period
    while IFS= read -r -d '' backup; do
        local backup_date
        backup_date=$(echo "$backup" | grep -oP '\d{8}')

        if [[ -n "$backup_date" ]]; then
            local backup_age
            backup_age=$(( ($(date +%s) - $(date -d "$backup_date" +%s)) / 86400 ))

            if [[ $backup_age -gt $RETENTION_DAYS ]]; then
                # Check if it's a weekly/monthly backup to keep
                local day_of_week
                day_of_week=$(date -d "$backup_date" +%u)
                local day_of_month
                day_of_month=$(date -d "$backup_date" +%d)

                # Keep weekly backups (Sunday)
                if [[ $day_of_week -eq 7 ]] && [[ $backup_age -le $((RETENTION_WEEKLY * 7)) ]]; then
                    debug "Keeping weekly backup: $backup"
                    continue
                fi

                # Keep monthly backups (1st of month)
                if [[ "$day_of_month" == "01" ]] && [[ $backup_age -le $((RETENTION_MONTHLY * 30)) ]]; then
                    debug "Keeping monthly backup: $backup"
                    continue
                fi

                log "INFO" "Deleting old backup (${backup_age} days): $backup"
                rm -f "$backup"
                deleted_count=$((deleted_count + 1))
            fi
        fi
    done < <(find "$BACKUP_DEST" -name "backup-*.tar.gz" -print0)

    log "INFO" "✓ Rotation complete (deleted: $deleted_count backups)"
}

# Show backup statistics
function show_statistics() {
    log "INFO" "=== Backup Statistics ==="

    # Count backups
    local total_backups
    total_backups=$(find "$BACKUP_DEST" -name "backup-*.tar.gz" | wc -l)
    log "INFO" "Total backups: $total_backups"

    # Total size
    local total_size=0
    while IFS= read -r backup; do
        local size
        size=$(stat -c%s "$backup" 2>/dev/null || stat -f%z "$backup")
        total_size=$((total_size + size))
    done < <(find "$BACKUP_DEST" -name "backup-*.tar.gz")

    local total_size_gb=$((total_size / 1024 / 1024 / 1024))
    log "INFO" "Total size: ${total_size_gb} GB"

    # Oldest and newest
    local oldest
    oldest=$(find "$BACKUP_DEST" -name "backup-*.tar.gz" | sort | head -1 | xargs basename 2>/dev/null || echo "N/A")
    local newest
    newest=$(find "$BACKUP_DEST" -name "backup-*.tar.gz" | sort | tail -1 | xargs basename 2>/dev/null || echo "N/A")

    log "INFO" "Oldest backup: $oldest"
    log "INFO" "Newest backup: $newest"
}

# Main function
function main() {
    log "INFO" "=== Starting Backup ==="

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN MODE: No changes will be made"
    fi

    acquire_lock
    validate_source

    local backup_file
    backup_file=$(create_backup)
    verify_backup "$backup_file"
    rotate_backups
    show_statistics

    # Success notification
    local size_bytes size_mb
    size_bytes=$(load_state "last_backup_size")
    if [[ -n "$size_bytes" && "$size_bytes" =~ ^[0-9]+$ ]]; then
        size_mb=$((size_bytes / 1024 / 1024))
    else
        size_mb="unknown"
    fi
    send_notification "✅ Backup completed successfully ($size_mb MB)"

    log "INFO" "=== Backup Complete ==="
}

main "$@"
