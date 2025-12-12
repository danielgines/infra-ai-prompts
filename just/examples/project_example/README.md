# Just Project Example: Complete Project Structure

This example demonstrates the **standard, production-ready way** to use `just` as your project's task runner with a main `justfile` that auto-discovers and imports modular components.

## 🎯 Purpose

This example shows:
1. **Main `justfile`** (no extension) - auto-discovered by `just`
2. **Modular `*.just` files** - imported components for organization
3. **Natural workflow** - `cd project_example/ && just --list`
4. **Import pattern** - keeping recipes organized by domain

## 📁 Structure

```
project_example/
├── justfile                  ← Main file (auto-discovered)
├── scripts/
│   ├── docker.just           ← Docker operations module
│   └── tests.just            ← Testing operations module
└── README.md                 ← This file
```

## 🔍 Key Differences: `justfile` vs `*.just` Files

### `justfile` (Main File, No Extension)

**Auto-discovery**: `just` automatically finds and uses this file when you run:
```bash
cd project_example/
just --list         # Auto-discovers justfile
just build          # Runs recipe from justfile
```

**Usage**: This is your project's **primary task runner file**. Every project using `just` should have one.

**Location**: Project root directory (same level as `package.json`, `README.md`, etc.)

**Characteristics**:
- No file extension
- Auto-discovered by `just` command
- Contains main project recipes
- Imports modular `*.just` files
- Can be named `justfile`, `Justfile`, or `.justfile` (hidden)

### `*.just` Files (Modules, With Extension)

**Explicit import**: These files are **imported** by the main `justfile`:
```just
# In justfile:
import 'scripts/docker.just'
import 'scripts/tests.just'
```

**Usage**: Organize related recipes into logical modules for:
- Better organization (Docker operations, testing, deployment)
- Reusability across projects
- Separation of concerns

**Location**: Usually in `scripts/`, `tasks/`, or similar subdirectories

**Characteristics**:
- `.just` file extension
- Not auto-discovered (must be imported)
- Contains domain-specific recipes
- Can be shared across projects
- Syntax highlighting in editors (VSCode, Vim, etc.)

## 📖 How to Use This Example

### 1. Navigate to the directory
```bash
cd /data/Projetos/infra-ai-prompts/just/examples/project_example/
```

### 2. List available recipes
```bash
just --list
# or just: just -l
```

**Output shows recipes from ALL files** (justfile + imported modules):
```
Available recipes:
    default                       # Shows this list
    info                          # Show project information
    setup                         # Setup development environment
    clean                         # Clean build artifacts
    ci                            # Full CI pipeline
    ...
    docker-build                  # From scripts/docker.just
    docker-run                    # From scripts/docker.just
    test                          # From scripts/tests.just
    test-coverage                 # From scripts/tests.just
```

### 3. Run recipes naturally
```bash
just info               # From main justfile
just docker-build       # From scripts/docker.just (imported)
just test               # From scripts/tests.just (imported)
```

### 4. Explore the import pattern

**In `justfile`** (lines 10-11):
```just
# Import modular task files
import 'scripts/docker.just'
import 'scripts/tests.just'
```

This makes ALL recipes from imported files available as if they were in the main file.

## 🎓 Learning Paths

### Beginner: Basic Project Automation
1. Review `justfile` - main recipes (setup, build, ci)
2. Run `just setup` - see environment setup automation
3. Run `just --list` - see all available recipes

### Intermediate: Modular Organization
1. Examine `scripts/docker.just` - Docker-specific recipes
2. Examine `scripts/tests.just` - Testing-specific recipes
3. Run `just docker-build` - recipe from imported module
4. Try adding your own module: `scripts/database.just`

### Advanced: Custom Project Structure
1. Study the import pattern in `justfile`
2. Organize recipes by domain (docker, tests, deploy, db)
3. Create reusable modules across multiple projects
4. Use environment variables and dotenv loading

## 🔧 Key Patterns Demonstrated

### 1. Project Configuration
```just
# At top of justfile
set shell := ["bash", "-c"]
set dotenv-load := true

app_name := "myapp"
version := `git describe --tags --always 2>/dev/null || echo "dev"`
```

### 2. Default Recipe
```just
# Shows help when you type 'just' without arguments
default:
    @just --list
```

### 3. Recipe Dependencies
```just
# CI pipeline runs lint, then test, then build
ci: lint test build
    @echo "✅ CI pipeline completed successfully"
```

### 4. Environment Variables
```just
docker_registry := env_var_or_default("DOCKER_REGISTRY", "docker.io")
```

### 5. Multi-line Bash Scripts
```just
setup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting up..."
    # Multiple commands with proper error handling
```

### 6. Helper Recipes (Private)
```just
# Private recipe (prefixed with _)
_check-docker:
    #!/usr/bin/env bash
    if ! docker info &> /dev/null; then
        echo "Error: Docker is not running"
        exit 1
    fi
```

## 🚀 Real-World Usage Examples

### Daily Development
```bash
just setup              # First time setup
just dev                # Start development server
just test-watch         # Run tests on file changes
```

### Docker Workflow
```bash
just docker-build       # Build image
just docker-run         # Run locally
just docker-push v1.0.0 # Push to registry
```

### CI/CD Pipeline
```bash
just ci                 # Run full CI pipeline
just test-coverage      # Check coverage
just docker-build       # Build production image
```

### Testing
```bash
just test               # Run all tests
just test-unit          # Run unit tests only
just test-coverage      # With coverage report
just test-watch         # Watch mode
```

## 📚 Comparison with Other Examples

### This Example (`project_example/`)
- **File**: `justfile` (no extension)
- **Usage**: `cd project_example/ && just build`
- **Discovery**: Automatic
- **Purpose**: Real project structure
- **Organization**: Imports modules

### Other Examples (`*.just` files)
- **Files**: `basic_web_app.just`, `docker_workflow.just`, `monorepo_tasks.just`
- **Usage**: `just --justfile basic_web_app.just build`
- **Discovery**: Explicit with `--justfile` flag
- **Purpose**: Educational examples
- **Organization**: Self-contained

## 💡 When to Use Each Approach

### Use `justfile` (this example) when:
- ✅ Building a real project
- ✅ Want automatic discovery (`just` without flags)
- ✅ Need modular organization
- ✅ Project has multiple domains (docker, tests, deploy)
- ✅ Standard project task runner

### Use `*.just` files when:
- ✅ Creating reusable modules
- ✅ Sharing example code
- ✅ Multiple justfile configurations
- ✅ Educational demonstrations
- ✅ Imported by main justfile

## 🎯 Next Steps

1. **Copy this structure** to your project:
   ```bash
   cp -r project_example/justfile your-project/
   cp -r project_example/scripts your-project/
   ```

2. **Customize** recipes for your project's needs

3. **Add more modules** as needed:
   ```
   scripts/
   ├── docker.just
   ├── tests.just
   ├── database.just      ← Add this
   └── deployment.just    ← Add this
   ```

4. **Import new modules** in main justfile:
   ```just
   import 'scripts/database.just'
   import 'scripts/deployment.just'
   ```

## 📖 Further Reading

- [Just Manual](https://just.systems/man/en/)
- [Just GitHub Repository](https://github.com/casey/just)
- [Import Documentation](https://just.systems/man/en/chapter_52.html)

---

**Key Takeaway**: This example shows the **standard way** to use `just` in real projects. The main `justfile` is auto-discovered, while `*.just` modules keep recipes organized.
