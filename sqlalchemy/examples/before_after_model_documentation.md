# SQLAlchemy Model Documentation — Before & After Examples

> **Purpose**: Practical examples showing transformation from minimal/missing documentation to comprehensive, professional model documentation with real database examples.

---

## Table of Contents

1. [Example 1: Minimal Model → Fully Documented](#example-1-minimal-model--fully-documented)
2. [Example 2: Basic Comments → Professional with Real Data](#example-2-basic-comments--professional-with-real-data)
3. [Example 3: Complex Model with Relationships](#example-3-complex-model-with-relationships)
4. [Example 4: Adding pgModeler-Compatible Comments](#example-4-adding-pgmodeler-compatible-comments)

---

## Example 1: Minimal Model → Fully Documented

### BEFORE: Minimal Documentation

```python
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False)
    username = Column(String(50), nullable=False)
    password_hash = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
```

**Problems**:
- No class docstring
- No column comments
- No examples
- No relationship documentation
- No index documentation
- Missing table comment
- No migration history

---

### AFTER: Comprehensive Documentation

```python
from sqlalchemy import Column, Integer, String, Boolean, DateTime, func, Index
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class User(Base):
    """User account model for authentication and profile management.

    Stores user credentials, profile information, and account status.
    Central table for authentication system with relationships to orders
    and user profiles.

    Relationships:
        - orders: One-to-many with Order (backref='customer')
          Cascade: delete-orphan (orders deleted when user deleted)
          Typical: 0-50 orders per user, average 3.2
        - profile: One-to-one with UserProfile (backref='user')
          Optional: user can exist without profile

    Indexes:
        - email: Unique B-tree index for login queries
          Query: SELECT * FROM users WHERE email = ?
          Performance: <10ms average, 99th percentile <50ms
        - created_at: B-tree index for date-range reports
          Query: SELECT * FROM users WHERE created_at BETWEEN ? AND ?

    Constraints:
        - email: UNIQUE NOT NULL (login identifier)
        - username: UNIQUE NOT NULL, 3-50 chars
        - password_hash: NOT NULL, bcrypt format (never plaintext)
        - is_active: NOT NULL DEFAULT true

    Migration History:
        - 2024-01-15 (rev ae3f891): Initial table creation
        - 2024-02-01 (rev b4c2d3e): Added is_active flag for soft suspend

    Data Volume (as of 2024-03-15):
        - Total rows: ~1.2M users
        - Active users: ~850K (is_active=true)
        - Growth rate: ~10K new users/month

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
        >>> # Query by email
        >>> user = session.query(User).filter_by(email='john.doe@example.com').first()
        >>> print(f"User: {user.username}, Active: {user.is_active}")

    Security:
        - Passwords: bcrypt with cost factor 12
        - Email: Stored lowercase for case-insensitive comparison
        - Sessions: Tracked in separate sessions table

    Author: Daniel Ginês
    Last Updated: 2024-03-15
    """
    __tablename__ = 'users'
    __table_args__ = (
        Index('ix_users_email', 'email', unique=True),
        Index('ix_users_created_at', 'created_at'),
        {'comment': 'User accounts for authentication and profile management'}
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
        index=True,
        comment='User email address (login identifier), stored lowercase. '
                'Examples: "john.doe@example.com", "jane.smith@company.org", '
                '"admin@example.net"'
    )

    username = Column(
        String(50),
        unique=True,
        nullable=False,
        comment='Display name, unique across system, 3-50 chars. '
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
                'Examples: true (849523 users), false (12847 users)'
    )

    created_at = Column(
        DateTime,
        default=func.now(),
        nullable=False,
        comment='Account creation timestamp (UTC). '
                'Examples: "2024-01-15 14:30:00", "2024-03-10 09:15:22", '
                '"2024-03-12 16:45:33"'
    )

    updated_at = Column(
        DateTime,
        default=func.now(),
        onupdate=func.now(),
        comment='Last modification timestamp (UTC), auto-updated. '
                'Examples: "2024-01-15 14:30:00", "2024-03-12 16:45:33"'
    )

    # Relationships
    orders = relationship(
        'Order',
        back_populates='customer',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )

    profile = relationship(
        'UserProfile',
        back_populates='user',
        uselist=False,
        cascade='all, delete-orphan'
    )
```

**Improvements**:
- ✅ Comprehensive class docstring with all sections
- ✅ All columns have comments with real examples
- ✅ Relationships documented
- ✅ Indexes with query patterns
- ✅ Constraints documented
- ✅ Migration history
- ✅ Usage examples
- ✅ Security notes
- ✅ Table comment for pgModeler

---

## Example 2: Basic Comments → Professional with Real Data

### BEFORE: Generic Comments

```python
from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, Enum
from sqlalchemy.orm import declarative_base
import enum

Base = declarative_base()

class OrderStatus(enum.Enum):
    PENDING = 'pending'
    SHIPPED = 'shipped'
    DELIVERED = 'delivered'

class Order(Base):
    """Order model"""
    __tablename__ = 'orders'

    id = Column(Integer, primary_key=True, comment='Order ID')
    user_id = Column(Integer, ForeignKey('users.id'), comment='User ID')
    status = Column(Enum(OrderStatus), comment='Status')
    total_amount = Column(Numeric(10, 2), comment='Total amount')
```

**Problems**:
- Generic comments ("Order ID", "User ID")
- No real examples
- Missing FK details (ondelete behavior)
- No status distribution
- No relationship documentation

---

### AFTER: Professional Documentation with Real Data

```python
from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, Enum, DateTime, func, Index
from sqlalchemy.orm import declarative_base, relationship
import enum

Base = declarative_base()


class OrderStatus(enum.Enum):
    """Order status lifecycle enum."""
    PENDING = 'pending'
    PROCESSING = 'processing'
    SHIPPED = 'shipped'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'


class Order(Base):
    """Customer order model for e-commerce transactions.

    Tracks order lifecycle from creation to delivery. Each order belongs
    to a user and contains multiple order items.

    Relationships:
        - customer: Many-to-one with User (backref='orders')
          ondelete: CASCADE (delete orders when user deleted)
        - items: One-to-many with OrderItem (backref='order')
          Cascade: delete-orphan (items deleted with order)
          Typical: 1-10 items per order, average 2.7

    Indexes:
        - (user_id, created_at): Composite index for user order history
          Query: SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC
          Performance: <20ms for 10K orders per user
        - status: B-tree index for filtering by status
          Query: SELECT * FROM orders WHERE status = ?

    Constraints:
        - user_id: NOT NULL, FK to users.id with CASCADE delete
        - status: NOT NULL, enum values only
        - total_amount: NOT NULL, positive values only (CHECK constraint)

    Business Rules:
        - Total calculated from sum of order_items.subtotal
        - Status transitions: pending → processing → shipped → delivered
        - Cannot change status from delivered/cancelled

    Data Volume (as of 2024-03-15):
        - Total rows: ~5.2M orders
        - Orders per day: ~15K average
        - Status distribution: see status column comment

    Example:
        >>> # Create order with items
        >>> order = Order(
        ...     user_id=42,
        ...     status=OrderStatus.PENDING,
        ...     total_amount=Decimal('149.98')
        ... )
        >>> session.add(order)
        >>> session.commit()
        >>>
        >>> # Update status
        >>> order.status = OrderStatus.SHIPPED
        >>> session.commit()

    Author: Daniel Ginês
    Last Updated: 2024-03-15
    """
    __tablename__ = 'orders'
    __table_args__ = (
        Index('ix_orders_user_date', 'user_id', 'created_at'),
        Index('ix_orders_status', 'status'),
        {'comment': 'Customer orders with status tracking and totals'}
    )

    id = Column(
        Integer,
        primary_key=True,
        comment='Primary key, auto-increment. Examples: 1, 123, 9876, 55555'
    )

    user_id = Column(
        Integer,
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        index=True,
        comment='FK to users.id, CASCADE delete (remove orders when user deleted). '
                'Examples: 1, 42, 1337, 9999'
    )

    status = Column(
        Enum(OrderStatus, name='order_status'),
        nullable=False,
        default=OrderStatus.PENDING,
        comment='Order status enum, tracks lifecycle. '
                'Examples: "pending" (2341 orders), "processing" (1567), '
                '"shipped" (3421), "delivered" (45123), "cancelled" (892)'
    )

    total_amount = Column(
        Numeric(10, 2),
        nullable=False,
        comment='Order total in USD, sum of item subtotals, 2 decimal places. '
                'Examples: 19.99, 149.98, 2499.00, 0.99, 89.95'
    )

    created_at = Column(
        DateTime,
        default=func.now(),
        nullable=False,
        comment='Order creation timestamp (UTC). '
                'Examples: "2024-03-15 14:30:00", "2024-03-14 09:15:22", '
                '"2024-03-10 08:00:00"'
    )

    updated_at = Column(
        DateTime,
        default=func.now(),
        onupdate=func.now(),
        comment='Last status update timestamp (UTC), auto-updated. '
                'Examples: "2024-03-15 14:30:00", "2024-03-16 10:20:15"'
    )

    # Relationships
    customer = relationship('User', back_populates='orders')
    items = relationship(
        'OrderItem',
        back_populates='order',
        cascade='all, delete-orphan'
    )
```

**Improvements**:
- ✅ Real examples from database queries
- ✅ Status distribution (from actual data)
- ✅ Foreign key with explicit CASCADE
- ✅ Composite index with query pattern
- ✅ Business rules documented
- ✅ Usage examples
- ✅ Relationship details

---

## Example 3: Complex Model with Relationships

### BEFORE: Missing Relationship Documentation

```python
from sqlalchemy import Column, Integer, String, Text, JSONB, ARRAY, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB, ARRAY
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()

class Product(Base):
    __tablename__ = 'products'

    id = Column(Integer, primary_key=True)
    name = Column(String(200))
    description = Column(Text)
    price = Column(Numeric(10, 2))
    category_id = Column(Integer, ForeignKey('categories.id'))
    metadata = Column(JSONB)
    tags = Column(ARRAY(String))

    category = relationship('Category', back_populates='products')
```

**Problems**:
- No documentation of JSON structure
- No array examples
- No relationship details
- No nullable semantics

---

### AFTER: Comprehensive PostgreSQL-Specific Documentation

```python
from sqlalchemy import Column, Integer, String, Text, Numeric, ForeignKey, DateTime, func, Index
from sqlalchemy.dialects.postgresql import JSONB, ARRAY
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class Product(Base):
    """Product catalog model with metadata and categorization.

    Stores product information including pricing, descriptions, metadata,
    and search tags. Uses PostgreSQL-specific types (JSONB, ARRAY) for
    flexible data storage.

    Relationships:
        - category: Many-to-one with Category (backref='products')
          Optional: product can have NULL category (uncategorized)
          ondelete: SET NULL (preserve product if category deleted)
        - order_items: One-to-many with OrderItem (backref='product')
          Used for: Order history and sales tracking
          Cascade: None (preserve order history if product deleted)

    Indexes:
        - name: B-tree index for name search
          Query: SELECT * FROM products WHERE name ILIKE ?
        - tags: GIN index for array contains queries
          Query: SELECT * FROM products WHERE tags @> ARRAY[?]
        - metadata: GIN index for JSONB queries
          Query: SELECT * FROM products WHERE metadata @> ?

    PostgreSQL Features:
        - JSONB: Flexible metadata storage with indexing
        - ARRAY: Multiple tags per product
        - GIN indexes: Fast text and array searches

    Data Volume (as of 2024-03-15):
        - Total rows: ~45K products
        - Active products: ~38K (not deleted)
        - Average tags per product: 4.2
        - Growth: ~500 new products/month

    Example:
        >>> # Create product with metadata and tags
        >>> product = Product(
        ...     name='Wireless Headphones',
        ...     description='High-quality Bluetooth headphones...',
        ...     price=Decimal('149.99'),
        ...     category_id=5,
        ...     metadata={'brand': 'TechCo', 'warranty': '2 years'},
        ...     tags=['electronics', 'audio', 'wireless']
        ... )
        >>> session.add(product)
        >>> session.commit()
        >>>
        >>> # Query by tags (GIN index)
        >>> products = session.query(Product).filter(
        ...     Product.tags.contains(['wireless'])
        ... ).all()

    Author: Daniel Ginês
    Last Updated: 2024-03-15
    """
    __tablename__ = 'products'
    __table_args__ = (
        Index('ix_products_name', 'name'),
        Index('ix_products_tags', 'tags', postgresql_using='gin'),
        Index('ix_products_metadata', 'metadata', postgresql_using='gin'),
        {'comment': 'Product catalog with metadata and category relationships'}
    )

    id = Column(
        Integer,
        primary_key=True,
        comment='Primary key, auto-increment. Examples: 1, 123, 4567, 9999'
    )

    name = Column(
        String(200),
        nullable=False,
        comment='Product name for display and search, 1-200 chars. '
                'Examples: "Wireless Headphones", "USB-C Cable 6ft", '
                '"Laptop Stand Aluminum"'
    )

    description = Column(
        Text,
        nullable=True,
        comment='Product description, Markdown format, 50-5000 chars, NULL if not set. '
                'Examples: "High-quality **wireless** headphones with...", '
                '"Professional laptop stand made of...", NULL'
    )

    price = Column(
        Numeric(10, 2),
        nullable=False,
        comment='Product price in USD, 2 decimal places, positive values only. '
                'Examples: 19.99, 149.99, 2499.00, 0.99, 89.95'
    )

    category_id = Column(
        Integer,
        ForeignKey('categories.id', ondelete='SET NULL'),
        nullable=True,
        index=True,
        comment='FK to categories.id, NULL if uncategorized or category deleted. '
                'Examples: 5 (Electronics), 12 (Clothing), 3 (Home & Garden), NULL'
    )

    metadata = Column(
        JSONB,
        default=lambda: {},
        nullable=False,
        comment='Additional metadata, flexible schema (brand, warranty, specs). '
                'Examples: {"brand":"TechCo","warranty":"2 years","color":"black"}, '
                '{"brand":"BrandX","model":"Pro-2024"}, {}'
    )

    tags = Column(
        ARRAY(String),
        default=list,
        nullable=False,
        comment='Product tags for search and filtering, lowercase, 0-20 tags. '
                'Examples: ["electronics","audio","wireless"], '
                '["clothing","mens","casual"], []'
    )

    created_at = Column(
        DateTime,
        default=func.now(),
        nullable=False,
        comment='Product creation timestamp (UTC). '
                'Examples: "2024-01-15 14:30:00", "2024-03-10 09:15:22"'
    )

    updated_at = Column(
        DateTime,
        default=func.now(),
        onupdate=func.now(),
        comment='Last modification timestamp (UTC), auto-updated. '
                'Examples: "2024-01-15 14:30:00", "2024-03-16 10:20:15"'
    )

    # Relationships
    category = relationship('Category', back_populates='products')
    order_items = relationship('OrderItem', back_populates='product')
```

**Improvements**:
- ✅ PostgreSQL-specific features documented
- ✅ JSON structure examples
- ✅ Array examples
- ✅ GIN index usage explained
- ✅ NULL semantics clear
- ✅ Relationship cardinality and cascade details

---

## Example 4: Adding pgModeler-Compatible Comments

### BEFORE: Code-Only Documentation

```python
from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class Category(Base):
    """Product category for organization."""
    __tablename__ = 'categories'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), unique=True, nullable=False)
    slug = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime, default=func.now())
```

**Problem**: No inline comments = pgModeler HTML export will be empty

---

### AFTER: pgModeler-Ready with Table and Column Comments

```python
from sqlalchemy import Column, Integer, String, DateTime, func, Index
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class Category(Base):
    """Product category model for hierarchical organization.

    Organizes products into searchable categories. Uses slug for
    SEO-friendly URLs.

    Relationships:
        - products: One-to-many with Product (backref='category')
          Cascade: None (set product.category_id to NULL on delete)
          Typical: 10-5000 products per category

    Indexes:
        - name: Unique index for category name lookups
        - slug: Unique index for URL routing

    Data Volume (as of 2024-03-15):
        - Total rows: 45 categories
        - Most products: "Electronics" (12,345 products)
        - Empty: 3 categories (newly added)

    Example:
        >>> # Create category
        >>> category = Category(
        ...     name='Electronics',
        ...     slug='electronics'
        ... )
        >>> session.add(category)
        >>> session.commit()
        >>>
        >>> # Query with products
        >>> category = session.query(Category).filter_by(slug='electronics').first()
        >>> print(f"Products: {len(category.products)}")

    Author: Daniel Ginês
    Last Updated: 2024-03-15
    """
    __tablename__ = 'categories'
    __table_args__ = (
        Index('ix_categories_name', 'name', unique=True),
        Index('ix_categories_slug', 'slug', unique=True),
        {'comment': 'Product categories for hierarchical organization and navigation'}
    )

    id = Column(
        Integer,
        primary_key=True,
        comment='Primary key, auto-increment. Examples: 1, 5, 12, 45'
    )

    name = Column(
        String(100),
        unique=True,
        nullable=False,
        comment='Category display name, unique, 2-100 chars. '
                'Examples: "Electronics", "Clothing", "Home & Garden", "Sports & Outdoors"'
    )

    slug = Column(
        String(100),
        unique=True,
        nullable=False,
        comment='URL-safe slug, lowercase, hyphens for spaces, unique. '
                'Examples: "electronics", "clothing", "home-garden", "sports-outdoors"'
    )

    created_at = Column(
        DateTime,
        default=func.now(),
        nullable=False,
        comment='Category creation timestamp (UTC). '
                'Examples: "2024-01-15 14:30:00", "2024-02-20 09:00:00"'
    )

    # Relationships
    products = relationship('Product', back_populates='category')
```

**pgModeler HTML Export Result**:

```html
<h2>categories</h2>
<p>Product categories for hierarchical organization and navigation</p>

<table>
  <tr>
    <th>Column</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>id</td>
    <td>integer</td>
    <td>Primary key, auto-increment. Examples: 1, 5, 12, 45</td>
  </tr>
  <tr>
    <td>name</td>
    <td>character varying(100)</td>
    <td>Category display name, unique, 2-100 chars. Examples: "Electronics", "Clothing", "Home & Garden", "Sports & Outdoors"</td>
  </tr>
  <tr>
    <td>slug</td>
    <td>character varying(100)</td>
    <td>URL-safe slug, lowercase, hyphens for spaces, unique. Examples: "electronics", "clothing", "home-garden", "sports-outdoors"</td>
  </tr>
  <tr>
    <td>created_at</td>
    <td>timestamp without time zone</td>
    <td>Category creation timestamp (UTC). Examples: "2024-01-15 14:30:00", "2024-02-20 09:00:00"</td>
  </tr>
</table>
```

**Improvements**:
- ✅ Table comment in `__table_args__`
- ✅ All columns have inline comments
- ✅ pgModeler exports rich HTML dictionary
- ✅ Team has navigable database documentation

---

## Key Takeaways

### Documentation Completeness

**Before**: Minimal or generic documentation
**After**: Comprehensive documentation with:
- Class docstrings (relationships, indexes, constraints)
- Inline column comments (with real examples)
- Table comments for pgModeler
- Migration history
- Usage examples
- Security notes

### Real Data Examples

**Before**: No examples or made-up examples
**After**: Real examples from database queries:
- Queried with SQLAlchemy
- Anonymized for security
- 2-5 examples per column
- Distribution for enums/booleans

### pgModeler Integration

**Before**: Comments missing = empty HTML export
**After**: Complete comments = rich data dictionary

### Maintenance

**Before**: Documentation diverges from code
**After**: Documentation lives with code in comments, updated via migrations

---

**Philosophy**: The best documentation is the documentation that exists, is accurate, and is maintained. Inline comments with real examples make database models self-documenting and enable automated documentation generation.
