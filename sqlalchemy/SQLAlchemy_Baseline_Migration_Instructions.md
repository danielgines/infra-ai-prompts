# Baseline Migration Instructions — AI Prompt Template

> **Context**: Use this prompt to create a baseline migration for existing databases when starting to use Alembic migrations.
> **Reference**: See `SQLAlchemy_Model_Documentation_Standards_Reference.md` for model documentation standards.
> **Template**: See `examples/alembic_baseline_migration_template.py` for complete baseline template.

---

## Role & Objective

You are a **database migration specialist** with expertise in Alembic, SQLAlchemy, and legacy database migration strategies.

Your task: Create a **baseline migration** that marks an existing database schema as the initial version, allowing Alembic to track future schema changes without attempting to recreate existing structures.

---

## Pre-Execution Configuration

**User must specify:**

1. **Database connection**:
   - [ ] Provide DATABASE_URL environment variable
   - [ ] Provide connection parameters (host, port, database, user, password)
   - [ ] Use existing database session in code

2. **Schema scope**:
   - [ ] All tables in database
   - [ ] Specific schema/namespace
   - [ ] Subset of tables (specify which)

3. **Alembic setup status**:
   - [ ] Alembic already initialized (`alembic init` done)
   - [ ] Need to initialize Alembic first
   - [ ] Migrations directory exists

4. **Environment**:
   - [ ] Production database (existing data)
   - [ ] Staging database (test first)
   - [ ] Development database

---

## When to Use Baseline Migrations

### ✅ Use Baseline When:

1. **Legacy Database**: Existing database created without Alembic
   ```
   Scenario: Database tables created via:
   - Direct SQL scripts
   - Base.metadata.create_all()
   - Manual PostgreSQL commands
   - Import from dump file
   ```

2. **Mid-Project Migration Tool Adoption**: Project exists, now adding Alembic
   ```
   Scenario: Application running in production with manual schema management,
   now transitioning to migration-based workflow
   ```

3. **Multiple Databases Need Sync**: Bringing existing databases under version control
   ```
   Scenario: Dev, staging, and prod have same schema but no migration history,
   need to standardize going forward
   ```

### ❌ Don't Use Baseline When:

1. **New Project**: Creating database from scratch
   ```
   Solution: Create normal migrations with table definitions
   $ alembic revision -m "initial schema"
   ```

2. **Alembic Already Tracking**: Migration history already exists
   ```
   Solution: Continue with normal incremental migrations
   ```

3. **Schema Differs Across Environments**: Databases have different structures
   ```
   Solution: Manually reconcile schemas first, then baseline
   ```

---

## Process

### Step 1: Initialize Alembic (if not done)

**Check if Alembic is initialized**:
```bash
# Look for these files/directories
ls -la alembic.ini
ls -la alembic/
ls -la migrations/  # Alternative common name
```

**If not initialized, set up Alembic**:
```bash
# Initialize Alembic
alembic init alembic

# Or with custom directory name
alembic init migrations
```

**Configure `alembic.ini`**:
```ini
# alembic.ini
[alembic]
script_location = alembic
# Set your database URL
sqlalchemy.url = postgresql://user:password@localhost:5432/dbname

# Or use environment variable
# sqlalchemy.url = driver://user:pass@localhost/dbname
```

**Configure `env.py`** (for metadata autogenerate):
```python
# alembic/env.py
from your_app.models import Base  # Import your Base

# Set target metadata
target_metadata = Base.metadata
```

---

### Step 2: Inspect Current Database Schema

**Connect and inspect**:
```python
from sqlalchemy import create_engine, inspect, MetaData

DATABASE_URL = "postgresql://user:password@localhost:5432/dbname"
engine = create_engine(DATABASE_URL)
inspector = inspect(engine)

# Get all tables
tables = inspector.get_table_names()
print(f"Found {len(tables)} tables: {tables}")

# Inspect each table
for table_name in tables:
    print(f"\n--- Table: {table_name} ---")

    # Columns
    columns = inspector.get_columns(table_name)
    print(f"Columns ({len(columns)}):")
    for col in columns:
        print(f"  - {col['name']}: {col['type']}, nullable={col['nullable']}")

    # Primary keys
    pk = inspector.get_pk_constraint(table_name)
    print(f"Primary Key: {pk['constrained_columns']}")

    # Foreign keys
    fks = inspector.get_foreign_keys(table_name)
    if fks:
        print("Foreign Keys:")
        for fk in fks:
            print(f"  - {fk['constrained_columns']} → {fk['referred_table']}.{fk['referred_columns']}")

    # Indexes
    indexes = inspector.get_indexes(table_name)
    if indexes:
        print("Indexes:")
        for idx in indexes:
            print(f"  - {idx['name']}: {idx['column_names']}, unique={idx['unique']}")

    # Check constraints
    checks = inspector.get_check_constraints(table_name)
    if checks:
        print("Check Constraints:")
        for chk in checks:
            print(f"  - {chk['name']}: {chk['sqltext']}")
```

**Document findings**:
```
Schema Inventory:
- Total tables: 12
- Tables with relationships: 8
- Total foreign keys: 15
- Total indexes: 23
- Total constraints: 18

Key Tables:
1. users (12 columns, 2 relationships, 3 indexes)
2. orders (15 columns, 3 relationships, 5 indexes)
3. products (18 columns, 2 relationships, 4 indexes)
...
```

---

### Step 3: Create Baseline Migration

**Generate migration file**:
```bash
# Create empty migration
alembic revision -m "baseline existing schema"

# This creates: alembic/versions/001_abc123_baseline_existing_schema.py
```

**Edit migration file using template**:

Use the template from `examples/alembic_baseline_migration_template.py` and customize:

1. **Update revision ID** (optional, for clarity):
   ```python
   revision: str = '001_baseline'  # Clear semantic version
   ```

2. **Document schema in module docstring**:
   ```python
   """Baseline migration for existing database schema

   Existing Schema:
       Included Tables:
           - users: User accounts and authentication
             Columns: id, email, username, password_hash, is_active, created_at
             Constraints: PK(id), UNIQUE(email, username)
             Indexes: ix_users_email, ix_users_created_at

           - orders: Customer orders
             Columns: id, user_id, status, total_amount, created_at
             Constraints: PK(id), FK(user_id) → users.id CASCADE
             Indexes: ix_orders_user_date(user_id, created_at), ix_orders_status

           - products: Product catalog
             Columns: id, name, description, price, category_id, metadata
             Constraints: PK(id), FK(category_id) → categories.id SET NULL
             Indexes: ix_products_name, ix_products_metadata (GIN)

       Relationships:
           - users ← orders (One-to-Many, CASCADE)
           - categories ← products (One-to-Many, SET NULL)
           - users ← user_profiles (One-to-One, CASCADE)

       Data Volume (as of 2024-12-03):
           - users: ~1.2M records
           - orders: ~5.2M records
           - products: ~45K records

   Purpose:
       Register current schema state without executing DDL, enabling
       incremental migrations from this point forward.
   """
   ```

3. **Keep upgrade() and downgrade() empty**:
   ```python
   def upgrade() -> None:
       """Baseline migration - marks existing schema as initial version.

       This migration does NOT make changes to the database.
       Tables already exist and will not be modified.
       """
       pass

   def downgrade() -> None:
       """No downgrade for baseline.

       Cannot revert to state before initial state.
       """
       pass
   ```

---

### Step 4: Apply Baseline to Database

**Method 1: Stamp (Recommended for Existing Databases)**

```bash
# Mark database as being at baseline version WITHOUT running upgrade()
alembic stamp 001_baseline

# Verify
alembic current
# Output: 001_baseline (head)
```

**When to use stamp**:
- ✅ Existing production database with all tables present
- ✅ All environments already have the schema
- ✅ Want to register version without executing commands

**Method 2: Upgrade (For Empty Databases)**

```bash
# Run upgrade() function (which does nothing in baseline)
alembic upgrade 001_baseline

# Verify
alembic current
# Output: 001_baseline (head)
```

**When to use upgrade**:
- ✅ Empty database that needs to match production
- ✅ Testing migration workflow in clean environment
- ✅ Following standard migration process

---

### Step 5: Verify Baseline Applied

**Check Alembic version table**:
```sql
-- PostgreSQL
SELECT * FROM alembic_version;

-- Expected output:
-- version_num
-- 001_baseline
```

**Check current version via CLI**:
```bash
alembic current

# Expected output:
# 001_baseline (head)
```

**Verify no pending migrations**:
```bash
alembic heads

# Expected output:
# 001_baseline (effective head)
```

---

### Step 6: Test Future Migrations

**Create a test migration**:
```bash
# Add a simple column to test workflow
alembic revision -m "add test column to users"
```

**Edit migration**:
```python
def upgrade() -> None:
    op.add_column('users', sa.Column('test_column', sa.String(50), nullable=True))

def downgrade() -> None:
    op.drop_column('users', 'test_column')
```

**Test in development**:
```bash
# Apply
alembic upgrade head

# Verify column added
psql -d dbname -c "\d users"

# Rollback
alembic downgrade -1

# Verify column removed
psql -d dbname -c "\d users"
```

**If test successful, delete test migration**:
```bash
# Remove test files
rm alembic/versions/002_*_add_test_column_to_users.py

# Reset to baseline
alembic stamp 001_baseline
```

---

## Template Customization Guide

### Customize Module Docstring

**Minimal template** (small projects):
```python
"""Baseline migration for existing database schema

Existing Schema:
    Tables: users, orders, products, categories
    Total records: ~6.5M across all tables

Purpose:
    Mark existing schema as initial version for Alembic tracking.

How to Apply:
    $ alembic stamp 001_baseline
"""
```

**Standard template** (most projects):
```python
"""Baseline migration for existing database schema

Existing Schema:
    Included Tables:
        - users: Authentication and profiles
        - orders: E-commerce transactions
        - products: Product catalog

    Relationships:
        - users ← orders (One-to-Many)
        - categories ← products (One-to-Many)

    Data Volume (as of 2024-12-03):
        - users: ~1.2M records
        - orders: ~5.2M records

Purpose:
    Register current schema without DDL execution.

How to Apply:
    $ alembic stamp 001_baseline
"""
```

**Comprehensive template** (large projects, use provided template):
```python
# Use examples/alembic_baseline_migration_template.py
# Includes all sections:
# - Detailed schema documentation
# - Relationships and constraints
# - Verification queries
# - Best practices
# - Historical context
```

---

## Common Scenarios

### Scenario 1: Production Database + Alembic Adoption

**Problem**: Production database exists, want to start using Alembic

**Solution**:
1. Initialize Alembic in codebase
2. Create baseline migration documenting current schema
3. Apply baseline to production using `stamp`:
   ```bash
   # On production
   alembic stamp 001_baseline
   ```
4. Future changes go through normal migration workflow

---

### Scenario 2: Multiple Environments with Same Schema

**Problem**: Dev, staging, prod all have same schema but no migrations

**Solution**:
1. Inspect production schema (source of truth)
2. Create baseline migration based on production
3. Apply to all environments:
   ```bash
   # Dev
   alembic stamp 001_baseline

   # Staging
   alembic stamp 001_baseline

   # Production
   alembic stamp 001_baseline
   ```
4. All environments now at same migration version

---

### Scenario 3: Partial Schema Migration

**Problem**: Want to track only some tables with Alembic

**Solution**:
1. Create baseline documenting ALL tables (for reference)
2. Mark upgrade()/downgrade() as pass (no operations)
3. Future migrations only modify tracked tables
4. Document which tables are tracked in baseline docstring:
   ```python
   """
   Tracked Tables (Alembic manages):
       - users, orders, products

   Untracked Tables (manually managed):
       - audit_logs, temp_imports, cache_data
   """
   ```

---

### Scenario 4: Schema Differs Between Environments

**Problem**: Dev and prod have different schemas

**Solution**:
1. **DO NOT baseline yet**
2. First reconcile schemas:
   ```bash
   # Option A: Make dev match prod
   pg_dump --schema-only prod_db | psql dev_db

   # Option B: Make prod match dev (DANGEROUS)
   # Not recommended without extensive testing
   ```
3. After schemas match, then create baseline
4. Document reconciliation in migration docstring

---

## Validation Queries

### PostgreSQL

```sql
-- List all tables
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Table sizes
SELECT
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- All constraints
SELECT
    conname as constraint_name,
    contype as constraint_type,
    conrelid::regclass as table_name
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, contype;

-- All indexes
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Foreign key relationships
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;
```

### SQLAlchemy

```python
from sqlalchemy import create_engine, inspect, MetaData, Table

engine = create_engine(DATABASE_URL)
inspector = inspect(engine)
metadata = MetaData()

# Reflect all tables
metadata.reflect(bind=engine)

# Print schema summary
print(f"Tables: {list(metadata.tables.keys())}")

for table_name, table in metadata.tables.items():
    print(f"\n{table_name}:")
    print(f"  Columns: {[c.name for c in table.columns]}")
    print(f"  Primary Key: {[c.name for c in table.primary_key]}")
    print(f"  Foreign Keys: {[f'{fk.parent.name} → {fk.column}' for fk in table.foreign_keys]}")
    print(f"  Indexes: {[idx.name for idx in table.indexes]}")
```

---

## Best Practices

### ✅ DO

- **Document thoroughly**: Include all tables, relationships, constraints in docstring
- **Use stamp for existing databases**: Never run `upgrade` on database with existing tables
- **Test in staging first**: Apply baseline to staging, verify, then production
- **Backup before applying**: Always backup database before any migration operation
- **Version control migrations**: Commit migration files to git
- **One baseline per project**: Create single baseline at migration adoption point
- **Include data volume**: Document approximate row counts for context
- **Explain purpose clearly**: Help future developers understand why baseline exists

### ❌ DON'T

- **Don't run upgrade on existing database**: Use stamp instead
- **Don't modify baseline after applying**: Baseline is immutable once applied
- **Don't include DDL in baseline**: upgrade() and downgrade() should pass
- **Don't create multiple baselines**: One baseline per project lifecycle
- **Don't skip documentation**: Future developers need context
- **Don't ignore schema differences**: Reconcile environments before baseline
- **Don't baseline in production first**: Test in dev/staging first
- **Don't forget to commit**: Migration files must be in version control

---

## Troubleshooting

### Issue 1: "Table already exists" after baseline

**Cause**: Ran `upgrade` instead of `stamp` on existing database

**Solution**:
```bash
# Check current version
alembic current

# If at baseline, you're fine (just got error)
# If not at baseline, stamp it
alembic stamp 001_baseline

# Do NOT try to re-run upgrade
```

---

### Issue 2: Alembic version table doesn't exist

**Cause**: Alembic never initialized

**Solution**:
```bash
# Stamp will create alembic_version table
alembic stamp 001_baseline

# Or manually create
alembic upgrade head  # If baseline is head
```

---

### Issue 3: Schema differs from baseline documentation

**Cause**: Database changed after baseline created

**Solution**:
```bash
# Option A: Create new migration for changes
alembic revision -m "update schema differences"
# Document actual changes in new migration

# Option B: Update baseline documentation only (if not applied yet)
# Edit baseline docstring to match reality
# Only if baseline not yet applied to production
```

---

### Issue 4: Multiple heads after baseline

**Cause**: Created migrations before baseline was properly set

**Solution**:
```bash
# List all heads
alembic heads

# Merge heads
alembic merge -m "merge heads"

# Or remove incorrect migrations and restart from baseline
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
# .github/workflows/migrations.yml
name: Database Migrations

on:
  pull_request:
    paths:
      - 'alembic/versions/**'

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install sqlalchemy alembic psycopg2-binary

      - name: Run migrations
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
        run: |
          # Create database
          psql -h localhost -U postgres -c "CREATE DATABASE test;"

          # Apply all migrations
          alembic upgrade head

          # Downgrade to baseline
          alembic downgrade 001_baseline

          # Upgrade back to head
          alembic upgrade head
```

---

## Next Steps

After successfully applying baseline:

1. **Create first real migration**:
   ```bash
   alembic revision -m "add user last_login column"
   ```

2. **Document migration workflow** for team:
   - How to create migrations
   - How to test locally
   - How to deploy to production

3. **Set up autogenerate** (optional):
   ```bash
   # Auto-detect model changes
   alembic revision --autogenerate -m "detected changes"
   ```

4. **Establish migration review process**:
   - Code review required for migrations
   - Testing checklist before production
   - Rollback plan for each migration

5. **Add migration documentation**:
   - README in migrations directory
   - Team onboarding guide
   - Production deployment runbook

---

## Success Criteria

**Baseline is successfully applied when**:

1. ✅ `alembic current` shows baseline version
2. ✅ Database schema unchanged (no tables created/dropped)
3. ✅ `alembic_version` table contains baseline record
4. ✅ Test migration can be created and applied
5. ✅ Test migration can be rolled back
6. ✅ All environments (dev/staging/prod) at same baseline
7. ✅ Team understands migration workflow
8. ✅ CI/CD pipeline tests migrations
9. ✅ Documentation complete and committed
10. ✅ Backup and rollback procedures documented

---

**Philosophy**: Baseline migrations bridge the gap between manual schema management and migration-based workflows. A well-documented baseline provides context for future developers and ensures smooth transition to controlled schema evolution.
