# SQLAlchemy Model Documentation Standards Reference

> **Purpose**: Shared reference for SQLAlchemy model documentation standards. Use this as foundation for all database model documentation prompts.

---

## Overview

SQLAlchemy models require comprehensive documentation for:
- **Database schema understanding**: Table purpose, relationships, constraints
- **pgModeler integration**: Comments exported to HTML data dictionary
- **Team collaboration**: Clear expectations for data structure
- **Real-world examples**: Actual data patterns from production database

---

## Documentation Layers

### 1. Class Docstrings (Model Overview)

**Purpose**: High-level table documentation with business context

**Required sections**:
- Table purpose and business context
- Relationships (with cardinality and backref)
- Indexes (with query patterns they optimize)
- Constraints (with business rules)
- Triggers (if any)
- Migration history (major schema changes)
- Data lifecycle notes
- Example usage

**Template**:
```python
class User(Base):
    """User account model for authentication and profile management.

    Stores user credentials, profile information, and account status.
    Central table for authentication system with relationships to orders,
    profiles, and role-based access control.

    Relationships:
        - orders: One-to-many with Order (backref='customer')
          Cascade: delete-orphan (orders deleted when user deleted)
        - profile: One-to-one with UserProfile (backref='user')
          Optional: user can exist without profile
        - roles: Many-to-many with Role through user_roles table
          Junction: user_roles(user_id, role_id)

    Indexes:
        - email: Unique B-tree index for login queries
          Query: SELECT * FROM users WHERE email = ?
        - (email, is_active): Composite index for admin filtering
          Query: SELECT * FROM users WHERE email = ? AND is_active = true
        - created_at: B-tree index for date-range reports
          Query: SELECT * FROM users WHERE created_at BETWEEN ? AND ?

    Constraints:
        - email: UNIQUE NOT NULL (login identifier)
        - username: UNIQUE NOT NULL, 3-50 chars
        - password_hash: NOT NULL, bcrypt format (never plaintext)
        - is_active: NOT NULL DEFAULT true

    Triggers:
        - updated_at: Automatically set to CURRENT_TIMESTAMP on UPDATE

    Migration History:
        - 2024-01-15 (rev ae3f891): Added phone_number, phone_verified
        - 2024-02-01 (rev b4c2d3e): Added soft delete (deleted_at)
        - 2024-03-10 (rev c5d4e6f): Added last_login_at for security audit

    Data Lifecycle:
        - Creation: Via registration endpoint or admin panel
        - Updates: Profile changes, password resets, admin modifications
        - Soft delete: deleted_at set to timestamp, is_active = false
        - Hard delete: After 90 days (GDPR compliance), via scheduled job
        - Archive: Anonymized after 7 years (legal requirement)

    Data Volume (as of 2024-03-15):
        - Total rows: ~1.2M users
        - Active users: ~850K (is_active=true, deleted_at IS NULL)
        - Growth rate: ~10K new users/month
        - Largest row size: ~2KB (with JSON metadata field)

    Performance Notes:
        - Query performance: <10ms for email lookup (indexed)
        - Write performance: ~100 inserts/second sustained
        - Hot partition: Users created in last 30 days (80% of queries)

    Example:
        >>> # Create new user
        >>> user = User(
        ...     email='john.doe@example.com',
        ...     username='johndoe',
        ...     password_hash=hash_password('secure_password'),
        ...     is_active=True
        ... )
        >>> session.add(user)
        >>> session.commit()
        >>>
        >>> # Query with relationships
        >>> user = session.query(User).filter_by(email='john.doe@example.com').first()
        >>> print(f"Orders: {len(user.orders)}")
        >>> print(f"Roles: {[role.name for role in user.roles]}")

    Security:
        - Passwords: bcrypt with cost factor 12
        - Email: Stored lowercase for case-insensitive comparison
        - Sessions: Tracked in separate sessions table (not here)
        - API keys: Stored in separate api_keys table with FK to user_id

    Author: Daniel Ginês
    Last Updated: 2024-03-15
    """
    __tablename__ = 'users'
    __table_args__ = (
        Index('ix_users_email_active', 'email', 'is_active'),
        {'comment': 'User accounts for authentication and profile management'}
    )

    # Columns with inline comments (pgModeler exports these)
    id = Column(
        Integer,
        primary_key=True,
        comment='Primary key, auto-increment. Example: 1, 2, 3, ..., 1234567'
    )
    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
        comment='User email address (login identifier), stored lowercase. '
                'Examples: "john.doe@example.com", "jane.smith@company.org"'
    )
    username = Column(
        String(50),
        unique=True,
        nullable=False,
        comment='Display name, unique across system. '
                'Examples: "johndoe", "jane_smith", "tech_admin"'
    )
    password_hash = Column(
        String(255),
        nullable=False,
        comment='Bcrypt password hash (cost factor 12), never plaintext. '
                'Example: "$2b$12$KIXn8wP.H8K5V6vN8L7Z2.abc123def456..."'
    )
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment='Account active status, false = suspended/deleted. '
                'Examples: true (active), false (suspended)'
    )
    created_at = Column(
        DateTime,
        default=func.now(),
        nullable=False,
        comment='Account creation timestamp (UTC). '
                'Examples: "2024-01-15 14:30:00", "2024-03-10 09:15:22"'
    )
    updated_at = Column(
        DateTime,
        default=func.now(),
        onupdate=func.now(),
        comment='Last modification timestamp (UTC), auto-updated. '
                'Examples: "2024-01-15 14:30:00", "2024-03-12 16:45:33"'
    )
    deleted_at = Column(
        DateTime,
        nullable=True,
        comment='Soft delete timestamp (UTC), NULL = active user. '
                'Examples: NULL (active), "2024-02-20 10:30:00" (deleted)'
    )
```

---

## Column Comment Standards

### Comment Structure

**Format**: `<Description>. Examples: <real_data_1>, <real_data_2>, ...`

**Guidelines**:
- Start with clear, concise description
- Include data type/format clarification
- Add 2-5 real examples from database
- Explain NULL values or special cases
- Reference related columns if applicable

### Real Data Examples Protocol

**IMPORTANT**: Always query actual database data for examples

**Query pattern**:
```sql
-- Get diverse examples (avoid duplicates)
SELECT DISTINCT column_name
FROM table_name
WHERE column_name IS NOT NULL
  AND column_name != ''
ORDER BY RANDOM()
LIMIT 5;

-- For numeric ranges
SELECT MIN(column_name) as min_val,
       MAX(column_name) as max_val,
       AVG(column_name) as avg_val,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY column_name) as median
FROM table_name;

-- For enum-like columns
SELECT column_name, COUNT(*) as frequency
FROM table_name
GROUP BY column_name
ORDER BY frequency DESC
LIMIT 10;
```

### Comment Examples by Data Type

#### String Columns

```python
email = Column(
    String(255),
    comment='User email address, validated format, lowercase. '
            'Examples: "john.doe@gmail.com", "sarah.chen@company.com", '
            '"admin@example.org"'
)

status = Column(
    String(20),
    comment='Order status, enum-like values. '
            'Examples: "pending", "processing", "shipped", "delivered", "cancelled"'
)

description = Column(
    Text,
    comment='Product description, Markdown format, 50-5000 chars. '
            'Examples: "High-quality **wireless** headphones...", '
            '"Professional camera kit with..."'
)
```

#### Numeric Columns

```python
price = Column(
    Numeric(10, 2),
    comment='Product price in USD, 2 decimal places. '
            'Examples: 19.99, 149.50, 2499.00, 0.99'
)

age = Column(
    Integer,
    comment='User age in years, range 18-120. '
            'Examples: 25, 34, 42, 67, 19'
)

discount_percent = Column(
    Float,
    comment='Discount percentage, range 0.0-100.0. '
            'Examples: 0.0 (no discount), 10.5, 25.0, 50.0'
)
```

#### Boolean Columns

```python
is_active = Column(
    Boolean,
    comment='Account active status. '
            'Examples: true (849523 users), false (12847 users)'
)

email_verified = Column(
    Boolean,
    comment='Email verification status, true after confirmation link clicked. '
            'Examples: true (verified), false (pending verification)'
)
```

#### DateTime Columns

```python
created_at = Column(
    DateTime,
    comment='Record creation timestamp (UTC timezone). '
            'Examples: "2024-01-15 14:30:00", "2024-03-10 09:15:22", '
            '"2023-12-01 00:00:00"'
)

expires_at = Column(
    DateTime,
    nullable=True,
    comment='Expiration timestamp (UTC), NULL = never expires. '
            'Examples: "2024-12-31 23:59:59" (expires), NULL (permanent)'
)
```

#### JSON/JSONB Columns

```python
metadata = Column(
    JSONB,
    comment='Additional metadata, flexible schema. '
            'Examples: {"utm_source": "google", "campaign": "spring_sale"}, '
            '{"referrer": "facebook", "device": "mobile"}, '
            '{}'
)

settings = Column(
    JSON,
    comment='User preferences, key-value pairs. '
            'Examples: {"theme": "dark", "language": "en", "notifications": true}, '
            '{"theme": "light", "timezone": "America/New_York"}'
)
```

#### Foreign Key Columns

```python
user_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='CASCADE'),
    comment='Reference to users.id, CASCADE delete. '
            'Examples: 1, 42, 1337, 999999'
)

category_id = Column(
    Integer,
    ForeignKey('categories.id', ondelete='SET NULL'),
    nullable=True,
    comment='Reference to categories.id, NULL if category deleted. '
            'Examples: 5 (Electronics), 12 (Clothing), NULL (uncategorized)'
)
```

#### Enum Columns

```python
from enum import Enum as PyEnum

class UserRole(PyEnum):
    ADMIN = 'admin'
    MODERATOR = 'moderator'
    USER = 'user'
    GUEST = 'guest'

role = Column(
    Enum(UserRole),
    comment='User role, controls permissions. '
            'Examples: "admin" (12 users), "moderator" (45 users), '
            '"user" (849234 users), "guest" (1024 users)'
)
```

---

## Relationship Documentation

### One-to-Many

```python
class User(Base):
    """..."""
    orders = relationship(
        'Order',
        back_populates='customer',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    # Document in class docstring:
    # orders: One-to-many with Order
    #   - backref: customer
    #   - cascade: delete-orphan (orders deleted when user deleted)
    #   - lazy: dynamic (query object, not list)
    #   - typical count: 0-50 orders per user, avg 3.2

class Order(Base):
    """..."""
    customer_id = Column(
        Integer,
        ForeignKey('users.id', ondelete='CASCADE'),
        comment='FK to users.id. Examples: 1, 42, 1337'
    )
    customer = relationship('User', back_populates='orders')
```

### One-to-One

```python
class User(Base):
    """..."""
    profile = relationship(
        'UserProfile',
        back_populates='user',
        uselist=False,
        cascade='all, delete-orphan'
    )
    # Document:
    # profile: One-to-one with UserProfile
    #   - optional: user can exist without profile
    #   - cascade: delete-orphan

class UserProfile(Base):
    """..."""
    user_id = Column(
        Integer,
        ForeignKey('users.id', ondelete='CASCADE'),
        unique=True,
        comment='FK to users.id (one-to-one). Examples: 1, 42, 1337'
    )
    user = relationship('User', back_populates='profile')
```

### Many-to-Many

```python
# Association table
user_roles = Table(
    'user_roles',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id', ondelete='CASCADE'),
           comment='FK to users.id. Examples: 1, 42, 1337'),
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'),
           comment='FK to roles.id. Examples: 1, 2, 3'),
    Column('assigned_at', DateTime, default=func.now(),
           comment='Role assignment timestamp. Examples: "2024-01-15 14:30:00"'),
    comment='Many-to-many junction table for users and roles'
)

class User(Base):
    """..."""
    roles = relationship(
        'Role',
        secondary=user_roles,
        back_populates='users'
    )
    # Document:
    # roles: Many-to-many with Role through user_roles
    #   - typical: 1-3 roles per user
    #   - junction table: user_roles(user_id, role_id, assigned_at)

class Role(Base):
    """..."""
    users = relationship(
        'User',
        secondary=user_roles,
        back_populates='roles'
    )
```

---

## Index Documentation

### Simple Index

```python
__table_args__ = (
    Index('ix_users_email', 'email', unique=True),
    # Document in class docstring:
    # email: Unique B-tree index for login lookups
    #   Query pattern: SELECT * FROM users WHERE email = ?
    #   Performance: <10ms average, 99th percentile <50ms
)
```

### Composite Index

```python
__table_args__ = (
    Index('ix_orders_user_date', 'user_id', 'created_at'),
    # Document in class docstring:
    # (user_id, created_at): Composite index for user order history
    #   Query pattern: SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC
    #   Covers: user_id = ? AND created_at BETWEEN ? AND ?
    #   Performance: <20ms for 10K orders per user
)
```

### Partial Index (PostgreSQL)

```python
__table_args__ = (
    Index(
        'ix_users_active_email',
        'email',
        postgresql_where=(is_active == True)
    ),
    # Document in class docstring:
    # email (partial, WHERE is_active=true): Index only active users
    #   Query pattern: SELECT * FROM users WHERE email = ? AND is_active = true
    #   Size reduction: 70% smaller than full index
)
```

---

## pgModeler Integration

### Table Comments

```python
__table_args__ = (
    {'comment': 'User accounts for authentication and profile management. '
                'Stores credentials, profile data, and account status. '
                'Central table for RBAC system.'}
)
```

### Export to HTML Dictionary

pgModeler reads PostgreSQL table and column comments to generate HTML data dictionary.

**Process**:
1. AI updates model with inline `comment=` parameters
2. Generate migration: `alembic revision --autogenerate -m "Update model comments"`
3. Apply migration: `alembic upgrade head`
4. Comments stored in PostgreSQL system catalogs
5. pgModeler export: Database → Export → HTML Data Dictionary
6. HTML contains descriptions from `comment=` fields

**Validation query**:
```sql
-- Check table comment
SELECT obj_description('users'::regclass, 'pg_class');

-- Check column comments
SELECT
    column_name,
    col_description('users'::regclass, ordinal_position) as comment
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;
```

---

## Best Practices

### ✅ DO

- Include real examples from database in comments
- Document business rules and constraints
- Explain NULL value semantics
- Reference related tables in FK comments
- Include data distribution statistics (if relevant)
- Document index query patterns
- Explain cascade behaviors
- Note performance characteristics for large tables
- Include migration history for schema changes
- Add security notes for sensitive columns

### ❌ DON'T

- Use generic comments like "user ID" for `user_id`
- Include example data without querying actual database
- Document obvious information (e.g., "primary key" for `id`)
- Use technical jargon without explanation
- Forget to update comments after schema changes
- Include sensitive data in examples (passwords, API keys, etc.)
- Document implementation details that may change
- Use inconsistent comment formats across models

---

## Query Examples for Data Collection

### Get Sample Values

```python
# In AI prompt, run these queries to get real examples
from sqlalchemy import select, func

# String column examples
query = select(User.email).distinct().limit(5)
examples = session.execute(query).scalars().all()
# Result: ['john@example.com', 'jane@company.org', ...]

# Numeric statistics
query = select(
    func.min(Order.total_amount),
    func.max(Order.total_amount),
    func.avg(Order.total_amount)
)
stats = session.execute(query).first()
# Result: (9.99, 4999.00, 156.73)

# Enum value distribution
query = select(
    Order.status,
    func.count(Order.id).label('count')
).group_by(Order.status).order_by(func.count(Order.id).desc())
distribution = session.execute(query).all()
# Result: [('delivered', 45123), ('shipped', 12456), ...]
```

---

## Security Considerations

### Sensitive Data

```python
# ❌ BAD: Exposing real sensitive data
password_hash = Column(
    String(255),
    comment='Password hash. Example: "$2b$12$real_hash_from_db"'  # DON'T
)

# ✅ GOOD: Generic but accurate example
password_hash = Column(
    String(255),
    comment='Bcrypt password hash (cost 12). '
            'Example: "$2b$12$KIXn8wP.H8K5V6vN8L7Z2.abc123def456..." (truncated)'
)
```

### PII (Personally Identifiable Information)

```python
# ❌ BAD: Real user email
email = Column(
    String(255),
    comment='Examples: "john.smith@gmail.com", "real.person@company.com"'  # DON'T
)

# ✅ GOOD: Anonymized but realistic
email = Column(
    String(255),
    comment='User email, lowercase. '
            'Examples: "user1@example.com", "admin@company.test", "jane@domain.org"'
)
```

---

## Documentation Checklist

- [ ] Class docstring with all required sections
- [ ] Relationships documented with cardinality and cascade
- [ ] Indexes documented with query patterns
- [ ] Constraints documented with business rules
- [ ] All columns have inline comments
- [ ] Comments include 2-5 real examples from database
- [ ] Sensitive data anonymized in examples
- [ ] NULL value semantics explained
- [ ] Foreign keys reference target table
- [ ] Table comment in `__table_args__`
- [ ] Migration history noted (if applicable)
- [ ] Performance notes for large tables
- [ ] Example usage in class docstring

---

## Alembic Migrations

### Baseline Migrations for Existing Databases

When adopting Alembic on a project with an existing database schema:

**Purpose**: Create a baseline migration that marks the current database state as the initial version, allowing future schema changes to be tracked without attempting to recreate existing tables.

**When to use**:
- Legacy database transitioning to migration-based workflow
- Database created via manual SQL scripts or `Base.metadata.create_all()`
- Mid-project adoption of Alembic
- Multiple environments need version control synchronization

**Template**:
```python
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
        - users: User accounts and authentication
        - orders: Customer orders and transactions
        - products: Product catalog with metadata

    Relationships:
        - users ← orders (One-to-Many, CASCADE)
        - categories ← products (One-to-Many, SET NULL)

    Data Volume (as of 2024-12-03):
        - users: ~1.2M records
        - orders: ~5.2M records

Purpose:
    Register current schema without DDL execution, enabling incremental
    migrations from this point forward.

How to Apply:
    $ alembic stamp 001_baseline  # For existing databases
    $ alembic upgrade head         # For empty databases
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '001_baseline'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

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

**Best Practices**:
- ✅ Document all tables, relationships, and constraints in baseline docstring
- ✅ Use `alembic stamp` on existing databases (not `upgrade`)
- ✅ Include data volume statistics for context
- ✅ Test in staging before applying to production
- ✅ Backup database before any migration operation
- ❌ Don't include DDL commands in baseline upgrade/downgrade
- ❌ Don't modify baseline after applying to production
- ❌ Don't run `upgrade` on databases with existing tables

**Reference**: See `SQLAlchemy_Baseline_Migration_Instructions.md` for detailed guide on creating and applying baseline migrations.

**Template**: See `examples/alembic_baseline_migration_template.py` for complete baseline template.

---

**Philosophy**: Database models are contracts. Documentation should enable any developer to understand data structure, business rules, and usage patterns without reading application code or asking questions.
