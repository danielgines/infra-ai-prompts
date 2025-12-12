# Just Preferences System

> **Purpose**: Customize just script generation without modifying base prompt templates.

---

## Overview

The preferences system allows you to **override or extend default behavior** when generating justfiles. Preferences are composed with base prompts to produce customized outputs.

**Key principle**: Base prompts remain unchanged; all customization happens in preference files.

---

## How It Works

### Step 1: Choose a Base Prompt

Start with a base instruction file:
- `Just_Script_Generation_Instructions.md` - Generate new justfiles
- `Just_Script_Review_Instructions.md` - Review existing justfiles
- `Just_Script_Debugging_Instructions.md` - Debug failing recipes

### Step 2: Create Your Preferences

Copy `preferences_template.md` and fill in your customizations:

```bash
cp preferences_template.md my_project_preferences.md
# Edit my_project_preferences.md
```

### Step 3: Compose and Use

Combine the base prompt with your preferences:

```bash
cat Just_Script_Generation_Instructions.md \
    preferences/my_project_preferences.md > combined_prompt.txt
```

Then paste `combined_prompt.txt` into your AI assistant.

---

## What Can Be Customized?

### 1. Project Context

Override default project detection:

```markdown
## Project Context

**Project type**: Node.js web application with Next.js framework
**Build tool**: npm (Node 20+)
**Database**: PostgreSQL 15
**Cache**: Redis
**Deployment**: Docker on AWS ECS
```

### 2. Required Recipes

Specify which recipes to generate:

```markdown
## Required Recipes

- [x] Development server with hot reload
- [x] Test suite (Jest + Playwright)
- [x] Database migrations (Prisma)
- [x] Docker build and deployment
- [ ] Kubernetes deployment (not needed)
```

### 3. Coding Standards

Enforce project-specific patterns:

```markdown
## Coding Standards

**Shell**: bash only (no sh, zsh, fish)
**Error handling**: Always use `set -euxo pipefail` (include -x for debugging)
**Logging**: Use structured JSON logs, not plain text
**Variables**: All caps for exports (DATABASE_URL), lowercase for locals
```

### 4. Security Requirements

Add security constraints:

```markdown
## Security Requirements

**Secrets management**: AWS Secrets Manager (no .env files)
**Credentials**: All credentials fetched at runtime, never stored
**Permissions**: All scripts must be 700, credential files 600
**Audit logging**: All deployments logged to CloudWatch
```

### 5. CI/CD Integration

Specify automation needs:

```markdown
## CI/CD Integration

**Platform**: GitHub Actions
**Runners**: Ubuntu 22.04 (self-hosted)
**Caching**: npm packages cached in GitHub cache
**Artifacts**: Stored in S3, not GitHub artifacts
```

### 6. Team Conventions

Document team-specific patterns:

```markdown
## Team Conventions

**Recipe naming**: Use verb-noun format (build-frontend, test-api)
**Documentation**: Every recipe must have usage examples
**Testing**: All recipes must have `--dry-run` support
**Notifications**: Post to #deployments Slack channel on deploy
```

---

## Preference File Structure

All preference files should follow this template:

```markdown
# Project Name Preferences

> **Base Prompt**: Just_Script_Generation_Instructions.md
> **Last Updated**: YYYY-MM-DD

## Project Context
[Project-specific information]

## Required Recipes
[Checkboxes for needed recipes]

## Coding Standards
[Overrides for default patterns]

## Security Requirements
[Additional security constraints]

## CI/CD Integration
[Automation platform details]

## Team Conventions
[Team-specific patterns]

## Custom Recipes
[Project-specific recipes not in base template]

## Exclusions
[Features to explicitly skip]

## Examples
[Concrete examples of expected output]
```

---

## Usage Patterns

### Pattern 1: New Project Setup

Use `preferences_template.md` to generate a complete justfile for a new project:

```bash
# 1. Fill out preferences
cp preferences_template.md my_app_preferences.md
# Edit my_app_preferences.md with project details

# 2. Combine with generation prompt
cat Just_Script_Generation_Instructions.md \
    preferences/my_app_preferences.md > prompt.txt

# 3. Use with AI
# Paste prompt.txt into Claude/ChatGPT
```

### Pattern 2: Code Review

Add preferences to review prompts:

```bash
cat Just_Script_Review_Instructions.md \
    preferences/my_app_preferences.md > review_prompt.txt

# AI will review existing justfile against your standards
```

### Pattern 3: Team Onboarding

Create shared team preferences:

```bash
# Team preferences stored in version control
cat Just_Script_Generation_Instructions.md \
    preferences/team_standards.md > prompt.txt

# All team members use same standards
```

### Pattern 4: Multiple Environments

Create environment-specific preferences:

```bash
# Development
cat Just_Script_Generation_Instructions.md \
    preferences/dev_environment.md > dev_prompt.txt

# Production
cat Just_Script_Generation_Instructions.md \
    preferences/prod_environment.md > prod_prompt.txt
```

---

## Example Preference Files

### 1. Microservices Monorepo

```markdown
## Project Context
**Type**: Monorepo with 12 microservices
**Build**: Turborepo with npm workspaces
**Deployment**: Kubernetes on GCP

## Custom Recipes
- `build-service`: Build specific service
- `test-service`: Test specific service
- `deploy-service`: Deploy single service
- `deploy-all`: Deploy all services
- `logs-service`: Tail service logs

## Team Conventions
**Service naming**: Always prefix with service name (api-test, web-build)
**Dependencies**: Use Turborepo's dependency graph
**Caching**: Leverage Turborepo's remote cache
```

### 2. Data Pipeline Project

```markdown
## Project Context
**Type**: ETL data pipeline
**Stack**: Python, Apache Airflow, dbt
**Database**: Snowflake

## Required Recipes
- DAG validation
- dbt model testing
- Data quality checks
- Schema migrations
- Airflow deployment

## Security Requirements
**Credentials**: From Snowflake OAuth, no passwords
**Data access**: Row-level security enforced
**Audit**: All data access logged
```

### 3. Static Site

```markdown
## Project Context
**Type**: Static site generator
**Framework**: 11ty (Eleventy)
**Deployment**: Netlify

## Required Recipes
- Build production site
- Development server
- Image optimization
- Deploy to Netlify
- Generate sitemap

## Exclusions
- Database recipes (not needed)
- Docker recipes (not needed)
- Backend server recipes
```

---

## Best Practices

### 1. Version Control Your Preferences

Store preferences alongside your project:

```
project/
├── justfile
├── .justfile-preferences.md  # Your preferences
└── .env.example
```

### 2. Document Deviations

Explain why you override defaults:

```markdown
## Coding Standards

**Shell**: zsh only
**Reason**: Team uses macOS exclusively, zsh-specific features needed
```

### 3. Keep Preferences Minimal

Only override what's necessary:

```markdown
# ❌ BAD - Repeating defaults
**Error handling**: Use `set -euo pipefail`

# ✅ GOOD - Only overrides
**Error handling**: Add `-x` flag for debug logging in dev environment
```

### 4. Provide Examples

Show concrete examples of expected output:

```markdown
## Examples

**Expected dev recipe**:
```just
# Start development server with hot reload
dev:
    #!/usr/bin/env bash
    set -euxo pipefail
    docker-compose up -d
    npm run dev | tee logs/dev-$(date +%Y%m%d).log
```
```

### 5. Update Preferences Regularly

Keep preferences in sync with project evolution:

```markdown
# Project Preferences

> **Last Updated**: 2025-12-11
> **Next Review**: 2026-01-11

## Changelog
- 2025-12-11: Added Kubernetes deployment recipes
- 2025-11-01: Updated to Node 20
```

---

## Common Customizations

### Override Shell

```markdown
## Coding Standards

**Shell**: sh (POSIX-compliant for Alpine Linux containers)
```

### Add Custom Variables

```markdown
## Custom Variables

All justfiles must include:
- `SERVICE_NAME`: Name of the microservice
- `ENVIRONMENT`: Current environment (dev/staging/prod)
- `REGION`: AWS region for deployment
```

### Require Confirmation

```markdown
## Security Requirements

**Destructive operations**: Must prompt with service name
**Example**:
```just
db-drop:
    @echo "⚠️  WARNING: Dropping database for {{SERVICE_NAME}}"
    @read -p "Type '{{SERVICE_NAME}}' to confirm: " confirm
    @[ "$confirm" = "{{SERVICE_NAME}}" ] || (echo "Aborted"; exit 1)
    dropdb {{SERVICE_NAME}}
```
```

### Framework Integration

```markdown
## Custom Recipes

**Next.js specific**:
- `build-standalone`: Build with standalone output
- `analyze-bundle`: Analyze bundle size with @next/bundle-analyzer
- `export-static`: Export static HTML
```

---

## Troubleshooting

### Issue 1: AI Ignores Preferences

**Problem**: Generated justfile doesn't match preferences

**Solution**: Be more explicit with examples
```markdown
# ❌ Vague
**Use Docker for development**

# ✅ Specific
**Development server**: Must run inside Docker container
**Example**:
```just
dev:
    docker-compose up -d
    docker-compose exec app npm run dev
```
```

### Issue 2: Conflicting Preferences

**Problem**: Preferences contradict base prompt

**Solution**: Clearly mark overrides
```markdown
## Overrides

**OVERRIDE BASE PROMPT**: Do NOT use `set -euo pipefail`
**Reason**: Legacy scripts require lenient error handling
**Alternative**: Manual error checking with `|| true`
```

### Issue 3: Too Many Preferences

**Problem**: Preferences file longer than base prompt

**Solution**: Extract to separate documentation
```markdown
## Additional Documentation

For detailed architecture and patterns, see:
- `docs/justfile-patterns.md`
- `docs/deployment-procedures.md`

**Summary for AI**: Use GitOps workflow with ArgoCD
```

---

## Examples Directory

See `examples/` for complete preference files:

- `ci_cd_preferences.md` - CI/CD-heavy project
- `monorepo_preferences.md` - Turborepo monorepo
- `docker_workflow_preferences.md` - Docker-centric development
- `serverless_preferences.md` - AWS Lambda serverless app

---

**Last Updated**: 2025-12-11
