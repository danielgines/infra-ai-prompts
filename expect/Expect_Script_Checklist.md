# Expect Script Checklist

> **Purpose**: Quick reference checklist for writing secure, reliable, and maintainable Expect scripts.

---

## Before Writing

- [ ] **Verify necessity** - Is Expect the right tool? Consider alternatives (Ansible, Python Paramiko, etc.)
- [ ] **Plan authentication** - Will use SSH keys, environment variables, or credential files?
- [ ] **Define scope** - What interactive applications will be automated?
- [ ] **Review security requirements** - Compliance, audit logging, credential management

---

## Script Structure

- [ ] **Shebang line** - `#!/usr/bin/expect` or `#!/usr/bin/expect -f`
- [ ] **Header comment** - Purpose, author, date, usage instructions
- [ ] **Configuration section** - Timeout, variables, paths
- [ ] **Procedures** - Reusable functions for common operations
- [ ] **Main execution** - Primary script logic
- [ ] **Cleanup section** - Close connections, unset sensitive variables

---

## Security

### Credential Management

- [ ] **No hardcoded passwords** - Never use `set password "MyPassword123"`
- [ ] **Environment variables** - Use `$env(PASSWORD)` for automation
- [ ] **Credential files** - Store in `~/.credentials/` with 600 permissions
- [ ] **Runtime prompts** - Use `stty -echo` and `expect_user` for interactive
- [ ] **SSH keys preferred** - Key-based authentication when possible
- [ ] **Clear credentials** - `unset password` after use

### File Permissions

- [ ] **Script permissions** - `chmod 700 script.exp`
- [ ] **Credential file permissions** - `chmod 600 ~/.credentials/creds`
- [ ] **Permission validation** - Script checks file permissions before use
- [ ] **Directory permissions** - Credential directory `chmod 700`

### Logging

- [ ] **Disable for passwords** - `log_user 0` before `send "$password\r"`
- [ ] **Re-enable after** - `log_user 1` after sensitive operations
- [ ] **File logging** - Ensure log files have secure permissions (600)
- [ ] **No passwords in logs** - Review all log output

### Version Control

- [ ] **Update .gitignore** - Add `*.exp`, `.credentials/`, `*.log`
- [ ] **Pre-commit hook** - Scan for credential patterns
- [ ] **Review commits** - Never commit scripts with credentials
- [ ] **Clean history** - Use BFG if credentials were committed

---

## Error Handling

### Timeout Handling

- [ ] **Set timeout** - `set timeout 30` (adjust as needed)
- [ ] **Handle timeout** - Include `timeout { ... }` in every expect block
- [ ] **Appropriate duration** - Match timeout to operation (5s for prompts, 300s for transfers)

### EOF Handling

- [ ] **Handle eof** - Include `eof { ... }` in expect blocks
- [ ] **Proper exit** - Use `exit 1` for errors, `exit 0` for success
- [ ] **Close connections** - Call `close` and `wait` before exit

### Pattern Matching

- [ ] **Handle all cases** - Timeout, eof, success, and error patterns
- [ ] **Order patterns** - Exceptions first, likely patterns last
- [ ] **Test patterns** - Verify patterns match expected output
- [ ] **Use exp_continue** - For handling multiple prompts in sequence

---

## Pattern Matching

### Pattern Type Selection

- [ ] **Use -ex for literals** - `expect -ex "Cost: $500"` for strings with special chars
- [ ] **Use -re for regex** - `expect -re "(Password|password):.*"` for complex patterns
- [ ] **Use glob default** - `expect "Password:*"` for simple wildcards
- [ ] **Use -nocase** - `expect -nocase "password:"` for case-insensitive

### Pattern Best Practices

- [ ] **Be specific** - Avoid overly general patterns like `expect "error"`
- [ ] **Escape special chars** - Use `\\` for regex special characters
- [ ] **Test thoroughly** - Verify patterns with actual output
- [ ] **Document patterns** - Comment complex regex patterns

---

## Debugging

### Before Testing

- [ ] **Enable diagnostics** - `exp_internal 1` for debugging
- [ ] **Log output** - `log_file debug.log` for troubleshooting
- [ ] **Test with log_user** - Keep `log_user 1` during development

### During Development

- [ ] **Use autoexpect** - Record sessions with `autoexpect` for pattern discovery
- [ ] **Check spawn_id** - Verify process spawned correctly
- [ ] **Validate expect_out** - Inspect `$expect_out(buffer)` when debugging
- [ ] **Test incrementally** - Add expect/send pairs one at a time

### After Testing

- [ ] **Disable diagnostics** - Remove or comment `exp_internal 1`
- [ ] **Clean up logs** - Remove debug log files
- [ ] **Test edge cases** - Timeout, connection failure, unexpected output

---

## Code Quality

### Readability

- [ ] **Use procedures** - Create functions for repeated operations
- [ ] **Meaningful names** - Use descriptive variable and procedure names
- [ ] **Comments** - Document complex logic and patterns
- [ ] **Consistent style** - Follow Tcl/Expect conventions

### Maintainability

- [ ] **Parameterize** - Use command-line arguments for hosts, users, files
- [ ] **Validate input** - Check `$argc` and validate arguments
- [ ] **DRY principle** - Don't repeat yourself, use procedures
- [ ] **Configuration section** - Centralize timeouts and paths at top

### Robustness

- [ ] **Graceful failure** - Handle errors without crashing
- [ ] **Informative errors** - Use `puts stderr "ERROR: ..."` for error messages
- [ ] **Exit codes** - Use `exit 1` for errors, `exit 0` for success
- [ ] **Signal handling** - Use `trap` for cleanup on SIGINT/SIGTERM

---

## Common Patterns

### SSH Connection

- [ ] **Handle host key** - Expect "Are you sure" for first connection
- [ ] **Handle password prompt** - Expect "password:" (case-sensitive check)
- [ ] **Wait for prompt** - Expect "$ " or "# " after authentication
- [ ] **Exit cleanly** - Send "exit\r" and `expect eof`

### File Transfer (SCP/SFTP)

- [ ] **Long timeout** - Set `timeout 300` or higher for large files
- [ ] **Progress indicator** - Expect "100%" or similar for completion
- [ ] **Handle errors** - Check for "No such file", "Permission denied"

### Network Devices (Telnet)

- [ ] **Device-specific prompts** - Match device prompt patterns accurately
- [ ] **Configuration mode** - Handle different prompt modes (>, #, (config)#)
- [ ] **Save config** - Remember to save changes (write memory, copy running-config)
- [ ] **Exit properly** - Send "exit" at each prompt level

---

## Testing

### Unit Testing

- [ ] **Test with good input** - Verify success path works
- [ ] **Test with bad input** - Verify error handling works
- [ ] **Test timeouts** - Set short timeout and test timeout handling
- [ ] **Test connection failures** - Verify script handles unreachable hosts

### Integration Testing

- [ ] **Test in staging** - Never test first in production
- [ ] **Test with real services** - SSH to actual servers, not mocks
- [ ] **Test credential rotation** - Ensure script works after password change
- [ ] **Test concurrent execution** - Verify no race conditions

### Security Testing

- [ ] **Scan for credentials** - Use `grep` to search for hardcoded passwords
- [ ] **Review logs** - Ensure passwords don't appear in any logs
- [ ] **Test permissions** - Verify file permissions are enforced
- [ ] **Code review** - Have another person review for security issues

---

## Documentation

### Script Documentation

- [ ] **Usage examples** - Show how to run the script
- [ ] **Prerequisites** - List required software, credentials, access
- [ ] **Parameters** - Document command-line arguments
- [ ] **Environment variables** - List required env vars

### External Documentation

- [ ] **README** - Create README.md for script collections
- [ ] **Architecture diagram** - Document system connections
- [ ] **Runbook** - Document operational procedures
- [ ] **Troubleshooting guide** - Common errors and solutions

---

## Deployment

### Pre-Deployment

- [ ] **Code review** - Peer review for security and quality
- [ ] **Security scan** - Run automated security scanning tools
- [ ] **Permission audit** - Verify all file permissions are secure
- [ ] **Backup** - Backup existing scripts before replacing

### Deployment

- [ ] **Deploy to staging** - Test in staging environment first
- [ ] **Validate** - Run smoke tests after deployment
- [ ] **Monitor** - Watch logs for errors during initial runs
- [ ] **Document** - Update runbooks and documentation

### Post-Deployment

- [ ] **Monitoring** - Set up alerting for script failures
- [ ] **Audit logging** - Review audit logs for anomalies
- [ ] **Credential rotation** - Schedule regular password changes
- [ ] **Access review** - Quarterly review of who has access

---

## Maintenance

### Regular Reviews

- [ ] **Security audit** - Quarterly security review
- [ ] **Permission check** - Verify file permissions quarterly
- [ ] **Log review** - Monthly review of audit logs
- [ ] **Access review** - Quarterly review of user access

### Updates

- [ ] **Expect updates** - Keep Expect updated to latest stable version
- [ ] **Credential rotation** - Rotate credentials on schedule (e.g., every 90 days)
- [ ] **Pattern updates** - Update patterns if target application UI changes
- [ ] **Timeout adjustments** - Adjust timeouts based on actual performance

### Incident Response

- [ ] **Breach plan** - Document steps if credentials are compromised
- [ ] **Rollback plan** - Document how to revert to previous version
- [ ] **Contact list** - Maintain list of people to notify for issues
- [ ] **Post-mortem** - Document lessons learned after incidents

---

## Quick Command Reference

### Essential Commands

```tcl
spawn <command>              # Start process
send "<string>\r"            # Send string with Enter
expect "<pattern>"           # Wait for pattern
interact                     # Hand control to user
close                        # Close connection
wait                         # Wait for process to finish
exit <code>                  # Exit with code (0=success, 1=error)
```

### Pattern Types

```tcl
expect "pattern"             # Glob pattern (default)
expect -ex "exact string"    # Exact match
expect -re "regex"           # Regular expression
expect -nocase "pattern"     # Case-insensitive
```

### Special Variables

```tcl
$expect_out(buffer)          # All output since last expect
$expect_out(0,string)        # Matched text
$spawn_id                    # Current process ID
$timeout                     # Timeout value in seconds
$argv                        # Command-line arguments
$argc                        # Argument count
$env(VAR)                    # Environment variable
```

### Debugging

```tcl
exp_internal 1               # Enable diagnostics
log_user 0                   # Disable output logging
log_file "debug.log"         # Log to file
puts "debug message"         # Print debug message
```

---

## Common Mistakes to Avoid

- [ ] ❌ Hardcoding passwords
- [ ] ❌ Forgetting `\r` after send commands
- [ ] ❌ Not handling timeout and eof
- [ ] ❌ Using world-readable file permissions
- [ ] ❌ Logging passwords to stdout or files
- [ ] ❌ Committing scripts with credentials to git
- [ ] ❌ Not validating command-line arguments
- [ ] ❌ Using overly general expect patterns
- [ ] ❌ Not testing timeout scenarios
- [ ] ❌ Forgetting to close and wait at script end

---

## Additional Resources

- [Expect Best Practices Guide](./Expect_Best_Practices_Guide.md)
- [Expect Security Standards Reference](./Expect_Security_Standards_Reference.md)
- [Official Expect Documentation](https://core.tcl-lang.org/expect/index)
- [Expect Man Page](https://www.man7.org/linux/man-pages/man1/expect.1.html)

---

**Last Updated**: 2025-12-11
