# Just Script Preferences Template

> **Purpose**: Customize just script generation to match your project's specific requirements.
> **Instructions**: Copy this file, fill in relevant sections, and compose with base prompt templates.

---

## Project Context

**Project name**: _______________

**Project type** (check all that apply):
- [ ] Web application (specify framework: _______________)
- [ ] CLI tool
- [ ] Library/package
- [ ] Microservices/monorepo
- [ ] Data pipeline/ETL
- [ ] Infrastructure/DevOps
- [ ] Static site generator
- [ ] Mobile app backend
- [ ] Game server
- [ ] IoT/embedded system
- [ ] Other: _______________

**Primary programming language(s)**:
- [ ] JavaScript/TypeScript (Node.js)
- [ ] Python
- [ ] Go
- [ ] Rust
- [ ] Ruby
- [ ] Java/Kotlin
- [ ] C#/.NET
- [ ] PHP
- [ ] Other: _______________

**Build tool/package manager**:
- [ ] npm
- [ ] yarn
- [ ] pnpm
- [ ] pip
- [ ] poetry
- [ ] cargo
- [ ] go modules
- [ ] maven/gradle
- [ ] Other: _______________

**Database(s)**:
- [ ] PostgreSQL (version: _______)
- [ ] MySQL/MariaDB (version: _______)
- [ ] SQLite
- [ ] MongoDB
- [ ] Redis
- [ ] Elasticsearch
- [ ] None
- [ ] Other: _______________

**Caching layer**:
- [ ] Redis
- [ ] Memcached
- [ ] Application-level caching
- [ ] CDN (CloudFront, Cloudflare, etc.)
- [ ] None
- [ ] Other: _______________

**Message queue/event bus**:
- [ ] RabbitMQ
- [ ] Apache Kafka
- [ ] AWS SQS/SNS
- [ ] Redis Pub/Sub
- [ ] None
- [ ] Other: _______________

**Deployment target**:
- [ ] Docker containers
- [ ] Kubernetes
- [ ] AWS (specify services: _______________)
- [ ] Google Cloud Platform (specify services: _______________)
- [ ] Azure (specify services: _______________)
- [ ] Heroku
- [ ] Vercel/Netlify
- [ ] Bare metal/VPS
- [ ] Other: _______________

---

## Required Recipes

### Development Workflows

- [ ] `dev` - Start development server
- [ ] `dev-debug` - Start server with debugger
- [ ] `dev-docker` - Start via Docker Compose
- [ ] `install` - Install dependencies
- [ ] `update` - Update dependencies
- [ ] `clean` - Clean build artifacts
- [ ] `reset` - Full reset (clean + reinstall)
- [ ] Other: _______________

### Testing

- [ ] `test` - Run all tests
- [ ] `test-unit` - Unit tests only
- [ ] `test-integration` - Integration tests
- [ ] `test-e2e` - End-to-end tests
- [ ] `test-watch` - Watch mode
- [ ] `test-coverage` - Coverage report
- [ ] `test-ci` - CI-optimized tests
- [ ] Other: _______________

### Code Quality

- [ ] `lint` - Run linter
- [ ] `lint-fix` - Auto-fix linting issues
- [ ] `format` - Format code
- [ ] `format-check` - Check formatting
- [ ] `type-check` - Type checking (TypeScript, mypy, etc.)
- [ ] `security-scan` - Vulnerability scanning
- [ ] Other: _______________

### Build

- [ ] `build` - Production build
- [ ] `build-dev` - Development build
- [ ] `build-docker` - Build Docker image
- [ ] `build-assets` - Build static assets
- [ ] `analyze-bundle` - Bundle analysis
- [ ] Other: _______________

### Database Operations

- [ ] `db-create` - Create database
- [ ] `db-drop` - Drop database
- [ ] `db-migrate` - Run migrations
- [ ] `db-rollback` - Rollback migration
- [ ] `db-seed` - Seed database
- [ ] `db-reset` - Drop, create, migrate, seed
- [ ] `db-backup` - Create backup
- [ ] `db-restore` - Restore from backup
- [ ] `db-console` - Open database console
- [ ] Other: _______________

### Docker Operations

- [ ] `docker-build` - Build image
- [ ] `docker-up` - Start containers
- [ ] `docker-down` - Stop containers
- [ ] `docker-logs` - View logs
- [ ] `docker-shell` - Open shell in container
- [ ] `docker-rebuild` - Rebuild and restart
- [ ] `docker-clean` - Clean Docker resources
- [ ] Other: _______________

### Deployment

- [ ] `deploy` - Deploy to production
- [ ] `deploy-staging` - Deploy to staging
- [ ] `deploy-dev` - Deploy to development
- [ ] `rollback` - Rollback deployment
- [ ] `status` - Check deployment status
- [ ] Other: _______________

### Monitoring & Debugging

- [ ] `logs` - View application logs
- [ ] `logs-follow` - Tail logs
- [ ] `logs-error` - Error logs only
- [ ] `metrics` - View metrics
- [ ] `health-check` - Run health checks
- [ ] Other: _______________

### Documentation

- [ ] `docs-generate` - Generate documentation
- [ ] `docs-serve` - Serve docs locally
- [ ] `docs-deploy` - Deploy documentation
- [ ] Other: _______________

### Custom Recipes

List any project-specific recipes needed:

1. _______________: _______________
2. _______________: _______________
3. _______________: _______________

---

## Coding Standards

### Shell Configuration

**Shell preference**:
- [ ] bash (recommended)
- [ ] sh (POSIX)
- [ ] zsh
- [ ] fish
- [ ] Other: _______________

**Reason for choice**: _______________

**Error handling pattern**:
- [ ] `set -euo pipefail` (standard)
- [ ] `set -euxo pipefail` (with debug)
- [ ] Custom pattern: _______________

### Variable Conventions

**Naming style**:
- [ ] lowercase_with_underscores (recommended)
- [ ] UPPER_CASE_FOR_EXPORTS
- [ ] camelCase
- [ ] Custom: _______________

**Environment variables**:
- [ ] Use `env_var_or_default()` function
- [ ] Require all variables to be set
- [ ] Custom validation: _______________

### Recipe Conventions

**Recipe naming**:
- [ ] lowercase-with-dashes (recommended)
- [ ] snake_case
- [ ] verb-noun format (build-frontend, test-api)
- [ ] Custom: _______________

**Default recipe behavior**:
- [ ] Show recipe list (`just --list`)
- [ ] Run most common workflow (e.g., `dev`)
- [ ] Show custom help message
- [ ] Custom: _______________

**Helper recipes**:
- [ ] Prefix with underscore (`_helper`)
- [ ] Separate file (include mechanism)
- [ ] Custom: _______________

### Documentation Style

**Recipe comments**:
- [ ] Above recipe with single # (recommended)
- [ ] Inline with recipe definition
- [ ] Separate documentation file
- [ ] Custom: _______________

**Comment format**:
```just
# [Your preferred format here]
recipe-name:
    command
```

### Output Style

**Logging format**:
- [ ] Plain text
- [ ] Structured JSON
- [ ] Colored output with emojis
- [ ] Custom: _______________

**Progress indicators**:
- [ ] Simple echo statements
- [ ] Spinners/progress bars
- [ ] None
- [ ] Custom: _______________

---

## Security Requirements

### Secrets Management

**Credential storage method**:
- [ ] Environment variables only
- [ ] .env files (with .gitignore)
- [ ] AWS Secrets Manager
- [ ] HashiCorp Vault
- [ ] GCP Secret Manager
- [ ] Azure Key Vault
- [ ] 1Password/LastPass CLI
- [ ] Other: _______________

**Secret validation**:
- [ ] Check required secrets at recipe start
- [ ] Fail fast if secrets missing
- [ ] Provide clear error messages
- [ ] Custom: _______________

### File Permissions

**Script permissions**: _______________

**Credential file permissions**: _______________

**Other file permission requirements**: _______________

### Access Control

**Deployment authorization**:
- [ ] Any team member can deploy
- [ ] Specific users only (list: _______________)
- [ ] Role-based (roles: _______________)
- [ ] Other: _______________

### Audit Logging

**Logging requirements**:
- [ ] Log all deployments
- [ ] Log all destructive operations
- [ ] Log all production access
- [ ] Log destination: _______________
- [ ] Other: _______________

### Input Validation

**Validation requirements**:
- [ ] Validate all recipe parameters
- [ ] Whitelist allowed environments
- [ ] Validate file paths
- [ ] Other: _______________

---

## CI/CD Integration

### Platform

**CI/CD platform(s)**:
- [ ] GitHub Actions
- [ ] GitLab CI
- [ ] Jenkins
- [ ] CircleCI
- [ ] Travis CI
- [ ] Drone CI
- [ ] Bitbucket Pipelines
- [ ] Azure Pipelines
- [ ] Other: _______________

### Runner Environment

**Operating system**:
- [ ] Ubuntu (version: _______)
- [ ] macOS
- [ ] Windows (WSL)
- [ ] Docker container
- [ ] Custom: _______________

**Runner type**:
- [ ] Cloud-hosted (GitHub, GitLab)
- [ ] Self-hosted
- [ ] Hybrid
- [ ] Custom: _______________

### Trigger Configuration

**Build triggers**:
- [ ] Push to main/master
- [ ] Push to any branch
- [ ] Pull requests
- [ ] Tags
- [ ] Scheduled (cron: _______________)
- [ ] Manual dispatch
- [ ] Other: _______________

### Caching Strategy

**Cache configuration**:
- [ ] npm/yarn cache
- [ ] pip cache
- [ ] Docker layer cache
- [ ] Build artifact cache
- [ ] Custom: _______________

**Cache location**: _______________

### Artifact Management

**Artifact storage**:
- [ ] GitHub Artifacts
- [ ] GitLab Artifacts
- [ ] S3/GCS/Azure Blob
- [ ] Artifactory/Nexus
- [ ] Custom: _______________

**Artifact retention**: _______________ days

### Notification Preferences

**Notification channels**:
- [ ] Slack (channel: _______________)
- [ ] Email (recipients: _______________)
- [ ] Microsoft Teams
- [ ] Discord
- [ ] PagerDuty
- [ ] Other: _______________

**Notify on**:
- [ ] All builds
- [ ] Failures only
- [ ] Deployments only
- [ ] Custom: _______________

---

## Team Conventions

### Workflow Patterns

**Development workflow**:
```
Describe your team's typical development workflow here:
1. _______________
2. _______________
3. _______________
```

**Review process**:
```
Describe code review requirements:
- _______________
- _______________
```

**Deployment process**:
```
Describe deployment procedures:
1. _______________
2. _______________
3. _______________
```

### Communication

**Documentation location**: _______________

**Support channels**:
- [ ] Slack: _______________
- [ ] Wiki: _______________
- [ ] Confluence: _______________
- [ ] Other: _______________

### Responsibilities

**Recipe ownership**:
```
Who maintains which recipes:
- Development recipes: _______________
- Deployment recipes: _______________
- Database recipes: _______________
```

---

## Performance Requirements

### Build Performance

**Build time targets**:
- Development build: _______________ seconds
- Production build: _______________ minutes
- Test suite: _______________ minutes

**Optimization requirements**:
- [ ] Parallel execution where possible
- [ ] Incremental builds
- [ ] Caching strategies
- [ ] Other: _______________

### Resource Constraints

**Memory limits**: _______________

**CPU limits**: _______________

**Disk space limits**: _______________

---

## Exclusions

**Features to explicitly exclude**:

- [ ] Database recipes (no database used)
- [ ] Docker recipes (not using containers)
- [ ] Deployment recipes (handled by external system)
- [ ] Testing recipes (tests in separate tool)
- [ ] Other: _______________

**Justification**: _______________

---

## Examples

### Expected Recipe Format

**Provide an example of how you want recipes formatted**:

```just
# [Example recipe]
recipe-name param1 param2='default':
    #!/usr/bin/env bash
    set -euo pipefail

    # Your implementation style here
    echo "Processing {{param1}} with {{param2}}"
```

### Expected Variable Definition

```just
# [Example variables]
export VAR_NAME := env_var_or_default("VAR_NAME", "default_value")
```

### Expected Error Handling

```just
# [Example error handling]
recipe-with-validation input:
    #!/usr/bin/env bash
    set -euo pipefail

    # Your validation pattern here
```

### Expected Documentation

```just
# [Example documentation style]
# Recipe description here
# Usage: just recipe-name <param>
# Example: just recipe-name value
recipe-name param:
    command
```

---

## Additional Requirements

### Backwards Compatibility

**Version support**: _______________

**Migration path**: _______________

### Internationalization

**Language support**: _______________

**Message localization**: _______________

### Compliance

**Regulatory requirements**: _______________

**Audit requirements**: _______________

---

## Notes

**Additional context or requirements**:

_______________

_______________

_______________

---

## Metadata

**Created**: YYYY-MM-DD

**Last Updated**: YYYY-MM-DD

**Author**: _______________

**Reviewers**: _______________

**Next Review Date**: YYYY-MM-DD

---

**Instructions for AI**:

When generating justfiles, prioritize the preferences specified in this document over default patterns in the base prompt template. Where preferences conflict with base recommendations, always follow the preferences. If any preference is unclear, ask for clarification before proceeding.

For any section marked "Custom:" or filled with specific requirements, adapt the output to match exactly what is specified, even if it differs from standard best practices.

---

**Last Updated**: 2025-12-11
