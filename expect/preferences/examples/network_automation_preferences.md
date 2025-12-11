# Network Device Automation Preferences

> **Purpose**: Expect script preferences for network device automation (Cisco, Juniper, HP switches/routers)
> **Use Case**: Network engineers automating device configuration and management
> **Author**: Example preference file for network automation

---

## Credential Management Preference

**Selected method**: Environment Variables + SSH Keys (when available)

**Rationale**:
- Environment variables work well with automation tools (Ansible, Jenkins)
- SSH keys preferred but many network devices only support password auth
- Centralized credential management via CI/CD secrets

**Implementation**:

```tcl
# Check for environment variable first
if {![info exists env(DEVICE_PASSWORD)]} {
    puts stderr "ERROR: DEVICE_PASSWORD environment variable not set"
    puts stderr "Set with: export DEVICE_PASSWORD='your_password'"
    exit 1
}

set password $env(DEVICE_PASSWORD)

# Enable password (if different)
if {[info exists env(ENABLE_PASSWORD)]} {
    set enable_password $env(ENABLE_PASSWORD)
} else {
    set enable_password $password
}
```

---

## Timeout Standards

### Quick Operations (Login, Mode Changes)

**Timeout**: 10 seconds

```tcl
set timeout 10
```

### Command Execution

**Timeout**: 30 seconds

```tcl
set timeout 30
```

### Configuration Deployment

**Timeout**: 60 seconds (for large configs with many lines)

```tcl
set timeout 60
```

### Firmware Upgrades

**Timeout**: 600 seconds (10 minutes)

```tcl
set timeout 600
```

---

## Security Requirements

### Mandatory Security Checks

- [x] **File permissions**: All scripts must be 700
- [x] **Credential validation**: Check environment variables exist and are non-empty
- [x] **Logging security**: Always disable logging when sending passwords
- [x] **Audit logging**: Log all device accesses to centralized syslog
- [x] **Configuration backups**: Always backup before making changes

### Security Policy

```tcl
# Enforce script permissions
set script_perms [file attributes $argv0 -permissions]
if {$script_perms != "0700"} {
    puts stderr "ERROR: Script permissions must be 700"
    puts stderr "Run: chmod 700 $argv0"
    exit 1
}

# Validate credentials are set and non-empty
if {$password eq ""} {
    puts stderr "ERROR: DEVICE_PASSWORD is empty"
    exit 1
}
```

---

## Logging Preferences

### Standard Logging

**Console output**: Enabled (for real-time monitoring)

```tcl
log_user 1
```

**File logging**: Enabled with device-specific log files

```tcl
set log_dir "/var/log/network_automation"
set log_file "$log_dir/${device}_[clock format [clock seconds] -format %Y%m%d_%H%M%S].log"

# Create log directory if it doesn't exist
file mkdir $log_dir

# Start logging
log_file -a $log_file
```

### Audit Logging

**Required**: Yes (compliance requirement)

**Log location**: /var/log/network_audit.log

**Log format**: Timestamp | Engineer | Device | Action | Status | Config_Hash

```tcl
proc network_audit_log {device action status details} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    set engineer $env(USER)
    set workstation [info hostname]

    set audit_file "/var/log/network_audit.log"
    set log_entry "$timestamp | $engineer@$workstation | $device | $action | $status | $details"

    # Ensure audit log exists and is writable
    if {[catch {
        set fp [open $audit_file a]
        puts $fp $log_entry
        close $fp
    } err]} {
        puts stderr "WARNING: Failed to write audit log: $err"
    }
}
```

---

## Error Handling Standards

### Required Error Patterns

All network device expect blocks must handle:

- [x] **timeout** - Device not responding
- [x] **eof** - Connection dropped
- [x] **Authentication failures** - Invalid credentials
- [x] **Command errors** - Invalid command syntax
- [x] **Configuration errors** - Config rollback required

### Network Device Error Template

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout waiting for device response"
        network_audit_log $device $action "TIMEOUT" "No response after $timeout seconds"
        exit 1
    }
    eof {
        puts stderr "ERROR: Connection closed by device"
        network_audit_log $device $action "DISCONNECTED" "Unexpected connection close"
        exit 1
    }
    "% Invalid" {
        puts stderr "ERROR: Invalid command syntax"
        network_audit_log $device $action "ERROR" "Invalid command"
        exit 1
    }
    "% Incomplete command" {
        puts stderr "ERROR: Incomplete command"
        network_audit_log $device $action "ERROR" "Incomplete command"
        exit 1
    }
    "Access denied" {
        puts stderr "ERROR: Access denied - check credentials"
        network_audit_log $device $action "AUTH_FAILED" "Access denied"
        exit 1
    }
    "$expected_prompt" {
        # Success case
    }
}
```

---

## Naming Conventions

### Script Files

**Format**: [action]_[device_type]_[environment].exp

**Examples**:
- `backup_cisco_switches_prod.exp`
- `config_juniper_routers_staging.exp`
- `upgrade_hp_switches_lab.exp`

### Variables

**Device variables**: `device`, `device_ip`, `device_name`

**Credential variables**: `password`, `enable_password`, `snmp_community`

**Configuration variables**: `config_file`, `backup_file`, `vlan_id`

---

## Target Environment Specifics

### Cisco IOS Devices

**Prompt patterns**:

```tcl
# User EXEC mode
set user_prompt ">"

# Privileged EXEC mode
set priv_prompt "#"

# Global configuration mode
set config_prompt "(config)#"

# Interface configuration mode
set if_config_prompt "(config-if)#"

# Wait for any exec prompt
proc wait_for_exec_prompt {} {
    expect {
        timeout {
            puts stderr "ERROR: Prompt timeout"
            exit 1
        }
        -re "\[>#\]\\s*$" {
            return 0
        }
    }
}
```

**Standard login sequence**:

```tcl
proc cisco_login {device user password enable_password} {
    global spawn_id

    # SSH to device
    spawn ssh -o StrictHostKeyChecking=no "$user@$device"

    # Handle login
    expect {
        timeout {
            puts stderr "ERROR: Connection timeout to $device"
            return 1
        }
        "Password:" {
            log_user 0
            send "$password\r"
            log_user 1
        }
    }

    # Wait for user mode prompt
    expect {
        timeout {
            puts stderr "ERROR: Login timeout"
            return 1
        }
        ">" {
            # User mode - need to enable
            send "enable\r"

            expect "Password:"
            log_user 0
            send "$enable_password\r"
            log_user 1

            expect "#"
        }
        "#" {
            # Already in privileged mode
        }
    }

    # Disable paging
    send "terminal length 0\r"
    expect "#"

    return 0
}
```

**Configuration backup**:

```tcl
proc cisco_backup_config {device} {
    set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
    set backup_dir "/backups/cisco"
    set backup_file "$backup_dir/${device}_${timestamp}.cfg"

    file mkdir $backup_dir

    send "show running-config\r"

    set timeout 60
    expect -re "#\\s*$"

    set config $expect_out(buffer)

    # Write to file
    set fp [open $backup_file w]
    puts $fp $config
    close $fp

    puts "Backup saved to: $backup_file"
    network_audit_log $device "BACKUP" "SUCCESS" "Saved to $backup_file"

    return $backup_file
}
```

### Juniper Junos Devices

**Prompt patterns**:

```tcl
# Operational mode
set oper_prompt ">"

# Configuration mode
set config_prompt "#"

# Wait for operational prompt
proc wait_for_junos_prompt {} {
    expect {
        timeout {
            puts stderr "ERROR: Prompt timeout"
            exit 1
        }
        -re "\[>#\]\\s*$" {
            return 0
        }
    }
}
```

**Standard commands**:

```tcl
proc junos_enter_config_mode {} {
    send "configure\r"
    expect {
        timeout {
            puts stderr "ERROR: Failed to enter config mode"
            return 1
        }
        "#" {
            return 0
        }
    }
}

proc junos_commit_config {} {
    send "commit and-quit\r"

    expect {
        timeout {
            puts stderr "ERROR: Commit timeout"
            return 1
        }
        "commit complete" {
            expect ">"
            return 0
        }
        "error:" {
            puts stderr "ERROR: Commit failed"
            send "rollback\r"
            expect "#"
            send "exit\r"
            expect ">"
            return 1
        }
    }
}
```

---

## Code Organization Standards

### Network Script Template

```tcl
#!/usr/bin/expect -f

################################################################################
# Script: [script_name.exp]
# Purpose: [Network automation task description]
# Target Devices: [Cisco/Juniper/HP switches/routers]
# Author: [Network Team]
# Date: [YYYY-MM-DD]
#
# Usage: ./script_name.exp <device_ip> <username>
#
# Environment Variables:
#   - DEVICE_PASSWORD: Login password (required)
#   - ENABLE_PASSWORD: Enable password (optional, defaults to DEVICE_PASSWORD)
#
# Prerequisites:
#   - SSH access to devices
#   - Appropriate user privileges
#   - Backup directory writable
#
# Exit Codes:
#   - 0: Success
#   - 1: Error (connection, authentication, or configuration)
################################################################################

# ============================================================================
# CONFIGURATION
# ============================================================================

set timeout 30
log_user 1
exp_internal 0

set log_dir "/var/log/network_automation"
set backup_dir "/backups/network"

# ============================================================================
# VALIDATION
# ============================================================================

if {$argc < 2} {
    puts stderr "Usage: $argv0 <device_ip> <username>"
    exit 1
}

set device [lindex $argv 0]
set username [lindex $argv 1]

# Validate credentials
if {![info exists env(DEVICE_PASSWORD)]} {
    puts stderr "ERROR: DEVICE_PASSWORD not set"
    exit 1
}

set password $env(DEVICE_PASSWORD)

if {[info exists env(ENABLE_PASSWORD)]} {
    set enable_password $env(ENABLE_PASSWORD)
} else {
    set enable_password $password
}

# ============================================================================
# PROCEDURES
# ============================================================================

# [Include device-specific procedures here]

# ============================================================================
# MAIN EXECUTION
# ============================================================================

network_audit_log $device "CONNECT" "INITIATED" "Starting automation"

# [Main automation logic]

network_audit_log $device "CONNECT" "COMPLETED" "Automation finished"

exit 0
```

---

## Testing Requirements

### Pre-Deployment Testing

- [x] **Syntax validation**: `expect -c 'source script.exp' < /dev/null`
- [x] **Lab testing**: Test on lab devices before production
- [x] **Backup verification**: Verify backup is created before changes
- [x] **Rollback testing**: Verify rollback works if config fails

### Test Devices

**Lab environment**:
- lab-sw-01 (Cisco Catalyst 3850)
- lab-rtr-01 (Cisco ISR 4431)
- lab-fw-01 (Juniper SRX)

### Test Cases

1. **Valid credentials** - Normal operation on lab device
2. **Invalid credentials** - Authentication failure handling
3. **Device timeout** - Unreachable device handling
4. **Invalid command** - Command error handling
5. **Configuration error** - Rollback on config failure

---

## Compliance Requirements

### Change Management

**Required approvals**:
- [ ] Change request ticket created
- [ ] Peer review completed
- [ ] Manager approval obtained
- [ ] Maintenance window scheduled

**Rollback plan**:
- Configuration backup created before changes
- Rollback commands documented
- Maximum time window: 2 hours

### Audit Requirements

**Required audit events**:
- [x] Device connection attempts
- [x] Authentication successes/failures
- [x] Configuration changes
- [x] Configuration backups
- [x] Rollback events

**Retention**: 90 days minimum

---

## Team-Specific Patterns

### Standard Connection Procedure

```tcl
proc network_connect {device user password enable_password device_type} {
    global spawn_id

    network_audit_log $device "CONNECT" "INITIATED" "Connection attempt"

    spawn ssh -o StrictHostKeyChecking=no \
              -o ConnectTimeout=10 \
              "$user@$device"

    expect {
        timeout {
            puts stderr "ERROR: Connection timeout to $device"
            network_audit_log $device "CONNECT" "TIMEOUT" "Connection timeout"
            return 1
        }
        "Connection refused" {
            puts stderr "ERROR: Connection refused by $device"
            network_audit_log $device "CONNECT" "REFUSED" "Connection refused"
            return 1
        }
        "No route to host" {
            puts stderr "ERROR: No route to $device"
            network_audit_log $device "CONNECT" "UNREACHABLE" "No route"
            return 1
        }
        "Password:" {
            log_user 0
            send "$password\r"
            log_user 1
        }
    }

    # Device-specific login handling
    switch $device_type {
        "cisco" {
            expect {
                ">" {
                    send "enable\r"
                    expect "Password:"
                    log_user 0
                    send "$enable_password\r"
                    log_user 1
                    expect "#"
                }
                "#" {
                    # Already privileged
                }
            }
            send "terminal length 0\r"
            expect "#"
        }
        "juniper" {
            expect ">"
            send "set cli screen-length 0\r"
            expect ">"
        }
    }

    network_audit_log $device "CONNECT" "SUCCESS" "Connected successfully"
    return 0
}
```

### Configuration Change Workflow

```tcl
proc safe_config_change {device commands rollback_commands} {
    # Step 1: Create backup
    puts "Creating backup..."
    set backup_file [cisco_backup_config $device]

    network_audit_log $device "BACKUP" "SUCCESS" "Backup: $backup_file"

    # Step 2: Enter config mode
    send "configure terminal\r"
    expect "(config)#"

    # Step 3: Apply configuration
    set success 1
    foreach cmd $commands {
        send "$cmd\r"

        expect {
            timeout {
                puts stderr "ERROR: Timeout executing: $cmd"
                set success 0
                break
            }
            "% Invalid" {
                puts stderr "ERROR: Invalid command: $cmd"
                set success 0
                break
            }
            "(config" {
                # Command accepted
            }
        }
    }

    # Step 4: Exit config mode
    send "end\r"
    expect "#"

    # Step 5: Handle result
    if {$success} {
        # Save configuration
        send "write memory\r"
        expect "#"

        network_audit_log $device "CONFIG" "SUCCESS" "Configuration applied"
        puts "SUCCESS: Configuration applied and saved"
        return 0
    } else {
        # Rollback
        puts "ROLLBACK: Applying rollback configuration"
        send "configure terminal\r"
        expect "(config)#"

        foreach cmd $rollback_commands {
            send "$cmd\r"
            expect "(config"
        }

        send "end\r"
        expect "#"

        network_audit_log $device "CONFIG" "ROLLBACK" "Configuration rolled back"
        return 1
    }
}
```

---

## Integration with Network Management Tools

### Ansible Integration

```yaml
# Playbook to run Expect scripts for legacy devices
- name: Configure legacy network devices
  hosts: legacy_switches
  tasks:
    - name: Run expect script
      shell: |
        export DEVICE_PASSWORD="{{ vault_device_password }}"
        expect /scripts/config_switch.exp {{ inventory_hostname }} {{ ansible_user }}
      register: result
      failed_when: result.rc != 0
```

### Monitoring Integration

**Nagios check integration**:

```tcl
# Exit codes for Nagios
# 0 = OK
# 1 = WARNING
# 2 = CRITICAL
# 3 = UNKNOWN

if {$backup_successful} {
    puts "OK: Device backup completed successfully"
    exit 0
} else {
    puts "CRITICAL: Device backup failed"
    exit 2
}
```

---

## Notes

### Known Device Quirks

**Cisco Catalyst 2960**:
- Slow to respond after "write memory" - use 30s timeout
- Sometimes drops connection during firmware upgrade - retry logic needed

**Juniper EX Series**:
- Configuration commit can take 60+ seconds on large configs
- Must use "commit confirmed" for critical changes

---

## References

- Internal Network Wiki: https://wiki.example.com/network
- Device IP Inventory: https://ipam.example.com
- Network Change Calendar: https://changes.example.com
- On-Call Rotation: https://oncall.example.com/network

---

**Last Updated**: 2025-12-11
**Owner**: Network Engineering Team
**Review Schedule**: Quarterly
