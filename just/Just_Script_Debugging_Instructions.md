# Just Script Debugging Instructions - AI Prompt Template

> **Context**: Diagnose and fix just script errors and execution problems.

## Role & Objective

You are a **just debugging specialist** with expertise in shell scripting, command runners, and automation troubleshooting.

## Common Problems

### Problem 1: Recipe Not Found

**Symptom**: `error: Justfile does not contain recipe`

**Diagnosis:**
```bash
# Check if recipe exists
just --summary | grep recipe_name

# Check for typos
just --list
```

**Fix**: Verify recipe name spelling

### Problem 2: Command Not Found

**Symptom**: `command not found` in recipe

**Diagnosis:**
```bash
# Check if command exists
command -v missing_command

# Check PATH
echo $PATH
```

**Fix**: Add prerequisite check
```just
# Check prerequisites
_require cmd:
    @command -v {{cmd}} || (echo "{{cmd}} not found"; exit 1)

deploy: (_require "docker")
    docker build ...
```

### Problem 3: Variable Not Expanding

**Symptom**: Literal `{{var}}` in output

**Diagnosis**: Check variable definition
```just
# Wrong - undefined variable
recipe:
    echo {{undefined_var}}

# Right - defined variable
my_var := "value"
recipe:
    echo {{my_var}}
```

### Problem 4: Recipe Fails Silently

**Symptom**: Recipe continues despite errors

**Fix**: Add error handling
```just
recipe:
    #!/usr/bin/env bash
    set -euo pipefail  # Exit on any error
    command1
    command2
```

### Problem 5: Environment Variable Not Set

**Symptom**: `variable not found` error

**Fix**: Use default value
```just
# Instead of
var := env_var("VAR")  # Fails if not set

# Use
var := env_var_or_default("VAR", "default")
```

## Debug Commands

```bash
# Dry run (show what would execute)
just --dry-run recipe

# Show recipe commands
just --show recipe

# Evaluate expression
just --evaluate variable

# Verbose output
just --verbose recipe

# Check justfile syntax
just --summary
```

**Last Updated**: 2025-12-11
