# [Your Project Name] SQLAlchemy Documentation Preferences

> **Context**: Custom conventions for [project/team name]
> **Author**: [Your name]
> **Last Updated**: [Date]
> **Applies to**: SQLAlchemy model documentation

---

## Documentation Style

**Selected approach** (choose one):
- [ ] Detailed: Comprehensive docstrings with examples, context, and references
- [ ] Standard: Balanced documentation with essential information
- [ ] Minimal: Concise comments focused on non-obvious behavior

**Rationale**: [Why this approach fits your project]

---

## Column Naming Conventions

### Primary Keys

**Convention**:
- [ ] Use `id` for all tables
- [ ] Use `{table}_id` format (e.g., `user_id` in users table)
- [ ] Use UUIDs instead of integers
- [ ] Other: [specify]

**Examples**:
```python
# Your standard
```

---

### Foreign Keys

**Format**: [e.g., `{referenced_table_singular}_id`]

**Examples**:
```python
# Your pattern
user_id = Column(Integer, ForeignKey('users.id'))
category_id = Column(Integer, ForeignKey('categories.id'))
```

---

### Timestamps

**Required timestamp columns**:
- [ ] `created_at` (creation time)
- [ ] `updated_at` (last modification time)
- [ ] `deleted_at` (soft delete)
- [ ] `created_by_id` (who created)
- [ ] `updated_by_id` (who modified)
- [ ] Other: [specify]

**Timezone**: [UTC / Local / Other]

**Examples**:
```python
# Your pattern
```

---

### Boolean Columns

**Naming pattern**: [e.g., `is_`, `has_`, `can_` prefix]

**Default values**: [True / False / depends on context]

**Examples**:
```python
is_active = Column(Boolean, default=True)
has_verified_email = Column(Boolean, default=False)
can_receive_notifications = Column(Boolean, default=True)
```

---

### Enum Columns

**Approach** (choose one):
- [ ] String columns with check constraints
- [ ] SQLAlchemy Enum type with Python Enum class
- [ ] PostgreSQL ENUM type
- [ ] Other: [specify]

**Examples**:
```python
# Your pattern
```

---

## Comment Format

### Standard Format

**Template**: [Your comment format]

**Example**:
```python
email = Column(
    String(255),
    comment='[Your format here]'
)
```

---

### Required Information

**Every column comment must include**:
- [ ] Description
- [ ] Examples (how many: [2-5])
- [ ] Business rule reference
- [ ] Data classification (PUBLIC, PII, SENSITIVE, etc.)
- [ ] Validation rules
- [ ] NULL semantics (if nullable)
- [ ] Other: [specify]

---

### Data Classification

**Categories used in your project**:
- [ ] PUBLIC: [definition]
- [ ] INTERNAL: [definition]
- [ ] PII: [definition]
- [ ] SENSITIVE: [definition]
- [ ] Other: [specify]

**Format in comments**:
```python
comment='[Description] [CLASSIFICATION]. Examples: ...'
```

---

## Relationship Conventions

### Cascade Rules

**Your policies**:
- Parent-child (strong ownership): [cascade setting]
- Optional reference: [ondelete setting]
- Required reference: [ondelete setting]

**Examples**:
```python
# Your patterns
```

---

### Lazy Loading

**Default strategy**: [select / dynamic / joined / subquery]

**Special cases**:
- Large collections (>X items): [strategy]
- Frequently accessed: [strategy]
- Rarely accessed: [strategy]

---

### Back Populates vs Backref

**Your choice**:
- [ ] Always use `back_populates` (explicit)
- [ ] Use `backref` (implicit)
- [ ] Mixed (specify when)

**Rationale**: [Why]

---

## Index Strategy

### Required Indexes

**Always index**:
- [ ] Primary keys (automatic)
- [ ] Foreign keys
- [ ] Columns in WHERE clauses
- [ ] Columns in ORDER BY
- [ ] Unique constraints
- [ ] Other: [specify]

---

### Composite Indexes

**Naming convention**: [e.g., `ix_{table}_{col1}_{col2}`]

**Column order**: [Most selective first / By query pattern / Other]

**Documentation requirement**:
```python
# Example of how you document composite indexes
```

---

### Partial Indexes

**When to use**: [Your criteria]

**PostgreSQL-specific**: [Yes / No / Optional]

---

## Database-Specific Features

### PostgreSQL

**Features used**:
- [ ] JSONB columns
- [ ] Array columns
- [ ] Full-text search
- [ ] Partial indexes
- [ ] Materialized views
- [ ] Triggers
- [ ] Other: [specify]

**Documentation requirements**: [How to document these]

---

### Other Databases

**Database**: [MySQL / SQLite / Oracle / Other]

**Specific features**: [List]

---

## Migration Standards

### Alembic Migrations

**Docstring required sections**:
```python
"""[Migration title]

Revision ID: [auto-generated]
Revises: [auto-generated]
Create Date: [auto-generated]

Changes:
    - [Your format]

Deployment Steps:
    - [Your format]

Rollback:
    - [Your format]

Testing:
    - [Your format]

[Other sections you require]
"""
```

---

### Deployment Windows

**Allowed times**: [e.g., Sundays 2-4 AM UTC]

**Restrictions**:
- Large migrations (>X rows): [requirement]
- Breaking changes: [requirement]
- Data migrations: [requirement]

---

## Security Requirements

### Sensitive Data

**Columns requiring encryption**:
- [ ] Passwords (always bcrypt/argon2)
- [ ] API keys (always hashed)
- [ ] Payment info (PCI DSS)
- [ ] PII (GDPR/compliance)
- [ ] Other: [specify]

**Documentation format**:
```python
# How you document sensitive columns
```

---

### Audit Trail

**Required columns**:
- [ ] `created_by_id`: Who created record
- [ ] `updated_by_id`: Who last updated
- [ ] `deleted_by_id`: Who deleted (soft delete)
- [ ] Other: [specify]

**Foreign key target**: [e.g., `users.id`, `admins.id`]

---

## Soft Delete Pattern

**Approach**:
- [ ] Use `deleted_at` column (NULL = active)
- [ ] Use `is_deleted` boolean
- [ ] Don't use soft delete
- [ ] Other: [specify]

**Hard delete policy**: [When allowed / Never / Other]

**Examples**:
```python
# Your pattern
```

---

## Data Examples Protocol

### Source of Examples

**Preferred method**:
- [ ] Query live database (production)
- [ ] Query staging database
- [ ] Query development database
- [ ] Generate synthetic examples
- [ ] Other: [specify]

---

### Anonymization Rules

**For PII**:
- Emails: [Your format, e.g., user@example.com]
- Names: [Your format]
- Phone numbers: [Your format]
- Addresses: [Your format]

**For sensitive data**:
- Passwords/hashes: [How to show pattern]
- API keys: [How to show pattern]
- Payment info: [Never show / Generic pattern]

---

## Framework Integration

### FastAPI

**Special requirements**:
- [ ] Pydantic model generation
- [ ] Async session support
- [ ] Dependency injection patterns
- [ ] Other: [specify]

**Example**:
```python
# Your FastAPI-specific patterns
```

---

### Flask-SQLAlchemy

**Special requirements**:
- [ ] Use `db.Model` base class
- [ ] Flask app context
- [ ] Migration commands
- [ ] Other: [specify]

---

### Django (if using SQLAlchemy alongside Django ORM)

**Special requirements**: [specify]

---

### Other Framework

**Framework**: [name]

**Requirements**: [specify]

---

## Performance Guidelines

### Query Performance

**Document when**:
- Query time > [X ms]
- Result set > [X rows]
- Complex joins (> [X] tables)

**Format**:
```python
# Your performance note format
```

---

### Data Volume

**Document when**:
- Table > [X] rows
- Growth rate > [X] rows/day
- Partition strategy needed

---

## Testing Requirements

### Model Testing

**Required tests**:
- [ ] Column constraints
- [ ] Relationship loading
- [ ] Cascade behaviors
- [ ] Index usage
- [ ] Migration up/down
- [ ] Other: [specify]

---

## Version Control

### Model Changes

**Review requirements**:
- [ ] Peer review required
- [ ] DBA approval for schema changes
- [ ] Security review for sensitive columns
- [ ] Other: [specify]

---

### Migration Review

**Checklist before merge**:
- [ ] Tested on staging
- [ ] Rollback strategy documented
- [ ] Performance impact assessed
- [ ] Downtime estimated
- [ ] Other: [specify]

---

## Custom Rules

### [Category 1]

**Requirement**: [Describe]

**Examples**:
```python
# Your examples
```

---

### [Category 2]

**Requirement**: [Describe]

**Examples**:
```python
# Your examples
```

---

## Exceptions

### When to Deviate from Standards

**Allowed exceptions**:
1. [Reason 1]: [Alternative approach]
2. [Reason 2]: [Alternative approach]

**Documentation requirement**: [How to document exceptions]

---

## Quality Checklist

Before committing model changes:

- [ ] All columns have comments with examples
- [ ] Class docstring includes relationships, indexes, constraints
- [ ] Foreign keys have explicit ondelete behavior
- [ ] Sensitive data properly classified
- [ ] Migration generated and reviewed
- [ ] Tests updated
- [ ] Documentation updated
- [ ] [Your additional checks]

---

## References

**Internal documentation**:
- [Link to your data governance policy]
- [Link to your security requirements]
- [Link to your deployment process]

**External standards**:
- SQLAlchemy: https://docs.sqlalchemy.org/
- PEP 257: https://peps.python.org/pep-0257/
- [Your other references]

---

## Examples

### Example 1: [Scenario]

```python
# Your example
```

---

### Example 2: [Scenario]

```python
# Your example
```

---

## Contact

**Questions about conventions**: [Person/team]

**Request for exception**: [Person/team]

**Update this document**: [Person/team]

---

**Philosophy**: [Your team's philosophy on database documentation]
