# Shell Script Preferences System

> **Purpose**: Customize AI script generation for your organization's specific needs.
> **Audience**: Teams standardizing shell script patterns across projects.

---

## What Are Preferences?

Preferences allow you to customize how the AI generates shell scripts without modifying the base prompts. This enables:

- **Organization standards**: Enforce company-specific patterns
- **Project conventions**: Match existing codebase styles
- **Technology choices**: Specify preferred tools and services
- **Security requirements**: Add custom validation and compliance checks

---

## How to Use Preferences

### 1. Start with the Template

Copy `preferences_template.md` as your starting point:

```bash
cp preferences_template.md my_project_preferences.md
```

### 2. Customize for Your Needs

Edit the sections relevant to your project:

```markdown
## Logging Strategy
- Use journald for all system services
- Structured JSON logs for application services
- Central syslog server: logs.company.internal
```

### 3. Combine with Base Prompts

When prompting the AI, include your preferences:

```
[Paste Shell_Script_Generation_Instructions.md]

[Paste my_project_preferences.md]

Generate a deployment script for our web application.
```

The AI will follow both the base instructions and your custom preferences.

---

## Preference Categories

### 1. Organization Standards

Define company-wide requirements:

```markdown
## Organization Standards
- All scripts must have company copyright header
- Script version must follow semver (v1.2.3)
- Change log required for all production scripts
- Code review approval required before deployment
```

### 2. Technology Stack

Specify tools and services used:

```markdown
## Technology Stack
- Operating System: Ubuntu 22.04 LTS
- Init system: systemd (no SysV init support)
- Package manager: apt (no snap packages)
- Configuration management: Ansible
- Secret management: AWS Secrets Manager
- Monitoring: Prometheus + Grafana
```

### 3. Security Requirements

Add custom security policies:

```markdown
## Security Requirements
- All credentials via AWS Secrets Manager (no environment variables)
- Scripts must run as non-root service accounts
- File permissions: 750 for scripts, 600 for configs
- TLS 1.3 minimum for all network communications
- Audit logging required for privileged operations
```

### 4. Logging and Monitoring

Specify observability requirements:

```markdown
## Logging
- Format: JSON structured logs
- Destination: journald for services, files for batch jobs
- Levels: DEBUG, INFO, WARN, ERROR, CRITICAL
- Include: timestamp, hostname, PID, user, operation
- Retention: 30 days in journald, 90 days in S3

## Monitoring
- Health check endpoint required for long-running services
- Metrics exported via Prometheus node exporter
- Alert on failures via PagerDuty
```

### 5. Deployment Patterns

Define standard deployment practices:

```markdown
## Deployment
- Blue/green deployments for web services
- Rolling updates for worker services
- Database migrations before application deployment
- Rollback plan required in deployment script
- Post-deployment smoke tests mandatory
```

### 6. Error Handling

Customize error behavior:

```markdown
## Error Handling
- All errors logged to centralized logging (Datadog)
- Critical errors trigger PagerDuty alerts
- Transient errors retry 3 times with exponential backoff
- All errors include correlation ID for tracing
- Error notifications sent to #ops-alerts Slack channel
```

### 7. Testing Requirements

Specify testing standards:

```markdown
## Testing
- All scripts must have integration tests
- Use BATS (Bash Automated Testing System) for tests
- Minimum 80% code coverage
- Test in Docker container before production
- Smoke tests run after deployment
```

---

## Example Use Cases

### Use Case 1: Systemd Service Automation

**Scenario**: Company deploys all applications as systemd services with standard patterns.

**Preferences**: `examples/systemd_automation_preferences.md`

**Result**: AI generates scripts with:
- Service file creation following company template
- Health check monitoring
- Graceful shutdown handling
- Log rotation configuration
- Automated rollback on failure

### Use Case 2: AWS Infrastructure

**Scenario**: All infrastructure runs on AWS with specific patterns.

**Preferences**: `examples/aws_infrastructure_preferences.md`

**Result**: AI generates scripts with:
- AWS CLI error handling (rate limits, retries)
- IAM role-based credentials (no access keys)
- CloudWatch log integration
- SNS notifications for failures
- Resource tagging for cost tracking

### Use Case 3: Container Orchestration

**Scenario**: Kubernetes cluster management scripts.

**Preferences**: `examples/kubernetes_ops_preferences.md`

**Result**: AI generates scripts with:
- kubectl context validation
- Namespace isolation
- Helm chart deployments
- Pod health verification
- Resource quota checks

---

## Preference File Structure

### Recommended Template

```markdown
# Project Name - Shell Script Preferences

## Project Context
[Brief description of project and infrastructure]

## Organization Standards
[Company-wide requirements]

## Technology Stack
[Tools, services, platforms used]

## Security Requirements
[Security policies and compliance needs]

## Logging and Monitoring
[Observability requirements]

## Error Handling
[Error management policies]

## Deployment Patterns
[Standard deployment practices]

## Testing Requirements
[Testing standards and tools]

## Additional Notes
[Project-specific considerations]
```

---

## Tips for Effective Preferences

### Be Specific

❌ **Too vague**:
```markdown
- Use secure credentials
```

✅ **Specific**:
```markdown
- Load credentials from HashiCorp Vault at /v1/secret/data/myapp
- Validate TLS certificate against company CA
- Rotate credentials every 90 days
```

### Include Examples

❌ **No example**:
```markdown
- Use structured logging
```

✅ **With example**:
```markdown
- Use structured logging in JSON format:
  ```json
  {
    "timestamp": "2025-01-15T10:30:45Z",
    "level": "INFO",
    "service": "myapp",
    "message": "User login successful",
    "user_id": "12345"
  }
  ```
```

### Prioritize Requirements

Use severity levels to indicate what's mandatory vs optional:

```markdown
## Security Requirements

### REQUIRED (Must Have)
- TLS 1.3 for all connections
- No hardcoded credentials

### RECOMMENDED (Should Have)
- Certificate pinning for API calls
- Request rate limiting

### OPTIONAL (Nice to Have)
- Mutual TLS authentication
- WAF integration
```

---

## Versioning Preferences

Track preference changes over time:

```markdown
# Project Preferences

**Version**: 2.1.0
**Last Updated**: 2025-01-15
**Authors**: Platform Team

## Changelog

### 2.1.0 (2025-01-15)
- Added AWS Secrets Manager requirement
- Updated logging format to JSON
- Added PagerDuty integration

### 2.0.0 (2024-12-01)
- Migrated from SysV to systemd
- Updated Ubuntu version to 22.04

### 1.0.0 (2024-06-01)
- Initial preferences document
```

---

## Common Pitfalls

### 1. Over-Specification

❌ **Too detailed** (limits AI flexibility):
```markdown
- Use exactly 4 spaces for indentation
- Variable names must start with lowercase letter
- Functions must be between 10-50 lines
```

✅ **Appropriate level**:
```markdown
- Follow standard bash indentation (consistent with existing codebase)
- Use descriptive variable names (lowercase with underscores)
- Keep functions focused and single-purpose
```

### 2. Conflicting Requirements

❌ **Contradictory**:
```markdown
- All scripts must run as root
- Never use sudo or root privileges
```

✅ **Consistent**:
```markdown
- Scripts should run with minimal privileges
- Use sudo only for specific operations (systemctl, file permissions)
- Document which operations require elevated privileges
```

### 3. Missing Context

❌ **No context**:
```markdown
- Use the company VPN
```

✅ **With context**:
```markdown
- Scripts connecting to production databases must:
  - Run from bastion host (bastion.company.internal)
  - Connect via company VPN (vpn.company.internal)
  - Use read-only database user for queries
```

---

## Updating Preferences

As your infrastructure evolves, update your preferences:

1. **Version bump**: Increment version number
2. **Changelog entry**: Document what changed and why
3. **Team review**: Get approval from affected teams
4. **Documentation**: Update related runbooks and procedures
5. **Training**: Communicate changes to development teams

---

## Examples Directory

See `examples/` for complete preference files:

- `systemd_automation_preferences.md` - Service automation patterns
- `aws_infrastructure_preferences.md` - AWS deployment scripts
- `kubernetes_ops_preferences.md` - Kubernetes management scripts

---

**Last Updated**: 2025-12-12
