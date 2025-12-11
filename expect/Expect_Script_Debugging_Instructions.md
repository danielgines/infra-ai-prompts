# Expect Script Debugging Instructions — AI Prompt Template

> **Context**: Use this prompt to diagnose and fix problematic Expect scripts that are failing, hanging, or producing unexpected results.
> **Reference**: See `Expect_Best_Practices_Guide.md` (Debugging Techniques) for detailed debugging strategies.

---

## Role & Objective

You are an **Expect debugging specialist** with expertise in diagnosing pattern matching failures, timeout issues, connection problems, and interaction errors in automation scripts.

Your task: Analyze a failing Expect script, **identify the root cause**, and **provide specific fixes** with explanations. Use systematic debugging approach and provide working solutions.

---

## Pre-Execution Configuration

**User must provide:**

1. **Problem description** (choose all that apply):
   - [ ] Script hangs indefinitely
   - [ ] Timeout errors occur
   - [ ] Pattern not matching
   - [ ] Authentication failures
   - [ ] Unexpected output
   - [ ] Connection drops unexpectedly
   - [ ] Commands not executing
   - [ ] Intermittent failures
   - [ ] Other: _________________

2. **Script information**:
   - [ ] Full script code
   - [ ] Error messages (if any)
   - [ ] Expected behavior
   - [ ] Actual behavior
   - [ ] Environment details (OS, Expect version, target system)

3. **Debugging level** (choose one):
   - [ ] **Quick fix**: Identify and fix primary issue
   - [ ] **Comprehensive**: Full analysis with multiple improvements
   - [ ] **Root cause**: Deep dive into underlying problem

4. **Output preference** (choose one):
   - [ ] Fixed script with explanations
   - [ ] Diagnostic report with recommendations
   - [ ] Step-by-step debugging guide
   - [ ] Side-by-side comparison (broken vs fixed)

---

## Debugging Process

### Step 1: Gather Debug Information

**Enable diagnostics in the script:**

```tcl
#!/usr/bin/expect -f

# Add these lines at the top for debugging
exp_internal 1           # Show pattern matching details
log_user 1               # Show all output
set timeout 30           # Reasonable timeout for testing

# Optional: Log to file
log_file -a /tmp/expect_debug.log
```

**Run script and capture output:**

```bash
# Run with debugging
./script.exp 2>&1 | tee debug_output.txt

# Check debug log
cat /tmp/expect_debug.log
```

**What to look for in debug output:**

1. **Pattern matching attempts**:
   ```
   expect: does "Login: " match pattern "password:"? no
   expect: does "Login: user\r\nPassword: " match pattern "password:"? Gate "assword:"? gate=yes re=no
   ```

2. **Timeout indicators**:
   ```
   expect: timeout
   ```

3. **Unexpected EOF**:
   ```
   expect: EOF
   ```

4. **Connection issues**:
   ```
   spawn: connection refused
   spawn: no route to host
   ```

---

### Step 2: Diagnose Common Issues

#### Issue 1: Script Hangs (No Output)

**Symptoms**:
- Script runs but produces no output
- Appears frozen
- No timeout error

**Common Causes**:

1. **Infinite timeout**:
   ```tcl
   set timeout -1  # Script will wait forever
   ```
   **Fix**:
   ```tcl
   set timeout 30  # Reasonable timeout
   ```

2. **Pattern never matches**:
   ```tcl
   expect "exact_prompt$ "  # Prompt is actually "user@host$ "
   ```
   **Debug**:
   ```tcl
   exp_internal 1
   # Run script and see what Expect receives
   ```
   **Fix**:
   ```tcl
   expect -re "\[#\\$\] $"  # Match any shell prompt
   ```

3. **Waiting for input that never comes**:
   ```tcl
   expect_user -re "(.*)\n"  # Waiting for user input
   ```

**Diagnostic script**:
```tcl
#!/usr/bin/expect -f

exp_internal 1
log_user 1
set timeout 10

spawn ssh user@host

# See exactly what Expect receives
expect {
    timeout {
        puts "\n\n=== TIMEOUT DEBUG ==="
        puts "Buffer contains:"
        puts $expect_out(buffer)
        exit 1
    }
    -re "(.*)" {
        puts "\n\n=== RECEIVED ==="
        puts $expect_out(1,string)
        puts "================="
    }
}
```

---

#### Issue 2: Timeout Errors

**Symptoms**:
- "timeout" error messages
- Script exits prematurely

**Common Causes**:

1. **Timeout too short**:
   ```tcl
   set timeout 5  # Too short for SSH on slow network
   ```
   **Fix**:
   ```tcl
   set timeout 30  # More appropriate for network operations
   ```

2. **Slow target system**:
   ```tcl
   # Target takes 15 seconds to show prompt
   set timeout 10  # Too short
   ```
   **Fix**:
   ```tcl
   set timeout 20  # Account for slow systems
   ```

3. **Pattern doesn't match (same as Issue 1)**

**Diagnostic approach**:
```tcl
# Add timeout debugging
expect {
    timeout {
        puts stderr "\n=== TIMEOUT DEBUG ==="
        puts stderr "Expected pattern: 'password:'"
        puts stderr "Buffer contents:"
        puts stderr "=================="
        if {[info exists expect_out(buffer)]} {
            puts stderr $expect_out(buffer)
        } else {
            puts stderr "(buffer empty)"
        }
        puts stderr "=================="
        exit 1
    }
    "password:" {
        # Success
    }
}
```

---

#### Issue 3: Pattern Not Matching

**Symptoms**:
- Timeout occurs even though expected text appears in output
- Pattern matches sometimes but not always

**Common Causes**:

1. **Extra whitespace**:
   ```tcl
   expect "password:"       # Actual: "password: "  (trailing space)
   expect "Login:"          # Actual: "Login: \r\n" (CRLF)
   ```
   **Fix**:
   ```tcl
   expect -re "password:\\s*"   # Allow whitespace
   expect "Login:"              # Use -re for flexibility
   ```

2. **Case sensitivity**:
   ```tcl
   expect "password:"       # Actual: "Password:" (capital P)
   ```
   **Fix**:
   ```tcl
   expect -nocase "password:"
   # Or
   expect -re "(password|Password):"
   ```

3. **Special characters not escaped**:
   ```tcl
   expect "Cost: $500"      # $ has special meaning in patterns
   ```
   **Fix**:
   ```tcl
   expect -ex "Cost: $500"  # Exact match, no interpretation
   ```

4. **Buffer cleared before pattern arrives**:
   ```tcl
   expect "first"
   # Buffer cleared after match
   expect "second"  # May have already appeared and was discarded
   ```
   **Fix**:
   ```tcl
   expect {
       -re "first.*second" {
           # Both in same pattern
       }
   }
   # Or use exp_continue
   expect {
       "first" { exp_continue }
       "second" { # Success }
   }
   ```

**Pattern debugging script**:
```tcl
#!/usr/bin/expect -f

# Capture everything and analyze
spawn ssh user@host

set timeout 30
log_user 1
exp_internal 1

expect {
    timeout {
        puts "\n\n=== PATTERN DEBUG ==="
        puts "Looking for: 'password:'"
        puts "Received:"
        puts "-------------------"
        puts $expect_out(buffer)
        puts "-------------------"

        # Show hex dump to see hidden characters
        binary scan $expect_out(buffer) H* hex
        puts "Hex: $hex"
        exit 1
    }
    -re "(.*)\n" {
        puts "Line: $expect_out(1,string)"
        exp_continue
    }
}
```

---

#### Issue 4: Authentication Failures

**Symptoms**:
- "Permission denied" errors
- "Access denied" messages
- Login loop (keeps asking for password)

**Common Causes**:

1. **Wrong credentials**:
   ```tcl
   set password $env(SSH_PASSWORD)  # Variable not set or wrong
   ```
   **Debug**:
   ```tcl
   # Add validation
   if {![info exists env(SSH_PASSWORD)]} {
       puts stderr "ERROR: SSH_PASSWORD not set"
       exit 1
   }
   set password $env(SSH_PASSWORD)
   if {$password eq ""} {
       puts stderr "ERROR: SSH_PASSWORD is empty"
       exit 1
   }
   puts "DEBUG: Using password of length [string length $password]"
   ```

2. **Password not sent correctly**:
   ```tcl
   send "$password"  # Missing \r (carriage return)
   ```
   **Fix**:
   ```tcl
   send "$password\r"  # Must include \r
   ```

3. **Password sent to wrong prompt**:
   ```tcl
   expect "username:"
   send "$username\r"
   send "$password\r"  # Sent too early!
   expect "password:"  # Too late, already sent
   ```
   **Fix**:
   ```tcl
   expect "username:"
   send "$username\r"
   expect "password:"  # Wait for password prompt
   send "$password\r"  # Then send password
   ```

4. **Special characters in password**:
   ```tcl
   # Password contains: P@ssw0rd!
   send "$password\r"  # Special chars may need escaping
   ```
   **Fix**:
   ```tcl
   send -- "$password\r"  # Use -- to prevent interpretation
   ```

---

#### Issue 5: Connection Drops

**Symptoms**:
- "Connection closed" errors
- EOF (end of file) unexpectedly
- Script works sometimes, fails other times

**Common Causes**:

1. **No eof handler**:
   ```tcl
   expect "$ "  # Connection drops, script hangs
   ```
   **Fix**:
   ```tcl
   expect {
       timeout { puts stderr "Timeout"; exit 1 }
       eof { puts stderr "Connection closed"; exit 1 }
       "$ " { # Success }
   }
   ```

2. **Commands cause disconnect**:
   ```tcl
   send "reboot\r"  # System reboots, connection drops
   expect "$ "      # Will never happen
   ```
   **Fix**:
   ```tcl
   send "reboot\r"
   expect {
       eof {
           puts "System rebooting (expected disconnect)"
           exit 0
       }
   }
   ```

3. **Idle timeout**:
   ```tcl
   # Long pause between commands
   sleep 300  # Server may disconnect idle sessions
   ```
   **Fix**:
   ```tcl
   # Send keepalive or reduce delays
   spawn ssh -o ServerAliveInterval=60 user@host
   ```

---

#### Issue 6: Commands Not Executing

**Symptoms**:
- Commands sent but no output
- Commands appear to be ignored

**Common Causes**:

1. **Missing carriage return**:
   ```tcl
   send "ls"  # Command not sent, missing \r
   ```
   **Fix**:
   ```tcl
   send "ls\r"  # Must end with \r
   ```

2. **Sent before prompt ready**:
   ```tcl
   spawn ssh user@host
   send "ls\r"  # Sent too early, before login!
   ```
   **Fix**:
   ```tcl
   spawn ssh user@host
   expect "password:"
   send "$password\r"
   expect "$ "  # Wait for prompt
   send "ls\r"  # Now send command
   ```

3. **Wrong shell mode** (network devices):
   ```tcl
   # Cisco device in user mode (>)
   send "configure terminal\r"  # Requires privileged mode (#)
   ```
   **Fix**:
   ```tcl
   # Enter privileged mode first
   send "enable\r"
   expect "Password:"
   send "$enable_password\r"
   expect "#"
   # Now can enter config mode
   send "configure terminal\r"
   expect "(config)#"
   ```

---

### Step 3: Apply Systematic Debugging

**Debugging checklist:**

1. **Enable full diagnostics**:
   ```tcl
   exp_internal 1
   log_user 1
   log_file -a /tmp/debug.log
   ```

2. **Add buffer inspection**:
   ```tcl
   expect {
       timeout {
           puts "\nBuffer: $expect_out(buffer)"
           exit 1
       }
       "pattern" { }
   }
   ```

3. **Test patterns incrementally**:
   ```tcl
   # Start with very general pattern
   expect -re ".*"
   puts "Matched: $expect_out(0,string)"

   # Gradually make more specific
   expect -re "pass.*"
   expect -re "password:.*"
   expect "password:"
   ```

4. **Verify each step**:
   ```tcl
   puts "Spawning process..."
   spawn ssh user@host
   puts "Spawn complete, spawn_id: $spawn_id"

   puts "Waiting for password prompt..."
   expect "password:"
   puts "Got password prompt"

   puts "Sending password..."
   send "$password\r"
   puts "Password sent"
   ```

5. **Compare with manual session**:
   ```bash
   # Run manually and save output
   script manual_session.txt
   ssh user@host
   # Perform same operations
   exit
   exit  # Exit script recording

   # Compare with Expect output
   cat manual_session.txt
   cat /tmp/debug.log
   ```

---

## Debugging Tools & Techniques

### Tool 1: autoexpect

Record a manual session and generate Expect script:

```bash
# Start recording
autoexpect -f recorded.exp

# Perform manual session
ssh user@host
# ... interact normally ...
exit

# Review generated script
cat recorded.exp

# Compare patterns with your script
```

### Tool 2: Hex Dump for Hidden Characters

```tcl
# See exactly what's in the buffer
expect {
    timeout {
        set buffer $expect_out(buffer)
        puts "\nBuffer (text): $buffer"

        # Show hex to see \r, \n, etc.
        binary scan $buffer H* hexdata
        puts "Buffer (hex): $hexdata"

        # Show length
        puts "Buffer length: [string length $buffer]"
        exit 1
    }
}
```

### Tool 3: Interactive Debugging

```tcl
# Drop into interactive mode at specific point
interact {
    # User can type and see responses
    # Press Ctrl+] to return to script
}
```

### Tool 4: Incremental Testing

```bash
# Test just connection
expect -c '
    exp_internal 1
    spawn ssh user@host
    expect timeout { puts "Failed" } "password:" { puts "Success" }
'

# Test just authentication
expect -c '
    spawn ssh user@host
    expect "password:"
    send "password\r"
    expect timeout { puts "Failed" } "$ " { puts "Success" }
'
```

---

## Common Solutions Library

### Solution 1: Generic Prompt Waiter

```tcl
proc wait_for_prompt {} {
    expect {
        timeout {
            puts stderr "\n=== PROMPT TIMEOUT DEBUG ==="
            puts stderr "Buffer: $expect_out(buffer)"
            puts stderr "=========================="
            return 1
        }
        eof {
            puts stderr "ERROR: Connection closed"
            return 1
        }
        -re "\[#\\$%>\] $" {
            return 0
        }
    }
}
```

### Solution 2: Robust Authentication

```tcl
proc authenticate {host user password} {
    spawn ssh "$user@$host"

    expect {
        timeout {
            puts stderr "ERROR: Connection timeout"
            return 1
        }
        "Connection refused" {
            puts stderr "ERROR: Connection refused"
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
        "Permission denied" {
            puts stderr "ERROR: Authentication failed"
            return 1
        }
        -re "\[#\\$\] $" {
            return 0
        }
    }
}
```

### Solution 3: Flexible Pattern Matching

```tcl
# Instead of exact pattern
expect "exact_prompt$ "

# Use flexible pattern
expect {
    -re "\\$ $" { puts "Found $ prompt" }
    -re "# $" { puts "Found # prompt" }
    -re "> $" { puts "Found > prompt" }
    -re "% $" { puts "Found % prompt" }
}

# Or single regex for all
expect -re "\[#\\$%>\] $"
```

---

## Output Format

### Diagnostic Report with Fix

```markdown
# Expect Script Debugging Report

**Script**: failing_script.exp
**Issue**: Script hangs at SSH authentication
**Root Cause**: Pattern mismatch on password prompt

---

## Problem Analysis

### User Report
"Script hangs during SSH login, never gets past password entry"

### Investigation
1. Enabled exp_internal debugging
2. Captured buffer at timeout
3. Identified pattern mismatch

### Finding
**Expected pattern**: "password:"
**Actual prompt**: "Password: " (capital P, trailing space)

Buffer contents at timeout:
```
SSH-2.0-OpenSSH_8.2
Password:
```

---

## Root Cause

Line 34 expects lowercase "password:" but target system returns "Password:" with capital P.

**Current code (broken)**:
```tcl
expect "password:"  # Case-sensitive, lowercase only
send "$password\r"
```

---

## Solution

Use case-insensitive pattern matching:

**Fixed code**:
```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout waiting for password prompt"
        puts stderr "Buffer: $expect_out(buffer)"
        exit 1
    }
    -nocase "password:" {
        log_user 0
        send "$password\r"
        log_user 1
    }
}
```

**Alternative (more robust)**:
```tcl
expect {
    timeout {
        puts stderr "ERROR: Timeout waiting for password prompt"
        exit 1
    }
    -re -nocase "password:\\s*" {
        log_user 0
        send "$password\r"
        log_user 1
    }
}
```

---

## Testing

```bash
# Test fixed script
export SSH_PASSWORD='your_password'
./fixed_script.exp test_server testuser

# Expected output:
# Connecting to test_server...
# Logged in successfully
# ...
# Script completed successfully
```

---

## Additional Improvements

While debugging, found other issues:

1. **No timeout handler** (Line 45)
   - Added timeout handler with buffer dump

2. **Missing eof handler** (Line 67)
   - Added eof handler for clean failures

3. **No cleanup** (End of script)
   - Added cleanup function to unset password

See attached fixed_script.exp for complete solution.
```

---

## Prevention Checklist

After fixing, verify:

- [ ] All expect blocks have timeout handlers
- [ ] All expect blocks have eof handlers
- [ ] Patterns use -nocase or -re for flexibility
- [ ] Debug output disabled (exp_internal 0)
- [ ] Passwords not logged
- [ ] Cleanup function present
- [ ] Script tested with slow networks
- [ ] Script tested with fast networks
- [ ] Script tested with authentication failures
- [ ] Script tested with connection failures

---

## References

Debugging techniques from:

- **Best Practices**: `Expect_Best_Practices_Guide.md` (Debugging Techniques section)
- **Common Patterns**: `examples/` directory
- **Standards**: `Expect_Security_Standards_Reference.md`

---

**Last Updated**: 2025-12-11
**Version**: 1.0
