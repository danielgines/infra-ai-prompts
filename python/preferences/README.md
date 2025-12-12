# Python Preferences System

> **Purpose**: Enable customization of Python documentation prompts without modifying base templates.

---

## Concept

The preferences system allows you to:

✅ Use **universal prompts** as-is (work for everyone)
✅ Add **personal conventions** without polluting base templates
✅ **Compose** multiple preference files for complex projects
✅ **Share** team conventions while keeping personal preferences private
✅ **Version control** team standards separately from personal choices

---

## How to Use

### 1. Copy the Template

```bash
cd python/preferences
cp preferences_template.md my_preferences.md
```

### 2. Customize Your Preferences

Edit `my_preferences.md` to include:

- Preferred docstring style (Google/NumPy/Sphinx)
- Framework-specific conventions (Django, Flask, FastAPI, Scrapy, etc.)
- Organization standards (TODO format, type hints policy, etc.)
- Domain-specific patterns (data science, web scraping, DevOps, etc.)

### 3. Combine with Base Prompt

**Option A: Manual concatenation**

```bash
# Combine base prompt + your preferences
cat ../Python_Documentation_Generation_Instructions.md my_preferences.md > combined_prompt.txt

# Copy to clipboard (macOS)
pbcopy < combined_prompt.txt

# Copy to clipboard (Linux)
xclip -selection clipboard < combined_prompt.txt
```

**Option B: Direct paste** (simpler)

1. Copy base prompt to AI
2. Add: "Also apply these preferences: [paste your preferences file]"

### 4. Apply to Your Code

Send the combined prompt to your AI assistant along with your Python code.

---

## File Organization

```
preferences/
├── README.md                           # This file
├── preferences_template.md             # Empty template to copy
├── examples/                           # Public examples
│   ├── daniel_gines_preferences.md     # Author's preferences
│   ├── scrapy_conventions.md           # Scrapy-specific patterns
│   ├── data_science_preferences.md     # NumPy/Pandas conventions
│   └── web_api_preferences.md          # FastAPI/Flask patterns
└── [your files]                        # Your personal preferences
```

---

## Privacy Options

### Option 1: Keep Preferences Private

Add to `.gitignore`:

```gitignore
# Personal Python preferences
python/preferences/*_preferences.md
!python/preferences/preferences_template.md
!python/preferences/examples/
```

Your preferences stay local, won't be committed.

### Option 2: Share Team Preferences

```bash
# Create team-wide conventions
cp preferences_template.md team_preferences.md

# Commit to repository
git add team_preferences.md
git commit -m "docs(python): add team Python conventions"
```

### Option 3: Contribute Examples

```bash
# Share your preferences as example for others
cp my_preferences.md examples/my_name_preferences.md
git add examples/my_name_preferences.md
git commit -m "docs(python): add example preferences for [use case]"
```

---

## Combining Multiple Preferences

For complex projects, combine multiple preference files:

```bash
# Base + team + personal preferences
cat \
  ../Python_Documentation_Generation_Instructions.md \
  team_preferences.md \
  my_preferences.md \
  > combined_prompt.txt
```

**Order matters**: Later preferences override earlier ones.

Example hierarchy:
1. **Base prompt** (universal standards)
2. **Team preferences** (organization conventions)
3. **Personal preferences** (your specific choices)

---

## Example Use Cases

### Use Case 1: Solo Developer

```bash
# Copy template once
cp preferences_template.md daniel_preferences.md

# Edit with your preferences
vim daniel_preferences.md

# Use forever
cat ../Python_Documentation_Generation_Instructions.md daniel_preferences.md
```

### Use Case 2: Team with Shared Standards

```bash
# Team lead creates shared conventions
cp preferences_template.md team_preferences.md
git add team_preferences.md
git commit -m "docs: add team Python conventions"
git push

# Each developer can extend with personal additions
cp preferences_template.md my_extras.md
# Keep my_extras.md in .gitignore

# Combine both
cat ../Python_Documentation_Generation_Instructions.md team_preferences.md my_extras.md
```

### Use Case 3: Multiple Projects with Different Conventions

```bash
preferences/
├── project_a_preferences.md    # Django project
├── project_b_preferences.md    # FastAPI microservices
└── project_c_preferences.md    # Scrapy web scraping
```

Switch preferences based on current project:

```bash
# Working on Django project
cat ../Python_Documentation_Generation_Instructions.md project_a_preferences.md

# Working on Scrapy project
cat ../Python_Documentation_Generation_Instructions.md project_c_preferences.md
```

---

## Creating Good Preferences

### ✅ Do:

- **Be specific**: "Scrapy spiders must document target URL" not "add docs"
- **Provide examples**: Show before/after transformations
- **Explain rationale**: Why this convention matters
- **Keep it focused**: One preference file per domain/framework
- **Use clear sections**: Organize by topic

### ❌ Don't:

- **Override fundamental standards**: PEP 257 is non-negotiable
- **Make preferences too generic**: "Write good docs" is useless
- **Contradict yourself**: Ensure preferences are internally consistent
- **Add too much**: Keep it under 200 lines for readability

---

## Preference File Structure

Recommended sections:

```markdown
# [Your Name] Python Preferences

## Docstring Style
**Selected**: Google Style (or NumPy/Sphinx)

## Framework-Specific Conventions
### Django
[Your Django-specific rules]

### FastAPI
[Your FastAPI-specific rules]

## Type Hints Policy
[Your type hint preferences]

## Comment Style
[Your comment conventions]

## TODO/FIXME Format
[Your task marker format]

## Custom Rules
[Any other preferences]
```

---

## Troubleshooting

**Q: Preferences seem to be ignored by AI**

A: Ensure preferences are **after** the base prompt. Add explicit instruction:
```
IMPORTANT: Apply the custom preferences below AFTER standard conventions.

[Your preferences]
```

**Q: Conflicts between team and personal preferences**

A: Last preference wins. If you want personal preferences to override team:
```bash
cat base.md team.md personal.md  # personal wins
```

**Q: Preferences file too large**

A: Split into multiple files:
```bash
preferences/
├── django_preferences.md
├── testing_preferences.md
└── database_preferences.md
```

Combine only relevant ones per task.

---

## Examples Directory

Check `examples/` for:

- **daniel_gines_preferences.md**: Scrapy, SQLAlchemy, Alembic patterns
- **data_science_preferences.md**: NumPy, Pandas, Jupyter conventions
- **web_api_preferences.md**: FastAPI, Flask REST API patterns
- **django_preferences.md**: Django views, models, forms documentation

Use these as inspiration or starting point for your own preferences.

---

## Contributing Preferences

Want to share your preferences as examples?

1. Copy to `examples/` with descriptive name
2. Add clear header explaining context:
   ```markdown
   # [Framework/Domain] Python Preferences

   > Context: These conventions are for [specific use case]
   > Author: [Your name]
   > Last updated: [Date]
   ```
3. Submit PR or commit directly (if you have access)

---

## Philosophy

**Base prompts** = Universal best practices (PEP 257, industry standards)
**Preferences** = Your specific needs (frameworks, domain, team style)

This separation ensures:
- ✅ Base prompts work for everyone
- ✅ Easy to customize without forking
- ✅ Share what's useful, keep private what's personal
- ✅ Compose multiple conventions as needed

---

**Happy documenting!** 🐍📝
