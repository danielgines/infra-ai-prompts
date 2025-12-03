# SQLAlchemy Model Documentation Preferences

> **Purpose**: System for customizing SQLAlchemy model documentation conventions to match your project, team, or personal standards.

---

## Overview

The preferences system allows you to extend base documentation prompts with:
- Custom comment formats
- Project-specific naming conventions
- Framework integration requirements (FastAPI, Flask, Django)
- Database-specific features (PostgreSQL, MySQL, SQLite)
- Data governance policies
- Security requirements
- Migration strategies

---

## How It Works

### Base Prompts

The base prompts provide industry-standard documentation:
- `SQLAlchemy_Model_Documentation_Standards_Reference.md`: Standard formats
- `Model_Documentation_Instructions.md`: Documentation generation
- `Model_Comments_Update_Instructions.md`: Comment updates
- `Baseline_Migration_Instructions.md`: Baseline migrations for existing databases

### Preferences Layer

Your preferences file **extends** base prompts with:
- Additional requirements
- Custom conventions
- Project-specific rules
- Team standards

### Combined Usage

```bash
# Combine base prompt + preferences
cat Model_Documentation_Instructions.md preferences/my_preferences.md > combined_prompt.md

# Send combined prompt to AI
claude < combined_prompt.md
```

Or in conversation:
```
Please document my SQLAlchemy models following:
1. Model_Documentation_Instructions.md (base standards)
2. preferences/my_preferences.md (project-specific conventions)

[Paste both files or reference them]
```

---

## When to Use Preferences

### ✅ Use Preferences For:

- **Project-specific conventions**: Custom field naming, special columns
- **Framework integration**: FastAPI dependencies, Flask-SQLAlchemy patterns
- **Data governance**: PII handling, retention policies, audit trails
- **Team standards**: Preferred comment format, verbosity level
- **Database features**: PostgreSQL-specific types (JSONB, arrays, ranges)
- **Migration policies**: Deployment windows, rollback requirements
- **Security requirements**: Encryption columns, sensitive data handling

### ❌ Don't Need Preferences For:

- Standard SQLAlchemy usage (covered by base prompts)
- Basic comment format (already standardized)
- Common patterns (indexes, foreign keys, relationships)
- General best practices (already in reference docs)

---

## Creating Your Preferences File

### Step 1: Copy Template

```bash
cp preferences_template.md my_project_preferences.md
```

### Step 2: Fill In Your Conventions

Edit `my_project_preferences.md` with your requirements:

```markdown
# My Project SQLAlchemy Documentation Preferences

## Custom Conventions

### Timestamp Columns

All models must have:
- `created_at`: Creation timestamp (UTC)
- `updated_at`: Last update timestamp (UTC)
- `created_by_id`: FK to users.id (who created record)
- `updated_by_id`: FK to users.id (who last updated)

### Soft Delete Pattern

All models use soft delete:
- `deleted_at`: Timestamp of deletion (NULL = active)
- `deleted_by_id`: FK to users.id (who deleted)
- Never use hard deletes (compliance requirement)

### Comment Format

Include in every column comment:
- Description
- Examples (3-5 real data points)
- Business rule reference (if applicable)
- GDPR classification: PUBLIC, INTERNAL, PII, SENSITIVE

Example:
```python
email = Column(
    String(255),
    comment='User email [PII]. Examples: "user@example.com". Rule: BIZ-001'
)
```
```

### Step 3: Version Control

```bash
# Add to git
git add preferences/my_project_preferences.md
git commit -m "docs: add SQLAlchemy documentation preferences"
```

### Step 4: Share With Team

```markdown
# In your project README

## Database Documentation

When documenting models, use:
1. Base: `infra-ai-prompts/sqlalchemy/Model_Documentation_Instructions.md`
2. Project: `preferences/my_project_preferences.md`

Combine both when prompting AI for model documentation.
```

---

## Example Preferences

See `examples/` directory for real-world examples:

### `examples/daniel_gines_preferences.md`

Conventions for:
- **PostgreSQL-specific features**: JSONB, arrays, full-text search
- **Audit trail columns**: created_at, updated_at, created_by_id, updated_by_id
- **Soft delete pattern**: deleted_at with NULL = active
- **pgModeler integration**: Comment format for HTML export
- **Data examples**: Always query real database, anonymize PII
- **Migration notes**: Include rollback strategy in migration docstring

---

## Common Preference Categories

### 1. Column Naming Conventions

```markdown
## Column Naming

### Primary Keys
- Always use `id` (not `user_id` in User table)
- Type: Integer or UUID

### Foreign Keys
- Format: `{table_singular}_id` (e.g., `user_id`, `category_id`)
- Always include FK constraint with explicit ondelete behavior

### Timestamps
- Use: `created_at`, `updated_at` (not `date_created`, `modified`)
- Always UTC timezone
- Type: DateTime with default=func.now()

### Boolean Flags
- Prefix with `is_`, `has_`, `can_` (e.g., `is_active`, `has_verified`)
- Default to False unless specified
```

### 2. Comment Format

```markdown
## Comment Format

### Standard Format
```python
comment='[Description] [CLASSIFICATION]. Examples: [ex1], [ex2]. Rule: [BIZ-ID]'
```

### Classifications
- `[PUBLIC]`: Publicly shareable data
- `[INTERNAL]`: Internal business data
- `[PII]`: Personally identifiable information
- `[SENSITIVE]`: Passwords, tokens, payment info

### Business Rule Reference
- Include reference to business rules document if applicable
- Format: `Rule: BIZ-XXX` or `Policy: DATA-XXX`
```

### 3. Relationship Patterns

```markdown
## Relationships

### Cascade Rules
- Parent-child (strong ownership): `cascade='all, delete-orphan'`
- Reference (weak link): `cascade='save-update, merge'`
- Optional reference: `ondelete='SET NULL'`
- Required reference: `ondelete='CASCADE'` or `ondelete='RESTRICT'`

### Lazy Loading
- Default: `lazy='select'` (explicit is better)
- Collections: `lazy='dynamic'` for large result sets (>100 items)
- Avoid: `lazy='joined'` unless profiled and necessary

### Back Populates
- Always use `back_populates` (not `backref`)
- Explicit bidirectional relationships
```

### 4. Index Strategy

```markdown
## Indexes

### Required Indexes
- All foreign keys (automatic in PostgreSQL, explicit in code)
- All columns used in WHERE clauses (query log analysis)
- All columns used in ORDER BY (for pagination)

### Composite Indexes
- Order matters: most selective column first
- Cover common query patterns
- Document query pattern in model docstring

### Partial Indexes (PostgreSQL)
- Use for filtered queries (e.g., WHERE is_active = true)
- Document filter condition in docstring
```

### 5. Migration Standards

```markdown
## Migrations

### Migration Docstring
Required sections:
- **Changes**: What tables/columns changed
- **Deployment**: Steps to deploy safely
- **Rollback**: How to rollback if needed
- **Data Migration**: Any data transformation
- **Testing**: How migration was tested
- **Performance**: Expected downtime or impact

### Deployment Windows
- All migrations during maintenance window (Sundays 2-4 AM UTC)
- Large migrations (>1M rows): coordinate with ops team
- Breaking changes: require 2-phase deployment

### Baseline Migrations
When adopting Alembic on existing databases:
- Create baseline migration documenting current schema
- Use `alembic stamp` (not `upgrade`) on existing databases
- Document all tables, relationships, and constraints in baseline
- See: `Baseline_Migration_Instructions.md`
```

### 6. Security Requirements

```markdown
## Security

### Sensitive Columns
- Never log sensitive columns (password_hash, api_key, etc.)
- Use PostgreSQL column-level encryption for PII
- Document encryption method in column comment

### Password Storage
- Always bcrypt with cost factor 12+
- Comment format: "Bcrypt hash (cost 12). Never plaintext."

### API Keys / Tokens
- Store hashed (SHA-256 minimum)
- Include expiration column
- Implement rotation policy
```

---

## Testing Your Preferences

### Validation Checklist

Before committing preferences:

- [ ] Preferences compatible with base prompts
- [ ] No contradictions with standard practices
- [ ] Clear examples provided
- [ ] Reasoning explained for non-standard choices
- [ ] Team consensus on conventions
- [ ] Documented in project README

### Test Run

1. Combine base + preferences
2. Run on small test model
3. Review generated documentation
4. Verify it matches expectations
5. Iterate if needed

---

## Updating Preferences

### When to Update

- New project requirements
- Team feedback
- Framework version change
- Database migration
- Compliance policy change

### Versioning

```bash
# Tag preference versions
git tag -a prefs-v1.0 -m "Initial SQLAlchemy documentation preferences"

# Reference in code
"""
Documentation preferences: prefs-v1.0
Last updated: 2024-03-15
"""
```

---

## Example Workflow

### 1. Initial Setup

```bash
# Copy template
cd infra-ai-prompts/sqlalchemy/preferences/
cp preferences_template.md ../../../my-project/docs/sqlalchemy_preferences.md

# Edit with project requirements
vim ../../../my-project/docs/sqlalchemy_preferences.md

# Commit
cd ../../../my-project/
git add docs/sqlalchemy_preferences.md
git commit -m "docs: add SQLAlchemy documentation preferences"
```

### 2. Daily Use

```bash
# Document new model
cat path/to/infra-ai-prompts/sqlalchemy/Model_Documentation_Instructions.md \
    docs/sqlalchemy_preferences.md > /tmp/combined_prompt.md

# Send to AI
claude < /tmp/combined_prompt.md
```

### 3. Team Onboarding

```markdown
# In your team docs

## Database Documentation Standards

When adding or updating SQLAlchemy models:

1. **Base standards**: Follow [Model_Documentation_Instructions.md](link)
2. **Project conventions**: Follow [sqlalchemy_preferences.md](link)
3. **Always query real data**: Include examples from database
4. **Anonymize PII**: Never expose real user data in comments
5. **Generate migration**: `alembic revision --autogenerate -m "description"`
6. **Update pgModeler**: Refresh HTML dictionary after migration
```

---

## Best Practices

### ✅ DO

- Keep preferences focused on your project specifics
- Provide clear examples and reasoning
- Version control preferences file
- Update regularly based on team feedback
- Test preferences before enforcing
- Document why non-standard conventions exist

### ❌ DON'T

- Duplicate information from base prompts
- Create overly complex rules
- Contradict industry standards without reason
- Make preferences mandatory for experiments
- Lock down every detail (allow flexibility)
- Forget to communicate changes to team

---

## FAQ

### Q: Do I need a preferences file?

A: Only if your project has specific conventions beyond standard SQLAlchemy practices. For typical projects, base prompts are sufficient.

### Q: Can I have multiple preference files?

A: Yes! Create separate files for different contexts:
- `preferences/api_models.md`: API-facing models
- `preferences/internal_models.md`: Internal data models
- `preferences/reporting_models.md`: Read-only reporting views

### Q: How do I handle conflicts between preferences?

A: More specific preferences override general ones:
1. Base prompts (least specific)
2. Team/project preferences
3. Model-specific requirements (most specific)

### Q: Can preferences override base standards?

A: Yes, but document **why**. Example:
```markdown
## Override: Primary Key Naming

**Base standard**: Use `id` for all primary keys
**Our convention**: Use `{table}_id` (e.g., `user_id` in users table)
**Reason**: Legacy database migration, changing would break 50+ external integrations
```

---

## Support

For questions about preferences system:
1. Check examples in `examples/` directory
2. Review base prompt documentation
3. Open issue in repository
4. Consult team documentation lead

---

**Philosophy**: Preferences are about capturing your team's collective wisdom and project-specific requirements, not about reinventing best practices. Start minimal, grow organically.
