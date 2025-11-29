# Daniel Ginês Python Documentation Preferences

> **Context**: Conventions for web scraping (Scrapy), database projects (SQLAlchemy/Alembic), and infrastructure automation.
> **Author**: Daniel Ginês
> **Last Updated**: 2025-01-29

---

## Docstring Style

**Selected**: Google Style Guide

**Rationale**: Most readable for DevOps/infrastructure code. Clear section separation makes it easy to scan for Args/Returns/Raises.

---

## Framework-Specific Conventions

### Scrapy

**All spiders must document**:

```python
class ProductSpider(scrapy.Spider):
    """[Website name] product data scraper.

    Target: https://example.com/products
    Rate Limit: 1 request/2 seconds (respectful crawling)

    Extracts:
        Product Data:
            - name: Product title (str)
            - price: Price in USD (Decimal, parsed from "$XX.XX")
            - sku: Stock keeping unit (str)
            - availability: In stock status (bool)

        Images:
            - primary_image: Main product image URL (str)
            - gallery: List of additional image URLs (list[str])

        Optional:
            - reviews_count: Number of reviews (int, 0 if not available)
            - rating: Average rating 1-5 (float, None if not available)

    Configuration:
        DOWNLOAD_DELAY = 2  # Respectful crawling
        CONCURRENT_REQUESTS = 1  # Single-threaded for small sites
        ROBOTSTXT_OBEY = True
        USER_AGENT = 'MyBot/1.0 (+https://mywebsite.com/bot)'

    Usage:
        scrapy crawl product_spider -o products.jsonl -t jsonlines

    Notes:
        - Implements exponential backoff for rate limiting (429 responses)
        - Handles pagination via 'next' link extraction
        - Skips out-of-stock items (configurable via spider arg)
        - Respects site's robots.txt and crawl-delay directives

    Dependencies:
        - price-parser: For price extraction from various formats
        - scrapy-user-agents: For rotating user agents

    Author: Daniel Ginês
    Last Updated: 2024-01-15
    """
```

**Spider methods**:
```python
def parse_product(self, response):
    """Extract product data from product detail page.

    Args:
        response: Scrapy response object from product page.

    Yields:
        dict: Product data matching schema in class docstring.

    Note:
        Handles missing fields gracefully (returns None for optionals).
        Validates price format before yielding item.
    """
```

**Item pipelines**:
```python
class ValidationPipeline:
    """Validate scraped items before storage.

    Ensures required fields are present and data types are correct.
    Drops invalid items with detailed logging.

    Configuration:
        ITEM_PIPELINES = {'pipelines.ValidationPipeline': 300}

    Validation Rules:
        - 'name': Required, non-empty string
        - 'price': Required, positive Decimal
        - 'sku': Required, alphanumeric string
        - 'url': Required, valid HTTP/HTTPS URL
    """

    def process_item(self, item, spider):
        """Validate item fields and data types.

        Args:
            item: Scraped item dictionary.
            spider: Spider instance that generated item.

        Returns:
            Validated item if all checks pass.

        Raises:
            DropItem: If validation fails with reason in exception message.
        """
```

---

### SQLAlchemy

**Model docstrings**:

```python
class User(Base):
    """User account model for authentication and profile management.

    Relationships:
        - orders: One-to-many with Order (backref='customer')
        - profile: One-to-one with UserProfile (backref='user')
        - roles: Many-to-many with Role through user_roles association table

    Indexes:
        - email: Unique index for fast login lookups
        - created_at: B-tree index for date-range queries
        - (email, is_active): Composite index for admin user lists

    Constraints:
        - email: Unique, not null
        - username: Unique, not null, 3-50 chars
        - password_hash: Not null (never store plaintext)

    Triggers:
        - updated_at: Automatically set on UPDATE via onupdate=func.now()

    Migration History:
        - ae3f891 (2024-01-15): Added phone_number field
        - b4c2d3e (2024-02-01): Added soft delete (deleted_at field)

    Notes:
        - Passwords hashed with bcrypt (cost factor 12)
        - Email stored lowercase for case-insensitive matching
        - Soft delete via deleted_at (NULL = active user)

    Example:
        >>> user = User(
        ...     email='user@example.com',
        ...     username='johndoe',
        ...     password_hash=hash_password('secret')
        ... )
        >>> session.add(user)
        >>> session.commit()
    """
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False, index=True)  # Login identifier
    username = Column(String(50), unique=True, nullable=False)  # Display name
    password_hash = Column(String(255), nullable=False)  # Bcrypt hash (never plaintext)
    is_active = Column(Boolean, default=True, nullable=False)  # Account status
    created_at = Column(DateTime, default=func.now(), nullable=False)  # UTC timestamp
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())  # Auto-updated
    deleted_at = Column(DateTime, nullable=True)  # Soft delete: NULL = active
```

**Repository pattern methods**:
```python
class UserRepository:
    """Database repository for User model operations.

    Provides high-level CRUD operations with caching and query optimization.
    Thread-safe for concurrent access in web applications.

    Attributes:
        session: SQLAlchemy database session (scoped for thread safety)
        cache: Redis client for query result caching (optional)
    """

    def get_by_email(self, email: str) -> Optional[User]:
        """Retrieve user by email address.

        Email comparison is case-insensitive (stored as lowercase).

        Args:
            email: User's email address.

        Returns:
            User object if found, None otherwise.

        Note:
            Excludes soft-deleted users (deleted_at IS NOT NULL).
            Result cached for 5 minutes in Redis if cache enabled.
        """

    def create_with_password(self, email: str, username: str, password: str) -> User:
        """Create new user with hashed password.

        Args:
            email: User's email address (will be lowercased).
            username: Desired username (3-50 chars).
            password: Plaintext password (will be hashed with bcrypt).

        Returns:
            Created and persisted User object.

        Raises:
            ValueError: If email/username already exists.
            ValidationError: If password doesn't meet complexity requirements.

        Note:
            Automatically commits to database.
            Sends welcome email if EMAIL_ENABLED=True in config.
        """
```

---

### Alembic Migrations

**Migration docstrings**:

```python
"""Add user phone verification system

Revision ID: ae3f891b2c45
Revises: 1d2e3f4a5b6c
Create Date: 2024-01-15 10:23:45.123456

Changes:
    users table:
        - Add phone_number column (VARCHAR(20), nullable)
        - Add phone_verified column (BOOLEAN, default False)
        - Add phone_verification_sent_at column (TIMESTAMP, nullable)

    New tables:
        - phone_verifications: Stores OTP codes and verification attempts
            - id (Primary Key)
            - user_id (Foreign Key to users.id)
            - code (6-digit OTP)
            - expires_at (TIMESTAMP)
            - attempts (INTEGER, max 3)
            - verified (BOOLEAN)

    Indexes:
        - phone_verifications.user_id (for lookup by user)
        - phone_verifications.expires_at (for cleanup job)

Deployment Steps:
    1. Run migration during maintenance window (low traffic period)
    2. Verify migration success: SELECT COUNT(*) FROM phone_verifications
    3. Populate phone_number from legacy CRM system (separate script)
    4. Enable phone verification feature flag in config
    5. Monitor error rates for 24 hours

Data Migration:
    - Existing users: phone_number defaults to NULL
    - phone_verified defaults to False for all users
    - Users must verify phone on next login or profile update

Rollback:
    - Safe to rollback: No data loss (phone_number nullable)
    - Command: alembic downgrade -1
    - Cleanup: Delete phone_verifications table manually if needed

Dependencies:
    - Requires Twilio credentials in environment (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    - Redis for OTP storage (fallback to database if Redis unavailable)

Testing:
    - Tested on staging with 10k user sample
    - Performance impact: <5ms per user lookup
    - Verified foreign key constraints and cascading deletes

Author: Daniel Ginês
Jira: PROJ-1234
"""

from alembic import op
import sqlalchemy as sa

# Revision identifiers
revision = 'ae3f891b2c45'
down_revision = '1d2e3f4a5b6c'
branch_labels = None
depends_on = None


def upgrade():
    """Apply migration: add phone verification system."""
    # Add columns to users table
    op.add_column('users', sa.Column('phone_number', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('phone_verified', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('users', sa.Column('phone_verification_sent_at', sa.DateTime(), nullable=True))

    # Create phone_verifications table
    op.create_table(
        'phone_verifications',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('code', sa.String(6), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('attempts', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('verified', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )

    # Create indexes
    op.create_index('ix_phone_verifications_user_id', 'phone_verifications', ['user_id'])
    op.create_index('ix_phone_verifications_expires_at', 'phone_verifications', ['expires_at'])


def downgrade():
    """Rollback migration: remove phone verification system."""
    # Drop indexes
    op.drop_index('ix_phone_verifications_expires_at', 'phone_verifications')
    op.drop_index('ix_phone_verifications_user_id', 'phone_verifications')

    # Drop table
    op.drop_table('phone_verifications')

    # Remove columns from users
    op.drop_column('users', 'phone_verification_sent_at')
    op.drop_column('users', 'phone_verified')
    op.drop_column('users', 'phone_number')
```

---

## Type Hints Policy

- ✅ **Always use type hints** on public functions/methods
- ✅ Use modern Python 3.10+ syntax: `list[str]` not `List[str]`
- ✅ Import from `typing` only for: `Optional`, `Union`, `Protocol`, `TypedDict`
- ✅ Use `Any` sparingly (document why type cannot be determined)
- ✅ Async functions: use `async def` + `Awaitable` return type if complex

**Example**:
```python
from typing import Optional
from decimal import Decimal

def calculate_discount(
    base_price: Decimal,
    discount_percent: float,
    customer_tier: Optional[str] = None
) -> Decimal:
    """Calculate discounted price with optional tier bonus."""
```

---

## Comment Style

### Inline Comments

- Maximum line length: **88 characters** (Black formatter compatible)
- Use `#` with single space: `# comment`
- Prefer above-line comments for clarity

### Magic Numbers

**Always explain constants**:
```python
TIMEOUT_SECONDS = 300  # 5 minutes: AWS Lambda max execution time
RETRY_ATTEMPTS = 3  # Balance between reliability and user patience
BATCH_SIZE = 1000  # Optimal for PostgreSQL bulk inserts (tested)
CACHE_TTL = 3600  # 1 hour: balance freshness vs database load
```

### Database-Specific Comments

```python
# UTC timestamp: avoid DST issues in multi-timezone deployments
created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

# Composite index: critical for admin dashboard user filtering
# Covers queries: WHERE email = X AND is_active = True
__table_args__ = (Index('ix_email_active', 'email', 'is_active'),)
```

---

## TODO/FIXME Format

**Required format**:
```python
# TODO(daniel, 2024-02-15): Add connection pooling when traffic >1000 req/s
# FIXME(daniel): Race condition in concurrent cart updates - use Redis locks
# HACK(daniel): Library missing async support, remove when v3.0 released
# NOTE(daniel): Intentionally slow query for historical data (acceptable 5s latency)
```

---

## Module-Level Docstrings

**Must include**:
- Purpose and scope
- Main classes/functions
- Usage example
- Dependencies (if non-standard)

**Example**:
```python
"""Database connection and session management.

Provides SQLAlchemy engine configuration, connection pooling,
and scoped session management for web application.

Classes:
    Database: Main database manager with connection pooling

Functions:
    get_session: Retrieve thread-local database session
    init_db: Initialize database schema

Example:
    >>> from database import get_session, User
    >>> with get_session() as session:
    ...     user = session.query(User).filter_by(email='test@example.com').first()

Dependencies:
    - SQLAlchemy >=2.0
    - psycopg2-binary (PostgreSQL driver)
    - alembic (migrations)

Configuration:
    Requires DATABASE_URL environment variable:
    postgresql://user:pass@localhost:5432/dbname

Author: Daniel Ginês
"""
```

---

## Custom Rules

### Environment Variables

Document in module docstring:
```python
"""
Required Environment Variables:
    DATABASE_URL: PostgreSQL connection string
    REDIS_URL: Redis connection string (optional, disables caching if missing)
    TWILIO_ACCOUNT_SID: Twilio account ID (for SMS)
    SECRET_KEY: Flask/Django secret key (generate with secrets.token_hex(32))
"""
```

### Credentials

```python
# NEVER hardcode credentials
# ❌ api_key = "sk_live_123456789"

# ✅ Load from environment
api_key = os.getenv('API_KEY')
if not api_key:
    raise ValueError("API_KEY environment variable required")
```

### File Paths

```python
from pathlib import Path

# Use pathlib for cross-platform compatibility
PROJECT_ROOT = Path(__file__).parent.parent
CONFIG_FILE = PROJECT_ROOT / 'config' / 'settings.yaml'  # Not 'config/settings.yaml'
```

### Logging

```python
import logging

logger = logging.getLogger(__name__)

def process_payment(amount: Decimal) -> bool:
    """Process payment transaction.

    Logs:
        INFO: Successful payment processing
        WARNING: Retry attempts on failure
        ERROR: Payment failure with details
    """
    logger.info(f"Processing payment: ${amount}")
    # ...
```

---

## Quality Standards

- ✅ All public APIs have docstrings with Args/Returns/Raises
- ✅ All SQLAlchemy models document relationships and indexes
- ✅ All Alembic migrations have deployment instructions
- ✅ All Scrapy spiders document extraction schema and rate limits
- ✅ Complex functions (>10 lines) have usage examples
- ✅ Magic numbers explained with comments
- ✅ Environment variables documented in module docstring

---

**Philosophy**: Infrastructure code is read more often than written. Optimize for clarity and operational safety over brevity.
