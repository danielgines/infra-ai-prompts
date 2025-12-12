# Python Security Standards Reference

> **Purpose**: Security best practices for Python applications to prevent common vulnerabilities.

## Table of Contents

1. [Input Validation](#input-validation)
2. [SQL Injection Prevention](#sql-injection-prevention)
3. [Command Injection Prevention](#command-injection-prevention)
4. [Path Traversal Prevention](#path-traversal-prevention)
5. [Secrets Management](#secrets-management)
6. [Dependency Security](#dependency-security)

---

## Input Validation

### Always Validate User Input

```python
# BAD - No validation
def set_age(age):
    self.age = age

# GOOD - Validation
def set_age(age: int) -> None:
    """Set user age with validation."""
    if not isinstance(age, int):
        raise TypeError("Age must be integer")
    if age < 0 or age > 150:
        raise ValueError("Age must be 0-150")
    self.age = age
```

---

## SQL Injection Prevention

### NEVER Use String Formatting for SQL

**PROHIBITED**:
```python
# CRITICAL VULNERABILITY
query = f"SELECT * FROM users WHERE id = {user_id}"
query = "SELECT * FROM users WHERE id = %s" % user_id
query = "SELECT * FROM users WHERE id = " + str(user_id)
```

**SECURE**:
```python
# Use ORM
user = session.query(User).filter(User.id == user_id).first()

# Or parameterized queries
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
```

---

## Command Injection Prevention

### Use subprocess with List Arguments

**PROHIBITED**:
```python
# CRITICAL - Command injection
import os
os.system(f"ls {directory}")
```

**SECURE**:
```python
import subprocess
subprocess.run(["ls", directory], check=True, capture_output=True)
```

---

## Path Traversal Prevention

```python
from pathlib import Path

def read_file(filename: str) -> str:
    """Read file securely preventing path traversal."""
    base_dir = Path("/uploads").resolve()
    file_path = (base_dir / filename).resolve()
    
    # Verify path is within base_dir
    if not str(file_path).startswith(str(base_dir)):
        raise ValueError("Invalid filename")
    
    return file_path.read_text()
```

---

## Secrets Management

**PROHIBITED**:
```python
# Hardcoded secrets
API_KEY = "sk_live_abc123"
DB_PASSWORD = "MyPassword123"
```

**SECURE**:
```python
import os
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.environ["API_KEY"]
DB_PASSWORD = os.environ.get("DB_PASSWORD")
```

---

## Dependency Security

```bash
# Check for vulnerabilities
pip install safety
safety check

# Keep dependencies updated
pip list --outdated
pip install --upgrade package_name
```

---

## Security Checklist

- [ ] All user input validated
- [ ] No SQL string formatting
- [ ] No os.system() or shell=True
- [ ] Path traversal prevented
- [ ] Secrets in environment variables
- [ ] Dependencies regularly updated
- [ ] HTTPS for all external requests

---

**Last Updated**: 2025-12-11
