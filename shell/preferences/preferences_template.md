# Shell Script Preferences Template

> **Purpose**: Template for creating custom shell script generation preferences.
> **Instructions**: Copy this file and fill in sections relevant to your project.

---

## Project Context

**Project Name**: _________________

**Description**: [Brief description of project and its infrastructure]

**Team**: _________________

**Contact**: _________________

---

## Organization Standards

[Company-wide requirements that must be followed]

### Required Elements
- [ ] Copyright header format
- [ ] Licensing requirements
- [ ] Version numbering scheme
- [ ] Code review requirements
- [ ] Approval process

### Example
```markdown
- All scripts must include company copyright header
- Scripts follow semver versioning (v1.2.3)
- Minimum 2 approvals required for production deployment
```

---

## Technology Stack

[Specify the technologies, tools, and platforms used in your environment]

### Operating System
- Distribution: _________________
- Version: _________________
- Architecture: _________________

### Init System
- [ ] systemd
- [ ] SysV init
- [ ] OpenRC
- [ ] Other: _________________

### Package Manager
- [ ] apt (Debian/Ubuntu)
- [ ] yum/dnf (RHEL/CentOS/Fedora)
- [ ] apk (Alpine)
- [ ] zypper (openSUSE)
- [ ] pacman (Arch)

### Container Platform
- [ ] Docker
- [ ] Podman
- [ ] containerd
- [ ] LXC/LXD
- [ ] Not applicable

### Orchestration
- [ ] Kubernetes
- [ ] Docker Swarm
- [ ] Nomad
- [ ] Not applicable

### Cloud Provider
- [ ] AWS
- [ ] Google Cloud
- [ ] Azure
- [ ] On-premises
- [ ] Hybrid

### Configuration Management
- [ ] Ansible
- [ ] Puppet
- [ ] Chef
- [ ] Salt
- [ ] Terraform
- [ ] None

---

## Security Requirements

[Security policies and compliance requirements]

### Credential Management
[How credentials should be handled]

**Method**:
- [ ] Environment variables
- [ ] Credential files
- [ ] Secret management service (specify): _________________
- [ ] Cloud provider secret service
- [ ] HashiCorp Vault
- [ ] AWS Secrets Manager
- [ ] Azure Key Vault
- [ ] Google Secret Manager

**Requirements**:
```markdown
- [Specify credential loading method]
- [Specify permission requirements]
- [Specify validation requirements]
- [Specify rotation policy]
```

### Encryption
- TLS version required: _________________
- Certificate authority: _________________
- Certificate validation: [yes/no/custom]

### Access Control
- Minimum privilege level: _________________
- Sudo requirements: _________________
- Service account naming: _________________

### Compliance
- [ ] PCI DSS
- [ ] HIPAA
- [ ] SOC 2
- [ ] GDPR
- [ ] Other: _________________

---

## Logging and Monitoring

[Observability requirements]

### Logging

**Destination**:
- [ ] journald (systemd)
- [ ] Syslog
- [ ] File-based logging
- [ ] Centralized logging service: _________________
- [ ] Cloud logging (CloudWatch, Stackdriver, etc.)

**Format**:
- [ ] Plain text
- [ ] JSON structured logs
- [ ] Key-value pairs
- [ ] Custom format: _________________

**Required Fields**:
```markdown
- Timestamp: [format]
- Log level: [levels used]
- Service/application name
- [Other required fields]
```

**Retention**:
- Local logs: _______ days
- Centralized logs: _______ days
- Archive location: _________________

### Monitoring

**Metrics System**:
- [ ] Prometheus
- [ ] Datadog
- [ ] New Relic
- [ ] CloudWatch
- [ ] Grafana Cloud
- [ ] Other: _________________

**Health Checks**:
- [ ] HTTP endpoint required
- [ ] Process monitoring required
- [ ] Custom health check
- [ ] Not applicable

**Alerting**:
- [ ] PagerDuty
- [ ] OpsGenie
- [ ] Slack
- [ ] Email
- [ ] SMS
- [ ] Other: _________________

---

## Error Handling

[Error management policies]

### Error Severity Levels
```markdown
- CRITICAL: [Definition and response]
- ERROR: [Definition and response]
- WARNING: [Definition and response]
- INFO: [Definition and response]
- DEBUG: [Definition and response]
```

### Retry Logic
- Transient errors: _______ retries
- Backoff strategy: _________________
- Maximum retry duration: _______ seconds

### Notification
- Critical errors notify: _________________
- Error notification method: _________________
- Include in notifications: _________________

---

## Deployment Patterns

[Standard deployment practices]

### Deployment Strategy
- [ ] Blue/green
- [ ] Canary
- [ ] Rolling update
- [ ] Recreate
- [ ] Custom: _________________

### Pre-Deployment
- [ ] Backup required
- [ ] Database migration required
- [ ] Health check required
- [ ] Approval required

### Post-Deployment
- [ ] Smoke tests
- [ ] Integration tests
- [ ] Performance tests
- [ ] Monitoring verification

### Rollback
- [ ] Automatic rollback on failure
- [ ] Manual rollback only
- [ ] Rollback time limit: _______ minutes

---

## File Permissions

[Standard file permission requirements]

### Scripts
- Executable scripts: _________________
- Library scripts: _________________
- Ownership: _________________

### Configuration Files
- Application configs: _________________
- System configs: _________________
- Ownership: _________________

### Credential Files
- Permissions: _________________
- Ownership: _________________
- Validation required: [yes/no]

### Log Files
- Permissions: _________________
- Ownership: _________________
- Rotation: _________________

---

## Naming Conventions

[Standardized naming patterns]

### Script Names
- Format: _________________
- Example: _________________

### Function Names
- Format: _________________
- Example: _________________

### Variable Names
- Constants: _________________
- Local variables: _________________
- Environment variables: _________________

### Service Names
- Format: _________________
- Example: _________________

---

## Testing Requirements

[Testing standards and procedures]

### Test Framework
- [ ] BATS (Bash Automated Testing System)
- [ ] Shunit2
- [ ] Custom framework
- [ ] None

### Coverage Requirements
- Minimum coverage: _______%
- Coverage tool: _________________

### Test Environments
- [ ] Docker containers
- [ ] Virtual machines
- [ ] Staging environment
- [ ] Production-like environment

### Required Tests
- [ ] Unit tests
- [ ] Integration tests
- [ ] End-to-end tests
- [ ] Performance tests
- [ ] Security tests

---

## Documentation Requirements

[Documentation standards]

### Script Documentation
- [ ] Header comments required
- [ ] Function documentation required
- [ ] Usage examples required
- [ ] Prerequisites documented

### External Documentation
- [ ] README required
- [ ] Runbook required
- [ ] Architecture diagram required
- [ ] Troubleshooting guide required

---

## Environment-Specific Configuration

[Configuration for different environments]

### Development
```markdown
- Environment name: development
- Configuration:
  [List dev-specific requirements]
```

### Staging
```markdown
- Environment name: staging
- Configuration:
  [List staging-specific requirements]
```

### Production
```markdown
- Environment name: production
- Configuration:
  [List production-specific requirements]
```

---

## Additional Requirements

[Any additional project-specific requirements not covered above]

### Custom Requirements
```markdown
[Add any custom requirements here]
```

### Exceptions
```markdown
[Document any exceptions to standard practices]
```

### Notes
```markdown
[Additional notes and context]
```

---

## Maintenance

**Version**: 1.0.0
**Last Updated**: [Date]
**Next Review**: [Date]
**Owner**: [Name/Team]

### Changelog
```markdown
## [1.0.0] - [Date]
- Initial preferences document
```

---

**Usage Instructions**:
1. Copy this template to create your project preferences
2. Fill in all relevant sections
3. Remove sections that don't apply to your project
4. Keep this document versioned in your repository
5. Review and update quarterly or when infrastructure changes
