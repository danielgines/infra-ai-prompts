# README Checklist

> **Purpose**: Quick reference checklist for writing complete, clear, and effective README files.

---

## Before Writing

- [ ] **Understand target audience** - Contributors? End users? Ops team?
- [ ] **Know project purpose** - What problem does it solve?
- [ ] **Gather information** - Installation steps, configuration, examples
- [ ] **Check similar projects** - Study READMEs in same domain

---

## Essential Sections

### Project Title and Description
- [ ] **Clear title** - Project name obvious and descriptive
- [ ] **One-line description** - ≤120 characters, explains what it does
- [ ] **Detailed description** - 2-3 paragraphs with problem, solution, benefits
- [ ] **Badges** - Build status, coverage, version, license

### Installation
- [ ] **Prerequisites listed** - Software, tools, versions required
- [ ] **Step-by-step installation** - Copy-paste commands
- [ ] **Multiple installation methods** - pip, docker, from source
- [ ] **Verification steps** - How to confirm installation worked
- [ ] **Common issues** - Troubleshooting installation problems

### Quick Start
- [ ] **Minimal working example** - Simplest possible usage
- [ ] **Expected output** - What user should see
- [ ] **Next steps** - Links to full documentation

### Usage Examples
- [ ] **Basic example** - Most common use case
- [ ] **3-5 scenarios** - Different ways to use the project
- [ ] **Code examples** - With syntax highlighting
- [ ] **Expected output** - For each example
- [ ] **Link to more examples** - If applicable

### Configuration
- [ ] **Configuration file location** - Where config lives
- [ ] **All options documented** - With descriptions
- [ ] **Example configuration** - Copy-paste template
- [ ] **Environment variables** - List and explain each
- [ ] **Defaults documented** - What happens without config

### API Reference (if applicable)
- [ ] **Core methods/endpoints** - With parameters
- [ ] **Request/response examples** - For APIs
- [ ] **Error codes** - Possible errors and meanings
- [ ] **Link to full docs** - If extensive

### Contributing
- [ ] **How to contribute** - Process for PRs
- [ ] **Development setup** - Running locally
- [ ] **Running tests** - Test command
- [ ] **Code style** - Formatting standards
- [ ] **Link to CONTRIBUTING.md** - If exists

### License
- [ ] **License type stated** - MIT, Apache, GPL, etc.
- [ ] **Link to full license** - LICENSE file
- [ ] **Year and copyright holder** - Legal clarity

### Support
- [ ] **How to get help** - Issue tracker, chat, email
- [ ] **FAQ section** - Common questions
- [ ] **Known issues** - Current limitations
- [ ] **Contact information** - Maintainer contacts

---

## Quality Checks

### Clarity
- [ ] **Beginner-friendly** - No unexplained jargon
- [ ] **Scannable** - Headers, lists, code blocks
- [ ] **Concise** - No unnecessary words
- [ ] **Active voice** - "Run command" not "Command should be run"

### Accuracy
- [ ] **Code examples work** - All tested
- [ ] **Links valid** - No 404s
- [ ] **Versions current** - Dependencies up to date
- [ ] **Screenshots accurate** - If included

### Completeness
- [ ] **All features mentioned** - Nothing important omitted
- [ ] **Prerequisites complete** - Everything needed listed
- [ ] **Edge cases covered** - Common gotchas documented

### Formatting
- [ ] **Consistent heading levels** - Proper hierarchy
- [ ] **Code blocks have language** - ```python not ```
- [ ] **Lists formatted consistently** - All bullets or all numbers
- [ ] **No trailing whitespace** - Clean formatting

---

## Optional but Recommended

### Advanced Sections
- [ ] **Architecture** - High-level design diagram
- [ ] **Performance** - Benchmarks, optimization tips
- [ ] **Security** - Security considerations
- [ ] **Deployment** - Production deployment guide
- [ ] **Troubleshooting** - Common problems and solutions
- [ ] **Changelog** - Recent changes, or link to CHANGELOG.md
- [ ] **Roadmap** - Planned features
- [ ] **Acknowledgments** - Credits and thanks

### Visual Enhancements
- [ ] **Logo** - Project logo at top
- [ ] **Screenshots** - UI screenshots if applicable
- [ ] **GIFs/videos** - Demo in action
- [ ] **Diagrams** - Architecture or flow diagrams
- [ ] **Badges** - Build, coverage, downloads, etc.

---

## Common Mistakes to Avoid

- [ ] **No "coming soon" sections** - Only document what exists
- [ ] **No outdated information** - Keep up to date
- [ ] **No broken links** - Test all links
- [ ] **No "TODO" in released docs** - Clean up before release
- [ ] **No assumptions** - Don't assume prior knowledge
- [ ] **No copy-paste from other projects** - Customize for yours

---

## README Length Guidelines

- **Minimum**: 200 lines (basic project)
- **Target**: 300-500 lines (typical project)
- **Maximum**: 1000 lines (complex project)

If >1000 lines, consider:
- Moving sections to separate docs/
- Creating wiki
- Using documentation site

---

## Validation Commands

```bash
# Check word count
wc -w README.md

# Check line count
wc -l README.md

# Find broken internal links
grep -oP '(?<=\]\()[^)]+(?=\))' README.md | \
  grep -v "^http" | \
  while read f; do [ -f "$f" ] || echo "BROKEN: $f"; done

# Find broken markdown links
markdown-link-check README.md

# Spell check
aspell check README.md

# Lint markdown
markdownlint README.md
```

---

## Template Structure

```markdown
# Project Name

One-line description

[![Build](badge)](link)
[![Coverage](badge)](link)
[![License](badge)](link)

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

### Prerequisites
### Install Steps
### Verify

## Quick Start

```bash
# Minimal example
```

## Usage

### Basic Example
### Advanced Examples

## Configuration

## API Reference

## Development

### Setup
### Testing
### Contributing

## Deployment

## Troubleshooting

## FAQ

## Changelog

## License

## Support
```

---

## Self-Review Questions

Before publishing README:

1. **Can a beginner install and run this?**
2. **Are all code examples tested and working?**
3. **Do all links work?**
4. **Is version information current?**
5. **Are prerequisites clearly listed?**
6. **Can someone contribute after reading this?**
7. **Is there a clear next step after Quick Start?**
8. **Are security considerations mentioned?**
9. **Is the license clearly stated?**
10. **Can users get help if stuck?**

---

## Additional Resources

- [README_Standards_Reference.md](./README_Standards_Reference.md)
- [New_README_Instructions.md](./New_README_Instructions.md)
- [Update_README_Instructions.md](./Update_README_Instructions.md)
- [README_Review_Instructions.md](./README_Review_Instructions.md)
- [examples/before_after_readme.md](./examples/before_after_readme.md)

---

**Last Updated**: 2025-12-11
