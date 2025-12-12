# Shell Script Quality Checklist

> **Purpose**: Comprehensive validation checklist for production-ready shell scripts.
> **Usage**: Review this checklist before deploying any shell script to production.

---

## 1. Script Header and Configuration

### Shebang and Error Handling
- [ ] Script starts with correct shebang: `#!/bin/bash`
- [ ] Uses `set -euo pipefail` for strict error handling
- [ ] Locale variables set if needed: `export LANG=C.UTF-8`
- [ ] Working directory set explicitly if required

### Script Documentation
- [ ] Script has header comment with name and purpose
- [ ] Usage instructions provided (usage function or comments)
- [ ] Required dependencies documented
- [ ] Prerequisites clearly stated (OS, commands, permissions)
- [ ] Examples of valid invocations provided

---

## 2. Variable Declarations

### Variable Naming and Scope
- [ ] Variables have clear, descriptive names
- [ ] UPPERCASE used for constants and environment variables
- [ ] lowercase used for local/temporary variables
- [ ] `readonly` used for constants that shouldn't change
- [ ] `local` used for all function variables
- [ ] No single-letter variables (except loop counters)

### Variable Expansion
- [ ] All variables quoted in expansions: `"$var"` not `$var`
- [ ] Arrays used instead of space-separated strings for lists
- [ ] Parameter expansion with defaults used where appropriate: `"${VAR:-default}"`
- [ ] Required variables checked at start: `"${VAR:?Error message}"`

### Configuration Variables
- [ ] All hardcoded paths assigned to variables
- [ ] Configuration consolidated at top of script
- [ ] Sensitive data loaded from environment or secure files
- [ ] No hardcoded credentials (passwords, API keys, tokens)

---

## 3. Functions

### Function Structure
- [ ] Functions follow single responsibility principle
- [ ] Function names are descriptive (verb-noun format)
- [ ] Functions use `local` for all internal variables
- [ ] Functions return meaningful exit codes (0 = success, non-zero = failure)
- [ ] Complex functions have documentation comments

### Function Documentation
- [ ] Function purpose clearly documented
- [ ] Required arguments documented
- [ ] Optional arguments documented with defaults
- [ ] Return values documented
- [ ] Side effects documented (file creation, state changes)

### Function Validation
- [ ] Functions validate required arguments
- [ ] Functions check prerequisites before executing
- [ ] Functions handle errors gracefully
- [ ] Functions provide clear error messages

---

## 4. Error Handling

### Basic Error Handling
- [ ] Script uses `set -e` to exit on errors
- [ ] Script uses `set -u` to catch undefined variables
- [ ] Script uses `set -o pipefail` to catch pipeline failures
- [ ] Critical operations explicitly check exit codes
- [ ] Errors logged with context (timestamp, line number, function)

### Error Functions
- [ ] Centralized `error()` function exists
- [ ] Error function logs to stderr (>&2)
- [ ] Error function includes cleanup before exit
- [ ] Error function accepts exit code parameter
- [ ] Meaningful exit codes used (not just 0 or 1)

### Cleanup and Recovery
- [ ] `trap` handler registered for cleanup (EXIT, INT, TERM)
- [ ] Cleanup function removes temporary files
- [ ] Cleanup function kills background processes
- [ ] Cleanup function releases locks
- [ ] Cleanup function restores original state if needed

---

## 5. Security

### Credential Management
- [ ] No hardcoded passwords in script
- [ ] No hardcoded API keys or tokens
- [ ] Credentials loaded from environment variables
- [ ] Credential files have secure permissions (400 or 600)
- [ ] Credential file permissions verified before loading
- [ ] Credentials never logged or printed

### Input Validation
- [ ] All user inputs validated before use
- [ ] File paths validated against directory traversal
- [ ] Numeric inputs validated as numbers
- [ ] Input validation uses allowlists, not denylists
- [ ] Command injection prevented (no `eval` with user input)
- [ ] SQL injection prevented (use parameterized queries)

### Command Execution Security
- [ ] No use of `eval` with untrusted input
- [ ] No use of unquoted variables in commands
- [ ] Shell metacharacters properly escaped
- [ ] `--` used to terminate option parsing where applicable
- [ ] Full paths used for critical commands (avoid PATH attacks)

### File Operation Security
- [ ] Temporary files created with `mktemp`
- [ ] Temporary files have restrictive permissions (600)
- [ ] No predictable temporary filenames used
- [ ] Symbolic link attacks prevented
- [ ] Race conditions (TOCTOU) avoided
- [ ] File permissions set explicitly after creation

---

## 6. Privilege Management

### Privilege Checking
- [ ] Script checks if root privileges required
- [ ] Script checks if it's NOT running as root when inappropriate
- [ ] Privilege escalation only used when necessary
- [ ] `sudo` usage clearly documented
- [ ] Privilege checks happen before destructive operations

### Sudo Usage
- [ ] Sudo not used redundantly (when already root)
- [ ] Sudo access validated before attempting operations
- [ ] Sudoers configuration documented in comments
- [ ] Script doesn't assume passwordless sudo
- [ ] Sudo timeout considerations handled

### User and Group Management
- [ ] User existence checked before operations
- [ ] Group existence checked before operations
- [ ] User creation is idempotent
- [ ] System users created with `--system` flag
- [ ] Service users have `--shell /bin/false`

---

## 7. File Operations

### File Existence Checks
- [ ] Files checked for existence before reading
- [ ] Directories checked for existence before use
- [ ] File readability checked before reading
- [ ] File writability checked before writing
- [ ] Parent directories exist before creating files

### Idempotent Operations
- [ ] Operations check current state before acting
- [ ] Files only copied if source and dest differ (`cmp -s`)
- [ ] Directories created only if they don't exist
- [ ] Services started only if not already active
- [ ] No duplicate configuration entries added

### File Permissions
- [ ] All created files have permissions set explicitly
- [ ] Configuration files: 640 or 644
- [ ] Credential files: 400 or 600
- [ ] Executable scripts: 750 or 755
- [ ] Log files: 640 or 644
- [ ] Ownership set explicitly with `chown`

### Critical File Validation
- [ ] Sudoers files validated with `visudo -c` before installing
- [ ] Systemd unit files validated before installing
- [ ] JSON/YAML configs validated with parsers (jq, yq)
- [ ] Syntax validation happens before file replacement

---

## 8. Systemd Integration

### Service File Management
- [ ] Service files copied to correct location (/etc/systemd/system/)
- [ ] Service file permissions set to 644
- [ ] `systemctl daemon-reload` called after changes
- [ ] Service file syntax validated before deployment
- [ ] Service dependencies properly configured

### Service State Management
- [ ] Service status checked with `systemctl is-active` before starting
- [ ] Service enabled status checked with `systemctl is-enabled` before enabling
- [ ] Service health verified after starting
- [ ] Service logs checked for errors after starting
- [ ] Retry logic implemented for transient failures

### Service Operations
- [ ] Services started only if not already active
- [ ] Services enabled for boot if appropriate
- [ ] Service restart used instead of stop/start
- [ ] Service reload used for config changes when supported
- [ ] Service status displayed after operations

---

## 9. Logging and Output

### Log Configuration
- [ ] Log file location defined as variable
- [ ] Log directory created if it doesn't exist
- [ ] Log file permissions set securely (640)
- [ ] Log rotation configured or implemented
- [ ] Old logs cleaned up to prevent disk fill

### Log Format
- [ ] All log messages have timestamps
- [ ] Log messages include log level (INFO, WARN, ERROR)
- [ ] Log messages include context (function, line number)
- [ ] Multiline output handled correctly in logs
- [ ] Log entries are parseable (structured format)

### Log Content Security
- [ ] Sensitive data redacted from logs (passwords, tokens)
- [ ] Log injection prevented (newlines removed from user input)
- [ ] Error messages include actionable information
- [ ] Success messages confirm what was done
- [ ] Progress indicators provided for long operations

### Debug Support
- [ ] DEBUG variable/flag supported
- [ ] Debug function only outputs when DEBUG=true
- [ ] Debug output goes to stderr
- [ ] Verbose mode available for troubleshooting
- [ ] Dry-run mode available for testing

---

## 10. System Integration

### Command Availability
- [ ] Required commands checked at start: `command -v cmd`
- [ ] Missing commands result in clear error message
- [ ] Alternative commands handled gracefully
- [ ] PATH set explicitly if needed
- [ ] Commands run with full paths for security

### Environment Variables
- [ ] Required environment variables documented
- [ ] Environment variables checked for presence
- [ ] Environment variables have sensible defaults
- [ ] .env file support implemented if appropriate
- [ ] Environment variable expansion secure (no injection)

### Signal Handling
- [ ] SIGINT (Ctrl+C) handled gracefully
- [ ] SIGTERM handled for clean shutdown
- [ ] SIGHUP handled if running as daemon
- [ ] Background processes cleaned up on signals
- [ ] Locks released on signals

---

## 11. Automation and Concurrency

### Lock File Management
- [ ] Lock file used to prevent concurrent execution
- [ ] Lock file location documented
- [ ] Lock file properly acquired (atomic operation)
- [ ] Lock file contains PID for debugging
- [ ] Lock file released on exit (via trap)
- [ ] Stale lock files detected and handled

### Idempotency
- [ ] Script safe to run multiple times
- [ ] Script checks state before making changes
- [ ] Script doesn't create duplicates (users, files, config entries)
- [ ] Script resumes if interrupted (state persistence)
- [ ] Script reports what changed vs what was already correct

### Cron/Timer Compatibility
- [ ] Script works with minimal environment (cron)
- [ ] PATH set explicitly for cron execution
- [ ] HOME and USER set if needed
- [ ] Output redirected appropriately (not emailed by cron)
- [ ] Working directory set explicitly

---

## 12. Testing and Validation

### Syntax Validation
- [ ] Script validated with `bash -n script.sh`
- [ ] Script validated with `shellcheck` if available
- [ ] No syntax warnings or errors
- [ ] All functions can be parsed
- [ ] All variables properly defined

### Functionality Testing
- [ ] Script tested in clean environment
- [ ] Script tested with minimal permissions
- [ ] Script tested with various inputs (valid, invalid, edge cases)
- [ ] Error cases tested (missing files, wrong permissions)
- [ ] Idempotency tested (run twice, same result)

### Integration Testing
- [ ] Script tested with actual services/commands
- [ ] Script tested in target environment (OS, version)
- [ ] Script tested with production-like data
- [ ] Script tested with concurrent execution (if applicable)
- [ ] Rollback/cleanup tested

---

## 13. Production Readiness

### Performance
- [ ] No unnecessary subshells
- [ ] Efficient algorithms used for large datasets
- [ ] Long operations show progress
- [ ] Timeouts configured for network operations
- [ ] Resource usage reasonable (CPU, memory, disk)

### Maintainability
- [ ] Code is readable and well-formatted
- [ ] Functions are small and focused
- [ ] No code duplication (DRY principle followed)
- [ ] Magic numbers replaced with named constants
- [ ] Complex logic explained with comments

### Monitoring and Alerting
- [ ] Critical failures trigger alerts
- [ ] Success/failure status clearly indicated
- [ ] Metrics logged for monitoring (duration, items processed)
- [ ] Health checks available for automated monitoring
- [ ] Notifications sent to appropriate channels (email, Slack, PagerDuty)

### Documentation
- [ ] README exists explaining what script does
- [ ] Installation instructions provided
- [ ] Configuration instructions provided
- [ ] Troubleshooting guide available
- [ ] Examples of common use cases provided

---

## 14. Code Quality

### Shell Best Practices
- [ ] No useless use of cat: `cat file | grep` → `grep file`
- [ ] No useless use of echo: `echo $(cmd)` → `cmd`
- [ ] Arrays used for lists: `arr=("a" "b")` not `arr="a b"`
- [ ] `[[` used instead of `[` for tests
- [ ] `$(command)` used instead of backticks
- [ ] `readonly` used for constants

### Portability
- [ ] Bash-specific features explicitly required (shebang = bash)
- [ ] OS-specific commands documented
- [ ] Alternative commands for different OSes if needed
- [ ] No bashisms if claiming POSIX sh compatibility
- [ ] Character encoding handled correctly (UTF-8)

### Error Messages
- [ ] Errors go to stderr (>&2)
- [ ] Error messages are actionable
- [ ] Error messages include context
- [ ] Error messages suggest fixes
- [ ] Error messages reference documentation

---

## 15. Final Validation

### Pre-Deployment Checks
- [ ] Script reviewed by another developer
- [ ] All checklist items above completed
- [ ] Script tested in staging environment
- [ ] Rollback plan documented
- [ ] Monitoring configured for script execution

### Security Review
- [ ] No hardcoded credentials
- [ ] Input validation comprehensive
- [ ] File permissions secure
- [ ] Privilege escalation justified and documented
- [ ] Security team approval obtained (if required)

### Compliance
- [ ] Script follows organization coding standards
- [ ] Script follows naming conventions
- [ ] Licensing information included if required
- [ ] Copyright notices included if required
- [ ] Change log maintained

---

## Quick Validation Commands

### Syntax Check
```bash
bash -n script.sh
```

### Shellcheck
```bash
shellcheck script.sh
```

### Dry Run
```bash
DRY_RUN=true ./script.sh
```

### Debug Mode
```bash
DEBUG=true ./script.sh
# or
bash -x script.sh
```

### Test in Isolated Environment
```bash
docker run --rm -v $(pwd):/app -w /app ubuntu:22.04 bash -c "
    apt-get update && apt-get install -y bash shellcheck
    bash -n /app/script.sh
    shellcheck /app/script.sh
"
```

---

## Severity Levels

**CRITICAL** (❌ Must Fix Before Deployment):
- Hardcoded credentials
- Command injection vulnerabilities
- Missing error handling (`set -e`)
- Insecure file permissions on credentials
- Missing input validation on dangerous operations

**HIGH** (⚠️ Fix Soon):
- No logging for critical operations
- No cleanup trap handler
- Missing privilege checks
- Unquoted variable expansions
- No lock file for concurrent prevention

**MEDIUM** (💡 Should Fix):
- Poor error messages
- No debug mode
- Code duplication
- Missing function documentation
- No idempotency checks

**LOW** (✓ Nice to Have):
- Shellcheck warnings
- Suboptimal performance
- Missing progress indicators
- No dry-run mode
- Minor code style issues

---

## Example Validation Workflow

1. **Syntax Validation**
   ```bash
   bash -n script.sh && echo "✓ Syntax OK"
   ```

2. **Static Analysis**
   ```bash
   shellcheck script.sh
   ```

3. **Security Scan**
   ```bash
   grep -n "password\|api_key\|token" script.sh  # Check for hardcoded secrets
   grep -n "eval\|exec" script.sh  # Check for dangerous commands
   ```

4. **Test Run**
   ```bash
   DRY_RUN=true DEBUG=true ./script.sh
   ```

5. **Integration Test**
   ```bash
   ./script.sh && ./script.sh  # Test idempotency
   ```

6. **Peer Review**
   - Submit for code review
   - Address all feedback
   - Get approval

7. **Staging Deployment**
   - Deploy to staging
   - Monitor execution
   - Verify results

8. **Production Deployment**
   - Deploy to production
   - Monitor closely
   - Have rollback ready

---

**Last Updated**: 2025-12-12
