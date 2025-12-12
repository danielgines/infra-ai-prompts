# CI/CD-Optimized Project Preferences

> **Base Prompt**: Just_Script_Generation_Instructions.md
> **Last Updated**: 2025-12-11
> **Project**: Enterprise Node.js API with comprehensive CI/CD pipeline

---

## Project Context

**Project name**: Enterprise API Gateway

**Project type**:
- [x] Web application (Node.js + Express + TypeScript)
- [x] Microservices architecture (12 services)
- [x] Infrastructure/DevOps

**Primary programming language(s)**:
- [x] TypeScript (Node.js 20 LTS)

**Build tool/package manager**:
- [x] npm (with package-lock.json)

**Database(s)**:
- [x] PostgreSQL (version: 15.3)
- [x] Redis (version: 7.0) - for caching and session storage

**Caching layer**:
- [x] Redis
- [x] CloudFront CDN for static assets

**Message queue/event bus**:
- [x] AWS SQS/SNS for async processing
- [x] Redis Pub/Sub for real-time updates

**Deployment target**:
- [x] Docker containers on AWS ECS Fargate
- [x] RDS for PostgreSQL
- [x] ElastiCache for Redis

---

## Required Recipes

### Development Workflows

- [x] `dev` - Start development server with hot reload
- [x] `dev-debug` - Start server with Node debugger on port 9229
- [x] `dev-docker` - Start via Docker Compose (matches prod environment)
- [x] `install` - Install dependencies with npm ci
- [x] `update` - Update dependencies (npm update)
- [x] `clean` - Clean build artifacts and node_modules
- [x] `reset` - Full reset (clean + reinstall)

### Testing

- [x] `test` - Run all tests
- [x] `test-unit` - Unit tests only (Jest)
- [x] `test-integration` - Integration tests (Supertest)
- [x] `test-e2e` - End-to-end tests (Playwright)
- [x] `test-watch` - Watch mode for development
- [x] `test-coverage` - Coverage report (must be >80%)
- [x] `test-ci` - CI-optimized tests (parallel, no watch, coverage)

### Code Quality

- [x] `lint` - Run ESLint
- [x] `lint-fix` - Auto-fix linting issues
- [x] `format` - Format code with Prettier
- [x] `format-check` - Check formatting without modifying
- [x] `type-check` - TypeScript type checking
- [x] `security-scan` - npm audit + Snyk scanning

### Build

- [x] `build` - Production build (TypeScript → JavaScript)
- [x] `build-docker` - Build Docker image with caching
- [x] `analyze-bundle` - Webpack bundle analyzer

### Database Operations

- [x] `db-create` - Create database
- [x] `db-drop` - Drop database (requires confirmation)
- [x] `db-migrate` - Run migrations (Prisma)
- [x] `db-rollback` - Rollback last migration
- [x] `db-seed` - Seed database
- [x] `db-reset` - Drop, create, migrate, seed (dev only)
- [x] `db-backup` - Create backup to S3
- [x] `db-restore` - Restore from S3 backup

### Docker Operations

- [x] `docker-build` - Build image with build args
- [x] `docker-up` - Start all services
- [x] `docker-down` - Stop all services
- [x] `docker-logs` - View logs (all or specific service)
- [x] `docker-shell` - Open bash in API container
- [x] `docker-rebuild` - Rebuild and restart
- [x] `docker-clean` - Prune images, containers, volumes

### Deployment

- [x] `deploy` - Deploy to production (requires approval)
- [x] `deploy-staging` - Deploy to staging environment
- [x] `rollback` - Rollback to previous version
- [x] `status` - Check deployment status (ECS task health)

### Monitoring & Debugging

- [x] `logs` - View CloudWatch logs
- [x] `logs-follow` - Tail CloudWatch logs
- [x] `logs-error` - Error logs only
- [x] `metrics` - View CloudWatch metrics
- [x] `health-check` - Run health checks against running service

### Custom Recipes

1. `ci-prepare`: Prepare CI environment (install just, setup AWS CLI)
2. `ci-validate`: Run all validation (lint, type-check, format-check)
3. `ci-test`: Run all tests with coverage and reporting
4. `ci-build`: Build and tag Docker image for CI
5. `ci-deploy`: Deploy to environment based on branch
6. `notify-slack`: Send deployment notification to Slack

---

## Coding Standards

### Shell Configuration

**Shell preference**:
- [x] bash (standard across all environments)

**Reason for choice**: Consistency across Ubuntu-based CI runners and ECS containers

**Error handling pattern**:
- [x] `set -euxo pipefail` (with debug flag for CI visibility)

### Variable Conventions

**Naming style**:
- [x] UPPER_CASE_FOR_EXPORTS (environment variables)
- [x] lowercase_with_underscores (local variables in recipes)

**Environment variables**:
- [x] Use `env_var_or_default()` with validation
- [x] All secrets from AWS Secrets Manager (no .env in production)

### Recipe Conventions

**Recipe naming**:
- [x] verb-noun format (build-docker, test-unit, deploy-staging)

**Default recipe behavior**:
- [x] Show custom help message with common workflows

**Helper recipes**:
- [x] Prefix with underscore (`_helper`)
- [x] All helpers validate prerequisites

### Documentation Style

**Recipe comments**:
- [x] Above recipe with detailed description
- [x] Include usage examples for complex recipes

**Comment format**:
```just
# Deploy to specified environment
# Usage: just deploy-env <environment> <version>
# Example: just deploy-env staging v1.2.3
# Prerequisites: AWS credentials configured, Docker image pushed
deploy-env environment version:
    #!/usr/bin/env bash
    set -euxo pipefail
    # implementation
```

### Output Style

**Logging format**:
- [x] Structured JSON for CI parsing
- [x] Human-readable with timestamps for local development

**Progress indicators**:
- [x] Clear step markers (→ Running tests..., ✓ Tests passed)

---

## Security Requirements

### Secrets Management

**Credential storage method**:
- [x] AWS Secrets Manager (production)
- [x] .env files (local development only, .gitignore'd)

**Required secrets**:
- `DATABASE_URL` - RDS connection string
- `REDIS_URL` - ElastiCache connection string
- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `SLACK_WEBHOOK_URL` - Slack notifications
- `GITHUB_TOKEN` - For GitHub API access
- `SNYK_TOKEN` - For security scanning

**Secret validation**:
- [x] Check all required secrets at start of deploy recipes
- [x] Fail fast with clear error messages
- [x] Never log secret values

### File Permissions

**Script permissions**: 700 (owner read/write/execute only)

**Credential file permissions**: 600 (.env files owner read/write only)

**Deployment key permissions**: 400 (read-only)

### Access Control

**Deployment authorization**:
- [x] Specific users only
- [x] Allowed deployers: devops-team, lead-engineer, on-call-engineer
- [x] All deployments logged to CloudWatch + Slack

### Audit Logging

**Logging requirements**:
- [x] Log all deployments (who, when, what, where)
- [x] Log all database operations in production
- [x] Log all secret access
- [x] Log destination: CloudWatch Logs (retention: 90 days)

**Log format**:
```json
{
  "timestamp": "2025-12-11T10:30:00Z",
  "action": "deploy",
  "user": "john.doe",
  "environment": "production",
  "version": "v1.2.3",
  "result": "success"
}
```

### Input Validation

**Validation requirements**:
- [x] Whitelist allowed environments (dev, staging, production)
- [x] Validate version format (semantic versioning: v1.2.3)
- [x] Validate branch names match environment rules
- [x] Validate Docker image exists before deploying

---

## CI/CD Integration

### Platform

**CI/CD platform(s)**:
- [x] GitHub Actions (primary)
- [x] Self-hosted runners for sensitive operations

### Runner Environment

**Operating system**:
- [x] Ubuntu 22.04 LTS

**Runner type**:
- [x] Self-hosted (for production deployments)
- [x] GitHub-hosted (for PR checks and staging)

**Runner requirements**:
- Docker 24+
- AWS CLI v2
- Node.js 20 LTS
- just 1.16+
- PostgreSQL client 15
- 4 CPU cores, 8GB RAM minimum

### Trigger Configuration

**Build triggers**:
- [x] Push to main → Deploy to staging automatically
- [x] Push to production → Deploy to production (requires approval)
- [x] Pull requests → Run tests and validation
- [x] Tags matching v* → Create GitHub release
- [x] Scheduled (cron: 0 2 * * *) → Nightly security scans

### Caching Strategy

**Cache configuration**:
- [x] npm cache (~/.npm)
- [x] Docker layer cache (GitHub Actions cache)
- [x] TypeScript build cache (.tsbuildinfo)

**Cache keys**:
```yaml
npm-${{ runner.os }}-${{ hashFiles('package-lock.json') }}
docker-${{ runner.os }}-${{ hashFiles('Dockerfile', 'package-lock.json') }}
```

### Artifact Management

**Artifact storage**:
- [x] Docker images → AWS ECR
- [x] Build artifacts → S3 (s3://artifacts-bucket/builds/)
- [x] Test reports → S3 (s3://artifacts-bucket/reports/)

**Artifact retention**:
- Docker images: Last 30 versions
- Build artifacts: 90 days
- Test reports: 365 days

**Naming convention**:
- Docker: `{account}.dkr.ecr.{region}.amazonaws.com/api-gateway:{version}-{sha}`
- Artifacts: `api-gateway-{version}-{timestamp}.tar.gz`

### Notification Preferences

**Notification channels**:
- [x] Slack (channel: #deployments)
- [x] Email (on failures only): devops@company.com

**Notify on**:
- [x] Production deployments (always)
- [x] Staging deployments (always)
- [x] Test failures on main branch
- [x] Security vulnerabilities detected

**Notification format**:
```
🚀 Deployment to production
Version: v1.2.3
Deployer: @john.doe
Status: ✅ Success
Duration: 5m 32s
Link: https://github.com/org/repo/actions/runs/12345
```

---

## Team Conventions

### Workflow Patterns

**Development workflow**:
```
1. Create feature branch from main
2. Run `just dev` to start development server
3. Make changes with hot reload
4. Run `just test-watch` in separate terminal
5. Before commit: `just ci-validate` (lint, format, type-check)
6. Git hooks run `just test-unit` on pre-push
7. Push to GitHub → PR checks run automatically
8. After PR approval and merge → Auto-deploy to staging
9. Manual approval required for production deployment
```

**Review process**:
```
- All PRs require 2 approvals
- CI checks must pass (test-ci, lint, type-check, security-scan)
- Coverage must not decrease
- No merge if Snyk finds high/critical vulnerabilities
- Deployment recipes reviewed by DevOps team only
```

**Deployment process**:
```
1. Ensure all tests pass: `just ci-test`
2. Build Docker image: `just ci-build`
3. Push to ECR (automated by CI)
4. Deploy to staging: `just deploy-staging`
5. Run smoke tests against staging
6. Get approval from team lead
7. Deploy to production: `just deploy` (creates git tag)
8. Monitor metrics and logs for 15 minutes
9. Rollback if issues detected: `just rollback`
```

### Communication

**Documentation location**: Confluence (https://wiki.company.com/api-gateway)

**Support channels**:
- [x] Slack: #api-gateway-dev (development questions)
- [x] Slack: #api-gateway-ops (deployment/production issues)
- [x] PagerDuty: On-call rotation for production incidents

### Responsibilities

**Recipe ownership**:
```
- Development recipes (dev, test): Backend team
- Deployment recipes (deploy, rollback): DevOps team
- Database recipes (db-migrate, db-backup): Database team
- CI recipes (ci-*): CI/CD team

All changes to deployment recipes require DevOps review
```

---

## Performance Requirements

### Build Performance

**Build time targets**:
- TypeScript compilation: < 30 seconds
- Docker image build: < 3 minutes
- Full CI pipeline: < 10 minutes
- Deployment: < 5 minutes

**Optimization requirements**:
- [x] Parallel test execution (Jest --maxWorkers=4)
- [x] Incremental TypeScript builds (tsc --incremental)
- [x] Docker layer caching
- [x] npm ci instead of npm install

### Resource Constraints

**Memory limits**:
- Development: 2GB
- CI runners: 4GB
- Production containers: 1GB per task

**CPU limits**:
- Development: No limit
- CI runners: 2 cores
- Production containers: 0.5 vCPU per task

**Disk space limits**:
- CI runners: 50GB (clean after each run)
- Build artifacts: Max 500MB per build

---

## Exclusions

**Features to explicitly exclude**:

- [ ] Kubernetes recipes (using ECS Fargate, not K8s)
- [ ] Frontend build recipes (separate frontend repo)
- [ ] Mobile app deployment (separate mobile repo)

---

## Examples

### Expected Recipe Format

```just
# Deploy to specified environment with health checks
# Usage: just deploy-env <environment> <version>
# Example: just deploy-env production v1.2.3
# Prerequisites: AWS credentials, Docker image in ECR
deploy-env environment version: (_validate-env environment) (_validate-version version)
    #!/usr/bin/env bash
    set -euxo pipefail

    echo "→ Deploying {{version}} to {{environment}}..."

    # Fetch secrets from AWS Secrets Manager
    export DATABASE_URL=$(aws secretsmanager get-secret-value \
        --secret-id "{{environment}}/database-url" \
        --query SecretString --output text)

    # Update ECS service
    aws ecs update-service \
        --cluster "api-gateway-{{environment}}" \
        --service "api-gateway" \
        --force-new-deployment \
        --task-definition "api-gateway:{{version}}"

    # Wait for deployment to complete
    aws ecs wait services-stable \
        --cluster "api-gateway-{{environment}}" \
        --services "api-gateway"

    # Run health check
    just health-check "{{environment}}"

    # Log deployment
    just _log-deployment "{{environment}}" "{{version}}" "$(whoami)"

    # Notify Slack
    just notify-slack "✅ Deployed {{version}} to {{environment}}"

    echo "✓ Deployment complete"
```

### Expected Variable Definition

```just
# Environment configuration
export AWS_REGION := env_var_or_default("AWS_REGION", "us-east-1")
export NODE_ENV := env_var_or_default("NODE_ENV", "development")

# CI/CD configuration
ci := env_var_or_default("CI", "false")
github_actor := env_var_or_default("GITHUB_ACTOR", "unknown")

# Slack webhook for notifications
slack_webhook := env_var_or_default("SLACK_WEBHOOK_URL", "")
```

### Expected Error Handling

```just
# Validate environment is allowed
_validate-env environment:
    #!/usr/bin/env bash
    set -euo pipefail

    allowed_envs=("dev" "staging" "production")

    if [[ ! " ${allowed_envs[@]} " =~ " {{environment}} " ]]; then
        echo "Error: Invalid environment '{{environment}}'"
        echo "Allowed environments: ${allowed_envs[@]}"
        exit 1
    fi

# Validate version follows semantic versioning
_validate-version version:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! echo "{{version}}" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "Error: Invalid version format '{{version}}'"
        echo "Expected format: v1.2.3 (semantic versioning)"
        exit 1
    fi
```

### Expected Documentation

```just
# Run all CI validation checks
# This recipe is used in GitHub Actions to validate PRs
# Includes: linting, formatting, type checking, security scanning
# Exit code: 0 if all checks pass, 1 if any check fails
ci-validate:
    #!/usr/bin/env bash
    set -euxo pipefail

    echo "→ Running linter..."
    just lint

    echo "→ Checking code formatting..."
    just format-check

    echo "→ Running type checker..."
    just type-check

    echo "→ Running security scan..."
    just security-scan

    echo "✓ All validation checks passed"
```

---

## CI Recipe Patterns

### GitHub Actions Optimized Recipes

```just
# Prepare CI environment (run once per job)
ci-prepare:
    #!/usr/bin/env bash
    set -euxo pipefail

    echo "→ Installing just..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | \
        bash -s -- --to /usr/local/bin

    echo "→ Configuring AWS CLI..."
    aws configure set region ${AWS_REGION}
    aws configure set output json

    echo "→ Logging into ECR..."
    aws ecr get-login-password --region ${AWS_REGION} | \
        docker login --username AWS --password-stdin ${ECR_REGISTRY}

    echo "✓ CI environment ready"

# Build Docker image with CI optimizations
ci-build:
    #!/usr/bin/env bash
    set -euxo pipefail

    VERSION=$(git describe --tags --always --dirty)
    SHA=$(git rev-parse --short HEAD)
    IMAGE_TAG="${VERSION}-${SHA}"

    echo "→ Building Docker image: ${IMAGE_TAG}..."

    docker build \
        --cache-from ${ECR_REGISTRY}/api-gateway:latest \
        --build-arg NODE_ENV=production \
        --build-arg VERSION=${VERSION} \
        --tag ${ECR_REGISTRY}/api-gateway:${IMAGE_TAG} \
        --tag ${ECR_REGISTRY}/api-gateway:latest \
        .

    echo "→ Pushing to ECR..."
    docker push ${ECR_REGISTRY}/api-gateway:${IMAGE_TAG}
    docker push ${ECR_REGISTRY}/api-gateway:latest

    echo "✓ Image built and pushed: ${IMAGE_TAG}"

# Run tests with CI-specific settings
ci-test:
    #!/usr/bin/env bash
    set -euxo pipefail

    echo "→ Running tests..."

    npm test -- \
        --ci \
        --coverage \
        --maxWorkers=4 \
        --reporters=default \
        --reporters=jest-junit

    echo "→ Checking coverage thresholds..."

    # Fail if coverage below 80%
    coverage_percent=$(cat coverage/coverage-summary.json | \
        jq '.total.lines.pct')

    if (( $(echo "$coverage_percent < 80" | bc -l) )); then
        echo "Error: Coverage ${coverage_percent}% is below 80%"
        exit 1
    fi

    echo "✓ Tests passed with ${coverage_percent}% coverage"
```

---

## Additional Requirements

### Monitoring Integration

**CloudWatch metrics to track**:
- Deployment success/failure rate
- Deployment duration
- Test execution time
- Build time
- API response time (post-deployment)
- Error rate (post-deployment)

**Alerts**:
- Deployment failure → PagerDuty
- Coverage drop >5% → Slack #api-gateway-dev
- High severity vulnerability → Slack #security

### Rollback Procedures

**Automatic rollback triggers**:
- Health check fails 3 times in 5 minutes
- Error rate >1% for 5 minutes
- Response time >2s for 5 minutes

**Manual rollback**:
```bash
# Find previous version
just status production

# Rollback to previous version
just rollback production

# Verify rollback
just health-check production
```

---

## Notes

**Important considerations**:

1. All CI recipes must use `set -euxo pipefail` for maximum visibility in logs
2. Docker builds must be reproducible (pin all base image tags)
3. Never deploy on Fridays after 2pm (wait until Monday)
4. Production deployments require approval from 2 people
5. Database migrations must be backwards compatible (blue-green deployment)

**Future enhancements**:
- Add canary deployments with gradual traffic shifting
- Implement automatic rollback based on metrics
- Add performance benchmarking to CI pipeline

---

## Metadata

**Created**: 2025-12-11
**Last Updated**: 2025-12-11
**Author**: DevOps Team
**Reviewers**: @john.doe, @jane.smith
**Next Review Date**: 2026-01-11

---

**Last Updated**: 2025-12-11
