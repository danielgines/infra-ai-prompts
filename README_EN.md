# Technical AI Prompts Library

**English** | **[Português](README.md)**

Repository with prompt templates, guides, and checklists for using AI in the generation and review of technical infrastructure content: commit messages, just scripts, shell scripts, and Python documentation.

The goal is to standardize AI behavior to produce consistent, secure outputs aligned with DevOps/SRE and Python development best practices.

---

## Repository Structure

```text
.
├── commits/
│   ├── Conventional_Commits_Reference.md
│   ├── First_Commit_Instructions.md
│   ├── Progress_Commit_Instructions.md
│   └── History_Rewrite_Instructions.md
├── just/
│   ├── Just_Script_Best_Practices_Guide.md
│   ├── Just_Script_Checklist.md
│   ├── Makefile_to_Just_Migration_Guideline.md
│   └── Template_Prompt_IA_Just_Script_Generation.md
├── python/
│   ├── Python_Docstring_Standards_Reference.md
│   ├── Code_Documentation_Instructions.md
│   ├── Comment_Cleanup_Instructions.md
│   ├── preferences/
│   │   ├── README.md
│   │   ├── preferences_template.md
│   │   └── examples/
│   │       └── daniel_gines_preferences.md
│   └── examples/
│       └── before_after_docstrings.md
├── readme/
│   ├── README_Standards_Reference.md
│   ├── New_README_Instructions.md
│   ├── Update_README_Instructions.md
│   └── examples/
│       └── before_after_readme.md
├── sqlalchemy/
│   ├── SQLAlchemy_Model_Documentation_Standards_Reference.md
│   ├── Model_Documentation_Instructions.md
│   ├── Model_Comments_Update_Instructions.md
│   ├── preferences/
│   │   ├── README.md
│   │   ├── preferences_template.md
│   │   └── examples/
│   │       └── daniel_gines_preferences.md
│   └── examples/
│       └── before_after_model_documentation.md
├── README.md
└── shell/
    ├── Shell_Script_Best_Practices_Guide.md
    ├── Shell_Script_Checklist.md
    └── Template_Prompt_IA_Shell_Script_Generation.md
```

### `commits/`

- **Conventional_Commits_Reference.md**
  Shared base with Conventional Commits standards. Reference for all commit templates.

- **First_Commit_Instructions.md**
  Prompt template for generating the first commit message of a repository.

- **Progress_Commit_Instructions.md**
  Prompt template for analyzing changes and generating commit messages during active development (most common use case).

- **History_Rewrite_Instructions.md**
  Prompt template for safe Git history rewriting with standardized messages (advanced and rare use).

### `python/`

- **Python_Docstring_Standards_Reference.md**
  Complete reference for Python documentation standards: PEP 257, Google Style, NumPy Style, and Sphinx. Base for all Python documentation prompts.

- **Code_Documentation_Instructions.md**
  Prompt template for standardizing docstrings in Python code. Supports analysis of entire projects, modules, or specific functions.

- **Comment_Cleanup_Instructions.md**
  Prompt template for cleaning and improving inline comments in Python code. Removes obvious comments, commented-out code, and improves essential comments.

- **preferences/**
  Customizable preferences system for framework-specific conventions (Scrapy, Django, SQLAlchemy, FastAPI, etc.). Allows combining base prompts with personal or team preferences.

  - **README.md**: Complete guide to the preferences system
  - **preferences_template.md**: Empty template to copy and customize
  - **examples/daniel_gines_preferences.md**: Example preferences for Scrapy, SQLAlchemy, and Alembic

- **examples/before_after_docstrings.md**
  Practical examples of transforming poorly documented code into professionally documented code.

### `readme/`

- **README_Standards_Reference.md**
  Shared base with modern technical documentation standards. Structure of 24 essential sections, badges, formatting, conditional inclusion, and best practices for professional READMEs.

- **New_README_Instructions.md**
  Prompt template for generating complete README from scratch. Analyzes repository (dependencies, entry points, configuration) and creates evidence-based documentation.

- **Update_README_Instructions.md**
  Prompt template for updating existing README while preserving valid content (license, authors, context). Audits current state, corrects outdated information, and adds missing sections.

- **examples/before_after_readme.md**
  Practical examples of README transformations for different project types (no README → complete Scrapy, minimal → enhanced FastAPI, outdated → corrected CLI tool).

### `sqlalchemy/`

- **SQLAlchemy_Model_Documentation_Standards_Reference.md**
  Shared base with SQLAlchemy model documentation standards. Docstring structure, inline comment format, pgModeler integration, real database examples.

- **Model_Documentation_Instructions.md**
  Prompt template for documenting SQLAlchemy models from scratch. Queries database for real examples, generates complete docstrings and pgModeler-compatible inline comments.

- **Model_Comments_Update_Instructions.md**
  Prompt template for updating only inline comments on existing models. Focuses on adding real data examples by querying the database, without modifying code.

- **preferences/**
  Customizable preferences system for project-specific conventions (PostgreSQL, pgModeler, migration strategies, soft delete, audit trail, etc.).

  - **README.md**: Complete guide to the preferences system
  - **preferences_template.md**: Empty template to copy and customize
  - **examples/daniel_gines_preferences.md**: Example preferences for PostgreSQL, Alembic, and pgModeler

- **examples/before_after_model_documentation.md**
  Practical examples of transforming poorly documented models into professionally documented models with inline comments and real data examples.

### `just/`

- **Makefile_to_Just_Migration_Guideline.md**
  Technical guide for migrating from `Makefile` to `just`, with syntax, structure, and behavior recommendations.

- **Just_Script_Best_Practices_Guide.md**
  Best practices for writing `just` recipes (using `set shell`, `set -e`, dependencies, validations, logging, etc.).

- **Just_Script_Checklist.md**
  Quick review checklist for `just` scripts before production use.

- **Template_Prompt_IA_Just_Script_Generation.md**
  Prompt template to guide AI in generating `justfile` following the best practices defined in the guide.

### `shell/`

- **Shell_Script_Best_Practices_Guide.md**
  Best practices for Bash scripts (shebang, `set -e`, functions, error handling, permissions, systemd, logging, etc.).

- **Shell_Script_Checklist.md**
  Validation checklist for shell scripts before use in critical environments.

- **Template_Prompt_IA_Shell_Script_Generation.md**
  Prompt template to guide AI in generating Bash scripts aligned with the best practices guide.

---

## How to Use These Files

1. **Choose the area**
   - Commit messages → `commits/` folder
   - Python documentation → `python/` folder
   - README documentation → `readme/` folder
   - SQLAlchemy models → `sqlalchemy/` folder
   - Just scripts → `just/` folder
   - Bash scripts → `shell/` folder

2. **For commits, choose the specific scenario:**
   - **First repository commit** → `First_Commit_Instructions.md`
   - **Commit during development** (most common) → `Progress_Commit_Instructions.md`
   - **History rewrite** (advanced) → `History_Rewrite_Instructions.md`
   - **Standards reference** → `Conventional_Commits_Reference.md`

3. **For Python, choose the task:**
   - **Standardize docstrings** → `Code_Documentation_Instructions.md`
   - **Clean up comments** → `Comment_Cleanup_Instructions.md`
   - **Add personal preferences** → Copy `preferences/preferences_template.md` and customize
   - **View examples** → `examples/before_after_docstrings.md`
   - **Standards reference** → `Python_Docstring_Standards_Reference.md`

4. **For README, choose the scenario:**
   - **Create README from scratch** → `New_README_Instructions.md`
   - **Update existing README** → `Update_README_Instructions.md`
   - **View transformation examples** → `examples/before_after_readme.md`
   - **Standards reference** → `README_Standards_Reference.md`

5. **For SQLAlchemy models, choose the task:**
   - **Document models from scratch** → `Model_Documentation_Instructions.md`
   - **Update only comments** → `Model_Comments_Update_Instructions.md`
   - **Add project preferences** → Copy `preferences/preferences_template.md` and customize
   - **View examples** → `examples/before_after_model_documentation.md`
   - **Standards reference** → `SQLAlchemy_Model_Documentation_Standards_Reference.md`

6. **For scripts (just/shell), select the document type:**
   - `Template_Prompt_...` → text to be pasted directly into AI as the main prompt.
   - `...Best_Practices_Guide...` → technical reference for how the output should be structured.
   - `...Checklist...` → use in final review of what was generated.

7. **Adapt to project context**
   - Adjust service names, paths, specific commands, environments (dev/stage/prod), and internal policies.
   - For Python/SQLAlchemy: combine base prompt with preferences file if needed (`cat base.md preferences.md`).
   - For SQLAlchemy: provide DATABASE_URL to query real data from database.

8. **Send the prompt to the AI**
   - Use the corresponding template, including additional context from your project when necessary.

9. **Review before applying**
   - Validate the generated output using the checklist from the corresponding folder (when applicable).
   - Only then apply the script/change to repositories or real environments.

---

## Scope and Technical Focus

The prompts and guides in this repository follow these principles:

- Generation of reproducible and idempotent outputs whenever possible.
- Focus on operational security (permissions, `sudo` usage, systemd, validations).
- Standardization of naming conventions, log messages, and script structure.
- Avoid "creative" decisions and maintain predictable behavior.

---

## Contributions

Technical adjustments and improvements are welcome, provided that:

- They maintain focus on professional use (infra/DevOps/SRE).
- They don't break compatibility with existing prompts.
- They respect the directory structure and separation between templates, guides, and checklists.

---

## Author

- **Daniel Ginês**
