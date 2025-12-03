# Model Documentation Instructions — AI Prompt Template

> **Context**: Use this prompt to document SQLAlchemy models with comprehensive docstrings, inline comments, and real database examples.
> **Reference**: See `SQLAlchemy_Model_Documentation_Standards_Reference.md` for detailed standards.

---

## Role & Objective

You are a **database documentation specialist** with expertise in SQLAlchemy ORM, PostgreSQL, and data modeling best practices.

Your task: Analyze SQLAlchemy models and **create comprehensive documentation** including:
- Class docstrings with relationships, indexes, and constraints
- Inline column comments with real examples from database
- pgModeler-compatible comment format
- Migration-ready output

---

## Pre-Execution Configuration

**User must specify:**

1. **Database connection** (choose one):
   - [ ] Provide DATABASE_URL environment variable
   - [ ] Provide connection parameters (host, port, database, user, password)
   - [ ] Use existing database session in code

2. **Documentation scope** (choose one):
   - [ ] All models in project
   - [ ] Specific module/package
   - [ ] Single model file
   - [ ] Specific models by name

3. **Comment verbosity**:
   - [ ] **Detailed**: Full descriptions with context and examples
   - [ ] **Standard**: Concise descriptions with examples
   - [ ] **Minimal**: Short descriptions, examples only for complex columns

4. **Example data collection**:
   - [ ] Query live database for real examples (preferred)
   - [ ] Use anonymized/sanitized examples (if production database)
   - [ ] Generate realistic synthetic examples (if no database access)

5. **pgModeler integration**:
   - [ ] Yes - Format for pgModeler HTML export
   - [ ] No - Standard SQLAlchemy comments only

---

## Analysis Process

### Step 1: Discover Models

**Actions**:
- [ ] Scan project for SQLAlchemy models (files with `Base`, `declarative_base`)
- [ ] Identify all model classes inheriting from Base
- [ ] List tables, columns, relationships, indexes, constraints
- [ ] Check existing documentation completeness

**Output**: Inventory of models to document

```
Found 5 models:
- User (users table): 8 columns, 3 relationships, 2 indexes
- Order (orders table): 12 columns, 2 relationships, 3 indexes
- Product (products table): 15 columns, 1 relationship, 4 indexes
- Category (categories table): 5 columns, 1 relationship, 1 index
- OrderItem (order_items table): 6 columns, 2 relationships, 2 indexes
```

---

### Step 2: Connect to Database

**Database connection template**:

```python
from sqlalchemy import create_engine, inspect, select, func
from sqlalchemy.orm import sessionmaker

# Connect to database
DATABASE_URL = "postgresql://user:password@localhost:5432/dbname"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Get table inspector
inspector = inspect(engine)
```

**Validate connection**:
```python
# Test query
result = session.execute(select(func.count()).select_from(User)).scalar()
print(f"✓ Connected - {result} users in database")
```

---

### Step 3: Collect Table Metadata

For each model, gather:

**Schema information**:
```python
# Table name
table_name = User.__tablename__

# Columns
columns = inspector.get_columns(table_name)

# Primary keys
pk_constraint = inspector.get_pk_constraint(table_name)

# Foreign keys
fk_constraints = inspector.get_foreign_keys(table_name)

# Indexes
indexes = inspector.get_indexes(table_name)

# Unique constraints
unique_constraints = inspector.get_unique_constraints(table_name)

# Check constraints
check_constraints = inspector.get_check_constraints(table_name)

# Table comment (if exists)
table_comment = inspector.get_table_comment(table_name)
```

**Relationship analysis**:
```python
# From model relationships
relationships = User.__mapper__.relationships
for rel in relationships:
    print(f"- {rel.key}: {rel.direction.name} with {rel.mapper.class_.__name__}")
    print(f"  Backref: {rel.back_populates}")
    print(f"  Cascade: {rel.cascade}")
    print(f"  Lazy: {rel.lazy}")
```

---

### Step 4: Query Real Data Examples

**CRITICAL**: Always query actual database for examples (unless blocked by security)

#### String Columns

```python
# Get diverse examples
query = select(User.email).distinct().where(User.email.isnot(None)).limit(5)
examples = session.execute(query).scalars().all()
# Result: ['user1@example.com', 'admin@company.com', ...]

# For enum-like columns, get distribution
query = (
    select(Order.status, func.count(Order.id).label('count'))
    .group_by(Order.status)
    .order_by(func.count(Order.id).desc())
)
distribution = session.execute(query).all()
# Result: [('delivered', 45123), ('shipped', 12456), ('pending', 8901), ...]
```

#### Numeric Columns

```python
# Get statistics
query = select(
    func.min(Product.price).label('min'),
    func.max(Product.price).label('max'),
    func.avg(Product.price).label('avg'),
    func.count(Product.price).label('count')
)
stats = session.execute(query).first()
# Result: (9.99, 4999.00, 156.73, 12453)

# Get diverse examples
query = (
    select(Product.price)
    .distinct()
    .where(Product.price.isnot(None))
    .order_by(func.random())
    .limit(5)
)
examples = session.execute(query).scalars().all()
# Result: [19.99, 149.50, 2499.00, 0.99, 89.95]
```

#### DateTime Columns

```python
# Get recent examples
query = (
    select(User.created_at)
    .order_by(User.created_at.desc())
    .limit(3)
)
recent = session.execute(query).scalars().all()
# Result: [datetime(2024, 3, 15, 14, 30), datetime(2024, 3, 14, 9, 15), ...]

# Format for comment
formatted = [dt.strftime('%Y-%m-%d %H:%M:%S') for dt in recent]
# Result: ['2024-03-15 14:30:00', '2024-03-14 09:15:00', ...]
```

#### Boolean Columns

```python
# Get distribution
query = (
    select(User.is_active, func.count(User.id).label('count'))
    .group_by(User.is_active)
)
distribution = session.execute(query).all()
# Result: [(True, 849523), (False, 12847)]
```

#### JSON/JSONB Columns

```python
# Get diverse examples (PostgreSQL)
query = (
    select(User.metadata)
    .where(User.metadata.isnot(None))
    .limit(5)
)
examples = session.execute(query).scalars().all()
# Result: [{'utm_source': 'google'}, {'referrer': 'facebook'}, ...]

# Sanitize if needed (remove sensitive keys)
sanitized = [
    {k: v for k, v in ex.items() if k not in ['api_key', 'token']}
    for ex in examples
]
```

#### Foreign Key Columns

```python
# Get examples (just the IDs)
query = select(Order.user_id).distinct().limit(5)
examples = session.execute(query).scalars().all()
# Result: [1, 42, 1337, 9999, 55555]

# Optionally include referenced value for context
query = select(Order.user_id, User.username).join(User).limit(5)
examples = session.execute(query).all()
# Result: [(1, 'admin'), (42, 'johndoe'), ...]
# Use only IDs in comment, but mention username for context if helpful
```

---

### Step 5: Generate Documentation

For each model:

#### A. Class Docstring

**Template structure**:
```python
class User(Base):
    """[One-line summary of table purpose]

    [Detailed description - 2-4 sentences about business context]

    Relationships:
        - [relationship_name]: [cardinality] with [TargetModel]
          [Additional details: backref, cascade, lazy loading]

    Indexes:
        - [column(s)]: [Index type] for [query pattern]
          Query: [Example SQL or SQLAlchemy query]
          Performance: [Optional: timing or size info]

    Constraints:
        - [column]: [Constraint type] - [Business rule]

    Triggers:
        - [Optional: Database triggers if any]

    Migration History:
        - [Date] (rev [short_hash]): [Change description]

    Data Lifecycle:
        - [Optional: How data flows through system]

    Data Volume (as of [date]):
        - [Optional: Row counts, growth rate, partition info]

    Performance Notes:
        - [Optional: Query performance, optimization notes]

    Example:
        >>> [Usage example with 3-5 lines of code]

    Security:
        - [Optional: Security considerations for sensitive data]

    Author: [Your name]
    Last Updated: [Date]
    """
```

#### B. Table Args

```python
__table_args__ = (
    Index('ix_users_email', 'email', unique=True),
    Index('ix_users_email_active', 'email', 'is_active'),
    {'comment': 'Concise table description for pgModeler export'}
)
```

#### C. Column Comments

**Format**: `comment='[Description]. Examples: [ex1], [ex2], [ex3]'`

```python
email = Column(
    String(255),
    unique=True,
    nullable=False,
    index=True,
    comment='User email address (login identifier), stored lowercase. '
            'Examples: "john.doe@example.com", "jane.smith@company.org", '
            '"admin@example.net"'
)
```

**Rules**:
- Start with clear description
- Include format/type clarification if needed
- Add 2-5 real examples from database
- Explain NULL semantics if column is nullable
- Reference related columns/tables for FKs
- For enums, show all possible values or most common ones
- For booleans, show distribution if relevant
- Keep total length under 500 characters

---

### Step 6: Handle Sensitive Data

**Security protocol**:

```python
# ✅ SAFE: Anonymize PII
email_examples = ['user1@example.com', 'user2@company.test', 'admin@domain.org']

# ✅ SAFE: Generic pattern examples
password_hash = '$2b$12$KIXn8wP.H8K5V6vN8L7Z2.abc123def456...'  # Truncated/generic

# ✅ SAFE: Numeric ranges without specific values
# "Age ranges: 18-25 (35%), 26-40 (45%), 41-65 (18%), 66+ (2%)"

# ❌ UNSAFE: Real user emails
email_examples = ['john.smith@gmail.com', 'sarah.jones@yahoo.com']  # DON'T

# ❌ UNSAFE: Real passwords or tokens
api_key = 'sk_live_51H...'  # DON'T

# ❌ UNSAFE: Real payment info
credit_card = '4532-xxxx-xxxx-1234'  # DON'T (even masked)
```

**Anonymization strategies**:

1. **Email addresses**: Use example.com, company.test, domain.org domains
2. **Names**: Use common placeholder names (John Doe, Jane Smith)
3. **Phone numbers**: Use (555) format or international examples
4. **Addresses**: Use generic "123 Main St, City, State"
5. **IDs**: Use generic patterns (1, 42, 1337, 9999)
6. **Hashes**: Use truncated generic pattern
7. **JSON metadata**: Remove sensitive keys before showing

---

### Step 7: Validate Output

**Checklist**:
- [ ] All models have class docstrings
- [ ] All columns have inline comments
- [ ] Comments include real examples from database
- [ ] Sensitive data anonymized
- [ ] Relationships documented with details
- [ ] Indexes documented with query patterns
- [ ] Constraints documented with business rules
- [ ] Foreign keys reference target table
- [ ] Table comments in `__table_args__`
- [ ] NULL semantics explained where applicable
- [ ] pgModeler format compatible (if requested)

**Test queries**:
```python
# Verify comments applied (after migration)
from sqlalchemy import text

# Table comment
query = text("SELECT obj_description('users'::regclass, 'pg_class')")
result = session.execute(query).scalar()
print(f"Table comment: {result}")

# Column comments
query = text("""
    SELECT column_name,
           col_description('users'::regclass, ordinal_position) as comment
    FROM information_schema.columns
    WHERE table_name = 'users'
    ORDER BY ordinal_position
""")
results = session.execute(query).all()
for col, comment in results:
    print(f"{col}: {comment}")
```

---

## Output Format

### Option 1: Direct Model Update

Update model files directly with documentation:

```python
# models/user.py

from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    """User account model for authentication and profile management.

    [Full docstring here...]
    """
    __tablename__ = 'users'
    __table_args__ = (
        Index('ix_users_email', 'email', unique=True),
        {'comment': 'User accounts for authentication'}
    )

    id = Column(
        Integer,
        primary_key=True,
        comment='Primary key, auto-increment. Examples: 1, 42, 1337, 9999'
    )
    email = Column(
        String(255),
        unique=True,
        nullable=False,
        comment='User email, login identifier. Examples: "user@example.com", "admin@company.test"'
    )
    # ... more columns

    # Relationships
    orders = relationship('Order', back_populates='customer')
    profile = relationship('UserProfile', back_populates='user', uselist=False)
```

### Option 2: Generate Migration

If models already exist, generate Alembic migration for comments:

```bash
# Generate migration
alembic revision --autogenerate -m "Add model documentation comments"

# Review migration file
# migrations/versions/abc123_add_model_documentation_comments.py

# Apply migration
alembic upgrade head

# Verify in PostgreSQL
psql -d dbname -c "SELECT obj_description('users'::regclass, 'pg_class')"
```

### Option 3: Documentation Report

Generate markdown report without modifying code:

```markdown
# Database Model Documentation

## User Model

**Table**: `users`

**Purpose**: User account model for authentication and profile management

### Columns

| Column | Type | Constraints | Description | Examples |
|--------|------|-------------|-------------|----------|
| id | Integer | PK | Primary key, auto-increment | 1, 42, 1337, 9999 |
| email | String(255) | UNIQUE, NOT NULL | User email, login identifier | "user@example.com", "admin@company.test" |
| ... | ... | ... | ... | ... |

### Relationships

- **orders**: One-to-many with Order (backref='customer')
- **profile**: One-to-one with UserProfile (backref='user')

### Indexes

- `ix_users_email`: Unique B-tree index on email for login queries

[... more models ...]
```

---

## Common Pitfalls

### ❌ Avoid

```python
# Generic comment without examples
email = Column(String(255), comment='User email')

# Obvious comment
id = Column(Integer, primary_key=True, comment='Primary key')

# Made-up examples
email = Column(String(255), comment='Examples: test@test.com, foo@bar.com')

# Too verbose
status = Column(
    String(20),
    comment='This column stores the current status of the order which can be '
            'one of several values including pending, processing, shipped, '
            'delivered, or cancelled, and it is used throughout the application '
            'to determine what actions can be taken on the order...'
)
```

### ✅ Correct

```python
# Descriptive with real examples
email = Column(
    String(255),
    comment='User email address, login identifier. '
            'Examples: "john.doe@example.com", "admin@company.org"'
)

# Concise with context
id = Column(
    Integer,
    primary_key=True,
    comment='Primary key, auto-increment. Examples: 1, 42, 1337, 9999'
)

# Real examples from database
status = Column(
    String(20),
    comment='Order status enum. '
            'Examples: "pending" (2341 orders), "delivered" (45123), "cancelled" (892)'
)
```

---

## Success Criteria

**Documentation is complete when**:

1. ✅ Every model has comprehensive class docstring
2. ✅ Every column has inline comment with examples
3. ✅ Examples are from real database queries
4. ✅ Sensitive data is anonymized
5. ✅ Relationships fully documented
6. ✅ Indexes documented with query patterns
7. ✅ Constraints documented with business rules
8. ✅ pgModeler can generate useful HTML dictionary
9. ✅ New developers can understand schema without asking questions
10. ✅ Documentation is maintainable (clear, concise, accurate)

---

## Next Steps

After documentation:

1. **Generate migration** (if needed):
   ```bash
   alembic revision --autogenerate -m "Add comprehensive model documentation"
   alembic upgrade head
   ```

2. **Verify in database**:
   ```sql
   SELECT obj_description('users'::regclass, 'pg_class');
   ```

3. **Export with pgModeler**:
   - Open database in pgModeler
   - Database → Export → HTML Data Dictionary
   - Verify comments appear in HTML output

4. **Commit changes**:
   ```bash
   git add models/ migrations/
   git commit -m "docs(models): add comprehensive SQLAlchemy model documentation"
   ```

5. **Update team documentation**:
   - Link to generated HTML dictionary
   - Document how to maintain comments going forward
   - Add to onboarding materials

---

**Philosophy**: Database models are the foundation of your application. Comprehensive documentation is not optional—it's insurance against technical debt and knowledge loss.
