# justfile for Docker-Centric Workflow
# Multi-container application with Docker Compose
# Documentation: https://just.systems

# Configuration
set shell := ["bash", "-c"]
set dotenv-load := true

# Variables
export COMPOSE_PROJECT_NAME := env_var_or_default("COMPOSE_PROJECT_NAME", "myapp")
export DOCKER_BUILDKIT := "1"
docker_compose := "docker-compose"

# Image configuration
image_name := env_var_or_default("IMAGE_NAME", "myapp")
image_tag := env_var_or_default("IMAGE_TAG", "latest")
registry := env_var_or_default("REGISTRY", "")

# Default recipe
default:
    @just --list

# Docker Build Recipes

# Build Docker image with caching
build tag=image_tag:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building Docker image: {{image_name}}:{{tag}}"

    docker build \
        --cache-from {{image_name}}:latest \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --tag {{image_name}}:{{tag}} \
        --tag {{image_name}}:latest \
        .

    echo "✓ Image built: {{image_name}}:{{tag}}"

# Build without cache (clean build)
build-no-cache:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building image without cache..."

    docker build \
        --no-cache \
        --tag {{image_name}}:{{image_tag}} \
        .

    echo "✓ Clean build complete"

# Build multi-platform image
build-multiplatform:
    #!/usr/bin/env bash
    set -euo pipefail

    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag {{image_name}}:{{image_tag}} \
        --push \
        .

# Container Management Recipes

# Start all services
up:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Starting services..."
    {{docker_compose}} up -d
    echo "✓ Services started"

# Start services with build
up-build:
    #!/usr/bin/env bash
    set -euo pipefail
    {{docker_compose}} up -d --build

# Stop all services
down:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Stopping services..."
    {{docker_compose}} down
    echo "✓ Services stopped"

# Stop and remove volumes
down-volumes:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "⚠️  WARNING: This will delete all volumes and data"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi

    {{docker_compose}} down -v
    echo "✓ Services and volumes removed"

# Restart all services
restart:
    {{docker_compose}} restart

# Restart specific service
restart-service service:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Restarting {{service}}..."
    {{docker_compose}} restart {{service}}
    echo "✓ {{service}} restarted"

# Logs and Monitoring Recipes

# View logs from all services
logs:
    {{docker_compose}} logs -f

# View logs from specific service
logs-service service:
    {{docker_compose}} logs -f {{service}}

# View last N lines of logs
logs-tail service lines='100':
    {{docker_compose}} logs --tail={{lines}} {{service}}

# View logs with timestamps
logs-timestamps service='':
    #!/usr/bin/env bash
    if [ -z "{{service}}" ]; then
        {{docker_compose}} logs -f --timestamps
    else
        {{docker_compose}} logs -f --timestamps {{service}}
    fi

# Show service status
status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Service Status:"
    {{docker_compose}} ps
    echo ""
    echo "Docker Resources:"
    docker stats --no-stream

# Check health of services
health:
    #!/usr/bin/env bash
    set -euo pipefail

    services=$({{docker_compose}} ps --services)

    for service in $services; do
        health=$({{docker_compose}} ps $service --format "{{{{.Health}}}}")

        if [ "$health" = "healthy" ] || [ -z "$health" ]; then
            echo "✓ $service: OK"
        else
            echo "✗ $service: $health"
        fi
    done

# Shell Access Recipes

# Open bash shell in main app container
shell:
    {{docker_compose}} exec app bash

# Open shell in specific service
shell-service service:
    {{docker_compose}} exec {{service}} bash

# Run command in app container
exec *args:
    {{docker_compose}} exec app {{args}}

# Run command in specific service
exec-service service *args:
    {{docker_compose}} exec {{service}} {{args}}

# Database Operations in Docker

# Open PostgreSQL console
db-console:
    {{docker_compose}} exec db psql -U postgres

# Run database migrations in container
db-migrate:
    {{docker_compose}} exec app npm run migrate

# Seed database
db-seed:
    {{docker_compose}} exec app npm run seed

# Backup database
db-backup:
    #!/usr/bin/env bash
    set -euo pipefail

    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="backups/db_backup_$timestamp.sql"

    mkdir -p backups

    {{docker_compose}} exec -T db pg_dump -U postgres > "$backup_file"

    echo "✓ Backup created: $backup_file"

# Restore database from backup
db-restore file:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "{{file}}" ]; then
        echo "Error: Backup file not found: {{file}}"
        exit 1
    fi

    echo "⚠️  WARNING: This will replace the current database"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi

    {{docker_compose}} exec -T db psql -U postgres < "{{file}}"
    echo "✓ Database restored from {{file}}"

# Development Workflow Recipes

# Start development environment
dev: up
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Development environment ready!"
    echo "App: http://localhost:3000"
    echo "Logs: just logs-service app"

# Watch logs during development
dev-logs:
    {{docker_compose}} logs -f app

# Rebuild and restart for development
dev-rebuild: down build up-build
    @echo "✓ Development environment rebuilt"

# Testing in Docker

# Run tests in container
test:
    {{docker_compose}} exec app npm test

# Run tests with coverage
test-coverage:
    {{docker_compose}} exec app npm test -- --coverage

# Run specific test file
test-file file:
    {{docker_compose}} exec app npm test {{file}}

# Cleanup Recipes

# Clean up Docker resources
clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning Docker resources..."

    # Stop containers
    {{docker_compose}} down

    # Remove unused images
    docker image prune -f

    # Remove unused containers
    docker container prune -f

    echo "✓ Docker cleanup complete"

# Deep clean (remove everything)
clean-all:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "⚠️  WARNING: This will remove all containers, images, and volumes"
    read -p "Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi

    {{docker_compose}} down -v
    docker system prune -af
    docker volume prune -f

    echo "✓ Deep clean complete"

# Registry Operations

# Tag image for registry
tag version:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{registry}}" ]; then
        echo "Error: REGISTRY environment variable not set"
        exit 1
    fi

    docker tag {{image_name}}:{{image_tag}} {{registry}}/{{image_name}}:{{version}}
    docker tag {{image_name}}:{{image_tag}} {{registry}}/{{image_name}}:latest

    echo "✓ Tagged: {{registry}}/{{image_name}}:{{version}}"

# Push image to registry
push version: (tag version)
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Pushing to registry..."

    docker push {{registry}}/{{image_name}}:{{version}}
    docker push {{registry}}/{{image_name}}:latest

    echo "✓ Pushed: {{registry}}/{{image_name}}:{{version}}"

# Pull image from registry
pull version='latest':
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{registry}}" ]; then
        echo "Error: REGISTRY environment variable not set"
        exit 1
    fi

    docker pull {{registry}}/{{image_name}}:{{version}}

# Helper Recipes

# Check if Docker is running
_check-docker:
    #!/usr/bin/env bash
    set -euo pipefail
    docker info > /dev/null 2>&1 || (echo "Error: Docker is not running"; exit 1)

# Check if docker-compose file exists
_check-compose:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -f "docker-compose.yml" ] || (echo "Error: docker-compose.yml not found"; exit 1)

# Wait for service to be healthy
_wait-healthy service timeout='60':
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Waiting for {{service}} to be healthy..."

    elapsed=0
    while [ $elapsed -lt {{timeout}} ]; do
        health=$({{docker_compose}} ps {{service}} --format "{{{{.Health}}}}" || echo "")

        if [ "$health" = "healthy" ]; then
            echo "✓ {{service}} is healthy"
            exit 0
        fi

        sleep 2
        elapsed=$((elapsed + 2))
    done

    echo "Error: {{service}} did not become healthy within {{timeout}} seconds"
    exit 1
