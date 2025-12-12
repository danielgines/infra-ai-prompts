# Just Script Checklist

> **Purpose**: Quick validation checklist for just script quality, security, and best practices.

## Documentation

- [ ] Module-level comment explaining justfile purpose
- [ ] All public recipes have descriptive comments
- [ ] Comment describes what recipe does, not how
- [ ] Recipe parameters documented with types and defaults
- [ ] Dependencies between recipes explained
- [ ] Variable purposes documented
- [ ] Complex logic has inline comments
- [ ] Examples provided for non-obvious recipes
- [ ] Security warnings for destructive operations
- [ ] Links to external documentation when needed

## Configuration

- [ ] Shell set explicitly: `set shell := ["bash", "-c"]`
- [ ] Dotenv loading configured: `set dotenv-load := true`
- [ ] Working directory set if needed: `set working-directory := "path"`
- [ ] Positional arguments configured: `set positional-arguments := true`
- [ ] Export settings documented
- [ ] All `set` directives at top of file
- [ ] No conflicting settings
- [ ] Shell choice justified (bash vs sh vs zsh)

## Variables

- [ ] All variables use lowercase_with_underscores
- [ ] Variables use `env_var_or_default()` for environment variables
- [ ] Default values are sensible
- [ ] No hardcoded credentials (API keys, passwords)
- [ ] No hardcoded absolute paths
- [ ] Variables exported when needed by child processes
- [ ] Boolean variables use "true"/"false" strings
- [ ] Variable names are descriptive
- [ ] Related variables grouped together
- [ ] Variables documented with comments

## Recipe Structure

- [ ] Recipe names use lowercase-with-dashes
- [ ] Recipe names are clear verbs (build, test, deploy)
- [ ] Default recipe shows help: `default: (@just --list)`
- [ ] Helper recipes prefixed with underscore: `_helper`
- [ ] Each recipe has single responsibility
- [ ] Long recipes broken into smaller steps
- [ ] Recipe dependencies clearly specified
- [ ] Parameters have sensible defaults
- [ ] Optional parameters marked with `=''` or `='default'`
- [ ] Variadic parameters use `*args`

## Error Handling

- [ ] Multi-line recipes use `#!/usr/bin/env bash`
- [ ] All multi-line recipes use `set -euo pipefail`
- [ ] Commands checked for existence before use
- [ ] File existence validated before operations
- [ ] Network operations have timeout
- [ ] Exit codes checked explicitly when needed
- [ ] Error messages are clear and actionable
- [ ] Errors output to stderr (>&2)
- [ ] Cleanup happens on error (trap handlers)
- [ ] No bare `||` without understanding behavior

## Dependencies

- [ ] Recipe dependencies specified: `recipe: dep1 dep2`
- [ ] Dependency order is correct
- [ ] No circular dependencies
- [ ] Dependencies don't duplicate work
- [ ] Helper recipe dependencies use `(_helper)`
- [ ] Optional dependencies handled gracefully
- [ ] External command dependencies documented
- [ ] Version requirements documented
- [ ] Cross-platform dependencies considered

## Security

- [ ] No hardcoded credentials anywhere
- [ ] Secrets loaded from environment variables
- [ ] Credential files have 600 permissions
- [ ] Script files have 700 permissions
- [ ] User input validated before use
- [ ] No command injection vulnerabilities
- [ ] No SQL injection in database recipes
- [ ] No path traversal vulnerabilities
- [ ] Destructive operations require confirmation
- [ ] Destructive operations have dry-run mode
- [ ] Sensitive output not logged or printed
- [ ] TLS/SSL verification enabled
- [ ] No `eval` or `exec` with user input
- [ ] File operations use safe paths
- [ ] Network operations validate URLs
- [ ] Sudo used only when necessary
- [ ] Sudo operations documented and justified
- [ ] Audit logging for sensitive operations

## File Operations

- [ ] File existence checked before reading
- [ ] Directory existence checked before writing
- [ ] File permissions set explicitly
- [ ] Temporary files use `mktemp`
- [ ] Temporary files cleaned up
- [ ] File paths use variables, not hardcoded
- [ ] Backups created before destructive operations
- [ ] File operations are idempotent when possible
- [ ] Symlinks handled correctly
- [ ] File ownership set when needed
- [ ] Large files processed in chunks

## Database Operations

- [ ] Database URL from environment variable
- [ ] Connection string doesn't contain password
- [ ] Database existence checked before operations
- [ ] Migrations run before seeds
- [ ] Backups created before destructive operations
- [ ] Transaction support for multi-step operations
- [ ] Database version documented
- [ ] Connection pool settings configured
- [ ] Query timeout configured
- [ ] No raw SQL with string interpolation

## Docker Operations

- [ ] Docker daemon checked before operations
- [ ] Image tags specified explicitly (not `latest`)
- [ ] Build context minimized
- [ ] Multi-stage builds used when appropriate
- [ ] Container names don't conflict
- [ ] Ports don't conflict with host
- [ ] Volumes mounted with correct permissions
- [ ] Container logs accessible
- [ ] Container cleanup implemented
- [ ] Network isolation configured

## Testing

- [ ] Test recipes exist (unit, integration, e2e)
- [ ] Tests can run independently
- [ ] Test data setup/teardown automated
- [ ] Test environment isolated from production
- [ ] Coverage reporting configured
- [ ] Test output clear and actionable
- [ ] Failed tests return non-zero exit code
- [ ] Flaky tests identified and fixed
- [ ] Performance tests included
- [ ] Security tests included

## CI/CD Integration

- [ ] Recipes work in CI environment
- [ ] CI-specific recipes created (test-ci, build-ci)
- [ ] Secrets passed via environment variables
- [ ] Artifacts generated in standard locations
- [ ] Build metadata generated
- [ ] Deployment gates implemented
- [ ] Rollback procedures documented
- [ ] Notifications configured (Slack, email)
- [ ] Job timeouts configured
- [ ] Retry logic for flaky operations

## Logging

- [ ] All operations log start/end
- [ ] Timestamps in ISO 8601 format
- [ ] Log levels used appropriately (info, warn, error)
- [ ] Sensitive data not logged
- [ ] Logs rotated to prevent disk fill
- [ ] Log location configurable
- [ ] Structured logging for parsing
- [ ] Colors used for terminal output
- [ ] Progress indicators for long operations
- [ ] Verbose mode available

## Performance

- [ ] Long operations show progress
- [ ] Expensive operations cached when possible
- [ ] Parallel operations use `&` and `wait`
- [ ] Database queries optimized
- [ ] Large files processed in streams
- [ ] Unnecessary file operations avoided
- [ ] Network calls minimized
- [ ] Build artifacts cached
- [ ] Dependencies installed incrementally

## Portability

- [ ] Works on Linux
- [ ] Works on macOS (if required)
- [ ] Works in Docker containers
- [ ] Works in CI/CD runners
- [ ] Shell features are portable (bash vs sh)
- [ ] Commands available on all platforms
- [ ] File paths work cross-platform
- [ ] Line endings handled correctly
- [ ] Locale/encoding issues addressed

## Common Mistakes

- [ ] No mutable operations without confirmation
- [ ] No `rm -rf` without validation
- [ ] No `chmod 777` (use minimum permissions)
- [ ] No `curl | sh` (validate before execute)
- [ ] No `sleep` in loops (use proper polling)
- [ ] No `kill -9` as first resort
- [ ] No mixing tabs and spaces
- [ ] No trailing whitespace
- [ ] No unused variables
- [ ] No unused recipes

## Recipe-Specific Checks

### Development Recipes

- [ ] `dev`: Starts development server
- [ ] `dev`: Hot reload enabled
- [ ] `dev`: Environment properly configured
- [ ] `install`: Installs all dependencies
- [ ] `install`: Uses lock file when available
- [ ] `clean`: Removes build artifacts
- [ ] `clean`: Doesn't remove source files
- [ ] `reset`: Provides fresh start

### Testing Recipes

- [ ] `test`: Runs all tests
- [ ] `test`: Returns non-zero on failure
- [ ] `test-unit`: Runs unit tests only
- [ ] `test-integration`: Runs integration tests
- [ ] `test-e2e`: Runs end-to-end tests
- [ ] `test-watch`: Watches for changes
- [ ] `test-coverage`: Generates coverage report
- [ ] `test-coverage`: Fails if coverage too low

### Build Recipes

- [ ] `build`: Produces production-ready artifacts
- [ ] `build`: Minification enabled for production
- [ ] `build`: Source maps generated
- [ ] `build`: Build metadata included
- [ ] `build`: Output directory cleaned first
- [ ] `build`: Deterministic builds
- [ ] `build`: Build artifacts validated

### Deployment Recipes

- [ ] `deploy`: Runs tests before deploying
- [ ] `deploy`: Builds before deploying
- [ ] `deploy`: Validates environment
- [ ] `deploy`: Checks prerequisites
- [ ] `deploy`: Creates backup
- [ ] `deploy`: Has rollback procedure
- [ ] `deploy`: Notifications sent
- [ ] `deploy`: Logs audit trail

### Database Recipes

- [ ] `db-create`: Creates database
- [ ] `db-drop`: Requires confirmation
- [ ] `db-migrate`: Runs migrations
- [ ] `db-migrate`: Idempotent
- [ ] `db-rollback`: Rolls back migration
- [ ] `db-seed`: Seeds database
- [ ] `db-seed`: Idempotent
- [ ] `db-reset`: Backs up first
- [ ] `db-backup`: Creates timestamped backup
- [ ] `db-restore`: Validates backup file

### Helper Recipes

- [ ] `_require cmd`: Checks command exists
- [ ] `_require-env var`: Checks env var set
- [ ] `_check-permissions file perm`: Validates permissions
- [ ] `_log message`: Logs with timestamp
- [ ] Helper recipes not shown in `just --list`
- [ ] Helper recipes reusable
- [ ] Helper recipes well-tested

## Pre-Deployment Validation

- [ ] `just --check` passes (syntax valid)
- [ ] `just --summary` shows all recipes
- [ ] `just --list` output is clear
- [ ] All recipes tested in clean environment
- [ ] All dependencies documented
- [ ] README explains common workflows
- [ ] `.env.example` provided
- [ ] `.gitignore` includes generated files
- [ ] Security review completed
- [ ] Performance acceptable
- [ ] Error handling tested
- [ ] Rollback procedures tested
- [ ] Documentation up to date
- [ ] Version tagged in git

## Code Review

- [ ] Naming conventions followed
- [ ] Comments are clear and necessary
- [ ] No commented-out code
- [ ] No debugging code (console.log, etc.)
- [ ] No TODO comments without tickets
- [ ] Consistent indentation (2 or 4 spaces)
- [ ] Line length reasonable (<120 chars)
- [ ] Recipe order logical
- [ ] Related recipes grouped
- [ ] File structure matches conventions

## Accessibility

- [ ] Color output can be disabled
- [ ] Plain text alternatives available
- [ ] Screen reader friendly
- [ ] Keyboard-only workflow possible
- [ ] Clear error messages
- [ ] Help available via `--help`

## Maintenance

- [ ] Just version documented
- [ ] Dependencies version pinned
- [ ] Deprecation warnings added
- [ ] Migration path documented
- [ ] Changelog maintained
- [ ] Breaking changes highlighted
- [ ] Legacy recipes marked for removal

## Final Validation

- [ ] Run `just --check` to validate syntax
- [ ] Run `just --evaluate` to check variables
- [ ] Run `just --dry-run recipe` for each recipe
- [ ] Test in fresh environment
- [ ] Test with minimum dependencies
- [ ] Test on target platforms
- [ ] Security scan completed
- [ ] Performance benchmarks met
- [ ] Documentation reviewed
- [ ] Ready for production

---

## Quick Command Reference

```bash
# Validate syntax
just --check

# List all recipes
just --list

# Show recipe definition
just --show recipe-name

# Evaluate variables
just --evaluate variable-name

# Dry run (show commands without executing)
just --dry-run recipe-name

# Verbose output
just --verbose recipe-name

# Check if recipe exists
just --summary | grep recipe-name
```

---

**Last Updated**: 2025-12-11
