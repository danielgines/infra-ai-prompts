# tests.just - Testing Operations Module
# This file is imported by the main justfile.
# Centralizes all testing-related recipes.

# Test configuration
test_pattern := env_var_or_default("TEST_PATTERN", "test_*.py")
coverage_min := "80"

# Run all tests
test:
    @just test-unit
    @just test-integration

# Run unit tests
test-unit:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running unit tests..."

    if [ -f "package.json" ] && grep -q "test" package.json; then
        npm test
    elif command -v pytest &> /dev/null; then
        pytest tests/unit/ -v
    elif command -v python &> /dev/null && [ -d "tests" ]; then
        python -m unittest discover -s tests/unit -p "{{test_pattern}}"
    else
        echo "No test framework found"
        exit 1
    fi

    echo "✓ Unit tests passed"

# Run integration tests
test-integration:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running integration tests..."

    if command -v pytest &> /dev/null && [ -d "tests/integration" ]; then
        pytest tests/integration/ -v --maxfail=1
    elif [ -d "tests/integration" ]; then
        python -m unittest discover -s tests/integration -p "{{test_pattern}}"
    else
        echo "No integration tests found"
    fi

    echo "✓ Integration tests passed"

# Run tests with coverage
test-coverage:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running tests with coverage..."

    if command -v pytest &> /dev/null; then
        pytest \
            --cov=src \
            --cov-report=html \
            --cov-report=term \
            --cov-fail-under={{coverage_min}}
    elif [ -f "package.json" ]; then
        npm run test:coverage
    else
        echo "Coverage tool not found"
        exit 1
    fi

    echo "✓ Coverage report generated"
    echo "View: open htmlcov/index.html"

# Run specific test file
test-file path:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v pytest &> /dev/null; then
        pytest {{path}} -v
    else
        python -m unittest {{path}}
    fi

# Run tests matching pattern
test-match pattern:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v pytest &> /dev/null; then
        pytest -k "{{pattern}}" -v
    else
        python -m unittest discover -k "{{pattern}}"
    fi

# Run tests in watch mode
test-watch:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v pytest-watch &> /dev/null; then
        ptw -- -v
    elif command -v nodemon &> /dev/null && [ -f "package.json" ]; then
        nodemon --exec npm test
    else
        echo "Watch mode requires pytest-watch or nodemon"
        exit 1
    fi

# Run end-to-end tests
test-e2e:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running E2E tests..."

    if [ -f "playwright.config.js" ]; then
        npx playwright test
    elif [ -f "cypress.config.js" ]; then
        npx cypress run
    elif [ -d "tests/e2e" ] && command -v pytest &> /dev/null; then
        pytest tests/e2e/ -v
    else
        echo "No E2E test framework found"
        exit 1
    fi

    echo "✓ E2E tests passed"

# Run smoke tests (quick sanity check)
test-smoke:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running smoke tests..."

    if [ -d "tests/smoke" ]; then
        pytest tests/smoke/ -v --maxfail=1
    else
        echo "Running quick test subset..."
        pytest tests/ -m smoke -v || pytest tests/ -k "smoke" -v
    fi

    echo "✓ Smoke tests passed"

# Run performance/benchmark tests
test-perf:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running performance tests..."

    if command -v pytest &> /dev/null; then
        pytest tests/performance/ -v --benchmark-only
    elif [ -f "package.json" ] && grep -q "test:perf" package.json; then
        npm run test:perf
    else
        echo "No performance tests found"
    fi

# Run mutation tests (test the tests)
test-mutation:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running mutation tests..."

    if command -v mutmut &> /dev/null; then
        mutmut run
    elif command -v stryker &> /dev/null; then
        stryker run
    else
        echo "Mutation testing requires mutmut (Python) or Stryker (JS)"
        exit 1
    fi

# Generate test report
test-report:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Generating test report..."

    if command -v pytest &> /dev/null; then
        pytest \
            --cov=src \
            --cov-report=html \
            --html=test-report.html \
            --self-contained-html
    else
        echo "Report generation requires pytest with plugins"
        exit 1
    fi

    echo "✓ Report generated: test-report.html"

# Show test statistics
test-stats:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Test Statistics:"
    echo "================"

    if [ -d "tests" ]; then
        echo "Test files: $(find tests -name '*.py' -o -name '*.test.js' | wc -l)"
        echo "Test functions:"

        if command -v pytest &> /dev/null; then
            pytest --collect-only -q | tail -1
        fi
    else
        echo "No tests directory found"
    fi

# Clean test artifacts
test-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning test artifacts..."

    rm -rf .pytest_cache/ .coverage htmlcov/ test-report.html
    rm -rf coverage/ .nyc_output/
    find . -type d -name "__pycache__" -delete

    echo "✓ Test artifacts cleaned"

# Run tests in parallel
test-parallel workers="auto":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Running tests in parallel ({{workers}} workers)..."

    if command -v pytest &> /dev/null; then
        pytest -n {{workers}} -v
    elif [ -f "package.json" ]; then
        npm test -- --maxWorkers={{workers}}
    else
        echo "Parallel testing requires pytest-xdist or Jest"
        exit 1
    fi

# Run tests with debugging enabled
test-debug:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v pytest &> /dev/null; then
        pytest -v --pdb --pdbcls=IPython.terminal.debugger:TerminalPdb
    else
        python -m pdb -m unittest discover
    fi

# Verify test isolation (run in random order)
test-isolation:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Testing isolation with random order..."

    if command -v pytest &> /dev/null; then
        pytest -v --random-order
    else
        echo "Test isolation checking requires pytest-random-order"
        exit 1
    fi

# Helper: check if tests exist
_check-tests:
    #!/usr/bin/env bash
    if [ ! -d "tests" ] && [ ! -d "test" ]; then
        echo "Error: No tests directory found"
        exit 1
    fi
