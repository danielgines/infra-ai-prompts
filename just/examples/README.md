# Just Script Examples

> **Purpose**: Working justfile examples demonstrating patterns, best practices, and common workflows.

---

## Available Examples

### 1. basic_web_app.just

**Purpose**: Simple web application justfile for beginners

**Project type**: Node.js web app (Express + React)

**Features demonstrated**:
- Basic recipe structure
- Development workflow (dev, test, build)
- Environment variable handling
- Simple dependency management
- Error handling patterns

**When to use**: Starting a new web application or learning just basics

**Complexity**: ⭐ Beginner

---

### 2. docker_workflow.just

**Purpose**: Docker-centric development workflow

**Project type**: Dockerized application with multi-container setup

**Features demonstrated**:
- Docker build optimization
- Multi-container orchestration
- Volume management
- Network configuration
- Container health checks
- Log aggregation

**When to use**: Projects that run entirely in Docker containers

**Complexity**: ⭐⭐ Intermediate

---

### 3. monorepo_tasks.just

**Purpose**: Monorepo task automation with Turborepo

**Project type**: Monorepo with multiple services/packages

**Features demonstrated**:
- Workspace-aware commands
- Selective builds and tests
- Dependency graph management
- Parallel execution
- Artifact caching
- Service-specific operations

**When to use**: Monorepo projects with multiple services or packages

**Complexity**: ⭐⭐⭐ Advanced

---

## Learning Path

### Path 1: Beginners

Start with understanding just fundamentals:

1. **Read**: `basic_web_app.just`
   - Understand recipe syntax
   - Learn variable definitions
   - See basic error handling

2. **Practice**: Copy and adapt
   - Copy `basic_web_app.just` to your project
   - Rename recipes to match your needs
   - Add project-specific variables

3. **Extend**: Add more recipes
   - Add database recipes
   - Add deployment recipes
   - Add helper recipes

### Path 2: Docker Users

Focus on container-based workflows:

1. **Read**: `basic_web_app.just` (for fundamentals)
2. **Read**: `docker_workflow.just` (for Docker patterns)
3. **Practice**: Integrate with your Docker setup
   - Adapt to your docker-compose.yml
   - Add service-specific commands
   - Implement health checks

### Path 3: Monorepo Developers

Learn workspace management:

1. **Read**: `basic_web_app.just` (for fundamentals)
2. **Read**: `monorepo_tasks.just` (for workspace patterns)
3. **Practice**: Adapt to your monorepo structure
   - Replace Turborepo with your tool (Nx, Lerna, etc.)
   - Add cross-workspace dependencies
   - Implement selective operations

---

## Key Patterns

### Pattern 1: Variable Organization

```just
# Configuration at the top
set shell := ["bash", "-c"]
set dotenv-load := true

# Global variables
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
database_url := env_var_or_default("DATABASE_URL", "postgresql://localhost/db")

# Computed variables
project_dir := justfile_directory()
build_dir := project_dir / "dist"
```

### Pattern 2: Helper Recipes

```just
# Hidden helpers (not in `just --list`)
_require cmd:
    @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found"; exit 1)

_log message:
    @echo "[$(date '+%Y-%m-%d %H:%M:%S')] {{message}}"

# Use in public recipes
deploy: (_require "docker") (_require "aws")
    just _log "Starting deployment..."
    # deployment logic
```

### Pattern 3: Default Recipe

```just
# Show help when running `just` without args
default:
    @just --list --unsorted

# Or show custom help
default:
    @echo "Common commands:"
    @echo "  just dev        - Start development server"
    @echo "  just test       - Run tests"
    @echo "  just build      - Build for production"
```

### Pattern 4: Error Handling

```just
# Multi-line recipes always use this header
recipe:
    #!/usr/bin/env bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures

    # Your commands here
    command1
    command2
```

### Pattern 5: Conditional Logic

```just
# Environment-specific behavior
build:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "$NODE_ENV" = "production" ]; then
        echo "Building for production..."
        npm run build -- --optimize
    else
        echo "Building for development..."
        npm run build
    fi
```

### Pattern 6: Recipe Dependencies

```just
# Sequential dependencies
deploy: test build
    ./deploy.sh

# Parallel dependencies
all: (test) (lint) (build)

# Conditional dependencies
deploy: (_check-env "production") test build
    ./deploy.sh

_check-env env:
    @[ "$NODE_ENV" = "{{env}}" ] || (echo "Wrong environment"; exit 1)
```

### Pattern 7: Parameter Handling

```just
# Optional parameter with default
build env='development':
    NODE_ENV={{env}} npm run build

# Required parameter (no default)
deploy-service service:
    docker-compose restart {{service}}

# Variadic parameters
test *args='':
    npm test {{args}}

# Usage: just test --watch --verbose
```

### Pattern 8: File Operations

```just
# Safe file operations
backup:
    #!/usr/bin/env bash
    set -euo pipefail

    backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    # Create backup
    tar czf "$backup_dir/backup.tar.gz" dist/

    # Set permissions
    chmod 600 "$backup_dir/backup.tar.gz"

    echo "Backup created: $backup_dir/backup.tar.gz"
```

### Pattern 9: Docker Integration

```just
# Docker operations with error handling
docker-build:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check if Docker is running
    docker info > /dev/null 2>&1 || (echo "Docker not running"; exit 1)

    # Build with cache
    docker build --cache-from myapp:latest -t myapp:latest .

docker-logs service='':
    #!/usr/bin/env bash
    if [ -z "{{service}}" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f {{service}}
    fi
```

### Pattern 10: Database Operations

```just
# Safe database operations
db-reset: _confirm-reset db-backup db-drop db-create db-migrate db-seed

_confirm-reset:
    #!/usr/bin/env bash
    read -p "⚠️  This will delete all data. Type 'yes' to confirm: " confirm
    [ "$confirm" = "yes" ] || (echo "Aborted"; exit 1)

db-backup:
    #!/usr/bin/env bash
    set -euo pipefail
    timestamp=$(date +%Y%m%d_%H%M%S)
    pg_dump $DATABASE_URL > "backups/db_$timestamp.sql"
    echo "Backup created: backups/db_$timestamp.sql"
```

---

## Common Mistakes to Avoid

### Mistake 1: Not Using Error Handling

```just
# ❌ BAD - Continues on error
build:
    npm run lint
    npm run build  # Runs even if lint fails

# ✅ GOOD - Stops on error
build:
    #!/usr/bin/env bash
    set -euo pipefail
    npm run lint
    npm run build
```

### Mistake 2: Hardcoded Values

```just
# ❌ BAD - Hardcoded paths
deploy:
    scp dist/* user@server.com:/var/www/app

# ✅ GOOD - Variables
deploy_server := env_var_or_default("DEPLOY_SERVER", "server.com")
deploy_path := env_var_or_default("DEPLOY_PATH", "/var/www/app")

deploy:
    scp dist/* user@{{deploy_server}}:{{deploy_path}}
```

### Mistake 3: Missing Documentation

```just
# ❌ BAD - No documentation
dr:
    docker-compose down && docker-compose up -d

# ✅ GOOD - Clear documentation
# Restart all Docker services
# Useful when docker-compose.yml changes
docker-restart:
    docker-compose down
    docker-compose up -d
```

### Mistake 4: No Validation

```just
# ❌ BAD - No input validation
deploy env:
    ./deploy.sh {{env}}

# ✅ GOOD - Validate input
deploy env:
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{env}}" in
        dev|staging|production)
            ./deploy.sh {{env}}
            ;;
        *)
            echo "Invalid environment: {{env}}"
            exit 1
            ;;
    esac
```

### Mistake 5: Destructive Operations Without Confirmation

```just
# ❌ BAD - No confirmation
clean:
    rm -rf dist/ node_modules/

# ✅ GOOD - Require confirmation
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    read -p "Delete dist/ and node_modules/? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    rm -rf dist/ node_modules/
```

---

## Testing Examples

All examples can be tested with:

```bash
# Syntax validation
just --justfile examples/basic_web_app.just --check

# List recipes
just --justfile examples/basic_web_app.just --list

# Dry run
just --justfile examples/basic_web_app.just --dry-run build

# Execute (if you have the environment set up)
just --justfile examples/basic_web_app.just build
```

---

## Adapting Examples

### Step 1: Choose Your Base

Pick the example closest to your project:
- Web app? → `basic_web_app.just`
- Containers? → `docker_workflow.just`
- Monorepo? → `monorepo_tasks.just`

### Step 2: Copy and Rename

```bash
cp examples/basic_web_app.just justfile
```

### Step 3: Customize Variables

Update variables to match your project:
```just
# Change these
export DATABASE_URL := env_var_or_default("DATABASE_URL", "YOUR_DB_URL")
export API_KEY := env_var_or_default("API_KEY", "")

# Add project-specific variables
project_name := "your-project"
```

### Step 4: Modify Recipes

Update recipes to match your build tool, test framework, etc.:
```just
# Change from npm to yarn/pnpm
build:
    yarn build  # was: npm run build
```

### Step 5: Add Custom Recipes

Add project-specific recipes:
```just
# Your custom recipe
deploy-lambda:
    aws lambda update-function-code \
        --function-name my-function \
        --zip-file fileb://dist/function.zip
```

### Step 6: Test Thoroughly

```bash
just --check  # Validate syntax
just --list   # Review recipes
just --dry-run build  # Test without executing
just build    # Actually run
```

---

## Integration Patterns

### Pattern: CI/CD Integration

Add CI-specific recipes to your justfile:

```just
# GitHub Actions
ci-test:
    npm test -- --ci --coverage --maxWorkers=2

ci-build:
    npm run build -- --production

ci-deploy:
    ./scripts/deploy-to-production.sh
```

### Pattern: Git Hooks

Install git hooks with just:

```just
hooks-install:
    #!/usr/bin/env bash
    cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
just lint && just test
EOF
    chmod +x .git/hooks/pre-commit
```

### Pattern: Docker Compose Integration

Wrap docker-compose commands:

```just
up:
    docker-compose up -d

down:
    docker-compose down

logs service='':
    docker-compose logs -f {{service}}

shell service='app':
    docker-compose exec {{service}} bash
```

---

## Troubleshooting

### Issue: Recipe not found

```bash
$ just biuld
error: Justfile does not contain recipe `biuld`.

# Solution: Check spelling
$ just --list
$ just build
```

### Issue: Variable not expanding

```bash
# Problem: {{variable}} appears literally in output

# Cause: Variable not defined
# Solution: Add variable definition
export variable := env_var_or_default("VARIABLE", "default")
```

### Issue: Command not found in recipe

```bash
# Problem: bash: npm: command not found

# Solution: Check prerequisites
_require cmd:
    @command -v {{cmd}} || (echo "{{cmd}} not installed"; exit 1)

build: (_require "npm")
    npm run build
```

---

## Additional Resources

- **Just Manual**: https://just.systems
- **Best Practices**: `../Just_Script_Best_Practices_Guide.md`
- **Security Standards**: `../Just_Security_Standards_Reference.md`
- **Generation Instructions**: `../Just_Script_Generation_Instructions.md`

---

**Last Updated**: 2025-12-11
