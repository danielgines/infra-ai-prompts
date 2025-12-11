# Commit Message Preferences System

> **Purpose**: Enable customization of commit message conventions without modifying base templates.

---

## Concept

The preferences system allows you to:

- Use **universal commit instructions** as-is (work for everyone)
- Add **organizational conventions** without polluting base templates
- **Compose** multiple preference files for complex environments
- **Share** team conventions while keeping personal preferences private
- **Version control** team standards separately from personal choices

---

## How to Use

### 1. Copy the Template

```bash
cd commits/preferences
cp preferences_template.md my_commit_preferences.md
```

### 2. Customize Your Preferences

Edit `my_commit_preferences.md` to include:

- **Standard scopes** for your project
- **Custom commit types** (if extending Conventional Commits)
- **Team conventions** (header length, emoji usage, etc.)
- **Issue reference format** (Jira, GitHub, GitLab, etc.)
- **Review requirements** (co-authors, sign-offs, etc.)

### 3. Combine with Base Prompt

**Option A: Manual concatenation**

```bash
cat ../Progress_Commit_Instructions.md my_commit_preferences.md > combined_prompt.txt
```

**Option B: Direct paste** (simpler)

1. Copy base prompt to AI
2. Add: "Also apply these preferences: [paste your preferences file]"

---

## File Organization

```
preferences/
├── README.md                           # This file
├── preferences_template.md             # Empty template to copy
├── examples/                           # Public examples
│   ├── enterprise_team_preferences.md
│   ├── open_source_preferences.md
│   └── monorepo_preferences.md
└── [your files]                        # Your personal preferences
```

---

## Privacy Options

### Option 1: Keep Preferences Private

Add to `.gitignore`:

```gitignore
commits/preferences/*_preferences.md
!commits/preferences/preferences_template.md
!commits/preferences/examples/
```

### Option 2: Share Team Preferences

```bash
git add team_commit_preferences.md
git commit -m "docs(commits): add team commit conventions"
```

---

## Composition Patterns

### Pattern 1: Layer Preferences

```bash
cat ../Progress_Commit_Instructions.md \
    general_preferences.md \
    project_preferences.md > prompt.txt
```

### Pattern 2: Environment-Specific

```bash
# Development team
cat ../Progress_Commit_Instructions.md \
    dev_team_preferences.md > dev_prompt.txt

# Release team
cat ../Progress_Commit_Instructions.md \
    release_team_preferences.md > release_prompt.txt
```

---

## Common Preference Categories

### Standard Scopes

Define project-specific scopes:

```markdown
## Standard Scopes

Your project uses these scopes consistently:

**Features**:
- `auth` - Authentication and authorization
- `api` - REST API endpoints
- `ui` - User interface components
- `db` - Database schema and queries

**Infrastructure**:
- `config` - Configuration files
- `docker` - Docker and containerization
- `k8s` - Kubernetes deployments
- `ci` - CI/CD pipelines
```

### Issue Reference Format

Specify how to reference issues:

```markdown
## Issue References

**Format**: Use JIRA ticket format

Example: `Closes PROJECT-1234`

NOT: `Closes #1234` (GitHub format)
```

### Team Conventions

Document team-specific rules:

```markdown
## Team Conventions

- **Header length**: Maximum 72 characters (not 50)
- **Emoji**: Use emojis for type: ✨ feat, 🐛 fix, 📝 docs
- **Co-authors**: Always include pair programming partners
- **Sign-off**: Required for all commits (use -s flag)
```

### Breaking Change Policy

Define how breaking changes are handled:

```markdown
## Breaking Change Policy

- **Requires**: Team lead approval before committing
- **Format**: BREAKING CHANGE footer + migration guide link
- **Communication**: Post in #releases Slack channel
```

---

## Example Use Cases

### Use Case 1: Monorepo with Multiple Projects

```bash
cat ../Progress_Commit_Instructions.md \
    monorepo_scopes.md > prompt.txt
```

**monorepo_scopes.md**:
```markdown
## Monorepo Scopes

Use package name as scope:
- `packages/web` → `feat(web): ...`
- `packages/api` → `fix(api): ...`
- `packages/shared` → `refactor(shared): ...`
```

### Use Case 2: Open Source Project with Contributors

```bash
cat ../Progress_Commit_Instructions.md \
    oss_guidelines.md > prompt.txt
```

**oss_guidelines.md**:
```markdown
## Open Source Guidelines

- Always reference issue: `Closes #123`
- Add `Signed-off-by` for DCO compliance
- Link to documentation for new features
- Credit contributors in footer
```

### Use Case 3: Enterprise with Compliance Requirements

```bash
cat ../Progress_Commit_Instructions.md \
    enterprise_compliance.md > prompt.txt
```

**enterprise_compliance.md**:
```markdown
## Compliance Requirements

- Reference change request: `Change-Id: CR-2024-0123`
- Include security scan results for dependencies
- Require code review reference: `Reviewed-by: John Doe`
- Document audit trail for database changes
```

---

## Integration with AI Assistants

### Claude Code / ChatGPT

```
Prompt structure:

1. Base instructions (from Progress_Commit_Instructions.md)
2. Your preferences (from my_commit_preferences.md)
3. Git diff output
4. Request: "Generate commit message following these conventions"
```

### GitHub Copilot

Add preferences to workspace `.copilot-instructions.md`:

```markdown
# Commit Message Conventions

[Paste your preferences here]
```

### Git Commit Template

Integrate with `.gitmessage`:

```bash
# Create commit template with your scopes
cat > .gitmessage <<EOF
# <type>(<scope>): <subject>
#
# Scopes for this project:
#   auth, api, ui, db, config, ci
#
# [Rest of template]
EOF

git config commit.template .gitmessage
```

---

## Getting Started Checklist

- [ ] Copy `preferences_template.md`
- [ ] Define project-specific scopes
- [ ] Set issue reference format
- [ ] Document team conventions
- [ ] Test with AI assistant
- [ ] Share with team (if applicable)
- [ ] Add to `.gitignore` (if private)

---

## References

- [Conventional Commits Reference](../Conventional_Commits_Reference.md)
- [Commit Best Practices Guide](../Commit_Best_Practices_Guide.md)
- [Progress Commit Instructions](../Progress_Commit_Instructions.md)
- [Commit Review Instructions](../Commit_Review_Instructions.md)

---

**Last Updated**: 2025-12-11
