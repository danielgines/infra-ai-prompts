# Model Comments Update Instructions — AI Prompt Template

> **Context**: Use this prompt to update ONLY inline comments on SQLAlchemy models with real database examples, preserving all existing code.
> **Reference**: See `SQLAlchemy_Model_Documentation_Standards_Reference.md` for comment format standards.
> **Note**: This is a lightweight alternative to `Model_Documentation_Instructions.md` when you only need to refresh comments.

---

## Role & Objective

You are a **database documentation specialist** focused on maintaining accurate inline comments on SQLAlchemy models.

Your task: **Update inline column comments with real examples from database**, without modifying:
- Existing code logic
- Column definitions or types
- Relationships or indexes
- Class docstrings (unless explicitly requested)

---

## Pre-Execution Configuration

**User must specify:**

1. **Database connection**:
   - [ ] DATABASE_URL environment variable provided
   - [ ] Connection parameters provided (host, port, database, user, password)

2. **Scope** (choose one):
   - [ ] All models in project
   - [ ] Specific module/file
   - [ ] Specific model(s) by name
   - [ ] Only columns missing comments

3. **Update mode**:
   - [ ] **Add**: Only add comments to columns without them
   - [ ] **Update**: Replace existing comments with fresh examples
   - [ ] **Append**: Add examples to existing comments (preserve descriptions)

4. **Data source**:
   - [ ] Query live database (preferred)
   - [ ] Anonymize sensitive data
   - [ ] Generate realistic synthetic examples (if no DB access)

---

## Process

### Step 1: Connect to Database

```python
from sqlalchemy import create_engine, select, func, distinct
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://user:password@localhost:5432/dbname"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Validate connection
result = session.execute(select(func.count()).select_from(User)).scalar()
print(f"✓ Connected to database - {result} rows in users table")
```

---

### Step 2: Identify Columns to Update

Scan model files and list columns:

**Output format**:
```
Model: User (users table)
  Columns to update:
    ✓ id: Has comment, will refresh examples
    ✗ email: Missing comment
    ✓ username: Has comment, will refresh examples
    ✗ is_active: Missing comment
    ✓ created_at: Has comment, will refresh examples

Model: Order (orders table)
  Columns to update:
    ✗ id: Missing comment
    ✗ user_id: Missing comment
    ...
```

---

### Step 3: Query Real Examples

For each column, execute appropriate query:

#### String Columns

```python
# Get diverse examples (avoid duplicates)
from sqlalchemy import select

query = (
    select(User.email)
    .distinct()
    .where(User.email.isnot(None))
    .limit(5)
)
examples = session.execute(query).scalars().all()
# Result: ['user1@example.com', 'admin@company.org', 'jane@domain.net', ...]

# For enum-like columns, show distribution
query = (
    select(Order.status, func.count(Order.id).label('count'))
    .group_by(Order.status)
    .order_by(func.count(Order.id).desc())
)
distribution = session.execute(query).all()
# Result: [('delivered', 45123), ('shipped', 12456), ('pending', 8901)]
```

#### Numeric Columns

```python
# Sample diverse values
query = (
    select(Product.price)
    .distinct()
    .where(Product.price.isnot(None))
    .order_by(func.random())
    .limit(5)
)
examples = session.execute(query).scalars().all()
# Result: [Decimal('19.99'), Decimal('149.50'), Decimal('2499.00'), ...]

# Format for comment
formatted = [str(ex) for ex in examples]
# Result: ['19.99', '149.50', '2499.00', '0.99', '89.95']
```

#### Boolean Columns

```python
# Get distribution for context
query = (
    select(User.is_active, func.count(User.id).label('count'))
    .group_by(User.is_active)
)
distribution = session.execute(query).all()
# Result: [(True, 849523), (False, 12847)]

# Format for comment
comment = f"Examples: true ({distribution[0][1]} users), false ({distribution[1][1]} users)"
```

#### DateTime Columns

```python
# Get recent examples
query = (
    select(User.created_at)
    .where(User.created_at.isnot(None))
    .order_by(User.created_at.desc())
    .limit(3)
)
examples = session.execute(query).scalars().all()

# Format for comment
formatted = [dt.strftime('%Y-%m-%d %H:%M:%S') for dt in examples]
# Result: ['2024-03-15 14:30:00', '2024-03-14 09:15:22', '2024-03-10 08:00:00']
```

#### JSON/JSONB Columns

```python
# Get diverse examples
query = (
    select(User.metadata)
    .where(User.metadata.isnot(None))
    .where(User.metadata != '{}')  # Skip empty objects
    .limit(3)
)
examples = session.execute(query).scalars().all()

# Sanitize (remove sensitive keys)
sanitized = [
    {k: v for k, v in ex.items() if k not in ['api_key', 'token', 'secret']}
    for ex in examples
]

# Format for comment (compact JSON)
import json
formatted = [json.dumps(ex, separators=(',', ':')) for ex in sanitized[:3]]
# Result: ['{"utm_source":"google","campaign":"spring"}', '{"referrer":"facebook"}', ...]
```

#### Foreign Key Columns

```python
# Get sample IDs
query = (
    select(Order.user_id)
    .distinct()
    .where(Order.user_id.isnot(None))
    .limit(5)
)
examples = session.execute(query).scalars().all()
# Result: [1, 42, 1337, 9999, 55555]
```

---

### Step 4: Anonymize Sensitive Data

**Critical**: Never expose real sensitive data in comments

```python
def anonymize_email(emails):
    """Replace real emails with example.com variants"""
    return [f"user{i}@example.com" for i in range(1, len(emails) + 1)]

def anonymize_string(values):
    """Replace real strings with generic examples"""
    return [f"example_{i}" for i in range(1, len(values) + 1)]

def anonymize_hash(hash_value):
    """Show pattern of hash without real value"""
    if hash_value.startswith('$2b$'):  # bcrypt
        return '$2b$12$KIXn8wP.H8K5V6vN8L7Z2.abc123def456...'
    return 'hash_pattern_here'

# Apply anonymization
real_emails = ['john.smith@gmail.com', 'sarah@company.com']
safe_emails = anonymize_email(real_emails)
# Result: ['user1@example.com', 'user2@example.com']
```

**Anonymization rules**:
- ✅ Email: Use example.com, company.test, domain.org
- ✅ Names: Use generic placeholders (John Doe, Jane Smith)
- ✅ Phone: Use (555) xxx-xxxx format
- ✅ Hashes: Show pattern only, truncate
- ✅ IDs: Use generic numbers (1, 42, 1337)
- ✅ JSON: Remove sensitive keys before showing

---

### Step 5: Update Comments

#### Comment Format

**Standard format**: `comment='[Description]. Examples: [ex1], [ex2], [ex3]'`

**Rules**:
1. Start with clear, concise description
2. Include format/type info if needed (e.g., "UTC timestamp", "lowercase")
3. Add "Examples: " prefix before examples
4. Quote string examples with double quotes
5. Separate examples with commas
6. Keep total length under 500 characters
7. Explain NULL semantics if nullable

#### Update Modes

**Mode A: Add (only if missing)**
```python
# BEFORE
email = Column(String(255), unique=True, nullable=False)

# AFTER
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email address, login identifier. '
            'Examples: "user1@example.com", "admin@company.org"'
)
```

**Mode B: Update (replace existing)**
```python
# BEFORE
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email'  # Too generic
)

# AFTER
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email address, login identifier, stored lowercase. '
            'Examples: "user1@example.com", "admin@company.org", "jane@domain.net"'
)
```

**Mode C: Append (add examples to existing)**
```python
# BEFORE
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email address for authentication'
)

# AFTER
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email address for authentication. '
            'Examples: "user1@example.com", "admin@company.org", "jane@domain.net"'
)
```

---

### Step 6: Column-Specific Templates

#### Primary Keys

```python
id = Column(
    Integer,
    primary_key=True,
    comment='Primary key, auto-increment. Examples: 1, 42, 1337, 9999'
)

uuid = Column(
    UUID(as_uuid=True),
    primary_key=True,
    default=uuid4,
    comment='Primary key, UUID v4. '
            'Examples: "550e8400-e29b-41d4-a716-446655440000", '
            '"7c9e6679-7425-40de-944b-e07fc1f90ae7"'
)
```

#### Foreign Keys

```python
user_id = Column(
    Integer,
    ForeignKey('users.id', ondelete='CASCADE'),
    nullable=False,
    comment='FK to users.id, CASCADE delete. Examples: 1, 42, 1337, 9999'
)

category_id = Column(
    Integer,
    ForeignKey('categories.id', ondelete='SET NULL'),
    nullable=True,
    comment='FK to categories.id, NULL if category deleted. '
            'Examples: 5 (Electronics), 12 (Clothing), NULL (uncategorized)'
)
```

#### Enum Columns

```python
status = Column(
    String(20),
    nullable=False,
    comment='Order status enum. '
            'Examples: "pending" (2341 orders), "delivered" (45123), "cancelled" (892)'
)

role = Column(
    Enum('admin', 'moderator', 'user', 'guest', name='user_role'),
    nullable=False,
    default='user',
    comment='User role for permissions. '
            'Examples: "admin" (12 users), "moderator" (45), "user" (849234)'
)
```

#### Timestamps

```python
created_at = Column(
    DateTime,
    default=func.now(),
    nullable=False,
    comment='Record creation timestamp (UTC). '
            'Examples: "2024-03-15 14:30:00", "2024-03-14 09:15:22", "2024-03-10 08:00:00"'
)

expires_at = Column(
    DateTime,
    nullable=True,
    comment='Expiration timestamp (UTC), NULL = never expires. '
            'Examples: "2024-12-31 23:59:59" (expires), NULL (permanent)'
)
```

#### Nullable vs NOT NULL

```python
# NOT NULL - explain default or validation
username = Column(
    String(50),
    nullable=False,
    comment='Display name, required, 3-50 chars. '
            'Examples: "johndoe", "jane_smith", "tech_admin"'
)

# NULLABLE - explain NULL semantics
phone_number = Column(
    String(20),
    nullable=True,
    comment='Phone number, optional, NULL if not provided. '
            'Examples: "+1-555-0123", "+44-20-1234-5678", NULL'
)
```

---

### Step 7: Generate Output

**Output format**: Show changes per model

```markdown
## Updated Model: User (users table)

### Changes:

**Added comments (5 columns)**:
- `id`: Primary key, auto-increment. Examples: 1, 42, 1337, 9999
- `is_active`: Account active status. Examples: true (849523), false (12847)
- `deleted_at`: Soft delete timestamp, NULL = active. Examples: NULL, "2024-02-20 10:30:00"

**Updated comments (3 columns)**:
- `email`:
  - OLD: "User email"
  - NEW: "User email address, login identifier, lowercase. Examples: "user1@example.com", "admin@company.org""
- `username`:
  - OLD: "Username"
  - NEW: "Display name, unique, 3-50 chars. Examples: "johndoe", "jane_smith", "tech_admin""

---

## Updated Model: Order (orders table)

### Changes:

**Added comments (8 columns)**:
- `id`: Primary key, auto-increment. Examples: 1, 123, 9876, 55555
- `user_id`: FK to users.id, CASCADE delete. Examples: 1, 42, 1337
- `status`: Order status enum. Examples: "pending" (2341), "delivered" (45123), "cancelled" (892)
...
```

---

### Step 8: Apply Changes

**Option 1: Direct file edit**

Use Edit tool to update model files:

```python
# Before
email = Column(String(255), unique=True, nullable=False)

# After
email = Column(
    String(255),
    unique=True,
    nullable=False,
    comment='User email address, login identifier, lowercase. '
            'Examples: "user1@example.com", "admin@company.org", "jane@domain.net"'
)
```

**Option 2: Generate migration**

If models deployed, create Alembic migration:

```bash
alembic revision -m "Update model comments with real examples"
```

Edit migration file:
```python
def upgrade():
    op.execute("""
        COMMENT ON COLUMN users.email IS
        'User email address, login identifier, lowercase. Examples: "user1@example.com", "admin@company.org"';
    """)
    # ... more columns
```

Apply:
```bash
alembic upgrade head
```

---

## Validation

### Check Applied Comments

```python
from sqlalchemy import text

# Table comment
query = text("SELECT obj_description('users'::regclass, 'pg_class')")
result = session.execute(query).scalar()
print(f"Table: {result}")

# Column comments
query = text("""
    SELECT
        column_name,
        col_description('users'::regclass, ordinal_position) as comment
    FROM information_schema.columns
    WHERE table_name = 'users'
    ORDER BY ordinal_position
""")
for row in session.execute(query):
    print(f"{row.column_name}: {row.comment}")
```

### Checklist

- [ ] All targeted columns have comments
- [ ] Comments include 2-5 real examples
- [ ] Sensitive data anonymized
- [ ] Format consistent across all columns
- [ ] NULL semantics explained for nullable columns
- [ ] Foreign keys reference target table
- [ ] Enum columns show possible values
- [ ] Boolean columns show distribution (if relevant)
- [ ] No code logic changed
- [ ] No column types changed
- [ ] No relationships modified

---

## Common Issues

### Issue 1: No Database Access

**Solution**: Generate realistic synthetic examples

```python
# String columns
email_examples = ['user1@example.com', 'user2@company.test', 'admin@domain.org']

# Numeric columns
price_examples = ['19.99', '149.50', '2499.00', '0.99']

# Boolean
boolean_examples = 'true, false'

# DateTime
datetime_examples = [
    datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
    (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d %H:%M:%S')
]
```

### Issue 2: Comments Too Long

**Solution**: Prioritize most important info

```python
# ❌ Too long (>500 chars)
comment = "This is the user email address which is used for authentication ..."

# ✅ Concise (<200 chars)
comment = "User email, login identifier. Examples: \"user1@example.com\", \"admin@company.org\""
```

### Issue 3: Ambiguous Nullability

**Solution**: Always explain NULL semantics

```python
# ❌ Ambiguous
comment = "Phone number. Examples: \"+1-555-0123\""

# ✅ Clear
comment = "Phone number, optional, NULL if not provided. Examples: \"+1-555-0123\", NULL"
```

---

## Success Criteria

**Comments are complete when**:

1. ✅ All columns have inline comments
2. ✅ Comments include 2-5 real examples from database
3. ✅ Format is consistent: "Description. Examples: ex1, ex2, ex3"
4. ✅ Sensitive data anonymized
5. ✅ NULL semantics explained for nullable columns
6. ✅ Foreign keys reference target table
7. ✅ No code logic modified
8. ✅ pgModeler can generate useful HTML dictionary
9. ✅ Comments are maintainable (concise, accurate)

---

## Next Steps

1. **Review changes**: Verify no code logic modified
2. **Generate migration**: If needed for deployed models
3. **Test pgModeler export**: Verify comments appear in HTML
4. **Commit changes**:
   ```bash
   git add models/
   git commit -m "docs(models): update column comments with real database examples"
   ```
5. **Schedule refresh**: Plan to update examples quarterly or after major data changes

---

**Philosophy**: Comments are documentation for future developers. Keep them accurate, concise, and evidence-based. Refresh regularly to reflect actual data patterns.
