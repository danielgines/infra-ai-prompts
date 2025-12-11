# Expect Best Practices Guide

> **Purpose**: Comprehensive guide for writing effective, secure, and maintainable Expect scripts for interactive application automation.

**Official Documentation**: [https://core.tcl-lang.org/expect/index](https://core.tcl-lang.org/expect/index)

---

## Table of Contents

1. [Introduction to Expect](#introduction-to-expect)
2. [Core Concepts](#core-concepts)
3. [Pattern Matching Best Practices](#pattern-matching-best-practices)
4. [Timeout Handling](#timeout-handling)
5. [Error Handling](#error-handling)
6. [Debugging Techniques](#debugging-techniques)
7. [Security Best Practices](#security-best-practices)
8. [Code Organization](#code-organization)
9. [Common Use Cases](#common-use-cases)
10. [Performance Optimization](#performance-optimization)

---

## Introduction to Expect

**Expect** is a command/scripting language that automates control of interactive applications using pseudo terminals (Unix) or console emulation (Windows). Originally designed by Don Libes in 1990, Expect extends Tcl (Tool Command Language).

### What Expect Does Best

- Automates SSH, Telnet, FTP sessions
- Handles interactive prompts (passwords, confirmations)
- Controls console applications programmatically
- Network device configuration automation
- Testing interactive applications

### Installation

```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install expect

# Fedora/Red Hat/Rocky Linux
sudo dnf install expect

# macOS
brew install expect
```

---

## Core Concepts

### The Four Fundamental Commands

#### 1. spawn

Starts a new process and attaches it to Expect's control.

```tcl
spawn ssh user@hostname
```

**Best Practices:**
- Always check the result of spawn with `expect_out(spawn_id)`
- Spawn only one process per script when possible
- Close spawned processes properly with `close` and `wait`

#### 2. send

Sends a string of characters to the spawned process's input.

```tcl
send "password\r"
```

**Best Practices:**
- Always include `\r` (carriage return) to simulate Enter key
- Use `send -- "$variable\r"` when sending variables (prevents issues with values starting with `-`)
- Precede the first `send` with an `expect` to ensure process is ready

#### 3. expect

Waits for a specific pattern from the spawned process's output.

```tcl
expect "password:"
```

**Best Practices:**
- Always include timeout and eof handling
- Order patterns from most specific to most general
- Use exception strings at the top of expect blocks
- Test patterns thoroughly to avoid false matches

#### 4. interact

Relinquishes control to the user for direct interaction.

```tcl
interact
```

**Best Practices:**
- Use at the end of scripts when user needs to continue manually
- Combine with expect patterns to automate initial setup only
- Ensure proper terminal state before calling interact

---

## Pattern Matching Best Practices

### Pattern Types

Expect supports three pattern matching modes:

#### Glob Patterns (Default)

Shell-style wildcards:

```tcl
expect "password:*"
expect "*Welcome*"
```

#### Regular Expressions

Use `-re` flag for regex patterns:

```tcl
expect -re "password|Password:"
expect -re "\\$ $"  # Shell prompt
```

#### Exact Matching

Use `-ex` flag for literal strings (no special character interpretation):

```tcl
expect -ex "Enter [y/n]:"
```

### Pattern Matching Guidelines

**1. Be Specific**

```tcl
# Bad - too general, may match unexpected output
expect "error"

# Good - specific error message
expect "Error: Authentication failed"
```

**2. Use Appropriate Pattern Type**

```tcl
# Use -ex for strings with special characters
expect -ex "Cost: $500.00"

# Use -re for complex patterns
expect -re "(Connected|Authenticated|Success)"

# Use glob for simple wildcards
expect "Password:*"
```

**3. Handle Case Sensitivity**

```tcl
# Case-insensitive matching
expect -nocase "password:"
```

**4. Order Patterns Correctly**

Write expect commands with exception strings at the top and likely strings at the bottom:

```tcl
expect {
    timeout {
        puts "ERROR: Operation timed out"
        exit 1
    }
    eof {
        puts "ERROR: Connection closed unexpectedly"
        exit 1
    }
    "Permission denied" {
        puts "ERROR: Authentication failed"
        exit 1
    }
    "password:" {
        send "$password\r"
    }
}
```

---

## Timeout Handling

### Setting Timeouts

**Default timeout**: 10 seconds

```tcl
# Set custom timeout
set timeout 30

# Infinite timeout (use with caution)
set timeout -1

# No timeout (return immediately if no match)
set timeout 0
```

### Timeout Best Practices

**1. Always Include Timeout Handling**

```tcl
expect {
    timeout {
        puts "Timeout occurred after $timeout seconds"
        exit 1
    }
    "expected pattern" {
        # Handle success
    }
}
```

**2. Use Appropriate Timeout Values**

```tcl
# Quick operations
set timeout 5
expect "Login:"

# Longer operations (compilation, data transfer)
set timeout 300
expect "Build completed"

# Interactive sessions
set timeout 30
expect "$ "
```

**3. Context-Specific Timeouts**

```tcl
# Save default timeout
set default_timeout $timeout

# Operation-specific timeout
set timeout 60
expect "download complete"

# Restore default
set timeout $default_timeout
```

---

## Error Handling

### Comprehensive Error Handling Pattern

Always handle these three scenarios:

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout waiting for response"
        exit 1
    }
    eof {
        puts stderr "ERROR: Connection closed unexpectedly"
        exit 1
    }
    "expected pattern" {
        # Success case
    }
}
```

### Using exp_continue

Handle multiple patterns in sequence:

```tcl
expect {
    "Are you sure?" {
        send "yes\r"
        exp_continue
    }
    "Password:" {
        send "$password\r"
        exp_continue
    }
    "$ " {
        # Final prompt reached
    }
}
```

### Clean Exit Strategy

```tcl
proc cleanup {} {
    global spawn_id
    if {[info exists spawn_id]} {
        catch {close}
        catch {wait}
    }
    exit 0
}

# Use cleanup on errors
trap cleanup {SIGINT SIGTERM}
```

---

## Debugging Techniques

### exp_internal

Show everything Expect sees and how it matches patterns:

```tcl
# Enable diagnostics
exp_internal 1

# Your expect commands here
spawn ssh user@host

# Disable diagnostics
exp_internal 0
```

### log_user

Control whether process output is logged to stdout:

```tcl
# Disable logging (useful when sending passwords)
log_user 0
send "$password\r"

# Re-enable logging
log_user 1
```

### Debugging Pattern

```tcl
#!/usr/bin/expect -d
# -d flag enables diagnostic output

# Or within script:
exp_internal -f /tmp/expect_debug.log 1
```

### Using autoexpect

Record interactive sessions automatically:

```bash
# Record session to script.exp
autoexpect

# Record to specific file
autoexpect session_recording.exp
```

---

## Security Best Practices

### Never Hardcode Credentials

**Bad Practice:**

```tcl
#!/usr/bin/expect
set password "MyPassword123"  # NEVER DO THIS
```

**Good Practices:**

#### 1. Environment Variables

```tcl
#!/usr/bin/expect
set password $env(SSH_PASSWORD)

if {![info exists password] || $password eq ""} {
    puts stderr "ERROR: SSH_PASSWORD environment variable not set"
    exit 1
}

# Use it
log_user 0
send "$password\r"
log_user 1
```

Usage:
```bash
export SSH_PASSWORD="secret"
./script.exp
unset SSH_PASSWORD
```

#### 2. Read from Secure File

```tcl
#!/usr/bin/expect
set credentials_file "$env(HOME)/.credentials/my_creds"

# Check file permissions (should be 600 or 400)
if {[file exists $credentials_file]} {
    set perms [file attributes $credentials_file -permissions]
    if {$perms != "0600" && $perms != "0400"} {
        puts stderr "ERROR: Credentials file has insecure permissions: $perms"
        puts stderr "Run: chmod 600 $credentials_file"
        exit 1
    }

    set fp [open $credentials_file r]
    set password [read -nonewline $fp]
    close $fp
} else {
    puts stderr "ERROR: Credentials file not found: $credentials_file"
    exit 1
}
```

#### 3. Runtime Prompt

```tcl
#!/usr/bin/expect
stty -echo
send_user "Password: "
expect_user -re "(.*)\n"
send_user "\n"
stty echo
set password $expect_out(1,string)
```

#### 4. Use SSH Keys Instead

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "automation@example.com"

# Copy to remote host
ssh-copy-id user@host

# Now scripts can connect without passwords
spawn ssh user@host
expect "$ "
```

### Secure Logging Practices

```tcl
# Disable logging when handling sensitive data
log_user 0
send "$password\r"
log_user 1

# Or disable logging to file
log_file
send "$password\r"
log_file -a /var/log/expect.log
```

### File Permissions

```bash
# Restrict script permissions
chmod 700 script.exp

# Credentials file should be even more restrictive
chmod 600 ~/.credentials/my_creds
```

### Version Control Safety

```bash
# Add to .gitignore
echo "*.exp" >> .gitignore
echo ".credentials/" >> .gitignore

# If already committed, remove from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch script.exp" \
  --prune-empty --tag-name-filter cat -- --all
```

---

## Code Organization

### Script Structure

```tcl
#!/usr/bin/expect

# ============================================================================
# Script: server_backup.exp
# Purpose: Automate server backup process
# Author: Your Name
# Date: 2025-12-11
# ============================================================================

# Configuration
set timeout 30
set log_file "/var/log/backup_script.log"

# Procedures
proc connect_to_server {host user} {
    global spawn_id
    spawn ssh "$user@$host"

    expect {
        timeout {
            puts stderr "ERROR: Connection timeout"
            return 1
        }
        "Are you sure" {
            send "yes\r"
            exp_continue
        }
        "$ " {
            return 0
        }
    }
}

proc run_backup {} {
    send "backup.sh\r"

    expect {
        timeout {
            puts stderr "ERROR: Backup timeout"
            return 1
        }
        "Backup completed" {
            puts "SUCCESS: Backup completed"
            return 0
        }
    }
}

# Main execution
if {[llength $argv] < 2} {
    puts "Usage: $argv0 <host> <user>"
    exit 1
}

set host [lindex $argv 0]
set user [lindex $argv 1]

# Execute
if {[connect_to_server $host $user] == 0} {
    run_backup
    send "exit\r"
    expect eof
}

# Cleanup
close
wait
```

### Use Procedures for Reusability

```tcl
proc wait_for_prompt {} {
    expect {
        timeout {
            puts stderr "ERROR: Prompt not found"
            exit 1
        }
        -re "\\$ $|# $" {
            return 0
        }
    }
}

# Use it multiple times
wait_for_prompt
send "command1\r"
wait_for_prompt
send "command2\r"
wait_for_prompt
```

---

## Common Use Cases

### SSH Automation

```tcl
#!/usr/bin/expect -f

set timeout 20
set host [lindex $argv 0]
set user [lindex $argv 1]
set password $env(SSH_PASSWORD)

spawn ssh "$user@$host"

expect {
    timeout {
        puts "ERROR: Connection timeout"
        exit 1
    }
    "Are you sure you want to continue connecting" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        log_user 0
        send "$password\r"
        log_user 1
    }
}

expect "$ "
send "uptime\r"
expect "$ "
send "exit\r"
expect eof
```

### SCP File Transfer

```tcl
#!/usr/bin/expect -f

set timeout 300
set password $env(SCP_PASSWORD)
set file [lindex $argv 0]
set remote [lindex $argv 1]

spawn scp $file $remote

expect {
    timeout {
        puts "ERROR: SCP timeout"
        exit 1
    }
    "password:" {
        log_user 0
        send "$password\r"
        log_user 1
    }
}

expect {
    timeout {
        puts "ERROR: Transfer timeout"
        exit 1
    }
    "100%" {
        puts "SUCCESS: File transferred"
    }
    eof {
        puts "SUCCESS: Transfer complete"
    }
}

wait
```

### Network Device Configuration

```tcl
#!/usr/bin/expect -f

set timeout 30
set device [lindex $argv 0]
set password $env(DEVICE_PASSWORD)

spawn telnet $device

expect "Password:"
log_user 0
send "$password\r"
log_user 1

expect "#"
send "show version\r"

expect "#"
send "configure terminal\r"

expect "(config)#"
send "interface gi0/1\r"

expect "(config-if)#"
send "description Uplink to Core\r"

expect "(config-if)#"
send "exit\r"

expect "(config)#"
send "exit\r"

expect "#"
send "write memory\r"

expect "#"
send "exit\r"

expect eof
```

---

## Performance Optimization

### Minimize Spawns

```tcl
# Bad - multiple spawns
spawn ssh host1
expect "$ "
send "exit\r"

spawn ssh host2
expect "$ "
send "exit\r"

# Good - single spawn with multiple commands
spawn ssh host1
expect "$ "
send "ssh host2\r"
expect "$ "
send "exit\r"
expect "$ "
send "exit\r"
```

### Use Efficient Patterns

```tcl
# Less efficient - multiple simple patterns
expect {
    "$ " { }
    "# " { }
    "> " { }
}

# More efficient - single regex
expect -re "\[\\$#>\] $"
```

### Buffer Management

```tcl
# Clear buffer before expecting
expect *

# Or set match_max to control buffer size
match_max 10000  # Default is 2000
```

---

## References

- [Official Expect Homepage](https://core.tcl-lang.org/expect/index)
- [Expect Man Page](https://www.man7.org/linux/man-pages/man1/expect.1.html)
- [Exploring Expect (O'Reilly Book)](https://www.oreilly.com/library/view/exploring-expect/9781565920903/)
- [Expect Examples and Tips](https://www.pantz.org/software/expect/expect_examples_and_tips)
- [Expect Wiki](https://wiki.tcl-lang.org/page/Expect)

---

**Last Updated**: 2025-12-11
