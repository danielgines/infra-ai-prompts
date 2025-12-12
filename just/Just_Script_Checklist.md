# Just Script Checklist

> **Purpose**: Quick reference checklist for writing maintainable, secure, and production-ready justfiles.

---

## Before Writing

- [ ] **Verify necessity** - Is `just` the right tool? Consider Makefiles, shell scripts, or task runners
- [ ] **Plan scope** - What tasks will be automated (build, test, deploy, database operations)?
- [ ] **Define dependencies** - External commands (docker, git, node, python, etc.)
- [ ] **Identify secrets** - Will need environment variables for credentials?
- [ ] **Review security requirements** - Production deployment, credential management, audit logging

---

## Script Structure

- [ ] **Settings block** - All `set` directives at top of file
- [ ] **Variables section** - Global variables after settings
- [ ] **Helper recipes** - Private recipes (prefixed with `_`) before public
- [ ] **Public recipes** - Main recipes users will call
- [ ] **Recipe grouping** - Related recipes together (all test recipes, all deploy recipes)
- [ ] **Default recipe** - First recipe shows help or most common action

---

## Configuration Settings

- [ ] **Shell set explicitly** - `set shell := ["bash", "-c"]` (recommended)
- [ ] **Error handling enabled** - Use bash with `-euo pipefail` for robust scripts
- [ ] **Dotenv loading** - `set dotenv-load := true` for environment variables
- [ ] **Working directory** - `set working-directory := "path"` if needed
- [ ] **Positional arguments** - `set positional-arguments := true` if using `$1`, `$2`
- [ ] **All settings at top** - No `set` directives scattered throughout file
- [ ] **Settings documented** - Comments explain why each setting is needed

---

## Variables

- [ ] **Lowercase with underscores** - `my_variable := "value"`
- [ ] **Descriptive names** - `database_url` not `db_url` or `url`
- [ ] **Environment variables** - Use `env_var_or_default("VAR", "default")`
- [ ] **Sensible defaults** - Default values work for development
- [ ] **No hardcoded credentials** - Never `password := "secret123"`
- [ ] **No API keys** - Always from environment: `api_key := env_var("API_KEY")`
- [ ] **No tokens** - Use environment variables or credential files
- [ ] **Grouped by purpose** - Database vars, Docker vars, build vars
- [ ] **Documented with comments** - Explain purpose and expected values

---

## Recipe Structure

- [ ] **Lowercase with dashes** - `build-docker` not `buildDocker` or `build_docker`
- [ ] **Clear verbs** - `build`, `test`, `deploy`, `clean`, `install`
- [ ] **Descriptive names** - `test-integration` not just `test-int`
- [ ] **Consistent prefixes** - All test recipes start with `test-`, all Docker recipes with `docker-`
- [ ] **Helper recipes** - Prefix with underscore: `_require-command`, `_check-env`
- [ ] **Default recipe** - Shows help or runs most common task: `default: (@just --list)`
- [ ] **Single responsibility** - Each recipe does one thing well
- [ ] **Parameters documented** - Comment shows parameter purpose and type
- [ ] **Sensible defaults** - Optional parameters: `deploy env='staging'`
- [ ] **Parameter validation** - Check parameter values at start of recipe
- [ ] **Dependencies specified** - `deploy: build test`
- [ ] **No circular dependencies** - Recipe A depends on B, B doesn't depend on A

---

## Error Handling

- [ ] **Shebang line** - Multi-line recipes use `#!/usr/bin/env bash`
- [ ] **Error handling flags** - Use `set -euo pipefail` in all bash recipes
- [ ] **Command existence** - Check with `command -v cmd` or `which cmd`
- [ ] **File existence** - Use `[ -f file ]` before reading files
- [ ] **Directory existence** - Use `[ -d dir ]` before operations
- [ ] **Clear messages** - Error messages explain what went wrong
- [ ] **Actionable guidance** - Tell user how to fix the problem
- [ ] **Output to stderr** - Use `echo "Error" >&2` or `printf "Error\n" >&2`
- [ ] **Exit codes** - Use `exit 1` for errors, `exit 0` for success
- [ ] **Trap handlers** - Use `trap 'cleanup' EXIT INT TERM` for cleanup
- [ ] **Temporary files** - Clean up temp files on error

---

## Security

### Credential Management

- [ ] **No hardcoded credentials** - Never passwords, API keys, or tokens in justfile
- [ ] **Environment variables** - Use `env_var("SECRET")` for credentials
- [ ] **Dotenv file** - Use `.env` file with `set dotenv-load := true`
- [ ] **Gitignore** - Add `.env` to `.gitignore`
- [ ] **Example file** - Provide `.env.example` with dummy values
- [ ] **No credential output** - Never echo or log credentials

### Input Validation & Injection Prevention

- [ ] **User input validated** - Check parameters before use
- [ ] **Whitelist approach** - Accept only known-good values
- [ ] **No command injection** - Quote all variables: `"$var"` not `$var`
- [ ] **No SQL injection** - Use parameterized queries, not string concatenation
- [ ] **No path traversal** - Validate paths don't contain `..`
- [ ] **Safe substitution** - Use `{{ var }}` in recipes, properly quoted in bash

### File Permissions & Destructive Operations

- [ ] **File permissions** - Justfile should be 644 (readable)
- [ ] **Script permissions** - Generated scripts should be 700
- [ ] **Credential files** - Must be 600 (owner read/write only)
- [ ] **Confirmation required** - Prompt user for destructive operations
- [ ] **Dry-run mode** - Provide `--dry-run` flag for testing
- [ ] **Backup first** - Create backups before destructive operations
- [ ] **Production guards** - Extra confirmation for production operations

### Sudo Usage

- [ ] **Sudo only when needed** - Avoid sudo unless absolutely required
- [ ] **Minimal sudo** - Sudo for specific commands, not entire recipe
- [ ] **Documented sudo** - Comment why sudo is necessary
- [ ] **Audit logging** - Log all privileged operations

---

## Code Quality

- [ ] **Module-level comment** - Header explaining justfile purpose
- [ ] **Recipe comments** - Every public recipe has descriptive comment
- [ ] **What not how** - Comment describes purpose, not implementation
- [ ] **Parameter documentation** - Document parameter types and defaults
- [ ] **Variable documentation** - Explain variable purposes and expected values
- [ ] **Consistent indentation** - Use 2 or 4 spaces consistently
- [ ] **Line length** - Keep lines under 120 characters
- [ ] **No trailing whitespace** - Clean up whitespace
- [ ] **DRY principle** - Don't repeat yourself, use helper recipes
- [ ] **Single responsibility** - Each recipe does one thing
- [ ] **Configuration at top** - All settings and variables at top
- [ ] **Safe to rerun** - Running recipe twice produces same result (idempotency)
- [ ] **Existence checks** - Check if action already done before doing

---

## File Operations

- [ ] **Existence checks** - Verify files exist before reading
- [ ] **Directory checks** - Create directories if needed
- [ ] **Permissions** - Set explicit permissions (644 for files, 755 for dirs)
- [ ] **Temporary files** - Use `mktemp` for temp file creation
- [ ] **Temp cleanup** - Always clean up temporary files
- [ ] **Backups** - Create backups before destructive operations
- [ ] **Atomic operations** - Write to temp then move for atomic updates

---

## Database Operations

- [ ] **URL from environment** - Use `DATABASE_URL` environment variable
- [ ] **No password in string** - Separate credentials from connection string
- [ ] **Database existence** - Check database exists before operations
- [ ] **Backups** - Create backups before destructive operations
- [ ] **No string interpolation** - Use parameterized queries only
- [ ] **Idempotent migrations** - Migrations safe to rerun
- [ ] **Rollback support** - Provide rollback recipes

---

## Docker Operations

- [ ] **Daemon check** - Verify Docker daemon running before operations
- [ ] **Explicit tags** - Never use `latest`, specify exact versions
- [ ] **Build context** - Minimize context with `.dockerignore`
- [ ] **Container naming** - Use unique names, avoid conflicts
- [ ] **Container cleanup** - Remove containers after use
- [ ] **Health checks** - Implement container health checks
- [ ] **Resource limits** - Set CPU and memory limits

---

## Testing

- [ ] **Test recipes exist** - Recipes for unit, integration, e2e tests
- [ ] **Independent tests** - Tests don't depend on execution order
- [ ] **Test isolation** - Each test has own setup/teardown
- [ ] **Isolated environment** - Test environment separate from production
- [ ] **Coverage reporting** - Generate and check coverage reports
- [ ] **Exit codes** - Failed tests return non-zero exit code

---

## CI/CD Integration

- [ ] **CI compatibility** - Recipes work in CI environment
- [ ] **CI-specific recipes** - Create `test-ci`, `build-ci` variants
- [ ] **Secrets management** - Pass secrets via environment variables
- [ ] **Artifact management** - Generate artifacts in standard locations
- [ ] **Build metadata** - Include commit SHA, timestamp, version
- [ ] **Deployment gates** - Implement checks before deployment
- [ ] **Rollback procedures** - Document and automate rollbacks

---

## Logging & Performance

- [ ] **Operation logging** - Log start/end of all operations
- [ ] **ISO 8601 timestamps** - Use standard timestamp format
- [ ] **No sensitive data** - Never log passwords, tokens, or keys
- [ ] **Progress indicators** - Show progress for long operations
- [ ] **Caching** - Cache expensive operations (downloads, builds)
- [ ] **Parallel execution** - Use `&` and `wait` for parallel tasks

---

## Portability

- [ ] **Linux support** - Works on Linux (Ubuntu, Debian, RHEL, etc.)
- [ ] **macOS support** - Works on macOS (if required)
- [ ] **Docker support** - Works in Docker containers
- [ ] **CI/CD support** - Works in GitHub Actions, GitLab CI, etc.
- [ ] **Command availability** - Check commands exist before use

---

## Common Mistakes to Avoid

- [ ] ❌ **No confirmation for destructive ops** - Always confirm `rm -rf`, `DROP DATABASE`
- [ ] ❌ **Unsafe deletion** - Never `rm -rf /` or `rm -rf "$var"` without validation
- [ ] ❌ **Excessive permissions** - Never `chmod 777`, use minimum needed
- [ ] ❌ **Pipe to shell** - Never `curl | sh` without verification
- [ ] ❌ **Mixed indentation** - No mixing tabs and spaces
- [ ] ❌ **Unused variables** - Remove or use all declared variables
- [ ] ❌ **Commented code** - Remove or explain commented recipes
- [ ] ❌ **Hardcoded values** - Use variables for configurable values
- [ ] ❌ **No error handling** - Always handle errors and timeouts
- [ ] ❌ **Unquoted variables** - Always quote: `"$var"` not `$var`

---

## Recipe-Specific Checks

### Development Recipes

- [ ] **`dev`** - Starts development server with hot reload
- [ ] **`install`** - Installs all dependencies with lock file
- [ ] **`clean`** - Removes build artifacts and temp files
- [ ] **`reset`** - Provides completely fresh start

### Testing Recipes

- [ ] **`test`** - Runs all tests and returns non-zero on failure
- [ ] **`test-unit`** - Runs unit tests only
- [ ] **`test-integration`** - Runs integration tests with fixtures
- [ ] **`test-coverage`** - Generates and displays coverage report

### Build Recipes

- [ ] **`build`** - Produces production-ready artifacts with tests
- [ ] **`build`** - Build metadata included (version, SHA, timestamp)
- [ ] **`build`** - Deterministic builds (same input = same output)

### Deployment Recipes

- [ ] **`deploy`** - Runs tests and builds before deploying
- [ ] **`deploy`** - Validates target environment and prerequisites
- [ ] **`deploy`** - Creates backup and has rollback procedure
- [ ] **`deploy`** - Confirmation prompt for production

### Database Recipes

- [ ] **`db-create`** - Creates database if doesn't exist
- [ ] **`db-drop`** - Requires confirmation before dropping
- [ ] **`db-migrate`** - Runs pending migrations (idempotent)
- [ ] **`db-rollback`** - Rolls back last migration
- [ ] **`db-seed`** - Seeds database with data (idempotent)
- [ ] **`db-backup`** - Creates timestamped backup file
- [ ] **`db-restore`** - Validates backup file before restoring

### Helper Recipes

- [ ] **`_require cmd`** - Checks command exists, exits with message
- [ ] **`_require-env var`** - Checks environment variable set
- [ ] **Helper recipes hidden** - Not shown in `just --list`
- [ ] **Helper recipes documented** - Comments explain parameters

---

## Final Validation

- [ ] **Syntax check** - Run `just --check` to validate syntax
- [ ] **Variable evaluation** - Run `just --evaluate` to check variables
- [ ] **Dry run all recipes** - Run `just --dry-run <recipe>` for each
- [ ] **Fresh environment** - Test in completely fresh environment
- [ ] **Target platforms** - Test on all target platforms (Linux, macOS, Docker)
- [ ] **Security scan** - Run security scanning tools
- [ ] **Documentation complete** - All documentation reviewed and current

---

## Quick Command Reference

### Essential Commands

```bash
# List all recipes with descriptions
just --list
just -l

# Show specific recipe
just --show recipe-name

# Run recipe with verbose output
just --verbose recipe-name
just -v recipe-name
```

### Validation Commands

```bash
# Validate justfile syntax
just --check

# Dry run (show commands without executing)
just --dry-run recipe-name
just -n recipe-name

# Evaluate variable
just --evaluate variable-name

# Show all recipes (one per line)
just --summary
```

### Debugging Commands

```bash
# Show recipe with dependencies
just --show recipe-name

# Dump justfile as JSON
just --dump

# Choose recipe interactively
just --choose

# Set working directory
just --working-directory /path/to/dir
just -d /path/to/dir
```

### Advanced Usage

```bash
# Load .env file from specific path
just --dotenv-path .env.production

# Set variable from command line
just --set variable value recipe-name

# Run recipe from specific justfile
just --justfile path/to/justfile recipe-name
just -f path/to/justfile recipe-name
```

---

## Additional Resources

- [Just Documentation](https://just.systems/)
- [Just GitHub Repository](https://github.com/casey/just)
- [Just Best Practices Guide](./Just_Best_Practices_Guide.md)
- [Just Script Examples](./examples/)

---

**Last Updated**: 2025-12-12
