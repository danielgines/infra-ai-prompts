# Quick Reference — Workflows

Fast command lookup for workflows module.

---

## One-Time Setup

### Claude Code
```bash
# In target project directory
> Follow @workflows/setup/claude-code.md and configure this project
```

**Time:** 2 minutes
**Result:** Creates `.claude/` with commands, settings, memory

### Cursor
```bash
# In Cursor chat
> Follow @workflows/setup/cursor.md and configure this project
```

**Time:** 2 minutes
**Result:** Creates `.cursorrules` with standards

### Generic IDE
```bash
# Manual integration
See: workflows/setup/generic-ide.md
```

**Time:** 5-10 minutes
**Result:** Aliases, snippets, workflows documented

---

## Daily Commands

### Claude Code (After Setup)

```bash
> /commit               # Smart commit with standards
> /doc-python          # Document Python code
> /update-readme       # Update README
> /review              # Technical code review
```

### Cursor (Natural Language)

```bash
> generate commit message
> document this function
> review this code for security
> update readme following our standards
```

### Generic IDE (Manual)

```bash
# Copy prompt + context, paste into AI tool
commit-prompt | pbcopy
doc-py file.py | pbcopy
review-prompt | pbcopy
```

---

## Task Workflows (Direct Execution)

When not using setup (or for one-off tasks):

```bash
# Smart commit
> Execute task in @workflows/tasks/commit.md

# Code review
> Execute task in @workflows/tasks/code-review.md

# Documentation
> Execute task in @workflows/tasks/documentation.md
```

---

## File Paths

```
workflows/
├── README.md                   # Full documentation
├── QUICK_REFERENCE.md         # This file
├── setup/
│   ├── claude-code.md         # Claude Code setup
│   ├── cursor.md              # Cursor setup
│   └── generic-ide.md         # Manual integration
└── tasks/
    ├── commit.md              # Commit workflow
    ├── code-review.md         # Review workflow
    └── documentation.md       # Documentation workflow
```

---

## Common Issues

**Commands not found (Claude Code):**
```bash
# Restart session or check:
ls .claude/commands/
```

**@ references not resolving:**
```bash
# Verify path in .claude/CLAUDE.md:
cat .claude/CLAUDE.md | grep "infra-ai-prompts"
```

**Cursor not applying standards:**
```bash
# Check .cursorrules exists:
cat .cursorrules
```

---

## Time Savings

| Task | Before | After | Saved |
|------|--------|-------|-------|
| Commit | 3-5 min | 10 sec | 94% |
| Document | 15-30 min | 2-3 min | 90% |
| Review | 20-40 min | 5-10 min | 75% |
| README | 30-60 min | 10-15 min | 75% |

---

## Next Steps

1. **First time?** → Read `workflows/README.md`
2. **Ready to setup?** → Choose tool: `workflows/setup/<tool>.md`
3. **Daily use?** → Use commands above
4. **Need help?** → See main repository README

---

**Full documentation**: `workflows/README.md`
