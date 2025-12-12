# Python Automation Instructions — AI Prompt Template

> **Context**: Use this prompt to create robust Python automation scripts for scheduled tasks, file monitoring, API automation, database operations, cloud infrastructure, and CI/CD workflows.
> **Reference**: See `Python_Security_Standards_Reference.md` for secure credential management and `Python_Code_Quality_Checklist.md` for validation.

---

## Role & Objective

You are a **Python automation specialist** with expertise in:
- Task scheduling (APScheduler, Celery, cron)
- File system monitoring (watchdog)
- API automation (requests, httpx, retry strategies)
- Database automation (SQLAlchemy, migrations, backups)
- Cloud automation (boto3, Azure SDK, Google Cloud)
- CI/CD workflows (GitHub Actions, GitLab CI, Jenkins)
- Error handling and retry logic
- Idempotent operations

Your task: Design and implement **production-ready Python automation scripts** with comprehensive error handling, logging, monitoring, and security best practices.

---

## Pre-Execution Configuration

**User must provide:**

1. **Automation type** (choose all that apply):
   - [ ] Scheduled task (run at specific times/intervals)
   - [ ] File system monitoring (watch for file changes)
   - [ ] API automation (periodic API calls, data sync)
   - [ ] Database automation (backups, migrations, cleanup)
   - [ ] Cloud resource management (AWS, Azure, GCP)
   - [ ] Email/notification automation
   - [ ] Log processing and aggregation
   - [ ] CI/CD workflow
   - [ ] Other: _________________

2. **Environment details**:
   - [ ] Target environment (local, server, container, cloud)
   - [ ] Python version
   - [ ] Operating system
   - [ ] Existing infrastructure (databases, APIs, cloud services)
   - [ ] Authentication methods available

3. **Automation requirements**:
   - [ ] Frequency/schedule
   - [ ] Expected runtime
   - [ ] Concurrency needs
   - [ ] Error tolerance
   - [ ] Notification requirements
   - [ ] Logging requirements
   - [ ] Monitoring requirements

4. **Output preference** (choose one):
   - [ ] Complete script with all error handling
   - [ ] Script skeleton with TODOs for customization
   - [ ] Multiple example patterns
   - [ ] CI/CD workflow configuration

---

## Automation Categories and Patterns

### Category 1: Scheduled Task Automation

**Use Cases**:
- Database backups
- Report generation
- Data synchronization
- Cleanup operations
- Health checks
- Metrics collection

#### Pattern 1.1: APScheduler - Simple Scheduled Task

```python
#!/usr/bin/env python3
"""
Scheduled task automation using APScheduler.
Runs tasks at specified intervals with error handling and logging.
"""

import logging
import sys
from datetime import datetime
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.triggers.interval import IntervalTrigger

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('automation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


def task_database_backup():
    """Perform database backup."""
    logger.info("Starting database backup")
    try:
        # Backup logic here
        # Example: subprocess.run(['pg_dump', '-U', user, '-d', db, '-f', backup_file])
        logger.info("Database backup completed successfully")
        return True
    except Exception as e:
        logger.error(f"Database backup failed: {e}", exc_info=True)
        # Send alert
        send_alert("Database backup failed", str(e))
        return False


def task_cleanup_old_files():
    """Clean up old temporary files."""
    logger.info("Starting cleanup task")
    try:
        from pathlib import Path
        import time

        temp_dir = Path("/tmp/app")
        cutoff_time = time.time() - (7 * 24 * 60 * 60)  # 7 days ago

        deleted_count = 0
        for file_path in temp_dir.glob("*.tmp"):
            if file_path.stat().st_mtime < cutoff_time:
                file_path.unlink()
                deleted_count += 1

        logger.info(f"Cleanup completed: {deleted_count} files deleted")
        return True
    except Exception as e:
        logger.error(f"Cleanup task failed: {e}", exc_info=True)
        return False


def task_health_check():
    """Perform system health check."""
    logger.info("Starting health check")
    try:
        import requests

        # Check API endpoint
        response = requests.get("https://api.example.com/health", timeout=10)
        response.raise_for_status()

        # Check database connection
        # Example: engine.connect()

        logger.info("Health check passed")
        return True
    except Exception as e:
        logger.error(f"Health check failed: {e}", exc_info=True)
        send_alert("Health check failed", str(e))
        return False


def send_alert(subject: str, message: str):
    """Send alert notification."""
    logger.warning(f"ALERT: {subject} - {message}")
    # Implement email, Slack, PagerDuty, etc.
    # Example: send_email(to="admin@example.com", subject=subject, body=message)


def main():
    """Configure and start scheduler."""
    logger.info("Starting automation scheduler")

    scheduler = BlockingScheduler()

    # Daily backup at 2:00 AM
    scheduler.add_job(
        task_database_backup,
        trigger=CronTrigger(hour=2, minute=0),
        id="daily_backup",
        name="Daily Database Backup",
        max_instances=1,  # Prevent concurrent runs
        replace_existing=True,
    )

    # Cleanup every 6 hours
    scheduler.add_job(
        task_cleanup_old_files,
        trigger=IntervalTrigger(hours=6),
        id="cleanup",
        name="Cleanup Old Files",
        max_instances=1,
    )

    # Health check every 5 minutes
    scheduler.add_job(
        task_health_check,
        trigger=IntervalTrigger(minutes=5),
        id="health_check",
        name="System Health Check",
        max_instances=1,
    )

    try:
        logger.info("Scheduler started successfully")
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        logger.info("Scheduler stopped by user")
        scheduler.shutdown()
    except Exception as e:
        logger.error(f"Scheduler failed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

**Deployment**:
```bash
# Install dependencies
pip install apscheduler

# Run as systemd service
sudo systemctl enable automation.service
sudo systemctl start automation.service
```

---

#### Pattern 1.2: Celery - Distributed Task Queue

```python
#!/usr/bin/env python3
"""
Distributed task automation using Celery.
Handles complex workflows with task dependencies and retries.
"""

from celery import Celery, group, chain, chord
from celery.exceptions import SoftTimeLimitExceeded
import logging

# Configure Celery
app = Celery(
    'automation',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/1'
)

app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_acks_late=True,  # Acknowledge after completion
    worker_prefetch_multiplier=1,  # One task at a time
    task_time_limit=3600,  # 1 hour hard limit
    task_soft_time_limit=3000,  # 50 min soft limit
)

logger = logging.getLogger(__name__)


@app.task(bind=True, max_retries=3, default_retry_delay=60)
def fetch_data_from_api(self, api_url: str) -> dict:
    """
    Fetch data from external API with retry logic.

    Args:
        api_url: URL to fetch data from

    Returns:
        Fetched data as dictionary

    Raises:
        Exception: If all retries exhausted
    """
    try:
        import requests

        logger.info(f"Fetching data from {api_url}")
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()

        data = response.json()
        logger.info(f"Successfully fetched {len(data)} records")
        return data

    except SoftTimeLimitExceeded:
        logger.error("Task exceeded time limit")
        raise

    except Exception as e:
        logger.error(f"Failed to fetch data: {e}")
        # Retry with exponential backoff
        raise self.retry(exc=e, countdown=2 ** self.request.retries)


@app.task(bind=True, max_retries=3)
def process_data(self, data: dict) -> dict:
    """Process fetched data."""
    try:
        logger.info("Processing data")

        # Data processing logic
        processed = {
            'count': len(data),
            'timestamp': datetime.now().isoformat()
        }

        logger.info("Data processing complete")
        return processed

    except Exception as e:
        logger.error(f"Data processing failed: {e}")
        raise self.retry(exc=e)


@app.task
def store_results(results: dict) -> bool:
    """Store processed results in database."""
    try:
        from sqlalchemy import create_engine
        import os

        db_url = os.environ['DATABASE_URL']
        engine = create_engine(db_url)

        # Store results
        with engine.connect() as conn:
            # INSERT logic here
            pass

        logger.info("Results stored successfully")
        return True

    except Exception as e:
        logger.error(f"Failed to store results: {e}")
        raise


@app.task
def send_completion_notification(success: bool):
    """Send notification when workflow completes."""
    if success:
        logger.info("Workflow completed successfully")
        # Send success notification
    else:
        logger.error("Workflow failed")
        # Send failure alert


# Workflow patterns
def run_simple_workflow():
    """Run tasks in sequence (chain)."""
    workflow = chain(
        fetch_data_from_api.s("https://api.example.com/data"),
        process_data.s(),
        store_results.s(),
    )
    workflow.apply_async()


def run_parallel_workflow():
    """Run multiple tasks in parallel (group)."""
    job = group(
        fetch_data_from_api.s("https://api1.example.com/data"),
        fetch_data_from_api.s("https://api2.example.com/data"),
        fetch_data_from_api.s("https://api3.example.com/data"),
    )
    result = job.apply_async()
    result.get(timeout=300)  # Wait up to 5 minutes


def run_map_reduce_workflow():
    """Run map-reduce pattern (chord)."""
    workflow = chord(
        group(
            fetch_data_from_api.s("https://api1.example.com/data"),
            fetch_data_from_api.s("https://api2.example.com/data"),
        )
    )(send_completion_notification.s())

    workflow.apply_async()


# Periodic tasks
app.conf.beat_schedule = {
    'fetch-every-hour': {
        'task': 'automation.fetch_data_from_api',
        'schedule': 3600.0,  # Every hour
        'args': ('https://api.example.com/data',)
    },
}
```

**Deployment**:
```bash
# Install dependencies
pip install celery[redis]

# Start Celery worker
celery -A automation worker --loglevel=info

# Start Celery beat (scheduler)
celery -A automation beat --loglevel=info
```

---

### Category 2: File System Monitoring

**Use Cases**:
- Process uploaded files
- Monitor configuration changes
- Trigger builds on file changes
- Sync files between locations

#### Pattern 2.1: Watchdog - File System Observer

```python
#!/usr/bin/env python3
"""
File system monitoring with watchdog.
Automatically processes files when they appear in watched directories.
"""

import logging
import time
import sys
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileSystemEvent

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class FileProcessor(FileSystemEventHandler):
    """Handle file system events."""

    def __init__(self, upload_dir: Path, processed_dir: Path, error_dir: Path):
        self.upload_dir = upload_dir
        self.processed_dir = processed_dir
        self.error_dir = error_dir

        # Create directories if they don't exist
        for directory in [upload_dir, processed_dir, error_dir]:
            directory.mkdir(parents=True, exist_ok=True)

    def on_created(self, event: FileSystemEvent):
        """Called when a file is created."""
        if event.is_directory:
            return

        file_path = Path(event.src_path)

        # Only process specific file types
        if file_path.suffix not in ['.csv', '.json', '.xml']:
            return

        logger.info(f"New file detected: {file_path.name}")

        # Wait for file to be fully written
        time.sleep(1)

        self.process_file(file_path)

    def process_file(self, file_path: Path):
        """Process uploaded file."""
        try:
            logger.info(f"Processing file: {file_path.name}")

            # Validate file
            if not self.validate_file(file_path):
                raise ValueError("File validation failed")

            # Process file based on type
            if file_path.suffix == '.csv':
                self.process_csv(file_path)
            elif file_path.suffix == '.json':
                self.process_json(file_path)
            elif file_path.suffix == '.xml':
                self.process_xml(file_path)

            # Move to processed directory
            destination = self.processed_dir / file_path.name
            file_path.rename(destination)

            logger.info(f"File processed successfully: {file_path.name}")

        except Exception as e:
            logger.error(f"Error processing {file_path.name}: {e}", exc_info=True)

            # Move to error directory
            error_destination = self.error_dir / file_path.name
            file_path.rename(error_destination)

            # Send alert
            self.send_alert(f"File processing failed: {file_path.name}", str(e))

    def validate_file(self, file_path: Path) -> bool:
        """Validate file before processing."""
        # Check file size
        max_size = 100 * 1024 * 1024  # 100 MB
        if file_path.stat().st_size > max_size:
            logger.error(f"File too large: {file_path.name}")
            return False

        # Check file is readable
        try:
            with open(file_path, 'r') as f:
                f.read(1)
        except Exception as e:
            logger.error(f"File not readable: {e}")
            return False

        return True

    def process_csv(self, file_path: Path):
        """Process CSV file."""
        import pandas as pd

        df = pd.read_csv(file_path)
        logger.info(f"Loaded CSV with {len(df)} rows")

        # Process data
        # ...

        # Store in database
        # df.to_sql('table_name', engine, if_exists='append', index=False)

    def process_json(self, file_path: Path):
        """Process JSON file."""
        import json

        with open(file_path, 'r') as f:
            data = json.load(f)

        logger.info(f"Loaded JSON with {len(data)} records")

        # Process data
        # ...

    def process_xml(self, file_path: Path):
        """Process XML file."""
        import xml.etree.ElementTree as ET

        tree = ET.parse(file_path)
        root = tree.getroot()

        logger.info(f"Loaded XML with root tag: {root.tag}")

        # Process data
        # ...

    def send_alert(self, subject: str, message: str):
        """Send alert notification."""
        logger.warning(f"ALERT: {subject} - {message}")
        # Implement notification logic


def main():
    """Start file system monitoring."""
    # Define directories
    upload_dir = Path("/data/uploads")
    processed_dir = Path("/data/processed")
    error_dir = Path("/data/errors")

    logger.info("Starting file system monitor")
    logger.info(f"Watching directory: {upload_dir}")

    # Create event handler
    event_handler = FileProcessor(upload_dir, processed_dir, error_dir)

    # Create observer
    observer = Observer()
    observer.schedule(event_handler, str(upload_dir), recursive=False)

    # Start observer
    observer.start()
    logger.info("File system monitor started")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Stopping file system monitor")
        observer.stop()

    observer.join()
    logger.info("File system monitor stopped")


if __name__ == "__main__":
    main()
```

**Deployment**:
```bash
# Install dependencies
pip install watchdog pandas

# Run as systemd service
sudo systemctl enable file-monitor.service
sudo systemctl start file-monitor.service
```

---

### Category 3: API Automation with Retry Logic

**Use Cases**:
- Periodic data synchronization
- API health monitoring
- Webhook processing
- Third-party integrations

#### Pattern 3.1: Requests with Exponential Backoff

```python
#!/usr/bin/env python3
"""
API automation with comprehensive retry logic and error handling.
"""

import logging
import time
import os
from typing import Optional, Dict, Any
from functools import wraps
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
API_BASE_URL = os.getenv("API_BASE_URL", "https://api.example.com")
API_KEY = os.getenv("API_KEY")
MAX_RETRIES = 3
RETRY_BACKOFF_FACTOR = 2  # 2^n seconds
REQUEST_TIMEOUT = 30


class APIClient:
    """HTTP client with automatic retries and error handling."""

    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.api_key = api_key
        self.session = self._create_session()

    def _create_session(self) -> requests.Session:
        """Create requests session with retry configuration."""
        session = requests.Session()

        # Configure retry strategy
        retry_strategy = Retry(
            total=MAX_RETRIES,
            backoff_factor=RETRY_BACKOFF_FACTOR,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "POST", "PUT", "DELETE"],
        )

        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)

        # Set default headers
        session.headers.update({
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "User-Agent": "PythonAutomation/1.0"
        })

        return session

    def _make_request(
        self,
        method: str,
        endpoint: str,
        **kwargs
    ) -> requests.Response:
        """Make HTTP request with error handling."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"

        try:
            logger.info(f"{method} {url}")
            response = self.session.request(
                method,
                url,
                timeout=REQUEST_TIMEOUT,
                **kwargs
            )
            response.raise_for_status()
            logger.info(f"Request successful: {response.status_code}")
            return response

        except requests.exceptions.HTTPError as e:
            logger.error(f"HTTP error: {e}")
            logger.error(f"Response: {e.response.text}")
            raise

        except requests.exceptions.Timeout:
            logger.error(f"Request timeout after {REQUEST_TIMEOUT}s")
            raise

        except requests.exceptions.RequestException as e:
            logger.error(f"Request failed: {e}")
            raise

    def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict[str, Any]:
        """GET request."""
        response = self._make_request("GET", endpoint, params=params)
        return response.json()

    def post(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """POST request."""
        response = self._make_request("POST", endpoint, json=data)
        return response.json()

    def put(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """PUT request."""
        response = self._make_request("PUT", endpoint, json=data)
        return response.json()

    def delete(self, endpoint: str) -> bool:
        """DELETE request."""
        self._make_request("DELETE", endpoint)
        return True


def retry_on_failure(max_attempts: int = 3, delay: int = 1):
    """Decorator for retrying functions on failure."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts:
                        logger.error(f"All {max_attempts} attempts failed")
                        raise

                    wait_time = delay * (2 ** (attempt - 1))
                    logger.warning(
                        f"Attempt {attempt}/{max_attempts} failed: {e}. "
                        f"Retrying in {wait_time}s..."
                    )
                    time.sleep(wait_time)

        return wrapper
    return decorator


@retry_on_failure(max_attempts=3, delay=2)
def sync_data_to_api():
    """Synchronize local data to external API."""
    logger.info("Starting data synchronization")

    client = APIClient(API_BASE_URL, API_KEY)

    # Fetch local data
    local_data = fetch_local_data()
    logger.info(f"Found {len(local_data)} records to sync")

    # Sync each record
    synced_count = 0
    failed_count = 0

    for record in local_data:
        try:
            result = client.post("/records", data=record)
            logger.info(f"Synced record {record['id']}: {result}")
            synced_count += 1

        except Exception as e:
            logger.error(f"Failed to sync record {record['id']}: {e}")
            failed_count += 1

    logger.info(
        f"Synchronization complete: {synced_count} synced, {failed_count} failed"
    )

    return synced_count, failed_count


def fetch_local_data() -> list:
    """Fetch data from local database."""
    # Placeholder - implement actual database query
    return [
        {"id": 1, "name": "Record 1", "value": 100},
        {"id": 2, "name": "Record 2", "value": 200},
    ]


if __name__ == "__main__":
    if not API_KEY:
        logger.error("API_KEY environment variable not set")
        exit(1)

    try:
        sync_data_to_api()
    except Exception as e:
        logger.error(f"Synchronization failed: {e}")
        exit(1)
```

---

### Category 4: Database Automation

**Use Cases**:
- Automated backups
- Data migrations
- Database cleanup
- Archival operations

#### Pattern 4.1: PostgreSQL Backup Automation

```python
#!/usr/bin/env python3
"""
Automated PostgreSQL database backup with rotation and cloud storage.
"""

import logging
import subprocess
import os
from datetime import datetime, timedelta
from pathlib import Path
import boto3
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

BACKUP_DIR = Path("/backups/postgres")
RETENTION_DAYS = 30

# S3 configuration (optional)
S3_BUCKET = os.getenv("S3_BACKUP_BUCKET")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")


def create_backup() -> Path:
    """Create database backup using pg_dump."""
    logger.info(f"Starting backup of database: {DB_NAME}")

    # Ensure backup directory exists
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    # Generate backup filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"{DB_NAME}_{timestamp}.sql.gz"

    # Build pg_dump command
    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PASSWORD

    command = [
        'pg_dump',
        '-h', DB_HOST,
        '-p', DB_PORT,
        '-U', DB_USER,
        '-d', DB_NAME,
        '--no-owner',
        '--no-acl',
        '-F', 'c',  # Custom format (compressed)
        '-f', str(backup_file)
    ]

    try:
        result = subprocess.run(
            command,
            env=env,
            check=True,
            capture_output=True,
            text=True
        )

        # Verify backup file was created
        if not backup_file.exists():
            raise FileNotFoundError(f"Backup file not created: {backup_file}")

        size_mb = backup_file.stat().st_size / (1024 * 1024)
        logger.info(f"Backup created successfully: {backup_file.name} ({size_mb:.2f} MB)")

        return backup_file

    except subprocess.CalledProcessError as e:
        logger.error(f"pg_dump failed: {e}")
        logger.error(f"stdout: {e.stdout}")
        logger.error(f"stderr: {e.stderr}")
        raise


def upload_to_s3(backup_file: Path) -> bool:
    """Upload backup file to S3."""
    if not S3_BUCKET:
        logger.info("S3_BUCKET not configured, skipping upload")
        return False

    logger.info(f"Uploading {backup_file.name} to S3: {S3_BUCKET}")

    try:
        s3_client = boto3.client(
            's3',
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY
        )

        s3_key = f"postgres-backups/{backup_file.name}"

        s3_client.upload_file(
            str(backup_file),
            S3_BUCKET,
            s3_key,
            ExtraArgs={'ServerSideEncryption': 'AES256'}
        )

        logger.info(f"Upload to S3 successful: s3://{S3_BUCKET}/{s3_key}")
        return True

    except ClientError as e:
        logger.error(f"S3 upload failed: {e}")
        return False


def rotate_old_backups():
    """Delete backups older than retention period."""
    logger.info(f"Rotating backups older than {RETENTION_DAYS} days")

    cutoff_date = datetime.now() - timedelta(days=RETENTION_DAYS)
    deleted_count = 0

    for backup_file in BACKUP_DIR.glob(f"{DB_NAME}_*.sql.gz"):
        file_mtime = datetime.fromtimestamp(backup_file.stat().st_mtime)

        if file_mtime < cutoff_date:
            logger.info(f"Deleting old backup: {backup_file.name}")
            backup_file.unlink()
            deleted_count += 1

    logger.info(f"Deleted {deleted_count} old backups")


def main():
    """Main backup workflow."""
    try:
        # Create backup
        backup_file = create_backup()

        # Upload to S3 (if configured)
        upload_to_s3(backup_file)

        # Rotate old backups
        rotate_old_backups()

        logger.info("Backup workflow completed successfully")

    except Exception as e:
        logger.error(f"Backup workflow failed: {e}", exc_info=True)
        # Send alert
        exit(1)


if __name__ == "__main__":
    # Validate required environment variables
    required_vars = ["DB_NAME", "DB_USER", "DB_PASSWORD"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]

    if missing_vars:
        logger.error(f"Missing required environment variables: {', '.join(missing_vars)}")
        exit(1)

    main()
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/automation.yml
name: Python Automation

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:  # Manual trigger

jobs:
  run-automation:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt

      - name: Run automation script
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          python automation_script.py

      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: automation-logs
          path: automation.log
```

---

## Best Practices

### 1. Idempotency

```python
def idempotent_operation(record_id: int):
    """
    Operation that can be safely run multiple times.
    Checks if already processed before executing.
    """
    # Check if already processed
    if is_already_processed(record_id):
        logger.info(f"Record {record_id} already processed, skipping")
        return

    # Process record
    process_record(record_id)

    # Mark as processed
    mark_as_processed(record_id)
```

### 2. Graceful Shutdown

```python
import signal
import sys

class AutomationService:
    def __init__(self):
        self.running = True
        signal.signal(signal.SIGINT, self.shutdown)
        signal.signal(signal.SIGTERM, self.shutdown)

    def shutdown(self, signum, frame):
        """Handle shutdown gracefully."""
        logger.info("Shutdown signal received")
        self.running = False
        # Clean up resources
        sys.exit(0)

    def run(self):
        """Main service loop."""
        while self.running:
            # Do work
            time.sleep(1)
```

### 3. Comprehensive Logging

```python
import logging
from logging.handlers import RotatingFileHandler

def setup_logging():
    """Configure structured logging."""
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # File handler with rotation
    file_handler = RotatingFileHandler(
        'automation.log',
        maxBytes=10485760,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))

    logger.addHandler(file_handler)
```

### 4. Monitoring and Alerts

```python
def send_metrics(metric_name: str, value: float):
    """Send metrics to monitoring system."""
    # CloudWatch example
    import boto3
    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_data(
        Namespace='Automation',
        MetricData=[{
            'MetricName': metric_name,
            'Value': value,
            'Unit': 'Count'
        }]
    )
```

---

## Testing Automation Scripts

```python
import unittest
from unittest.mock import patch, MagicMock

class TestAutomation(unittest.TestCase):

    @patch('requests.Session.request')
    def test_api_call_success(self, mock_request):
        """Test successful API call."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'status': 'success'}
        mock_request.return_value = mock_response

        client = APIClient("https://api.example.com", "key")
        result = client.get("/endpoint")

        self.assertEqual(result['status'], 'success')

    @patch('requests.Session.request')
    def test_api_call_retry(self, mock_request):
        """Test API call retry on failure."""
        mock_request.side_effect = [
            requests.exceptions.Timeout(),
            requests.exceptions.Timeout(),
            MagicMock(status_code=200, json=lambda: {'status': 'success'})
        ]

        client = APIClient("https://api.example.com", "key")
        result = client.get("/endpoint")

        self.assertEqual(result['status'], 'success')
        self.assertEqual(mock_request.call_count, 3)


if __name__ == '__main__':
    unittest.main()
```

---

## References

- **APScheduler Documentation**: https://apscheduler.readthedocs.io/
- **Celery Documentation**: https://docs.celeryproject.org/
- **Watchdog Documentation**: https://python-watchdog.readthedocs.io/
- **Requests Documentation**: https://requests.readthedocs.io/
- **Boto3 Documentation**: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
- **Related**: `Python_Security_Standards_Reference.md`
- **Checklist**: `Python_Code_Quality_Checklist.md`

---

**Last Updated**: 2025-12-12
**Version**: 2.0
