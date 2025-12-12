# Python Code Quality Checklist

> **Purpose**: Comprehensive validation checklist for Python code quality, security, performance, documentation, and deployment readiness.

---

## Table of Contents

1. [Before Writing Code](#before-writing-code)
2. [Script Structure](#script-structure)
3. [Security](#security)
4. [Error Handling](#error-handling)
5. [Code Quality](#code-quality)
6. [Common Patterns](#common-patterns)
7. [Testing](#testing)
8. [Documentation](#documentation)
9. [Deployment](#deployment)
10. [Quick Command Reference](#quick-command-reference)
11. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

---

## Before Writing Code

- [ ] Requirements clearly defined
- [ ] Input/output specifications documented
- [ ] Error scenarios identified
- [ ] Security requirements understood
- [ ] Performance requirements established

---

## Script Structure

### File Structure

- [ ] Module has clear, descriptive name
- [ ] Module-level docstring present
- [ ] Script has shebang line (`#!/usr/bin/env python3`)
- [ ] Encoding declared if non-ASCII (`# -*- coding: utf-8 -*-`)
- [ ] Imports properly organized:
  ```python
  # 1. Standard library imports
  import os
  import sys

  # 2. Third-party imports
  import requests
  from flask import Flask

  # 3. Local application imports
  from myapp import models
  from myapp.utils import helper
  ```

### Import Organization

- [ ] No wildcard imports (`from module import *`)
- [ ] No circular imports
- [ ] Imports sorted alphabetically within groups
- [ ] Unused imports removed (run: `autoflake --remove-all-unused-imports`)
- [ ] Import aliases are standard (e.g., `import numpy as np`)

### Main Function Pattern

- [ ] Script uses `if __name__ == "__main__":`
- [ ] Main logic in `main()` function
- [ ] Command-line arguments parsed with `argparse`
- [ ] Exit codes used appropriately (0=success, 1=error)

```python
def main():
    """Main script entry point."""
    try:
        # Script logic
        return 0
    except Exception as e:
        logger.error(f"Script failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
```

---

## Security

### Credential Management

- [ ] No hardcoded passwords/API keys/secrets
- [ ] Credentials loaded from environment variables
- [ ] Sensitive data not logged
- [ ] `.env` file in `.gitignore`
- [ ] Production secrets use secret manager (AWS Secrets Manager, Vault)

```python
# ✓ SECURE
import os
API_KEY = os.environ["API_KEY"]

# ✗ INSECURE
API_KEY = "sk_live_abc123"  # Hardcoded!
```

### Input Validation

- [ ] All user input validated
- [ ] Type checking with type hints
- [ ] Input sanitized before use
- [ ] Whitelist validation where possible
- [ ] Input length limits enforced

```python
def set_age(age: int) -> None:
    if not isinstance(age, int):
        raise TypeError("Age must be integer")
    if not 0 <= age <= 150:
        raise ValueError("Age must be 0-150")
```

### SQL Injection Prevention

- [ ] No SQL string formatting (f-strings, %, +)
- [ ] Parameterized queries used
- [ ] ORM (SQLAlchemy) preferred
- [ ] Dynamic table/column names whitelisted

```python
# ✗ VULNERABLE
query = f"SELECT * FROM users WHERE id = {user_id}"

# ✓ SECURE
query = text("SELECT * FROM users WHERE id = :id")
result = session.execute(query, {"id": user_id})
```

### Command Injection Prevention

- [ ] No `os.system()` usage
- [ ] No `shell=True` in subprocess
- [ ] subprocess uses list arguments
- [ ] User input validated before subprocess

```python
# ✗ VULNERABLE
os.system(f"ls {directory}")

# ✓ SECURE
subprocess.run(["ls", directory], check=True)
```

### File Operations

- [ ] Path traversal prevented
- [ ] File paths validated with `pathlib.Path.resolve()`
- [ ] File uploads validated (type, size, extension)
- [ ] File permissions set restrictively (0o600 for sensitive files)
- [ ] Temporary files cleaned up

```python
from pathlib import Path

def read_file_safe(filename: str) -> str:
    base_dir = Path("/data").resolve()
    file_path = (base_dir / filename).resolve()

    if not str(file_path).startswith(str(base_dir)):
        raise ValueError("Path traversal detected")

    return file_path.read_text()
```

---

## Error Handling

### Exception Handling

- [ ] No bare `except:` clauses
- [ ] Specific exceptions caught
- [ ] Exceptions logged with context
- [ ] Resources cleaned up in finally/with
- [ ] Custom exceptions defined when needed

```python
# ✗ BAD
try:
    dangerous_operation()
except:  # Catches KeyboardInterrupt, SystemExit!
    pass

# ✓ GOOD
try:
    dangerous_operation()
except ValueError as e:
    logger.error(f"Validation error: {e}")
    raise
except IOError as e:
    logger.error(f"I/O error: {e}")
    raise
```

### Logging

- [ ] Logging configured at module level
- [ ] Appropriate log levels used (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- [ ] Log messages include context
- [ ] Sensitive data not logged
- [ ] Structured logging used in production
- [ ] Log files rotated (RotatingFileHandler)

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

logger.info("Processing started")
logger.error(f"Failed to process: {error}")
```

### Exit Codes

- [ ] 0 for success
- [ ] 1 for general errors
- [ ] 2 for misuse of command
- [ ] Specific codes for specific errors

---

## Code Quality

### Readability

- [ ] Variable names descriptive
- [ ] Function names describe action (verbs)
- [ ] Class names describe entity (nouns)
- [ ] Magic numbers extracted as constants
- [ ] Complex logic has explanatory comments
- [ ] Functions are single-purpose
- [ ] Functions are < 50 lines
- [ ] Files are < 500 lines

### Maintainability

- [ ] No code duplication (DRY principle)
- [ ] Complex logic extracted into functions
- [ ] Configuration separated from code
- [ ] Hardcoded values avoided
- [ ] Dependencies minimized

### Robustness

- [ ] Edge cases handled
- [ ] None values checked
- [ ] Empty lists/dicts handled
- [ ] Division by zero prevented
- [ ] Resource limits enforced (timeouts, max retries)

### Style

- [ ] PEP 8 compliant (run: `flake8 .`)
- [ ] Black formatted (run: `black .`)
- [ ] Line length ≤ 88 characters
- [ ] Function names: `snake_case`
- [ ] Class names: `PascalCase`
- [ ] Constants: `UPPER_SNAKE_CASE`
- [ ] Private attributes: `_prefixed`

```bash
# Run style checkers
black .
flake8 .
pylint mymodule
```

---

## Common Patterns

### Context Managers

- [ ] Files opened with `with` statement
- [ ] Database connections use context managers
- [ ] Locks acquired with `with`
- [ ] Custom context managers for cleanup logic

```python
# ✓ GOOD
with open("file.txt", "r") as f:
    data = f.read()

# ✗ BAD
f = open("file.txt", "r")
data = f.read()
f.close()  # Might not execute if exception occurs
```

### Generators for Large Data

- [ ] Large datasets processed with generators
- [ ] Database queries use yield
- [ ] File reading uses chunking

```python
def read_large_file(file_path: Path):
    """Read file line by line (memory efficient)."""
    with open(file_path) as f:
        for line in f:
            yield line.strip()
```

### List Comprehensions

- [ ] Simple loops converted to comprehensions
- [ ] Complex comprehensions avoided (use regular loops)
- [ ] Dictionary/set comprehensions used appropriately

```python
# ✓ GOOD
squares = [x**2 for x in range(10)]

# ✗ BAD (too complex)
result = [x for x in [y**2 for y in range(10) if y % 2 == 0] if x > 50]
```

### Type Hints

- [ ] All function parameters typed
- [ ] Return types specified
- [ ] Optional used for nullable values
- [ ] Union used for multiple types
- [ ] Generic types used (List[str], Dict[str, int])
- [ ] Type checking passes (run: `mypy .`)

```python
from typing import Optional, List, Dict

def process_data(
    items: List[str],
    config: Dict[str, int],
    max_retries: Optional[int] = None
) -> bool:
    """Process data items."""
    # ...
    return True
```

### Async/Await

- [ ] Async functions marked with `async def`
- [ ] `await` used for async calls
- [ ] Async context managers used (`async with`)
- [ ] Event loop properly managed

---

## Testing

### Unit Testing

- [ ] Tests exist in `tests/` directory
- [ ] Test file names match source: `test_module.py`
- [ ] Test functions start with `test_`
- [ ] Each function has at least one test
- [ ] Edge cases tested
- [ ] Error cases tested
- [ ] Fixtures used for setup/teardown
- [ ] Mocking used for external dependencies

```python
import pytest
from unittest.mock import Mock, patch

def test_process_data_success():
    """Test successful data processing."""
    result = process_data(["item1", "item2"])
    assert result == expected_output

def test_process_data_empty_list():
    """Test with empty input."""
    result = process_data([])
    assert result == []

@patch('module.external_api_call')
def test_api_call_mocked(mock_api):
    """Test with mocked API."""
    mock_api.return_value = {"status": "success"}
    result = fetch_data()
    assert result["status"] == "success"
```

### Integration Testing

- [ ] Integration tests in `tests/integration/`
- [ ] Tests interact with real services (databases, APIs)
- [ ] Test data properly isolated
- [ ] Tests clean up after themselves

### Security Testing

- [ ] No secrets in test files
- [ ] SQL injection attempts tested
- [ ] Path traversal attempts tested
- [ ] Invalid input tested

### Coverage

- [ ] Test coverage measured (run: `pytest --cov=mymodule`)
- [ ] Coverage >= 80%
- [ ] Critical paths 100% covered
- [ ] Coverage report reviewed

```bash
# Run tests with coverage
pytest --cov=mymodule --cov-report=html
open htmlcov/index.html
```

---

## Documentation

### Docstrings

- [ ] Module docstring present
- [ ] All public functions have docstrings
- [ ] All public classes have docstrings
- [ ] Docstring format consistent (Google, NumPy, or Sphinx)
- [ ] Args section complete
- [ ] Returns section present
- [ ] Raises section lists exceptions
- [ ] Examples provided for complex functions

```python
def calculate_total(items: List[float], tax_rate: float = 0.1) -> float:
    """
    Calculate total price with tax.

    Args:
        items: List of item prices
        tax_rate: Tax rate as decimal (0.1 = 10%)

    Returns:
        Total price including tax

    Raises:
        ValueError: If tax_rate is negative

    Example:
        >>> calculate_total([10.0, 20.0], tax_rate=0.1)
        33.0
    """
    if tax_rate < 0:
        raise ValueError("Tax rate cannot be negative")

    subtotal = sum(items)
    return subtotal * (1 + tax_rate)
```

### README.md

- [ ] Installation instructions
- [ ] Usage examples
- [ ] Configuration options
- [ ] Environment variables documented
- [ ] License specified
- [ ] Contributing guidelines (if open source)

### Comments

- [ ] Complex algorithms explained
- [ ] Non-obvious decisions documented
- [ ] TODOs tracked and dated
- [ ] Commented-out code removed

---

## Deployment

### Pre-Deployment

- [ ] All tests passing
- [ ] Linters passing (flake8, pylint, black)
- [ ] Type checking passing (mypy)
- [ ] Security scan complete (bandit, safety)
- [ ] Dependencies updated
- [ ] README up to date

```bash
# Pre-deployment checks
pytest
black --check .
flake8 .
mypy .
bandit -r .
safety check
```

### Deployment Configuration

- [ ] Dependencies in requirements.txt or pyproject.toml
- [ ] Versions pinned (`requests==2.28.2`, not `requests>=2.0`)
- [ ] Python version specified (`.python-version`, `runtime.txt`)
- [ ] Environment variables documented
- [ ] Configuration file template provided

### Post-Deployment

- [ ] Health check endpoint working
- [ ] Monitoring configured
- [ ] Logging verified
- [ ] Error tracking setup (Sentry, Rollbar)
- [ ] Performance metrics collected

---

## Quick Command Reference

### Linting and Formatting

```bash
# Format code
black .

# Check style
flake8 .
pylint mymodule

# Type checking
mypy .

# Security scan
bandit -r .
```

### Testing

```bash
# Run all tests
pytest

# With coverage
pytest --cov=mymodule --cov-report=html

# Specific test file
pytest tests/test_module.py

# Specific test function
pytest tests/test_module.py::test_function_name

# Verbose output
pytest -v
```

### Dependency Management

```bash
# Install dependencies
pip install -r requirements.txt

# Generate requirements from environment
pip freeze > requirements.txt

# Check for vulnerabilities
pip install safety
safety check

# Check for outdated packages
pip list --outdated
```

### Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

---

## Common Mistakes to Avoid

### Mutable Default Arguments

```python
# ✗ BAD
def add_item(item, items=[]):  # Default list shared across calls!
    items.append(item)
    return items

# ✓ GOOD
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Bare Except Clauses

```python
# ✗ BAD
try:
    risky_operation()
except:  # Catches everything, including KeyboardInterrupt!
    pass

# ✓ GOOD
try:
    risky_operation()
except (ValueError, IOError) as e:
    logger.error(f"Operation failed: {e}")
```

### Not Closing Resources

```python
# ✗ BAD
file = open("data.txt")
data = file.read()
# File might not be closed if exception occurs

# ✓ GOOD
with open("data.txt") as file:
    data = file.read()
# File automatically closed
```

### Using `eval()` or `exec()`

```python
# ✗ DANGEROUS
user_input = "os.system('rm -rf /')"
eval(user_input)  # ARBITRARY CODE EXECUTION!

# ✓ SAFE
# Don't use eval/exec with user input
# Use ast.literal_eval() for safe literal evaluation
import ast
data = ast.literal_eval("[1, 2, 3]")  # Only evaluates literals
```

### Ignoring Return Values

```python
# ✗ BAD
subprocess.run(["important-command"])  # Ignores errors

# ✓ GOOD
result = subprocess.run(["important-command"], check=True)
```

### Using `isinstance()` Instead of Duck Typing

```python
# ✗ LESS PYTHONIC
def process(data):
    if isinstance(data, list):
        for item in data:
            print(item)

# ✓ MORE PYTHONIC (duck typing)
def process(data):
    try:
        for item in data:
            print(item)
    except TypeError:
        logger.error("Data is not iterable")
```

---

## Additional Resources

- **PEP 8**: https://peps.python.org/pep-0008/ (Style Guide)
- **PEP 257**: https://peps.python.org/pep-0257/ (Docstring Conventions)
- **Type Hints**: https://docs.python.org/3/library/typing.html
- **Testing**: https://docs.pytest.org/
- **Security**: `Python_Security_Standards_Reference.md`
- **Debugging**: `Python_Debugging_Instructions.md`

---

**Last Updated**: 2025-12-12
**Version**: 2.0
