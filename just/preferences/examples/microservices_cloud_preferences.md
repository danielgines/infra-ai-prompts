# Microservices & Cloud Deployment Preferences for Just Script Generation

## Usage

**How to use this preferences file with the base prompt:**

1. **Copy the base generation prompt**:
   - Open `/data/Projetos/infra-ai-prompts/just/Just_Script_Generation_Instructions.md`
   - Copy the entire content to your AI tool (Claude, ChatGPT, etc.)

2. **Append this preferences file**:
   - Copy this entire file
   - Paste it immediately after the base prompt in the same message

3. **Provide your requirements**:
   - Describe your microservices architecture and cloud platform
   - The AI will apply both base patterns AND these cloud-native preferences

4. **Expected behavior**:
   - All recipes will be cloud-native and Kubernetes-aware
   - Service mesh patterns (Istio, Linkerd) will be included
   - Multi-region deployment support will be built-in
   - Observability (Prometheus, Jaeger) will be integrated

**Example composition**:
```
[Base prompt from Just_Script_Generation_Instructions.md]

---

[This entire preferences file]

---

My project: Multi-service API platform on GKE
Services: auth, api-gateway, payment-processor, notification-service
Requirements: Kubernetes deployment with Istio service mesh...
```

---

## Cloud-Native & Microservices Configuration

When generating justfiles for microservices architectures deployed to cloud platforms (AWS, GCP, Azure, Kubernetes), apply these preferences:

### Architecture Context
- **Pattern**: Microservices with container orchestration
- **Platform**: Kubernetes, ECS, GKE, AKS
- **Scale**: Multi-region, high availability
- **CI/CD**: GitOps, automated pipelines

### Service Organization

**REQUIRED**:
- ✅ Separate recipes per service
- ✅ Service dependency management
- ✅ Health check integration
- ✅ Service mesh awareness (Istio, Linkerd)
- ✅ Observability built-in

**Example Pattern**:
```just
# Service-specific targets
services := "auth api gateway worker notifications"

# Deploy specific service
deploy-service service environment:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate service exists
    if [[ ! " {{services}} " =~ " {{service}} " ]]; then
        echo "Error: Unknown service '{{service}}'"
        echo "Available: {{services}}"
        exit 1
    fi

    echo "Deploying {{service}} to {{environment}}..."

    # Build and push image
    just build-service {{service}}
    just push-service {{service}} {{environment}}

    # Apply k8s manifests
    kubectl apply -f "k8s/{{service}}/{{environment}}/"

    # Wait for rollout
    kubectl rollout status deployment/{{service}} -n {{environment}}

    # Run smoke tests
    just smoke-test {{service}} {{environment}}
```

### Container & Docker Patterns

**REQUIRED**:
- ✅ Multi-stage Docker builds
- ✅ Layer caching optimization
- ✅ Image scanning (Trivy, Snyk)
- ✅ Minimal base images (distroless, Alpine)
- ✅ Multi-arch builds (AMD64, ARM64)

**Example Pattern**:
```just
# Container configuration
registry := env_var_or_default("CONTAINER_REGISTRY", "gcr.io/myproject")
image_tag := `git rev-parse --short HEAD`

# Build container with cache
build-container service:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building {{service}} container..."

    # Multi-stage build with BuildKit
    DOCKER_BUILDKIT=1 docker build \
        --target production \
        --cache-from {{registry}}/{{service}}:latest \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg VERSION={{image_tag}} \
        --platform linux/amd64,linux/arm64 \
        -t {{registry}}/{{service}}:{{image_tag}} \
        -t {{registry}}/{{service}}:latest \
        -f services/{{service}}/Dockerfile \
        services/{{service}}/

    # Scan for vulnerabilities
    trivy image --severity HIGH,CRITICAL {{registry}}/{{service}}:{{image_tag}}
```

### Kubernetes Integration

**REQUIRED**:
- ✅ Declarative manifests (YAML)
- ✅ Helm chart support
- ✅ Kustomize overlays
- ✅ ConfigMap/Secret management
- ✅ Rolling updates with health checks

**Example Pattern**:
```just
# Kubernetes cluster context
k8s_context := env_var_or_default("K8S_CONTEXT", "prod-cluster")
namespace := env_var_or_default("K8S_NAMESPACE", "default")

# Apply Kubernetes manifests
k8s-apply service environment:
    #!/usr/bin/env bash
    set -euo pipefail

    # Switch context
    kubectl config use-context {{k8s_context}}

    # Create namespace if not exists
    kubectl create namespace {{namespace}} --dry-run=client -o yaml | kubectl apply -f -

    # Apply with kustomize
    kubectl apply -k "k8s/{{service}}/overlays/{{environment}}/" -n {{namespace}}

    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod \
        -l app={{service}} \
        -n {{namespace}} \
        --timeout=300s

# Rollback deployment
k8s-rollback service:
    #!/usr/bin/env bash
    kubectl rollout undo deployment/{{service}} -n {{namespace}}
    kubectl rollout status deployment/{{service}} -n {{namespace}}
```

### Service Mesh Integration

**REQUIRED**:
- ✅ Istio/Linkerd virtual services
- ✅ Traffic splitting for canary
- ✅ Circuit breaker configuration
- ✅ Mutual TLS (mTLS)
- ✅ Distributed tracing

**Example Pattern**:
```just
# Canary deployment with traffic splitting
canary-deploy service version weight="10":
    #!/usr/bin/env bash
    set -euo pipefail

    # Deploy canary version
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: {{service}}-canary
  namespace: {{namespace}}
spec:
  selector:
    app: {{service}}
    version: {{version}}
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{service}}
  namespace: {{namespace}}
spec:
  hosts:
  - {{service}}
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: {{service}}-canary
        port:
          number: 80
      weight: 100
  - route:
    - destination:
        host: {{service}}
        port:
          number: 80
      weight: $((100 - {{weight}}))
    - destination:
        host: {{service}}-canary
        port:
          number: 80
      weight: {{weight}}
EOF

    echo "✓ Canary deployed with {{weight}}% traffic"
```

### Observability & Monitoring

**REQUIRED**:
- ✅ Prometheus metrics export
- ✅ Distributed tracing (Jaeger, Zipkin)
- ✅ Structured logging (JSON)
- ✅ APM integration (Datadog, New Relic)
- ✅ SLO/SLI definitions

**Example Pattern**:
```just
# Check service health and metrics
monitor-service service:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Checking {{service}} health..."

    # Health endpoint
    kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl -- \
        curl -sf http://{{service}}.{{namespace}}.svc.cluster.local/health

    # Metrics endpoint
    echo "Fetching metrics..."
    kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl -- \
        curl -sf http://{{service}}.{{namespace}}.svc.cluster.local/metrics | grep -E "^# HELP|^http_"

    # Check error rate
    error_rate=$(kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl -- \
        curl -sf "http://prometheus.monitoring.svc.cluster.local/api/v1/query?query=rate(http_requests_total{service=\"{{service}}\",status=~\"5..\"}[5m])" | \
        jq -r '.data.result[0].value[1]')

    echo "Current 5xx error rate: $error_rate"
```

### Multi-Region Deployment

**REQUIRED**:
- ✅ Region-aware deployments
- ✅ Cross-region traffic management
- ✅ Data replication strategies
- ✅ Disaster recovery procedures
- ✅ Blue-green across regions

**Example Pattern**:
```just
# Deploy to multiple regions
regions := "us-east-1 us-west-2 eu-west-1"

deploy-multi-region service version:
    #!/usr/bin/env bash
    set -euo pipefail

    for region in {{regions}}; do
        echo "Deploying to $region..."

        # Switch to region context
        kubectl config use-context "$region-cluster"

        # Deploy
        just k8s-apply {{service}} production

        # Validate
        just health-check {{service}} "$region"

        echo "✓ Deployed to $region"
    done

    echo "✓ Multi-region deployment complete"
```

### CI/CD Integration

**REQUIRED**:
- ✅ GitOps workflows (ArgoCD, Flux)
- ✅ Automated testing in pipeline
- ✅ Image promotion across environments
- ✅ Automated rollback on failure
- ✅ Deployment approvals

**Example Pattern**:
```just
# CI pipeline integration
ci-pipeline:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running CI pipeline..."

    # Lint
    just lint

    # Unit tests
    just test-unit

    # Build containers
    just build-all-services

    # Integration tests
    just test-integration

    # Security scan
    just scan-containers

    # Push to staging
    just deploy-all staging

    # E2E tests
    just test-e2e staging

    echo "✓ CI pipeline passed"
```

### Auto-Scaling Configuration

**REQUIRED**:
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Vertical Pod Autoscaler (VPA)
- ✅ Cluster autoscaling
- ✅ Load testing recipes
- ✅ Scaling metrics

**Example Pattern**:
```just
# Configure autoscaling
configure-autoscaling service min_replicas max_replicas cpu_threshold:
    #!/usr/bin/env bash
    set -euo pipefail

    kubectl autoscale deployment {{service}} \
        --min={{min_replicas}} \
        --max={{max_replicas}} \
        --cpu-percent={{cpu_threshold}} \
        -n {{namespace}}

    # Custom metrics (RPS-based)
    kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{service}}-hpa
  namespace: {{namespace}}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{service}}
  minReplicas: {{min_replicas}}
  maxReplicas: {{max_replicas}}
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
EOF
```

### Service Dependencies

**REQUIRED**:
- ✅ Dependency graph management
- ✅ Service discovery
- ✅ Circuit breaker patterns
- ✅ Retry/timeout configuration
- ✅ Graceful degradation

**Example Pattern**:
```just
# Service dependency map
service_deps := '{
  "api": ["auth", "database"],
  "gateway": ["api", "auth"],
  "worker": ["database", "queue"]
}'

# Deploy with dependency order
deploy-with-deps service:
    #!/usr/bin/env bash
    set -euo pipefail

    # Get dependencies
    deps=$(echo '{{service_deps}}' | jq -r '.["{{service}}"][]' 2>/dev/null || echo "")

    # Deploy dependencies first
    for dep in $deps; do
        echo "Deploying dependency: $dep"
        just deploy-service "$dep" production
    done

    # Deploy main service
    echo "Deploying {{service}}"
    just deploy-service {{service}} production
```

### Cost Optimization

**REQUIRED**:
- ✅ Spot instance support
- ✅ Resource requests/limits optimization
- ✅ Idle resource cleanup
- ✅ Cost tracking per service
- ✅ Right-sizing recommendations

**Example Pattern**:
```just
# Clean up unused resources
cleanup-idle-resources:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up idle resources..."

    # Delete old completed jobs
    kubectl delete job --field-selector status.successful=1 -n {{namespace}}

    # Clean up old replica sets
    kubectl delete replicaset --field-selector 'status.replicas=0' -n {{namespace}}

    # Remove unused PVCs
    kubectl get pvc -n {{namespace}} -o json | \
        jq -r '.items[] | select(.status.phase=="Bound" and (.spec.volumeName | startswith("unused"))) | .metadata.name' | \
        xargs -r kubectl delete pvc -n {{namespace}}

    echo "✓ Cleanup complete"
```

### Chaos Engineering

**REQUIRED**:
- ✅ Chaos Mesh integration
- ✅ Failure injection recipes
- ✅ Network latency simulation
- ✅ Pod failure simulation
- ✅ Recovery validation

**Example Pattern**:
```just
# Run chaos experiment
chaos-test service experiment:
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{experiment}}" in
        pod-failure)
            kubectl apply -f - <<EOF
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: {{service}}-pod-failure
  namespace: {{namespace}}
spec:
  action: pod-failure
  mode: one
  duration: "30s"
  selector:
    namespaces:
      - {{namespace}}
    labelSelectors:
      app: {{service}}
EOF
            ;;
        network-latency)
            kubectl apply -f - <<EOF
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: {{service}}-network-delay
  namespace: {{namespace}}
spec:
  action: delay
  mode: one
  selector:
    namespaces:
      - {{namespace}}
    labelSelectors:
      app: {{service}}
  delay:
    latency: "100ms"
  duration: "60s"
EOF
            ;;
        *)
            echo "Unknown experiment: {{experiment}}"
            exit 1
            ;;
    esac

    echo "✓ Chaos experiment started"
```

## Output Requirements

When generating justfiles with these preferences:

1. **Always include**:
   - Service-per-recipe organization
   - Container build and push workflows
   - Kubernetes manifest application
   - Health check validation
   - Multi-environment support
   - Observability integration

2. **Never include**:
   - Hardcoded cluster endpoints
   - Manual scaling (always HPA)
   - Single-region deployments (unless specified)
   - Unmonitored deployments

3. **Code style**:
   - Cloud-agnostic where possible
   - Infrastructure as code
   - GitOps compatible
   - Observability-first
   - Resilience patterns built-in

## Validation Checklist

Before accepting generated justfile:

- [ ] All services have health checks
- [ ] Container images are scanned
- [ ] Kubernetes manifests are declarative
- [ ] Auto-scaling is configured
- [ ] Monitoring/logging is integrated
- [ ] Multi-region deployment supported
- [ ] Rollback procedures included
- [ ] Service dependencies managed
- [ ] Cost optimization considered
- [ ] Chaos engineering ready

---

**Last Updated**: 2025-12-12
**Target Platforms**: Kubernetes, AWS ECS, GCP GKE, Azure AKS
**Architecture**: Microservices, Cloud-Native
