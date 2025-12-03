# Daniel Ginês SQLAlchemy Model Documentation Preferences

> **Context**: Conventions for PostgreSQL projects with Alembic migrations and pgModeler integration
> **Author**: Daniel Ginês
> **Last Updated**: 2025-01-29
> **Applies to**: SQLAlchemy 2.0+, PostgreSQL 14+, Alembic, pgModeler

---

## Documentation Style

**Selected**: Detailed documentation with comprehensive context

**Rationale**: Infrastructure and data-intensive projects require thorough documentation. Database models are long-lived contracts that outlive application code. Investment in documentation pays off through reduced onboarding time, fewer bugs, and better data governance.

---

## Column Naming Conventions

### Primary Keys

**Convention**: Use `id` for all tables (never `{table}_id`)

**Type**: Integer with auto-increment (default) or UUID for distributed systems

**Examples**:
```python
# Standard integer primary key
id = Column(
    Integer,
    primary_key=True,
    comment='Primary key, auto-increment. Examples: 1, 42, 1337, 9999'
)

# UUID for distributed systems
id = Column(
    UUID(as_uuid=True),
    primary_key=True,
    default=uuid4,
    comment='Primary key, UUID v4. '
            'Examples: "550e8400-e29b-41d4-a716-446655440000"'
)
```

---

### Foreign Keys

**Format**: `{referenced_table_singular}_id`

**Always include**:
- Explicit `ondelete` behavior
- Comment referencing target table
- Index (automatic in PostgreSQL, explicit in code)

**Examples**:
```python
user_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='CASCADE'),
    nullable=False,
    index=True,
    comment='FK to users.id, CASCADE delete. Examples: 1, 42, 1337, 9999'
)

category_id = Column(
    Integer,
    ForeignKey('categories.id', ondelete='SET NULL'),
    nullable=True,
    index=True,
    comment='FK to categories.id, NULL if category deleted. '
            'Examples: 5 (Electronics), 12 (Clothing), NULL (uncategorized)'
)
```

---

### Timestamps

**Required columns for all tables**:
- `created_at`: Creation timestamp (UTC)
- `updated_at`: Last modification timestamp (UTC)

**Optional audit columns** (use for important tables):
- `created_by_id`: FK to users.id (who created)
- `updated_by_id`: FK to users.id (who last updated)

**Timezone**: Always UTC (avoid DST issues)

**Examples**:
```python
created_at = Column(
    DateTime,
    default=func.now(),
    nullable=False,
    index=True,  # Common in date-range queries
    comment='Record creation timestamp (UTC). '
            'Examples: "2024-01-15 14:30:00", "2024-03-10 09:15:22"'
)

updated_at = Column(
    DateTime,
    default=func.now(),
    onupdate=func.now(),
    nullable=False,
    comment='Last modification timestamp (UTC), auto-updated. '
            'Examples: "2024-01-15 14:30:00", "2024-03-12 16:45:33"'
)

# Optional audit trail
created_by_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='SET NULL'),
    nullable=True,
    comment='FK to users.id (who created record). '
            'Examples: 1 (admin), 42 (johndoe), NULL (system)'
)
```

---

### Boolean Columns

**Naming**: Use `is_`, `has_`, `can_` prefix for clarity

**Default**: Explicitly set default (never implicit)

**Examples**:
```python
is_active = Column(
    Boolean,
    default=True,
    nullable=False,
    comment='Account active status, false = suspended. '
            'Examples: true (849523 users), false (12847 users)'
)

has_verified_email = Column(
    Boolean,
    default=False,
    nullable=False,
    comment='Email verification status, true after confirmation. '
            'Examples: true (verified), false (pending)'
)

can_receive_notifications = Column(
    Boolean,
    default=True,
    nullable=False,
    comment='User notification preference. '
            'Examples: true (opted in), false (opted out)'
)
```

---

### Enum Columns

**Approach**: Native PostgreSQL ENUM type with SQLAlchemy Enum

**Always include**:
- Python Enum class definition
- Distribution in comment (if relevant)

**Examples**:
```python
from enum import Enum as PyEnum

class OrderStatus(PyEnum):
    """Order status lifecycle."""
    PENDING = 'pending'
    PROCESSING = 'processing'
    SHIPPED = 'shipped'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'

status = Column(
    Enum(OrderStatus, name='order_status'),
    nullable=False,
    default=OrderStatus.PENDING,
    comment='Order status enum, tracks order lifecycle. '
            'Examples: "pending" (2341 orders), "delivered" (45123), "cancelled" (892)'
)
```

---

## Comment Format

### Standard Format

**Template**:
```python
comment='[Description with format/type info]. Examples: [ex1], [ex2], [ex3]'
```

**Rules**:
1. Start with clear description (what it stores, purpose)
2. Include format/type clarification (UTC, lowercase, bcrypt, etc.)
3. Add 2-5 real examples from database
4. Explain NULL semantics for nullable columns
5. Reference related tables for foreign keys
6. Keep under 500 characters
7. Use double quotes for string examples

---

### Required Information

**Every column comment must include**:
- ✅ Description (what and why)
- ✅ Format details (UTC timezone, case, encoding)
- ✅ 2-5 real examples from database
- ✅ NULL semantics (if nullable)
- ✅ Business rules (if applicable)

**Optional but recommended**:
- Distribution stats for booleans/enums (if relevant)
- Data source/origin
- Validation rules
- Migration notes (if changed recently)

---

### Data Classification

**Not used in inline comments** (too verbose)

**Instead**: Document sensitive data in class docstring Security section

```python
class User(Base):
    """...

    Security:
        - password_hash: Bcrypt with cost 12, never plaintext
        - email: PII, encrypt in backups
        - api_key: Hash with SHA-256, implement rotation
    """
```

---

## Relationship Conventions

### Cascade Rules

**My policies**:
```python
# Strong ownership (parent-child): delete children when parent deleted
orders = relationship('Order', cascade='all, delete-orphan')

# Weak reference: keep child when parent deleted (FK SET NULL)
category_id = Column(
    Integer,
    ForeignKey('categories.id', ondelete='SET NULL'),
    nullable=True
)

# Required reference: prevent deletion if children exist
user_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='RESTRICT'),
    nullable=False
)

# Cascade delete: delete child when parent deleted
user_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='CASCADE'),
    nullable=False
)
```

---

### Lazy Loading

**Default**: `lazy='select'` (explicit is better than implicit)

**Large collections**: `lazy='dynamic'` (>100 items, need filtering)

**Frequently accessed**: `lazy='joined'` (only if profiled)

**Examples**:
```python
# Standard relationship
orders = relationship(
    'Order',
    back_populates='customer',
    lazy='select'  # Explicit
)

# Large collection (user can have thousands of orders)
orders = relationship(
    'Order',
    back_populates='customer',
    lazy='dynamic'  # Returns query object
)

# Frequently accessed with parent (profile always loaded with user)
profile = relationship(
    'UserProfile',
    back_populates='user',
    uselist=False,
    lazy='joined'  # Load in same query
)
```

---

### Back Populates vs Backref

**Always use**: `back_populates` (explicit bidirectional)

**Never use**: `backref` (implicit is less clear)

**Rationale**: Explicit is better than implicit. Both sides of relationship should be visible in code.

```python
# User model
class User(Base):
    orders = relationship('Order', back_populates='customer')

# Order model
class Order(Base):
    customer_id = Column(Integer, ForeignKey('users.id'))
    customer = relationship('User', back_populates='orders')
```

---

## Index Strategy

### Required Indexes

**Always index**:
- ✅ Primary keys (automatic)
- ✅ Foreign keys (automatic in PostgreSQL, explicit in code)
- ✅ Unique constraints
- ✅ Columns in WHERE clauses (from query log analysis)
- ✅ Columns in ORDER BY (pagination queries)

**Example**:
```python
__table_args__ = (
    Index('ix_orders_user_date', 'user_id', 'created_at'),  # User's orders by date
    Index('ix_orders_status', 'status'),  # Filter by status
    {'comment': 'Customer orders with items and totals'}
)
```

---

### Composite Indexes

**Naming**: `ix_{table}_{col1}_{col2}`

**Column order**: Most selective first (or by query pattern)

**Document**: Include query pattern in class docstring

```python
class Order(Base):
    """...

    Indexes:
        - (user_id, created_at): Composite index for user order history
          Query: SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC
          Covers: user_id = ? AND created_at BETWEEN ? AND ?
          Performance: <20ms for 10K orders per user
    """

    __table_args__ = (
        Index('ix_orders_user_date', 'user_id', 'created_at'),
    )
```

---

### Partial Indexes

**When to use**: Filtered queries (e.g., active records only)

**PostgreSQL-specific**: Yes, document in class docstring

```python
class User(Base):
    """...

    Indexes:
        - email (partial, WHERE is_active=true): Index only active users
          Query: SELECT * FROM users WHERE email = ? AND is_active = true
          Size reduction: 70% smaller than full index
    """

    __table_args__ = (
        Index(
            'ix_users_active_email',
            'email',
            postgresql_where=(is_active == True)
        ),
    )
```

---

## Database-Specific Features (PostgreSQL)

### JSONB Columns

**Use for**: Flexible metadata, settings, non-relational data

**Always include**: Examples of actual JSON structure

```python
metadata = Column(
    JSONB,
    nullable=True,
    comment='Additional metadata, flexible schema. '
            'Examples: {"utm_source":"google","campaign":"spring_sale"}, '
            '{"referrer":"facebook","device":"mobile"}, {}'
)

settings = Column(
    JSONB,
    default=lambda: {},
    nullable=False,
    comment='User preferences, key-value pairs. '
            'Examples: {"theme":"dark","language":"en","notifications":true}, '
            '{"theme":"light","timezone":"America/New_York"}'
)
```

---

### Array Columns

**Use for**: Lists of values (tags, categories, permissions)

```python
from sqlalchemy.dialects.postgresql import ARRAY

tags = Column(
    ARRAY(String),
    default=list,
    nullable=False,
    comment='Product tags for search and filtering. '
            'Examples: ["electronics","gadgets","wireless"], ["clothing","mens"], []'
)
```

---

### Full-Text Search

**Use for**: Search-optimized text columns

```python
from sqlalchemy.dialects.postgresql import TSVECTOR

search_vector = Column(
    TSVECTOR,
    Computed("to_tsvector('english', title || ' ' || description)"),
    comment='Full-text search index (auto-generated from title + description)'
)

__table_args__ = (
    Index('ix_products_search', 'search_vector', postgresql_using='gin'),
)
```

---

## Migration Standards

### Alembic Migration Docstring

**Required format** (see full example in `daniel_gines_preferences.md` in python/):

```python
"""Add user phone verification system

Revision ID: ae3f891b2c45
Revises: 1d2e3f4a5b6c
Create Date: 2024-01-15 10:23:45.123456

Changes:
    users table:
        - Add phone_number column (VARCHAR(20), nullable)
        - Add phone_verified column (BOOLEAN, default False)

    New tables:
        - phone_verifications: OTP codes and attempts

Deployment Steps:
    1. Run during maintenance window (Sundays 2-4 AM UTC)
    2. Verify: SELECT COUNT(*) FROM phone_verifications
    3. Enable feature flag

Rollback:
    - Safe to rollback (phone_number nullable)
    - Command: alembic downgrade -1

Testing:
    - Tested on staging with 10K user sample
    - Performance: <5ms per user lookup

Author: Daniel Ginês
Jira: PROJ-1234
"""
```

---

### Deployment Windows

**Preferred time**: Sundays 2-4 AM UTC (low traffic)

**Restrictions**:
- Large migrations (>1M rows): Coordinate with ops team, possible read-replica lag
- Breaking changes: Require 2-phase deployment (add new → migrate data → remove old)
- Data migrations: Test on staging with production-size dataset

---

## Security Requirements

### Password Storage

**Always**: bcrypt with cost factor 12+ (never plaintext, never MD5/SHA)

```python
password_hash = Column(
    String(255),
    nullable=False,
    comment='Bcrypt password hash (cost factor 12), never plaintext. '
            'Example: "$2b$12$KIXn8wP.H8K5V6vN8L7Z2.abc123..." (truncated)'
)
```

---

### API Keys / Tokens

**Always**: Store hashed (SHA-256 minimum) with expiration

```python
api_key_hash = Column(
    String(64),  # SHA-256 = 64 hex chars
    unique=True,
    nullable=False,
    comment='SHA-256 hash of API key (original key shown once at creation). '
            'Example: "5e884898da28047151d0e56f8dc62927..."'
)

api_key_expires_at = Column(
    DateTime,
    nullable=True,
    comment='API key expiration (UTC), NULL = never expires. '
            'Examples: "2025-12-31 23:59:59", NULL'
)
```

---

### PII and Sensitive Data

**Document in class docstring** (Security section), not inline comments

**Anonymize examples**: Never show real user data in comments

```python
class User(Base):
    """...

    Security:
        - email: PII, store lowercase, encrypt in backups
        - password_hash: bcrypt cost 12, never log
        - phone_number: PII, optional, encrypt in backups
        - api_key: Hash with SHA-256, rotate every 90 days
    """
```

---

## Soft Delete Pattern

**Convention**: Use `deleted_at` column (NULL = active, timestamp = deleted)

**Never**: Hard delete user-generated content (compliance, audit trail)

**Hard delete**: Only for test data, spam, or after retention period (90 days)

```python
deleted_at = Column(
    DateTime,
    nullable=True,
    index=True,  # Common filter: WHERE deleted_at IS NULL
    comment='Soft delete timestamp (UTC), NULL = active record. '
            'Examples: NULL (active), "2024-02-20 10:30:00" (deleted)'
)

# Optional: track who deleted
deleted_by_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='SET NULL'),
    nullable=True,
    comment='FK to users.id (who deleted record). '
            'Examples: 1 (admin), 42 (moderator), NULL (automated)'
)
```

**Query pattern**:
```python
# Active records only
active_users = session.query(User).filter(User.deleted_at.is_(None))

# Include deleted (admin view)
all_users = session.query(User)
```

---

## Data Examples Protocol

### Source of Examples

**Preferred**: Query staging or development database (never production)

**Anonymize**: Always anonymize PII before including in comments

**Format**: Use realistic but generic examples

```python
# ✅ GOOD: Anonymized examples
email = Column(
    String(255),
    comment='Examples: "user1@example.com", "admin@company.test", "jane@domain.org"'
)

# ❌ BAD: Real user data
email = Column(
    String(255),
    comment='Examples: "john.smith@gmail.com", "sarah@realdomain.com"'  # DON'T
)
```

---

### Anonymization Strategies

**Email**: Use example.com, company.test, domain.org

**Names**: John Doe, Jane Smith, Admin User

**Phone**: (555) xxx-xxxx format or international generic

**Hashes**: Show pattern only, truncate with "..."

**IDs**: Use generic numbers (1, 42, 1337, 9999)

**JSON**: Remove sensitive keys (api_key, token, secret) before showing

---

## pgModeler Integration

### Purpose

pgModeler reads PostgreSQL comments to generate HTML data dictionary for documentation and team onboarding.

---

### Table Comments

**Always include** in `__table_args__`:

```python
__table_args__ = (
    Index('ix_users_email', 'email'),
    {'comment': 'User accounts for authentication and profile management. '
                'Stores credentials, profile data, and account status.'}
)
```

---

### Export Process

1. AI updates models with inline `comment=` parameters
2. Generate migration: `alembic revision --autogenerate -m "Update model comments"`
3. Apply migration: `alembic upgrade head`
4. Comments stored in PostgreSQL system catalogs
5. pgModeler: Database → Export → HTML Data Dictionary
6. HTML contains all comments from `comment=` fields

---

### Validation

```sql
-- Check table comment
SELECT obj_description('users'::regclass, 'pg_class');

-- Check all column comments
SELECT
    column_name,
    col_description('users'::regclass, ordinal_position) as comment
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;
```

---

## Performance Guidelines

### Document When

- Query time > 100ms (needs optimization)
- Result set > 10K rows (pagination required)
- Table > 1M rows (partitioning considered)
- Growth rate > 100K rows/day (monitoring needed)

**Format in class docstring**:
```python
class Order(Base):
    """...

    Performance Notes:
        - Query performance: <50ms for user order history (indexed)
        - Write performance: ~500 inserts/second sustained
        - Hot partition: Orders from last 30 days (80% of queries)
        - Archive strategy: Move orders >1 year to orders_archive table
    """
```

---

## Quality Checklist

Before committing model changes:

- [ ] All columns have comments with 2-5 real examples
- [ ] Class docstring includes: relationships, indexes, constraints, migration history
- [ ] Foreign keys have explicit `ondelete` behavior
- [ ] Timestamps use UTC timezone
- [ ] Sensitive data documented in Security section
- [ ] Soft delete uses `deleted_at` (if applicable)
- [ ] Migration generated and tested
- [ ] pgModeler export verified (if applicable)

---

**Philosophy**: Database models are the most stable part of the stack. Applications change, frameworks change, but data structure persists. Invest in documentation early to avoid technical debt later.
