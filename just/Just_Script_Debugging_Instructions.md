# Just Script Debugging Instructions — AI Prompt Template

> **Context**: Use this prompt to diagnose and fix problematic Just scripts that are failing, producing unexpected results, or experiencing performance issues.
> **Reference**: See `Just_Script_Best_Practices_Guide.md` and `Just_Security_Standards_Reference.md` for detailed standards.

---

## Role & Objective

You are a **Just debugging specialist** with expertise in diagnosing syntax errors, recipe failures, variable issues, dependency problems, and shell integration errors in justfiles.

Your task: Analyze a failing Just script, **identify the root cause**, and **provide specific fixes** with explanations. Use systematic debugging approach and provide working solutions.

---

## Pre-Execution Configuration

**User must provide:**

1. **Problem description** (choose all that apply):
   - [ ] Recipe not found error
   - [ ] Syntax error / parsing failure
   - [ ] Variable not expanding correctly
   - [ ] Recipe fails silently
   - [ ] Dependency cycle detected
   - [ ] Environment variable issues
   - [ ] Shell command failures
   - [ ] Permission denied errors
   - [ ] Performance problems (slow execution)
   - [ ] Import/module issues
   - [ ] Intermittent failures
   - [ ] Other: _________________

2. **Script information**:
   - [ ] Full justfile content
   - [ ] Error messages (exact output)
   - [ ] Expected behavior
   - [ ] Actual behavior
   - [ ] Environment details (OS, Just version, shell)
   - [ ] Recipe name causing issue

3. **Debugging level** (choose one):
   - [ ] **Quick fix**: Identify and fix primary issue
   - [ ] **Comprehensive**: Full analysis with multiple improvements
   - [ ] **Root cause**: Deep dive into underlying problem

4. **Output preference** (choose one):
   - [ ] Fixed justfile with explanations
   - [ ] Diagnostic report with recommendations
   - [ ] Step-by-step debugging guide
   - [ ] Side-by-side comparison (broken vs fixed)

---

## Debugging Process

### Step 1: Gather Debug Information

**Run diagnostic commands:**

```bash
# Validation
just --check                    # Check syntax
just --version                  # Show Just version

# Inspection
just --list                     # List recipes with descriptions
just --summary                  # List recipe names only
just --show recipe-name         # Show recipe definition
just --variables                # Show all variables
just --evaluate variable-name   # Evaluate specific variable
just --dump                     # Show parsed justfile

# Execution Testing
just --dry-run recipe-name      # Show commands without running
just --verbose recipe-name      # Verbose execution
```

**Enable debugging in recipes:**

```just
# Add verbose logging to recipes
recipe:
    #!/usr/bin/env bash
    set -euxo pipefail  # Add 'x' for command tracing

    echo "DEBUG: Starting recipe"
    echo "DEBUG: Variable value: {{variable}}"

    # Your commands here
```

**What to look for in debug output:**

1. **Syntax errors**: `error: Expected ':', '=', or ':=', but found ':' --> justfile:15:1`
2. **Recipe not found**: `error: Justfile does not contain recipe 'recipe-name'`
3. **Variable expansion issues**: `error: Variable 'undefined_var' not defined`
4. **Dependency cycle**: `error: Recipe 'a' depends on itself: a -> b -> c -> a`

---

### Step 2: Diagnose Common Issues

#### Issue 1: Recipe Not Found

**Symptoms**: `error: Justfile does not contain recipe 'name'`

**Common Causes & Fixes**:

1. **Typo in recipe name**:
   ```bash
   # Debug: List all recipes
   just --list
   just --summary | grep test
   ```

2. **Recipe name contains invalid characters**:
   ```just
   # ❌ BAD - Contains invalid characters
   test/integration:  # Slash not allowed
       npm test

   # ✅ GOOD - Use dashes
   test-integration:
       npm test
   ```

3. **Recipe hidden (starts with underscore)**:
   ```just
   # Private recipes don't show in --list
   _internal-helper:
       echo "This is internal"

   # But can still be called: just _internal-helper
   ```

---

#### Issue 2: Syntax Errors

**Symptoms**: `error: Expected ':', '=', or ':='`, Justfile won't parse

**Common Causes & Fixes**:

1. **Missing colon after recipe name**:
   ```just
   # ❌ BAD
   build
       npm run build

   # ✅ GOOD
   build:
       npm run build
   ```

2. **Incorrect indentation (tabs vs spaces)**:
   ```bash
   # Debug: Show whitespace characters
   cat -A justfile | grep -n "build" -A 2
   ```
   ```just
   # ✅ GOOD - Consistent indentation
   build:
       npm run build
       npm run test
   ```

3. **Invalid variable assignment**:
   ```just
   # ❌ BAD
   variable = "value"  # Single = not allowed

   # ✅ GOOD
   variable := "value"  # Use :=
   ```

4. **Unclosed string or interpolation**:
   ```just
   # ❌ BAD
   message := "Hello World
   build:
       echo {{version

   # ✅ GOOD
   message := "Hello World"
   build:
       echo {{version}}
   ```

**Diagnostic approach**:
```bash
just --check
# Shows line number: error: Expected ':', '=', or ':=' --> justfile:15:1

# Check specific line and context
sed -n '13,17p' justfile
```

---

#### Issue 3: Variable Not Expanding

**Symptoms**: Literal `{{var}}` in output, wrong value, or `error: Variable 'name' not defined`

**Common Causes & Fixes**:

1. **Variable not defined**:
   ```just
   # ❌ BAD
   build:
       npm run build --output={{output_dir}}  # output_dir not defined

   # ✅ GOOD
   output_dir := "dist"
   build:
       npm run build --output={{output_dir}}
   ```

2. **Using shell variable syntax instead of Just syntax**:
   ```just
   # ❌ BAD
   version := "1.0.0"
   build:
       echo $version  # Won't expand Just variable

   # ✅ GOOD - Use Just interpolation
   build:
       echo {{version}}

   # ✅ ALSO GOOD - Use in shebang recipe
   build:
       #!/usr/bin/env bash
       echo "{{version}}"  # Expands before shell sees it
   ```

3. **Environment variable not set**:
   ```just
   # ❌ BAD - Fails if API_KEY not set
   api_key := env_var("API_KEY")

   # ✅ GOOD - Provide default
   api_key := env_var_or_default("API_KEY", "")

   # ✅ GOOD - Validate in recipe
   deploy:
       #!/usr/bin/env bash
       set -euo pipefail

       if [ -z "{{api_key}}" ]; then
           echo "Error: API_KEY not set"
           exit 1
       fi

       ./deploy.sh
   ```

4. **Variable scope issues**:
   ```just
   # Recipe parameters don't affect global scope
   recipe param="default":
       echo {{param}}       # Works

   other-recipe:
       echo {{param}}       # ERROR: param not defined here
   ```

**Diagnostic approach**:
```bash
just --variables              # Check variable definitions
just --evaluate variable-name # Evaluate specific variable
echo $VARIABLE_NAME           # Check environment
just --dry-run recipe-name | grep variable  # Test expansion
```

---

#### Issue 4: Recipe Fails Silently

**Symptoms**: Recipe completes but commands failed, exit code 0 despite errors

**Common Causes & Fixes**:

1. **Missing error handling in single-line recipe**:
   ```just
   # ❌ BAD - Continues on failure
   deploy:
       npm test
       npm run build  # Runs even if test fails!
       ./deploy.sh

   # ✅ GOOD - Use && to chain
   deploy:
       npm test && npm run build && ./deploy.sh
   ```

2. **Missing `set -e` in shebang recipe**:
   ```just
   # ❌ BAD
   deploy:
       #!/usr/bin/env bash
       npm test        # If this fails...
       npm run build   # ...this still runs

   # ✅ GOOD
   deploy:
       #!/usr/bin/env bash
       set -euo pipefail
       npm test        # If this fails, recipe stops
       npm run build
   ```

3. **Suppressing errors with `@`**:
   ```just
   # ❌ BAD
   test:
       @npm test  # @ suppresses output AND errors

   # ✅ GOOD
   test:
       npm test

   # ✅ ALSO GOOD - Suppress output but handle errors
   test:
       @npm test || (echo "Tests failed"; exit 1)
   ```

**Diagnostic approach**:
```bash
# Run with verbose mode
just --verbose recipe-name

# Check exit code
just recipe-name
echo "Exit code: $?"

# Add debugging to recipe with command tracing
recipe:
    #!/usr/bin/env bash
    set -euxo pipefail  # 'x' prints each command
    command1
    command2
```

---

#### Issue 5: Dependency Problems

**Symptoms**: Circular dependency error, dependencies run in wrong order, dependencies run multiple times

**Common Causes & Fixes**:

1. **Circular dependencies**:
   ```just
   # ❌ BAD - Circular dependency
   build: deploy
       npm run build

   deploy: build
       ./deploy.sh
   # Error: Recipe `build` depends on itself: build -> deploy -> build

   # ✅ GOOD
   build:
       npm run build

   deploy: build
       ./deploy.sh
   ```

2. **Duplicate work in dependencies**:
   ```just
   # ❌ BAD - test runs twice
   test:
       npm test

   integration-test: test
       npm run test:integration

   all: test integration-test  # test runs twice!

   # ✅ GOOD
   test-unit:
       npm run test:unit

   test-integration:
       npm run test:integration

   test: test-unit test-integration
   ```

3. **Dependencies with side effects**:
   ```just
   # ❌ BAD - cleanup happens before build
   deploy: cleanup build
       ./deploy.sh

   cleanup:
       rm -rf dist/  # Deletes build output!

   # ✅ GOOD
   deploy: build
       ./deploy.sh

   clean:
       rm -rf dist/
   ```

**Diagnostic approach**:
```bash
just --show recipe-name  # Check dependency tree
just --dry-run recipe-name  # Test dependency order
just --dump | grep -A 5 "recipe-name"  # Visualize dependencies
```

---

#### Issue 6: Shell Command Failures

**Symptoms**: `command not found`, commands work in terminal but not in Just, path issues

**Common Causes & Fixes**:

1. **Command not in PATH**:
   ```just
   # ✅ GOOD - Verify command exists first
   build: (_require "npm")
       npm run build

   # Helper recipe
   _require cmd:
       @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found"; exit 1)
   ```

2. **Different shell environment**:
   ```just
   set shell := ["bash", "-c"]

   # ✅ GOOD - Explicit shebang
   build:
       #!/usr/bin/env bash
       set -euo pipefail
       array=("one" "two" "three")
       echo "Using array: ${array[@]}"
   ```

3. **Working directory issues**:
   ```just
   # ❌ BAD
   build:
       cd frontend && npm run build  # cd doesn't persist
       cd backend && npm run build   # Starts in original dir

   # ✅ GOOD - Use subshells
   build:
       (cd frontend && npm run build)
       (cd backend && npm run build)
   ```

4. **Quoting issues**:
   ```just
   # ❌ BAD
   file := "my file.txt"
   process:
       cat {{file}}  # Expands to: cat my file.txt (2 args!)

   # ✅ GOOD
   process:
       cat "{{file}}"
   ```

**Diagnostic approach**:
```bash
just --dry-run recipe-name        # Check what Just sees
just --evaluate 'env_var("PATH")' # Check PATH in Just
command -v npm                    # Test command availability
```

---

#### Issue 7: Environment Variable Issues

**Symptoms**: Variable has wrong value, `error: Environment variable 'NAME' not defined`, .env file not loaded

**Common Causes & Fixes**:

1. **.env file not loaded**:
   ```just
   # ✅ GOOD - Enable dotenv loading
   set dotenv-load := true

   deploy:
       ./deploy.sh  # Now loads .env
   ```

2. **Variable not exported**:
   ```just
   # ❌ BAD
   API_KEY := env_var_or_default("API_KEY", "")
   deploy:
       ./deploy.sh  # deploy.sh can't see $API_KEY

   # ✅ GOOD - Export variable
   export API_KEY := env_var_or_default("API_KEY", "")
   deploy:
       ./deploy.sh  # deploy.sh can see $API_KEY
   ```

3. **Variable evaluated at wrong time**:
   ```just
   # ❌ BAD - Evaluated once at parse time
   timestamp := `date +%s`
   log:
       echo "Time: {{timestamp}}"  # Always same value

   # ✅ GOOD - Evaluated at run time
   log:
       echo "Time: $(date +%s)"
   ```

**Diagnostic approach**:
```bash
just --evaluate 'env_var_or_default("VAR_FROM_DOTENV", "not-set")'
just --variables  # List all Just variables
env | grep VARIABLE_NAME  # Check environment
```

---

#### Issue 8: Permission Denied Errors

**Symptoms**: `Permission denied` when executing, file/directory access errors

**Common Causes & Fixes**:

1. **Script not executable**:
   ```just
   # ✅ GOOD - Use shell interpreter
   deploy:
       bash deploy.sh

   # ✅ ALSO GOOD - Make executable
   deploy: _ensure-executable
       ./deploy.sh

   _ensure-executable:
       chmod +x deploy.sh
   ```

2. **Insufficient file permissions**:
   ```just
   process:
       #!/usr/bin/env bash
       set -euo pipefail

       if [ ! -r "/etc/shadow" ]; then
           echo "Error: Cannot read /etc/shadow (permission denied)"
           echo "This operation requires root privileges"
           exit 1
       fi

       cat /etc/shadow
   ```

3. **Need sudo but not using it**:
   ```just
   # Install system dependencies (requires root)
   # Run with: sudo -E just install-system
   install-system:
       #!/usr/bin/env bash
       set -euo pipefail

       if [ "$EUID" -ne 0 ]; then
           echo "Error: This recipe must be run as root"
           echo "Run: sudo -E just install-system"
           exit 1
       fi

       apt-get update
       apt-get install -y postgresql
   ```

**Diagnostic approach**:
```bash
ls -la file.sh                 # Check file permissions
test -x file.sh && echo "Executable" || echo "Not executable"
chmod +x file.sh               # Fix permissions
whoami                         # Check current user
```

---

### Step 3: Advanced Debugging Techniques

#### Technique 1: Using --dry-run and --verbose

```bash
# See what would execute without running
just --dry-run recipe-name

# See detailed execution information
just --verbose recipe-name
```

#### Technique 2: Using --dump and --evaluate

```bash
# Show parsed justfile structure (all settings, variables, recipes)
just --dump

# Evaluate expression without running recipe
just --evaluate variable-name
just --evaluate 'env_var_or_default("NODE_ENV", "dev")'
just --evaluate 'justfile_directory()'
```

#### Technique 3: Binary Search for Errors

```just
# If large justfile has issues, binary search:
# Comment out second half of recipes
# just --check
# If passes, error is in second half; if fails, error is in first half
# Repeat until error found
```

#### Technique 4: Minimal Reproduction

```just
# Create minimal justfile that reproduces issue
set shell := ["bash", "-c"]

# Add problem recipe
problem-recipe:
    command-that-fails

# Run: just problem-recipe
# If it fails, issue is reproduced
# If it works, issue is elsewhere (dependencies, variables, etc.)
```

#### Technique 5: Shell Tracing

```just
# Enable shell command tracing
recipe:
    #!/usr/bin/env bash
    set -euxo pipefail  # 'x' enables tracing

    # Every command printed before execution:
    # + command1 arg1 arg2
    command1 arg1 arg2
    # + command2
    command2
```

#### Technique 6: Logging to File

```just
log_file := "just-debug.log"

recipe:
    #!/usr/bin/env bash
    set -euo pipefail

    # Redirect all output to log
    exec > >(tee -a "{{log_file}}") 2>&1

    echo "Starting recipe at $(date)"
    # Your commands here
    echo "Finished at $(date)"

view-log:
    cat {{log_file}}

clear-log:
    rm -f {{log_file}}
```

---

## Troubleshooting Quick Reference

### Diagnostic Flow

1. **Just command found?** NO → Install Just: `cargo install just`
2. **`just --check` passes?** NO → Fix syntax error (see line number in output)
3. **`just --list` shows recipe?** NO → Check recipe name spelling
4. **`just --show recipe-name` correct?** NO → Check hidden characters, indentation
5. **`just --dry-run recipe-name` correct?** NO → Check variable interpolation with `--evaluate`
6. **Recipe fails when executed?** YES → Add `set -euxo pipefail`, check logs

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Expected ':'` | Missing colon after recipe name | Add `:` after recipe name |
| `Expected ':=' or '='` | Invalid variable assignment | Use `:=` for assignment |
| `Unexpected token` | Mixed tabs/spaces | Use consistent indentation |
| `Unterminated string` | Missing closing quote | Close all strings with `"` |
| `Recipe not found` | Typo or recipe doesn't exist | Check with `just --list` |
| `Variable not defined` | Variable used before definition | Define variable before use |
| `Circular dependency` | Recipe depends on itself | Break circular reference |
| `Command not found` | Binary not in PATH | Use full path or add to PATH |
| `Permission denied` | Script not executable | Use `bash script.sh` or `chmod +x` |

---

## Performance Debugging

### Identifying Slow Recipes

```just
# Add timing to recipes
timed-recipe:
    #!/usr/bin/env bash
    set -euo pipefail

    start=$(date +%s)

    # Your commands here
    npm run build

    end=$(date +%s)
    duration=$((end - start))
    echo "✓ Recipe completed in ${duration}s"
```

### Optimization Strategies

1. **Cache expensive operations**:
   ```just
   # Only rebuild if needed
   build:
       #!/usr/bin/env bash
       set -euo pipefail

       if [ -d "dist" ] && [ "dist" -nt "src" ]; then
           echo "Build up to date"
           exit 0
       fi

       npm run build
   ```

2. **Parallelize independent tasks**:
   ```just
   all:
       #!/usr/bin/env bash
       set -euo pipefail

       just test &
       just lint &
       just type-check &

       wait
       echo "✓ All tasks complete"
   ```

3. **Minimize file operations**:
   ```just
   # ❌ SLOW
   process-files:
       #!/usr/bin/env bash
       for file in src/*.js; do
           cat "$file" | process
       done

   # ✅ FAST - Batch operation
   process-files:
       find src -name "*.js" -print0 | xargs -0 process
   ```

---

## Output Format

### Diagnostic Report with Fix

```markdown
# Just Script Debugging Report

**File**: justfile
**Issue**: Recipe fails with "variable not defined" error
**Root Cause**: Variable used before definition

---

## Problem Analysis

### User Report
"Recipe `deploy` fails with error: Variable `version` not defined"

### Investigation
1. Ran `just --check` - syntax valid
2. Ran `just --show deploy` - shows variable usage
3. Ran `just --variables` - `version` not in list
4. Found variable used on line 45 but never defined

### Finding
**Expected**: Variable `version` should be defined
**Actual**: Variable `version` used but not defined

Error occurs at:
```
Line 45: ./deploy.sh --version={{version}}
```

---

## Root Cause

Variable `version` is used in recipe `deploy` but never defined in justfile.

**Current code (broken)**:
```just
deploy:
    ./deploy.sh --version={{version}}  # version not defined
```

---

## Solution

Define `version` variable before use:

**Fixed code**:
```just
# Get version from git or environment
version := env_var_or_default("VERSION", `git rev-parse --short HEAD`)

deploy:
    ./deploy.sh --version={{version}}
```

**Alternative (if version should be a parameter)**:
```just
# Allow version as parameter with default
deploy version=`git rev-parse --short HEAD`:
    ./deploy.sh --version={{version}}

# Usage:
# just deploy              # Uses git hash
# just deploy 1.2.3        # Uses specified version
```

---

## Testing

```bash
# Test variable definition
just --evaluate version
# Should output: abc1234 (git hash)

# Test dry run
just --dry-run deploy
# Should output: ./deploy.sh --version=abc1234

# Test actual execution
just deploy
# Should deploy with version
```

---

## Additional Improvements

While debugging, found other issues:

1. **No error handling** - Added `set -euo pipefail` to recipe
2. **No prerequisite check** - Added dependency on `build` recipe
3. **No environment validation** - Added `_check-env` helper

See complete fixed justfile below.
```

### Complete Fixed Justfile Example

```just
# justfile for Application
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
version := env_var_or_default("VERSION", `git rev-parse --short HEAD`)

# Default recipe
default:
    @just --list

# Build application
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building version {{version}}..."
    npm run build
    echo "✓ Build complete"

# Deploy application
deploy: (_check-env) build
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Deploying version {{version}} to $NODE_ENV..."
    ./deploy.sh --version={{version}} --env=$NODE_ENV
    echo "✓ Deployed successfully"

# Helper: Check environment
_check-env:
    #!/usr/bin/env bash
    set -euo pipefail

    valid_envs=("development" "staging" "production")

    if [[ ! " ${valid_envs[@]} " =~ " $NODE_ENV " ]]; then
        echo "Error: Invalid NODE_ENV '$NODE_ENV'"
        echo "Valid values: ${valid_envs[@]}"
        exit 1
    fi
```

---

## Prevention Checklist

After fixing, verify:

- [ ] `just --check` passes (syntax valid)
- [ ] `just --variables` shows all required variables
- [ ] `just --list` shows all public recipes
- [ ] All recipes have `set -euo pipefail`
- [ ] Dependencies correctly specified
- [ ] Variables defined before use
- [ ] Environment variables have defaults
- [ ] Commands exist and are in PATH
- [ ] File permissions correct (scripts executable)
- [ ] No circular dependencies
- [ ] Error messages are clear
- [ ] Tested with `--dry-run`
- [ ] Tested actual execution

---

## References

Debugging techniques from:

- **Best Practices**: `Just_Script_Best_Practices_Guide.md`
- **Security**: `Just_Security_Standards_Reference.md`
- **Checklist**: `Just_Script_Checklist.md`
- **Just Manual**: https://just.systems
- **Just GitHub**: https://github.com/casey/just

---

**Last Updated**: 2025-12-12
**Version**: 2.0
