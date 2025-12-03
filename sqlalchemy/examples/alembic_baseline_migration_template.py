"""Baseline migration for existing database schema

Revision ID: 001_baseline
Revises:
Create Date: 2024-12-03 15:30:00.000000

Context:
    This baseline migration marks the initial state of an existing legacy
    database, allowing Alembic to start tracking schema changes from this
    point forward without attempting to recreate existing structures.

Existing Schema:
    Included Tables:
        - sellers: Master data of marketplace sellers
          Contains: seller_id, name, tax_id, status, metadata
          Constraints: PK(seller_id), UNIQUE(tax_id)
          Indexes: ix_sellers_tax_id, ix_sellers_status

        - seller_scan_status: Scraping status and retry logic
          Contains: id, seller_id, scan_date, status, retry_count
          Constraints: PK(id), FK(seller_id) → sellers.seller_id CASCADE
          Indexes: ix_scan_status_seller_date

    Relationships:
        - sellers ← seller_scan_status (One-to-Many)
          Cascade: DELETE CASCADE (scan status deleted with seller)

    Data Volume (as of 2024-12-03):
        - sellers: ~5.2K records
        - seller_scan_status: ~180K records
        - Growth: ~500 scans/day

Purpose:
    Register the current schema state without executing DDL commands, enabling
    future migrations to be applied incrementally and in a controlled manner.

    This baseline prevents conflicts between existing database structures and
    creation commands that Alembic would attempt to execute without this
    starting point.

How to Apply:
    Method 1 - Stamp (recommended):
        Marks the database as being at this version without executing commands:
        $ alembic stamp 001_baseline

        When to use: Database already contains all tables and structures

    Method 2 - Upgrade:
        Applies migration normally (safe, does not execute DDL):
        $ alembic upgrade 001_baseline

        When to use: Normal process after stamp, or in empty environments

Verification:
    To confirm current schema matches baseline:

    PostgreSQL:
        -- Check tables
        SELECT tablename FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename;

        -- Check constraints
        SELECT conname, contype
        FROM pg_constraint
        WHERE connamespace = 'public'::regnamespace;

        -- Check indexes
        SELECT indexname, tablename
        FROM pg_indexes
        WHERE schemaname = 'public';

    SQLAlchemy:
        >>> from sqlalchemy import inspect
        >>> inspector = inspect(engine)
        >>> tables = inspector.get_table_names()
        >>> print(f"Tables: {tables}")

Next Migrations:
    After applying this baseline, future schema changes should be created
    as incremental migrations:

    Examples:
        - 002_add_seller_rating_column: Add rating column
        - 003_add_seller_metadata_index: Create GIN index on JSONB
        - 004_add_comprehensive_comments: Full documentation (pgModeler)
        - 005_add_audit_triggers: Automatic audit triggers

    Creation pattern:
        $ alembic revision -m "change description"
        # Edit generated file in migrations/versions/
        $ alembic upgrade head

Rollback:
    Cannot downgrade from a baseline because it represents the initial
    database state. There is no "previous" state to revert to.

    If needed to remove version record:
        $ alembic downgrade base  # Removes all version records
        # WARNING: Does not remove database structures, only Alembic records

Historical Context:
    Project History:
        This project was created with manual schema before implementing
        Alembic. Tables were created via direct SQL scripts or through
        SQLAlchemy's Base.metadata.create_all().

    Motivation for Baseline:
        - Standardize schema management via migrations
        - Enable team collaboration with version control
        - Prepare for controlled future changes
        - Integrate with CI/CD for automated deploys

    Alternatives Considered:
        1. Recreate database from scratch: Rejected (loss of historical data)
        2. Export DDL and transform into migration: Rejected (complex)
        3. Empty baseline (this solution): Chosen (simple, safe)

Best Practices:
    When working with baseline migrations:
        ✅ DO:
            - Always use 'alembic stamp' on existing databases
            - Document current schema in detail in this migration
            - Test future migrations in staging environment first
            - Backup before applying any migration
            - Commit migration files to version control

        ❌ DON'T:
            - Run 'alembic upgrade' directly without stamp on existing database
            - Modify this baseline after applying it in production
            - Downgrade from baseline (impossible, meaningless)
            - Run create_all() after initializing Alembic
            - Ignore conflicts between code and current schema

Security & Compliance:
    - Migration files contain no sensitive data
    - Schema changes must pass code review
    - Production requires approval before upgrade
    - Backup mandatory before production migrations
    - Audit log of all applied migrations

Author: Your Name
Created: 2024-12-03
Last Updated: 2024-12-03
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '001_baseline'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Baseline migration - Marks existing schema as initial version.

    This migration does NOT make changes to the database.

    It registers the current state of the existing schema, including:
        - sellers: Master data of marketplace sellers
        - seller_scan_status: Scraping status and retry logic

    Purpose:
        Allows Alembic to start tracking schema changes from this point
        forward, without attempting to recreate tables that already exist
        in the database.

    How to apply:
        To mark the database as being at this version without executing commands:
        $ alembic stamp 001_baseline

        To apply (safe, does nothing to the database):
        $ alembic upgrade head

    Context:
        This project was created with manual schema before implementing
        Alembic. This baseline allows adding future migrations without
        conflicts with existing tables.

    Next migrations:
        Future schema changes (add columns, indexes, comments) will be
        created as incremental migrations from this baseline.
    """
    # This baseline migration does not execute any DDL commands
    # Tables already exist in the database
    pass


def downgrade() -> None:
    """No downgrade for baseline.

    Baseline represents the initial state of the existing database.
    Cannot "undo" initial state because there is no previous state.

    If needed to remove Alembic version record:
        $ alembic downgrade base

    IMPORTANT: This command only removes the version record from the
    alembic_version table, does NOT remove any database structures.
    """
    pass
