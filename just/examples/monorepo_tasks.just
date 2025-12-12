# justfile for Monorepo with Turborepo
# Multi-package repository with shared dependencies
# Documentation: https://just.systems

# Configuration
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
turbo := "npx turbo"

# Workspace paths
project_dir := justfile_directory()
packages_dir := project_dir / "packages"
apps_dir := project_dir / "apps"

# Available services/apps
services := "api web mobile-api admin-dashboard"
packages := "shared-ui utils config types"

# Default recipe
default:
    @just --list

# Global Operations

# Install all dependencies
install:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing dependencies for all workspaces..."
    npm install
    echo "✓ All dependencies installed"

# Clean all workspaces
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Cleaning all workspaces..."

    # Clean Turbo cache
    {{turbo}} clean

    # Clean node_modules
    find . -name "node_modules" -type d -prune -exec rm -rf {} +

    # Clean build artifacts
    find . -name "dist" -type d -exec rm -rf {} +
    find . -name "build" -type d -exec rm -rf {} +
    find . -name ".next" -type d -exec rm -rf {} +

    echo "✓ Clean complete"

# Build all packages and apps
build:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building all workspaces..."
    {{turbo}} run build
    echo "✓ Build complete"

# Run tests across all workspaces
test:
    #!/usr/bin/env bash
    set -euo pipefail
    {{turbo}} run test

# Run linter across all workspaces
lint:
    {{turbo}} run lint

# Auto-fix linting issues
lint-fix:
    {{turbo}} run lint:fix

# Type check all TypeScript code
type-check:
    {{turbo}} run type-check

# Development Recipes

# Start all development servers in parallel
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Starting all dev servers..."
    {{turbo}} run dev --parallel

# Start development for specific app
dev-app app:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Starting {{app}} development server..."
    {{turbo}} run dev --filter={{app}}

# Start API and web app (common combination)
dev-web:
    {{turbo}} run dev --filter=web --filter=api

# Workspace-Specific Operations

# Build specific workspace
build-workspace workspace:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building {{workspace}}..."
    {{turbo}} run build --filter={{workspace}}
    echo "✓ {{workspace}} built"

# Build workspace and its dependencies
build-with-deps workspace:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building {{workspace}} with dependencies..."
    {{turbo}} run build --filter={{workspace}}...
    echo "✓ {{workspace}} and dependencies built"

# Test specific workspace
test-workspace workspace:
    {{turbo}} run test --filter={{workspace}}

# Lint specific workspace
lint-workspace workspace:
    {{turbo}} run lint --filter={{workspace}}

# Run command in specific workspace
exec-workspace workspace *args:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{apps_dir}}/{{workspace}} && {{args}}

# Service Management

# Build all services (apps)
build-services:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building all services..."

    for service in {{services}}; do
        echo "Building $service..."
        {{turbo}} run build --filter=$service
    done

    echo "✓ All services built"

# Test all services
test-services:
    #!/usr/bin/env bash
    set -euo pipefail

    for service in {{services}}; do
        echo "Testing $service..."
        {{turbo}} run test --filter=$service
    done

# Start specific service
start-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate service exists
    if ! echo "{{services}}" | grep -q "{{service}}"; then
        echo "Error: Unknown service '{{service}}'"
        echo "Available services: {{services}}"
        exit 1
    fi

    echo "Starting {{service}}..."
    {{turbo}} run dev --filter={{service}}

# Package Management

# Build all shared packages
build-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Building all packages..."

    for package in {{packages}}; do
        echo "Building $package..."
        {{turbo}} run build --filter=$package
    done

    echo "✓ All packages built"

# Test all shared packages
test-packages:
    #!/usr/bin/env bash
    set -euo pipefail

    for package in {{packages}}; do
        echo "Testing $package..."
        {{turbo}} run test --filter=$package
    done

# Publish package to npm
publish-package package version:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate package exists
    if ! echo "{{packages}}" | grep -q "{{package}}"; then
        echo "Error: Unknown package '{{package}}'"
        echo "Available packages: {{packages}}"
        exit 1
    fi

    # Build package
    just build-workspace {{package}}

    # Navigate to package directory
    cd {{packages_dir}}/{{package}}

    # Update version
    npm version {{version}}

    # Publish
    npm publish

    echo "✓ {{package}}@{{version}} published"

# Dependency Management

# Add dependency to workspace
add-dep workspace package:
    #!/usr/bin/env bash
    set -euo pipefail

    workspace_path=$(just _workspace-path {{workspace}})

    cd "$workspace_path"
    npm install {{package}}

    echo "✓ Added {{package}} to {{workspace}}"

# Add dev dependency to workspace
add-dev-dep workspace package:
    #!/usr/bin/env bash
    set -euo pipefail

    workspace_path=$(just _workspace-path {{workspace}})

    cd "$workspace_path"
    npm install --save-dev {{package}}

    echo "✓ Added {{package}} (dev) to {{workspace}}"

# Remove dependency from workspace
remove-dep workspace package:
    #!/usr/bin/env bash
    set -euo pipefail

    workspace_path=$(just _workspace-path {{workspace}})

    cd "$workspace_path"
    npm uninstall {{package}}

    echo "✓ Removed {{package}} from {{workspace}}"

# Update dependencies across all workspaces
update-deps:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Updating dependencies..."
    npm update --workspaces
    echo "✓ Dependencies updated"

# Cache Management

# Show Turbo cache status
cache-status:
    {{turbo}} run build --dry-run

# Clear Turbo cache
cache-clear:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Clearing Turbo cache..."
    rm -rf .turbo/cache
    echo "✓ Cache cleared"

# Prune Turbo cache (keep recent)
cache-prune:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Pruning old cache entries..."

    # Keep cache from last 7 days
    find .turbo/cache -type f -mtime +7 -delete

    echo "✓ Cache pruned"

# CI/CD Recipes

# Run all CI checks
ci:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "→ Installing dependencies..."
    npm ci

    echo "→ Running linter..."
    just lint

    echo "→ Type checking..."
    just type-check

    echo "→ Running tests..."
    just test

    echo "→ Building..."
    just build

    echo "✓ All CI checks passed"

# Build for production
ci-build:
    #!/usr/bin/env bash
    set -euo pipefail

    NODE_ENV=production {{turbo}} run build

# Run affected tasks (based on git changes)
affected-test:
    #!/usr/bin/env bash
    set -euo pipefail

    # Get changed workspaces
    changed=$(git diff --name-only HEAD~1 HEAD | cut -d/ -f1-2 | sort -u)

    if [ -z "$changed" ]; then
        echo "No changes detected"
        exit 0
    fi

    echo "Testing affected workspaces..."
    {{turbo}} run test --filter="[HEAD~1]"

# Deployment

# Deploy specific service
deploy-service service environment:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate inputs
    just _validate-service {{service}}
    just _validate-env {{environment}}

    echo "Deploying {{service}} to {{environment}}..."

    # Build service
    just build-workspace {{service}}

    # Run deployment script
    cd {{apps_dir}}/{{service}}
    ./scripts/deploy.sh {{environment}}

    echo "✓ {{service}} deployed to {{environment}}"

# Deploy all services
deploy-all environment:
    #!/usr/bin/env bash
    set -euo pipefail

    just _validate-env {{environment}}

    for service in {{services}}; do
        just deploy-service $service {{environment}}
    done

    echo "✓ All services deployed to {{environment}}"

# Utility Recipes

# List all workspaces
list-workspaces:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Services:"
    for service in {{services}}; do
        echo "  - $service"
    done

    echo ""
    echo "Packages:"
    for package in {{packages}}; do
        echo "  - $package"
    done

# Show workspace dependencies
workspace-deps workspace:
    #!/usr/bin/env bash
    set -euo pipefail

    workspace_path=$(just _workspace-path {{workspace}})

    cd "$workspace_path"
    npm ls --depth=0

# Generate dependency graph
graph:
    {{turbo}} run build --graph=dependency-graph.html
    @echo "✓ Graph generated: dependency-graph.html"

# Helper Recipes

# Get workspace path
_workspace-path workspace:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check apps directory
    if [ -d "{{apps_dir}}/{{workspace}}" ]; then
        echo "{{apps_dir}}/{{workspace}}"
        exit 0
    fi

    # Check packages directory
    if [ -d "{{packages_dir}}/{{workspace}}" ]; then
        echo "{{packages_dir}}/{{workspace}}"
        exit 0
    fi

    echo "Error: Workspace '{{workspace}}' not found"
    exit 1

# Validate service name
_validate-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! echo "{{services}}" | grep -q "{{service}}"; then
        echo "Error: Unknown service '{{service}}'"
        echo "Available services: {{services}}"
        exit 1
    fi

# Validate environment
_validate-env environment:
    #!/usr/bin/env bash
    set -euo pipefail

    allowed=("dev" "staging" "production")

    if [[ ! " ${allowed[@]} " =~ " {{environment}} " ]]; then
        echo "Error: Invalid environment '{{environment}}'"
        echo "Allowed: ${allowed[@]}"
        exit 1
    fi
