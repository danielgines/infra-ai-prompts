# Expect Automation Instructions

> **Purpose**: Step-by-step instructions for creating automated Expect scripts for interactive application control.

---

## Table of Contents

1. [When to Use Expect](#when-to-use-expect)
2. [Script Creation Workflow](#script-creation-workflow)
3. [Template Structure](#template-structure)
4. [Pattern Discovery Process](#pattern-discovery-process)
5. [Implementation Steps](#implementation-steps)
6. [Testing Strategy](#testing-strategy)
7. [Deployment Guidelines](#deployment-guidelines)

---

## When to Use Expect

### Ideal Use Cases

Use Expect when you need to automate:

- **SSH/Telnet sessions** - Remote server management, network device configuration
- **Interactive prompts** - Password changes, installation wizards, setup scripts
- **File transfers** - SCP/SFTP with password authentication
- **Terminal applications** - Any CLI tool requiring user input
- **Testing** - Automated testing of interactive applications
- **Legacy systems** - Older systems without API access

### When NOT to Use Expect

Consider alternatives when:

- **APIs available** - Use REST APIs, libraries instead of screen scraping
- **SSH keys possible** - Use key-based authentication with Ansible, fabric
- **Modern tools exist** - Ansible, Terraform for infrastructure automation
- **GUI automation needed** - Use Selenium, Puppeteer for web interfaces
- **Simple tasks** - Shell scripts with here-docs may suffice

---

## Script Creation Workflow

### Phase 1: Planning (15-30 minutes)

1. **Define objective** - What needs to be automated?
2. **Identify interactions** - List all prompts and responses
3. **Choose credential method** - Environment variables, key-based auth, or credential file?
4. **Define error scenarios** - What can go wrong?
5. **Security review** - How will credentials be protected?

### Phase 2: Pattern Discovery (30-60 minutes)

1. **Manual session** - Connect manually and document all prompts
2. **Use autoexpect** - Record a session automatically
3. **Analyze output** - Identify exact patterns to match
4. **Test patterns** - Verify patterns are unique and reliable
5. **Document findings** - Note all prompts, patterns, and edge cases

### Phase 3: Implementation (1-2 hours)

1. **Create skeleton** - Use template structure
2. **Implement spawn** - Start the process
3. **Add expect/send pairs** - One interaction at a time
4. **Add error handling** - Timeout, eof, error patterns
5. **Implement logging** - Add audit logging if needed

### Phase 4: Testing (1-2 hours)

1. **Test happy path** - Verify normal operation
2. **Test error cases** - Timeout, wrong password, connection failure
3. **Security test** - Verify no credential exposure
4. **Performance test** - Verify appropriate timeouts
5. **Integration test** - Test with other systems

### Phase 5: Deployment (30 minutes)

1. **Code review** - Peer review for security and quality
2. **Deploy to staging** - Test in non-production environment
3. **Monitor** - Watch for issues
4. **Document** - Update runbooks
5. **Deploy to production** - Roll out to production systems

---

## Template Structure

### Basic Template

```tcl
#!/usr/bin/expect -f

################################################################################
# Script Name: script_name.exp
# Purpose: Brief description of what this script does
# Author: Your Name
# Date: YYYY-MM-DD
# Usage: ./script_name.exp <arg1> <arg2>
################################################################################

# ============================================================================
# CONFIGURATION
# ============================================================================

set timeout 30
log_user 1
exp_internal 0  # Set to 1 for debugging

# ============================================================================
# ARGUMENT VALIDATION
# ============================================================================

if {$argc < 2} {
    puts stderr "Usage: $argv0 <host> <user>"
    puts stderr "Environment variables required: PASSWORD"
    exit 1
}

set host [lindex $argv 0]
set user [lindex $argv 1]

# ============================================================================
# CREDENTIAL MANAGEMENT
# ============================================================================

if {![info exists env(PASSWORD)]} {
    puts stderr "ERROR: PASSWORD environment variable not set"
    exit 1
}

set password $env(PASSWORD)

# ============================================================================
# PROCEDURES
# ============================================================================

proc wait_for_prompt {} {
    expect {
        timeout {
            puts stderr "ERROR: Timeout waiting for shell prompt"
            exit 1
        }
        eof {
            puts stderr "ERROR: Connection closed unexpectedly"
            exit 1
        }
        -re "\[#\\$\] $" {
            return 0
        }
    }
}

proc cleanup {} {
    global spawn_id password

    # Clear sensitive data
    if {[info exists password]} {
        unset password
    }

    # Close connection
    if {[info exists spawn_id]} {
        catch {close}
        catch {wait}
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Set up cleanup on exit
trap cleanup {SIGINT SIGTERM EXIT}

# Spawn process
spawn ssh "$user@$host"

# Handle SSH interactions
expect {
    timeout {
        puts stderr "ERROR: Connection timeout"
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

# Wait for shell prompt
wait_for_prompt

# Execute commands
send "whoami\r"
wait_for_prompt

send "date\r"
wait_for_prompt

# Exit
send "exit\r"
expect eof

# Cleanup
cleanup

exit 0
```

---

## Pattern Discovery Process

### Method 1: autoexpect (Recommended for Beginners)

**Step 1**: Record a session

```bash
autoexpect -f recorded_session.exp
# Perform your manual interactions
# Exit when done
```

**Step 2**: Analyze the generated script

```bash
cat recorded_session.exp
```

**Step 3**: Extract patterns

Look for lines like:
```tcl
expect -exact "password: "
expect -exact "$ "
```

**Step 4**: Test patterns

Use the patterns in your script and verify they work.

---

### Method 2: Manual Analysis

**Step 1**: Connect and save output

```bash
ssh user@host | tee session_output.txt
```

**Step 2**: Analyze prompts

Review `session_output.txt` and identify:
- Login prompts
- Password prompts
- Shell prompts
- Command outputs
- Error messages

**Step 3**: Create pattern list

Document all patterns you need to match:

```
Pattern                     Type        Notes
------------------------   --------    ---------------------------
"password:"                exact       Login prompt
-re "\[#\$\] $"           regex       Shell prompt (# or $)
"Permission denied"        exact       Auth failure
"Connection refused"       exact       Connection error
```

---

### Method 3: Incremental Testing with Debugging

**Step 1**: Enable diagnostics

```tcl
#!/usr/bin/expect -f
exp_internal 1
log_user 1
```

**Step 2**: Add expect patterns one at a time

```tcl
spawn ssh user@host
expect {
    timeout { puts "TIMEOUT"; exit 1 }
    "password:" { puts "GOT PASSWORD PROMPT" }
}
```

**Step 3**: Run and observe

```bash
./test_script.exp 2>&1 | tee debug_output.txt
```

**Step 4**: Adjust patterns based on output

Look at the `expect:` lines in the debug output to see what Expect is matching.

---

## Implementation Steps

### Step 1: Create Script Skeleton

```bash
# Create script file
touch script_name.exp
chmod 700 script_name.exp

# Add shebang and basic structure
cat > script_name.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 30
# Add your code here
EOF
```

### Step 2: Implement Spawn

```tcl
# Spawn the process
spawn ssh user@host

# Verify spawn succeeded
if {![info exists spawn_id]} {
    puts stderr "ERROR: Failed to spawn process"
    exit 1
}
```

### Step 3: Add First Expect/Send Pair

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout"
        exit 1
    }
    "password:" {
        send "$password\r"
    }
}
```

### Step 4: Test Incrementally

```bash
./script_name.exp
# Verify first interaction works before adding more
```

### Step 5: Add Remaining Interactions

```tcl
# After password
expect "$ "
send "whoami\r"

expect "$ "
send "date\r"

expect "$ "
send "exit\r"

expect eof
```

### Step 6: Add Error Handling

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout waiting for prompt"
        exit 1
    }
    eof {
        puts stderr "ERROR: Connection closed"
        exit 1
    }
    "Permission denied" {
        puts stderr "ERROR: Authentication failed"
        exit 1
    }
    "$ " {
        # Success
    }
}
```

### Step 7: Add Logging (Optional)

```tcl
proc log_operation {message} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    puts "\[$timestamp\] $message"
}

log_operation "Connecting to $host"
log_operation "Authentication successful"
log_operation "Executing commands"
log_operation "Script completed successfully"
```

### Step 8: Clean Up

```tcl
# Clear sensitive variables
unset password

# Close connection
close
wait

exit 0
```

---

## Testing Strategy

### Unit Tests

**Test 1: Valid Credentials**

```bash
export PASSWORD="correct_password"
./script.exp host user
# Expected: Success, exit code 0
```

**Test 2: Invalid Credentials**

```bash
export PASSWORD="wrong_password"
./script.exp host user
# Expected: Error message, exit code 1
```

**Test 3: Connection Timeout**

```bash
./script.exp unreachable_host user
# Expected: Timeout error, exit code 1
```

**Test 4: Missing Environment Variable**

```bash
unset PASSWORD
./script.exp host user
# Expected: Error about missing PASSWORD, exit code 1
```

### Integration Tests

**Test 1: Multiple Hosts**

```bash
for host in host1 host2 host3; do
    ./script.exp $host user
done
```

**Test 2: Concurrent Execution**

```bash
./script.exp host1 user &
./script.exp host2 user &
./script.exp host3 user &
wait
```

**Test 3: Long-Running Operations**

```bash
# Script that takes 5+ minutes
time ./long_running_script.exp
```

### Security Tests

**Test 1: Check for Hardcoded Credentials**

```bash
grep -r "password\|passwd\|secret" script.exp
# Expected: No matches
```

**Test 2: Verify File Permissions**

```bash
ls -la script.exp
# Expected: -rwx------ (700)
```

**Test 3: Check Log Output**

```bash
./script.exp host user 2>&1 | grep -i password
# Expected: No matches (passwords should not appear in logs)
```

---

## Deployment Guidelines

### Pre-Deployment Checklist

- [ ] Code reviewed by peer
- [ ] All tests passing
- [ ] Security scan completed
- [ ] File permissions verified (700 for scripts, 600 for credentials)
- [ ] Documentation updated
- [ ] Runbook created or updated

### Staging Deployment

```bash
# Copy to staging server
scp script.exp staging-server:/opt/scripts/

# Set permissions
ssh staging-server "chmod 700 /opt/scripts/script.exp"

# Test in staging
ssh staging-server "/opt/scripts/script.exp staging-host user"
```

### Production Deployment

```bash
# Copy to production server
scp script.exp prod-server:/opt/scripts/

# Set permissions
ssh prod-server "chmod 700 /opt/scripts/script.exp"

# Create backup of old version
ssh prod-server "cp /opt/scripts/script.exp /opt/scripts/script.exp.backup"

# Test in production (non-critical system first)
ssh prod-server "/opt/scripts/script.exp test-host user"

# Monitor logs
ssh prod-server "tail -f /var/log/expect_script.log"
```

### Post-Deployment

- [ ] Verify script runs successfully
- [ ] Monitor logs for errors
- [ ] Set up alerting for failures
- [ ] Document any issues encountered
- [ ] Update runbook with lessons learned

---

## Common Automation Patterns

### Pattern 1: Multi-Host Automation

```tcl
#!/usr/bin/expect -f

set hosts [list "host1" "host2" "host3"]
set user "admin"
set password $env(PASSWORD)

foreach host $hosts {
    puts "Connecting to $host..."

    spawn ssh "$user@$host"

    expect "password:"
    log_user 0
    send "$password\r"
    log_user 1

    expect "$ "
    send "uptime\r"

    expect "$ "
    send "exit\r"

    expect eof
    puts "$host completed\n"
}
```

### Pattern 2: Command Execution with Output Capture

```tcl
#!/usr/bin/expect -f

spawn ssh user@host

expect "password:"
send "$password\r"

expect "$ "
send "df -h\r"

expect -re "(.*)\n.*$ "
set disk_usage $expect_out(1,string)

puts "Disk usage:\n$disk_usage"

send "exit\r"
expect eof
```

### Pattern 3: Interactive Menu Navigation

```tcl
#!/usr/bin/expect -f

spawn application

expect "Main Menu:"
send "1\r"  # Select option 1

expect "Submenu:"
send "2\r"  # Select option 2

expect "Enter value:"
send "100\r"

expect "Confirm (y/n):"
send "y\r"

expect eof
```

---

## Troubleshooting Guide

### Problem: Pattern Not Matching

**Symptoms**: Script hangs, timeout errors

**Solutions**:
1. Enable `exp_internal 1` to see what Expect is matching
2. Check for extra spaces, newlines, or hidden characters
3. Use `-re` for regex patterns if needed
4. Try more general pattern (e.g., `expect "password"` instead of `expect "password: "`)

### Problem: Credentials Not Working

**Symptoms**: "Permission denied", authentication failures

**Solutions**:
1. Verify environment variable is set: `echo $PASSWORD`
2. Test credentials manually first
3. Check for special characters in password that need escaping
4. Ensure `log_user 0` before sending password

### Problem: Script Hangs

**Symptoms**: No output, no timeout error

**Solutions**:
1. Check if timeout is set too high or to -1 (infinite)
2. Verify spawned process is running: `ps aux | grep expect`
3. Enable debugging: `exp_internal 1`
4. Check if waiting for unexpected prompt

### Problem: Passwords Appearing in Logs

**Symptoms**: Passwords visible in stdout or log files

**Solutions**:
1. Use `log_user 0` before `send "$password\r"`
2. Re-enable with `log_user 1` after
3. Review all log output carefully
4. Disable file logging during password operations

---

## Best Practices Summary

1. **Always use templates** - Start with proven structure
2. **Test incrementally** - Add one expect/send pair at a time
3. **Handle all errors** - Timeout, eof, unexpected output
4. **Secure credentials** - Never hardcode, use environment variables or files
5. **Enable debugging during development** - Use `exp_internal 1` and `log_user 1`
6. **Disable debugging in production** - Remove debug code before deployment
7. **Document patterns** - Comment complex regex patterns
8. **Use procedures** - Create reusable functions
9. **Clean up properly** - Close connections and unset sensitive variables
10. **Test security** - Verify no credential exposure in logs or process listings

---

## References

- [Expect Best Practices Guide](./Expect_Best_Practices_Guide.md)
- [Expect Security Standards Reference](./Expect_Security_Standards_Reference.md)
- [Expect Script Checklist](./Expect_Script_Checklist.md)
- [Official Expect Documentation](https://core.tcl-lang.org/expect/index)

---

**Last Updated**: 2025-12-11
