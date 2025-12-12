# Comment Cleanup Instructions — AI Prompt Template

> **Context**: Use this prompt to clean up and improve inline comments in Python code.
> **Philosophy**: Comments should explain **WHY**, not **WHAT**. Code should be self-documenting.

---

## Role & Objective

You are a **Python code quality specialist** focused on improving code clarity through better commenting practices.

Your task: Analyze Python code and **remove redundant comments**, improve necessary comments, and ensure remaining comments add genuine value.

---

## Core Principles

### Good Comments Explain:
- **WHY**: Business logic rationale
- **WHY NOT**: Why obvious alternative wasn't chosen
- **CONTEXT**: Historical or domain-specific knowledge
- **WARNINGS**: Non-obvious dangers or side effects
- **WORKAROUNDS**: Temporary fixes with explanation

### Bad Comments Explain:
- **WHAT**: What the code does (code should be self-evident)
- **HOW**: Implementation mechanics (obvious from reading code)
- **REDUNDANT**: Restating variable/function names

---

## Comment Removal Rules

### 1. Remove Obvious Comments

❌ **Remove**:
```python
# Increment counter
counter += 1

# Loop through users
for user in users:
    pass

# Return result
return result

# Set name to John
name = "John"
```

✅ **Keep code without comments** (self-explanatory):
```python
counter += 1

for user in users:
    pass

return result

name = "John"
```

### 2. Remove Commented-Out Code

❌ **Remove**:
```python
def process_data(data):
    # Old implementation
    # result = data * 2
    # return result + 10

    # Another old approach
    # if data > 0:
    #     return data * 3

    return data * 4  # Current implementation
```

✅ **Clean version**:
```python
def process_data(data):
    return data * 4
```

**Rationale**: Use version control (git) for history, not comments.

### 3. Remove Redundant Comments

❌ **Remove**:
```python
# User class
class User:
    pass

# Get user by ID
def get_user_by_id(user_id):
    pass

# Email validation function
def validate_email(email):
    pass
```

✅ **Keep code without comments** (names are clear):
```python
class User:
    pass

def get_user_by_id(user_id):
    pass

def validate_email(email):
    pass
```

### 4. Remove Outdated Comments

❌ **Remove outdated**:
```python
def calculate_total(items, tax_rate):  # ← tax_rate parameter added
    # Calculate total price for items
    # Note: tax not included  # ← OUTDATED!
    total = sum(item.price for item in items)
    return total * (1 + tax_rate)
```

✅ **Update or remove**:
```python
def calculate_total(items, tax_rate):
    """Calculate total price including tax."""
    total = sum(item.price for item in items)
    return total * (1 + tax_rate)
```

---

## Comment Improvement Rules

### 1. Transform Bad Comments to Good Comments

❌ **Bad** (explains WHAT):
```python
# Check if user is admin
if user.role == 'admin':
    pass
```

✅ **Good** (explains WHY):
```python
# Admin users bypass rate limiting for emergency maintenance
if user.role == 'admin':
    pass
```

### 2. Explain Non-Obvious Business Logic

✅ **Keep and improve**:
```python
# Invoice due date is 30 days for standard customers,
# but 60 days for enterprise customers per contract terms
due_days = 60 if customer.tier == 'enterprise' else 30

# Use UTC to avoid DST issues when calculating billing cycles
timestamp = datetime.now(timezone.utc)

# Minimum password length of 12 required by security audit (2024-01)
MIN_PASSWORD_LENGTH = 12
```

### 3. Document Magic Numbers

❌ **Bad**:
```python
timeout = 300
max_retries = 3
buffer_size = 8192
```

✅ **Good**:
```python
timeout = 300  # 5 minutes: AWS Lambda max execution time
max_retries = 3  # Balance between reliability and user wait time
buffer_size = 8192  # 8KB: optimal for most network conditions
```

### 4. Explain Workarounds and Hacks

✅ **Essential comments**:
```python
# HACK: Work around bug in library v2.3.1 where None is not handled
# properly. Remove when upgrading to v2.4.0 (fix confirmed in changelog)
if value is None:
    value = ""

# Workaround for race condition in PostgreSQL advisory locks
# See: https://github.com/sqlalchemy/sqlalchemy/issues/1234
time.sleep(0.1)
```

### 5. Warn About Non-Obvious Behavior

✅ **Critical warnings**:
```python
# WARNING: This modifies the input list in place for performance.
# Caller must copy list if original is needed.
def sort_items(items):
    items.sort()
    return items

# DANGER: This function is NOT thread-safe due to shared cache.
# Use locks if calling from multiple threads.
cache = {}
def get_cached(key):
    return cache.get(key)
```

---

## Comment Preservation Rules

### Keep These Comments:

#### 1. TODO/FIXME/HACK Markers

✅ **Keep with context**:
```python
# TODO(daniel, 2024-02-15): Add retry logic when API adds idempotency keys
def process_payment(amount):
    pass

# FIXME(team): Race condition when multiple workers access same record
# Temporary mitigation: Added random delay. Permanent fix: use distributed lock
time.sleep(random.uniform(0.1, 0.3))

# HACK: Library doesn't support async, wrapping in thread pool
# Remove when library releases v3.0 with native async support
result = await asyncio.to_thread(sync_function, data)
```

**Format**:
- `TODO(author, date): description` — Future improvement
- `FIXME(author): description` — Known bug to fix
- `HACK(author): description` — Temporary workaround
- `NOTE(author): description` — Important context

#### 2. Performance Optimizations

✅ **Explain optimization rationale**:
```python
# Using set for O(1) lookups instead of list O(n) - performance critical
# in loops processing 100k+ items
seen_ids = set()

# Cache compiled regex: 10x faster for repeated matching
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

# Batch database inserts: reduces queries from N to 1
session.bulk_insert_mappings(User, user_dicts)
```

#### 3. Complex Algorithms

✅ **High-level explanation**:
```python
# Dijkstra's algorithm for shortest path in weighted graph
# Time complexity: O((V + E) log V) with min-heap
def find_shortest_path(graph, start, end):
    # Initialize distances and priority queue
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    pq = [(0, start)]
    # ... implementation ...
```

#### 4. Regex Explanations

✅ **Break down complex patterns**:
```python
# Match valid phone numbers:
# - Optional country code: +1 or +55
# - Area code: (123) or 123
# - Number: 456-7890 or 4567890
PHONE_PATTERN = re.compile(
    r'^'
    r'(\+\d{1,2}\s?)?'  # Optional country code
    r'(\(\d{3}\)|\d{3})'  # Area code
    r'[\s.-]?'  # Optional separator
    r'\d{3}[\s.-]?\d{4}'  # Phone number
    r'$'
)
```

#### 5. Type Ignore Justifications

✅ **Explain type: ignore**:
```python
# type: ignore[attr-defined]
# Library missing type stubs, verified attribute exists at runtime
result = external_lib.undocumented_method()

# mypy cannot infer type through decorator, but guaranteed by framework
@app.route('/users/<int:user_id>')  # type: ignore[misc]
def get_user(user_id):
    pass
```

---

## Special Comment Categories

### 1. License Headers

✅ **Keep unchanged**:
```python
# Copyright (c) 2024 Company Name
# Licensed under MIT License
# See LICENSE file for details
```

### 2. Encoding Declarations

✅ **Keep if needed**:
```python
# -*- coding: utf-8 -*-
```

### 3. Shebang Lines

✅ **Keep for executable scripts**:
```python
#!/usr/bin/env python3
```

### 4. Module-Level Pragmas

✅ **Keep linter configurations**:
```python
# pylint: disable=invalid-name
# mypy: ignore-errors
# flake8: noqa
```

---

## Output Format (Required)

Structure your response exactly as follows:

```
## Analysis Summary
- **Files analyzed**: [number]
- **Total comments**: [number]
- **Comments removed**: [number] (X% of total)
- **Comments improved**: [number]
- **Comments preserved**: [number]

## Breakdown by Category

### Removed Comments (X)
1. **Obvious comments**: X — Explained self-evident code
2. **Commented-out code**: X — Use git for history
3. **Redundant comments**: X — Repeated function/variable names
4. **Outdated comments**: X — No longer accurate

### Improved Comments (X)
1. **Transformed WHAT → WHY**: X comments
2. **Added context**: X magic numbers explained
3. **Clarified warnings**: X non-obvious behaviors
4. **Enhanced TODO/FIXME**: X with author/date

### Preserved Comments (X)
1. **Business logic**: X essential context comments
2. **Performance notes**: X optimization explanations
3. **Workarounds**: X hacks with justification
4. **Security**: X vulnerability mitigation notes
5. **TODO/FIXME/HACK**: X action items

## Modified Code

[Show complete modified file(s) or specific sections with before/after]

## Recommendations

- [ ] Consider extracting complex logic to well-named functions
- [ ] Add docstrings where inline comments were insufficient
- [ ] Review TODO items for prioritization
- [ ] Update variable/function names to be more self-documenting

## Validation
- [x] No obvious comments remain
- [x] No commented-out code
- [x] All remaining comments add value
- [x] TODO/FIXME have owner and context
- [x] Magic numbers explained
- [x] Code more readable overall

**Status**: ✅ Comments cleaned and improved
```

---

## Decision Framework

When evaluating a comment, ask:

1. **Does it explain WHY?** → Keep/improve
2. **Does it explain WHAT code does?** → Remove (make code clearer instead)
3. **Is it a TODO/FIXME with context?** → Keep
4. **Does it explain non-obvious business logic?** → Keep
5. **Does it document a workaround?** → Keep with explanation
6. **Is it outdated?** → Remove or update
7. **Is it obvious from reading code?** → Remove

---

## Refactoring Suggestions

Sometimes the best comment removal is code improvement:

### Example 1: Extract Function

❌ **Before**:
```python
# Calculate discounted price based on customer tier
if customer.tier == 'gold':
    price = base_price * 0.8
elif customer.tier == 'silver':
    price = base_price * 0.9
else:
    price = base_price
```

✅ **After** (no comment needed):
```python
price = calculate_discounted_price(base_price, customer.tier)
```

### Example 2: Better Variable Names

❌ **Before**:
```python
# Time in seconds
t = 3600
```

✅ **After** (no comment needed):
```python
timeout_seconds = 3600
```

### Example 3: Use Constants

❌ **Before**:
```python
# Maximum file size is 10MB
if file.size > 10485760:
    raise ValueError("File too large")
```

✅ **After** (no comment needed):
```python
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024  # 10MB

if file.size > MAX_FILE_SIZE_BYTES:
    raise ValueError("File too large")
```

---

## Validation Checklist

Before outputting:

- [ ] All obvious comments removed
- [ ] Commented-out code removed
- [ ] Remaining comments explain WHY, not WHAT
- [ ] TODO/FIXME have owner and date
- [ ] Magic numbers have explanations
- [ ] Workarounds documented with rationale
- [ ] No outdated information
- [ ] Code readability improved overall

---

**Philosophy**: The best comment is no comment — write self-documenting code. When comments are necessary, make them count.
