# Python Security Standards Reference

> **Purpose**: Comprehensive security standards and patterns for Python applications to prevent OWASP Top 10 vulnerabilities and common security issues.

---

## Table of Contents

1. [Critical Security Principles](#critical-security-principles)
2. [Credential and Secrets Management](#credential-and-secrets-management)
3. [Input Validation and Sanitization](#input-validation-and-sanitization)
4. [Injection Prevention](#injection-prevention)
5. [Cryptography Standards](#cryptography-standards)
6. [Authentication and Authorization](#authentication-and-authorization)
7. [Session Management](#session-management)
8. [Web Application Security](#web-application-security)
9. [File Operations Security](#file-operations-security)
10. [Deserialization Security](#deserialization-security)
11. [Dependency and Supply Chain Security](#dependency-and-supply-chain-security)
12. [Logging and Error Handling Security](#logging-and-error-handling-security)
13. [API Security](#api-security)
14. [Real-World Security Breaches](#real-world-security-breaches)
15. [Security Audit Checklist](#security-audit-checklist)

---

## Critical Security Principles

### Defense in Depth

Implement multiple layers of security:

1. **Input Validation**: Validate all user inputs
2. **Access Control**: Implement proper authorization
3. **Encryption**: Encrypt sensitive data at rest and in transit
4. **Logging**: Log security events for audit
5. **Monitoring**: Detect and respond to suspicious activity
6. **Least Privilege**: Grant minimum necessary permissions

### Principle of Least Privilege

```python
# BAD - Overly permissive
file = open("config.txt", "w+")  # Unnecessary write permissions

# GOOD - Minimal permissions
file = open("config.txt", "r")  # Read-only when only reading
```

### Fail Securely

```python
# BAD - Fails open (grants access on error)
def check_permission(user_id: int) -> bool:
    try:
        return database.is_admin(user_id)
    except Exception:
        return True  # DANGER: Grants access on error!

# GOOD - Fails closed (denies access on error)
def check_permission(user_id: int) -> bool:
    try:
        return database.is_admin(user_id)
    except Exception as e:
        logger.error(f"Permission check failed: {e}")
        return False  # Deny access on error
```

---

## Credential and Secrets Management

### 1. Environment Variables (Recommended for Development)

```python
import os
from typing import Optional

def get_required_secret(key: str) -> str:
    """
    Get required secret from environment variable.

    Raises:
        RuntimeError: If secret not set or empty
    """
    value = os.environ.get(key)

    if value is None:
        raise RuntimeError(
            f"Required secret {key} not set. "
            f"Set it with: export {key}=your_value"
        )

    if not value.strip():
        raise RuntimeError(f"Secret {key} is empty")

    return value

# Usage
DATABASE_PASSWORD = get_required_secret("DB_PASSWORD")
API_KEY = get_required_secret("API_KEY")
```

### 2. dotenv Files (Development Only)

```python
from dotenv import load_dotenv
import os

# Load from .env file (NEVER commit .env to git!)
load_dotenv()

# Add to .gitignore:
# .env
# .env.local
# *.key
# *.pem

DATABASE_URL = os.getenv("DATABASE_URL")
```

### 3. Secret Management Services (Production)

```python
import boto3
from botocore.exceptions import ClientError

def get_secret_from_aws(secret_name: str) -> str:
    """
    Retrieve secret from AWS Secrets Manager.

    Production-grade secret management.
    """
    client = boto3.client('secretsmanager')

    try:
        response = client.get_secret_value(SecretId=secret_name)
        return response['SecretString']
    except ClientError as e:
        logger.error(f"Failed to retrieve secret {secret_name}: {e}")
        raise

# Usage
DATABASE_PASSWORD = get_secret_from_aws("prod/db/password")
```

```python
# HashiCorp Vault example
import hvac

def get_secret_from_vault(path: str, key: str) -> str:
    """Retrieve secret from HashiCorp Vault."""
    client = hvac.Client(url='https://vault.example.com')
    client.token = os.environ['VAULT_TOKEN']

    secret = client.secrets.kv.v2.read_secret_version(path=path)
    return secret['data']['data'][key]

# Usage
API_KEY = get_secret_from_vault('secret/api', 'key')
```

### 4. Never Hardcode Secrets

```python
# CRITICAL VULNERABILITY - NEVER DO THIS
API_KEY = "sk_live_abc123def456"  # ❌ HARDCODED
DB_PASSWORD = "MyPassword123"      # ❌ HARDCODED
AWS_SECRET = "wJalrXUtnFEMI/K7M"  # ❌ HARDCODED

# SECURE
API_KEY = os.environ["API_KEY"]           # ✓ From environment
DB_PASSWORD = get_secret("db_password")    # ✓ From secret manager
```

### 5. Secret Scanning

```bash
# Scan for accidentally committed secrets
pip install detect-secrets
detect-secrets scan > .secrets.baseline

# Add pre-commit hook
pip install pre-commit
# .pre-commit-config.yaml:
# - repo: https://github.com/Yelp/detect-secrets
#   hooks:
#     - id: detect-secrets
```

---

## Input Validation and Sanitization

### 1. Type Validation with Type Hints

```python
from typing import Annotated
from pydantic import BaseModel, Field, validator

class UserInput(BaseModel):
    """Validated user input using Pydantic."""

    username: Annotated[str, Field(min_length=3, max_length=50)]
    email: Annotated[str, Field(regex=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    age: Annotated[int, Field(ge=0, le=150)]

    @validator('username')
    def username_alphanumeric(cls, v):
        if not v.isalnum():
            raise ValueError('Username must be alphanumeric')
        return v

# Usage
try:
    user = UserInput(
        username="john_doe",  # Will fail - contains underscore
        email="john@example.com",
        age=25
    )
except ValidationError as e:
    logger.error(f"Invalid input: {e}")
```

### 2. Whitelist Validation

```python
from enum import Enum

class AllowedSortField(str, Enum):
    """Whitelist of allowed sort fields."""
    NAME = "name"
    DATE = "created_at"
    PRICE = "price"

def sort_products(sort_field: str):
    """Sort products with whitelist validation."""

    # BAD - Arbitrary SQL injection risk
    # query = f"SELECT * FROM products ORDER BY {sort_field}"

    # GOOD - Whitelist validation
    try:
        validated_field = AllowedSortField(sort_field)
    except ValueError:
        raise ValueError(f"Invalid sort field. Allowed: {[e.value for e in AllowedSortField]}")

    query = f"SELECT * FROM products ORDER BY {validated_field.value}"
    return execute_query(query)
```

### 3. Input Sanitization

```python
import re
from html import escape

def sanitize_user_input(user_input: str) -> str:
    """Sanitize user input to prevent XSS."""

    # Remove null bytes
    sanitized = user_input.replace('\x00', '')

    # Escape HTML entities
    sanitized = escape(sanitized)

    # Remove control characters
    sanitized = ''.join(char for char in sanitized if ord(char) >= 32 or char in '\n\r\t')

    return sanitized

def validate_filename(filename: str) -> str:
    """Validate and sanitize filename."""

    # Remove path separators
    filename = filename.replace('/', '').replace('\\', '')

    # Remove null bytes and special characters
    filename = re.sub(r'[^\w\s.-]', '', filename)

    # Limit length
    if len(filename) > 255:
        raise ValueError("Filename too long")

    # Prevent hidden files
    if filename.startswith('.'):
        raise ValueError("Hidden files not allowed")

    return filename
```

---

## Injection Prevention

### 1. SQL Injection Prevention

#### Always Use Parameterized Queries

```python
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session

# CRITICAL VULNERABILITY - SQL Injection
def get_user_unsafe(user_id: str):
    query = f"SELECT * FROM users WHERE id = {user_id}"  # ❌ VULNERABLE
    # Attacker input: "1 OR 1=1" - returns all users
    # Attacker input: "1; DROP TABLE users; --" - deletes table
    return engine.execute(query)

# SECURE - Parameterized query with SQLAlchemy
def get_user_safe(user_id: int):
    with Session(engine) as session:
        query = text("SELECT * FROM users WHERE id = :user_id")
        result = session.execute(query, {"user_id": user_id})
        return result.fetchone()

# SECURE - ORM (Best Practice)
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String)

def get_user_orm(user_id: int):
    with Session(engine) as session:
        return session.query(User).filter(User.id == user_id).first()
```

#### Dynamic Table/Column Names (Advanced)

```python
from sqlalchemy import MetaData, Table

ALLOWED_TABLES = ['users', 'products', 'orders']
ALLOWED_COLUMNS = ['id', 'name', 'created_at', 'price']

def get_records(table_name: str, column_name: str):
    """Query with dynamic table/column names (whitelisted)."""

    # Validate table name against whitelist
    if table_name not in ALLOWED_TABLES:
        raise ValueError(f"Invalid table: {table_name}")

    # Validate column name against whitelist
    if column_name not in ALLOWED_COLUMNS:
        raise ValueError(f"Invalid column: {column_name}")

    # Use SQLAlchemy metadata to safely reference table
    metadata = MetaData()
    table = Table(table_name, metadata, autoload_with=engine)

    query = select(getattr(table.c, column_name))
    return session.execute(query).fetchall()
```

### 2. Command Injection Prevention

```python
import subprocess
import shlex
from pathlib import Path

# CRITICAL VULNERABILITY - Command Injection
def backup_file_unsafe(filename: str):
    command = f"tar -czf backup.tar.gz {filename}"  # ❌ VULNERABLE
    # Attacker input: "file.txt; rm -rf /" - deletes system
    os.system(command)

# SECURE - Use subprocess with list arguments
def backup_file_safe(filename: str):
    """Safe command execution."""

    # Validate filename
    file_path = Path(filename).resolve()
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {filename}")

    # Use subprocess with list (NOT string)
    result = subprocess.run(
        ["tar", "-czf", "backup.tar.gz", str(file_path)],
        check=True,
        capture_output=True,
        text=True,
        timeout=300
    )

    return result.stdout

# If shell=True is ABSOLUTELY necessary (avoid if possible)
def run_shell_command_if_unavoidable(user_input: str):
    """
    Only use shell=True if absolutely necessary.
    ALWAYS sanitize input with shlex.quote().
    """

    # Sanitize input
    safe_input = shlex.quote(user_input)

    # Still risky - avoid if possible
    command = f"echo {safe_input}"

    result = subprocess.run(
        command,
        shell=True,
        check=True,
        capture_output=True,
        text=True,
        timeout=30
    )

    return result.stdout
```

### 3. NoSQL Injection Prevention

```python
from pymongo import MongoClient
from bson import ObjectId

# VULNERABLE - NoSQL injection
def find_user_unsafe(username: str):
    db = MongoClient()['mydb']
    # If username = {"$ne": null}, returns all users
    return db.users.find_one({"username": username})  # ❌ VULNERABLE

# SECURE - Type validation
def find_user_safe(username: str):
    """Prevent NoSQL injection with type validation."""

    if not isinstance(username, str):
        raise TypeError("Username must be a string")

    # Ensure username is not a dict (MongoDB operator injection)
    if isinstance(username, dict):
        raise ValueError("Invalid username format")

    db = MongoClient()['mydb']
    return db.users.find_one({"username": username})  # ✓ SAFE

# SECURE - Parameterized queries with PyMongo
def find_user_by_id(user_id: str):
    """Safe MongoDB query."""

    try:
        object_id = ObjectId(user_id)
    except Exception:
        raise ValueError("Invalid user ID format")

    db = MongoClient()['mydb']
    return db.users.find_one({"_id": object_id})
```

### 4. LDAP Injection Prevention

```python
import ldap
import ldap.filter

# VULNERABLE
def authenticate_user_unsafe(username: str, password: str):
    conn = ldap.initialize('ldap://ldap.example.com')
    # Attacker input: username = "*)(uid=*" - bypasses auth
    dn = f"uid={username},ou=users,dc=example,dc=com"  # ❌ VULNERABLE
    conn.simple_bind_s(dn, password)

# SECURE
def authenticate_user_safe(username: str, password: str):
    """Prevent LDAP injection."""

    conn = ldap.initialize('ldap://ldap.example.com')

    # Escape LDAP special characters
    safe_username = ldap.filter.escape_filter_chars(username)

    dn = f"uid={safe_username},ou=users,dc=example,dc=com"

    try:
        conn.simple_bind_s(dn, password)
        return True
    except ldap.INVALID_CREDENTIALS:
        return False
```

---

## Cryptography Standards

### 1. Password Hashing (NEVER use MD5/SHA1)

```python
import bcrypt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

# INSECURE - NEVER DO THIS
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()  # ❌ BROKEN
password_hash = hashlib.sha1(password.encode()).hexdigest()  # ❌ BROKEN

# SECURE - bcrypt (Good)
def hash_password_bcrypt(password: str) -> bytes:
    """Hash password using bcrypt."""
    salt = bcrypt.gensalt(rounds=12)  # Cost factor 12 (2^12 iterations)
    return bcrypt.hashpw(password.encode(), salt)

def verify_password_bcrypt(password: str, hashed: bytes) -> bool:
    """Verify password against bcrypt hash."""
    return bcrypt.checkpw(password.encode(), hashed)

# SECURE - Argon2 (Best - winner of Password Hashing Competition)
ph = PasswordHasher(
    time_cost=2,      # Iterations
    memory_cost=65536, # Memory in KiB
    parallelism=4      # Threads
)

def hash_password_argon2(password: str) -> str:
    """Hash password using Argon2."""
    return ph.hash(password)

def verify_password_argon2(password: str, hashed: str) -> bool:
    """Verify password against Argon2 hash."""
    try:
        ph.verify(hashed, password)
        return True
    except VerifyMismatchError:
        return False
```

### 2. Encryption (Data at Rest)

```python
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import base64
import os

def generate_key_from_password(password: str, salt: bytes = None) -> tuple[bytes, bytes]:
    """
    Derive encryption key from password using PBKDF2.

    Returns:
        (key, salt) tuple
    """
    if salt is None:
        salt = os.urandom(16)

    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,  # OWASP recommends 100,000+
    )

    key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
    return key, salt

def encrypt_data(data: str, key: bytes) -> bytes:
    """Encrypt data using Fernet (AES-128-CBC)."""
    f = Fernet(key)
    return f.encrypt(data.encode())

def decrypt_data(encrypted_data: bytes, key: bytes) -> str:
    """Decrypt data using Fernet."""
    f = Fernet(key)
    return f.decrypt(encrypted_data).decode()

# Usage
password = os.environ["ENCRYPTION_PASSWORD"]
key, salt = generate_key_from_password(password)

# Encrypt
encrypted = encrypt_data("sensitive data", key)

# Decrypt (need same password and salt)
key_for_decrypt, _ = generate_key_from_password(password, salt)
decrypted = decrypt_data(encrypted, key_for_decrypt)
```

### 3. Secure Random Number Generation

```python
import secrets
import random

# INSECURE - Predictable PRNG
token = str(random.randint(100000, 999999))  # ❌ NOT CRYPTOGRAPHICALLY SECURE

# SECURE - Cryptographically secure random
token = secrets.token_hex(32)  # 64 character hex string
token = secrets.token_urlsafe(32)  # URL-safe base64 string

# Generate secure random password
def generate_secure_password(length: int = 16) -> str:
    """Generate cryptographically secure random password."""
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    return ''.join(secrets.choice(alphabet) for _ in range(length))
```

---

## Authentication and Authorization

### 1. JWT Token Security

```python
import jwt
from datetime import datetime, timedelta
from typing import Dict, Any

JWT_SECRET = os.environ["JWT_SECRET"]  # Must be cryptographically random
JWT_ALGORITHM = "HS256"
TOKEN_EXPIRY_MINUTES = 30

def create_jwt_token(user_id: int, role: str) -> str:
    """Create JWT token with expiration."""

    payload = {
        "user_id": user_id,
        "role": role,
        "exp": datetime.utcnow() + timedelta(minutes=TOKEN_EXPIRY_MINUTES),
        "iat": datetime.utcnow(),
        "jti": secrets.token_hex(16)  # JWT ID (prevents replay attacks)
    }

    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def verify_jwt_token(token: str) -> Dict[str, Any]:
    """Verify and decode JWT token."""

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise ValueError("Token has expired")
    except jwt.InvalidTokenError:
        raise ValueError("Invalid token")

# Usage with Flask
from flask import Flask, request, jsonify
from functools import wraps

def require_auth(f):
    """Decorator to require authentication."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')

        if not token:
            return jsonify({"error": "No token provided"}), 401

        try:
            payload = verify_jwt_token(token)
            request.user_id = payload['user_id']
            request.user_role = payload['role']
        except ValueError as e:
            return jsonify({"error": str(e)}), 401

        return f(*args, **kwargs)

    return decorated

@app.route('/api/protected')
@require_auth
def protected_endpoint():
    return jsonify({"user_id": request.user_id})
```

### 2. Role-Based Access Control (RBAC)

```python
from enum import Enum
from functools import wraps

class Role(str, Enum):
    ADMIN = "admin"
    USER = "user"
    GUEST = "guest"

class Permission(str, Enum):
    READ = "read"
    WRITE = "write"
    DELETE = "delete"

# Role-Permission mapping
ROLE_PERMISSIONS = {
    Role.ADMIN: {Permission.READ, Permission.WRITE, Permission.DELETE},
    Role.USER: {Permission.READ, Permission.WRITE},
    Role.GUEST: {Permission.READ}
}

def require_permission(required_permission: Permission):
    """Decorator to require specific permission."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            user_role = request.user_role  # From JWT token

            if user_role not in ROLE_PERMISSIONS:
                return jsonify({"error": "Invalid role"}), 403

            if required_permission not in ROLE_PERMISSIONS[user_role]:
                return jsonify({"error": "Insufficient permissions"}), 403

            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/api/data', methods=['DELETE'])
@require_auth
@require_permission(Permission.DELETE)
def delete_data():
    # Only admins can access (only they have DELETE permission)
    return jsonify({"message": "Deleted"})
```

---

## Session Management

### 1. Secure Session Configuration

```python
from flask import Flask, session
from datetime import timedelta

app = Flask(__name__)

# Session security settings
app.config.update(
    SECRET_KEY=os.environ["SESSION_SECRET"],  # Cryptographically random
    SESSION_COOKIE_SECURE=True,    # Only send over HTTPS
    SESSION_COOKIE_HTTPONLY=True,  # Prevent JavaScript access
    SESSION_COOKIE_SAMESITE='Lax', # CSRF protection
    PERMANENT_SESSION_LIFETIME=timedelta(minutes=30),  # Session timeout
    SESSION_COOKIE_NAME='__Secure-session'  # Obscure cookie name
)

@app.route('/login', methods=['POST'])
def login():
    """Secure login with session."""

    username = request.form.get('username')
    password = request.form.get('password')

    # Verify credentials
    user = authenticate_user(username, password)

    if user:
        # Regenerate session ID (prevent session fixation)
        session.clear()
        session.permanent = True

        # Store minimal data in session
        session['user_id'] = user.id
        session['role'] = user.role

        return jsonify({"message": "Login successful"})

    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/logout')
def logout():
    """Secure logout."""
    session.clear()  # Clear all session data
    return jsonify({"message": "Logged out"})
```

### 2. Session Timeout and Idle Detection

```python
from datetime import datetime

def check_session_timeout():
    """Check if session has timed out."""

    if 'last_activity' not in session:
        session['last_activity'] = datetime.utcnow().isoformat()
        return False

    last_activity = datetime.fromisoformat(session['last_activity'])
    idle_time = (datetime.utcnow() - last_activity).total_seconds()

    IDLE_TIMEOUT_SECONDS = 900  # 15 minutes

    if idle_time > IDLE_TIMEOUT_SECONDS:
        session.clear()
        return True  # Session timed out

    # Update last activity
    session['last_activity'] = datetime.utcnow().isoformat()
    return False

@app.before_request
def before_request():
    """Check session timeout before each request."""
    if check_session_timeout():
        return jsonify({"error": "Session timeout"}), 401
```

---

## Web Application Security

### 1. XSS (Cross-Site Scripting) Prevention

```python
from markupsafe import escape
from html import escape as html_escape
import bleach

# VULNERABLE - XSS
@app.route('/profile')
def profile_unsafe():
    username = request.args.get('name')
    # If name = "<script>alert('XSS')</script>", executes malicious script
    return f"<h1>Welcome {username}</h1>"  # ❌ VULNERABLE

# SECURE - Escape output
@app.route('/profile')
def profile_safe():
    username = request.args.get('name')
    safe_username = escape(username)  # Escapes HTML entities
    return f"<h1>Welcome {safe_username}</h1>"  # ✓ SAFE

# SECURE - Template auto-escaping (Flask/Jinja2)
@app.route('/profile')
def profile_template():
    username = request.args.get('name')
    # Jinja2 auto-escapes by default
    return render_template('profile.html', username=username)

# For rich text content (allow some HTML tags)
def sanitize_html(content: str) -> str:
    """Sanitize HTML content, allowing safe tags only."""

    allowed_tags = ['p', 'br', 'strong', 'em', 'u', 'a', 'ul', 'ol', 'li']
    allowed_attributes = {'a': ['href', 'title']}

    return bleach.clean(
        content,
        tags=allowed_tags,
        attributes=allowed_attributes,
        strip=True
    )
```

### 2. CSRF (Cross-Site Request Forgery) Prevention

```python
from flask_wtf.csrf import CSRFProtect
import secrets

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ["SECRET_KEY"]

# Enable CSRF protection globally
csrf = CSRFProtect(app)

# For forms (automatically handled by Flask-WTF)
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField

class ProfileForm(FlaskForm):
    """Form with automatic CSRF protection."""
    username = StringField('Username')
    submit = SubmitField('Save')

@app.route('/profile', methods=['GET', 'POST'])
def profile():
    form = ProfileForm()

    if form.validate_on_submit():  # Validates CSRF token
        # Safe to process form
        return jsonify({"message": "Profile updated"})

    return render_template('profile.html', form=form)

# For AJAX/API endpoints
@app.route('/api/data', methods=['POST'])
def api_endpoint():
    """API endpoint with CSRF protection."""

    # Get CSRF token from header
    token = request.headers.get('X-CSRF-Token')

    if not csrf.validate_token(token):
        return jsonify({"error": "Invalid CSRF token"}), 403

    # Process request
    return jsonify({"message": "Success"})
```

### 3. Clickjacking Prevention

```python
@app.after_request
def set_security_headers(response):
    """Set security headers on all responses."""

    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'DENY'
    # Or allow only same origin:
    # response.headers['X-Frame-Options'] = 'SAMEORIGIN'

    # Content Security Policy
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "font-src 'self'; "
        "connect-src 'self'; "
        "frame-ancestors 'none';"
    )

    # Prevent MIME type sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'

    # Enable XSS filter
    response.headers['X-XSS-Protection'] = '1; mode=block'

    # HTTPS only (if applicable)
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'

    return response
```

---

## File Operations Security

### 1. Path Traversal Prevention

```python
from pathlib import Path
import os

UPLOAD_DIR = Path("/var/www/uploads").resolve()

def read_file_safe(filename: str) -> str:
    """Read file preventing path traversal attacks."""

    # Resolve to absolute path
    file_path = (UPLOAD_DIR / filename).resolve()

    # Verify file is within allowed directory
    if not str(file_path).startswith(str(UPLOAD_DIR)):
        raise ValueError("Path traversal attempt detected")

    # Verify file exists
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {filename}")

    # Verify it's a file (not directory)
    if not file_path.is_file():
        raise ValueError("Not a file")

    return file_path.read_text()

# Test cases
# read_file_safe("document.txt")  # ✓ OK
# read_file_safe("../../../etc/passwd")  # ✗ Blocked
# read_file_safe("/etc/passwd")  # ✗ Blocked
```

### 2. File Upload Security

```python
from werkzeug.utils import secure_filename
import mimetypes

ALLOWED_EXTENSIONS = {'pdf', 'png', 'jpg', 'jpeg', 'gif', 'doc', 'docx'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB

def allowed_file(filename: str) -> bool:
    """Check if file extension is allowed."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def validate_file_upload(file) -> tuple[bool, str]:
    """
    Validate uploaded file for security.

    Returns:
        (is_valid, error_message)
    """

    # Check if file exists
    if not file or not file.filename:
        return False, "No file provided"

    # Validate filename
    if not allowed_file(file.filename):
        return False, f"File type not allowed. Allowed: {ALLOWED_EXTENSIONS}"

    # Check file size
    file.seek(0, os.SEEK_END)
    size = file.tell()
    file.seek(0)

    if size > MAX_FILE_SIZE:
        return False, f"File too large (max {MAX_FILE_SIZE / 1024 / 1024}MB)"

    # Validate MIME type
    mime_type = mimetypes.guess_type(file.filename)[0]
    if mime_type and not mime_type.startswith(('image/', 'application/pdf', 'application/msword')):
        return False, "Invalid file type"

    return True, "Valid"

@app.route('/upload', methods=['POST'])
def upload_file():
    """Secure file upload endpoint."""

    file = request.files.get('file')

    # Validate file
    is_valid, error_message = validate_file_upload(file)
    if not is_valid:
        return jsonify({"error": error_message}), 400

    # Sanitize filename
    filename = secure_filename(file.filename)

    # Generate unique filename to prevent overwrites
    unique_filename = f"{secrets.token_hex(8)}_{filename}"

    # Save file
    file_path = UPLOAD_DIR / unique_filename
    file.save(file_path)

    # Set restrictive permissions
    os.chmod(file_path, 0o644)

    return jsonify({"message": "File uploaded", "filename": unique_filename})
```

---

## Deserialization Security

### 1. Pickle Security (NEVER use with untrusted data)

```python
import pickle
import json

# CRITICAL VULNERABILITY - Remote Code Execution
def load_user_data_unsafe(data: bytes):
    return pickle.loads(data)  # ❌ ARBITRARY CODE EXECUTION

# Attacker can execute arbitrary Python code:
# class Exploit:
#     def __reduce__(self):
#         return (os.system, ('rm -rf /',))
# pickle.dumps(Exploit())  # This would delete everything!

# SECURE - Use JSON instead
def load_user_data_safe(data: str):
    """Use JSON for untrusted data."""
    return json.loads(data)  # ✓ SAFE

# If you MUST use pickle (trusted data only):
def load_pickle_safely(data: bytes):
    """
    Only use pickle for trusted, authenticated data.
    NEVER with user-provided input.
    """

    # Verify data authenticity first (HMAC, signature, etc.)
    if not verify_data_signature(data):
        raise ValueError("Data signature invalid")

    return pickle.loads(data)
```

### 2. YAML Security

```python
import yaml

# VULNERABLE
def load_config_unsafe(yaml_string: str):
    return yaml.load(yaml_string)  # ❌ CODE EXECUTION POSSIBLE

# SECURE
def load_config_safe(yaml_string: str):
    """Use safe_load for untrusted YAML."""
    return yaml.safe_load(yaml_string)  # ✓ SAFE
```

---

## Dependency and Supply Chain Security

### 1. Dependency Scanning

```bash
# Check for known vulnerabilities
pip install safety
safety check

# Check outdated packages
pip list --outdated

# Use pip-audit (more comprehensive)
pip install pip-audit
pip-audit

# Snyk (commercial, free tier available)
pip install snyk
snyk test
```

### 2. requirements.txt Security

```txt
# Pin exact versions
requests==2.28.2
flask==2.3.2
sqlalchemy==2.0.15

# Use hash checking (pip-compile)
# requirements.in:
# requests
# flask

# Generate with hashes:
# pip-compile --generate-hashes requirements.in

# Install with hash verification:
# pip install --require-hashes -r requirements.txt
```

### 3. Virtual Environment Isolation

```bash
# Always use virtual environments
python3 -m venv venv
source venv/bin/activate

# Never install packages globally
# Never run pip with sudo
```

---

## Logging and Error Handling Security

### 1. Secure Logging

```python
import logging
import re

def setup_secure_logging():
    """Configure logging without exposing sensitive data."""

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[logging.FileHandler('app.log')]
    )

# INSECURE - Logs sensitive data
def process_payment_unsafe(card_number: str, cvv: str):
    logger.info(f"Processing payment for card {card_number}")  # ❌ LOGS PII
    logger.info(f"CVV: {cvv}")  # ❌ CRITICAL - LOGS CVV

# SECURE - Mask sensitive data
def mask_card_number(card_number: str) -> str:
    """Mask card number for logging."""
    if len(card_number) < 8:
        return "*" * len(card_number)
    return f"{'*' * (len(card_number) - 4)}{card_number[-4:]}"

def process_payment_safe(card_number: str, cvv: str):
    masked_card = mask_card_number(card_number)
    logger.info(f"Processing payment for card {masked_card}")  # ✓ SAFE
    # NEVER log CVV

    # Process payment
    result = charge_card(card_number, cvv)

    # Log outcome only
    logger.info(f"Payment {'successful' if result else 'failed'} for card {masked_card}")
```

### 2. Error Handling (Don't Reveal System Information)

```python
# INSECURE - Reveals system information
@app.errorhandler(500)
def internal_error_unsafe(error):
    # Exposes stack trace, file paths, library versions to attacker
    return str(error), 500  # ❌ DANGEROUS

# SECURE - Generic error message
@app.errorhandler(500)
def internal_error_safe(error):
    """Handle errors securely."""

    # Log full error internally
    logger.error(f"Internal error: {error}", exc_info=True)

    # Return generic message to user
    return jsonify({
        "error": "An internal error occurred. Please try again later.",
        "error_id": secrets.token_hex(8)  # For support reference
    }), 500
```

---

## API Security

### 1. Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["100 per hour"],
    storage_uri="redis://localhost:6379"
)

@app.route('/api/login', methods=['POST'])
@limiter.limit("5 per minute")  # Prevent brute force
def login():
    return jsonify({"message": "Login endpoint"})

@app.route('/api/data')
@limiter.limit("1000 per hour")
def get_data():
    return jsonify({"data": []})
```

### 2. API Key Security

```python
from functools import wraps

def require_api_key(f):
    """Decorator to require valid API key."""
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')

        if not api_key:
            return jsonify({"error": "API key required"}), 401

        # Validate API key (constant-time comparison)
        import secrets
        valid_key = os.environ["API_KEY"]

        if not secrets.compare_digest(api_key, valid_key):
            return jsonify({"error": "Invalid API key"}), 401

        return f(*args, **kwargs)

    return decorated

@app.route('/api/protected')
@require_api_key
def protected():
    return jsonify({"data": "sensitive"})
```

---

## Real-World Security Breaches

### 1. Equifax Breach (2017)

**Vulnerability**: Unpatched Apache Struts (CVE-2017-5638)

**Impact**: 147 million people's data exposed

**Lesson**: Keep dependencies updated

```python
# Prevention
pip install pip-audit
pip-audit  # Run regularly in CI/CD
```

### 2. Capital One Breach (2019)

**Vulnerability**: SSRF (Server-Side Request Forgery) → AWS metadata endpoint

**Impact**: 100 million customers affected

**Lesson**: Validate all URLs, restrict metadata access

```python
# Vulnerable code pattern
url = request.args.get('url')
response = requests.get(url)  # Can access http://169.254.169.254/latest/meta-data/

# Secure pattern
ALLOWED_HOSTS = ['api.example.com', 'cdn.example.com']

def fetch_url(url: str):
    parsed = urllib.parse.urlparse(url)

    # Block private IPs
    if parsed.hostname in ['localhost', '127.0.0.1', '169.254.169.254']:
        raise ValueError("Private IP access denied")

    # Whitelist allowed hosts
    if parsed.hostname not in ALLOWED_HOSTS:
        raise ValueError("Host not allowed")

    return requests.get(url)
```

---

## Security Audit Checklist

### Application Security
- [ ] All secrets in environment variables or secret manager
- [ ] All user input validated and sanitized
- [ ] All SQL queries parameterized (no string formatting)
- [ ] All subprocess calls use list arguments (no `shell=True`)
- [ ] All file operations validate paths (prevent traversal)
- [ ] Passwords hashed with bcrypt or Argon2
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced for all connections

### Web Application
- [ ] CSRF protection enabled
- [ ] XSS prevention (output escaping)
- [ ] Security headers set (CSP, X-Frame-Options, etc.)
- [ ] Session cookies: Secure, HttpOnly, SameSite
- [ ] Session timeout implemented
- [ ] Rate limiting on authentication endpoints

### Authentication & Authorization
- [ ] JWT tokens have expiration
- [ ] Role-based access control implemented
- [ ] Authentication failures logged
- [ ] Account lockout after failed attempts
- [ ] Multi-factor authentication (MFA) available

### Dependencies
- [ ] All dependencies up to date
- [ ] Vulnerability scanning in CI/CD (pip-audit, safety)
- [ ] No packages from untrusted sources
- [ ] Requirements pinned to specific versions

### Logging & Monitoring
- [ ] Security events logged (auth failures, access violations)
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] Log injection prevented
- [ ] Monitoring and alerting configured

### Deployment
- [ ] Debug mode disabled in production
- [ ] File permissions restrictive (600 for credentials, 700 for scripts)
- [ ] Unnecessary services disabled
- [ ] Regular security updates applied

---

## References

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **PEP 597**: Default Encoding in Python
- **PEP 543**: Unified TLS API for Python
- **Python Security Best Practices**: https://python.readthedocs.io/en/stable/library/security_warnings.html
- **CWE**: https://cwe.mitre.org/ (Common Weakness Enumeration)
- **Related**: `Python_Debugging_Instructions.md`, `Python_Code_Quality_Checklist.md`

---

**Last Updated**: 2025-12-12
**Version**: 2.0
