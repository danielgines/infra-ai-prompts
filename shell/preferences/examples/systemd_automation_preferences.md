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

---

## Service Hardening Preferences

### Security Hardening Directives

**Philosophy**: Defense in depth - minimize attack surface by restricting service capabilities to the minimum required for operation. Every hardening directive enabled is one less attack vector.

#### PrivateTmp (Temporary File Isolation)

**Directive**: `PrivateTmp=yes`

**Purpose**: Isolates `/tmp` and `/var/tmp` with service-specific namespaces, preventing services from accessing temporary files created by other processes.

**Rationale**:
- Prevents symlink attacks (CVE-2002-0069 and similar)
- Prevents information disclosure through shared temporary directories
- Automatically cleans up service-specific temp files on service stop

**Example**:
```ini
[Service]
PrivateTmp=yes
```

**When to relax**: Services that need to share temporary files with other processes. Document why sharing is required.

---

#### ProtectSystem (Filesystem Protection)

**Directive**: `ProtectSystem=strict`

**Options**:
- `no`: No protection (default, not recommended)
- `yes`: Read-only `/usr` and `/boot`
- `full`: Read-only `/usr`, `/boot`, and `/etc`
- `strict`: Entire filesystem read-only except explicit exceptions

**Rationale**:
- Prevents service from modifying system files
- Reduces impact of code injection or remote code execution
- Forces explicit declaration of writable paths (principle of least privilege)

**Example (Recommended)**:
```ini
[Service]
ProtectSystem=strict
ReadWritePaths=/var/log/myapp /opt/myapp/data
```

**When to relax**: Services that legitimately write to system directories. Use `ReadWritePaths=` to specify only what's needed.

---

#### ProtectHome (Home Directory Protection)

**Directive**: `ProtectHome=yes`

**Options**:
- `no`: Home directories accessible
- `yes`: Home directories inaccessible (appear empty)
- `read-only`: Home directories read-only
- `tmpfs`: Home directories replaced with empty tmpfs

**Rationale**:
- Prevents services from reading user data (privacy protection)
- Prevents services from modifying user configurations
- Reduces data exfiltration risk

**Example**:
```ini
[Service]
ProtectHome=yes
```

**When to relax**: Services that process user-specific data (backup agents, file indexers). Document specific user directories needed.

---

#### NoNewPrivileges (Privilege Escalation Prevention)

**Directive**: `NoNewPrivileges=yes`

**Purpose**: Ensures service cannot gain new privileges via setuid, setgid, or filesystem capabilities.

**Rationale**:
- Prevents privilege escalation exploits
- Mandatory for services running as unprivileged users
- No performance impact

**Example**:
```ini
[Service]
NoNewPrivileges=true
```

**When to relax**: Never for production services. If a service needs to escalate privileges, redesign the architecture.

---

#### PrivateDevices (Device Access Restriction)

**Directive**: `PrivateDevices=yes`

**Purpose**: Limits access to `/dev`, only exposes pseudo-devices like `/dev/null`, `/dev/zero`, `/dev/random`.

**Rationale**:
- Prevents access to physical devices (disks, USB)
- Prevents services from bypassing filesystem permissions via raw device access
- Protects against hardware-level attacks

**Example**:
```ini
[Service]
PrivateDevices=yes
```

**When to relax**: Services that need hardware access (USB daemons, disk monitoring). Specify exact devices with `DeviceAllow=`.

---

#### ProtectKernelTunables (Kernel Protection)

**Directive**: `ProtectKernelTunables=yes`

**Purpose**: Makes `/proc/sys`, `/sys`, `/proc/sysrq-trigger`, `/proc/latency_stats`, `/proc/acpi`, `/proc/timer_stats`, `/proc/fs`, and `/proc/irq` read-only.

**Rationale**:
- Prevents services from modifying kernel behavior
- Prevents privilege escalation via kernel tuning
- Essential for unprivileged services

**Example**:
```ini
[Service]
ProtectKernelTunables=yes
```

**When to relax**: System tuning tools or monitoring agents. Very rare. Require security team approval.

---

#### ProtectControlGroups (Cgroup Protection)

**Directive**: `ProtectControlGroups=yes`

**Purpose**: Makes cgroup hierarchy read-only.

**Rationale**:
- Prevents services from escaping resource limits
- Prevents container breakout attempts
- No legitimate reason for services to modify cgroups

**Example**:
```ini
[Service]
ProtectControlGroups=yes
```

**When to relax**: Container runtimes (Docker, containerd). Document why modification is required.

---

#### RestrictAddressFamilies (Network Restriction)

**Directive**: `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6`

**Purpose**: Limits which network address families the service can use.

**Rationale**:
- Prevents use of exotic protocols (AF_PACKET for raw sockets, AF_NETLINK)
- Reduces attack surface
- Forces explicit declaration of network requirements

**Common configurations**:
```ini
# Web service (HTTP/HTTPS)
RestrictAddressFamilies=AF_INET AF_INET6

# Local IPC only
RestrictAddressFamilies=AF_UNIX

# Web service + Unix sockets
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6

# No network access
RestrictAddressFamilies=
```

**When to relax**: Services that need raw sockets (network monitoring). Require security approval.

---

#### RestrictNamespaces (Namespace Restriction)

**Directive**: `RestrictNamespaces=yes`

**Purpose**: Prevents service from creating new namespaces (mount, PID, network, etc.).

**Rationale**:
- Prevents container escape techniques
- Prevents privilege escalation via namespace manipulation
- No legitimate use case for most services

**Example**:
```ini
[Service]
RestrictNamespaces=yes
```

**When to relax**: Container runtimes, sandboxing tools. Require explicit justification.

---

#### SystemCallFilter (System Call Filtering)

**Directive**: `SystemCallFilter=@system-service`

**Purpose**: Restricts which system calls the service can execute.

**Recommended filter groups**:
- `@system-service`: Standard system services (recommended baseline)
- `@network-io`: Network operations
- `@file-system`: File operations
- `@basic-io`: Basic I/O operations

**Block dangerous calls**:
```ini
# Block dangerous calls explicitly
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @reboot @debug
```

**Explanation of blocked groups**:
- `@privileged`: Privilege escalation calls (setuid, setgid)
- `@resources`: Resource manipulation (renice, setrlimit)
- `@mount`: Filesystem mounting
- `@swap`: Swap management
- `@reboot`: System reboot/shutdown
- `@debug`: Debugging/tracing (ptrace)

**Example (Web service)**:
```ini
[Service]
SystemCallFilter=@system-service @network-io
SystemCallFilter=~@privileged @resources
```

**When to relax**: Debugging or profiling tools. Enable only specific syscalls needed.

---

### Complete Hardened Service Template

**Use case**: Production web application service

```ini
[Unit]
Description=MyApp Web Service (Hardened)
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
ExecStart=/opt/myapp/bin/server
Restart=on-failure
RestartSec=5s
TimeoutStartSec=60s
TimeoutStopSec=30s

# Resource limits
MemoryMax=2G
CPUQuota=150%
TasksMax=512

# Security hardening (defense in depth)
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
RestrictNamespaces=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
LockPersonality=yes
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources
ReadWritePaths=/opt/myapp/data /var/log/myapp

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

**Testing hardening**:
```bash
# Analyze security settings
systemd-analyze security myapp.service

# Score: 9.2 EXCELLENT (lower is better)
# Shows which directives are enabled/missing

# Verify directives applied
systemctl show myapp.service | grep -E 'Private|Protect|Restrict|NoNew'
```

---

## Restart Policy Standards

### Restart Options by Service Type

**Directive**: `Restart=`

**Options**: `no`, `on-success`, `on-failure`, `on-abnormal`, `on-watchdog`, `on-abort`, `always`

---

#### Restart=always (Critical Services)

**Use for**:
- Database servers (PostgreSQL, MySQL)
- Monitoring agents (Prometheus Node Exporter, Datadog Agent)
- Critical infrastructure (DNS, DHCP)
- Load balancers

**Rationale**: Service must be running at all times. Downtime has severe impact.

**Example**:
```ini
[Service]
Restart=always
RestartSec=5s
```

**Monitoring**: Alert if restart count exceeds threshold (5 restarts in 1 hour).

---

#### Restart=on-failure (Application Services)

**Use for**:
- Web applications
- API servers
- Background workers
- Microservices

**Rationale**: Restart on errors, but respect manual stops (systemctl stop).

**Example**:
```ini
[Service]
Restart=on-failure
RestartSec=10s
StartLimitBurst=5
StartLimitIntervalSec=300
```

**When it restarts**:
- Non-zero exit code
- Process killed by signal (except SIGTERM, SIGHUP, SIGINT, SIGPIPE)
- Timeout occurred
- Watchdog triggered

**When it does NOT restart**:
- Clean exit (exit code 0)
- Manual stop (`systemctl stop`)

---

#### Restart=on-abnormal (Batch Jobs)

**Use for**:
- Scheduled tasks (systemd timers)
- Data processing jobs
- Backup scripts
- ETL pipelines

**Rationale**: Restart only on abnormal termination (signals, timeouts). Respect normal completion.

**Example**:
```ini
[Service]
Type=oneshot
Restart=on-abnormal
RestartSec=30s
```

**When it restarts**:
- Process killed by signal (except SIGTERM)
- Timeout occurred
- Watchdog triggered

**When it does NOT restart**:
- Clean exit (any exit code, including non-zero)
- Manual stop

---

#### Restart=no (One-Shot Services)

**Use for**:
- System initialization scripts
- One-time setup tasks
- Manual intervention required on failure

**Example**:
```ini
[Service]
Type=oneshot
Restart=no
```

---

### RestartSec Standards (Exponential Backoff)

**Purpose**: Prevent restart storms, allow external dependencies to recover.

**Basic configuration**:
```ini
[Service]
RestartSec=5s    # Simple fixed delay
```

**Recommended configuration** (built-in exponential backoff):
```ini
[Service]
RestartSec=10s                    # Base delay: 10 seconds
StartLimitIntervalSec=300         # Window: 5 minutes
StartLimitBurst=5                 # Max restarts in window: 5
```

**How it works**:
1. First restart: Immediate (or RestartSec delay)
2. Second restart: 10s
3. Third restart: 20s (doubled)
4. Fourth restart: 40s (doubled)
5. Fifth restart: 80s (doubled)
6. After 5 restarts in 5 minutes: Service enters failed state

**Progressive delay by service criticality**:

| Service Criticality | RestartSec | StartLimitBurst | StartLimitIntervalSec |
|---------------------|------------|-----------------|------------------------|
| Critical (database) | 5s         | 10              | 600s (10 min)          |
| High (API)          | 10s        | 5               | 300s (5 min)           |
| Medium (worker)     | 30s        | 3               | 180s (3 min)           |
| Low (batch job)     | 60s        | 2               | 120s (2 min)           |

**Example (High priority web service)**:
```ini
[Service]
Restart=on-failure
RestartSec=10s
StartLimitIntervalSec=300
StartLimitBurst=5
```

**Monitoring restart behavior**:
```bash
# Show service restart count
systemctl show myapp.service -p NRestarts

# Show restart history
journalctl -u myapp.service | grep -E 'Started|Stopped|Failed'

# Alert if restart count > 5 in 1 hour
```

---

## Resource Limit Templates

### CPU Quota Standards

**Directive**: `CPUQuota=`

**Purpose**: Limit CPU usage to prevent resource exhaustion.

**Units**: Percentage of one CPU core (100% = 1 core, 200% = 2 cores)

**Standards by workload**:

| Workload Type | CPUQuota | Rationale |
|---------------|----------|-----------|
| Web service (frontend) | 150% | CPU-light, mostly I/O bound |
| API service (backend) | 200% | Moderate CPU for processing |
| Worker (queue processor) | 300% | CPU-intensive batch processing |
| Database | 400% | High CPU for queries and indexing |
| Monitoring agent | 50% | Low priority, background task |

**Example (Web service)**:
```ini
[Service]
CPUQuota=150%
CPUAccounting=yes
```

**Monitoring CPU usage**:
```bash
# Show CPU usage for service
systemctl status myapp.service | grep -i cpu

# Show CPU accounting
systemd-cgtop -n 1 | grep myapp

# Alert if CPU usage > CPUQuota for 5 minutes
```

---

### Memory Limits

**Directives**: `MemoryMax=`, `MemoryHigh=`, `MemorySwapMax=`

**MemoryMax vs MemoryHigh**:
- `MemoryHigh`: Soft limit, throttle service when exceeded
- `MemoryMax`: Hard limit, kill service (OOM) when exceeded

**Recommended configuration**:
```ini
[Service]
MemoryHigh=1.5G    # Start throttling at 1.5GB
MemoryMax=2G       # Kill at 2GB
MemorySwapMax=0    # No swap (predictable performance)
MemoryAccounting=yes
```

**Standards by workload**:

| Workload Type | MemoryHigh | MemoryMax | Rationale |
|---------------|------------|-----------|-----------|
| Web service (Node.js) | 1.5G | 2G | Node typically needs 1GB, allow headroom |
| API service (Python) | 1G | 1.5G | Python moderate memory usage |
| Worker (batch) | 3G | 4G | Large data processing |
| Database (PostgreSQL) | 7G | 8G | Leave 20% for connections |
| Cache (Redis) | 3.5G | 4G | Set maxmemory in Redis config too |

**Swap policy**:
```ini
# Production services: No swap (predictable latency)
MemorySwapMax=0

# Development: Allow swap
MemorySwapMax=2G
```

**Monitoring memory**:
```bash
# Show memory usage
systemctl status myapp.service | grep Memory

# Show detailed memory accounting
systemd-cgtop -n 1 -m | grep myapp

# Check for OOM kills
journalctl -u myapp.service | grep -i "out of memory"
```

---

### TasksMax (Fork Bomb Prevention)

**Directive**: `TasksMax=`

**Purpose**: Limit number of processes/threads service can create.

**Standards**:

| Service Type | TasksMax | Rationale |
|--------------|----------|-----------|
| Simple daemon | 64 | Single process + few threads |
| Web service (threaded) | 512 | Thread pool + workers |
| Database | 1024 | Connection pool + background workers |
| Container runtime | 4096 | Must spawn many containers |

**Example**:
```ini
[Service]
TasksMax=512
TasksAccounting=yes
```

**Monitoring tasks**:
```bash
# Show task count
systemctl status myapp.service | grep Tasks

# Alert if tasks > 80% of TasksMax
```

---

### IOWeight (I/O Prioritization)

**Directive**: `IOWeight=`

**Purpose**: Prioritize disk I/O between services.

**Range**: 1-10000 (default: 100)

**Standards**:

| Service Type | IOWeight | Rationale |
|--------------|----------|-----------|
| Database | 500 | High priority for query performance |
| Log aggregator | 200 | Moderate I/O for log shipping |
| Backup service | 50 | Low priority, background task |
| Web service | 100 | Default, mostly network I/O |

**Example**:
```ini
[Service]
IOWeight=500
IOAccounting=yes
```

---

### Complete Resource-Constrained Service Example

```ini
[Unit]
Description=MyApp Worker (Resource Constrained)
After=network-online.target

[Service]
Type=simple
User=svc-myapp-worker
Group=svc-myapp-worker
WorkingDirectory=/opt/myapp

ExecStart=/opt/myapp/bin/worker

# Restart policy
Restart=on-failure
RestartSec=30s
StartLimitBurst=3
StartLimitIntervalSec=180

# Resource limits
CPUQuota=300%
CPUAccounting=yes

MemoryHigh=3G
MemoryMax=4G
MemorySwapMax=0
MemoryAccounting=yes

TasksMax=512
TasksAccounting=yes

IOWeight=200
IOAccounting=yes

# Additional limits
LimitNOFILE=4096        # File descriptors
LimitNPROC=512          # Processes

# Security
NoNewPrivileges=true
PrivateTmp=true

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp-worker

[Install]
WantedBy=multi-user.target
```

**Monitoring resource usage**:
```bash
# Real-time monitoring
systemd-cgtop

# Service-specific stats
systemctl show myapp-worker.service | grep -E 'CPU|Memory|Tasks|IO'

# Create Grafana dashboard with queries:
# - rate(systemd_cpu_seconds_total{name="myapp-worker.service"}[5m])
# - systemd_memory_bytes{name="myapp-worker.service"}
```

---

## Timer Unit Preferences

### OnCalendar Standards

**Purpose**: Schedule systemd services using calendar expressions (cron alternative).

**Syntax**: `OnCalendar=DayOfWeek Year-Month-Day Hour:Minute:Second`

---

#### Daily Maintenance Tasks

**Use case**: Database backups, log rotation, cleanup scripts

**Expression**: `OnCalendar=daily`

**Equivalent**: `OnCalendar=*-*-* 00:00:00`

**Example**:
```ini
[Unit]
Description=Daily database backup

[Timer]
OnCalendar=daily
Persistent=yes
AccuracySec=10min
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

**Rationale**:
- `Persistent=yes`: Run backup if server was down at scheduled time
- `AccuracySec=10min`: Allow systemd to batch timers (power efficiency)
- `RandomizedDelaySec=30min`: Distribute load across 30-minute window

---

#### Hourly Health Checks

**Use case**: Monitoring, certificate renewal checks

**Expression**: `OnCalendar=hourly`

**Equivalent**: `OnCalendar=*-*-* *:00:00`

**Example**:
```ini
[Unit]
Description=Hourly certificate expiry check

[Timer]
OnCalendar=hourly
AccuracySec=5min

[Install]
WantedBy=timers.target
```

---

#### Complex Schedules

**Business hours only** (Mon-Fri 9 AM - 5 PM):
```ini
[Timer]
OnCalendar=Mon..Fri *-*-* 09..17:00:00
```

**Twice daily** (6 AM and 6 PM):
```ini
[Timer]
OnCalendar=*-*-* 06,18:00:00
```

**Weekly** (Monday 3 AM):
```ini
[Timer]
OnCalendar=Mon *-*-* 03:00:00
```

**Monthly** (1st day of month, 2 AM):
```ini
[Timer]
OnCalendar=*-*-01 02:00:00
```

**Quarterly** (1st day of Jan/Apr/Jul/Oct):
```ini
[Timer]
OnCalendar=*-01,04,07,10-01 02:00:00
```

---

### OnBootSec (Startup Tasks)

**Purpose**: Run service N seconds after system boot.

**Use case**: System initialization, cache warming, health checks

**Example** (Wait 5 minutes after boot to warm cache):
```ini
[Timer]
OnBootSec=5min
```

---

### OnUnitActiveSec (Periodic Tasks)

**Purpose**: Run service N seconds after previous activation completed.

**Use case**: Continuous polling, metric collection, queue processing

**Example** (Poll every 30 seconds):
```ini
[Timer]
OnUnitActiveSec=30s
```

**Difference from OnCalendar**:
- `OnCalendar`: Fixed schedule (e.g., every hour at :00)
- `OnUnitActiveSec`: Relative to previous run (e.g., 30s after previous run finished)

---

### AccuracySec and RandomizedDelaySec

**Purpose**: Reduce system load by batching timers and distributing execution.

**AccuracySec**: Allow timer to fire within this window (default: 1min)

```ini
[Timer]
OnCalendar=hourly
AccuracySec=10min
# Timer fires between :00 and :10 of each hour
```

**RandomizedDelaySec**: Add random delay (0 to N) to scheduled time

```ini
[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
# Timer fires between 00:00 and 01:00
```

**Use case**: Distribute load when many services scheduled at same time

**Example** (Backup jobs):
```ini
# Without randomization: All 100 servers backup at 00:00 (network spike)
# With randomization: Servers backup between 00:00 and 01:00 (smooth load)

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
```

---

### Persistent (Catch Up Missed Runs)

**Directive**: `Persistent=yes`

**Purpose**: If system was down at scheduled time, run immediately on boot.

**Use case**: Critical scheduled tasks (backups, reports)

**Example**:
```ini
[Timer]
OnCalendar=daily
Persistent=yes
```

**Scenario**:
- Backup scheduled for 00:00
- Server reboots at 23:55
- Scheduled time missed
- With `Persistent=yes`: Backup runs immediately after boot
- Without: Backup skipped until next day

---

### Complete Timer Configuration Examples

**Daily backup with error handling**:

`/etc/systemd/system/backup.timer`:
```ini
[Unit]
Description=Daily backup timer
Documentation=https://wiki.company.internal/backup

[Timer]
OnCalendar=daily
Persistent=yes
AccuracySec=10min
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

`/etc/systemd/system/backup.service`:
```ini
[Unit]
Description=Daily backup service
Documentation=https://wiki.company.internal/backup

[Service]
Type=oneshot
ExecStart=/opt/backup/bin/backup.sh
User=backup
Group=backup

# Timeout if backup takes > 2 hours
TimeoutStartSec=2h

# Don't restart on failure (alert and manual intervention)
Restart=no

# Email admin on failure
OnFailure=notify-admin@.service

StandardOutput=journal
StandardError=journal
SyslogIdentifier=backup
```

**Enable and test**:
```bash
# Enable timer (NOT the service)
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check timer status
systemctl list-timers backup.timer

# Show next scheduled run
systemctl status backup.timer

# Test service manually
sudo systemctl start backup.service

# Check logs
journalctl -u backup.service -n 50
```

---

**Periodic monitoring (every 30 seconds)**:

`/etc/systemd/system/monitor.timer`:
```ini
[Unit]
Description=Health monitoring timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=30s

[Install]
WantedBy=timers.target
```

`/etc/systemd/system/monitor.service`:
```ini
[Unit]
Description=Health monitoring service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/health-check.sh
```

---

## Socket Activation Patterns

### When to Use Socket Activation

**Benefits**:
- Services start on-demand (saves resources)
- Zero downtime deployments (socket held by systemd during restart)
- Parallel service startup (systemd accepts connections while service starts)

**Use cases**:
- Rarely used services (SSH on non-standard ports)
- Services with slow startup (can accept connections before fully initialized)
- Services that need zero-downtime restarts

**Not suitable for**:
- High-traffic services (constant activation overhead)
- Services that need persistent state
- Services with long initialization

---

### TCP Socket Activation (ListenStream)

**Example** (HTTP service on port 8080):

`/etc/systemd/system/myapp.socket`:
```ini
[Unit]
Description=MyApp HTTP Socket
Documentation=https://docs.company.internal/myapp

[Socket]
ListenStream=8080
Accept=no
SocketUser=svc-myapp
SocketGroup=svc-myapp
SocketMode=0600

[Install]
WantedBy=sockets.target
```

`/etc/systemd/system/myapp.service`:
```ini
[Unit]
Description=MyApp HTTP Service
Documentation=https://docs.company.internal/myapp

[Service]
Type=simple
User=svc-myapp
Group=svc-myapp
ExecStart=/opt/myapp/bin/server
StandardInput=socket
StandardOutput=journal
StandardError=journal

# Don't restart automatically (socket handles connections)
Restart=no
```

**How it works**:
1. systemd listens on port 8080
2. Connection arrives
3. systemd starts myapp.service
4. systemd passes socket to service via stdin
5. Service accepts connection and handles request
6. Service remains running for subsequent requests

---

### UDP Socket Activation (ListenDatagram)

**Example** (Syslog receiver):

`/etc/systemd/system/syslog.socket`:
```ini
[Unit]
Description=Syslog UDP Socket

[Socket]
ListenDatagram=514
SocketUser=syslog
SocketGroup=syslog

[Install]
WantedBy=sockets.target
```

---

### Accept=yes vs Accept=no

**Accept=yes**: Systemd spawns new service instance per connection

**Use for**: Simple, stateless services (like `systemd-socket-proxyd`)

```ini
[Socket]
ListenStream=8080
Accept=yes
MaxConnections=64
```

**Accept=no**: Single service instance handles all connections (RECOMMENDED)

**Use for**: Most services (web servers, databases, APIs)

```ini
[Socket]
ListenStream=8080
Accept=no
```

---

### Testing Socket Activation

**Enable socket (not service)**:
```bash
sudo systemctl enable myapp.socket
sudo systemctl start myapp.socket

# Verify socket listening
ss -tlnp | grep 8080
# Should show systemd process

# Check status
systemctl status myapp.socket
# Should show "Active: active (listening)"
```

**Trigger activation**:
```bash
# Connect to port
curl http://localhost:8080

# Check service started
systemctl status myapp.service
# Should show "Active: active (running)"

# Check logs
journalctl -u myapp.service -u myapp.socket
```

---

## Dependency Ordering Guidance

### Understanding Systemd Dependencies

**After=**: Ordering only (does NOT create dependency)

**Wants=**: Weak dependency (continues if dependency fails)

**Requires=**: Strong dependency (fails if dependency fails)

**BindsTo=**: Like Requires + stops if dependency stops

---

### After vs Requires vs Wants

**After= (Ordering)**:
```ini
[Unit]
After=network-online.target
```
- Waits for network, but doesn't fail if network fails
- Use for: Services that benefit from ordering but can start anyway

**Wants= (Soft dependency)**:
```ini
[Unit]
Wants=postgresql.service
After=postgresql.service
```
- Starts postgresql if not running
- Continues even if postgresql fails
- Use for: Optional dependencies

**Requires= (Hard dependency)**:
```ini
[Unit]
Requires=postgresql.service
After=postgresql.service
```
- Starts postgresql if not running
- Fails if postgresql fails
- Use for: Critical dependencies

**Key point**: Always combine `Requires=`/`Wants=` with `After=` for correct ordering.

---

### Before (Reverse Ordering)

**Use case**: Ensure service stops before dependency stops

```ini
[Unit]
Before=shutdown.target
```

**Example** (Flush logs before shutdown):
```ini
[Unit]
Description=Log flusher
Before=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStop=/usr/local/bin/flush-logs.sh

[Install]
WantedBy=multi-user.target
```

---

### BindsTo (Tight Coupling)

**Purpose**: Service lifecycle bound to dependency (starts/stops together)

**Use case**: Container and orchestrator (Docker and containerd)

```ini
[Unit]
Description=Docker container
BindsTo=containerd.service
After=containerd.service
```

**Behavior**:
- If containerd stops → container stops
- If containerd fails → container fails
- Stronger than `Requires=`

---

### PartOf (Lifecycle Binding)

**Purpose**: Service stops when dependency stops (but not vice versa)

**Use case**: Multi-service applications

```ini
# api.service
[Unit]
Description=API Service
PartOf=webapp.service

[Service]
ExecStart=/opt/api/bin/server
```

**Behavior**:
- `systemctl stop webapp.service` → stops api.service
- `systemctl stop api.service` → does NOT stop webapp.service

---

### Conflicts (Mutual Exclusion)

**Purpose**: Two services cannot run simultaneously

```ini
[Unit]
Description=Production web server
Conflicts=webserver-dev.service
```

**Use case**: Prevent staging and production services running on same host

---

### Common Pitfalls

**Pitfall 1: Circular dependencies**

```ini
# service-a.service
Requires=service-b.service
After=service-b.service

# service-b.service
Requires=service-a.service
After=service-a.service
```

**Result**: Neither service starts

**Detection**:
```bash
systemctl start service-a.service
# Job for service-a.service failed because of a transaction ordering cycle.
```

**Solution**: Remove circular `Requires=`, use `Wants=` instead

---

**Pitfall 2: Missing After= with Requires=**

```ini
[Unit]
Requires=database.service
# Missing: After=database.service
```

**Result**: Service starts in parallel with database, may fail if database not ready

**Solution**: Always pair `Requires=`/`Wants=` with `After=`

---

## Journald Logging Preferences

### StandardOutput and StandardError Options

**Options**:
- `journal`: Send to systemd journal (RECOMMENDED)
- `syslog`: Send to syslog
- `kmsg`: Send to kernel log buffer
- `null`: Discard output
- `file:/path`: Write to file
- `socket`: Send to socket

**Recommended configuration**:
```ini
[Service]
StandardOutput=journal
StandardError=journal
```

**Rationale**: Centralized logging, automatic rotation, integration with journalctl

---

### SyslogIdentifier (Log Filtering)

**Purpose**: Tag journal entries for easy filtering

```ini
[Service]
SyslogIdentifier=myapp
```

**Usage**:
```bash
# View logs for specific service
journalctl -t myapp

# Follow logs
journalctl -t myapp -f

# Show only errors
journalctl -t myapp -p err
```

**Naming convention**: Use service name without `.service` suffix

---

### SyslogFacility and SyslogLevel

**SyslogFacility**: Categorize logs (local0-local7, daemon, user)

**SyslogLevel**: Default log level (emerg, alert, crit, err, warning, notice, info, debug)

```ini
[Service]
SyslogIdentifier=myapp
SyslogFacility=local0
SyslogLevel=info
```

**Use case**: Route logs to different destinations based on facility

---

### Log Correlation Patterns

**Best practice**: Include correlation IDs in logs for tracing requests across services

**Application code**:
```bash
#!/bin/bash
REQUEST_ID=$(uuidgen)
export REQUEST_ID

echo "[$REQUEST_ID] Processing request" | systemd-cat -t myapp -p info
```

**Journalctl filtering**:
```bash
# Search for specific request
journalctl -t myapp | grep "$REQUEST_ID"
```

---

### Journalctl Filtering for Debugging

**By service**:
```bash
journalctl -u myapp.service
```

**By time range**:
```bash
journalctl -u myapp.service --since "2025-12-12 10:00:00" --until "2025-12-12 11:00:00"
journalctl -u myapp.service --since "1 hour ago"
journalctl -u myapp.service --since today
```

**By priority**:
```bash
journalctl -u myapp.service -p err    # Errors only
journalctl -u myapp.service -p warning..emerg  # Warnings and above
```

**Follow logs (like tail -f)**:
```bash
journalctl -u myapp.service -f
journalctl -u myapp.service -f -n 50  # Last 50 lines + follow
```

**Output formats**:
```bash
journalctl -u myapp.service -o json-pretty
journalctl -u myapp.service -o cat  # Message only, no metadata
journalctl -u myapp.service -o short-iso  # ISO timestamps
```

---

### Log Retention

**Configure in** `/etc/systemd/journald.conf`:

```ini
[Journal]
SystemMaxUse=1G          # Max disk space for journal
SystemKeepFree=500M      # Always keep 500M free
SystemMaxFileSize=100M   # Max size per journal file
MaxRetentionSec=7day     # Delete logs older than 7 days
```

**Apply changes**:
```bash
sudo systemctl restart systemd-journald.service
```

**Check journal disk usage**:
```bash
journalctl --disk-usage
# Archived and active journals take up 512.0M in the file system.
```

**Manual cleanup**:
```bash
# Remove logs older than 7 days
sudo journalctl --vacuum-time=7d

# Keep only 1GB of logs
sudo journalctl --vacuum-size=1G
```

---

## Security Context (SELinux/AppArmor)

### SELinux Context

**Directive**: `SELinuxContext=`

**Purpose**: Confine service with SELinux security policy

**Example**:
```ini
[Service]
SELinuxContext=system_u:system_r:myapp_t:s0
```

**When to use**:
- RHEL/CentOS/Fedora systems with SELinux enforcing
- Services handling sensitive data
- Services exposed to network

**Testing**:
```bash
# Check current context
ps -eZ | grep myapp

# Verify service can access files
ls -Z /opt/myapp
```

---

### AppArmor Profile

**Directive**: `AppArmorProfile=`

**Purpose**: Confine service with AppArmor security policy

**Example**:
```ini
[Service]
AppArmorProfile=myapp-profile
```

**When to use**:
- Ubuntu/Debian systems
- Services requiring filesystem/network restrictions

**Creating profile**:
```bash
# Generate profile from runtime behavior
sudo aa-genprof /opt/myapp/bin/server

# Load profile
sudo apparmor_parser -r /etc/apparmor.d/myapp-profile

# Set profile in systemd unit
```

---

### Testing and Troubleshooting

**SELinux**:
```bash
# Check for denials
sudo ausearch -m avc -ts recent | grep myapp

# Temporarily set to permissive (troubleshooting only)
sudo setenforce 0

# Generate policy from denials
sudo audit2allow -M myapp-policy < /var/log/audit/audit.log
sudo semodule -i myapp-policy.pp
```

**AppArmor**:
```bash
# Check denials
sudo dmesg | grep -i apparmor | grep myapp

# Set profile to complain mode (log violations but allow)
sudo aa-complain /etc/apparmor.d/myapp-profile

# Generate policy from logs
sudo aa-logprof
```
