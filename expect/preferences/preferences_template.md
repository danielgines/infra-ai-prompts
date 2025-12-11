# Expect Script Preferences Template

> **Instructions**: Copy this file and customize for your needs.
> Append to base prompts (`Expect_Automation_Instructions.md`) for personalized behavior.

---

## Credential Management Preference

**Selected method**: [Environment Variables / Credential Files / SSH Keys / Runtime Prompt / Secret Management System]

**Rationale**: [Explain why you chose this method for your environment]

**Implementation notes**:
```tcl
# Example: Environment variables approach
if {![info exists env(SSH_PASSWORD)]} {
    puts stderr "ERROR: SSH_PASSWORD not set"
    exit 1
}
set password $env(SSH_PASSWORD)
```

---

## Timeout Standards

Define standard timeout values for different operation types:

### Quick Operations (Prompts, Login)

**Timeout**: [5-10 seconds recommended]

```tcl
set timeout 10
```

### Medium Operations (Command Execution)

**Timeout**: [30-60 seconds recommended]

```tcl
set timeout 30
```

### Long Operations (File Transfer, Compilation)

**Timeout**: [300-600 seconds recommended]

```tcl
set timeout 300
```

### Very Long Operations (Backup, Large Data Transfer)

**Timeout**: [600+ seconds]

```tcl
set timeout 600
```

---

## Security Requirements

### Mandatory Security Checks

- [ ] **File permissions**: Scripts must be 700, credential files 600
- [ ] **Credential validation**: Check environment variables before use
- [ ] **Logging security**: Disable logging when sending passwords
- [ ] **Audit logging**: Log all connection attempts and operations
- [ ] **Version control**: Never commit credentials or sensitive scripts

### Security Policy

**File permissions enforcement**:
```tcl
# Self-check script permissions
set script_perms [file attributes $argv0 -permissions]
if {$script_perms != "0700" && $script_perms != "0500"} {
    puts stderr "ERROR: Insecure script permissions: $script_perms"
    exit 1
}
```

---

## Logging Preferences

### Standard Logging

**Console output**: [Enabled / Disabled]

```tcl
log_user 1  # Enable console output
# log_user 0  # Disable console output
```

**File logging**: [Enabled / Disabled / Conditional]

```tcl
# Enable file logging
log_file -a /var/log/expect_scripts.log

# Disable during password operations
log_file
send "$password\r"
log_file -a /var/log/expect_scripts.log
```

### Audit Logging

**Required**: [Yes / No]

**Log location**: [/var/log/expect_audit.log]

**Log format**: [Timestamp | User | Host | Action | Status | Details]

```tcl
proc audit_log {action status details} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    set user $env(USER)
    set host [info hostname]
    set log_entry "$timestamp | $user@$host | $action | $status | $details"

    set fp [open "/var/log/expect_audit.log" a]
    puts $fp $log_entry
    close $fp
}
```

---

## Error Handling Standards

### Required Error Patterns

All expect blocks must handle:

- [ ] **timeout** - Operation timeout
- [ ] **eof** - Unexpected connection close
- [ ] **Error patterns** - Application-specific errors

### Standard Error Handling Template

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout after $timeout seconds"
        exit 1
    }
    eof {
        puts stderr "ERROR: Connection closed unexpectedly"
        exit 1
    }
    "Permission denied" {
        puts stderr "ERROR: Authentication failed"
        exit 1
    }
    "expected pattern" {
        # Success case
    }
}
```

---

## Naming Conventions

### Script Files

**Format**: [description]_[environment].exp

**Examples**:
- `backup_servers_prod.exp`
- `config_switches_staging.exp`
- `deploy_application_dev.exp`

### Variables

**Credential variables**: `password`, `ssh_password`, `api_key`

**Host variables**: `host`, `remote_host`, `target_server`

**User variables**: `user`, `username`, `remote_user`

### Procedures

**Format**: [verb]_[noun]

**Examples**:
- `connect_to_server`
- `wait_for_prompt`
- `execute_command`
- `transfer_file`

---

## Code Organization Standards

### Required Script Sections

```tcl
#!/usr/bin/expect -f

# ============================================================================
# [HEADER] Script metadata
# ============================================================================

# ============================================================================
# [CONFIGURATION] Timeout, logging, constants
# ============================================================================

# ============================================================================
# [VALIDATION] Argument and environment validation
# ============================================================================

# ============================================================================
# [PROCEDURES] Reusable functions
# ============================================================================

# ============================================================================
# [MAIN] Main execution logic
# ============================================================================

# ============================================================================
# [CLEANUP] Connection closing and cleanup
# ============================================================================
```

### Header Template

```tcl
################################################################################
# Script: [script_name.exp]
# Purpose: [Brief description]
# Author: [Your Name/Team]
# Date: [YYYY-MM-DD]
# Last Modified: [YYYY-MM-DD]
#
# Usage: ./script_name.exp <arg1> <arg2>
#
# Environment Variables:
#   - PASSWORD: [Description]
#   - OPTIONAL_VAR: [Description] (optional)
#
# Prerequisites:
#   - [Software/access requirements]
#
# Exit Codes:
#   - 0: Success
#   - 1: Error (see stderr for details)
################################################################################
```

---

## Target Environment Specifics

### SSH Connections

**Prompt patterns**: [Define your standard prompt patterns]

```tcl
# Unix/Linux prompts
expect -re "\[#\\$\] $"

# Or specific prompts
expect "username@hostname $ "
```

**SSH options**: [Define standard SSH options]

```tcl
spawn ssh -o StrictHostKeyChecking=yes \
          -o UserKnownHostsFile=~/.ssh/known_hosts \
          "$user@$host"
```

### Network Devices

**Device types**: [Cisco / Juniper / HP / Dell / Other]

**Prompt patterns**: [Define device-specific prompts]

```tcl
# Cisco devices
expect "Router>"          # User mode
expect "Router#"          # Privileged mode
expect "Router(config)#"  # Configuration mode
```

**Common commands**: [Define standard command patterns]

```tcl
# Enter privileged mode
send "enable\r"
expect "Password:"
send "$enable_password\r"
expect "#"

# Enter configuration mode
send "configure terminal\r"
expect "(config)#"

# Save configuration
send "write memory\r"
expect "#"
```

### Legacy Systems

**System types**: [Define your legacy systems]

**Special considerations**: [Encoding, terminal types, etc.]

```tcl
# Set terminal type
set env(TERM) vt100

# Set terminal size
stty rows 24 cols 80
```

---

## Testing Requirements

### Pre-Deployment Testing

- [ ] **Syntax validation**: `expect -c 'source script.exp' < /dev/null`
- [ ] **Dry run**: Test with non-production hosts first
- [ ] **Security scan**: Check for hardcoded credentials
- [ ] **Permission check**: Verify file permissions

### Test Cases

**Minimum required tests**:

1. **Valid credentials test** - Normal operation success
2. **Invalid credentials test** - Authentication failure handling
3. **Timeout test** - Timeout handling
4. **Connection failure test** - Unreachable host handling

---

## Documentation Requirements

### Inline Comments

**Required for**:
- Complex regex patterns
- Non-obvious timeout values
- Security-critical sections
- Workarounds or hacks

```tcl
# SECURITY: Disable logging before sending password
log_user 0
send "$password\r"
log_user 1

# Timeout set to 300s for large file transfer
set timeout 300
expect "Transfer complete"
```

### README Requirements

For script collections, include:

- [ ] **Purpose** - What the scripts do
- [ ] **Setup** - Prerequisites and installation
- [ ] **Usage** - How to run each script
- [ ] **Security** - Credential management approach
- [ ] **Troubleshooting** - Common issues and solutions

---

## Compliance Requirements

### Audit Requirements

**Required**: [Yes / No / Conditional]

**Audit events**:
- [ ] Connection attempts
- [ ] Authentication successes/failures
- [ ] Command executions
- [ ] File transfers
- [ ] Configuration changes

### Retention Policy

**Audit logs**: [Retain for X days/months]

**Script logs**: [Retain for X days/months]

**Rotation**: [Daily / Weekly / Monthly]

---

## Team-Specific Patterns

### Custom Procedures

Define reusable procedures for your team:

```tcl
proc company_standard_connect {host user password} {
    global spawn_id

    spawn ssh "$user@$host"

    expect {
        timeout {
            puts stderr "ERROR: Connection timeout to $host"
            return 1
        }
        "Are you sure" {
            send "yes\r"
            exp_continue
        }
        "password:" {
            log_user 0
            send "$password\r"
            log_user 1
        }
    }

    expect {
        timeout {
            puts stderr "ERROR: Login timeout"
            return 1
        }
        "$ " {
            return 0
        }
    }
}
```

### Custom Logging

```tcl
proc company_log {level message} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    puts "\[$timestamp\] \[$level\] $message"
}

# Usage
company_log "INFO" "Connecting to server"
company_log "ERROR" "Connection failed"
company_log "SUCCESS" "Operation completed"
```

---

## Integration Patterns

### CI/CD Integration

**Platform**: [Jenkins / GitLab CI / GitHub Actions / Other]

**Authentication method**: [SSH keys required / Environment variables]

**Example**:
```yaml
# GitLab CI example
run_automation:
  stage: deploy
  script:
    - export SSH_PASSWORD=$VAULT_SSH_PASSWORD
    - expect ./automation_script.exp production app-server
  only:
    - master
```

### Monitoring Integration

**Monitoring system**: [Prometheus / Nagios / DataDog / Other]

**Integration method**: [Exit codes / Log parsing / Metrics endpoint]

```tcl
# Exit with appropriate code for monitoring
if {$operation_successful} {
    puts "SUCCESS: Operation completed"
    exit 0
} else {
    puts stderr "FAILURE: Operation failed"
    exit 1
}
```

---

## Notes and Exceptions

### Known Issues

Document any known limitations or workarounds:

```
Issue: [Description]
Workaround: [Solution]
Tracked in: [Ticket ID]
```

### Exceptions to Standards

Document any approved exceptions:

```
Exception: [What standard is being violated]
Reason: [Why this is necessary]
Approved by: [Name/Team]
Date: [YYYY-MM-DD]
```

---

## References

Add links to internal documentation:

- Internal wiki: [URL]
- Team runbooks: [URL]
- Credential management guide: [URL]
- Security policies: [URL]

---

**Last Updated**: [YYYY-MM-DD]
**Owner**: [Team/Individual]
**Review Schedule**: [Monthly / Quarterly / Annually]
