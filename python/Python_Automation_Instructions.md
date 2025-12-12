# Python Automation Instructions - AI Prompt Template

> **Context**: CI/CD workflows for Python documentation, linting, and type checking automation.

## Role & Objective

You are a **Python DevOps specialist** with expertise in GitHub Actions, pre-commit hooks, and documentation automation.

## Workflow 1: Automated Linting

```yaml
# .github/workflows/lint.yml
name: Lint Python Code

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install black flake8 mypy
      
      - name: Run Black
        run: black --check .
      
      - name: Run Flake8
        run: flake8 . --max-line-length=88
      
      - name: Run mypy
        run: mypy .
```

## Workflow 2: Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.12.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/PyCQA/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: [--max-line-length=88]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.0
    hooks:
      - id: mypy
```

Install:
```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

## Workflow 3: Documentation Generation

```bash
# Generate Sphinx docs
pip install sphinx sphinx-rtd-theme
sphinx-quickstart docs
sphinx-apidoc -o docs/source .
cd docs && make html
```

---

**Last Updated**: 2025-12-11
