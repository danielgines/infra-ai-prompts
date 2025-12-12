# SQLAlchemy Security Standards Reference

> **Purpose**: Security standards and best practices for SQLAlchemy applications to prevent SQL injection, data breaches, and unauthorized access.

**Security References**:
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SQLAlchemy Security Best Practices](https://docs.sqlalchemy.org/en/20/faq/security.html)
- [CWE-89: SQL Injection](https://cwe.mitre.org/data/definitions/89.html)

---

## Table of Contents

1. [Critical Security Risks](#critical-security-risks)
2. [SQL Injection Prevention](#sql-injection-prevention)
3. [Sensitive Data Protection](#sensitive-data-protection)
4. [Authentication and Authorization](#authentication-and-authorization)
5. [Connection Security](#connection-security)
6. [Audit and Compliance](#audit-and-compliance)
7. [Security Checklist](#security-checklist)

---

## Critical Security Risks

### Why SQLAlchemy Applications Are High-Risk

Database applications handle sensitive data and are primary targets for attackers. Common attack vectors:

#### 1. SQL Injection

**Risk Level**: CRITICAL

**Description**: Attacker injects malicious SQL through user input to bypass security, extract data, or modify database.

**Real-World Breaches**:
- 2023: MOVEit Transfer SQL injection (millions of records)
- 2022: LastPass breach via SQL injection
- Continuous automated scanning for SQL injection vulnerabilities

#### 2. Sensitive Data Exposure

**Risk Level**: CRITICAL

**Description**: Plaintext storage of passwords, credit cards, PII, or API keys in database.

**Impact**:
- Direct credential theft
- Identity theft
- Regulatory fines (GDPR: up to €20M or 4% revenue)

#### 3. Insecure Direct Object References

**Risk Level**: HIGH

**Description**: Using predictable IDs without authorization checks allows unauthorized data access.

**Example**:
```python
# VULNERABLE: No authorization check
@app.route("/user/<int:user_id>")
def get_user(user_id):
    return session.query(User).get(user_id)
# Attacker can access ANY user by changing ID
```

---

## SQL Injection Prevention

### NEVER Use String Concatenation or F-Strings

**PROHIBITED**:

```python
# CRITICAL VULNERABILITY - SQL Injection
def get_user_by_name(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return session.execute(text(query)).first()

# Attack: username = "admin' OR '1'='1'; --"
# Resulting SQL: SELECT * FROM users WHERE username = 'admin' OR '1'='1'; --'
# Returns: ALL users!

# Attack: username = "'; DROP TABLE users; --"
# Resulting SQL: SELECT * FROM users WHERE username = ''; DROP TABLE users; --'
# Impact: ENTIRE TABLE DELETED!
```

**Why This Is Dangerous**:
- Attacker controls SQL structure
- Bypasses authentication
- Can extract entire database
- Can modify or delete data
- Automated tools constantly scan for this

---

### Secure Methods

#### Method 1: ORM Query API (Recommended)

**Implementation**:

```python
# SECURE - Parameterized via ORM
def get_user_by_name(username):
    return session.query(User).filter(User.username == username).first()

# SQLAlchemy generates: SELECT * FROM users WHERE username = ?
# Parameters bound separately: username value
# Injection impossible - username treated as literal value
```

**Advantages**:
- Automatic parameterization
- Type checking
- No SQL injection possible
- Database-agnostic

#### Method 2: Bound Parameters with text()

**Implementation**:

```python
# SECURE - Explicit parameter binding
from sqlalchemy import text

def get_user_by_name(username):
    query = text("SELECT * FROM users WHERE username = :username")
    return session.execute(query, {"username": username}).first()

# Parameters bound separately, not interpolated into SQL string
```

**Usage**:
```python
# Safe regardless of input
get_user_by_name("admin' OR '1'='1")
# SQL: SELECT * FROM users WHERE username = 'admin'' OR ''1''=''1'
# Treats entire string as literal username (no match)
```

#### Method 3: select() API (SQLAlchemy 2.0+)

**Implementation**:

```python
# SECURE - Modern select() syntax
from sqlalchemy import select

def get_user_by_name(username):
    stmt = select(User).where(User.username == username)
    return session.scalars(stmt).first()
```

---

### Dynamic Column Names (DANGEROUS)

**Problem**: User-controlled column names cannot be parameterized.

```python
# VULNERABLE - Column name from user input
def search_users(search_column, search_value):
    query = f"SELECT * FROM users WHERE {search_column} = :value"
    # Column name cannot be parameterized!
    return session.execute(text(query), {"value": search_value}).all()

# Attack: search_column = "username = 'admin' OR '1'='1' --"
```

**Secure Alternatives**:

```python
# Method 1: Whitelist allowed columns
ALLOWED_COLUMNS = {"username", "email", "id"}

def search_users(search_column, search_value):
    if search_column not in ALLOWED_COLUMNS:
        raise ValueError(f"Invalid column: {search_column}")

    # Use getattr to safely access model attribute
    column = getattr(User, search_column)
    return session.query(User).filter(column == search_value).all()

# Method 2: Map user input to column objects
SEARCH_COLUMNS = {
    "name": User.username,
    "email": User.email,
    "id": User.id
}

def search_users(search_key, search_value):
    column = SEARCH_COLUMNS.get(search_key)
    if column is None:
        raise ValueError(f"Invalid search key: {search_key}")

    return session.query(User).filter(column == search_value).all()
```

---

## Sensitive Data Protection

### Password Storage

**PROHIBITED - Plaintext Passwords**:

```python
# CRITICAL SECURITY VIOLATION
class User(Base):
    __tablename__ = "users"
    password: Mapped[str] = mapped_column(String(128))  # NEVER!

# Storing plaintext
user.password = request.form['password']  # WRONG!
```

**Why This Is Dangerous**:
- Database breach exposes all passwords
- Passwords often reused across services
- Cannot detect breach without audit logs

---

**SECURE - Password Hashing**:

```python
from sqlalchemy.ext.hybrid import hybrid_property
from passlib.hash import bcrypt

class User(Base):
    __tablename__ = "users"

    _password_hash: Mapped[str] = mapped_column(
        "password_hash",
        String(128),
        nullable=False,
        comment="Security: Bcrypt hash of user password (never store plaintext)"
    )

    @hybrid_property
    def password(self):
        """Password is write-only."""
        raise AttributeError("Password is not readable")

    @password.setter
    def password(self, plaintext):
        """Hash password before storing."""
        self._password_hash = bcrypt.hash(plaintext)

    def verify_password(self, plaintext):
        """Verify password against stored hash."""
        return bcrypt.verify(plaintext, self._password_hash)
```

**Usage**:

```python
# Registration
user = User(username="alice")
user.password = "SecurePassword123!"  # Automatically hashed
session.add(user)
session.commit()

# Login verification
user = session.query(User).filter(User.username == username).first()
if user and user.verify_password(provided_password):
    # Login successful
    pass
```

**Best Practices**:
- Use bcrypt, argon2, or scrypt (NOT MD5, SHA1, or plain SHA256)
- Add salt automatically (bcrypt does this)
- Use work factor/cost parameter (bcrypt default: 12 rounds)
- Never log password hashes

---

### Personally Identifiable Information (PII)

**Data Classification**:

| Data Type | Classification | Protection |
|-----------|---------------|------------|
| Password | Secret | Hashed (bcrypt) |
| SSN, Credit Card | Secret | Encrypted at rest |
| Email, Phone | PII | Encrypted or access-controlled |
| Name, Address | PII | Access-controlled |
| User ID | Public | No special protection |

**Encryption at Rest**:

```python
from cryptography.fernet import Fernet
from sqlalchemy.types import TypeDecorator, String

class EncryptedString(TypeDecorator):
    """SQLAlchemy type for encrypted strings."""

    impl = String
    cache_ok = True

    def __init__(self, key, *args, **kwargs):
        self.key = key
        self.fernet = Fernet(key)
        super().__init__(*args, **kwargs)

    def process_bind_param(self, value, dialect):
        """Encrypt before storing."""
        if value is not None:
            value = self.fernet.encrypt(value.encode()).decode()
        return value

    def process_result_value(self, value, dialect):
        """Decrypt when retrieving."""
        if value is not None:
            value = self.fernet.decrypt(value.encode()).decode()
        return value

# Usage
import os
ENCRYPTION_KEY = os.environ["DB_ENCRYPTION_KEY"]

class User(Base):
    ssn: Mapped[Optional[str]] = mapped_column(
        EncryptedString(ENCRYPTION_KEY, 255),
        comment="PII: Social Security Number (encrypted at rest)"
    )
```

---

## Authentication and Authorization

### Authorization Checks

**INSECURE - No Authorization**:

```python
# VULNERABLE: Any user can access any data
@app.route("/user/<int:user_id>/profile")
def get_profile(user_id):
    user = session.query(User).get(user_id)
    return jsonify(user.to_dict())

# Attack: Change user_id in URL to access other users
# GET /user/42/profile → Access user 42's data
```

**SECURE - Authorization Check**:

```python
@app.route("/user/<int:user_id>/profile")
@login_required
def get_profile(user_id):
    # Verify user can access this profile
    if current_user.id != user_id and not current_user.is_admin:
        abort(403)  # Forbidden

    user = session.query(User).get(user_id)
    return jsonify(user.to_dict())
```

**Role-Based Access Control (RBAC)**:

```python
class User(Base):
    role: Mapped[str] = mapped_column(
        String(20),
        default="user",
        comment="Authorization: User role (user, moderator, admin)"
    )

    def has_permission(self, permission):
        """Check if user has specific permission."""
        ROLE_PERMISSIONS = {
            "user": ["read_own", "write_own"],
            "moderator": ["read_own", "write_own", "read_all", "moderate"],
            "admin": ["read_own", "write_own", "read_all", "write_all", "delete_all"]
        }
        return permission in ROLE_PERMISSIONS.get(self.role, [])

# Usage
@app.route("/admin/users")
@login_required
def list_all_users():
    if not current_user.has_permission("read_all"):
        abort(403)

    users = session.query(User).all()
    return jsonify([u.to_dict() for u in users])
```

---

## Connection Security

### Secure Connection Strings

**INSECURE - Hardcoded Credentials**:

```python
# CRITICAL VULNERABILITY
engine = create_engine("postgresql://admin:Password123@localhost/production")
# Credentials in code, visible in version control!
```

**SECURE - Environment Variables**:

```python
import os

DATABASE_URL = os.environ["DATABASE_URL"]
engine = create_engine(DATABASE_URL)

# Or use explicit components
DB_HOST = os.environ["DB_HOST"]
DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
DB_NAME = os.environ["DB_NAME"]

engine = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}")
```

### SSL/TLS Connections

```python
# PostgreSQL with SSL
engine = create_engine(
    "postgresql://user:pass@host/db",
    connect_args={
        "sslmode": "require",
        "sslrootcert": "/path/to/ca.pem"
    }
)

# MySQL with SSL
engine = create_engine(
    "mysql+pymysql://user:pass@host/db",
    connect_args={
        "ssl": {
            "ca": "/path/to/ca.pem",
            "cert": "/path/to/client-cert.pem",
            "key": "/path/to/client-key.pem"
        }
    }
)
```

---

## Audit and Compliance

### Audit Logging

```python
from datetime import datetime

class AuditMixin:
    """Mixin for audit logging."""

    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(),
        comment="Audit: Record creation timestamp"
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        onupdate=func.now(),
        comment="Audit: Last modification timestamp"
    )
    created_by_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("users.id"),
        comment="Audit: User who created this record"
    )

class User(Base, AuditMixin):
    __tablename__ = "users"
    # ...

# Track modifications
from sqlalchemy import event

@event.listens_for(User, "before_insert")
@event.listens_for(User, "before_update")
def log_changes(mapper, connection, target):
    """Log all changes to audit table."""
    audit_log = AuditLog(
        table_name="users",
        record_id=target.id,
        action="INSERT" if target.id is None else "UPDATE",
        changed_by=current_user.id,
        timestamp=datetime.utcnow()
    )
    # Insert into audit_log table
```

---

## Security Checklist

### Before Deployment

- [ ] **No SQL injection**: All queries use ORM or bound parameters
- [ ] **Passwords hashed**: Using bcrypt/argon2 with hybrid_property
- [ ] **PII encrypted**: Sensitive data encrypted at rest
- [ ] **Authorization checks**: Every endpoint validates user permissions
- [ ] **Secure connections**: SSL/TLS enabled for database connections
- [ ] **No hardcoded secrets**: Credentials from environment variables
- [ ] **Audit logging**: Critical operations logged
- [ ] **Rate limiting**: Prevent brute force attacks
- [ ] **Input validation**: All user input validated and sanitized
- [ ] **Error handling**: No sensitive data in error messages

### During Development

- [ ] Use parameterized queries only
- [ ] Never log passwords or sensitive data
- [ ] Validate all user input
- [ ] Use least privilege database accounts
- [ ] Enable SQL query logging (development only)
- [ ] Regular security updates (sqlalchemy, drivers)

### After Deployment

- [ ] Monitor for suspicious queries
- [ ] Regular security audits
- [ ] Penetration testing
- [ ] Keep dependencies updated
- [ ] Review audit logs
- [ ] Incident response plan ready

---

## Quick Reference: Secure vs Insecure Patterns

| Pattern | Insecure | Secure |
|---------|----------|--------|
| **Queries** | f-strings, % formatting | ORM filters, bound parameters |
| **Passwords** | Plaintext in column | bcrypt hash with hybrid_property |
| **Connection** | Hardcoded in code | Environment variables |
| **PII** | Stored plaintext | Encrypted with Fernet |
| **Authorization** | No checks | Role-based access control |
| **Dynamic columns** | User input in SQL | Whitelist + getattr |

---

## References

- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [SQLAlchemy Security FAQ](https://docs.sqlalchemy.org/en/20/faq/security.html)
- [NIST Password Guidelines](https://pages.nist.gov/800-63-3/)
- [GDPR Compliance](https://gdpr.eu/)
- [CIS Database Security Benchmark](https://www.cisecurity.org/)

---

**Last Updated**: 2025-12-11
**Review Schedule**: Quarterly
