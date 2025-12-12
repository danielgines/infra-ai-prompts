# README Preferences System

> **Purpose**: Enable customization of README generation and review without modifying base templates.

---

## Concept

The preferences system allows you to:

- Use **universal README templates** as-is (work for everyone)
- Add **project-specific conventions** without polluting base templates
- **Compose** multiple preference files for different project types
- **Share** team conventions while keeping personal preferences private
- **Version control** team standards separately from personal choices

---

## How to Use

### 1. Copy the Template

```bash
cd readme/preferences
cp preferences_template.md my_readme_preferences.md
```

### 2. Customize Your Preferences

Edit `my_readme_preferences.md` to include:

- **Required sections** for your project type
- **Badge preferences** (which badges to include)
- **Documentation style** (formal vs casual)
- **Example format** (minimal vs comprehensive)
- **Target audience** (developers, end users, ops)

### 3. Combine with Base Prompt

**Option A: Manual concatenation**

```bash
cat ../New_README_Instructions.md my_readme_preferences.md > combined_prompt.txt
```

**Option B: Direct paste** (simpler)

1. Copy base prompt to AI
2. Add: "Also apply these preferences: [paste your preferences file]"

---

## File Organization

```
preferences/
├── README.md                     # This file
├── preferences_template.md       # Empty template to copy
├── examples/                     # Public examples
│   ├── api_project_preferences.md
│   ├── cli_tool_preferences.md
│   └── library_preferences.md
└── [your files]                  # Your personal preferences
```

---

## Common Preference Categories

### Project Type Preferences

Define standard sections for your project type:

**CLI Tools**:
- Installation (binaries, from source)
- Commands reference
- Configuration files
- Examples with output

**Web APIs**:
- Quick start
- Authentication
- Endpoints reference
- Rate limiting
- Error codes

**Libraries**:
- Installation (pip, npm, etc.)
- Basic usage
- API reference
- Examples
- Version compatibility

### Badge Preferences

Specify which badges to include:
- Build status (CI/CD)
- Code coverage
- Version/release
- License
- Downloads
- Language/framework
- Dependencies status

### Documentation Style

- **Formal**: Technical, precise, comprehensive
- **Casual**: Friendly, accessible, example-heavy
- **Minimal**: Brief, essentials only

### Example Preferences

- **Minimal**: One quick start example
- **Standard**: 3-5 common scenarios
- **Comprehensive**: 10+ examples, edge cases

---

## Example Use Cases

### Use Case 1: Open Source Library

```bash
cat ../New_README_Instructions.md \
    open_source_library_preferences.md > prompt.txt
```

**Preferences include**:
- Installation from pip/npm
- Basic usage example
- API reference link
- Contributing guidelines
- Code of conduct
- License badge

### Use Case 2: Internal Tool

```bash
cat ../New_README_Instructions.md \
    internal_tool_preferences.md > prompt.txt
```

**Preferences include**:
- Installation from internal registry
- Company-specific sections
- Security considerations
- Support contacts
- No public badges

### Use Case 3: Microservice

```bash
cat ../New_README_Instructions.md \
    microservice_preferences.md > prompt.txt
```

**Preferences include**:
- Architecture diagram
- API endpoints
- Deployment instructions
- Monitoring/logging
- Dependencies

---

## Integration with AI Assistants

### Claude Code / ChatGPT

```
Prompt structure:

1. Base instructions (from New_README_Instructions.md)
2. Your preferences (from my_readme_preferences.md)
3. Repository context
4. Request: "Generate README following these conventions"
```

### GitHub Copilot

Add preferences to workspace `.copilot-instructions.md`

---

## Getting Started Checklist

- [ ] Copy `preferences_template.md`
- [ ] Define project type requirements
- [ ] Set badge preferences
- [ ] Choose documentation style
- [ ] Test with AI assistant
- [ ] Share with team (if applicable)
- [ ] Add to `.gitignore` (if private)

---

## References

- [README_Standards_Reference.md](../README_Standards_Reference.md)
- [New_README_Instructions.md](../New_README_Instructions.md)
- [README_Review_Instructions.md](../README_Review_Instructions.md)

---

**Last Updated**: 2025-12-11
