#!/bin/bash
# health_check_monitor.sh - Continuous service health monitoring
# Copyright (c) 2025 Example Company
# Usage: ./health_check_monitor.sh [--interval=30]

set -euo pipefail

# Configuration
readonly APP_NAME="myapp"
readonly SERVICE_NAME="${APP_NAME}.service"
readonly HEALTH_URL="${HEALTH_URL:-http://localhost:8080/health}"
readonly METRICS_URL="${METRICS_URL:-http://localhost:8080/metrics}"
readonly LOG_FILE="/var/log/${APP_NAME}-monitor.log"
readonly STATE_FILE="/var/lib/${APP_NAME}/monitor-state.json"

# Monitoring settings
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"  # seconds
readonly MAX_FAILURES=3
readonly ALERT_COOLDOWN=300  # 5 minutes between alerts

# Alert settings
readonly PAGERDUTY_KEY="${PAGERDUTY_KEY:-}"
readonly SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# Environment
DEBUG="${DEBUG:-false}"

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --interval=*)
            CHECK_INTERVAL="${arg#*=}"
            ;;
        --debug)
            DEBUG=true
            ;;
        -h|--help)
            cat << EOF
Usage: $0 [OPTIONS]

Continuous health monitoring for ${APP_NAME}.

OPTIONS:
    --interval=N     Check interval in seconds (default: 30)
    --debug          Enable debug output
    -h, --help       Show this help message

ENVIRONMENT VARIABLES:
    HEALTH_URL       Health check endpoint (default: http://localhost:8080/health)
    METRICS_URL      Metrics endpoint (default: http://localhost:8080/metrics)
    PAGERDUTY_KEY    PagerDuty integration key
    SLACK_WEBHOOK_URL Slack webhook URL

EXAMPLES:
    $0
    $0 --interval=60
    DEBUG=true $0

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
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

# Load state
function load_state() {
    local key="$1"
    local default="${2:-0}"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo "$default"
        return
    fi

    if command -v jq &>/dev/null; then
        jq -r --arg key "$key" '.[$key] // empty' "$STATE_FILE" 2>/dev/null || echo "$default"
    else
        echo "$default"
    fi
}

# Check if alert cooldown period has passed
function can_send_alert() {
    local last_alert
    last_alert=$(load_state "last_alert_timestamp" "0")
    local current_time
    current_time=$(date +%s)
    local elapsed=$((current_time - last_alert))

    if [[ $elapsed -ge $ALERT_COOLDOWN ]]; then
        return 0
    else
        debug "Alert cooldown active (${elapsed}s / ${ALERT_COOLDOWN}s)"
        return 1
    fi
}

# Send alert to PagerDuty
function send_pagerduty_alert() {
    local message="$1"
    local severity="${2:-error}"

    if [[ -z "$PAGERDUTY_KEY" ]]; then
        debug "PagerDuty key not configured"
        return 0
    fi

    if ! command -v curl &>/dev/null; then
        debug "curl not available for PagerDuty alert"
        return 0
    fi

    local payload
    payload=$(cat <<EOF
{
  "routing_key": "$PAGERDUTY_KEY",
  "event_action": "trigger",
  "payload": {
    "summary": "$message",
    "severity": "$severity",
    "source": "$(hostname)",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
  }
}
EOF
)

    curl -X POST https://events.pagerduty.com/v2/enqueue \
         -H 'Content-Type: application/json' \
         -d "$payload" \
         --silent --max-time 10 || true
}

# Send alert to Slack
function send_slack_alert() {
    local message="$1"
    local emoji="${2:-:warning:}"

    if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
        debug "Slack webhook not configured"
        return 0
    fi

    if ! command -v curl &>/dev/null; then
        debug "curl not available for Slack alert"
        return 0
    fi

    curl -X POST -H 'Content-type: application/json' \
         --data "{\"text\": \"$emoji [${APP_NAME}] $message\"}" \
         "$SLACK_WEBHOOK_URL" \
         --silent --max-time 10 || true
}

# Send alert through all configured channels
function send_alert() {
    local message="$1"
    local severity="${2:-warning}"

    log "WARN" "ALERT: $message"

    if can_send_alert; then
        send_pagerduty_alert "$message" "$severity"
        send_slack_alert "$message" ":rotating_light:"

        save_state "last_alert_timestamp" "$(date +%s)"
        save_state "last_alert_message" "$message"
    fi
}

# Check if service is running
function check_service() {
    if ! systemctl is-active "$SERVICE_NAME" &>/dev/null; then
        log "ERROR" "Service is not active: $SERVICE_NAME"
        return 1
    fi

    debug "Service is active: $SERVICE_NAME"
    return 0
}

# Check HTTP health endpoint
function check_http_health() {
    if ! command -v curl &>/dev/null; then
        debug "curl not available, skipping HTTP health check"
        return 0
    fi

    local response
    response=$(curl -sf --max-time 5 "$HEALTH_URL" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        debug "HTTP health check passed: $HEALTH_URL"

        # Parse JSON response if jq available
        if command -v jq &>/dev/null; then
            local status
            status=$(echo "$response" | jq -r '.status // empty' 2>/dev/null)
            if [[ "$status" == "healthy" ]] || [[ "$status" == "ok" ]]; then
                return 0
            elif [[ -n "$status" ]]; then
                log "WARN" "Health endpoint returned non-healthy status: $status"
                return 1
            fi
        fi

        return 0
    else
        log "ERROR" "HTTP health check failed: $HEALTH_URL (exit code: $exit_code)"
        return 1
    fi
}

# Collect metrics
function collect_metrics() {
    if ! command -v curl &>/dev/null; then
        debug "curl not available, skipping metrics collection"
        return
    fi

    local metrics
    metrics=$(curl -sf --max-time 5 "$METRICS_URL" 2>/dev/null)

    if [[ -n "$metrics" ]]; then
        debug "Metrics collected from $METRICS_URL"

        # Extract key metrics if Prometheus format
        if echo "$metrics" | grep -q "^# HELP"; then
            local request_count
            request_count=$(echo "$metrics" | grep -E "^http_requests_total" | awk '{print $2}' | head -1)
            local error_count
            error_count=$(echo "$metrics" | grep -E "^http_errors_total" | awk '{print $2}' | head -1)

            if [[ -n "$request_count" ]]; then
                save_state "metrics_request_count" "$request_count"
            fi

            if [[ -n "$error_count" ]]; then
                save_state "metrics_error_count" "$error_count"
            fi
        fi
    fi
}

# Perform health check
function perform_health_check() {
    local failed=false

    # Check service
    if ! check_service; then
        failed=true
    fi

    # Check HTTP health endpoint
    if ! check_http_health; then
        failed=true
    fi

    # Collect metrics (non-blocking)
    collect_metrics

    if [ "$failed" = true ]; then
        return 1
    else
        return 0
    fi
}

# Handle health check failure
function handle_failure() {
    local failure_count
    failure_count=$(load_state "consecutive_failures" "0")
    failure_count=$((failure_count + 1))

    save_state "consecutive_failures" "$failure_count"
    save_state "last_failure_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    log "WARN" "Health check failed (consecutive failures: $failure_count)"

    if [[ $failure_count -ge $MAX_FAILURES ]]; then
        send_alert "Service unhealthy: $failure_count consecutive failures" "error"

        # Check if service needs restart
        if ! systemctl is-active "$SERVICE_NAME" &>/dev/null; then
            log "WARN" "Attempting service restart..."
            systemctl restart "$SERVICE_NAME" || log "ERROR" "Service restart failed"
        fi
    fi
}

# Handle health check success
function handle_success() {
    local failure_count
    failure_count=$(load_state "consecutive_failures" "0")

    if [[ $failure_count -gt 0 ]]; then
        log "INFO" "Service recovered after $failure_count failure(s)"
        send_alert "Service recovered after $failure_count failure(s)" "info"
    fi

    save_state "consecutive_failures" "0"
    save_state "last_success_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

# Show monitor status
function show_status() {
    log "INFO" "=== Monitor Status ==="
    log "INFO" "Service: $SERVICE_NAME"
    log "INFO" "Health URL: $HEALTH_URL"
    log "INFO" "Check Interval: ${CHECK_INTERVAL}s"

    local last_success
    last_success=$(load_state "last_success_timestamp" "never")
    local last_failure
    last_failure=$(load_state "last_failure_timestamp" "never")
    local consecutive_failures
    consecutive_failures=$(load_state "consecutive_failures" "0")

    log "INFO" ""
    log "INFO" "Last successful check: $last_success"
    log "INFO" "Last failed check: $last_failure"
    log "INFO" "Consecutive failures: $consecutive_failures"
}

# Cleanup on exit
function cleanup() {
    log "INFO" "Monitor stopping..."
}

trap cleanup EXIT INT TERM

# Main monitoring loop
function main() {
    log "INFO" "=== Health Monitor Starting ==="
    show_status

    log "INFO" "Starting monitoring loop (interval: ${CHECK_INTERVAL}s)"

    while true; do
        debug "Performing health check..."

        if perform_health_check; then
            handle_success
        else
            handle_failure
        fi

        debug "Sleeping for ${CHECK_INTERVAL}s"
        sleep "$CHECK_INTERVAL"
    done
}

main "$@"
