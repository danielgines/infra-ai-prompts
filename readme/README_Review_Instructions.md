# README Review Instructions — AI Prompt Template

> **Context**: Use this prompt to review existing README files for completeness, clarity, and standards compliance.
> **Reference**: See `README_Standards_Reference.md` for detailed review criteria.

---

## Role & Objective

You are a **technical documentation auditor** with expertise in evaluating documentation quality, clarity, and effectiveness for developer onboarding.

Your task: Analyze an existing README.md and **provide comprehensive review** covering completeness, accuracy, clarity, and adherence to documentation best practices. Prioritize findings by severity and provide specific, actionable recommendations.

---

## Pre-Execution Configuration

**User must specify:**

1. **Review scope** (choose one):
   - [ ] Single README (focused analysis)
   - [ ] Multiple READMEs (consistency check across repos)
   - [ ] Monorepo (multiple package READMEs)

2. **Review focus** (choose all that apply):
   - [ ] **Completeness**: All required sections present
   - [ ] **Clarity**: Understandable by target audience
   - [ ] **Accuracy**: Code examples work, links valid
   - [ ] **Maintenance**: Up-to-date with current codebase
   - [ ] **Standards**: Follows documentation conventions

3. **Target audience**:
   - [ ] New contributors
   - [ ] End users
   - [ ] DevOps/SRE teams
   - [ ] API consumers

4. **Output format** (choose one):
   - [ ] Detailed report with explanations
   - [ ] Checklist format (pass/fail)
   - [ ] Prioritized action list
   - [ ] Side-by-side comparison (before/after suggestions)

---

## Review Process

### Step 1: Initial Assessment

**Scan README for basic structure:**

```bash
# Get file stats
wc -l README.md
wc -w README.md

# Check for sections
grep -E "^#+ " README.md

# Verify links
grep -oP '(?<=\[)[^\]]+(?=\]\([^)]+\))' README.md
grep -oP '(?<=\]\()[^)]+(?=\))' README.md
```

**Output**: Initial assessment summary
```
File: README.md
Lines: 250
Words: 1,800
Sections: 8
Internal links: 5
External links: 12
Code blocks: 15
Images: 3

Initial issues: Missing installation section, outdated dependencies
```

---

### Step 2: Completeness Audit

**Critical Sections (MUST HAVE):**

#### 1. Project Title and Description

**❌ Missing/Poor**:
```markdown
# My Project

A project.
```

**✅ Complete**:
```markdown
# Project Name

One-line description of what the project does (≤120 characters).

Longer paragraph explaining the problem this solves and key benefits.
Can include 2-3 sentences about unique features or approach.
```

**Finding template**:
```
CRITICAL: Inadequate project description
Issue: Description is only 2 words ("A project")
Impact: Users can't determine if project solves their problem
Fix: Add 1-2 paragraphs explaining:
  - What problem does this solve?
  - Who is this for?
  - What makes it unique?
Example: See README_Standards_Reference.md (Project Overview)
```

---

#### 2. Installation Instructions

**❌ Missing/Incomplete**:
```markdown
## Installation

Install the dependencies.
```

**✅ Complete**:
```markdown
## Installation

### Prerequisites

- Python 3.9+
- pip or pipenv
- PostgreSQL 13+ (for database)

### Quick Start

```bash
# Clone repository
git clone https://github.com/user/project.git
cd project

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run setup
python setup.py install
```

### Verify Installation

```bash
project --version
# Expected output: project 1.0.0
```
```

**Finding template**:
```
HIGH: Incomplete installation instructions
Issue: Only says "Install the dependencies" without specifics
Problems:
  - No prerequisites listed
  - No step-by-step commands
  - No verification steps
  - No troubleshooting
Fix: Add complete installation section with:
  - Prerequisites with versions
  - Copy-paste commands
  - Verification command
  - Common issues section
```

---

#### 3. Usage Examples

**❌ Missing/Vague**:
```markdown
## Usage

Run the program.
```

**✅ Complete**:
```markdown
## Usage

### Basic Example

```bash
# Simple use case
project run --input data.csv --output results.json
```

### Common Scenarios

#### Scenario 1: Data Processing

```bash
# Process CSV file
project process \
  --input sales_data.csv \
  --format json \
  --output processed_sales.json
```

Output:
```json
{
  "total_records": 1000,
  "processed": 998,
  "errors": 2
}
```

#### Scenario 2: With Configuration File

```bash
# Use config file
project run --config production.yaml
```

See [examples/](examples/) for more use cases.
```

**Finding template**:
```
HIGH: Missing usage examples
Issue: Only says "Run the program" with no examples
Impact: Users don't know how to use the project
Fix: Add usage section with:
  - Basic example with expected output
  - 2-3 common scenarios
  - Links to more examples
  - Parameter documentation
```

---

### Step 3: Clarity Audit

**Clarity Issues:**

#### 1. Jargon Without Explanation

**❌ Problematic**:
```markdown
Uses ETL pipeline with CDC to sync data via Kafka streams.
```

**✅ Clear**:
```markdown
Extracts data from sources (ETL), detects changes in real-time (CDC),
and syncs via Apache Kafka message streams.

See [Architecture](docs/architecture.md) for detailed flow.
```

**Finding template**:
```
MEDIUM: Unexplained technical jargon
Location: Description section
Issue: Uses "ETL", "CDC", "Kafka streams" without explanation
Impact: Non-experts can't understand what project does
Fix: Either:
  - Add brief explanations in parentheses
  - Link to glossary
  - Simplify language for README
```

---

#### 2. Ambiguous Instructions

**❌ Ambiguous**:
```markdown
Configure the settings.
```

**✅ Specific**:
```markdown
## Configuration

Copy the example configuration and edit values:

```bash
cp config.example.yaml config.yaml
```

Required settings:
- `database.url`: PostgreSQL connection string
- `api.key`: API key from https://example.com/api-keys
- `redis.host`: Redis server hostname (default: localhost)

Example:
```yaml
database:
  url: "postgresql://user:pass@localhost:5432/mydb"
api:
  key: "your-api-key-here"
redis:
  host: "localhost"
  port: 6379
```
```

---

### Step 4: Accuracy Audit

**Accuracy Issues:**

#### 1. Broken Links

**Check all links**:
```bash
# Extract and test links
grep -oP '(?<=\]\()[^)]+(?=\))' README.md | while read link; do
  if [[ $link == http* ]]; then
    curl -I "$link" 2>&1 | grep "HTTP/"
  else
    [ -f "$link" ] && echo "$link: OK" || echo "$link: MISSING"
  fi
done
```

**Finding template**:
```
HIGH: Broken links detected
Links broken:
  - [Documentation](docs/guide.md) → File not found
  - [Website](http://old-domain.com) → 404 Not Found
  - [API Docs](api/README.md) → File moved to docs/api.md
Fix: Update or remove broken links
```

---

#### 2. Outdated Code Examples

**❌ Outdated**:
```python
# README shows
import oldlib

# But actual code uses
import newlib
```

**Finding template**:
```
HIGH: Code examples don't match current codebase
Issue: README shows `import oldlib` but codebase uses `import newlib`
Impact: Examples don't work, frustrates new users
Fix: Update code examples to match current implementation
Test: Run all code examples to verify they work
```

---

### Step 5: Maintenance Audit

#### 1. Version Mismatches

**Check consistency**:
```bash
# README version
grep -i "version" README.md

# Actual version
cat setup.py | grep version
cat package.json | grep version
git describe --tags
```

**Finding template**:
```
MEDIUM: Version mismatch
README says: "Version 1.0.0"
Actual version: 1.2.5 (in setup.py)
Fix: Update version in README or remove version claim
Consider: Use dynamic version badge from package manager
```

---

#### 2. Outdated Dependencies

**❌ Outdated**:
```markdown
Requires Python 3.6+
```

**Actual requirements**:
```python
# setup.py
python_requires='>=3.9'
```

**Finding template**:
```
MEDIUM: Outdated prerequisite versions
README: Python 3.6+
Actual: Python 3.9+ (in setup.py)
Fix: Update README to match actual requirements
```

---

## Review Output Format

### Comprehensive Review Report

```markdown
# README Review Report

**File**: README.md
**Review Date**: 2025-12-11
**Repository**: https://github.com/user/project
**Reviewer**: AI Documentation Auditor

---

## Executive Summary

- **Overall Score**: 6/10 (Needs Improvement)
- **Critical Issues**: 1 (MUST FIX)
- **High Priority**: 4 (SHOULD FIX)
- **Medium Priority**: 5
- **Low Priority**: 2

**Primary Concerns**:
1. Missing installation section (CRITICAL)
2. No usage examples (HIGH)
3. Broken links (3 links) (HIGH)

---

## Critical Issues (MUST FIX)

### 1. Missing Installation Section

**Severity**: CRITICAL
**Impact**: Users cannot install or run the project

**Current State**: No installation section exists

**Required Content**:
```markdown
## Installation

### Prerequisites
- List required software/tools with versions

### Installation Steps
1. Step-by-step installation
2. With copy-paste commands
3. Verification steps

### Troubleshooting
- Common installation issues
```

**Priority**: Fix immediately before next release

---

## Sections Missing

- [ ] Installation instructions
- [ ] Contributing guidelines
- [ ] License information
- [ ] Changelog/Release notes

## Sections Incomplete

- [ ] Usage (only 2 lines, needs examples)
- [ ] Configuration (no details)
- [ ] API reference (broken link)

## Sections Well-Done

- [x] Project description (clear and concise)
- [x] Features list (comprehensive)
- [x] Architecture diagram (helpful visual)

---

## Recommendations

### Immediate Actions (This Week)
1. Add installation section with prerequisites
2. Add 3-5 usage examples with output
3. Fix 3 broken links
4. Add missing sections: Contributing, License

### Short-term (This Month)
1. Add troubleshooting section
2. Expand configuration documentation
3. Add FAQ based on common issues
4. Update dependency versions

### Long-term (Next Quarter)
1. Add video tutorial or GIF demos
2. Create separate advanced usage guide
3. Add performance benchmarks
4. Internationalize documentation

---

## Positive Findings

✅ Clear project description
✅ Good feature list with checkboxes
✅ Architecture diagram included
✅ Code examples use proper syntax highlighting
✅ Badges showing build status and coverage

---

## Checklist Results

### Required Sections (5/10 present)
- [x] Title
- [x] Description
- [ ] Installation
- [ ] Usage
- [ ] Configuration
- [x] Features
- [ ] Contributing
- [ ] License
- [ ] Changelog
- [x] Contact/Support

### Quality Metrics
- Lines: 150 (target: 200-500)
- Code examples: 2 (target: 5-10)
- Internal links: 5 (all working)
- External links: 12 (3 broken)
- Images: 3 (all loading)

---

## Suggested Structure

```markdown
# Project Name

Brief description

## Features
## Installation
## Quick Start
## Usage Examples
## Configuration
## API Reference
## Contributing
## Testing
## Deployment
## Troubleshooting
## FAQ
## Changelog
## License
## Support
```

---

## References

- README_Standards_Reference.md
- before_after_readme.md (examples)
- Contributing guidelines template
```

---

## Post-Review Actions

1. **Generate improved README** (if requested)
2. **Provide section templates** for missing parts
3. **Link validation script**:
   ```bash
   #!/bin/bash
   # validate_readme_links.sh
   grep -oP '(?<=\]\()[^)]+(?=\))' README.md | while read link; do
     # Check if link works
   done
   ```

---

## References

- **Standards**: `README_Standards_Reference.md`
- **Examples**: `examples/before_after_readme.md`
- **Template**: `README_Generation_Instructions.md`
- **Checklist**: `README_Checklist.md`

---

**Last Updated**: 2025-12-11
**Version**: 1.0
