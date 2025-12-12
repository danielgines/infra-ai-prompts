# SQLAlchemy Model Examples

> **Purpose**: Practical, working examples of SQLAlchemy models demonstrating best practices for documentation, relationships, and security.

---

## Available Examples

### 1. before_after_model_documentation.md

**Purpose**: Demonstrates transformation from poorly documented models to fully documented, pgModeler-ready models.

**Features**:
- Before/after comparison
- Progressive improvement across 4 stages
- Real-world user/post/comment relationship
- pgModeler-compatible comments

**Usage**:
```python
# See file for complete examples
# Shows evolution from minimal to comprehensive documentation
```

**What it demonstrates**:
- Column comment standards
- Relationship documentation
- Class-level docstrings
- Index documentation

---

### 2. basic_model.py

**Purpose**: Simple, single-table model demonstrating fundamental patterns.

**Features**:
- Basic column types (String, Integer, Boolean, DateTime)
- Primary key definition
- Unique constraints
- Timestamps with server defaults
- Comprehensive comments
- Hybrid property for password hashing

**Usage**:
```bash
# Run example
python examples/basic_model.py

# Expected output:
# Creating User model...
# ✓ User created: alice (alice@example.com)
# ✓ Password verification works
# ✓ Timestamps set automatically
```

**What it demonstrates**:
- `Mapped[Type]` syntax (SQLAlchemy 2.0+)
- Primary key definition
- Unique constraints
- Password hashing with hybrid_property
- Timestamp columns with `server_default=func.now()`
- pgModeler-compatible comments

---

### 3. advanced_model_relationships.py

**Purpose**: Multi-table models with complex relationships demonstrating real-world patterns.

**Features**:
- One-to-many relationships (User → Posts)
- Many-to-one relationships (Post → User)
- Many-to-many relationships (Post ↔ Tags via association table)
- Cascade behaviors
- Bidirectional back_populates
- Eager loading examples
- Foreign key indexes

**Usage**:
```bash
# Run example
python examples/advanced_model_relationships.py

# Expected output:
# Creating models with relationships...
# ✓ User created with profile
# ✓ Posts linked to user
# ✓ Tags associated with posts
# ✓ Comments thread properly
# ✓ Relationships load correctly
# ✓ Cascade delete works
```

**What it demonstrates**:
- One-to-many: `Mapped[List["Post"]]` with `cascade="all, delete-orphan"`
- Many-to-one: `Mapped["User"]` without cascade
- Many-to-many: Association table with `secondary=`
- back_populates symmetry
- ForeignKey with index=True
- Relationship doc= parameters
- Lazy loading strategies (selectinload, joined, dynamic)

---

## Running the Examples

### Prerequisites

1. **Install SQLAlchemy 2.0+**:
```bash
pip install sqlalchemy>=2.0.0

# PostgreSQL
pip install psycopg2-binary

# MySQL
pip install pymysql

# SQLite (included with Python)
```

2. **Install password hashing library**:
```bash
pip install passlib bcrypt
```

3. **Set Up Database** (optional, examples use SQLite):
```bash
# Examples default to in-memory SQLite
# For PostgreSQL testing:
export DATABASE_URL="postgresql://user:password@localhost/testdb"
```

---

## Security Notes for Examples

### Important Reminders

1. **Passwords in Examples**:
   - Examples use bcrypt hashing
   - Never store plaintext passwords
   - In production, use environment-based configuration

2. **Database URLs**:
   - Examples use SQLite in-memory (safe for testing)
   - Production should use environment variables:
     ```python
     import os
     DATABASE_URL = os.environ["DATABASE_URL"]
     ```

3. **Never commit credentials**:
   - Add `.env` to `.gitignore`
   - Use python-dotenv for local development
   - Use secrets management in production

4. **SQL Injection Prevention**:
   - All examples use ORM queries (safe)
   - Never use f-strings for SQL
   - See `SQLAlchemy_Security_Standards_Reference.md`

---

## Customization Guide

### Modifying Database Backend

```python
# SQLite (default in examples)
engine = create_engine("sqlite:///example.db")

# PostgreSQL
engine = create_engine("postgresql://user:pass@localhost/dbname")

# MySQL
engine = create_engine("mysql+pymysql://user:pass@localhost/dbname")
```

### Changing Password Hashing

```python
# Replace bcrypt with argon2
from passlib.hash import argon2

class User(Base):
    @password.setter
    def password(self, plaintext):
        self._password_hash = argon2.hash(plaintext)

    def verify_password(self, plaintext):
        return argon2.verify(plaintext, self._password_hash)
```

### Adding Validation

```python
from sqlalchemy.orm import validates

class User(Base):
    @validates('email')
    def validate_email(self, key, email):
        assert '@' in email, "Invalid email format"
        return email.lower()

    @validates('username')
    def validate_username(self, key, username):
        assert 3 <= len(username) <= 50, "Username must be 3-50 characters"
        assert username.isalnum(), "Username must be alphanumeric"
        return username
```

---

## Troubleshooting

### Problem: ImportError: cannot import name 'Mapped'

**Solution**: Upgrade to SQLAlchemy 2.0+
```bash
pip install --upgrade 'sqlalchemy>=2.0.0'
```

### Problem: TypeError: 'type' object is not subscriptable (Mapped[List[...]])

**Solution**: Add future annotations (Python 3.9+):
```python
from __future__ import annotations
from typing import List
```

Or use string references (Python 3.7+):
```python
posts: Mapped["List[Post]"] = relationship("Post")
```

### Problem: DetachedInstanceError when accessing relationships

**Solution**: Eager load relationships:
```python
from sqlalchemy.orm import selectinload
users = session.query(User).options(selectinload(User.posts)).all()
```

### Problem: Circular import errors

**Solution**: Use TYPE_CHECKING:
```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .post import Post

class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post")
```

### Problem: Migration shows changes when models haven't changed

**Solution**: Check for:
- Different default values in code vs database
- Timezone issues with DateTime columns
- Type mismatches (Integer vs BigInteger)

---

## Learning Path

### Beginner

1. **Start with `basic_model.py`**:
   - Understand basic column types
   - Learn primary key definition
   - Practice password hashing pattern
   - Experiment with timestamps

2. **Read `before_after_model_documentation.md`**:
   - See progression from basic to complete
   - Understand comment standards
   - Learn documentation patterns

3. **Modify `basic_model.py`**:
   - Add new columns (phone, address)
   - Add validation with @validates
   - Change database backend

### Intermediate

4. **Study `advanced_model_relationships.py`**:
   - Understand one-to-many relationships
   - Learn cascade behaviors
   - Practice eager loading

5. **Extend relationships**:
   - Add new related models
   - Implement many-to-many with data on association table
   - Add self-referential relationships (user followers)

6. **Create migration**:
   - Install Alembic
   - Generate migration from models
   - Test up/down migrations

### Advanced

7. **Build production models**:
   - Add audit logging (created_by, modified_by)
   - Implement soft deletes (is_deleted flag)
   - Add row-level security

8. **Optimize performance**:
   - Add composite indexes
   - Implement caching strategies
   - Use database-specific features (PostgreSQL JSON)

9. **Security hardening**:
   - Encrypt PII data at rest
   - Implement role-based access control
   - Add audit trail

---

## Real-World Patterns

### Pattern 1: Base Model with Common Fields

```python
from datetime import datetime
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    """Base class with common columns."""
    pass

class TimestampMixin:
    """Mixin for created/updated timestamps."""
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(),
        comment="Audit: Record creation timestamp"
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        onupdate=func.now(),
        comment="Audit: Last modification timestamp"
    )

class User(Base, TimestampMixin):
    __tablename__ = "users"
    # Automatically has created_at, updated_at
```

### Pattern 2: Soft Deletes

```python
class SoftDeleteMixin:
    """Mixin for soft delete functionality."""
    is_deleted: Mapped[bool] = mapped_column(
        default=False,
        comment="Audit: Soft delete flag (True = deleted)"
    )
    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        comment="Audit: Deletion timestamp"
    )

class User(Base, SoftDeleteMixin):
    __tablename__ = "users"

    @classmethod
    def query_active(cls, session):
        """Query only non-deleted records."""
        return session.query(cls).filter(cls.is_deleted == False)
```

### Pattern 3: Polymorphic Models

```python
class Content(Base):
    __tablename__ = "content"
    id: Mapped[int] = mapped_column(primary_key=True)
    type: Mapped[str] = mapped_column(String(20))
    title: Mapped[str] = mapped_column(String(200))

    __mapper_args__ = {
        "polymorphic_on": type,
        "polymorphic_identity": "content"
    }

class Article(Content):
    __mapper_args__ = {"polymorphic_identity": "article"}
    body: Mapped[str] = mapped_column(Text)

class Video(Content):
    __mapper_args__ = {"polymorphic_identity": "video"}
    url: Mapped[str] = mapped_column(String(500))
    duration: Mapped[int] = mapped_column(Integer)
```

---

## Testing Examples

### Unit Test Example

```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, User

@pytest.fixture
def session():
    """Create test database session."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()

def test_user_creation(session):
    """Test creating a user."""
    user = User(username="alice", email="alice@example.com")
    user.password = "secure123"
    session.add(user)
    session.commit()

    assert user.id is not None
    assert user.username == "alice"
    assert user.verify_password("secure123")
    assert not user.verify_password("wrong")

def test_user_relationships(session):
    """Test user-post relationship."""
    user = User(username="bob", email="bob@example.com")
    post = Post(title="Test", content="Content", author=user)
    session.add_all([user, post])
    session.commit()

    assert len(user.posts) == 1
    assert post.author == user
```

---

## Additional Resources

- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [SQLAlchemy Model Documentation Standards](../SQLAlchemy_Model_Documentation_Standards_Reference.md)
- [SQLAlchemy Security Standards](../SQLAlchemy_Security_Standards_Reference.md)
- [Model Review Instructions](../SQLAlchemy_Model_Review_Instructions.md)
- [Model Debugging Guide](../SQLAlchemy_Model_Debugging_Instructions.md)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)

---

## Contributing Examples

If you've created useful SQLAlchemy patterns:

1. **Follow the template**:
   - Use SQLAlchemy 2.0+ syntax (Mapped[Type])
   - Include comprehensive comments
   - Add docstrings to all classes
   - Use hybrid_property for password hashing

2. **Test thoroughly**:
   - Test with SQLite (in-memory)
   - Test relationships (load both directions)
   - Test cascade deletes
   - Verify migrations generate correctly

3. **Document usage**:
   - Add to this README
   - Include expected output
   - Document prerequisites
   - Add troubleshooting tips

---

**Last Updated**: 2025-12-11
