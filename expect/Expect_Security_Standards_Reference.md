# Expect Security Standards Reference

> **Purpose**: Security standards and best practices for Expect scripts to prevent credential exposure, unauthorized access, and security vulnerabilities.

**Security References**:
- [CWE-798: Use of Hard-coded Credentials](https://cwe.mitre.org/data/definitions/798.html)
- [OWASP: Hard-coded Password](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)

---

## Table of Contents

1. [Critical Security Risks](#critical-security-risks)
2. [Credential Management](#credential-management)
3. [File Permission Standards](#file-permission-standards)
4. [Secure Logging Practices](#secure-logging-practices)
5. [Version Control Safety](#version-control-safety)
6. [Network Security](#network-security)
7. [Audit and Compliance](#audit-and-compliance)
8. [Security Checklist](#security-checklist)

---

## Critical Security Risks

### Why Expect Scripts Are High-Risk

Expect scripts often handle sensitive credentials and access critical systems. Common vulnerabilities include:

#### 1. Hardcoded Credentials

**Risk Level**: CRITICAL

Hardcoding passwords in scripts exposes credentials to:
- Anyone with file system access
- Version control history
- Backup systems
- Log files
- Process listings

**Real-World Breaches:**
- 2022 Uber breach: PowerShell scripts with hardcoded credentials
- GitHub credential leaks: Thousands of exposed credentials annually

#### 2. Insecure File Permissions

**Risk Level**: HIGH

Scripts with world-readable permissions expose credentials to all system users.

#### 3. Credential Logging

**Risk Level**: HIGH

Passwords appearing in logs, debug output, or terminal history.

#### 4. Process Exposure

**Risk Level**: MEDIUM

Passwords passed as command-line arguments visible in `ps` output.

---

## Credential Management

### NEVER Hardcode Credentials

**❌ PROHIBITED - Never Do This:**

```tcl
#!/usr/bin/expect
# SECURITY VIOLATION - Hardcoded password
set password "MyPassword123"
set db_password "DatabasePass456"
```

**Why This Is Dangerous:**
- Readable by anyone with file access
- Exposed in version control
- Visible in backups
- Cannot rotate without script updates
- Discoverable by automated scanners

---

### ✅ Secure Credential Methods

#### Method 1: Environment Variables (Recommended for Automation)

**Implementation:**

```tcl
#!/usr/bin/expect

# Read from environment variable
if {![info exists env(SSH_PASSWORD)]} {
    puts stderr "ERROR: SSH_PASSWORD environment variable not set"
    puts stderr "Usage: export SSH_PASSWORD='your_password' && $argv0"
    exit 1
}

set password $env(SSH_PASSWORD)

# Validate password is not empty
if {$password eq ""} {
    puts stderr "ERROR: SSH_PASSWORD is empty"
    exit 1
}

# Use password securely
log_user 0
send "$password\r"
log_user 1

# Clear from memory when done
unset password
```

**Usage:**

```bash
# Set environment variable
export SSH_PASSWORD='SecurePassword123'

# Run script
./secure_script.exp

# Immediately unset
unset SSH_PASSWORD

# Or one-liner (password not stored in history with space prefix)
 SSH_PASSWORD='SecurePassword123' ./secure_script.exp
```

**Advantages:**
- No credentials in script files
- Easy to rotate passwords
- Works with automation systems
- Can be set by CI/CD securely

**Disadvantages:**
- Visible in process environment (use carefully)
- Requires secure shell configuration

---

#### Method 2: Secure Credential File (Recommended for Manual Use)

**Implementation:**

```tcl
#!/usr/bin/expect

set credentials_file "$env(HOME)/.credentials/expect_creds"

# Verify file exists
if {![file exists $credentials_file]} {
    puts stderr "ERROR: Credentials file not found: $credentials_file"
    puts stderr "Create with: echo 'password' > $credentials_file && chmod 600 $credentials_file"
    exit 1
}

# Check file permissions (must be 600 or 400)
set file_perms [file attributes $credentials_file -permissions]

if {$file_perms != "0600" && $file_perms != "0400"} {
    puts stderr "ERROR: Insecure file permissions: $file_perms"
    puts stderr "Fix with: chmod 600 $credentials_file"
    exit 1
}

# Read password
set fp [open $credentials_file r]
set password [read -nonewline $fp]
close $fp

# Validate
if {$password eq ""} {
    puts stderr "ERROR: Credentials file is empty"
    exit 1
}

# Use password
log_user 0
send "$password\r"
log_user 1

# Clear from memory
unset password
```

**Setup:**

```bash
# Create credentials directory
mkdir -p ~/.credentials
chmod 700 ~/.credentials

# Store password (note: leading space prevents history storage)
 echo 'MySecurePassword' > ~/.credentials/expect_creds

# Secure permissions
chmod 600 ~/.credentials/expect_creds

# Verify
ls -la ~/.credentials/expect_creds
# Should show: -rw------- (600)
```

**Advantages:**
- Credentials in secure location
- Proper file permissions enforced
- Easy to update passwords
- Not visible in process list

---

#### Method 3: Runtime Password Prompt (Most Secure)

**Implementation:**

```tcl
#!/usr/bin/expect

proc read_password {prompt} {
    send_user "$prompt"
    stty -echo
    expect_user -re "(.*)\n"
    send_user "\n"
    stty echo
    return $expect_out(1,string)
}

# Prompt for password at runtime
set password [read_password "Enter password: "]

# Validate
if {$password eq ""} {
    puts stderr "ERROR: Password cannot be empty"
    exit 1
}

# Use password
log_user 0
send "$password\r"
log_user 1

# Clear from memory
unset password
```

**Advantages:**
- Most secure: no stored credentials
- Password never touches disk
- Cannot be leaked via files or environment

**Disadvantages:**
- Requires interactive user
- Cannot be automated

---

#### Method 4: SSH Key-Based Authentication (Best Practice)

**Setup:**

```bash
# Generate SSH key pair (Ed25519 recommended)
ssh-keygen -t ed25519 -C "automation-script" -f ~/.ssh/automation_key

# Set secure permissions
chmod 600 ~/.ssh/automation_key
chmod 644 ~/.ssh/automation_key.pub

# Copy public key to remote host
ssh-copy-id -i ~/.ssh/automation_key.pub user@remote-host

# Or manually append to authorized_keys
cat ~/.ssh/automation_key.pub | ssh user@remote-host 'cat >> ~/.ssh/authorized_keys'
```

**Expect Script:**

```tcl
#!/usr/bin/expect

set timeout 20
set host [lindex $argv 0]
set user [lindex $argv 1]
set key "$env(HOME)/.ssh/automation_key"

# No password needed with key-based auth
spawn ssh -i $key "$user@$host"

expect {
    timeout {
        puts stderr "ERROR: Connection timeout"
        exit 1
    }
    "Are you sure" {
        send "yes\r"
        exp_continue
    }
    "$ " {
        # Connected successfully
    }
}

# Execute commands
send "whoami\r"
expect "$ "
send "exit\r"
expect eof
```

**Advantages:**
- No passwords to manage
- More secure than passwords
- Perfect for automation
- Key rotation without script changes

---

#### Method 5: Secret Management Systems (Enterprise)

**Integration Examples:**

**HashiCorp Vault:**

```tcl
#!/usr/bin/expect

# Retrieve password from Vault
set vault_token $env(VAULT_TOKEN)
set vault_addr $env(VAULT_ADDR)

# Call vault CLI to get password
set vault_cmd "vault kv get -field=password secret/myapp/ssh"
set password [exec {*}$vault_cmd]

# Use password
log_user 0
send "$password\r"
log_user 1

# Clear from memory
unset password
```

**AWS Secrets Manager:**

```bash
#!/bin/bash
# Wrapper script
PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id prod/ssh/password \
  --query SecretString \
  --output text)

export SSH_PASSWORD="$PASSWORD"
expect ./script.exp
unset SSH_PASSWORD
```

---

## File Permission Standards

### Script Files

```bash
# Expect scripts should be executable by owner only
chmod 700 script.exp

# Verify permissions
ls -la script.exp
# Should show: -rwx------ (700)
```

### Credential Files

```bash
# Credential files: read-only by owner
chmod 600 ~/.credentials/creds

# Or even more restrictive (read-only, no write)
chmod 400 ~/.credentials/creds

# Directory permissions
chmod 700 ~/.credentials
```

### Permission Enforcement in Scripts

```tcl
#!/usr/bin/expect

# Self-check script permissions
set script_path [file normalize $argv0]
set script_perms [file attributes $script_path -permissions]

if {$script_perms != "0700" && $script_perms != "0500"} {
    puts stderr "WARNING: Script has insecure permissions: $script_perms"
    puts stderr "Recommended: chmod 700 $script_path"
}

# Check credentials file permissions
proc verify_file_permissions {filepath required_perms} {
    if {![file exists $filepath]} {
        puts stderr "ERROR: File not found: $filepath"
        return 1
    }

    set perms [file attributes $filepath -permissions]

    if {$perms != $required_perms} {
        puts stderr "ERROR: Insecure permissions on $filepath"
        puts stderr "Current: $perms, Required: $required_perms"
        puts stderr "Fix with: chmod [string range $required_perms 1 end] $filepath"
        return 1
    }

    return 0
}

# Usage
if {[verify_file_permissions "~/.credentials/creds" "0600"] != 0} {
    exit 1
}
```

---

## Secure Logging Practices

### Disable Logging for Sensitive Operations

```tcl
#!/usr/bin/expect

# Normal logging enabled
log_user 1
send "username\r"

# Disable logging before sending password
log_user 0
send "$password\r"

# Re-enable logging
log_user 1

expect "$ "
send "whoami\r"
```

### File Logging Security

```tcl
#!/usr/bin/expect

set log_file "/var/log/expect_script.log"

# Ensure log directory exists with secure permissions
file mkdir [file dirname $log_file]
exec chmod 700 [file dirname $log_file]

# Start logging
log_file -a $log_file

# Secure log file permissions
exec chmod 600 $log_file

# Your script operations here

# Disable file logging for password
log_file
log_user 0
send "$password\r"
log_user 1

# Resume logging
log_file -a $log_file
```

### Sanitize Logs

```tcl
proc log_sanitized {message} {
    # Remove potential passwords (basic example)
    regsub -all {[Pp]assword[:\s]+\S+} $message "Password: [REDACTED]" clean_message
    puts $clean_message
}

# Usage
log_sanitized "Sending password: MySecret123"
# Output: Sending password: [REDACTED]
```

---

## Version Control Safety

### .gitignore Configuration

Create `.gitignore` in your repository:

```gitignore
# Expect scripts with credentials
*_creds.exp
*_password.exp

# Credential files
.credentials/
*.creds
*.password

# Log files
*.log
expect_*.log

# Backup files
*.exp~
*.exp.bak
```

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Check for potential credential patterns in Expect scripts
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '.exp$')

if [ -n "$FILES" ]; then
    echo "Checking Expect scripts for hardcoded credentials..."

    for FILE in $FILES; do
        # Check for common password patterns
        if grep -qE 'set (password|passwd|pwd|secret|token)[ ]*[=][ ]*["\x27][^\x27"]+["\x27]' "$FILE"; then
            echo "ERROR: Potential hardcoded credential in $FILE"
            echo "Please use environment variables or secure credential storage"
            exit 1
        fi
    done
fi

exit 0
```

Make executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Removing Committed Credentials

If credentials were accidentally committed:

```bash
# Install BFG Repo-Cleaner
# https://rtyley.github.io/bfg-repo-cleaner/

# Remove file from all history
bfg --delete-files script_with_password.exp

# Or replace password strings
bfg --replace-text passwords.txt

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (coordinate with team!)
git push --force
```

---

## Network Security

### Use Encrypted Protocols

```tcl
# ✅ GOOD - Encrypted protocols
spawn ssh user@host
spawn sftp user@host
spawn scp file user@host:/path

# ❌ BAD - Unencrypted protocols (avoid when possible)
spawn telnet host
spawn ftp host
spawn rsh host
```

### SSH Configuration

Create `~/.ssh/config`:

```ssh-config
# Default SSH configuration for automation
Host automation-*
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    IdentityFile ~/.ssh/automation_key
    PreferredAuthentications publickey
    PubkeyAuthentication yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    Compression yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### Expect Script with Secure SSH

```tcl
#!/usr/bin/expect

set timeout 20
set host [lindex $argv 0]
set user [lindex $argv 1]

# Use secure SSH options
spawn ssh -o StrictHostKeyChecking=yes \
         -o UserKnownHostsFile=~/.ssh/known_hosts \
         -o PreferredAuthentications=publickey \
         "$user@$host"

expect {
    "Host key verification failed" {
        puts stderr "ERROR: Host key verification failed"
        puts stderr "Possible man-in-the-middle attack!"
        exit 1
    }
    timeout {
        puts stderr "ERROR: Connection timeout"
        exit 1
    }
    "$ " {
        # Connected successfully
    }
}
```

---

## Audit and Compliance

### Audit Logging

```tcl
#!/usr/bin/expect

proc audit_log {action status details} {
    set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    set user $env(USER)
    set host [info hostname]
    set audit_file "/var/log/expect_audit.log"

    set log_entry "$timestamp | $user@$host | $action | $status | $details"

    # Append to audit log
    if {[catch {
        set fp [open $audit_file a]
        puts $fp $log_entry
        close $fp
    } err]} {
        puts stderr "WARNING: Failed to write audit log: $err"
    }
}

# Usage examples
audit_log "SSH_CONNECTION" "INITIATED" "Connecting to prod-server-01"
audit_log "SSH_CONNECTION" "SUCCESS" "Connected to prod-server-01"
audit_log "COMMAND_EXECUTION" "SUCCESS" "Executed: backup.sh"
audit_log "SSH_CONNECTION" "CLOSED" "Disconnected from prod-server-01"
```

### Compliance Checklist

- [ ] No hardcoded credentials in scripts
- [ ] Script files have 700 or 600 permissions
- [ ] Credential files have 600 or 400 permissions
- [ ] Passwords not logged to files or stdout
- [ ] Scripts not committed to public repositories
- [ ] Audit logging implemented for critical operations
- [ ] SSH keys used instead of passwords where possible
- [ ] Regular credential rotation schedule
- [ ] Access review performed quarterly
- [ ] Security scanning tools run on scripts

---

## Security Checklist

### Before Deployment

- [ ] **No hardcoded credentials** - Verified all passwords use secure methods
- [ ] **File permissions set** - chmod 700 on scripts, 600 on credential files
- [ ] **Logging reviewed** - Passwords not logged anywhere
- [ ] **Version control safe** - Scripts do not contain secrets
- [ ] **SSH keys preferred** - Using key-based auth where possible
- [ ] **Environment validated** - Credentials passed securely
- [ ] **Error handling** - Secure failure modes implemented
- [ ] **Documentation** - Security procedures documented
- [ ] **Access control** - Only authorized users can execute
- [ ] **Audit logging** - Critical operations logged

### During Development

- [ ] Use environment variables or credential files
- [ ] Test with log_user and log_file disabled for password operations
- [ ] Validate file permissions in code
- [ ] Use `unset password` after use
- [ ] Never commit scripts with credentials to version control
- [ ] Use pre-commit hooks to catch credential patterns
- [ ] Code review focuses on security

### After Deployment

- [ ] Regular security audits
- [ ] Credential rotation schedule
- [ ] Access reviews
- [ ] Log monitoring
- [ ] Permission verification
- [ ] Update credentials if scripts are compromised
- [ ] Incident response plan documented

---

## Quick Reference: Credential Method Selection

| Method | Security | Automation | Interactive | Best For |
|--------|----------|------------|-------------|----------|
| Environment Variables | ⭐⭐⭐ | ✅ Yes | ❌ No | CI/CD, scheduled jobs |
| Credential Files | ⭐⭐⭐⭐ | ✅ Yes | ❌ No | Manual execution, multiple scripts |
| Runtime Prompt | ⭐⭐⭐⭐⭐ | ❌ No | ✅ Yes | Manual, one-time operations |
| SSH Keys | ⭐⭐⭐⭐⭐ | ✅ Yes | ✅ Yes | All SSH operations (recommended) |
| Secret Management | ⭐⭐⭐⭐⭐ | ✅ Yes | ✅ Yes | Enterprise, compliance requirements |
| Hardcoded (NEVER) | ⭐ | ✅ Yes | ✅ Yes | **NEVER USE** |

---

## References

- [CWE-798: Use of Hard-coded Credentials](https://cwe.mitre.org/data/definitions/798.html)
- [OWASP: Hard-coded Password](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)
- [BeyondTrust: Hardcoded Credentials](https://www.beyondtrust.com/blog/entry/hardcoded-and-embedded-credentials-are-an-it-security-hazard-heres-what-you-need-to-know)
- [Secure Code Warrior: Hardcoded Credentials](https://www.securecodewarrior.com/article/hardcoded-credentials-introduce-security-risk)
- [Codacy: Hard-coded Secrets](https://blog.codacy.com/hard-coded-secrets)

---

**Last Updated**: 2025-12-11
**Review Schedule**: Quarterly
