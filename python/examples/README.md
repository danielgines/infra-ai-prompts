# Python Code Examples

> **Purpose**: Examples of Python docstring styles and documentation patterns.

## Available Examples

### 1. before_after_docstrings.md

**Purpose**: Demonstrates transformation from undocumented to fully documented code.

**Features**:
- Google Style docstrings
- NumPy Style docstrings
- Sphinx reStructuredText
- Before/after comparisons

**What it demonstrates**:
- Function documentation
- Class documentation
- Module documentation
- Type hints integration

---

## Docstring Styles

### Google Style (Recommended)

```python
def calculate_total(items: list[dict], tax: float = 0.1) -> float:
    """Calculate total price with tax.

    Args:
        items: List of item dicts with 'price' key
        tax: Tax rate as decimal (default: 0.1 = 10%)

    Returns:
        Total price including tax

    Examples:
        >>> calculate_total([{'price': 100}, {'price': 50}], 0.08)
        162.0
    """
    subtotal = sum(item['price'] for item in items)
    return subtotal * (1 + tax)
```

### NumPy Style (Scientific)

```python
def calculate_total(items, tax=0.1):
    """
    Calculate total price with tax.

    Parameters
    ----------
    items : list of dict
        List of item dicts with 'price' key
    tax : float, optional
        Tax rate as decimal (default is 0.1 = 10%)

    Returns
    -------
    float
        Total price including tax

    Examples
    --------
    >>> calculate_total([{'price': 100}, {'price': 50}], 0.08)
    162.0
    """
    subtotal = sum(item['price'] for item in items)
    return subtotal * (1 + tax)
```

---

## Quick Reference

**Generate docs**:
```bash
# Sphinx
pip install sphinx
sphinx-apidoc -o docs .
cd docs && make html
```

**Check docstrings**:
```bash
# pydocstyle
pip install pydocstyle
pydocstyle .
```

**Type checking**:
```bash
# mypy
pip install mypy
mypy .
```

---

**Last Updated**: 2025-12-11
