# README Standards Reference

> **Purpose**: Shared reference for modern README documentation standards. Use this as foundation for all README-related prompts.

---

## Format Overview

A modern technical README should be:
- **Accurate**: Based on actual repository content
- **Complete**: Covers all essential aspects
- **Actionable**: Commands are executable
- **Maintainable**: Easy to keep up to date
- **Accessible**: Clear for target audience

---

## Essential README Sections

### 1. Title + Badges

**Purpose**: Immediate project identification and status visibility

**Components**:
- Project name (H1 heading)
- One-line tagline
- Status badges

**Standard Badges**:
```markdown
![Build Status](https://img.shields.io/github/actions/workflow/status/user/repo/ci.yml)
![Coverage](https://img.shields.io/codecov/c/github/user/repo)
![License](https://img.shields.io/github/license/user/repo)
![Python Version](https://img.shields.io/badge/python-3.11+-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)
```

**When to include badges**:
- Build status: CI/CD workflow exists (`.github/workflows/`, `.gitlab-ci.yml`)
- Coverage: Coverage reporting configured
- License: `LICENSE` file exists
- Language version: From `pyproject.toml`, `package.json`, `go.mod`
- Container: `Dockerfile` exists

---

### 2. Description

**Purpose**: Explain what the project does in 2-4 sentences

**Guidelines**:
- Technical but accessible
- Focus on problem solved and approach
- Mention key technologies
- Avoid marketing language

**Example**:
```markdown
Web scraping framework for e-commerce price monitoring. Built with Scrapy and
PostgreSQL, processes 100k+ products daily with automatic retry and rate limiting.
Supports multiple retailers via pluggable spider architecture.
```

---

### 3. Table of Contents

**When to include**: README > 150 lines or > 8 major sections

**Format**:
```markdown
## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)
```

**Note**: Ensure all anchors match section headings (lowercase, hyphens for spaces)

---

### 4. Quick Start

**Purpose**: Get user running the project in < 5 minutes

**Structure**:
```markdown
## Quick Start

​```bash
# Clone repository
git clone https://github.com/user/repo.git
cd repo

# Setup environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Initialize
just setup  # or: python setup.py

# Run
just run    # or: python main.py
​```
```

**Requirements**:
- All commands must be real (exist in repo)
- Must work on fresh clone
- Include OS-specific variations when needed

---

### 5. Features

**Purpose**: Highlight key capabilities

**Format**:
```markdown
## Features

- 🔄 **Automatic retry** with exponential backoff
- 🚀 **High performance** (10k items/second)
- 🐳 **Docker ready** with docker-compose setup
- 📊 **Monitoring** via Prometheus metrics
- 🔒 **Secure** with environment-based secrets
- 🧪 **Tested** with 95% code coverage
```

**Guidelines**:
- Use emojis sparingly (optional)
- Quantify when possible (metrics, performance)
- Focus on user benefits
- 4-8 key features

---

### 6. Requirements

**Purpose**: System prerequisites before installation

**Format**:
```markdown
## Requirements

### System Dependencies
- Python 3.11+
- PostgreSQL 14+
- Redis 6+ (optional, for caching)

### External Services
- AWS S3 (for data storage)
- Sentry (for error tracking, optional)

### Development Tools
- Docker 20+ (for local development)
- just 1.0+ (task runner)
```

**Source**: From dependency files, docker-compose.yml, documentation in code

---

### 7. Installation

**Purpose**: Detailed setup instructions

**Structure**:
1. Prerequisites verification
2. Repository clone
3. Environment setup (venv, conda, etc.)
4. Dependency installation
5. Configuration
6. Database/service initialization
7. Verification

**Example**:
```markdown
## Installation

### 1. Clone Repository

​```bash
git clone https://github.com/user/repo.git
cd repo
​```

### 2. Create Virtual Environment

​```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
​```

### 3. Install Dependencies

​```bash
pip install -r requirements.txt
# or for development:
pip install -r requirements-dev.txt
​```

### 4. Configure Environment

​```bash
cp .env.example .env
# Edit .env with your settings
​```

### 5. Initialize Database

​```bash
just db-init  # or: alembic upgrade head
​```

### 6. Verify Installation

​```bash
just test  # or: pytest
​```
```

---

### 8. Usage

**Purpose**: How to use the project

**Varies by project type**:

#### CLI Tool
```markdown
## Usage

### Basic Command

​```bash
myapp --help
​```

### Common Operations

​```bash
# Process single file
myapp process input.csv

# Batch processing
myapp batch --input data/ --output results/

# Verbose mode
myapp process input.csv --verbose
​```

### Advanced Options

​```bash
# Custom configuration
myapp --config custom.yaml process input.csv

# Parallel processing
myapp batch --workers 4 --input data/
​```
```

#### Web Application
```markdown
## Usage

### Start Development Server

​```bash
just dev  # or: uvicorn app.main:app --reload
​```

Access at: http://localhost:8000

### API Documentation

Interactive docs: http://localhost:8000/docs

### Example Requests

​```bash
# Create user
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "name": "John"}'

# Get user
curl http://localhost:8000/users/123
​```
```

#### Library
```markdown
## Usage

### Basic Example

​```python
from mylib import Client

client = Client(api_key="your-key")
result = client.fetch_data()
print(result)
​```

### Advanced Usage

​```python
from mylib import Client, AsyncClient

# Async context
async with AsyncClient(api_key="key") as client:
    data = await client.fetch_data(limit=1000)

# Batch processing
for batch in client.stream_data(batch_size=100):
    process(batch)
​```
```

---

### 9. Configuration

**Purpose**: Document all configurable parameters

**Format** (Table):
```markdown
## Configuration

### Environment Variables

#### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@localhost/db` |
| `SECRET_KEY` | Application secret key | `generate with: openssl rand -hex 32` |
| `API_KEY` | External API authentication | `sk_live_...` |

#### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Logging verbosity | `INFO` |
| `WORKERS` | Number of concurrent workers | `4` |
| `TIMEOUT` | Request timeout in seconds | `30` |
| `REDIS_URL` | Redis connection (for caching) | `redis://localhost:6379/0` |

### Configuration Files

- `config/settings.yaml` - Main application settings
- `config/logging.yaml` - Logging configuration
- `.scrapy.cfg` - Scrapy-specific settings (if applicable)

### Security Notes

⚠️ Never commit `.env` file to repository
⚠️ Rotate `SECRET_KEY` in production
⚠️ Use strong passwords for `DATABASE_URL`
```

**Source**: `.env.example`, settings files, code configuration

---

### 10. Architecture

**Purpose**: Explain project structure and design

**Directory Tree**:
```markdown
## Architecture

### Project Structure

​```
.
├── src/
│   ├── cli.py              # Command-line interface entry point
│   ├── spiders/            # Scrapy spider implementations
│   ├── pipelines/          # Data processing and validation
│   ├── models/             # SQLAlchemy database models
│   └── utils/              # Shared utility functions
├── tests/
│   ├── unit/               # Unit tests
│   └── integration/        # Integration tests
├── scripts/
│   ├── setup.sh            # Initial setup automation
│   └── deploy.sh           # Deployment script
├── config/
│   ├── settings.yaml       # Application configuration
│   └── logging.yaml        # Logging configuration
├── migrations/             # Alembic database migrations
├── docker/
│   ├── Dockerfile          # Production container
│   └── docker-compose.yml  # Local development environment
└── docs/                   # Additional documentation
​```

### Component Overview

- **Spiders**: Extract data from target websites
- **Pipelines**: Validate, transform, and store scraped data
- **Models**: Database schema and ORM layer
- **CLI**: User-facing command interface
```

**Optional: Data Flow Diagram**:
```markdown
### Data Flow

​```mermaid
flowchart LR
    A[CLI] --> B[Spider]
    B --> C[Pipeline]
    C --> D[Validation]
    D --> E[Database]
    E --> F[API]
​```
```

---

### 11. Deployment

**Purpose**: Production deployment instructions

**Include when**: Dockerfile, k8s/, systemd/, or cloud configs exist

**Docker**:
```markdown
## Deployment

### Docker

#### Build Image

​```bash
docker build -t myapp:latest .
​```

#### Run Container

​```bash
docker run -d \
  --name myapp \
  -p 8000:8000 \
  --env-file .env \
  myapp:latest
​```

#### Docker Compose

​```bash
docker-compose up -d
​```

Access at: http://localhost:8000
```

**Kubernetes**:
```markdown
### Kubernetes

#### Deploy to Cluster

​```bash
kubectl apply -f k8s/
​```

#### Check Status

​```bash
kubectl get pods -n myapp
kubectl logs -f deployment/myapp
​```

#### Update Deployment

​```bash
kubectl set image deployment/myapp myapp=myapp:v2.0.0
​```
```

**Systemd**:
```markdown
### Systemd Service

#### Install Service

​```bash
sudo cp systemd/myapp.service /etc/systemd/system/
sudo systemctl daemon-reload
​```

#### Enable and Start

​```bash
sudo systemctl enable myapp
sudo systemctl start myapp
​```

#### Check Status

​```bash
sudo systemctl status myapp
sudo journalctl -u myapp -f
​```
```

---

### 12. Services & Scheduled Jobs

**Purpose**: Document automated tasks and background services

**Include when**: systemd timers, cron, Kubernetes CronJobs, or CI schedules exist

**Format**:
```markdown
## Services & Scheduled Jobs

### Systemd Services

| Name | File | Command | Restart | Logs |
|------|------|---------|---------|------|
| `myapp` | `systemd/myapp.service` | `/usr/bin/python /app/main.py` | `on-failure` | `journalctl -u myapp` |
| `myapp-worker` | `systemd/myapp-worker.service` | `/usr/bin/python /app/worker.py` | `always` | `journalctl -u myapp-worker` |

### Scheduled Jobs (Timers)

| Name | Schedule | Command | Timeout | Logs |
|------|----------|---------|---------|------|
| `myapp-daily` | Daily at 3:00 AM UTC | `python scripts/daily_task.py` | 1 hour | `/var/log/myapp/daily.log` |
| `myapp-hourly` | Hourly at :15 | `python scripts/sync.py` | 10 min | `/var/log/myapp/hourly.log` |

**Timezone**: All schedules in UTC

### Kubernetes CronJobs

| Name | Schedule | Image | Restart Policy |
|------|----------|-------|----------------|
| `backup-db` | `0 2 * * *` | `myapp:latest` | `OnFailure` |
| `cleanup` | `0 */6 * * *` | `myapp:latest` | `Never` |
```

---

### 13. Development

**Purpose**: Guide for contributors

**Include when**: CONTRIBUTING.md exists or contribution process documented

**Format**:
```markdown
## Development

### Setup Development Environment

​```bash
# Clone with submodules
git clone --recursive https://github.com/user/repo.git

# Install dev dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install
​```

### Code Style

- **Formatter**: Black (line length: 88)
- **Linter**: Ruff
- **Type Checker**: mypy
- **Import Sorter**: isort

Run checks:
​```bash
just lint  # or: black . && ruff . && mypy .
​```

### Git Workflow

1. Create feature branch: `git checkout -b feature/amazing-feature`
2. Make changes and commit: `git commit -m "feat: add amazing feature"`
3. Push branch: `git push origin feature/amazing-feature`
4. Open Pull Request

### Commit Message Format

Follow Conventional Commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Tests
```

---

### 14. Testing

**Purpose**: How to run tests

**Include when**: tests/ directory or CI configuration exists

**Format**:
```markdown
## Testing

### Run All Tests

​```bash
pytest
​```

### Run Specific Tests

​```bash
# By file
pytest tests/test_spiders.py

# By pattern
pytest tests/ -k "test_validation"

# With coverage
pytest --cov=src --cov-report=html
​```

### Integration Tests

​```bash
# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Run integration tests
pytest tests/integration/

# Cleanup
docker-compose -f docker-compose.test.yml down
​```

### Coverage Report

View HTML report: `open htmlcov/index.html`

### CI/CD

Tests run automatically on:
- Every push to feature branches
- Every pull request
- Scheduled daily at 3:00 AM UTC

See `.github/workflows/ci.yml` for details.
```

---

### 15. Monitoring & Logs

**Purpose**: Observability and debugging

**Include when**: Logging configured or monitoring setup exists

**Format**:
```markdown
## Monitoring & Logs

### Log Locations

- Application logs: `/var/log/myapp/app.log`
- Error logs: `/var/log/myapp/error.log`
- Access logs: `/var/log/myapp/access.log`
- Systemd logs: `journalctl -u myapp`

### Log Levels

Set via `LOG_LEVEL` environment variable:
- `DEBUG`: Detailed debugging information
- `INFO`: General informational messages (default)
- `WARNING`: Warning messages
- `ERROR`: Error messages
- `CRITICAL`: Critical issues

### Monitoring Endpoints

- Health check: `http://localhost:8000/health`
- Metrics: `http://localhost:8000/metrics` (Prometheus format)
- Status: `http://localhost:8000/status`

### Alerting

Configure alerts in `config/alerts.yaml`:
- High error rate (> 5% for 5 minutes)
- Service down (health check fails 3 times)
- High memory usage (> 80%)
```

---

### 16. Troubleshooting

**Purpose**: Common issues and solutions

**Include when**: TROUBLESHOOTING.md exists or common issues documented

**Format**:
```markdown
## Troubleshooting

### Database Connection Errors

**Error**: `psycopg2.OperationalError: could not connect to server`

**Solution**:
1. Verify PostgreSQL is running: `systemctl status postgresql`
2. Check DATABASE_URL in `.env`
3. Ensure database exists: `psql -l`

### Import Errors

**Error**: `ModuleNotFoundError: No module named 'scrapy'`

**Solution**:
​```bash
# Activate virtual environment
source .venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
​```

### Permission Denied

**Error**: `Permission denied: '/var/log/myapp/app.log'`

**Solution**:
​```bash
# Create log directory with correct permissions
sudo mkdir -p /var/log/myapp
sudo chown $USER:$USER /var/log/myapp
​```

### Port Already in Use

**Error**: `OSError: [Errno 98] Address already in use`

**Solution**:
​```bash
# Find process using port 8000
sudo lsof -i :8000

# Kill process
kill -9 <PID>
​```
```

---

### 17. Examples

**Purpose**: Practical usage scenarios

**Include when**: `examples/` directory exists

**Format**:
```markdown
## Examples

### Basic Scraping

​```python
from myapp import Spider

spider = Spider(name='products')
spider.start_urls = ['https://example.com/products']
results = spider.crawl()
​```

See `examples/basic_usage.py` for complete code.

### Advanced: Custom Pipeline

​```python
from myapp import Spider, Pipeline

class CustomPipeline(Pipeline):
    def process_item(self, item):
        # Custom validation
        if item.price < 0:
            raise ValueError("Invalid price")
        return item

spider = Spider(pipeline=CustomPipeline())
​```

See `examples/custom_pipeline.py` for complete code.

### More Examples

- [Batch Processing](examples/batch_processing.py)
- [API Integration](examples/api_integration.py)
- [Database Export](examples/db_export.py)
```

---

### 18. Performance

**Purpose**: Performance characteristics and benchmarks

**Include when**: benchmarks/ directory exists or performance documented

**Format**:
```markdown
## Performance

### Benchmarks

Tested on: 4-core CPU, 8GB RAM, SSD storage

| Operation | Throughput | Latency (p95) |
|-----------|------------|---------------|
| Scraping | 10k items/sec | 50ms |
| Database insert | 5k items/sec | 20ms |
| API requests | 1k req/sec | 100ms |

### Resource Usage

- Memory: ~200MB average, 500MB peak
- CPU: 25% average (single core)
- Disk I/O: ~50MB/s write

### Scaling

- Horizontal: Scales linearly up to 10 instances
- Vertical: Benefits from additional CPU cores
- Bottleneck: Database writes (use batching)

### Optimization Tips

1. Enable Redis caching: `REDIS_URL=redis://localhost`
2. Increase workers: `WORKERS=8`
3. Batch database inserts: `BATCH_SIZE=1000`
4. Use connection pooling: `DB_POOL_SIZE=20`
```

---

### 19. Security

**Purpose**: Security considerations

**Include when**: SECURITY.md exists

**Format**:
```markdown
## Security

### Reporting Vulnerabilities

Please report security issues to: security@example.com

**Do not** open public GitHub issues for security vulnerabilities.

### Security Best Practices

1. **Never commit secrets**: Use environment variables
2. **Rotate credentials**: Change API keys and passwords regularly
3. **Update dependencies**: Run `pip list --outdated` monthly
4. **Use HTTPS**: Disable HTTP in production
5. **Validate input**: Sanitize all user inputs
6. **Enable authentication**: Protect all API endpoints

### Security Features

- 🔒 Environment-based secret management
- 🔑 JWT authentication with expiration
- 🛡️ SQL injection prevention via ORM
- 🚫 Rate limiting on API endpoints
- 📝 Audit logging for sensitive operations
```

---

### 20. License

**Purpose**: Legal terms

**Include when**: LICENSE file exists

**Format**:
```markdown
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

Or:
```markdown
## License

Copyright (c) 2024 Daniel Ginês

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
```

---

### 21. Authors & Acknowledgments

**Purpose**: Credit contributors

**Format**:
```markdown
## Authors

- **Daniel Ginês** - *Initial work* - [@danielgines](https://github.com/danielgines)

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for full list of contributors.

## Acknowledgments

- [Scrapy](https://scrapy.org/) - Web scraping framework
- [FastAPI](https://fastapi.tiangolo.com/) - API framework
- Inspired by [similar-project](https://github.com/user/similar-project)
```

---

### 22. Support

**Purpose**: Where to get help

**Include when**: Support channels documented

**Format**:
```markdown
## Support

- 📧 **Email**: support@example.com
- 💬 **Slack**: [#myapp](https://slack.example.com/myapp)
- 🐛 **Issues**: [GitHub Issues](https://github.com/user/repo/issues)
- 📖 **Documentation**: [docs.example.com](https://docs.example.com)
- 💡 **Discussions**: [GitHub Discussions](https://github.com/user/repo/discussions)
```

---

### 23. Related Projects

**Purpose**: Ecosystem context

**Format**:
```markdown
## Related Projects

- [myapp-cli](https://github.com/user/myapp-cli) - Command-line client
- [myapp-ui](https://github.com/user/myapp-ui) - Web interface
- [similar-tool](https://github.com/user/similar) - Alternative approach
```

---

### 24. Changelog

**Purpose**: Version history

**Include when**: CHANGELOG.md exists

**Format**:
```markdown
## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

### Latest Release (v2.1.0)

- feat: Add support for async spiders
- fix: Resolve memory leak in pipeline
- perf: Improve database insert performance by 40%
```

---

## Section Inclusion Rules

| Section | Include When | Omit When |
|---------|-------------|-----------|
| Title + Badges | Always | Never |
| Description | Always | Never |
| TOC | README > 150 lines | Short README |
| Quick Start | Always | Pure library (no CLI) |
| Features | Always | Trivial project |
| Requirements | Dependencies exist | No external deps |
| Installation | Always | Single-file script |
| Usage | Always | Self-evident |
| Configuration | Config files exist | No configuration |
| Architecture | Complex project | Single file |
| Deployment | Deploy files exist | Development only |
| Services/Jobs | Manifests versioned | No automation |
| Development | CONTRIBUTING.md exists | Not accepting contributions |
| Testing | tests/ exists | No tests |
| Monitoring | Logging configured | No observability |
| Troubleshooting | FAQ documented | No common issues |
| Examples | examples/ exists | Usage is simple |
| Performance | benchmarks/ exists | Not performance-critical |
| Security | SECURITY.md exists | No security considerations |
| License | LICENSE exists | No license (private) |
| Authors | Multiple contributors | Solo project (optional) |
| Support | Support channels exist | No formal support |
| Related | Related projects exist | Standalone |
| Changelog | CHANGELOG.md exists | No formal releases |

---

## Markdown Best Practices

### Headings
- Use ATX style (`#` not underlines)
- One H1 (title) only
- Hierarchical (H2 → H3 → H4)
- Descriptive, not generic

### Code Blocks
```markdown
​```bash
command here
​```
```

- Always specify language
- Use `bash` for shell commands
- Use appropriate syntax highlighting

### Links
```markdown
[Relative link](docs/guide.md)
[Absolute link](https://example.com)
[Anchor link](#section-name)
```

- Prefer relative links for internal docs
- Ensure all links are valid

### Tables
```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

- Align pipes for readability (optional)
- Use for structured data

### Lists
```markdown
- Unordered item
- Another item
  - Nested item

1. Ordered item
2. Another item
```

- Use unordered for non-sequential items
- Use ordered for steps/sequences

---

## Anti-Patterns

❌ **Vague placeholders**:
```markdown
## Installation
TODO: Add installation steps
```

❌ **Dead links**:
```markdown
See [documentation](docs/guide.md)  # ← File doesn't exist
```

❌ **Exposed secrets**:
```markdown
DATABASE_URL=postgresql://admin:password123@localhost
```

❌ **Outdated commands**:
```markdown
Run: python app.py  # ← app.py doesn't exist anymore
```

❌ **Wall of text**:
```markdown
This project is a web scraping framework that allows you to scrape websites and store
data in databases and it supports multiple spiders and has pipelines for processing
data and it uses Scrapy as the underlying framework and provides CLI interface...
```

✅ **Better** (use sections, bullets, brevity)

---

## Validation Checklist

Before finalizing README:

### Content
- [ ] All commands verified in repository
- [ ] All file/directory references exist
- [ ] No secrets or sensitive data exposed
- [ ] No TODOs or placeholder text
- [ ] Language consistent throughout

### Links
- [ ] All relative links work
- [ ] All anchor links match headings
- [ ] External links are valid
- [ ] License file linked correctly

### Formatting
- [ ] Markdown syntax valid
- [ ] Code blocks have language specified
- [ ] Tables formatted correctly
- [ ] Heading hierarchy logical
- [ ] No excessive blank lines

### Accuracy
- [ ] Commands are executable
- [ ] Configuration examples match code
- [ ] Version numbers accurate
- [ ] Dependencies list complete
- [ ] Installation steps work on fresh clone

---

**Philosophy**: A great README is the first code a user reads. Make it count.
