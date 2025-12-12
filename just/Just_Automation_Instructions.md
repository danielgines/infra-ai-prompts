# Just Automation Instructions - AI Prompt Template

> **Context**: Integrate justfiles with CI/CD pipelines, git hooks, and automated workflows.
> **Reference**: See `Just_Script_Best_Practices_Guide.md` and `Just_Security_Standards_Reference.md`.

## Role & Objective

You are a **DevOps automation specialist** with expertise in CI/CD integration, just command runner, and workflow automation.

Your task: Integrate justfiles into automated workflows (GitHub Actions, GitLab CI, Jenkins, git hooks) and **generate complete, production-ready automation configurations**.

---

## Pre-Execution Configuration

**User must specify:**

1. **CI/CD platform** (choose all that apply):
   - [ ] GitHub Actions
   - [ ] GitLab CI
   - [ ] Jenkins
   - [ ] CircleCI
   - [ ] Travis CI
   - [ ] Drone CI
   - [ ] Other: _________________

2. **Automation triggers** (choose all that apply):
   - [ ] Push to branches
   - [ ] Pull requests
   - [ ] Git hooks (pre-commit, pre-push)
   - [ ] Scheduled (cron)
   - [ ] Manual dispatch
   - [ ] Release tags

3. **Workflows to automate** (choose all that apply):
   - [ ] Linting and formatting
   - [ ] Testing (unit, integration, e2e)
   - [ ] Building artifacts
   - [ ] Deployment
   - [ ] Database migrations
   - [ ] Security scanning
   - [ ] Documentation generation

4. **Environment** (choose all that apply):
   - [ ] Linux (Ubuntu, Debian)
   - [ ] macOS
   - [ ] Docker containers
   - [ ] Self-hosted runners
   - [ ] Cloud runners (GitHub, GitLab)

---

## Integration Patterns

### Pattern 1: GitHub Actions

**Complete workflow example:**

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install just
        uses: extractions/setup-just@v1
        with:
          just-version: 1.16.0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: just install

      - name: Run linter
        run: just lint

      - name: Run tests
        run: just test-coverage
        env:
          NODE_ENV: test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build:
    needs: test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install just
        uses: extractions/setup-just@v1

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: just install

      - name: Build application
        run: just build
        env:
          NODE_ENV: production

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Install just
        uses: extractions/setup-just@v1

      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts
          path: dist/

      - name: Deploy to production
        run: just deploy
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
          DEPLOY_ENV: production
```

**Matrix builds:**

```yaml
# .github/workflows/matrix-test.yml
name: Matrix Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        node-version: [18, 20, 21]

    steps:
      - uses: actions/checkout@v4

      - name: Install just
        uses: extractions/setup-just@v1

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}

      - name: Run tests
        run: just test
```

---

### Pattern 2: GitLab CI

**Complete pipeline example:**

```yaml
# .gitlab-ci.yml
stages:
  - install
  - lint
  - test
  - build
  - deploy

variables:
  JUST_VERSION: "1.16.0"

before_script:
  - wget -qO- https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin

install:
  stage: install
  script:
    - just install
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  artifacts:
    paths:
      - node_modules/
    expire_in: 1 hour

lint:
  stage: lint
  dependencies:
    - install
  script:
    - just lint

test:
  stage: test
  dependencies:
    - install
  script:
    - just test-coverage
  coverage: '/Lines\s*:\s*(\d+\.?\d*)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build:
  stage: build
  dependencies:
    - install
  script:
    - just build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy:production:
  stage: deploy
  dependencies:
    - build
  script:
    - just deploy
  environment:
    name: production
    url: https://app.example.com
  only:
    - main
  when: manual
```

---

### Pattern 3: Jenkins Pipeline

**Jenkinsfile example:**

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        NODE_ENV = 'test'
        DEPLOY_KEY = credentials('deploy-key')
    }

    tools {
        nodejs 'NodeJS 20'
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    sh '''
                        # Install just
                        wget -qO- https://github.com/casey/just/releases/download/1.16.0/just-1.16.0-x86_64-unknown-linux-musl.tar.gz | tar xz
                        sudo mv just /usr/local/bin/
                        just --version
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'just install'
            }
        }

        stage('Lint') {
            steps {
                sh 'just lint'
            }
        }

        stage('Test') {
            steps {
                sh 'just test-coverage'
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'coverage',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }

        stage('Build') {
            steps {
                sh 'just build'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'just deploy'
            }
        }
    }

    post {
        failure {
            sh 'just cleanup || true'
        }
        cleanup {
            cleanWs()
        }
    }
}
```

---

### Pattern 4: Git Hooks

**Pre-commit hook:**

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

set -euo pipefail

echo "Running pre-commit checks..."

# Check if just is installed
if ! command -v just &> /dev/null; then
    echo "Error: just is not installed"
    exit 1
fi

# Run linter
echo "→ Running linter..."
if ! just lint; then
    echo "✗ Linting failed. Commit aborted."
    exit 1
fi

# Run formatter check
echo "→ Checking code formatting..."
if ! just format-check; then
    echo "✗ Code is not formatted. Run 'just format' and try again."
    exit 1
fi

# Run tests
echo "→ Running tests..."
if ! just test; then
    echo "✗ Tests failed. Commit aborted."
    exit 1
fi

echo "✓ All checks passed!"
exit 0
```

**Pre-push hook:**

```bash
#!/usr/bin/env bash
# .git/hooks/pre-push

set -euo pipefail

echo "Running pre-push checks..."

# Run full test suite
echo "→ Running full test suite..."
if ! just test-all; then
    echo "✗ Tests failed. Push aborted."
    exit 1
fi

# Run security scan
echo "→ Running security scan..."
if ! just security-scan; then
    echo "✗ Security issues detected. Push aborted."
    exit 1
fi

# Check for secrets
echo "→ Checking for secrets..."
if ! just check-secrets; then
    echo "✗ Potential secrets detected. Push aborted."
    exit 1
fi

echo "✓ All checks passed!"
exit 0
```

**Setup git hooks with just:**

```just
# Install git hooks
hooks-install:
    #!/usr/bin/env bash
    set -euo pipefail

    HOOKS_DIR=".git/hooks"

    # Pre-commit hook
    cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
just lint && just format-check && just test
EOF

    # Pre-push hook
    cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
just test-all && just security-scan
EOF

    chmod +x "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/pre-push"

    echo "✓ Git hooks installed"

# Uninstall git hooks
hooks-uninstall:
    rm -f .git/hooks/pre-commit .git/hooks/pre-push
    @echo "✓ Git hooks removed"
```

---

### Pattern 5: Docker Integration

**Dockerfile with just:**

```dockerfile
# Dockerfile
FROM ubuntu:22.04

# Install just
RUN apt-get update && apt-get install -y wget && \
    wget -qO- https://github.com/casey/just/releases/download/1.16.0/just-1.16.0-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/just

# Install runtime dependencies
RUN apt-get install -y nodejs npm postgresql-client

WORKDIR /app

# Copy justfile first for caching
COPY justfile .

# Copy package files
COPY package*.json ./

# Install dependencies using just
RUN just install

# Copy application code
COPY . .

# Build application
RUN just build

# Run application
CMD ["just", "start"]
```

**docker-compose with just:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    command: just dev
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://user:password@db:5432/app_dev
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=app_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Just recipes for Docker:**

```just
# Docker development workflow

# Build Docker image
docker-build tag='latest':
    docker build -t myapp:{{tag}} .

# Run all services
docker-up:
    docker-compose up -d

# Stop all services
docker-down:
    docker-compose down

# View logs
docker-logs service='':
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{service}}" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f {{service}}
    fi

# Execute just commands inside container
docker-just *args:
    docker-compose exec app just {{args}}

# Run tests in Docker
docker-test:
    docker-compose exec app just test

# Database operations in Docker
docker-db-migrate:
    docker-compose exec app just db-migrate

docker-db-seed:
    docker-compose exec app just db-seed

# Clean Docker resources
docker-clean:
    docker-compose down -v
    docker system prune -f
```

---

## Justfile Patterns for CI/CD

### Pattern: CI-Specific Recipes

```just
# Detect if running in CI
is_ci := env_var_or_default("CI", "false")

# CI-friendly test output
test-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{is_ci}}" = "true" ]; then
        npm test -- --ci --coverage --maxWorkers=2
    else
        npm test
    fi

# CI-optimized install (no optional deps)
install-ci:
    npm ci --prefer-offline --no-audit

# Generate reports for CI
coverage-report:
    npm test -- --coverage --coverageReporters=lcov --coverageReporters=text-summary
```

### Pattern: Artifact Management

```just
# Package application for deployment
package version:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Packaging version {{version}}..."

    # Build
    just build

    # Create tarball
    tar czf "app-{{version}}.tar.gz" \
        dist/ \
        package.json \
        package-lock.json \
        --exclude="*.map"

    echo "✓ Package created: app-{{version}}.tar.gz"

# Generate build metadata
build-metadata:
    #!/usr/bin/env bash
    set -euo pipefail

    cat > dist/build-info.json << EOF
{
  "version": "$(git describe --tags --always)",
  "commit": "$(git rev-parse HEAD)",
  "branch": "$(git rev-parse --abbrev-ref HEAD)",
  "buildDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "buildNumber": "${BUILD_NUMBER:-local}"
}
EOF
```

### Pattern: Deployment Gates

```just
# Check if deployment is allowed
_check-deploy-ready:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "Error: Uncommitted changes detected"
        exit 1
    fi

    # Check if on correct branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$current_branch" != "main" ]; then
        echo "Error: Must deploy from 'main' branch"
        exit 1
    fi

    # Check if tests pass
    if ! just test; then
        echo "Error: Tests failed"
        exit 1
    fi

    echo "✓ Deployment checks passed"

# Safe deployment with gates
deploy: _check-deploy-ready build
    @echo "Deploying to production..."
    ./scripts/deploy.sh
```

---

## Scheduled Tasks

### Pattern: Cron-Style Recipes

```just
# Daily maintenance tasks
daily-maintenance:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running daily maintenance..."

    # Update dependencies
    npm update

    # Run security audit
    npm audit

    # Clean old logs
    find logs/ -name "*.log" -mtime +30 -delete

    # Backup database
    just db-backup

    echo "✓ Daily maintenance complete"

# Weekly cleanup
weekly-cleanup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running weekly cleanup..."

    # Clean Docker images
    docker image prune -af --filter "until=168h"

    # Clean npm cache
    npm cache clean --force

    # Archive old backups
    just backup-archive

    echo "✓ Weekly cleanup complete"
```

**GitHub Actions for scheduled tasks:**

```yaml
# .github/workflows/scheduled.yml
name: Scheduled Maintenance

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:  # Manual trigger

jobs:
  maintenance:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install just
        uses: extractions/setup-just@v1

      - name: Run daily maintenance
        run: just daily-maintenance
```

---

## Notification Integration

### Pattern: Slack Notifications

```just
# Send Slack notification
_notify-slack channel message:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        echo "Warning: SLACK_WEBHOOK_URL not set, skipping notification"
        exit 0
    fi

    curl -X POST "${SLACK_WEBHOOK_URL}" \
        -H 'Content-Type: application/json' \
        -d "{\"channel\": \"{{channel}}\", \"text\": \"{{message}}\"}"

# Deploy with notifications
deploy-notify:
    just _notify-slack "#deployments" "🚀 Starting deployment..."
    just deploy
    just _notify-slack "#deployments" "✅ Deployment complete!"
```

---

## Best Practices for CI/CD Integration

1. **Always install specific just version**:
   ```yaml
   - uses: extractions/setup-just@v1
     with:
       just-version: 1.16.0
   ```

2. **Cache dependencies**:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.cache/pip
       key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
   ```

3. **Use environment variables for secrets**:
   ```just
   deploy:
       #!/usr/bin/env bash
       set -euo pipefail
       if [ -z "${DEPLOY_KEY:-}" ]; then
           echo "Error: DEPLOY_KEY not set"
           exit 1
       fi
       ./deploy.sh
   ```

4. **Fail fast with `set -euo pipefail`**:
   ```just
   test:
       #!/usr/bin/env bash
       set -euo pipefail  # Always use in CI
       npm test
   ```

5. **Generate machine-readable output**:
   ```just
   test-ci:
       npm test -- --ci --json --outputFile=test-results.json
   ```

---

## Troubleshooting CI/CD

### Issue 1: Just not found in CI

**Solution**: Install just in CI pipeline

```yaml
# GitHub Actions
- name: Install just
  run: |
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
```

### Issue 2: Permission denied in CI

**Solution**: Fix file permissions

```just
# Ensure scripts are executable
_fix-permissions:
    chmod +x scripts/*.sh
    chmod +x .git/hooks/*
```

### Issue 3: Environment variables not set

**Solution**: Use defaults and validation

```just
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    : "${DEPLOY_KEY:?Error: DEPLOY_KEY not set}"
    : "${DEPLOY_ENV:?Error: DEPLOY_ENV not set}"

    ./deploy.sh
```

---

**Last Updated**: 2025-12-11
