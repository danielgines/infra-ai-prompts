# First Commit Instructions — AI Prompt Template

> **Context**: Use this prompt when creating the **very first commit** of a new repository.
> **Reference**: See `Commits_Message_Reference.md` for standards.

---

## Role & Objective

You are a **senior DevOps engineer** specializing in repository initialization and infrastructure automation.

Your task: Generate a **professional, standards-compliant commit message** for the initial commit of a project, following Conventional Commits specification.

---

## Pre-Execution Validation

Before generating the commit message, verify:

- [ ] This is truly the **first commit** (no prior history)
- [ ] No collaborators will be impacted
- [ ] Content is staged and reviewed (`git status`)
- [ ] Project language/domain is identified

---

## Classification Strategy

Analyze staged files to determine the appropriate type and scope:

### Type Selection Matrix

| Primary Content | Type | Scope Examples |
|----------------|------|----------------|
| Source code + initial structure | `feat` | `core`, `api`, `cli` |
| Configuration + tooling setup | `chore` | `setup`, `config` |
| Dependencies/lock files only | `build` | `deps` |
| Documentation only | `docs` | - |
| CI/CD pipelines only | `ci` | - |

### Mixed Content Rules

**Multiple significant components** → Choose dominant one:
1. Working code > configuration
2. Configuration > documentation
3. Documentation > empty structure

---

## Commit Message Structure

### Header Format
```
<type>(<scope>): <imperative description>
```

**Constraints:**
- ≤ 50 characters
- Imperative mood ("add", "implement", "initialize")
- No period at end
- Avoid generic terms: "first commit", "initial", "start"

### Body (Optional)
Include when:
- Architecture decisions need explanation
- Multiple subsystems initialized
- Non-obvious setup choices made

**Format:**
- Wrap at 72 characters
- Focus on **WHY** and **WHAT** (not how)
- Blank line after header

---

## Common Patterns & Examples

### Full Application Structure
```
feat(core): implement initial project structure

Establishes base architecture with modular design.
Includes configuration for linting, formatting, and testing.
```

### Configuration & Tooling
```
chore(setup): initialize repository with tooling

Sets up EditorConfig, ESLint, Prettier, and Git hooks.
Defines directory structure and coding standards.
```

### Dependencies Only
```
build(deps): define initial project dependencies

Adds core libraries and development tooling.
Locks versions for reproducible builds.
```

### Documentation Focus
```
docs: add project overview and setup guide

Includes architecture decisions, installation steps, and contribution guidelines.
```

### Infrastructure as Code
```
feat(infra): implement base Terraform configuration

Defines VPC, subnets, and security groups.
Supports multi-environment deployment (dev/staging/prod).
```

### Monorepo Initial Structure
```
chore(setup): initialize monorepo with workspace structure

Creates packages for api, web, and shared utilities.
Configures Nx/Lerna for coordinated builds.
```

---

## Git Commands

### Scenario A: No commits yet (initial)
```bash
git add -A
git commit -m "type(scope): description"
git log -1 --oneline
```

### Scenario B: One commit exists (amend first commit)
```bash
git commit --amend -m "type(scope): description"
git log -1 --oneline
git show --stat HEAD
```

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Analysis
- **Files staged**: [list key files/directories]
- **Project type**: [web app / CLI tool / infrastructure / library / etc.]
- **Primary language**: [JavaScript / Python / Go / etc.]
- **Recommended type**: [feat / chore / build / docs / ci]
- **Recommended scope**: [core / setup / deps / infra / etc.]
- **Rationale**: [1-2 sentences explaining the classification]

## Suggested Commit Message
[type](scope): description

[optional body if needed]

## Git Command
git commit -m "type(scope): description"

## Validation
- [x] Type and scope appropriate
- [x] Header concise and imperative
- [x] Body adds context (if included)
- [x] No generic terms used
- [x] Matches staged content

**Status**: ✅ Ready to apply
```

---

## Final Checklist

Before outputting the commit message:

- [ ] Type accurately reflects primary content
- [ ] Scope is specific and meaningful
- [ ] Header is imperative and concise
- [ ] Body included only if it adds value
- [ ] No vague terms ("initial", "first", "update")
- [ ] Message aligns with staged files
- [ ] Git command is correct for context

---

## Anti-Patterns to Avoid

❌ **Generic descriptions**:
- `chore: initial commit`
- `feat: first commit`
- `chore: setup`

✅ **Specific, descriptive**:
- `feat(api): implement RESTful user management`
- `chore(setup): configure TypeScript and build tooling`
- `build(deps): add Express, TypeORM, and testing libraries`

---

## Edge Cases

**Empty repository with only README:**
```
docs: add project overview and goals
```

**Only .gitignore and config files:**
```
chore(config): initialize repository settings
```

**Generated boilerplate (create-react-app, etc.):**
```
feat(web): initialize React application scaffold

Generated with create-react-app v5.0.
Includes default routing and component structure.
```

---

---

## Framework-Specific First Commits

### Web Frameworks

#### React Application
```
feat(web): initialize React application with TypeScript

Generated with create-react-app v5.0.
Includes routing (react-router-dom), state management (Redux),
and component structure (src/components, src/pages).

Development server: npm start
Production build: npm run build
```

#### Next.js Application
```
feat(web): initialize Next.js application with App Router

Sets up Next.js 14 with:
- App Router architecture
- TypeScript configuration
- Tailwind CSS styling
- API routes structure

Development: npm run dev
```

#### Vue.js Application
```
feat(web): initialize Vue 3 application with Composition API

Created with Vue CLI v5.
Includes Vuex store, Vue Router, and component scaffolding.
```

#### Django Project
```
feat(api): initialize Django REST API project

Sets up Django 4.2 with:
- REST framework configuration
- Database models structure
- Authentication system
- Admin panel customization

Environment: Python 3.11+
```

#### Flask API
```
feat(api): implement Flask REST API structure

Establishes modular blueprint architecture.
Includes SQLAlchemy ORM, JWT authentication, and API versioning.

Development server: flask run
```

#### Express.js API
```
feat(api): initialize Express.js REST API

Sets up Express 4.18 with:
- TypeScript configuration
- Middleware stack (cors, helmet, morgan)
- Route organization
- Database integration (TypeORM)
```

### Mobile Applications

#### React Native
```
feat(mobile): initialize React Native application

Generated with React Native CLI v0.72.
Includes navigation (React Navigation), state management,
and native modules setup for iOS and Android.

Run iOS: npm run ios
Run Android: npm run android
```

#### Flutter
```
feat(mobile): initialize Flutter application

Sets up Flutter 3.x project with:
- Material Design widgets
- State management (Provider)
- Screen routing
- Platform-specific configurations

Run: flutter run
```

### CLI Tools

#### Node.js CLI
```
feat(cli): implement command-line interface structure

Sets up Commander.js for command parsing.
Includes subcommands, flags, and help documentation.

Install: npm install -g
Usage: mycli --help
```

#### Python CLI
```
feat(cli): initialize Click-based CLI application

Establishes command structure with:
- Argument parsing (Click)
- Configuration management
- Output formatting
- Error handling

Install: pip install -e .
```

---

## Monorepo First Commits

### Nx Monorepo
```
chore(setup): initialize Nx monorepo with workspace structure

Creates workspace with:
- apps/ (applications)
- libs/ (shared libraries)
- Nx Cloud integration
- Consistent tooling (ESLint, Prettier, Jest)

Workspaces configured:
- apps/web (React)
- apps/api (NestJS)
- libs/shared-utils

Commands:
- nx serve web
- nx serve api
- nx test
```

### Turborepo
```
chore(setup): initialize Turborepo monorepo

Establishes Turborepo workspace with:
- packages/ui (shared components)
- packages/config (shared configs)
- apps/web (Next.js)
- apps/docs (Next.js docs)

Build: turbo run build
Dev: turbo run dev
```

### Lerna Monorepo
```
chore(setup): initialize Lerna monorepo with independent versioning

Creates packages:
- @myorg/core
- @myorg/utils
- @myorg/cli

Versioning: independent
Publish: lerna publish
```

### Yarn Workspaces
```
chore(setup): initialize Yarn workspaces monorepo

Configures workspace structure:
- packages/* (shared packages)
- services/* (microservices)

Install: yarn install
```

---

## Team Workflow Considerations

### Solo Developer First Commit
```
feat(core): implement initial project architecture

Establishes modular structure with clear separation of concerns.
Includes development tooling and testing framework.

This is a solo project - no team conventions required yet.
```

### Team Project First Commit
```
feat(core): implement initial project architecture

Establishes agreed-upon team structure from design review.
Follows company coding standards and security policies.

Team conventions:
- Code review required for all PRs
- Test coverage minimum: 80%
- Branch naming: feature/*, bugfix/*

Development setup: see CONTRIBUTING.md
```

### Open Source First Commit
```
feat(core): implement initial library architecture

Establishes public API interface and plugin system.
Includes comprehensive documentation for contributors.

Project follows Apache 2.0 license.
Contributing guidelines: CONTRIBUTING.md
Code of Conduct: CODE_OF_CONDUCT.md

See README.md for installation and usage examples.
```

---

## Post-Commit Validation Checklist

After creating the first commit, verify:

### Repository Health
- [ ] `git log` shows single commit with proper message
- [ ] `git status` shows clean working tree
- [ ] All intended files are committed (`git ls-files`)
- [ ] No unintended files committed (.env, node_modules, etc.)
- [ ] `.gitignore` is working correctly

### Build Verification
- [ ] Project builds successfully (npm run build, make, etc.)
- [ ] Tests run (if any exist) (npm test, pytest, etc.)
- [ ] Development server starts (if applicable)
- [ ] No obvious errors in console/terminal

### Documentation Check
- [ ] README.md exists and has installation instructions
- [ ] LICENSE file present (if required)
- [ ] .gitignore appropriate for project type
- [ ] Environment variables documented (.env.example)

### Remote Setup (if applicable)
- [ ] Remote repository created (GitHub, GitLab, etc.)
- [ ] Remote added: `git remote add origin <url>`
- [ ] First push successful: `git push -u origin main`
- [ ] Repository visibility set correctly (public/private)

---

## Common First Commit Mistakes

### ❌ Mistake 1: Including Secrets
```bash
# BAD: Committing .env file with secrets
git add .env
git commit -m "feat(core): initial setup"
```

**Fix**:
```bash
# Add .env to .gitignore FIRST
echo ".env" >> .gitignore
git add .gitignore
git commit -m "chore(config): add gitignore with secret files"
```

### ❌ Mistake 2: Committing node_modules or Build Artifacts
```bash
# BAD: 50MB commit with dependencies
git add node_modules/
```

**Prevention**: Ensure .gitignore includes:
```
node_modules/
dist/
build/
*.pyc
__pycache__/
.venv/
```

### ❌ Mistake 3: Vague Commit Message
```
❌ git commit -m "initial commit"
❌ git commit -m "first"
❌ git commit -m "setup"
```

**Better**:
```
✅ git commit -m "feat(api): implement REST API with Express and TypeORM"
✅ git commit -m "chore(setup): initialize Node.js project with TypeScript"
✅ git commit -m "feat(web): create React application with routing and state"
```

### ❌ Mistake 4: Mixing Unrelated Concerns
```
❌ feat: add api + frontend + docs + ci/cd + tests
```

**Better**: Make focused first commit, add other parts in follow-up commits:
```
✅ feat(api): implement REST API structure
  (follow with separate commits for frontend, docs, etc.)
```

### ❌ Mistake 5: Wrong Branch
```bash
# BAD: Committing to main when should use feature branch
git checkout -b feature/initial-setup  # Too late after commit
```

**Correct**:
```bash
# Create branch BEFORE first commit (if not using main)
git checkout -b feature/initial-setup
git add .
git commit -m "feat(core): implement initial structure"
```

---

## Project Type Decision Matrix

Use this to quickly identify appropriate type and scope:

| Project Type | Recommended Type | Scope | Example |
|-------------|------------------|-------|---------|
| Web App (full stack) | `feat` | `core` | `feat(core): implement full-stack application structure` |
| REST API | `feat` | `api` | `feat(api): implement REST API with Express` |
| GraphQL API | `feat` | `api` | `feat(api): implement GraphQL API with Apollo Server` |
| CLI Tool | `feat` | `cli` | `feat(cli): implement command-line interface` |
| Library/Package | `feat` | `core` | `feat(core): implement library API interface` |
| Mobile App | `feat` | `mobile` | `feat(mobile): initialize React Native application` |
| Infrastructure | `feat` | `infra` | `feat(infra): implement Terraform AWS infrastructure` |
| Documentation Site | `docs` | - | `docs: initialize documentation site with Docusaurus` |
| Microservice | `feat` | `service-name` | `feat(auth-service): implement authentication microservice` |
| Monorepo | `chore` | `setup` | `chore(setup): initialize monorepo with Nx` |
| Config Only | `chore` | `config` | `chore(config): initialize repository configuration` |

---

## Scaffolding Tool Integration

### Using Generator Tools

When first commit contains generated code:

#### create-react-app
```
feat(web): initialize React application with CRA

Generated with create-react-app v5.0.1.
Includes default routing, testing setup, and build configuration.

Modified files:
- Added: custom environment variables
- Updated: package.json with additional dependencies

Development: npm start
Production: npm run build
```

#### nest new
```
feat(api): initialize NestJS application

Generated with Nest CLI v10.0.
Includes modules structure, dependency injection, and testing framework.

Architecture: modular monolith with controller/service pattern
```

#### django-admin startproject
```
feat(api): initialize Django project structure

Created with django-admin startproject.
Includes settings for development/production environments.

Setup: python manage.py migrate
Run: python manage.py runserver
```

---

## Edge Cases and Special Scenarios

### Migrating from Another VCS
```
chore(setup): initialize Git repository from SVN migration

Preserves commit history from SVN r1234-r5678.
Converted branches: trunk → main, branches/* → feature/*

Migration tool: git svn
Previous repo: svn://old-repo.com/project
```

### Forking with Customization
```
feat(core): initialize project based on upstream template

Forked from: github.com/original/project v2.1
Customizations:
- Removed unnecessary dependencies
- Updated configuration for our use case
- Modified branding and documentation

Upstream: git remote add upstream <url>
```

### Monorepo Package Addition
```
feat(packages/new-lib): add new shared library package

Adds new workspace package to existing monorepo.
Follows established project structure and conventions.

Dependencies: @myorg/core, @myorg/utils
Export: ESM and CommonJS modules
```

---

## Quick Decision Flowchart

```
Is this truly the FIRST commit?
├─ YES → Continue
└─ NO → Use Commits_Message_Generation_Progress_Instructions.md

What files are staged?
├─ Working code (src/, lib/, app/) → feat(core/api/cli)
├─ Config only (package.json, .eslintrc) → chore(setup/config)
├─ Docs only (README, CONTRIBUTING) → docs
├─ CI/CD only (.github/workflows/) → ci
└─ Dependencies only (package-lock.json) → build(deps)

Is it a monorepo?
├─ YES → chore(setup): initialize [tool] monorepo
└─ NO → Continue with type from above

Is it generated code?
├─ YES → Mention generator in body
└─ NO → Standard commit message

Add body if:
- Architecture decisions made
- Multiple subsystems initialized
- Non-obvious setup choices
- Generated code with modifications
```

---

**Reference**: `Commits_Message_Reference.md` for detailed standards.
**Last Updated**: 2025-12-12
**Version**: 2.0
