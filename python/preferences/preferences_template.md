# Python Documentation Preferences Template

> **Instructions**: Copy this file and customize for your needs.
> Append to base prompts (`Code_Documentation_Instructions.md`) for personalized behavior.

---

## Docstring Style Preference

**Selected style**: [Google Style / NumPy Style / Sphinx reStructuredText]

**Rationale**: [Explain why you chose this style for your projects]

---

## Framework-Specific Conventions

### Django

**Views**:
- [ ] Document HTTP methods supported
- [ ] List required permissions
- [ ] Document query parameters
- [ ] Include example request/response

**Models**:
- [ ] Document model purpose
- [ ] List key relationships (Foreign Keys, Many-to-Many)
- [ ] Document important constraints
- [ ] Note indexes for performance

**Example**:
```python
class Article(models.Model):
    """Blog article model.

    Relationships:
        - author: ForeignKey to User
        - tags: ManyToMany with Tag
        - comments: Reverse relation from Comment

    Indexes:
        - published_date (for chronological queries)
        - slug (unique, for URL lookups)
    """
```

### Flask / FastAPI

**Routes**:
- [ ] Document endpoint purpose
- [ ] List all query/path parameters
- [ ] Document request body schema
- [ ] Document response schema
- [ ] List possible status codes

**Example**:
```python
@app.post("/users")
async def create_user(user: UserCreate) -> UserResponse:
    """Create new user account.

    Args:
        user: User creation data with email and password.

    Returns:
        Created user object with generated ID.

    Raises:
        HTTPException 400: If email already exists.
        HTTPException 422: If validation fails.

    Status Codes:
        201: User created successfully
        400: Email already registered
        422: Validation error
    """
```

### Scrapy

**Spiders**:
- [ ] Document target website
- [ ] List data schema extracted
- [ ] Document rate limiting settings
- [ ] Provide usage example

**Example**:
```python
class ProductSpider(scrapy.Spider):
    """Scrape product data from example.com.

    Target: https://example.com/products

    Extracts:
        - name: Product name (str)
        - price: Price in USD (Decimal)
        - sku: Stock keeping unit (str)
        - availability: In stock status (bool)

    Settings:
        DOWNLOAD_DELAY = 2
        CONCURRENT_REQUESTS = 1
        ROBOTSTXT_OBEY = True

    Usage:
        scrapy crawl product_spider -o products.jsonl
    """
```

### SQLAlchemy

**Models**:
- [ ] Document table purpose
- [ ] List relationships with cardinality
- [ ] Document important indexes
- [ ] Note migration history for complex changes

**Example**:
```python
class Order(Base):
    """Customer order model.

    Relationships:
        - customer: Many-to-one with User
        - items: One-to-many with OrderItem
        - payment: One-to-one with Payment

    Indexes:
        - customer_id, created_at (composite, for user order history)
        - status (for filtering pending/completed orders)

    Notes:
        Added payment_method column in migration ae3f891 (2024-01-15).
    """
```

### Alembic

**Migrations**:
- [ ] Document what changed
- [ ] List deployment steps if complex
- [ ] Note data migrations if needed
- [ ] Reference related migrations

**Example**:
```python
"""Add user email verification

Revision ID: 1234567890ab
Revises: abcdef123456
Create Date: 2024-01-15 10:30:00

Changes:
    - Add email_verified column to users table
    - Add verification_token column
    - Create email_verifications table for audit trail

Deployment:
    1. Run migration during maintenance window
    2. Send verification emails to existing users
    3. Enable email verification feature flag

Data Migration:
    Existing users: email_verified defaults to False
    Must verify email on next login
"""
```

### Pandas / NumPy (Data Science)

**Functions**:
- [ ] Document input DataFrame shape/columns
- [ ] Document output DataFrame structure
- [ ] Note data type transformations
- [ ] Provide example with sample data

**Example**:
```python
def clean_sales_data(df: pd.DataFrame) -> pd.DataFrame:
    """Clean and prepare sales data for analysis.

    Removes duplicates, handles missing values, and converts
    data types for downstream processing.

    Parameters
    ----------
    df : pd.DataFrame
        Raw sales data with columns:
        - date: str (YYYY-MM-DD format)
        - amount: str (with currency symbols)
        - customer_id: int or str

    Returns
    -------
    pd.DataFrame
        Cleaned data with columns:
        - date: datetime64
        - amount: float64
        - customer_id: int64

    Notes
    -----
    Drops rows where amount is negative (refunds handled separately).
    Missing customer_id filled with -1 (guest purchases).

    Examples
    --------
    >>> raw_df = pd.DataFrame({
    ...     'date': ['2024-01-01', '2024-01-02'],
    ...     'amount': ['$10.50', '$25.00'],
    ...     'customer_id': [123, 456]
    ... })
    >>> clean_df = clean_sales_data(raw_df)
    >>> clean_df.dtypes
    date           datetime64[ns]
    amount         float64
    customer_id    int64
    """
```

---

## Type Hints Policy

- [ ] **Always use type hints** (required for all public functions)
- [ ] Use modern syntax (Python 3.10+): `list[str]` instead of `List[str]`
- [ ] Import from `typing` for complex types: `Optional`, `Union`, `Callable`
- [ ] Use `Any` sparingly (only when truly type-agnostic)
- [ ] Document type hints in docstring only if non-obvious

**Example**:
```python
from typing import Optional, Protocol
from collections.abc import Callable

def process_items(
    items: list[dict[str, any]],
    filter_fn: Optional[Callable[[dict], bool]] = None
) -> list[dict[str, any]]:
    """Process items with optional filtering.

    Args:
        items: List of item dictionaries.
        filter_fn: Optional predicate to filter items.
            Should return True to keep item.
    """
```

---

## Comment Style

### Inline Comments

- [ ] Use `#` with single space: `# comment`
- [ ] Prefer above-line comments for multi-line explanations
- [ ] Maximum line length: [72 / 79 / 88 / 100] (choose one)

### Block Comments

- [ ] Use triple quotes for large explanations
- [ ] Place before function/class definition (or use docstring)

### Magic Numbers

- [ ] Always explain non-obvious constants:
  ```python
  TIMEOUT_SECONDS = 300  # 5 minutes: AWS Lambda max execution
  BATCH_SIZE = 1000  # Optimal for PostgreSQL bulk inserts
  ```

---

## TODO/FIXME/HACK Format

**Required format**:

```python
# TODO(author, YYYY-MM-DD): Description of future work
# FIXME(author): Description of bug to fix
# HACK(author): Temporary workaround explanation
# NOTE(author): Important context that isn't obvious
```

**Example**:
```python
# TODO(daniel, 2024-02-01): Add caching layer when Redis deployed
def fetch_user_data(user_id):
    pass

# FIXME(team): Race condition in concurrent updates
# Temporary mitigation: added random delay
time.sleep(random.uniform(0.1, 0.3))

# HACK(daniel): Library doesn't support async yet
# Remove when v3.0 released (Q2 2024)
result = await asyncio.to_thread(sync_function)
```

---

## Module-Level Docstrings

**Must include**:

- [ ] One-line summary
- [ ] Detailed description (if module is complex)
- [ ] List of main classes/functions (optional, for large modules)
- [ ] Author/maintainer (optional)
- [ ] Example usage (for public API modules)
- [ ] Version/date (optional)

**Example**:
```python
"""User authentication and authorization module.

Provides JWT-based authentication, role-based access control,
and session management. Integrates with OAuth2 providers.

Classes:
    User: User account model
    Session: Session manager

Functions:
    authenticate: Validate credentials
    verify_token: Validate JWT token

Example:
    >>> from auth import authenticate
    >>> token = authenticate('user@example.com', 'password')

Author: Your Name <your.email@example.com>
Version: 2.1.0
"""
```

---

## Testing Documentation

### Test Function Docstrings

- [ ] Document what is being tested (not how)
- [ ] Explain test scenario
- [ ] Note edge cases covered

**Example**:
```python
def test_user_registration_with_duplicate_email():
    """Verify registration fails gracefully with duplicate email.

    Tests that:
    1. Second registration attempt returns 400 error
    2. Error message identifies email as duplicate
    3. No partial user record created in database
    """
```

### Fixtures

- [ ] Document fixture purpose
- [ ] List what fixtures provides
- [ ] Note cleanup behavior

---

## Async Functions

- [ ] Always document async requirements
- [ ] Note event loop requirements
- [ ] Show example with `await`

**Example**:
```python
async def fetch_data(url: str) -> dict:
    """Fetch data asynchronously from URL.

    Args:
        url: Target URL.

    Returns:
        Parsed JSON response.

    Note:
        Requires active asyncio event loop.
        Use with await: `data = await fetch_data(url)`
    """
```

---

## Custom Rules

[Add any additional preferences specific to your workflow]

**Examples**:

- Database connection strings: Document environment variables in module docstring
- API keys: Reference config file location in docstring
- Credentials: Never in code, document `.env` usage
- File paths: Use `pathlib.Path`, document expected structure
- Logging: Document log levels for each function

---

## Exclusions

**Do NOT document** (unless complex):

- [ ] Simple getters/setters
- [ ] Obvious property methods
- [ ] Private helpers (single underscore) in strict mode
- [ ] Test fixtures (unless complex setup)

**Example** (no docstring needed):
```python
@property
def email(self) -> str:
    return self._email

@email.setter
def email(self, value: str) -> None:
    self._email = value
```

---

## Quality Standards

- [ ] All public APIs must have docstrings
- [ ] All docstrings must have summary line
- [ ] Complex functions (>10 lines) must have examples
- [ ] All exceptions must be documented
- [ ] Type hints must be present on public functions

---

**Last Updated**: [YYYY-MM-DD]
**Author**: [Your Name]
**Context**: [Brief description of when to use these preferences]
