# Workflow Integration Templates

> **Context**: Use these workflow templates to integrate infra-ai-prompts standards with AI-powered development tools (Claude Code, Cursor, generic IDEs).
> **Reference**: Orchestrates prompts from `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` modules.

---

## What Are Workflow Templates?

Workflow templates are **meta-prompts** that configure AI tools to automatically apply the technical standards from this repository.

**Difference:**
- **Standard prompts** (other modules): You copy and paste directly → "Generate commit following these rules..."
- **Workflow templates** (this module): AI reads and applies automatically → "Configure project to use repo standards"

---

## Structure

```
workflows/
├── README.md                # This file
├── QUICK_REFERENCE.md       # Fast command reference
├── setup/                   # One-time configuration templates
│   ├── claude-code.md       # Configure Claude Code CLI
│   ├── cursor.md            # Configure Cursor IDE
│   └── generic-ide.md       # Manual integration for other IDEs
└── tasks/                   # Daily workflow templates
    ├── commit.md            # Smart commit workflow
    ├── code-review.md       # Technical review workflow
    └── documentation.md     # Code documentation workflow
```

---

## When to Use

### Setup Templates (One-Time)

Use **once per project** to configure your tool:

```
> Follow @workflows/setup/claude-code.md and configure this project
```

**Result:** Creates `.claude/CLAUDE.md`, custom commands, security settings.
**After:** You only need `> /commit` and Claude already knows your standards.

### Task Templates (Daily)

Use **whenever needed** to execute tasks following your standards:

```
> Execute task in @workflows/tasks/commit.md
```

**Result:** AI follows complete workflow using relevant modules (commits/, python/, etc).

---

## Visual Example

### Before Workflows (Manual, Every Time)

**Every commit in every project:**
```
> Analyze git diff --staged
> Generate commit following Conventional Commits
> Reference commits/Progress_Commit_Instructions.md
> Use commits/Conventional_Commits_Reference.md
> Apply format: type(scope): description
> Add body explaining why this change was made
> Validate against checklist
> Ask user to approve
```

**Time:** 5-8 minutes per commit
**Consistency:** Varies by manual effort
**Error rate:** High (forgotten steps, inconsistent format)

### After Workflows (Automated, One Command)

**One-time setup:**
```
> Follow @workflows/setup/claude-code.md and configure this project
```
**Time:** 2 minutes (once per project)

**Every commit:**
```
> /commit
```

**Time:** 10-15 seconds
**Consistency:** Perfect (automated)
**Error rate:** Near zero (validated automatically)

---

## Efficiency Gains

Based on typical development workflows:

| Task | Without Workflows | With Workflows | Time Saved |
|------|------------------|----------------|------------|
| Commit message | 3-5 min | 10 sec | **94%** |
| Code documentation | 15-30 min | 2-3 min | **90%** |
| Code review | 20-40 min | 5-10 min | **75%** |
| README update | 30-60 min | 10-15 min | **75%** |

**Total time saved per week**: ~2-4 hours for active developers

**Quality improvements**:
- ✅ 100% adherence to Conventional Commits
- ✅ Consistent documentation style (Google Style docstrings)
- ✅ Security checks on every review
- ✅ No forgotten validation steps

---

## Tool Comparison

| Feature | Claude Code | Cursor | Windsurf | Generic IDE |
|---------|-------------|--------|----------|-------------|
| **Setup file** | `.claude/CLAUDE.md` | `.cursorrules` | TBD | Manual snippets |
| **Command style** | Slash commands (`/commit`) | Natural chat | TBD | Copy/paste prompts |
| **Automation** | Hooks, scripts | Chat-driven | TBD | Manual |
| **Integration** | CLI-native | IDE-native | TBD | Copy/paste |
| **Best for** | Terminal workflows | Interactive coding | TBD | Any tool |
| **Learning curve** | Low | Low | TBD | Lowest |

**All tools can reference the same prompt modules from this repository.**

---

## How It Works

### 1. Choose Your Tool

Pick the AI tool you use:
- **Claude Code**: Official CLI from Anthropic
- **Cursor**: AI-powered IDE
- **Windsurf**: AI-powered IDE (experimental)
- **Generic**: VS Code, PyCharm, etc. (manual integration)

### 2. Run Setup Template

Execute the appropriate setup workflow:

**Claude Code:**
```
> Follow @workflows/setup/claude-code.md and configure this project
```

**Cursor:**
```
> Follow @workflows/setup/cursor.md and configure this project
```

**Generic IDE:**
```
See workflows/setup/generic-ide.md for manual integration
```

### 3. Use Daily Workflows

After setup, use simplified commands:

**Claude Code:**
```
> /commit                # Smart commit with standards
> /doc-python           # Document with Google Style
> /review               # Security-focused code review
> /update-readme        # Update README with standards
```

**Cursor (natural language):**
```
> generate commit message
> document this function
> review this code for security
```

**Generic IDE:**
```
Copy prompt from workflows/tasks/[task].md
Paste into your AI tool
```

---

## Advantages

1. **Reusability** - Configure once, use forever
2. **Consistency** - All projects follow same standards
3. **Productivity** - 75-94% time reduction on common tasks
4. **Portability** - Works with any AI tool
5. **Maintainability** - Update modules, all projects benefit
6. **Onboarding** - New team members get standardized setup
7. **Quality** - Automated validation, no forgotten steps

---

## Compatibility

Workflow templates work with:

- ✅ **Claude Code** (CLI) - Full integration
- ✅ **Cursor** (IDE) - Full integration
- ⚠️ **Windsurf** (IDE) - Experimental (use generic-ide.md)
- ⚠️ **VS Code** - Manual integration (use generic-ide.md)
- ⚠️ **PyCharm** - Manual integration (use generic-ide.md)
- ⚠️ **Any tool** - Manual copy/paste workflow

---

## Next Steps

1. **Read**: `workflows/QUICK_REFERENCE.md` for fast commands
2. **Choose**: Your tool (Claude Code, Cursor, or Generic)
3. **Setup**: Run setup template for your tool (`workflows/setup/<tool>.md`)
4. **Use**: Execute daily workflows (`workflows/tasks/<task>.md`)
5. **Customize**: Adjust via preferences in module folders (python/preferences/, sqlalchemy/preferences/)

---

## Important Notes

- **Don't modify workflows** - They reference original modules as single source of truth
- **Customize via module preferences** - Use python/preferences/, sqlalchemy/preferences/
- **Workflows evolve automatically** - When modules update, workflows inherit changes
- **Commit workflow configs** - Share `.claude/` or `.cursorrules` with team (except `.local` files)
- **Security**: Workflow templates include safe permission defaults for infrastructure work

---

## Philosophy

Transform repository standards into **living, automated workflows** instead of documentation that gets ignored.

**Traditional approach:**
- Standards documented → Developers read → Developers manually apply → Inconsistent results

**Workflow approach:**
- Standards documented → AI configured once → AI applies automatically → Consistent results

---

## Contributing

Improvements to workflow templates are welcome:

- Maintain focus on infrastructure/DevOps/SRE workflows
- Don't duplicate content from other modules (reference them)
- Follow template structure from other modules
- Test with actual AI tools before submitting

---

## Related Documentation

- **Commit standards**: `commits/`
- **Python documentation**: `python/`
- **README standards**: `readme/`
- **Shell scripts**: `shell/`
- **Just scripts**: `just/`
- **SQLAlchemy models**: `sqlalchemy/`

---

See `QUICK_REFERENCE.md` for fast command lookup.
