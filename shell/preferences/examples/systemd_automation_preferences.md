# Systemd Service Automation Preferences

> **Purpose**: Standard preferences for deploying and managing systemd services.
> **Project**: Enterprise Web Platform
> **Team**: Platform Engineering
> **Last Updated**: 2025-12-12

---

## Project Context

**Project Name**: Enterprise Web Platform

**Description**: Multi-service web platform running on Ubuntu 22.04 LTS with systemd service management. All application services run as unprivileged users with centralized logging to journald and monitoring via Prometheus.

**Team**: Platform Engineering

**Contact**: platform-team@company.com

---

## Organization Standards

### Required Elements
- All scripts must include company copyright header:
  ```bash
  #!/bin/bash
  # Copyright (c) 2025 Company Name
  # Licensed under MIT License
  ```

- Script version follows semver (v1.2.3)
- Minimum 2 code reviews required for production scripts
- Security team approval required for scripts accessing credentials
- Change log maintained in script header or separate CHANGELOG.md

### Code Review Process
1. Developer creates PR with script
2. Automated tests run (syntax, shellcheck, integration)
3. Two senior engineers approve
4. Security team approves if credentials/network operations involved
5. Merge to main, deploy to staging
6. Staging validation (24h minimum)
7. Production deployment with rollback plan

---

## Technology Stack

### Operating System
- Distribution: Ubuntu
- Version: 22.04 LTS (Jammy Jellyfish)
- Architecture: x86_64

### Init System
- systemd version 249+
- No SysV init compatibility required
- All services managed via systemd units

### Package Manager
- apt (Debian/Ubuntu)
- No snap packages (use apt or manual installation)
- Package repositories: official Ubuntu repos + company internal repo

### Container Platform
- Docker 24.0+
- Container services run as systemd units
- No Docker Compose in production (use systemd + docker run)

### Orchestration
- Not applicable (monolithic deployment on VMs)
- Future migration to Kubernetes planned

### Cloud Provider
- AWS (EC2 for compute, RDS for databases, S3 for storage)
- Instance types: t3.medium for services, t3.large for databases
- VPC with private subnets for application services

### Configuration Management
- Ansible for server provisioning
- Shell scripts for service deployment and management
- Git for configuration version control

---

## Security Requirements

### Credential Management

**Method**: AWS Secrets Manager

**Requirements**:
- All credentials stored in AWS Secrets Manager
- Scripts retrieve credentials via AWS CLI using IAM instance role
- No environment variables for secrets (except AWS_REGION)
- Credential files MUST have 400 permissions (read-only by owner)
- Credentials cached locally for max 5 minutes, then re-fetched

**Example**:
```bash
# Retrieve database password from AWS Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id prod/myapp/database \
    --query SecretString \
    --output text | jq -r '.password')

# Validate retrieved credential
if [[ -z "$DB_PASSWORD" ]]; then
    error "Failed to retrieve database password from Secrets Manager"
fi
```

### Encryption
- TLS 1.3 minimum for all network communications
- Certificate authority: company CA (ca.company.internal)
- Certificate validation: MUST validate against company CA bundle
- Certificate auto-renewal via certbot systemd timer

### Access Control
- Minimum privilege: All services run as non-root dedicated users
- Sudo requirements: Only for systemctl operations, file permission changes
- Service account naming: `svc-{application-name}` (e.g., `svc-webapp`, `svc-api`)
- Service accounts have /bin/false shell and no login capability

### Compliance
- SOC 2 Type II compliance required
- Audit logging for all privileged operations
- Access logs retained for 90 days minimum
- No personally identifiable information (PII) in logs

---

## Logging and Monitoring

### Logging

**Destination**: journald (systemd)

**Format**: JSON structured logs

**Required Fields**:
```json
{
  "timestamp": "2025-12-12T10:30:45.123Z",
  "level": "INFO",
  "service": "webapp",
  "environment": "production",
  "hostname": "web-01.company.internal",
  "pid": 12345,
  "message": "User authentication successful",
  "correlation_id": "abc123xyz",
  "user_id": "user-456"
}
```

**Log Levels**:
- DEBUG: Detailed diagnostic information (disabled in production)
- INFO: General informational messages
- WARN: Warning messages, degraded functionality
- ERROR: Error conditions, request failed
- CRITICAL: System unusable, immediate attention required

**Retention**:
- journald local retention: 7 days
- CloudWatch Logs retention: 90 days
- S3 archive: 7 years (compliance requirement)

**Shipping**:
- journald → CloudWatch Logs via cloudwatch-agent
- Real-time streaming for CRITICAL and ERROR levels
- Batch upload (5-minute intervals) for INFO and WARN

### Monitoring

**Metrics System**: Prometheus + Grafana

**Metrics Collection**:
- Prometheus node exporter on all servers
- Application metrics via StatsD → Prometheus
- Custom metrics exported via `/metrics` HTTP endpoint
- Scrape interval: 15 seconds

**Health Checks**:
- All services MUST expose HTTP `/health` endpoint
- Health check returns JSON with status and checks:
  ```json
  {
    "status": "healthy",
    "checks": {
      "database": "ok",
      "cache": "ok",
      "disk_space": "ok"
    },
    "timestamp": "2025-12-12T10:30:45Z"
  }
  ```
- systemd health check every 30 seconds
- 3 consecutive failures trigger alert

**Alerting**: PagerDuty + Slack

**Alert Routing**:
- CRITICAL: Page on-call engineer immediately
- ERROR: Post to #ops-alerts Slack channel
- WARNING: Post to #ops-monitoring Slack channel (business hours only)

**Alert Requirements**:
- Alert must include service name, hostname, error message
- Alert must include link to runbook
- Alert must include link to relevant Grafana dashboard
- Alert must include correlation ID for log searching

---

## Error Handling

### Error Severity Levels
- **CRITICAL**: Service down, database unreachable, data loss risk
  - Action: Page on-call engineer, initiate incident response
- **ERROR**: Request failed, feature unavailable, retry exhausted
  - Action: Log to CloudWatch, alert to Slack, create ticket
- **WARNING**: Degraded performance, retry succeeded, approaching limits
  - Action: Log to CloudWatch, post to Slack (business hours)
- **INFO**: Normal operation, successful requests
  - Action: Log to CloudWatch
- **DEBUG**: Detailed diagnostic information
  - Action: Log locally (disabled in production)

### Retry Logic
- Transient errors (network timeout, rate limit): 3 retries
- Backoff strategy: Exponential (1s, 2s, 4s)
- Maximum retry duration: 10 seconds
- Non-retryable errors: authentication failures, invalid input, not found

### Notification
- Critical errors notify: on-call engineer via PagerDuty
- Error notification method: PagerDuty + Slack #ops-alerts
- Include in notifications:
  - Service name and hostname
  - Error message and stack trace
  - Correlation ID for log search
  - Link to runbook
  - Time of occurrence

---

## Deployment Patterns

### Deployment Strategy
- **Web services**: Blue/green deployment
- **API services**: Rolling update (20% at a time)
- **Worker services**: Drain queue, then restart
- **Database migrations**: Run before application deployment, with rollback plan

### Pre-Deployment Checks
- [ ] All tests passing in CI/CD
- [ ] Staging validation completed (minimum 24 hours)
- [ ] Database backup created (if schema changes)
- [ ] Rollback plan documented
- [ ] On-call engineer notified
- [ ] Change ticket approved

### Deployment Steps
1. Create pre-deployment backup
2. Stop load balancer traffic to target instances
3. Run database migrations (if applicable)
4. Deploy new version
5. Run post-deployment smoke tests
6. Restore load balancer traffic
7. Monitor for 15 minutes
8. If errors detected, rollback automatically

### Post-Deployment
- [ ] Smoke tests pass (HTTP 200 on `/health`)
- [ ] Integration tests pass
- [ ] Error rate within normal range (<0.1%)
- [ ] Response time within SLA (p95 <200ms)
- [ ] All metrics green in Grafana

### Rollback
- Automatic rollback on:
  - Health check failures (3 consecutive)
  - Error rate spike (>5% of requests)
  - Critical alert triggered
- Rollback time limit: 5 minutes maximum
- Rollback notification: PagerDuty + Slack
- Post-rollback: Create incident ticket, schedule post-mortem

---

## Systemd Service Standards

### Service File Template
```ini
[Unit]
Description=MyApp Service
Documentation=https://docs.company.internal/myapp
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=svc-myapp
Group=svc-myapp
WorkingDirectory=/opt/myapp

# Environment
Environment="NODE_ENV=production"
Environment="PORT=8080"
EnvironmentFile=/etc/myapp/environment

# Process management
ExecStartPre=/opt/myapp/scripts/pre-start.sh
ExecStart=/opt/myapp/bin/server
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/opt/myapp/scripts/graceful-shutdown.sh
Restart=on-failure
RestartSec=5s
TimeoutStartSec=60s
TimeoutStopSec=30s

# Resource limits
MemoryLimit=2G
CPUQuota=150%
TasksMax=512

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/myapp/data /var/log/myapp

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

### Service Management Requirements
- All service files in `/etc/systemd/system/`
- Service file permissions: 644
- After changes: `systemctl daemon-reload` MUST be called
- Service enabled: `systemctl enable myapp.service`
- Service started only if not active
- Service health verified after start (30-second timeout)

### Graceful Shutdown
- All services MUST support SIGTERM for graceful shutdown
- Shutdown timeout: 30 seconds
- Shutdown steps:
  1. Stop accepting new requests
  2. Finish processing current requests
  3. Close database connections
  4. Write shutdown marker to logs
  5. Exit with code 0

---

## File Permissions

### Scripts
- Executable scripts: 750 (rwxr-x---)
- Library scripts (sourced): 640 (rw-r-----)
- Ownership: root:svc-{app}

### Configuration Files
- Application configs: 640 (rw-r-----)
- System configs: 644 (rw-r--r--)
- Ownership: root:svc-{app}

### Credential Files
- Permissions: 400 (r--------)
- Ownership: svc-{app}:svc-{app}
- Validation required: YES (check before loading)

### Log Files
- Permissions: 640 (rw-r-----)
- Ownership: svc-{app}:svc-{app}
- Rotation: Daily, keep 7 days locally

---

## Naming Conventions

### Script Names
- Format: `{action}-{resource}.sh`
- Examples: `deploy-webapp.sh`, `backup-database.sh`, `restart-services.sh`

### Function Names
- Format: `{verb}_{noun}`
- Examples: `create_user`, `validate_config`, `start_service`, `check_health`

### Variable Names
- Constants: UPPERCASE_WITH_UNDERSCORES
- Local variables: lowercase_with_underscores
- Environment variables: UPPERCASE_WITH_UNDERSCORES

### Service Names
- Format: `{app-name}.service`
- Examples: `webapp.service`, `api.service`, `worker.service`

---

## Testing Requirements

### Test Framework
- BATS (Bash Automated Testing System) for unit tests
- Integration tests in Docker containers
- Smoke tests on staging before production

### Coverage Requirements
- Minimum coverage: 70% of functions
- Critical functions (credential handling, deployment): 100% coverage

### Test Environments
- Docker containers for unit tests (Ubuntu 22.04 image)
- Staging environment mirrors production (1/4 scale)
- Production-like test data (anonymized)

### Required Tests
- [ ] Syntax validation (bash -n, shellcheck)
- [ ] Unit tests for all functions
- [ ] Integration tests for service deployment
- [ ] Smoke tests for health endpoint
- [ ] Rollback tests
- [ ] Security tests (credential leaks, permission checks)

---

## Additional Requirements

### Monitoring Dashboards
- All services MUST have Grafana dashboard
- Dashboard includes:
  - Request rate (requests/second)
  - Error rate (errors/second, %)
  - Response time (p50, p95, p99)
  - System resources (CPU, memory, disk)
  - Active connections
  - Health check status

### Documentation
- README.md required for all scripts
- Runbook required for all production services
- Runbook includes:
  - Service architecture diagram
  - Deployment steps
  - Rollback procedure
  - Common issues and solutions
  - Escalation contacts

### Compliance
- All scripts reviewed for SOC 2 compliance
- Security team approval before production deployment
- Quarterly security audit of all production scripts

---

## Maintenance

**Version**: 2.3.0
**Last Updated**: 2025-12-12
**Next Review**: 2026-03-12
**Owner**: Platform Engineering Team

### Changelog

#### [2.3.0] - 2025-12-12
- Updated systemd service template with security hardening
- Added CloudWatch Logs integration requirements
- Updated health check format to JSON

#### [2.2.0] - 2025-09-01
- Migrated credential management to AWS Secrets Manager
- Updated logging format to JSON structured logs
- Added PagerDuty integration for critical alerts

#### [2.1.0] - 2025-06-01
- Updated Ubuntu version to 22.04 LTS
- Added Grafana dashboard requirements
- Updated rollback automation

#### [2.0.0] - 2025-03-01
- Migrated from SysV init to systemd
- Updated deployment strategy to blue/green
- Added comprehensive monitoring requirements

#### [1.0.0] - 2024-12-01
- Initial preferences document for systemd automation
