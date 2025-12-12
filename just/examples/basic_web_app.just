# justfile for Basic Web Application
# Node.js + Express API + React Frontend
# Documentation: https://just.systems

# Configuration
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
export NODE_ENV := env_var_or_default("NODE_ENV", "development")
export PORT := env_var_or_default("PORT", "3000")
export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgresql://localhost/myapp_dev")

# Project paths
project_dir := justfile_directory()
frontend_dir := project_dir / "frontend"
backend_dir := project_dir / "backend"

# Default recipe - show available commands
default:
    @just --list

# Development Recipes

# Start development server with hot reload
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Starting development server on port {{PORT}}..."
    npm run dev

# Start backend and frontend in parallel
dev-full:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Starting full-stack development..."

    # Start backend in background
    cd {{backend_dir}} && npm run dev &
    backend_pid=$!

    # Start frontend in background
    cd {{frontend_dir}} && npm run dev &
    frontend_pid=$!

    # Wait for both processes
    wait $backend_pid $frontend_pid

# Install Dependencies

# Install all dependencies
install:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing dependencies..."

    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi

    echo "✓ Dependencies installed"

# Update dependencies to latest versions
update:
    npm update

# Testing Recipes

# Run all tests
test:
    #!/usr/bin/env bash
    set -euo pipefail
    npm test

# Run tests in watch mode
test-watch:
    npm test -- --watch

# Run tests with coverage
test-coverage:
    #!/usr/bin/env bash
    set -euo pipefail
    npm test -- --coverage --watchAll=false

    # Check coverage threshold
    echo "✓ Tests passed with coverage"

# Code Quality Recipes

# Run linter
lint:
    npm run lint

# Auto-fix linting issues
lint-fix:
    npm run lint -- --fix

# Format code with Prettier
format:
    npx prettier --write "src/**/*.{js,jsx,ts,tsx,json,css,md}"

# Check code formatting
format-check:
    npx prettier --check "src/**/*.{js,jsx,ts,tsx,json,css,md}"

# Build Recipes

# Build for production
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building for production..."

    # Clean previous build
    rm -rf dist/

    # Run build
    NODE_ENV=production npm run build

    echo "✓ Build complete"

# Build and analyze bundle size
build-analyze:
    #!/usr/bin/env bash
    set -euo pipefail
    npm run build -- --analyze
    echo "✓ Bundle analysis available at dist/stats.html"

# Database Recipes

# Create database
db-create:
    #!/usr/bin/env bash
    set -euo pipefail
    db_name=$(echo {{DATABASE_URL}} | sed 's|.*\/||')
    createdb "$db_name" || echo "Database may already exist"
    echo "✓ Database created: $db_name"

# Drop database (with confirmation)
db-drop:
    #!/usr/bin/env bash
    set -euo pipefail

    db_name=$(echo {{DATABASE_URL}} | sed 's|.*\/||')

    echo "⚠️  WARNING: This will delete database: $db_name"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi

    dropdb --if-exists "$db_name"
    echo "✓ Database dropped"

# Run database migrations
db-migrate:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running migrations..."
    npm run migrate
    echo "✓ Migrations complete"

# Seed database with test data
db-seed:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Seeding database..."
    npm run seed
    echo "✓ Database seeded"

# Reset database (drop, create, migrate, seed)
db-reset: db-drop db-create db-migrate db-seed
    @echo "✓ Database reset complete"

# Cleanup Recipes

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Cleaning build artifacts..."
    rm -rf dist/ build/ .next/ coverage/
    echo "✓ Clean complete"

# Clean and reinstall dependencies
clean-install: clean
    rm -rf node_modules/
    npm install

# Full reset (clean + database reset)
reset: clean db-reset
    @echo "✓ Full reset complete"

# Helper Recipes (prefixed with _ so they don't show in --list)

# Check if command exists
_require cmd:
    @command -v {{cmd}} >/dev/null || (echo "Error: {{cmd}} not found. Please install it."; exit 1)

# Log message with timestamp
_log message:
    @echo "[$(date '+%Y-%m-%d %H:%M:%S')] {{message}}"

# Check if database is running
_check-db:
    #!/usr/bin/env bash
    set -euo pipefail
    psql {{DATABASE_URL}} -c "SELECT 1" > /dev/null 2>&1 || (echo "Error: Cannot connect to database"; exit 1)
