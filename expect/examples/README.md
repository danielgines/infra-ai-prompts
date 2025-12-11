# Expect Script Examples

> **Purpose**: Practical, working examples of Expect scripts for common automation tasks.

---

## Available Examples

### 1. ssh_automation_basic.exp

**Purpose**: Basic SSH automation demonstrating connection, command execution, and disconnection.

**Features**:
- Secure password handling via environment variables
- Proper error handling (timeout, eof, connection errors)
- Multiple command execution
- Clean disconnect and cleanup

**Usage**:
```bash
# Set password
export SSH_PASSWORD='your_password'

# Run script
./ssh_automation_basic.exp 192.168.1.100 admin

# Clean up
unset SSH_PASSWORD
```

**What it demonstrates**:
- SSH connection with password authentication
- Handling SSH host key verification
- Waiting for shell prompts
- Executing multiple commands
- Proper cleanup and exit

---

### 2. scp_file_transfer.exp

**Purpose**: Automate SCP file transfers (upload and download) with password authentication.

**Features**:
- Bi-directional transfer support (upload and download)
- File validation before transfer
- Transfer progress monitoring
- Large file support (300s timeout)
- Comprehensive error handling

**Usage**:
```bash
# Set password
export SCP_PASSWORD='your_password'

# Upload a file
./scp_file_transfer.exp /local/file.txt user@192.168.1.100:/remote/path/

# Download a file
./scp_file_transfer.exp user@192.168.1.100:/remote/file.txt /local/path/

# Clean up
unset SCP_PASSWORD
```

**What it demonstrates**:
- SCP automation with password
- File size detection
- Upload and download operations
- Transfer completion detection (100%)
- Exit code checking

---

### 3. multi_host_automation.exp

**Purpose**: Execute commands on multiple hosts sequentially with comprehensive reporting.

**Features**:
- Multiple host support
- Sequential execution
- Per-host error handling
- Comprehensive summary report
- Success/failure tracking

**Usage**:
```bash
# Set password
export SSH_PASSWORD='your_password'

# Run on multiple hosts
./multi_host_automation.exp admin server1 server2 server3

# Clean up
unset SSH_PASSWORD
```

**What it demonstrates**:
- Looping through multiple hosts
- Reusable procedures for connection/execution/disconnect
- Result tracking and reporting
- Graceful failure handling (continue to next host on error)
- Summary statistics

**Customization**:

Edit the `commands` list in the script to change what commands are executed:

```tcl
set commands {
    "hostname"
    "uptime"
    "df -h | head -3"
    "free -m"
    "last -n 5"
}
```

---

## Running the Examples

### Prerequisites

1. **Install Expect**:
```bash
# Debian/Ubuntu
sudo apt-get install expect

# Fedora/Red Hat
sudo dnf install expect

# macOS
brew install expect
```

2. **Set Execute Permissions**:
```bash
chmod +x *.exp
```

3. **Set Up Test Environment** (optional):

For testing, you can use a local SSH server:

```bash
# Install SSH server (if not already installed)
sudo apt-get install openssh-server

# Start SSH service
sudo systemctl start sshd

# Test with localhost
export SSH_PASSWORD='your_local_password'
./ssh_automation_basic.exp localhost $(whoami)
```

---

## Security Notes for Examples

### Important Reminders

1. **Environment Variables**: These examples use environment variables for passwords. This is acceptable for learning and development but not ideal for production.

2. **Production Alternatives**:
   - Use SSH keys instead of passwords
   - Use secret management systems (Vault, AWS Secrets Manager)
   - Use credential files with strict permissions (600)

3. **Never Commit Passwords**:
```bash
# These examples are safe to commit because:
# - No hardcoded passwords
# - Use environment variables
# - Clear passwords after use
```

4. **File Permissions**:
```bash
# Set restrictive permissions on all scripts
chmod 700 *.exp

# Verify permissions
ls -la *.exp
# Should show: -rwx------ (700)
```

---

## Customization Guide

### Modifying Timeouts

```tcl
# Quick operations
set timeout 10

# Long-running operations
set timeout 300

# Infinite timeout (use with caution)
set timeout -1
```

### Changing Prompt Patterns

```tcl
# Current pattern (matches # and $)
expect -re "\[#\\$\] $"

# Custom pattern for specific prompt
expect "myserver $ "

# More complex pattern
expect -re "(\\$|#|>) $"
```

### Adding New Commands

In `ssh_automation_basic.exp`:

```tcl
# Add after existing commands
send "your_command_here\r"
wait_for_prompt
```

In `multi_host_automation.exp`:

```tcl
# Edit the commands list
set commands {
    "hostname"
    "uptime"
    "your_command_1"
    "your_command_2"
}
```

### Adding Logging

```tcl
# Add at the beginning of script
set log_file "/var/log/expect_script.log"
log_file -a $log_file

# Your script here

# Close log at the end
log_file
```

---

## Troubleshooting

### Problem: "permission denied" errors

**Solution**:
```bash
# Verify credentials
echo $SSH_PASSWORD  # Should show your password

# Test SSH manually
ssh user@host  # Verify you can connect with the password
```

### Problem: Script hangs

**Solution**:
```bash
# Enable debugging
# Add this line after the shebang:
exp_internal 1

# Run script again to see what it's waiting for
```

### Problem: Prompt not recognized

**Solution**:
```bash
# Check your actual prompt
echo $PS1

# Modify the prompt pattern in the script
# Change this:
expect -re "\[#\\$\] $"

# To match your prompt:
expect "your_prompt> "
```

### Problem: Commands execute too fast

**Solution**:
```tcl
# Add delays between commands
send "command1\r"
wait_for_prompt
sleep 1  # Wait 1 second
send "command2\r"
wait_for_prompt
```

---

## Learning Path

### Beginner

1. Start with `ssh_automation_basic.exp`
   - Understand connection flow
   - Practice with your own commands
   - Test error scenarios (wrong password, bad host)

2. Move to `scp_file_transfer.exp`
   - Try uploading and downloading files
   - Experiment with different file sizes
   - Test timeout scenarios

### Intermediate

3. Study `multi_host_automation.exp`
   - Understand procedure usage
   - Modify command list
   - Add custom reporting

4. Create your own variations:
   - Combine features from multiple examples
   - Add custom procedures
   - Implement specific use cases for your environment

### Advanced

5. Create production scripts based on these examples:
   - Add audit logging
   - Implement retry logic
   - Add configuration file support
   - Integrate with monitoring systems

---

## Additional Resources

- [Expect Best Practices Guide](../Expect_Best_Practices_Guide.md) - Comprehensive best practices
- [Expect Security Standards](../Expect_Security_Standards_Reference.md) - Security guidelines
- [Expect Automation Instructions](../Expect_Automation_Instructions.md) - Step-by-step automation guide
- [Official Expect Documentation](https://core.tcl-lang.org/expect/index)

---

## Contributing Examples

If you've created a useful Expect script and want to share it:

1. **Follow the template**:
   - Use the same header format
   - Include comprehensive error handling
   - Use environment variables for credentials
   - Add detailed comments

2. **Test thoroughly**:
   - Test with valid and invalid inputs
   - Test error scenarios
   - Verify cleanup works properly

3. **Document usage**:
   - Add to this README
   - Include usage examples
   - Document any special requirements

---

**Last Updated**: 2025-12-11
