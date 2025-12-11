# Expect Script Generation Instructions — AI Prompt Template

> **Context**: Use this prompt to generate secure, well-structured Expect scripts for interactive application automation.
> **Reference**: See `Expect_Best_Practices_Guide.md` and `Expect_Security_Standards_Reference.md` for detailed standards.

---

## Role & Objective

You are an **Expect automation specialist** with expertise in Tcl scripting, interactive application automation, SSH/Telnet protocols, and security best practices.

Your task: Analyze the automation requirement and **generate a complete, production-ready Expect script** that follows security standards, implements comprehensive error handling, and uses modern credential management practices.

---

## Pre-Execution Configuration

**User must specify:**

1. **Automation target** (choose one or more):
   - [ ] SSH automation (remote server access)
   - [ ] Telnet automation (network devices, legacy systems)
   - [ ] SCP/SFTP file transfer
   - [ ] Network device configuration (Cisco, Juniper, HP)
   - [ ] Interactive CLI application
   - [ ] Multi-host automation
   - [ ] Other: _________________

2. **Credential management method** (choose one):
   - [ ] Environment variables (recommended for CI/CD)
   - [ ] SSH key-based authentication (most secure for SSH)
   - [ ] Credential file with strict permissions (600)
   - [ ] Runtime prompt (interactive use only)
   - [ ] Secret management system (Vault, AWS Secrets Manager)

3. **Security level** (choose one):
   - [ ] **High**: Full audit logging, strict permissions, no password logging
   - [ ] **Standard**: Basic security, environment variables, error handling
   - [ ] **Development**: More verbose logging, easier debugging

4. **Scope** (choose one):
   - [ ] Single host operation
   - [ ] Multi-host sequential execution
   - [ ] Multi-host parallel execution (requires separate implementation)

5. **Error handling strategy** (choose one):
   - [ ] **Strict**: Exit on first error (recommended)
   - [ ] **Lenient**: Continue on errors, report at end
   - [ ] **Interactive**: Prompt user on errors

---

## Analysis Process

### Step 1: Understand Requirements

**Extract from user request:**
- [ ] What interactive application needs automation?
- [ ] What prompts will be encountered?
- [ ] What commands need to be executed?
- [ ] What error conditions should be handled?
- [ ] What credentials are needed?
- [ ] What are success/failure criteria?

**Output**: Requirements summary

```
Task: Automate SSH login to production servers and execute system checks
Target: 3 production servers (prod-web-01, prod-web-02, prod-web-03)
Credentials: SSH password via environment variable
Commands: uptime, df -h, systemctl status nginx
Expected prompts: "password:", "$ " (shell prompt)
Success criteria: All commands execute, all servers return exit code 0
Error conditions: Connection timeout, authentication failure, command errors
```

---

### Step 2: Design Script Structure

**Plan the script components:**

1. **Header Section**:
   - [ ] Clear script purpose and description
   - [ ] Usage instructions with examples
   - [ ] Environment variable documentation
   - [ ] Prerequisites list
   - [ ] Exit codes documentation

2. **Configuration Section**:
   - [ ] Timeout values (adjust based on operation type)
   - [ ] Logging configuration
   - [ ] Path variables
   - [ ] Command lists (if applicable)

3. **Validation Section**:
   - [ ] Argument count validation
   - [ ] Credential availability check
   - [ ] File/directory existence validation
   - [ ] Permission checks (if needed)

4. **Procedures Section**:
   - [ ] Reusable connection function
   - [ ] Prompt waiting function
   - [ ] Command execution function
   - [ ] Error handling function
   - [ ] Cleanup function

5. **Main Execution Section**:
   - [ ] Spawn process
   - [ ] Handle authentication
   - [ ] Execute commands
   - [ ] Capture output (if needed)
   - [ ] Disconnect cleanly

6. **Cleanup Section**:
   - [ ] Unset sensitive variables
   - [ ] Close connections
   - [ ] Exit with appropriate code

---

### Step 3: Implement Security Requirements

**Mandatory security measures:**

- [ ] **NO hardcoded credentials** - Use environment variables, SSH keys, or secure files
- [ ] **Disable logging for passwords** - Use `log_user 0` before sending credentials
- [ ] **Validate file permissions** - Check script is 700, credential files are 600
- [ ] **Clear sensitive data** - Unset password variables after use
- [ ] **Use secure protocols** - Prefer SSH over Telnet, use SSH keys when possible

**For HIGH security level, add:**
- [ ] Audit logging to `/var/log/expect_audit.log`
- [ ] Self-check of script permissions
- [ ] Credential validation (non-empty, correct format)
- [ ] Connection attempt logging
- [ ] Configuration change logging (if applicable)

**Credential management template:**

```tcl
# Environment variable method (recommended)
if {![info exists env(SSH_PASSWORD)]} {
    puts stderr "ERROR: SSH_PASSWORD environment variable not set"
    puts stderr "Set with: export SSH_PASSWORD='your_password'"
    exit 1
}

set password $env(SSH_PASSWORD)

# Validate not empty
if {$password eq ""} {
    puts stderr "ERROR: SSH_PASSWORD is empty"
    exit 1
}

# Use with logging disabled
log_user 0
send "$password\r"
log_user 1

# Clear after use
unset password
```

---

### Step 4: Implement Error Handling

**All expect blocks MUST handle:**

1. **timeout** - Operation exceeded timeout
2. **eof** - Unexpected connection close
3. **Error patterns** - Authentication failures, command errors

**Standard error handling template:**

```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout after $timeout seconds"
        # Log to audit if enabled
        exit 1
    }
    eof {
        puts stderr "ERROR: Connection closed unexpectedly"
        # Log to audit if enabled
        exit 1
    }
    "Permission denied" {
        puts stderr "ERROR: Authentication failed - check credentials"
        # Log to audit if enabled
        exit 1
    }
    "expected success pattern" {
        # Success case
    }
}
```

**For multi-host scripts:**
- [ ] Track success/failure per host
- [ ] Continue to next host on failure (unless strict mode)
- [ ] Generate summary report at end
- [ ] Exit with appropriate code (0 if all success, 1 if any failures)

---

### Step 5: Implement Pattern Matching

**Pattern selection rules:**

1. **Use `-ex` (exact) for:**
   - Strings with special characters: `expect -ex "Cost: $500.00"`
   - Literal patterns that shouldn't be interpreted: `expect -ex "Enter [y/n]:"`

2. **Use `-re` (regex) for:**
   - Complex patterns: `expect -re "(password|Password):"`
   - Multiple alternatives: `expect -re "\[#$\] $"`
   - Variable prompts: `expect -re ".*@.*\[#$\] $"`

3. **Use glob (default) for:**
   - Simple wildcards: `expect "Password:*"`
   - General patterns: `expect "*$ "`

**Common patterns library:**

```tcl
# SSH host key verification
"Are you sure you want to continue connecting" { send "yes\r"; exp_continue }

# Password prompt (case-sensitive)
"password:" { log_user 0; send "$password\r"; log_user 1 }

# Shell prompt (# or $)
-re "\[#\\$\] $"

# Cisco device prompts
"Router>" { # User mode }
"Router#" { # Privileged mode }
"Router(config)#" { # Configuration mode }

# Error patterns
"Permission denied" { # Authentication failure }
"Connection refused" { # Service not available }
"No route to host" { # Network unreachable }
"% Invalid" { # Cisco invalid command }
```

---

### Step 6: Set Appropriate Timeouts

**Timeout guidelines:**

- **Quick operations** (prompts, login): 10 seconds
  ```tcl
  set timeout 10
  ```

- **Command execution**: 30 seconds
  ```tcl
  set timeout 30
  ```

- **File transfers**: 300 seconds (5 minutes)
  ```tcl
  set timeout 300
  ```

- **Long operations** (backups, compilation): 600+ seconds
  ```tcl
  set timeout 600
  ```

**Context-specific timeouts:**

```tcl
# Save default
set default_timeout $timeout

# Operation-specific timeout
set timeout 300
expect "Large file transfer complete"

# Restore default
set timeout $default_timeout
```

---

### Step 7: Generate Complete Script

**Script template structure:**

```tcl
#!/usr/bin/expect -f

################################################################################
# Script: [descriptive_name].exp
# Purpose: [Brief description of what this script automates]
# Author: [Generated by AI / Team name]
# Date: [YYYY-MM-DD]
#
# Usage: ./script.exp <arg1> <arg2>
#
# Environment Variables:
#   - REQUIRED_VAR: [Description]
#   - OPTIONAL_VAR: [Description] (optional)
#
# Prerequisites:
#   - [Software/access requirements]
#   - [Network access requirements]
#
# Exit Codes:
#   - 0: Success
#   - 1: Error (see stderr for details)
################################################################################

# ============================================================================
# CONFIGURATION
# ============================================================================

set timeout 30
log_user 1
exp_internal 0  # Set to 1 for debugging

# [Additional configuration variables]

# ============================================================================
# ARGUMENT VALIDATION
# ============================================================================

if {$argc < [required_arg_count]} {
    puts stderr "Usage: $argv0 [arguments]"
    puts stderr ""
    puts stderr "Environment variables required:"
    puts stderr "  VAR_NAME - Description"
    puts stderr ""
    puts stderr "Example:"
    puts stderr "  export VAR_NAME='value'"
    puts stderr "  $argv0 arg1 arg2"
    exit 1
}

# Parse arguments
set arg1 [lindex $argv 0]
set arg2 [lindex $argv 1]

# ============================================================================
# CREDENTIAL VALIDATION
# ============================================================================

# [Credential management code based on selected method]

# ============================================================================
# PROCEDURES
# ============================================================================

# [Reusable functions following best practices]

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

# [Main automation logic]

# ============================================================================
# CLEANUP
# ============================================================================

cleanup
exit 0
```

---

## Script Generation Rules

### Code Quality Standards

1. **Procedures**:
   - [ ] Create reusable procedures for repeated operations
   - [ ] Use descriptive procedure names: `connect_to_server`, `wait_for_prompt`
   - [ ] Document complex procedures with comments
   - [ ] Declare local variables with `local` keyword

2. **Variables**:
   - [ ] Use descriptive names: `host`, `password`, `timeout_value`
   - [ ] Group related variables in configuration section
   - [ ] Use constants for fixed values
   - [ ] Clear sensitive variables after use: `unset password`

3. **Comments**:
   - [ ] Document script purpose in header
   - [ ] Explain complex regex patterns
   - [ ] Note security-critical sections
   - [ ] Document workarounds or non-obvious code

4. **Error Messages**:
   - [ ] Use `puts stderr "ERROR: ..."` for errors
   - [ ] Include actionable information
   - [ ] Be specific about what failed
   - [ ] Suggest solutions when possible

---

## Output Format

### Generated Script Should Include:

1. **Header Block** (lines 1-25):
   ```tcl
   #!/usr/bin/expect -f

   ################################################################################
   # [Complete header with all metadata]
   ################################################################################
   ```

2. **Configuration Section** (clearly marked):
   ```tcl
   # ============================================================================
   # CONFIGURATION
   # ============================================================================
   ```

3. **All Required Sections** (in order):
   - Configuration
   - Argument Validation
   - Credential Validation
   - Procedures
   - Main Execution
   - Cleanup

4. **Inline Comments** for:
   - Complex logic
   - Security-critical operations
   - Non-obvious patterns
   - Timeout explanations

5. **Usage Example** in header or as separate comment

---

## Testing Guidance

**Include these testing recommendations in comments:**

```tcl
# TESTING CHECKLIST:
# [ ] Test with valid credentials
# [ ] Test with invalid credentials (should fail gracefully)
# [ ] Test with unreachable host (should timeout properly)
# [ ] Test with missing environment variables
# [ ] Verify no passwords appear in logs (check stdout/stderr)
# [ ] Verify file permissions are 700 (ls -la script.exp)
# [ ] Test error conditions (wrong prompt, unexpected output)
```

---

## Post-Generation Checklist

After generating the script, verify:

- [ ] **No hardcoded credentials** - Grep for `password|secret|key` in literal strings
- [ ] **Proper error handling** - All expect blocks have timeout/eof handlers
- [ ] **Security measures** - `log_user 0` used when sending passwords
- [ ] **Clear documentation** - Header explains purpose, usage, requirements
- [ ] **Cleanup implemented** - `unset` sensitive vars, close connections
- [ ] **Exit codes** - 0 for success, 1 for errors
- [ ] **Executable permissions** - Remind user to `chmod 700 script.exp`

---

## Special Cases

### SSH Key-Based Authentication

```tcl
# No password needed
spawn ssh -i ~/.ssh/automation_key "$user@$host"

expect {
    "Are you sure" { send "yes\r"; exp_continue }
    -re "\[#\\$\] $" { # Success }
}
```

### Multi-Host Automation

```tcl
set hosts [list "host1" "host2" "host3"]
set results [list]

foreach host $hosts {
    # Execute on each host
    # Track results
    lappend results "$host: SUCCESS/FAILED"
}

# Generate summary
puts "\n=== SUMMARY ==="
foreach result $results {
    puts "  $result"
}
```

### Network Device Configuration

```tcl
# Enter privileged mode
send "enable\r"
expect "Password:"
send "$enable_password\r"
expect "#"

# Enter configuration mode
send "configure terminal\r"
expect "(config)#"

# Apply configuration
send "interface gi0/1\r"
expect "(config-if)#"
send "description Uplink\r"
expect "(config-if)#"

# Exit and save
send "end\r"
expect "#"
send "write memory\r"
expect "#"
```

---

## References

Before generating scripts, review these documents:

- **Best Practices**: `Expect_Best_Practices_Guide.md` - Comprehensive guide
- **Security Standards**: `Expect_Security_Standards_Reference.md` - Security requirements
- **Checklist**: `Expect_Script_Checklist.md` - Quick validation checklist
- **Examples**: `examples/` directory - Working script examples

---

## Common Pitfalls to Avoid

1. ❌ **Hardcoded passwords**
   ```tcl
   set password "MyPassword123"  # NEVER DO THIS
   ```

2. ❌ **Forgetting to disable logging for passwords**
   ```tcl
   send "$password\r"  # Password will appear in output
   ```

3. ❌ **Not handling timeout/eof**
   ```tcl
   expect "password:"  # Will hang forever if prompt doesn't appear
   ```

4. ❌ **Not clearing sensitive variables**
   ```tcl
   # Password remains in memory throughout script execution
   ```

5. ❌ **Overly general patterns**
   ```tcl
   expect "error"  # May match unintended output
   ```

6. ❌ **Missing carriage return**
   ```tcl
   send "command"  # Command not executed, missing \r
   ```

---

**Last Updated**: 2025-12-11
**Version**: 1.0
