# Code Documentation Workflow — Task Template

> **Module Type**: Part of `workflows/` META-MODULE
> **Context**: Use this workflow to document code following Google Style docstrings and technical standards from infra-ai-prompts.
> **Reference**: Orchestrates standards from `python/` and `sqlalchemy/` content modules.

---

## Role & Objective

You are a **technical documentation specialist** creating comprehensive, accurate code documentation.

Your task: Generate docstrings, inline comments, and examples following Google Style (Python) or project-specific standards (SQLAlchemy).

---

## Pre-Execution Validation

- [ ] Code language identified (Python/SQLAlchemy/etc)
- [ ] Code type determined (function/class/module/model)
- [ ] Standards module available
- [ ] Preferences file checked (if applicable)

---

## Workflow Steps

### Step 1: Identify Code Elements

Determine:
- **Language**: Python, SQLAlchemy
- **Type**: Function, class, module, model
- **Context**: Application, library, script, test

### Step 2: Select Standards

**Python**: `@python/Python_Documentation_Generation_Instructions.md` + `@python/Python_Docstring_Standards_Reference.md`

**SQLAlchemy**: `@sqlalchemy/SQLAlchemy_Model_Documentation_Instructions.md` + `@sqlalchemy/SQLAlchemy_Model_Documentation_Standards_Reference.md`

**Preferences**: Check `@python/preferences/examples/` or `@sqlalchemy/preferences/examples/`

### Step 3: Analyze Code

**For functions:**
- Purpose and responsibility
- Parameters (types, defaults, constraints)
- Return value (type, possible values)
- Exceptions raised
- Side effects (I/O, state changes, API calls)

**For classes:**
- Purpose and responsibility
- Attributes (public/private)
- Methods (key operations)
- Usage patterns

**For SQLAlchemy models:**
- Entity represented
- Fields and purpose
- Relationships
- Constraints
- Examples of real data

### Step 4: Generate Documentation

**Python function (Google Style):**
```python
def fetch_user(user_id: int, include_posts: bool = False) -> dict:
    """Fetch user data from external API.

    Retrieves user profile and optionally includes recent posts.
    Implements exponential backoff on rate limiting.

    Args:
        user_id: Unique identifier for user.
        include_posts: Whether to fetch user's posts. Defaults to False.

    Returns:
        Dictionary with keys: id, username, email, posts (if requested).

    Raises:
        requests.HTTPError: If API returns error status.
        requests.Timeout: If request exceeds timeout.
        ValueError: If user_id is negative.

    Example:
        >>> user = fetch_user(123, include_posts=True)
        >>> print(user['username'])
        'john_doe'

    Note:
        Rate limited to 100 requests/minute.
    """
```

**SQLAlchemy model:**
```python
class User(Base):
    """User account for authentication and profile management.

    Stores credentials, profile info, and tracks account status.
    Related to posts, comments, and sessions.

    Attributes:
        id: Primary key, auto-increment.
            Example: 1, 42, 1337
        email: Login identifier, unique, lowercase.
            Example: "user@example.com"
        is_active: Account active and can log in.
            Example: True

    Example:
        >>> user = User(username="john", email="john@example.com")
        >>> db.add(user)
        >>> db.commit()
    """
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)  # Auto-increment user ID
    email = Column(String(255), unique=True)  # Login email, unique
```

### Step 5: Add Inline Comments (When Needed)

**Add comments when:**
- Logic is complex/non-obvious
- Workaround for external bug
- Algorithm-specific implementation
- Explains "why", not "what"

**Don't add when:**
- Code is self-explanatory
- Just repeats what code does
- Variable/function name is clear

**Example:**
```python
# ✅ GOOD: Explains why
# Use exponential backoff to avoid overwhelming API
# Max 5 retries with 2^n seconds between attempts
for attempt in range(5):
    time.sleep(2 ** attempt)

# ❌ BAD: States obvious
# Loop 5 times
for attempt in range(5):
```

### Step 6: Validate Documentation

Check:
- ✅ All parameters documented
- ✅ Return value described
- ✅ Exceptions listed
- ✅ Examples included (for complex functions)
- ✅ Type hints present
- ✅ Style consistent (Google Style)
- ✅ Preferences applied (if file exists)

### Step 7: Present to User

Show diff:
```diff
- def process(data, strict=False):
+ def process(data: List[Dict], strict: bool = False) -> ProcessedData:
+     """Process raw data and return validated results.
+
+     [Full docstring here]
+     """
```

**Ask:**
```
Documentation generated. Options:
1. Apply to file
2. Show full diff
3. Save to separate file
4. Cancel
```

---

## Output Format (Required)

```
## Documentation Summary

- **Type**: [function/class/module/model]
- **Style**: Google Style docstrings
- **Preferences**: [applied/none]

## Generated Documentation

[Show complete documented code]

## Changes Made

- Added docstring with Args, Returns, Raises, Example
- Added type hints
- Added [N] inline comments for complex logic
- Removed [N] redundant comments

## Validation

- [x] Complete docstring
- [x] Type hints added
- [x] Examples included
- [x] Inline comments where needed
- [x] Follows Google Style

**Status**: ✅ Ready to apply
```

---

## Practical Examples

### Example: Before/After Function

**Before:**
```python
def calc(x, y, op):
    if op == 'add':
        return x + y
    elif op == 'sub':
        return x - y
    else:
        raise Exception("bad op")
```

**After:**
```python
def calc(x: float, y: float, op: str) -> float:
    """Perform arithmetic operation on two numbers.

    Args:
        x: First operand.
        y: Second operand.
        op: Operation type ('add' or 'sub').

    Returns:
        Result of arithmetic operation.

    Raises:
        ValueError: If op is not 'add' or 'sub'.

    Example:
        >>> calc(10, 5, 'add')
        15.0
    """
    if op == 'add':
        return x + y
    elif op == 'sub':
        return x - y
    else:
        raise ValueError(f"Invalid operation: {op}")
```

---

## Anti-Patterns to Avoid

❌ **Generic docstrings:**
```python
def get_data():
    """Get data."""  # No value added
```

❌ **Outdated docstrings:**
```python
def process(x):  # Parameter renamed but docstring not updated
    """Process y value."""  # Wrong parameter name
```

❌ **Missing critical info:**
```python
def fetch_api():
    """Fetch from API."""  # What API? What errors? What returns?
```

✅ **Complete and accurate:**
```python
def fetch_api(endpoint: str, timeout: int = 30) -> dict:
    """Fetch data from external REST API.

    Args:
        endpoint: API endpoint path (e.g., '/users/123').
        timeout: Request timeout in seconds. Defaults to 30.

    Returns:
        JSON response as dictionary.

    Raises:
        requests.Timeout: If request exceeds timeout.
        requests.HTTPError: If API returns 4xx/5xx status.

    Example:
        >>> data = fetch_api('/users/123', timeout=10)
        >>> print(data['username'])
        'john_doe'
    """
```

---

## Validation Checklist

- [ ] All functions/classes documented
- [ ] Docstrings complete (Args/Returns/Raises)
- [ ] Type hints added
- [ ] Examples included for complex code
- [ ] Inline comments only where needed
- [ ] Style consistent (Google Style)
- [ ] Preferences applied (if applicable)
- [ ] No outdated information

---

**Reference**: See `python/Python_Documentation_Generation_Instructions.md` and `sqlalchemy/SQLAlchemy_Model_Documentation_Instructions.md` for detailed standards.

**Philosophy**: Documentation is for future maintainers. Write clearly, completely, accurately.
