# Before/After Docstring Examples

> **Purpose**: Practical examples showing transformation from poor/missing documentation to industry-standard docstrings.

---

## Example 1: Missing Docstring → Complete Documentation

### ❌ Before

```python
def process_order(order_id, user_id, items, discount=None):
    total = sum(item['price'] * item['quantity'] for item in items)
    if discount:
        total = total * (1 - discount)
    # Save to database
    db.save_order(order_id, user_id, total, items)
    return total
```

### ✅ After (Google Style)

```python
def process_order(
    order_id: str,
    user_id: int,
    items: list[dict],
    discount: Optional[float] = None
) -> Decimal:
    """Calculate order total and persist to database.

    Computes total price from line items, applies optional discount,
    and atomically saves order with items to database.

    Args:
        order_id: Unique order identifier (UUID format).
        user_id: Customer's user ID.
        items: List of order items, each containing:
            - 'product_id': Product identifier (str)
            - 'price': Unit price (Decimal)
            - 'quantity': Number of units (int)
        discount: Optional discount as decimal (0.1 = 10% off).

    Returns:
        Final order total after discount application.

    Raises:
        ValueError: If items list is empty.
        DatabaseError: If order persistence fails.

    Example:
        >>> items = [
        ...     {'product_id': 'P123', 'price': Decimal('10.00'), 'quantity': 2},
        ...     {'product_id': 'P456', 'price': Decimal('5.00'), 'quantity': 1}
        ... ]
        >>> total = process_order('ORD-001', 42, items, discount=0.1)
        >>> print(total)
        Decimal('22.50')

    Note:
        Operation is atomic: either all items saved or none (transaction).
    """
    total = sum(item['price'] * item['quantity'] for item in items)
    if discount:
        total = total * (1 - discount)
    db.save_order(order_id, user_id, total, items)
    return total
```

---

## Example 2: Inadequate Docstring → Comprehensive Documentation

### ❌ Before

```python
class User:
    """User class."""

    def __init__(self, email, password):
        self.email = email
        self.password = password
        self.is_active = True
```

### ✅ After (Google Style)

```python
class User:
    """User account model with authentication support.

    Represents a user account with email-based authentication.
    Passwords are automatically hashed on initialization.

    Attributes:
        email: User's email address (unique identifier).
        password_hash: Bcrypt hash of user's password.
        is_active: Account status (True = active, False = suspended).
        created_at: Account creation timestamp (UTC).
        last_login: Last successful login timestamp (UTC, None if never).

    Example:
        >>> user = User(email='john@example.com', password='secret123')
        >>> user.verify_password('secret123')
        True
        >>> user.verify_password('wrong')
        False

    Note:
        Plaintext password is never stored. Only bcrypt hash is retained.
        Email is stored lowercase for case-insensitive matching.
    """

    def __init__(self, email: str, password: str):
        """Initialize user with email and hashed password.

        Args:
            email: User's email address (will be lowercased).
            password: Plaintext password (will be hashed with bcrypt).

        Raises:
            ValueError: If email format is invalid.
        """
        self.email = email.lower()
        self.password_hash = bcrypt.hashpw(
            password.encode('utf-8'),
            bcrypt.gensalt(rounds=12)
        )
        self.is_active = True
        self.created_at = datetime.now(timezone.utc)
        self.last_login = None
```

---

## Example 3: Commented Code → Proper Docstring

### ❌ Before

```python
# This function fetches user data from API
# It returns a dict with user info
# Raises exception if user not found
def get_user(user_id):
    response = requests.get(f'https://api.example.com/users/{user_id}')
    response.raise_for_status()
    return response.json()
```

### ✅ After (Google Style)

```python
def get_user(user_id: int) -> dict:
    """Fetch user data from external API.

    Makes HTTP GET request to retrieve user profile information.
    Implements automatic retry with exponential backoff on rate limiting.

    Args:
        user_id: Unique identifier for user.

    Returns:
        Dictionary containing user profile:
            - 'id': User ID (int)
            - 'username': Username (str)
            - 'email': Email address (str)
            - 'created_at': Account creation date (ISO 8601 str)

    Raises:
        requests.HTTPError: If user not found (404) or API error (5xx).
        requests.Timeout: If request exceeds 5 second timeout.
        requests.ConnectionError: If API is unreachable.

    Example:
        >>> user = get_user(12345)
        >>> print(user['username'])
        'johndoe'

    Note:
        Result is cached for 5 minutes in Redis if caching enabled.
    """
    response = requests.get(
        f'https://api.example.com/users/{user_id}',
        timeout=5.0
    )
    response.raise_for_status()
    return response.json()
```

---

## Example 4: SQLAlchemy Model → Fully Documented

### ❌ Before

```python
class Product(Base):
    __tablename__ = 'products'

    id = Column(Integer, primary_key=True)
    name = Column(String(255))
    price = Column(Numeric(10, 2))
    category_id = Column(Integer, ForeignKey('categories.id'))
```

### ✅ After (Google Style)

```python
class Product(Base):
    """Product catalog model.

    Represents items available for purchase in the e-commerce system.

    Relationships:
        - category: Many-to-one with Category
        - order_items: One-to-many with OrderItem
        - reviews: One-to-many with ProductReview

    Indexes:
        - name: B-tree index for search queries
        - category_id: Foreign key index for filtering by category
        - (category_id, price): Composite for category price range queries

    Constraints:
        - name: Not null, max 255 characters
        - price: Not null, positive values only (check constraint)
        - sku: Unique identifier for inventory management

    Example:
        >>> product = Product(
        ...     name='Widget Pro',
        ...     price=Decimal('29.99'),
        ...     sku='WGT-001',
        ...     category_id=5
        ... )
        >>> session.add(product)
        >>> session.commit()

    Note:
        Prices stored in USD. Currency conversion handled at display layer.
    """
    __tablename__ = 'products'

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False, index=True)  # Product display name
    sku = Column(String(50), unique=True, nullable=False)  # Stock keeping unit
    price = Column(Numeric(10, 2), nullable=False)  # Price in USD, 2 decimal places
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=False)  # Product category
    created_at = Column(DateTime, default=func.now())  # UTC timestamp
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())  # Auto-updated

    # Relationships
    category = relationship('Category', back_populates='products')
    order_items = relationship('OrderItem', back_populates='product')

    # Composite index for common query pattern
    __table_args__ = (
        Index('ix_category_price', 'category_id', 'price'),
        CheckConstraint('price > 0', name='positive_price'),
    )
```

---

## Example 5: Scrapy Spider → Professional Documentation

### ❌ Before

```python
class ProductSpider(scrapy.Spider):
    name = 'products'
    start_urls = ['https://example.com/products']

    def parse(self, response):
        for product in response.css('.product'):
            yield {
                'name': product.css('.title::text').get(),
                'price': product.css('.price::text').get(),
            }
```

### ✅ After (Google Style)

```python
class ProductSpider(scrapy.Spider):
    """E-commerce product catalog scraper for example.com.

    Target: https://example.com/products
    Rate Limit: 2 seconds between requests (DOWNLOAD_DELAY=2)

    Extracts:
        Product Data:
            - name: Product title (str)
            - price: Price in USD (str, format "$XX.XX")
            - sku: Product SKU (str)
            - url: Product detail page URL (str)
            - availability: Stock status (bool)

        Images:
            - image_url: Primary product image (str)

    Configuration:
        DOWNLOAD_DELAY = 2  # Respectful crawling
        CONCURRENT_REQUESTS_PER_DOMAIN = 1
        ROBOTSTXT_OBEY = True
        USER_AGENT = 'ProductBot/1.0 (+https://ourwebsite.com/bot)'

    Usage:
        scrapy crawl products -o products.jsonl -t jsonlines
        scrapy crawl products -a category=electronics -o electronics.json

    Spider Arguments:
        category: Filter products by category (optional)
        max_pages: Maximum number of pages to crawl (default: unlimited)

    Pipeline:
        - ValidationPipeline: Validates required fields
        - PriceNormalizationPipeline: Parses price strings to Decimal
        - DuplicatesPipeline: Filters duplicate SKUs

    Notes:
        - Handles pagination automatically via "next" button
        - Skips out-of-stock items by default (configurable)
        - Implements exponential backoff for 429 responses
        - Respects robots.txt crawl-delay directive

    Dependencies:
        - price-parser: For robust price extraction
        - scrapy-user-agents: For user agent rotation

    Author: Web Scraping Team
    Last Updated: 2024-01-15
    """
    name = 'products'
    allowed_domains = ['example.com']
    start_urls = ['https://example.com/products']

    custom_settings = {
        'DOWNLOAD_DELAY': 2,
        'CONCURRENT_REQUESTS_PER_DOMAIN': 1,
        'ROBOTSTXT_OBEY': True,
    }

    def parse(self, response):
        """Extract product listings and follow pagination.

        Args:
            response: Scrapy response from product listing page.

        Yields:
            Request: For product detail pages.
            Request: For next page pagination.

        Note:
            Pagination handled via CSS selector for "next" button.
        """
        for product in response.css('.product'):
            product_url = response.urljoin(product.css('a::attr(href)').get())
            yield scrapy.Request(product_url, callback=self.parse_product)

        # Pagination
        next_page = response.css('.pagination .next::attr(href)').get()
        if next_page:
            yield response.follow(next_page, callback=self.parse)

    def parse_product(self, response):
        """Extract detailed product information.

        Args:
            response: Scrapy response from product detail page.

        Yields:
            dict: Product data matching schema in class docstring.

        Note:
            Skips products marked as out-of-stock.
            Price extracted with price-parser for robust parsing.
        """
        availability = response.css('.stock-status::text').get()
        if 'out of stock' in availability.lower():
            return  # Skip out-of-stock items

        yield {
            'name': response.css('h1.title::text').get(),
            'price': response.css('.price::text').get(),
            'sku': response.css('.sku::text').get(),
            'url': response.url,
            'availability': 'in stock' in availability.lower(),
            'image_url': response.css('.main-image::attr(src)').get(),
        }
```

---

## Example 6: Async Function → Complete Documentation

### ❌ Before

```python
async def fetch_data(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()
```

### ✅ After (Google Style)

```python
async def fetch_data(url: str, timeout: float = 10.0) -> dict:
    """Asynchronously fetch JSON data from URL.

    Makes non-blocking HTTP GET request suitable for concurrent operations.
    Implements timeout and automatic connection pooling.

    Args:
        url: Target URL (must be valid HTTP/HTTPS).
        timeout: Request timeout in seconds. Defaults to 10.0.

    Returns:
        Parsed JSON response as dictionary.

    Raises:
        aiohttp.ClientError: If HTTP request fails.
        asyncio.TimeoutError: If request exceeds timeout.
        json.JSONDecodeError: If response is not valid JSON.

    Example:
        >>> async def main():
        ...     data = await fetch_data('https://api.example.com/users')
        ...     print(data['users'][0]['name'])
        >>> asyncio.run(main())

    Note:
        Requires active asyncio event loop. Use with await.
        Connection pooling managed automatically by aiohttp.
        Maximum concurrent connections: 100 (aiohttp default).
    """
    timeout_config = aiohttp.ClientTimeout(total=timeout)
    async with aiohttp.ClientSession(timeout=timeout_config) as session:
        async with session.get(url) as response:
            response.raise_for_status()
            return await response.json()
```

---

## Summary of Improvements

| Aspect | Before | After |
|--------|--------|-------|
| **Purpose** | Missing or vague | Clear, specific description |
| **Parameters** | Undocumented | All params documented with types |
| **Returns** | Not explained | Return value structure described |
| **Exceptions** | Not listed | All possible exceptions documented |
| **Examples** | None | Working code examples provided |
| **Context** | Missing | Business logic and constraints explained |
| **Type Hints** | Missing | Complete type annotations |
| **Relationships** | Unknown | Database relations explicitly stated |
| **Configuration** | Unclear | Settings and dependencies listed |

---

**Key Takeaways**:

1. **Transform comments to docstrings**: Comments explain implementation, docstrings explain interface
2. **Add type hints**: They complement docstrings (what) with machine-readable types
3. **Include examples**: Show typical usage, not just abstract description
4. **Document exceptions**: Callers need to know what can go wrong
5. **Explain WHY**: Not just WHAT the code does, but why it exists
6. **Context matters**: Business rules, performance notes, migration history

---

**Use these examples** as templates when standardizing your own codebase.
