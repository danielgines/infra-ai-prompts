# Python Docstring Standards Reference

> **Purpose**: Shared reference for Python documentation standards. Use this as foundation for all Python documentation prompts.

---

## PEP 257 — Docstring Conventions

**Official Python standard**: https://peps.python.org/pep-0257/

### Basic Rules

1. **All modules, classes, functions, and methods** should have docstrings
2. Use **triple double quotes**: `"""Docstring"""`
3. **One-line docstrings**: For simple, obvious cases
4. **Multi-line docstrings**: Summary line + blank line + detailed description
5. **Prescriptive mood**: "Do this" not "Does this"
6. **End with period**: Complete sentences

### One-Line Docstrings

```python
def square(x):
    """Return the square of x."""
    return x * x
```

### Multi-Line Docstrings

```python
def complex_function(param1, param2):
    """Summary line goes here.

    More detailed description follows after a blank line.
    Explain behavior, side effects, and return value.

    Args:
        param1: Description of param1.
        param2: Description of param2.

    Returns:
        Description of return value.
    """
```

---

## Major Documentation Styles

### 1. Google Style (Recommended for Readability)

**Advantages**: Clean, readable, widely adopted

```python
def fetch_data(url: str, timeout: int = 30, retries: int = 3) -> dict:
    """Fetch data from a remote URL with retry logic.

    Makes HTTP GET request with exponential backoff on failures.
    Raises exception after exhausting all retries.

    Args:
        url: Target URL to fetch data from. Must be valid HTTP/HTTPS.
        timeout: Request timeout in seconds. Defaults to 30.
        retries: Maximum number of retry attempts. Defaults to 3.

    Returns:
        Parsed JSON response as dictionary.

    Raises:
        requests.HTTPError: If response status is 4xx or 5xx.
        requests.Timeout: If request exceeds timeout after all retries.
        ValueError: If response is not valid JSON.

    Example:
        >>> data = fetch_data('https://api.example.com/users')
        >>> print(data['users'][0]['name'])
        'John Doe'

    Note:
        Implements exponential backoff: 1s, 2s, 4s between retries.
    """
```

### 2. NumPy/SciPy Style (Scientific Computing)

**Advantages**: Excellent for complex mathematical functions

```python
def calculate_stats(data, axis=None, weights=None):
    """Calculate statistical measures for array data.

    Computes mean, variance, and standard deviation with optional
    weighting along specified axis.

    Parameters
    ----------
    data : array_like
        Input data array. Can be list, tuple, or numpy array.
    axis : int or None, optional
        Axis along which statistics are computed. If None (default),
        compute over flattened array.
    weights : array_like, optional
        Array of weights associated with values in data. Must be
        same shape as data. If None (default), uniform weights.

    Returns
    -------
    stats : dict
        Dictionary containing:
        - 'mean' : float or ndarray
        - 'variance' : float or ndarray
        - 'std' : float or ndarray

    Raises
    ------
    ValueError
        If weights shape doesn't match data shape.
    TypeError
        If data cannot be converted to numeric array.

    See Also
    --------
    numpy.average : Weighted average computation
    scipy.stats.describe : More comprehensive statistics

    Notes
    -----
    Uses Bessel's correction (N-1) for variance calculation.

    Examples
    --------
    >>> data = [1, 2, 3, 4, 5]
    >>> stats = calculate_stats(data)
    >>> print(stats['mean'])
    3.0

    With weights:

    >>> weights = [1, 1, 1, 1, 10]
    >>> stats = calculate_stats(data, weights=weights)
    >>> print(stats['mean'])
    4.28
    """
```

### 3. Sphinx reStructuredText Style

**Advantages**: Integrates perfectly with Sphinx documentation generator

```python
def process_user(user_id, action='read', db_session=None):
    """Process user action in database.

    Performs CRUD operation on user record with transaction safety.
    Automatically commits on success, rolls back on error.

    :param user_id: Unique identifier for user
    :type user_id: int
    :param action: Action to perform ('read', 'update', 'delete')
    :type action: str, optional
    :param db_session: Database session. If None, creates new session.
    :type db_session: sqlalchemy.orm.Session, optional

    :returns: User object after processing
    :rtype: models.User

    :raises ValueError: If action is not recognized
    :raises sqlalchemy.exc.IntegrityError: If database constraint violated
    :raises PermissionError: If user lacks permission for action

    .. note::
       Requires active database connection in application context.

    .. warning::
       Delete action is irreversible. Consider soft-delete instead.

    Example::

        >>> user = process_user(123, action='update')
        >>> print(user.username)
        'john_doe'
    """
```

---

## Type Hints Integration (PEP 484)

**Modern Python documentation combines type hints + docstrings**

```python
from typing import List, Dict, Optional, Union
from pathlib import Path

def load_config(
    config_path: Union[str, Path],
    env: str = 'production',
    overrides: Optional[Dict[str, any]] = None
) -> Dict[str, any]:
    """Load application configuration from file.

    Reads YAML or JSON config file and applies environment-specific
    overrides. Validates required keys are present.

    Args:
        config_path: Path to configuration file (YAML or JSON).
        env: Environment name ('development', 'staging', 'production').
        overrides: Optional dictionary to override config values.

    Returns:
        Merged configuration dictionary with all settings.

    Raises:
        FileNotFoundError: If config file doesn't exist.
        yaml.YAMLError: If YAML parsing fails.
        KeyError: If required configuration keys are missing.
    """
```

**Key principle**: Type hints define **what**, docstrings explain **why** and **how**.

---

## Documentation by Function Type

### Module-Level Docstring

```python
"""User authentication and authorization module.

Provides JWT-based authentication, role-based access control (RBAC),
and session management for web application. Integrates with OAuth2
providers (Google, GitHub) for social login.

Classes:
    User: Main user model with authentication methods
    Role: RBAC role definition
    Permission: Granular permission model

Functions:
    authenticate_user: Validate credentials and issue JWT
    verify_token: Decode and validate JWT token
    check_permission: Verify user has required permission

Constants:
    TOKEN_EXPIRY: JWT token lifetime in seconds (3600)
    REFRESH_EXPIRY: Refresh token lifetime in seconds (604800)

Example:
    Basic authentication flow::

        from auth import authenticate_user, verify_token

        token = authenticate_user('user@example.com', 'password')
        user = verify_token(token)

Notes:
    - All tokens are signed with HS256 algorithm
    - Passwords hashed with bcrypt (cost factor 12)
    - Sessions stored in Redis for horizontal scaling

Author:
    Daniel Ginês <daniel@example.com>

Version:
    2.1.0 (2024-01-15)
"""
```

### Class Docstring

```python
class DatabaseConnection:
    """Thread-safe database connection manager with pooling.

    Manages SQLAlchemy connection pool with automatic reconnection
    on failure. Supports multiple database backends (PostgreSQL, MySQL).

    Attributes:
        engine: SQLAlchemy engine instance
        pool_size: Maximum number of connections in pool
        is_connected: Boolean indicating active connection

    Example:
        >>> db = DatabaseConnection('postgresql://localhost/mydb')
        >>> with db.session() as session:
        ...     users = session.query(User).all()

    Note:
        Thread-safe for use in multi-threaded applications.
        Connection pool shared across threads.
    """

    def __init__(self, connection_string: str, pool_size: int = 10):
        """Initialize database connection.

        Args:
            connection_string: SQLAlchemy connection URL.
            pool_size: Maximum connections in pool. Defaults to 10.

        Raises:
            sqlalchemy.exc.ArgumentError: If connection string invalid.
        """
```

### Method Docstring

```python
def validate_email(self, email: str) -> bool:
    """Validate email format and check if domain exists.

    Performs regex validation and DNS MX record lookup to verify
    email address is properly formatted and domain can receive mail.

    Args:
        email: Email address to validate.

    Returns:
        True if email is valid and domain exists, False otherwise.

    Note:
        DNS lookup may add 1-2 seconds latency. Consider caching
        results for frequently checked domains.
    """
```

### Property Docstring

```python
@property
def full_name(self) -> str:
    """Return user's full name (first + last).

    Returns empty string if both names are None. Handles middle names
    if present.
    """
    return f"{self.first_name} {self.last_name}".strip()
```

### Generator Function

```python
def batch_process(items: List[any], batch_size: int = 100):
    """Yield items in batches of specified size.

    Memory-efficient processing of large lists by yielding
    chunks rather than creating sublists.

    Args:
        items: List of items to process.
        batch_size: Number of items per batch. Defaults to 100.

    Yields:
        List containing up to batch_size items.

    Example:
        >>> items = range(1000)
        >>> for batch in batch_process(items, batch_size=50):
        ...     process_batch(batch)
    """
```

### Async Function

```python
async def fetch_user_async(user_id: int) -> User:
    """Asynchronously fetch user from database.

    Non-blocking database query suitable for async web frameworks
    (FastAPI, aiohttp). Uses asyncpg connection pool.

    Args:
        user_id: Unique identifier for user.

    Returns:
        User object if found.

    Raises:
        UserNotFoundError: If user doesn't exist.
        asyncpg.PostgresError: If database error occurs.

    Note:
        Requires active asyncio event loop. Use with `await`:
        `user = await fetch_user_async(123)`
    """
```

### Decorator Function

```python
def retry(max_attempts: int = 3, delay: float = 1.0):
    """Decorator to retry function on exception with exponential backoff.

    Args:
        max_attempts: Maximum retry attempts. Defaults to 3.
        delay: Initial delay in seconds. Doubles on each retry.

    Returns:
        Decorated function with retry logic.

    Example:
        >>> @retry(max_attempts=5, delay=2.0)
        ... def unstable_api_call():
        ...     return requests.get('https://api.example.com/data')
    """
```

---

## Common Docstring Sections

| Section | Purpose | Required? |
|---------|---------|-----------|
| **Summary** | One-line description | ✅ Always |
| **Args/Parameters** | Parameter descriptions | ✅ If has params |
| **Returns/Yields** | Return value description | ✅ If returns |
| **Raises** | Exceptions that may be raised | ⚠️ Important ones |
| **Example** | Usage examples | 🟡 Recommended |
| **Note** | Additional context | 🟡 When helpful |
| **Warning** | Critical information | ⚠️ For dangerous ops |
| **See Also** | Related functions/classes | 🟡 Optional |
| **Deprecated** | Deprecation notice | ✅ If deprecated |

---

## Anti-Patterns to Avoid

❌ **Obvious docstrings**:
```python
def get_name(self):
    """Get name."""  # Adds no value
    return self.name
```

❌ **Outdated docstrings**:
```python
def process_users(users, active_only=False):  # ← Changed signature
    """Process list of users.

    Args:
        users: List of user objects
        # Missing: active_only parameter!
    """
```

❌ **Implementation details in docstring**:
```python
def calculate(x):
    """Calculate result.

    Uses numpy array with vectorized operations and broadcasts
    over axis 0 then applies einsum for matrix multiplication.
    """
    # ↑ Too much implementation detail. Focus on WHAT and WHY.
```

❌ **Docstring duplicating type hints**:
```python
def add(x: int, y: int) -> int:
    """Add two integers.

    Args:
        x: integer  # ← Type already in signature
        y: integer  # ← Redundant

    Returns:
        integer     # ← Redundant
    """
```

✅ **Better**:
```python
def add(x: int, y: int) -> int:
    """Return sum of x and y.

    Args:
        x: First operand.
        y: Second operand.

    Returns:
        Sum of both operands.
    """
```

---

## Tools for Docstring Validation

- **pydocstyle**: PEP 257 compliance checker
- **darglint**: Matches docstrings to function signatures
- **interrogate**: Measures docstring coverage
- **sphinx**: Generates HTML documentation from docstrings
- **pdoc**: Simpler alternative to Sphinx

---

## Validation Checklist

- [ ] All public functions/classes have docstrings
- [ ] Summary line is concise and descriptive
- [ ] Parameters documented (if any)
- [ ] Return value documented (if returns)
- [ ] Exceptions documented (important ones)
- [ ] Examples provided (for complex functions)
- [ ] Type hints match docstring descriptions
- [ ] No outdated information
- [ ] Grammar and spelling correct

---

**References**:
- PEP 257: https://peps.python.org/pep-0257/
- Google Style: https://google.github.io/styleguide/pyguide.html
- NumPy Style: https://numpydoc.readthedocs.io/
- Sphinx: https://www.sphinx-doc.org/
