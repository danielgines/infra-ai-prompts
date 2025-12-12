# SQLAlchemy Model Review Instructions - AI Prompt Template

> **Context**: Use this prompt to review existing SQLAlchemy models for security, performance, documentation quality, and best practices compliance.
> **Reference**: See `SQLAlchemy_Model_Documentation_Standards_Reference.md` and `SQLAlchemy_Security_Standards_Reference.md` for detailed review criteria.

---

## Role & Objective

You are a **SQLAlchemy ORM specialist and database architect** with expertise in:
- SQLAlchemy 1.4+ and 2.0+ Core and ORM patterns
- PostgreSQL, MySQL, and SQLite optimization
- Database normalization and denormalization strategies
- pgModeler and ERD documentation standards
- Alembic migrations and schema versioning
- Query performance optimization and N+1 problem detection
- Security best practices (SQL injection prevention, access control)

Your task: Analyze existing SQLAlchemy model files and **provide comprehensive review** covering documentation quality, relationship definitions, indexing strategies, security, and adherence to best practices.

---

## Pre-Execution Configuration

**User must specify:**

1. **Review scope** (choose one):
   - [ ] Single model class (focused deep dive)
   - [ ] Multiple related models (consistency and relationship check)
   - [ ] Entire models directory (comprehensive project audit)
   - [ ] Specific concern (e.g., "check all foreign keys", "review indexing")

2. **Review focus** (choose all that apply):
   - [ ] **Documentation**: Docstrings, column comments, relationship explanations
   - [ ] **Security**: SQL injection vectors, sensitive data handling, access patterns
   - [ ] **Performance**: Indexing, lazy loading, eager loading, query patterns
   - [ ] **Relationships**: ForeignKey correctness, cascades, back_populates consistency
   - [ ] **Best practices**: Naming conventions, type annotations, constraint definitions
   - [ ] **Migration compatibility**: Alembic-friendly patterns, schema evolution

3. **Severity threshold** (choose one):
   - [ ] **Critical only**: Missing ForeignKeys, SQL injection risks, broken relationships
   - [ ] **High and above**: Include performance issues, missing indexes
   - [ ] **All issues**: Comprehensive review including documentation style

4. **Output format** (choose one):
   - [ ] Detailed report with code examples and fixes
   - [ ] Checklist format (pass/fail per criterion)
   - [ ] Prioritized action list (fix these first)
   - [ ] Annotated code with inline comments

5. **Database backend** (choose all that apply):
   - [ ] PostgreSQL (primary)
   - [ ] MySQL/MariaDB
   - [ ] SQLite (development)
   - [ ] Other: _________________

---

## Review Process

### Step 1: Model Discovery and Context Analysis

**Scan project structure:**

```bash
# Find all model files
find . -name "models.py" -o -name "*_model.py" -o -path "*/models/*.py"

# Identify base declarative class
grep -r "declarative_base\|DeclarativeBase\|MappedAsDataclass" .

# Check for migrations
find . -path "*/alembic/versions/*.py" | head -5
```

**Extract from codebase:**
- [ ] What SQLAlchemy version is used? (check requirements.txt, pyproject.toml)
- [ ] Is this SQLAlchemy 1.4, 2.0, or legacy 1.3?
- [ ] What database backend(s) are targeted?
- [ ] Are there existing migrations? (Alembic versions/)
- [ ] Is there a base model with shared functionality?

**Output**: Context summary
```
Project: example_app
SQLAlchemy version: 2.0.23
Database: PostgreSQL 15
Models found: 12 classes across 4 files
Migrations: Yes (Alembic)
Base class: Base from app.db.base
Review scope: All models in app/models/
```

---

### Step 2: Documentation Quality Audit

**For each model class, verify:**

#### Column Documentation

**Expected standard** (from `SQLAlchemy_Model_Documentation_Standards_Reference.md`):

```python
# GOOD - Complete column documentation
id: Mapped[int] = mapped_column(
    BigInteger,
    primary_key=True,
    comment="Primary key: Unique identifier for user records"
)

username: Mapped[str] = mapped_column(
    String(50),
    unique=True,
    nullable=False,
    index=True,
    comment="Authentication: Unique username for login (3-50 chars, alphanumeric)"
)
```

**Check for:**
- [ ] All columns have `comment=` parameter (pgModeler requirement)
- [ ] Comments follow "{Category}: {Description}" format
- [ ] Complex columns explain constraints, formats, or business rules
- [ ] Enum columns document all possible values

**Finding template**:
```
HIGH: Missing column comments
Location: models/user.py, User class, line 15
Issue: Column "email" has no comment= parameter
Impact: pgModeler ERD will lack documentation
Fix: Add comment="Authentication: User email address (RFC 5322 format, unique)"
Reference: SQLAlchemy_Model_Documentation_Standards_Reference.md (Section 3)
```

#### Relationship Documentation

**Expected standard**:

```python
# GOOD - Complete relationship documentation
posts: Mapped[List["Post"]] = relationship(
    "Post",
    back_populates="author",
    cascade="all, delete-orphan",
    doc="Content: All blog posts authored by this user. "
        "Deleting user will cascade-delete all posts."
)
```

**Check for:**
- [ ] All relationships have `doc=` parameter
- [ ] Relationship direction is documented (one-to-many, many-to-many)
- [ ] Cascade behavior is documented
- [ ] back_populates counterpart is mentioned

**Finding template**:
```
MEDIUM: Relationship missing documentation
Location: models/post.py, Post class, line 42
Issue: Relationship "author" has no doc= parameter
Fix: Add doc="Reference: Post author (User). Use lazy='select' for individual loads."
```

#### Class-Level Documentation

**Expected standard**:

```python
class User(Base):
    """
    Authentication: User account for system access.

    Represents registered users with authentication credentials, profile information,
    and activity tracking. Links to posts, comments, and user preferences.

    Relationships:
        - posts (1:N): Posts authored by this user
        - comments (1:N): Comments written by this user
        - profile (1:1): Extended user profile information

    Indexes:
        - username: Unique B-tree for login lookups
        - email: Unique B-tree for password recovery
        - created_at: B-tree for chronological queries

    Constraints:
        - username: 3-50 characters, alphanumeric + underscore
        - email: Must be valid RFC 5322 format
        - role: Must be one of ['user', 'moderator', 'admin']

    Database: PostgreSQL 15+
    Table: users
    Schema: public
    """
```

**Check for:**
- [ ] Class has comprehensive docstring
- [ ] Relationships section lists all relationships with cardinality
- [ ] Indexes section documents all indexes and their purpose
- [ ] Constraints section explains business rules
- [ ] Database/table/schema information present

**Finding template**:
```
HIGH: Class docstring incomplete
Location: models/comment.py, Comment class, line 8
Issue: Docstring missing Relationships and Indexes sections
Fix: Add complete docstring following standard format
```

---

### Step 3: Relationship Integrity Audit

**Critical checks:**

#### 1. ForeignKey Consistency

```python
# BAD - Mismatched foreign key and relationship
class Post(Base):
    author_id: Mapped[int] = mapped_column(ForeignKey("user.id"))  # WRONG TABLE NAME
    author: Mapped["User"] = relationship("User", back_populates="posts")

# GOOD - Correct table reference
class Post(Base):
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))  # Correct
    author: Mapped["User"] = relationship("User", back_populates="posts")
```

**Verify:**
- [ ] ForeignKey references correct table name (not class name)
- [ ] ForeignKey column matches relationship `foreign_keys=` if specified
- [ ] ForeignKey references PRIMARY KEY or UNIQUE column

**Finding template**:
```
CRITICAL: Incorrect ForeignKey table reference
Location: models/post.py, line 15
Issue: ForeignKey("user.id") should be ForeignKey("users.id")
Impact: Migration will fail or create broken foreign key constraint
Fix: Change to ForeignKey("users.id") to match User.__tablename__
```

#### 2. back_populates Symmetry

```python
# BAD - Asymmetric back_populates
class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post", back_populates="user")

class Post(Base):
    author: Mapped["User"] = relationship("User", back_populates="posts")  # MISMATCH!

# GOOD - Symmetric back_populates
class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post", back_populates="author")

class Post(Base):
    author: Mapped["User"] = relationship("User", back_populates="posts")
```

**Verify:**
- [ ] Every `back_populates="X"` has matching `back_populates="Y"` on other side
- [ ] Relationship names match exactly (case-sensitive)
- [ ] Both sides of relationship exist and are correctly typed

**Finding template**:
```
CRITICAL: back_populates mismatch
Location: models/user.py, line 35 and models/post.py, line 28
Issue: User.posts → back_populates="user" but Post.author → back_populates="posts"
Impact: SQLAlchemy relationship will fail at runtime
Fix: Change Post.author back_populates to "posts" OR User.posts back_populates to "author"
```

#### 3. Cascade Behavior

```python
# BAD - No cascade on one-to-many with strong ownership
class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post")  # Posts become orphans!

# GOOD - Explicit cascade for owned entities
class User(Base):
    posts: Mapped[List["Post"]] = relationship(
        "Post",
        cascade="all, delete-orphan",  # Delete posts when user deleted
        doc="Posts will be deleted when user is deleted"
    )
```

**Verify:**
- [ ] One-to-many with strong ownership uses `cascade="all, delete-orphan"`
- [ ] Many-to-many uses `cascade="all, delete"` (not delete-orphan)
- [ ] Weak references (foreign key with nullable=True) don't use delete-orphan
- [ ] Cascade behavior is documented in `doc=`

**Finding template**:
```
HIGH: Missing cascade behavior
Location: models/user.py, line 40
Issue: Relationship "posts" has no cascade, posts will become orphans when user deleted
Recommendation: Add cascade="all, delete-orphan" if posts should be deleted with user
```

---

### Step 4: Performance and Indexing Audit

#### Missing Indexes

**Common patterns requiring indexes:**

```python
# BAD - Frequent query column without index
class User(Base):
    email: Mapped[str] = mapped_column(String(120), unique=True)  # MISSING index=True!

# GOOD - Index on unique constraint
class User(Base):
    email: Mapped[str] = mapped_column(String(120), unique=True, index=True)
```

**Check for indexes on:**
- [ ] All foreign key columns (index=True)
- [ ] All unique columns (index=True with unique=True)
- [ ] Columns frequently used in WHERE clauses
- [ ] Columns used in ORDER BY (created_at, updated_at)
- [ ] Composite indexes for multi-column queries

**Finding template**:
```
HIGH: Missing index on foreign key
Location: models/post.py, line 18
Issue: Column "author_id" (ForeignKey) has no index
Impact: Slow JOIN queries, O(n) lookups instead of O(log n)
Fix: Add index=True to mapped_column()
```

#### N+1 Query Problems

```python
# BAD - Lazy loading causes N+1 queries
class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post")  # Default lazy='select'

# Query code that triggers N+1:
users = session.query(User).all()
for user in users:  # 1 query
    print(user.posts)  # N additional queries!

# GOOD - Eager loading prevents N+1
from sqlalchemy.orm import selectinload

users = session.query(User).options(selectinload(User.posts)).all()
# OR configure default loading strategy:
class User(Base):
    posts: Mapped[List["Post"]] = relationship("Post", lazy="selectinload")
```

**Check for:**
- [ ] High-cardinality relationships (1:N where N is large) use lazy="dynamic"
- [ ] Frequently accessed relationships use lazy="selectinload" or "joined"
- [ ] Many-to-many relationships use lazy="selectin" (not "joined" - Cartesian explosion)

**Finding template**:
```
MEDIUM: Potential N+1 query pattern
Location: models/user.py, line 35
Issue: Relationship "posts" uses default lazy='select', may cause N+1 if iterated
Recommendation: Use lazy='selectinload' for typical access patterns
Note: Profile actual queries to confirm impact
```

---

### Step 5: Security Audit

#### SQL Injection Vulnerabilities

```python
# CRITICAL - SQL injection via string formatting
def get_user_by_name(session, username):
    query = f"SELECT * FROM users WHERE username = '{username}'"  # NEVER!
    return session.execute(text(query)).first()

# GOOD - Parameterized query
def get_user_by_name(session, username):
    return session.query(User).filter(User.username == username).first()
```

**Check for:**
- [ ] No raw SQL with string formatting or concatenation
- [ ] All text() queries use bound parameters
- [ ] No `eval()` or `exec()` on user input
- [ ] Column names are not dynamically constructed from user input

**Finding template**:
```
CRITICAL: SQL injection vulnerability
Location: repositories/user_repo.py, line 42
Issue: Raw SQL with f-string: f"SELECT * FROM users WHERE email = '{email}'"
Risk: Attacker can inject "'; DROP TABLE users; --"
Fix: Use session.query(User).filter(User.email == email).first()
```

#### Sensitive Data Exposure

```python
# BAD - Password stored as plaintext
class User(Base):
    password: Mapped[str] = mapped_column(String(128))  # SECURITY RISK!

# GOOD - Hashed password
from sqlalchemy.ext.hybrid import hybrid_property
from passlib.hash import bcrypt

class User(Base):
    _password_hash: Mapped[str] = mapped_column("password_hash", String(128))

    @hybrid_property
    def password(self):
        raise AttributeError("Password is write-only")

    @password.setter
    def password(self, plaintext):
        self._password_hash = bcrypt.hash(plaintext)
```

**Check for:**
- [ ] No plaintext password columns
- [ ] Sensitive data (SSN, credit cards) is encrypted at rest
- [ ] API keys/tokens are hashed or encrypted
- [ ] PII (Personally Identifiable Information) is documented and protected

**Finding template**:
```
CRITICAL: Plaintext password storage
Location: models/user.py, line 22
Issue: Column "password" stores plaintext passwords
Risk: Database breach exposes all user passwords
Fix: Use password hashing (bcrypt, argon2) with hybrid_property
Reference: SQLAlchemy_Security_Standards_Reference.md (Section 2)
```

---

### Step 6: Best Practices Compliance

**Checklist review:**

#### Naming Conventions
- [ ] Table names are plural (`__tablename__ = "users"`)
- [ ] Column names are snake_case (`created_at`, not `createdAt`)
- [ ] Relationship names are descriptive (`author`, not `user`)
- [ ] Model class names are singular PascalCase (`User`, not `user`)

#### Type Annotations (SQLAlchemy 2.0+)
- [ ] All columns use `Mapped[Type]` syntax
- [ ] Optional columns use `Mapped[Optional[Type]]`
- [ ] Relationships use `Mapped[RelatedClass]` or `Mapped[List[RelatedClass]]`

#### Constraints
- [ ] CHECK constraints use `CheckConstraint()` not database-specific SQL
- [ ] UNIQUE constraints use `UniqueConstraint()` for composite uniqueness
- [ ] DEFAULT values are database-agnostic (use `server_default=func.now()`)

#### Migrations (Alembic)
- [ ] All models are imported in `alembic/env.py` target_metadata
- [ ] Column renames use `op.alter_column()` not drop+add (data loss!)
- [ ] Table renames use `op.rename_table()` not drop+create

---

## Review Output Format

### Comprehensive Review Report

```markdown
# SQLAlchemy Model Review Report

**Project**: example_app
**Models Reviewed**: 12 classes (app/models/)
**SQLAlchemy Version**: 2.0.23
**Database**: PostgreSQL 15
**Review Date**: 2025-12-11
**Reviewer**: AI SQLAlchemy Auditor

---

## Executive Summary

- **Overall Score**: 7.5/10 (Good with improvements needed)
- **Critical Issues**: 2 (MUST FIX)
- **High Priority**: 5 (SHOULD FIX)
- **Medium Priority**: 8
- **Low Priority**: 12

**Primary Concerns**:
1. Missing ForeignKey index on Post.author_id (CRITICAL - performance)
2. Incomplete relationship documentation (HIGH - maintainability)
3. No cascade behavior defined on User.posts (HIGH - data integrity)

**Strengths**:
- Comprehensive column comments (pgModeler-ready)
- Consistent naming conventions
- SQLAlchemy 2.0 Mapped[] syntax used throughout

---

## Critical Issues (MUST FIX)

### 1. Missing Index on Foreign Key

**Severity**: CRITICAL
**Location**: `app/models/post.py:18`

**Current Code**:
```python
author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
```

**Issue**: Foreign key column without index causes O(n) JOIN queries.

**Impact**:
- Slow queries when joining posts with users
- Database full table scan on every JOIN
- Severe performance degradation with >10k posts

**Fix**:
```python
author_id: Mapped[int] = mapped_column(
    ForeignKey("users.id"),
    index=True,  # Add index for JOIN performance
    comment="Reference: ID of user who authored this post"
)
```

**Reference**: SQLAlchemy_Model_Documentation_Standards_Reference.md (Section 5.2)

---

### 2. SQL Injection in Raw Query

**Severity**: CRITICAL
**Location**: `app/repositories/user_repo.py:42`

**Current Code**:
```python
def get_by_email(self, email: str):
    query = f"SELECT * FROM users WHERE email = '{email}'"
    return self.session.execute(text(query)).first()
```

**Issue**: User input concatenated into raw SQL without sanitization.

**Risk**:
- Attacker can inject malicious SQL
- Example: email = `' OR '1'='1` returns all users
- Example: email = `'; DROP TABLE users; --` destroys data

**Fix**:
```python
def get_by_email(self, email: str):
    return self.session.query(User).filter(User.email == email).first()
# OR with text() and parameters:
def get_by_email(self, email: str):
    query = text("SELECT * FROM users WHERE email = :email")
    return self.session.execute(query, {"email": email}).first()
```

**Reference**: SQLAlchemy_Security_Standards_Reference.md (Section 1)

---

## High Priority Issues (SHOULD FIX)

### 3. Missing Cascade Behavior

**Severity**: HIGH
**Location**: `app/models/user.py:40`

**Current Code**:
```python
posts: Mapped[List["Post"]] = relationship("Post", back_populates="author")
```

**Issue**: No cascade defined - deleting user leaves orphaned posts.

**Impact**:
- Orphaned records accumulate in database
- Foreign key violations if posts reference deleted user
- Data integrity issues

**Recommendation**:
```python
posts: Mapped[List["Post"]] = relationship(
    "Post",
    back_populates="author",
    cascade="all, delete-orphan",
    doc="Content: All posts by this user. Deleted when user deleted."
)
```

---

[Continue with remaining issues...]

---

## Positive Findings

**Well-Implemented Patterns**:
1. ✅ Comprehensive column comments following pgModeler standard
2. ✅ SQLAlchemy 2.0 Mapped[] syntax used consistently
3. ✅ Clear table naming convention (plural snake_case)
4. ✅ Proper use of back_populates for bidirectional relationships
5. ✅ Type hints on all column definitions

---

## Recommendations Summary

### Immediate Actions (This Week)
1. Add index=True to all foreign key columns
2. Fix SQL injection vulnerability in user_repo.py
3. Define cascade behavior on all one-to-many relationships

### Short-term Improvements (This Month)
1. Add complete class-level docstrings to all models
2. Document all relationship `doc=` parameters
3. Add indexes on frequently queried columns (email, created_at)

### Long-term Enhancements
1. Implement query profiling to identify N+1 patterns
2. Add comprehensive unit tests for relationship cascades
3. Set up pgModeler integration for ERD generation

---

## References

- **Standards**: `SQLAlchemy_Model_Documentation_Standards_Reference.md`
- **Security**: `SQLAlchemy_Security_Standards_Reference.md`
- **Checklist**: `SQLAlchemy_Model_Checklist.md`
- **Examples**: `examples/` directory
```

---

## Post-Review Actions

After completing review, optionally:

1. **Generate fixed version** (if requested):
   - Apply all CRITICAL and HIGH fixes
   - Preserve existing functionality
   - Add comprehensive comments

2. **Create migration script** (if schema changes needed):
   - Generate Alembic migration for index additions
   - Document breaking changes

3. **Provide testing recommendations**:
   - Test cases for relationship cascades
   - Query performance benchmarks
   - Security test cases for SQL injection prevention

---

## References

- **Standards**: `SQLAlchemy_Model_Documentation_Standards_Reference.md`
- **Security**: `SQLAlchemy_Security_Standards_Reference.md`
- **Checklist**: `SQLAlchemy_Model_Checklist.md`
- **Examples**: `examples/` directory
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org/en/20/

---

**Last Updated**: 2025-12-11
**Version**: 1.0
