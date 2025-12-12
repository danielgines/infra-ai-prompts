# SQLAlchemy Model Checklist

> **Purpose**: Quick reference checklist for writing secure, well-documented, and performant SQLAlchemy models.

---

## Before Writing

- [ ] **Database backend determined** - PostgreSQL, MySQL, or SQLite
- [ ] **SQLAlchemy version confirmed** - 2.0+, 1.4, or legacy
- [ ] **Naming convention agreed** - Table names (plural), column names (snake_case)
- [ ] **Documentation standard chosen** - pgModeler-compatible comments required

---

## Model Structure

### Basic Structure
- [ ] **Declarative base imported** - `from app.db.base import Base`
- [ ] **__tablename__ defined** - Plural snake_case (e.g., `"users"`)
- [ ] **Primary key defined** - `id: Mapped[int] = mapped_column(primary_key=True)`
- [ ] **Type annotations used** - All columns use `Mapped[Type]`
- [ ] **Class docstring present** - Comprehensive documentation with sections

### Class Docstring
- [ ] **Purpose statement** - One-line summary of model
- [ ] **Detailed description** - Business logic and use cases
- [ ] **Relationships section** - Lists all relationships with cardinality (1:N, N:M)
- [ ] **Indexes section** - Documents all indexes and their purpose
- [ ] **Constraints section** - Explains business rules and validations
- [ ] **Database info** - PostgreSQL version, schema, table name

---

## Column Definitions

### Basic Requirements
- [ ] **All columns have comment=** - pgModeler requirement
- [ ] **Comments follow format** - "{Category}: {Description}"
- [ ] **Nullable specified explicitly** - `nullable=False` or `nullable=True`
- [ ] **Appropriate types used** - String(n), Integer, Boolean, DateTime, etc.
- [ ] **Default values set** - `default=` or `server_default=` where appropriate

### Common Column Types
- [ ] **Primary keys** - `mapped_column(BigInteger, primary_key=True, comment="...")`
- [ ] **Foreign keys** - `mapped_column(ForeignKey("table.id"), index=True, comment="...")`
- [ ] **Unique columns** - `unique=True, index=True`
- [ ] **Timestamps** - `server_default=func.now()` for created_at
- [ ] **Enums** - Use Python Enum with `Enum(PyEnum)` type

### Security-Sensitive Columns
- [ ] **Passwords** - Never plaintext; use hybrid_property with hashing
- [ ] **PII data** - Encrypted at rest (SSN, credit cards)
- [ ] **API keys/tokens** - Hashed or encrypted
- [ ] **Sensitive data documented** - Comment explains sensitivity

---

## Relationships

### Relationship Definition
- [ ] **relationship() used** - Not just ForeignKey
- [ ] **back_populates defined** - Bidirectional relationships have matching back_populates
- [ ] **cascade behavior set** - Explicit cascade for one-to-many ownership
- [ ] **lazy loading specified** - `lazy="select"`, `"selectinload"`, `"joined"`, or `"dynamic"`
- [ ] **doc= parameter present** - Relationship documented with doc string

### Relationship Types
- [ ] **One-to-many** - `Mapped[List["RelatedClass"]]` with `cascade="all, delete-orphan"`
- [ ] **Many-to-one** - `Mapped["ParentClass"]` without cascade
- [ ] **Many-to-many** - Association table with `secondary=` parameter
- [ ] **One-to-one** - `uselist=False` on both sides

### Foreign Key Consistency
- [ ] **ForeignKey references table** - Not class name (e.g., `"users.id"` not `"User.id"`)
- [ ] **Foreign key column indexed** - `index=True` on ForeignKey column
- [ ] **Relationship target matches** - relationship("User") matches ForeignKey("users.id")
- [ ] **back_populates symmetric** - Both sides reference each other correctly

---

## Indexes and Performance

### Index Strategy
- [ ] **Primary keys indexed** - Automatic with `primary_key=True`
- [ ] **Foreign keys indexed** - Manual `index=True` required
- [ ] **Unique columns indexed** - `unique=True, index=True`
- [ ] **Query columns indexed** - Columns in WHERE clauses have indexes
- [ ] **Sort columns indexed** - `created_at`, `updated_at` have indexes

### Composite Indexes
- [ ] **Multi-column queries** - Use `Index("ix_name", "col1", "col2")`
- [ ] **Uniqueness constraints** - Use `UniqueConstraint("col1", "col2")`

### Loading Strategy
- [ ] **High-cardinality relationships** - Use `lazy="dynamic"` (large collections)
- [ ] **Frequently accessed** - Use `lazy="selectinload"` or `"joined"`
- [ ] **Many-to-many** - Use `lazy="selectin"` (avoid Cartesian explosion)

---

## Security

### SQL Injection Prevention
- [ ] **No raw SQL with f-strings** - Never use string formatting for queries
- [ ] **text() uses bound params** - `text("... WHERE id = :id")` with dict
- [ ] **Column names whitelisted** - Dynamic columns validated against whitelist
- [ ] **No eval() or exec()** - Never execute user input

### Sensitive Data
- [ ] **Passwords hashed** - bcrypt/argon2 with hybrid_property
- [ ] **PII encrypted** - Sensitive data encrypted at rest
- [ ] **No secrets in comments** - Comments don't expose sensitive logic
- [ ] **Authorization model** - Role-based access control defined

---

## Documentation

### Column Comments
- [ ] **All columns commented** - Every `mapped_column()` has `comment=`
- [ ] **Category prefix used** - "Primary key:", "Foreign key:", "Authentication:", etc.
- [ ] **Constraints explained** - Format, length, allowed values documented
- [ ] **Business rules noted** - Why column exists, how it's used

### Relationship Comments
- [ ] **All relationships have doc=** - Every `relationship()` has `doc=` parameter
- [ ] **Cardinality stated** - "One-to-many", "Many-to-many" specified
- [ ] **Cascade behavior documented** - Explains what happens on delete
- [ ] **Loading strategy noted** - Why lazy/eager loading chosen

---

## Constraints and Validation

### Database Constraints
- [ ] **NOT NULL enforced** - `nullable=False` where appropriate
- [ ] **UNIQUE constraints** - `unique=True` or `UniqueConstraint()`
- [ ] **CHECK constraints** - `CheckConstraint()` for value ranges
- [ ] **Foreign key constraints** - Proper ForeignKey definitions with `ondelete=`

### Application-Level Validation
- [ ] **Length validation** - String(n) with appropriate length
- [ ] **Enum validation** - Use Enum types for fixed value sets
- [ ] **Hybrid properties** - Complex validation in @hybrid_property
- [ ] **Custom validators** - @validates decorators for complex rules

---

## Migrations (Alembic)

### Migration Compatibility
- [ ] **Models in env.py** - All models imported in `alembic/env.py`
- [ ] **Column renames handled** - Use `op.alter_column()` not drop+add
- [ ] **Default values migration-safe** - Use `server_default=` not Python defaults
- [ ] **Nullable changes careful** - Populate data before making NOT NULL

### Migration Testing
- [ ] **Migration generates** - `alembic revision --autogenerate` works
- [ ] **Migration applies** - `alembic upgrade head` succeeds
- [ ] **Rollback works** - `alembic downgrade -1` succeeds
- [ ] **No data loss** - Test with sample data in test database

---

## Code Quality

### Naming Conventions
- [ ] **Table names plural** - `__tablename__ = "users"` not "user"
- [ ] **Column names snake_case** - `created_at` not `createdAt`
- [ ] **Relationship names descriptive** - `author` not `user`, `posts` not `items`
- [ ] **Model class names singular** - `User` not `Users`

### Type Annotations (SQLAlchemy 2.0+)
- [ ] **Mapped[Type] used** - All columns typed
- [ ] **Optional for nullable** - `Mapped[Optional[str]]` for nullable columns
- [ ] **List for collections** - `Mapped[List["RelatedClass"]]` for one-to-many

### Code Organization
- [ ] **One model per file** - Or logical grouping (e.g., auth models together)
- [ ] **Base model for common fields** - created_at, updated_at in base class
- [ ] **Mixins for shared logic** - AuditMixin, TimestampMixin, etc.
- [ ] **Imports organized** - stdlib → third-party → local

---

## Testing

### Unit Tests
- [ ] **Model instantiation** - Test creating instances
- [ ] **Relationship access** - Test lazy/eager loading
- [ ] **Cascade behavior** - Test delete cascades
- [ ] **Validation** - Test constraint violations
- [ ] **Password hashing** - Test hybrid_property password setter

### Integration Tests
- [ ] **Database round-trip** - Insert, query, update, delete
- [ ] **Transaction rollback** - Test session.rollback()
- [ ] **Concurrent access** - Test with_for_update() locking
- [ ] **Migration testing** - Test up/down migrations

---

## Common Mistakes to Avoid

- [ ] **No hardcoded credentials in models**
- [ ] **No f-strings in raw SQL**
- [ ] **No missing back_populates on relationships**
- [ ] **No ForeignKey without index=True**
- [ ] **No lazy loading without eager loading option**
- [ ] **No plaintext passwords in columns**
- [ ] **No missing nullable= specification**
- [ ] **No `import *` statements**
- [ ] **No circular imports (use TYPE_CHECKING)**
- [ ] **No missing comments on columns**
- [ ] **No database-specific types (unless intentional)**
- [ ] **No accessing lazy relationships after session.close()**

---

## Quick Command Reference

### Essential Commands

```python
# Create model
class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)

# Query
session.query(User).filter(User.username == "alice").first()

# Insert
user = User(username="alice")
session.add(user)
session.commit()

# Update
user.email = "alice@example.com"
session.commit()

# Delete
session.delete(user)
session.commit()
```

### Relationship Loading

```python
# Eager load (prevent N+1)
from sqlalchemy.orm import selectinload
session.query(User).options(selectinload(User.posts)).all()

# Multiple relationships
from sqlalchemy.orm import selectinload, joinedload
session.query(User).options(
    selectinload(User.posts),
    joinedload(User.profile)
).all()
```

### Debugging

```python
# Enable SQL logging
engine = create_engine("postgresql://...", echo=True)

# Print query SQL
from sqlalchemy.dialects import postgresql
query = session.query(User)
print(query.statement.compile(dialect=postgresql.dialect()))
```

---

## Additional Resources

- [SQLAlchemy Model Documentation Standards](SQLAlchemy_Model_Documentation_Standards_Reference.md)
- [SQLAlchemy Security Standards](SQLAlchemy_Security_Standards_Reference.md)
- [Model Review Instructions](SQLAlchemy_Model_Review_Instructions.md)
- [Model Debugging Instructions](SQLAlchemy_Model_Debugging_Instructions.md)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)

---

**Last Updated**: 2025-12-11
