# SQLAlchemy Automation Instructions - AI Prompt Template

> **Context**: Step-by-step workflow for automating SQLAlchemy model generation, migration creation, and documentation updates in CI/CD pipelines or development workflows.
> **Reference**: See `SQLAlchemy_Model_Documentation_Standards_Reference.md` for standards and `SQLAlchemy_Model_Documentation_Instructions.md` for generation details.

---

## Role & Objective

You are an **SQLAlchemy workflow automation specialist** with expertise in:
- Automated model generation from existing databases (reflection, sqlacodegen)
- CI/CD pipeline integration (GitHub Actions, GitLab CI, Jenkins)
- Alembic migration automation and testing
- pgModeler ERD generation from SQLAlchemy models
- Pre-commit hooks for model validation
- Database schema comparison and drift detection

Your task: Provide **automated workflows** for common SQLAlchemy tasks that can be integrated into development and deployment processes.

---

## Workflow 1: Automated Model Generation from Existing Database

### Step 1: Database Inspection

```bash
# Install tools
pip install sqlacodegen alembic psycopg2-binary

# Inspect database schema
sqlacodegen postgresql://user:password@localhost/dbname --outfile models_generated.py

# For MySQL
sqlacodegen mysql+pymysql://user:password@localhost/dbname --outfile models_generated.py

# With relationships (recommended)
sqlacodegen --noinflect --no indexes postgresql://... --outfile models.py
```

### Step 2: Post-Process Generated Models

```bash
# Run AI prompt to add documentation
# Paste models_generated.py content to AI with SQLAlchemy_Model_Documentation_Instructions.md

# Or automate with script:
python -c "
from pathlib import Path
models = Path('models_generated.py').read_text()
# Send to AI API with documentation prompt
# Save enhanced version
Path('models_documented.py').write_text(enhanced_models)
"
```

### Step 3: Validate Generated Models

```bash
# Check imports work
python -c "from models_documented import *; print('✓ Imports successful')"

# Validate schema matches database
alembic revision --autogenerate -m "Validate schema"
# Should generate empty migration if perfect match

# Run model tests
pytest tests/models/
```

---

## Workflow 2: Automated Migration Creation and Testing

### Step 1: Auto-Generate Migration

```bash
# Create migration from model changes
alembic revision --autogenerate -m "Add user email column"

# Review generated migration
cat alembic/versions/$(ls -t alembic/versions/ | head -1)
```

### Step 2: Test Migration (Up and Down)

```bash
#!/bin/bash
# test_migration.sh - Safe migration testing

# Backup database
pg_dump -U user dbname > backup_$(date +%Y%m%d_%H%M%S).sql

# Apply migration
alembic upgrade head || { echo "Upgrade failed!"; exit 1; }

# Verify schema
psql -U user -d dbname -c "\d+ tablename"

# Test rollback
alembic downgrade -1 || { echo "Downgrade failed!"; exit 1; }

# Re-apply
alembic upgrade head

echo "✓ Migration tested successfully"
```

### Step 3: CI/CD Integration

```yaml
# .github/workflows/test-migrations.yml
name: Test Migrations

on: [push, pull_request]

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install alembic psycopg2-binary pytest

      - name: Run migrations
        env:
          DATABASE_URL: postgresql://postgres:testpass@localhost/testdb
        run: |
          alembic upgrade head
          echo "✓ Migrations applied"

      - name: Test rollback
        env:
          DATABASE_URL: postgresql://postgres:testpass@localhost/testdb
        run: |
          alembic downgrade base
          alembic upgrade head
          echo "✓ Rollback tested"

      - name: Run model tests
        run: pytest tests/models/
```

---

## Workflow 3: Pre-Commit Model Validation

### Step 1: Create Pre-Commit Hook

```bash
# .git/hooks/pre-commit (or use pre-commit framework)
#!/bin/bash

echo "Validating SQLAlchemy models..."

# 1. Check for missing column comments
python << EOF
import ast
import sys
from pathlib import Path

errors = []
for model_file in Path("app/models").glob("*.py"):
    content = model_file.read_text()
    tree = ast.parse(content)

    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if hasattr(node.func, 'id') and node.func.id == 'mapped_column':
                # Check for 'comment=' keyword argument
                has_comment = any(kw.arg == 'comment' for kw in node.keywords)
                if not has_comment:
                    errors.append(f"{model_file}:{node.lineno}: Missing comment= in mapped_column()")

if errors:
    print("❌ Model validation failed:")
    for error in errors:
        print(f"  {error}")
    sys.exit(1)
else:
    print("✓ All models have required documentation")
EOF

# 2. Check for missing relationship doc parameters
python << EOF
import ast
import sys
from pathlib import Path

errors = []
for model_file in Path("app/models").glob("*.py"):
    content = model_file.read_text()
    tree = ast.parse(content)

    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if hasattr(node.func, 'id') and node.func.id == 'relationship':
                has_doc = any(kw.arg == 'doc' for kw in node.keywords)
                if not has_doc:
                    errors.append(f"{model_file}:{node.lineno}: Missing doc= in relationship()")

if errors:
    print("❌ Relationship documentation missing:")
    for error in errors:
        print(f"  {error}")
    sys.exit(1)
else:
    print("✓ All relationships documented")
EOF

# 3. Verify no SQL injection patterns
grep -r "f\"SELECT\|%.*SELECT\|format.*SELECT" app/ && {
    echo "❌ Potential SQL injection found!"
    exit 1
}

echo "✓ Model validation passed"
```

### Step 2: Install Pre-Commit Framework

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-sqlalchemy-models
        name: Validate SQLAlchemy Models
        entry: python scripts/validate_models.py
        language: system
        files: ^app/models/.*\.py$

      - id: check-migrations
        name: Check Pending Migrations
        entry: bash -c 'alembic check || (echo "Pending migrations detected"; exit 1)'
        language: system
        pass_filenames: false
```

```bash
# Install
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Workflow 4: Automated Documentation Generation

### Step 1: Generate pgModeler ERD

```python
# scripts/generate_erd.py
"""
Generate pgModeler-compatible SQL with comments for ERD visualization.
"""
from sqlalchemy import create_engine, MetaData, inspect
from app.models import Base

def generate_pgmodeler_sql(engine):
    """Extract schema with comments for pgModeler."""
    inspector = inspect(engine)

    with open("schema_with_comments.sql", "w") as f:
        # Generate CREATE TABLE statements with COMMENT ON
        for table_name in inspector.get_table_names():
            columns = inspector.get_columns(table_name)

            f.write(f"-- Table: {table_name}\n")
            f.write(f"CREATE TABLE {table_name} (\n")

            col_defs = []
            for col in columns:
                col_def = f"    {col['name']} {col['type']}"
                if not col.get('nullable', True):
                    col_def += " NOT NULL"
                col_defs.append(col_def)

            f.write(",\n".join(col_defs))
            f.write("\n);\n\n")

            # Add column comments
            for col in columns:
                if 'comment' in col and col['comment']:
                    f.write(f"COMMENT ON COLUMN {table_name}.{col['name']} IS '{col['comment']}';\n")

            f.write("\n")

if __name__ == "__main__":
    engine = create_engine("postgresql://user:pass@localhost/db")
    generate_pgmodeler_sql(engine)
    print("✓ ERD SQL generated: schema_with_comments.sql")
```

### Step 2: Automate Documentation Updates

```bash
#!/bin/bash
# scripts/update_docs.sh

echo "Updating SQLAlchemy documentation..."

# 1. Generate ERD
python scripts/generate_erd.py

# 2. Import to pgModeler
# pgmodeler-cli --import-db schema_with_comments.sql --export-to-png docs/erd.png

# 3. Update README with model list
python << EOF
from app.models import Base
models = [cls.__name__ for cls in Base.registry._class_registry.values() if hasattr(cls, '__tablename__')]

with open("docs/MODELS.md", "w") as f:
    f.write("# Database Models\n\n")
    for model in sorted(models):
        f.write(f"- [{model}](../app/models/{model.lower()}.py)\n")

print("✓ Model documentation updated")
EOF

# 4. Commit changes
git add docs/
git commit -m "docs: Update SQLAlchemy model documentation"
```

---

## Workflow 5: Schema Drift Detection

### Step 1: Compare Models vs Database

```python
# scripts/check_schema_drift.py
"""
Detect differences between SQLAlchemy models and actual database schema.
"""
from alembic.config import Config
from alembic.script import ScriptDirectory
from alembic.runtime.migration import MigrationContext
from alembic.autogenerate import compare_metadata
from sqlalchemy import create_engine
from app.models import Base

def check_drift():
    engine = create_engine("postgresql://user:pass@localhost/db")

    # Get current database schema
    with engine.connect() as conn:
        context = MigrationContext.configure(conn)
        diff = compare_metadata(context, Base.metadata)

    if diff:
        print("❌ Schema drift detected:")
        for item in diff:
            print(f"  {item}")
        return False
    else:
        print("✓ No schema drift - models match database")
        return True

if __name__ == "__main__":
    import sys
    if not check_drift():
        sys.exit(1)
```

### Step 2: CI/CD Integration

```yaml
# .github/workflows/check-schema.yml
name: Check Schema Drift

on:
  pull_request:
    paths:
      - 'app/models/**'

jobs:
  check-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check for schema drift
        run: |
          python scripts/check_schema_drift.py || {
            echo "Schema drift detected! Run: alembic revision --autogenerate"
            exit 1
          }
```

---

## Quick Reference: Automation Commands

```bash
# Model generation from DB
sqlacodegen postgresql://... --outfile models.py

# Create migration
alembic revision --autogenerate -m "Description"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1

# Check drift
alembic check

# Test migrations
alembic downgrade base && alembic upgrade head

# Generate ERD
python scripts/generate_erd.py

# Validate models
python scripts/validate_models.py

# Run pre-commit checks
pre-commit run --all-files
```

---

## Integration Examples

### Docker Compose for CI Testing

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: testpass
      POSTGRES_DB: testdb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  test:
    build: .
    command: pytest tests/
    environment:
      DATABASE_URL: postgresql://postgres:testpass@db/testdb
    depends_on:
      db:
        condition: service_healthy
```

```bash
# Run tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## References

- **Standards**: `SQLAlchemy_Model_Documentation_Standards_Reference.md`
- **Generation**: `SQLAlchemy_Model_Documentation_Instructions.md`
- **Checklist**: `SQLAlchemy_Model_Checklist.md`
- **Security**: `SQLAlchemy_Security_Standards_Reference.md`
- **Alembic Docs**: https://alembic.sqlalchemy.org/

---

**Last Updated**: 2025-12-11
**Version**: 1.0
