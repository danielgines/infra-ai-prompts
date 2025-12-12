# docker.just - Docker Operations Module
# This file is imported by the main justfile.
# Demonstrates modular organization of just recipes.

# Docker configuration
docker_image := "myapp"
docker_tag := `git describe --tags --always 2>/dev/null || echo "latest"`
docker_registry := env_var_or_default("DOCKER_REGISTRY", "docker.io")

# Build Docker image
docker-build platform="linux/amd64":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building Docker image {{docker_image}}:{{docker_tag}} for {{platform}}..."

    docker build \
        --platform {{platform}} \
        --build-arg VERSION={{docker_tag}} \
        --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
        -t {{docker_image}}:{{docker_tag}} \
        -t {{docker_image}}:latest \
        .

    echo "✓ Image built: {{docker_image}}:{{docker_tag}}"

# Build multi-platform image
docker-build-multi:
    @echo "Building multi-platform image..."
    @just docker-build "linux/amd64,linux/arm64"

# Run container locally
docker-run port="8080":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running {{docker_image}}:{{docker_tag}} on port {{port}}..."

    docker run \
        --rm \
        -it \
        -p {{port}}:8080 \
        --env-file .env \
        --name {{docker_image}}-dev \
        {{docker_image}}:{{docker_tag}}

# Run container in background
docker-up port="8080":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Starting {{docker_image}} container..."

    docker run \
        -d \
        -p {{port}}:8080 \
        --env-file .env \
        --name {{docker_image}}-dev \
        --restart unless-stopped \
        {{docker_image}}:{{docker_tag}}

    echo "✓ Container started on port {{port}}"
    echo "View logs: just docker-logs"
    echo "Stop: just docker-stop"

# Stop container
docker-stop:
    #!/usr/bin/env bash
    set -euo pipefail

    if docker ps -q -f name={{docker_image}}-dev | grep -q .; then
        echo "Stopping {{docker_image}}-dev..."
        docker stop {{docker_image}}-dev
        docker rm {{docker_image}}-dev
        echo "✓ Container stopped"
    else
        echo "No running container found"
    fi

# View container logs
docker-logs follow="true":
    #!/usr/bin/env bash
    if [[ "{{follow}}" == "true" ]]; then
        docker logs -f {{docker_image}}-dev
    else
        docker logs {{docker_image}}-dev
    fi

# Execute shell in running container
docker-shell:
    @docker exec -it {{docker_image}}-dev /bin/bash || docker exec -it {{docker_image}}-dev /bin/sh

# Tag image for registry
docker-tag tag:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Tagging {{docker_image}}:{{docker_tag}} as {{docker_registry}}/{{docker_image}}:{{tag}}..."

    docker tag {{docker_image}}:{{docker_tag}} {{docker_registry}}/{{docker_image}}:{{tag}}

    echo "✓ Tagged as {{docker_registry}}/{{docker_image}}:{{tag}}"

# Push image to registry
docker-push tag:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Pushing {{docker_registry}}/{{docker_image}}:{{tag}}..."

    # Tag if not already tagged
    if ! docker images | grep -q "{{docker_registry}}/{{docker_image}}.*{{tag}}"; then
        just docker-tag {{tag}}
    fi

    docker push {{docker_registry}}/{{docker_image}}:{{tag}}

    echo "✓ Pushed to {{docker_registry}}/{{docker_image}}:{{tag}}"

# Pull image from registry
docker-pull tag="latest":
    @docker pull {{docker_registry}}/{{docker_image}}:{{tag}}

# Inspect image
docker-inspect:
    @docker inspect {{docker_image}}:{{docker_tag}} | head -50

# Show image size
docker-size:
    @docker images {{docker_image}} --format "table {{{{.Repository}}}}\t{{{{.Tag}}}}\t{{{{.Size}}}}"

# Remove old images
docker-prune:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Removing unused Docker images..."
    docker image prune -af --filter "label=app={{docker_image}}"
    echo "✓ Pruned"

# Docker Compose operations

# Start services with docker-compose
compose-up:
    @docker-compose up -d

# Stop services
compose-down:
    @docker-compose down

# Restart services
compose-restart:
    @docker-compose restart

# View compose logs
compose-logs service="":
    #!/usr/bin/env bash
    if [ -n "{{service}}" ]; then
        docker-compose logs -f {{service}}
    else
        docker-compose logs -f
    fi

# Execute command in service
compose-exec service command:
    @docker-compose exec {{service}} {{command}}

# Show service status
compose-ps:
    @docker-compose ps

# Helper: check if Docker is running
_check-docker:
    #!/usr/bin/env bash
    if ! docker info &> /dev/null; then
        echo "Error: Docker is not running"
        exit 1
    fi
