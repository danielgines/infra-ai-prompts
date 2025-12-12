#!/usr/bin/env python3
"""
Basic Automation Example

Demonstrates:
- Simple scheduled tasks
- Environment variable configuration
- File operations
- Basic error handling
- Logging setup
- Type hints
- Proper exit codes

Usage:
    export BACKUP_DIR="/path/to/backups"
    export DATA_DIR="/path/to/data"
    python basic_automation.py
"""

import os
import sys
import logging
import shutil
from pathlib import Path
from datetime import datetime
from typing import Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('automation.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


def get_env_variable(key: str, default: Optional[str] = None) -> str:
    """
    Get environment variable with validation.

    Args:
        key: Environment variable name
        default: Default value if variable not set

    Returns:
        Environment variable value

    Raises:
        ValueError: If variable not set and no default provided
    """
    value = os.getenv(key, default)

    if value is None:
        raise ValueError(f"Environment variable {key} not set")

    if not value.strip():
        raise ValueError(f"Environment variable {key} is empty")

    return value


def create_backup(source_dir: Path, backup_dir: Path) -> bool:
    """
    Create backup of source directory.

    Args:
        source_dir: Directory to backup
        backup_dir: Backup destination directory

    Returns:
        True if backup successful, False otherwise
    """
    try:
        # Validate source directory exists
        if not source_dir.exists():
            logger.error(f"Source directory does not exist: {source_dir}")
            return False

        if not source_dir.is_dir():
            logger.error(f"Source path is not a directory: {source_dir}")
            return False

        # Create backup directory if it doesn't exist
        backup_dir.mkdir(parents=True, exist_ok=True)

        # Generate timestamp-based backup filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"backup_{timestamp}"
        backup_path = backup_dir / backup_name

        logger.info(f"Creating backup: {source_dir} -> {backup_path}")

        # Copy directory tree
        shutil.copytree(source_dir, backup_path)

        # Verify backup was created
        if not backup_path.exists():
            logger.error(f"Backup verification failed: {backup_path}")
            return False

        # Log success with size information
        backup_size = sum(
            f.stat().st_size
            for f in backup_path.rglob('*')
            if f.is_file()
        )
        size_mb = backup_size / (1024 * 1024)

        logger.info(f"Backup created successfully: {backup_path} ({size_mb:.2f} MB)")
        return True

    except PermissionError as e:
        logger.error(f"Permission denied during backup: {e}")
        return False

    except OSError as e:
        logger.error(f"OS error during backup: {e}")
        return False

    except Exception as e:
        logger.error(f"Unexpected error during backup: {e}", exc_info=True)
        return False


def cleanup_old_backups(backup_dir: Path, keep_count: int = 5) -> int:
    """
    Remove old backups, keeping only the most recent ones.

    Args:
        backup_dir: Directory containing backups
        keep_count: Number of recent backups to keep

    Returns:
        Number of backups removed
    """
    try:
        if not backup_dir.exists():
            logger.warning(f"Backup directory does not exist: {backup_dir}")
            return 0

        # Get all backup directories
        backups = [
            d for d in backup_dir.iterdir()
            if d.is_dir() and d.name.startswith("backup_")
        ]

        if len(backups) <= keep_count:
            logger.info(f"No cleanup needed. Found {len(backups)} backups, keeping {keep_count}")
            return 0

        # Sort by modification time (oldest first)
        backups.sort(key=lambda x: x.stat().st_mtime)

        # Remove oldest backups
        removed_count = 0
        backups_to_remove = backups[:-keep_count]

        for backup in backups_to_remove:
            try:
                logger.info(f"Removing old backup: {backup}")
                shutil.rmtree(backup)
                removed_count += 1
            except Exception as e:
                logger.error(f"Failed to remove backup {backup}: {e}")

        logger.info(f"Cleanup complete. Removed {removed_count} old backups")
        return removed_count

    except Exception as e:
        logger.error(f"Error during cleanup: {e}", exc_info=True)
        return 0


def main() -> int:
    """
    Main automation script entry point.

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    logger.info("=== Backup Automation Started ===")

    try:
        # Load configuration from environment variables
        data_dir = Path(get_env_variable("DATA_DIR", "/tmp/data"))
        backup_dir = Path(get_env_variable("BACKUP_DIR", "/tmp/backups"))

        logger.info(f"Configuration: DATA_DIR={data_dir}, BACKUP_DIR={backup_dir}")

        # Create backup
        backup_success = create_backup(data_dir, backup_dir)

        if not backup_success:
            logger.error("Backup failed")
            return 1

        # Cleanup old backups
        removed = cleanup_old_backups(backup_dir, keep_count=5)
        logger.info(f"Removed {removed} old backups")

        logger.info("=== Backup Automation Completed Successfully ===")
        return 0

    except ValueError as e:
        logger.error(f"Configuration error: {e}")
        logger.error("Please set DATA_DIR and BACKUP_DIR environment variables")
        return 1

    except KeyboardInterrupt:
        logger.warning("Script interrupted by user")
        return 1

    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
