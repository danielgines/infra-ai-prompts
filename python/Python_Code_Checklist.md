# Python Code Checklist

> **Purpose**: Quick validation checklist for Python code quality, documentation, and security.

## Documentation

- [ ] All public functions have docstrings
- [ ] Docstrings include Args, Returns, Raises
- [ ] Type hints on all function arguments
- [ ] Type hints on return values
- [ ] Examples in docstrings for complex functions
- [ ] Module-level docstring present

## Code Style

- [ ] PEP 8 compliant (run: `flake8 .`)
- [ ] Black formatted (run: `black --check .`)
- [ ] Function names are snake_case
- [ ] Class names are PascalCase
- [ ] Constants are UPPER_CASE
- [ ] Imports properly ordered (stdlib, third-party, local)
- [ ] No unused imports

## Type Hints

- [ ] All arguments typed
- [ ] Return types specified
- [ ] Optional used for nullable values
- [ ] Type checking passes (run: `mypy .`)

## Security

- [ ] No hardcoded credentials
- [ ] No SQL string formatting (f-strings, %)
- [ ] No os.system() or shell=True
- [ ] User input validated
- [ ] Path traversal prevented
- [ ] Secrets in environment variables

## Testing

- [ ] Unit tests present
- [ ] Tests cover edge cases
- [ ] Mocking used for external dependencies
- [ ] Test coverage >= 80%

## Performance

- [ ] No N+1 database queries
- [ ] List comprehensions for simple loops
- [ ] Generators for large datasets
- [ ] Caching for expensive operations

## Common Mistakes

- [ ] No mutable default arguments
- [ ] No bare except clauses
- [ ] No eval() or exec()
- [ ] Context managers for file/connection handling
- [ ] Proper exception handling

---

**Last Updated**: 2025-12-11
