# Generic IDE Integration Guide — Workflow Template

> **Module Type**: Part of `workflows/` META-MODULE
> **Context**: Manual integration guide for IDEs without native AI support (VS Code, PyCharm, IntelliJ, Vim, etc.).
> **Reference**: Uses prompts from `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` content modules via copy/paste.

---

## Overview

For IDEs without built-in AI integration, use these patterns to manually apply infra-ai-prompts standards with external AI tools (ChatGPT, Claude, etc.).

---

## Integration Patterns

### Pattern 1: Prompt Composition (Recommended)

Compose prompts by combining module content with current context.

**Example - Smart Commit:**

```bash
# 1. Copy prompt template
cat ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md > /tmp/prompt.txt

# 2. Add current changes
echo "\n\n## Current Changes:\n" >> /tmp/prompt.txt
git diff --staged >> /tmp/prompt.txt

# 3. Paste into AI tool
cat /tmp/prompt.txt | pbcopy  # macOS
cat /tmp/prompt.txt | xclip -selection clipboard  # Linux
```

**Result:** AI generates commit following standards.

---

### Pattern 2: IDE Snippets

Create IDE-specific snippets/templates:

**VS Code** (`.vscode/snippets.code-snippets`):

```json
{
  "Smart Commit Prompt": {
    "prefix": "!commit",
    "body": [
      "Generate commit message following ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md",
      "",
      "Changes:",
      "${TM_SELECTED_TEXT}",
      "",
      "Apply Conventional Commits format with detailed body."
    ]
  },
  "Python Doc Prompt": {
    "prefix": "!doc-py",
    "body": [
      "Document this Python code following ~/infra-ai-prompts/python/Python_Documentation_Generation_Instructions.md",
      "",
      "Code:",
      "${TM_SELECTED_TEXT}",
      "",
      "Use Google Style docstrings."
    ]
  }
}
```

**Usage:**
1. Type `!commit` and Tab → snippet expands
2. Copy expanded text
3. Paste into AI tool

---

### Pattern 3: Shell Aliases

Create command-line helpers:

```bash
# ~/.bashrc or ~/.zshrc

# Smart commit prompt
alias commit-prompt='cat ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md && echo "\n\nChanges:" && git diff --staged'

# Python doc prompt
alias doc-py='echo "Document following ~/infra-ai-prompts/python/Python_Documentation_Generation_Instructions.md\n\nCode:" && cat'

# Code review prompt
alias review-prompt='cat ~/infra-ai-prompts/shell/Shell_Script_Checklist.md && echo "\n\nCode to review:"'
```

**Usage:**
```bash
commit-prompt | pbcopy
# Paste into AI tool
```

---

### Pattern 4: Git Hooks

Automate prompt composition with git hooks:

**`.git/hooks/prepare-commit-msg`:**

```bash
#!/bin/bash

# Generate prompt file
PROMPT_FILE="/tmp/commit-prompt-$$.txt"

cat ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md > "$PROMPT_FILE"
echo "\n\n## Staged Changes:\n" >> "$PROMPT_FILE"
git diff --staged >> "$PROMPT_FILE"

# Open in editor with prompt
if [ -z "$VISUAL" ]; then
    VISUAL="vim"
fi

$VISUAL "$PROMPT_FILE"

echo "Commit prompt saved to: $PROMPT_FILE"
echo "Copy content and paste into AI tool for commit message."
```

---

## Common Workflows

### Workflow 1: Generate Commit

**Steps:**
1. Stage changes: `git add .`
2. Get prompt: `commit-prompt | pbcopy`
3. Paste into AI tool
4. AI generates message following standards
5. Copy message
6. Commit: `git commit -m "message here"`

**Time:** ~1-2 minutes

---

### Workflow 2: Document Python Code

**Steps:**
1. Select function in IDE
2. Copy code
3. Compose prompt:
   ```
   Document this Python function following
   ~/infra-ai-prompts/python/Python_Documentation_Generation_Instructions.md

   Code:
   [PASTE CODE HERE]

   Use Google Style with Args, Returns, Raises, Examples.
   ```
4. Paste into AI tool
5. AI generates docstring
6. Copy and apply to code

**Time:** ~2-3 minutes

---

### Workflow 3: Code Review

**Steps:**
1. Identify code type (Python/Shell/Just)
2. Get checklist:
   ```bash
   # For shell script
   cat ~/infra-ai-prompts/shell/Shell_Script_Checklist.md
   ```
3. Compose prompt:
   ```
   Review this shell script using checklist above.

   Code:
   [PASTE CODE]

   Report: CRITICAL/HIGH/MEDIUM/LOW issues.
   ```
4. Paste into AI tool
5. AI provides review with severity levels

**Time:** ~3-5 minutes

---

## Efficiency Tips

### Tip 1: Create Project README

Create `AI_WORKFLOWS.md` in project:

```markdown
# AI-Assisted Workflows

## Commit Messages

Prompt:
```
Follow ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md
Changes: [GIT_DIFF]
```

## Python Documentation

Prompt:
```
Follow ~/infra-ai-prompts/python/Python_Documentation_Generation_Instructions.md
Code: [CODE]
```

[... more workflows ...]
```

**Result:** Team has consistent prompts.

---

### Tip 2: Browser Bookmarklets

For web-based AI tools (ChatGPT, Claude):

```javascript
javascript:(function(){
  var prompt = 'Follow ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md\n\nChanges:\n';
  prompt += document.querySelector('textarea').value;
  document.querySelector('textarea').value = prompt;
})();
```

**Usage:** Click bookmarklet → prompt auto-fills

---

### Tip 3: IDE Extensions

**VS Code:**
- Install: "Copy for AI" extension
- Configure custom templates
- Bind to keyboard shortcuts

**PyCharm:**
- Use: "Live Templates"
- Create custom template group
- Configure expansion keys

---

## Tool-Specific Guides

### VS Code

**Extension: "Codeium" or "GitHub Copilot"**

While not as integrated as Claude Code/Cursor:
1. Install extension
2. Create `.vscode/settings.json`:
   ```json
   {
     "codeium.customPrompts": [
       {
         "name": "Smart Commit",
         "prompt": "Follow ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md"
       }
     ]
   }
   ```

---

### PyCharm/IntelliJ

**Use: External Tools**

1. Settings → Tools → External Tools → Add
2. Name: "Generate Commit Prompt"
3. Program: `bash`
4. Arguments: `-c "cat ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md && git diff --staged"`
5. Output: Copy to clipboard

**Usage:** Tools → External Tools → Generate Commit Prompt

---

### Vim/Neovim

**Create vim commands:**

```vim
" ~/.vimrc or ~/.config/nvim/init.vim

" Smart commit prompt
command! CommitPrompt :r !cat ~/infra-ai-prompts/commits/Commits_Message_Generation_Progress_Instructions.md && echo && git diff --staged

" Python doc prompt
command! -range DocPy :echo system('echo "Follow ~/infra-ai-prompts/python/Python_Documentation_Generation_Instructions.md\n\nCode:" && sed -n ' . a:firstline . ',' . a:lastline . 'p %')
```

**Usage:** `:CommitPrompt`, `:DocPy`

---

## Comparison: Manual vs Integrated

| Aspect | Manual (Generic IDE) | Integrated (Claude Code/Cursor) |
|--------|---------------------|----------------------------------|
| Setup | Copy/paste workflows | One-time config |
| Speed | 2-5 min per task | 10-30 sec per task |
| Consistency | Depends on user | Automated |
| Learning curve | Low | Low-Medium |
| Flexibility | High | Medium |
| Portability | Works anywhere | Tool-specific |

**Recommendation:**
- Use manual if happy with current IDE
- Consider integrated for 75-90% time savings

---

## Validation Checklist

- [ ] Identified primary workflows (commit, doc, review)
- [ ] Created aliases or snippets for common tasks
- [ ] Tested workflows with real code
- [ ] Documented in project README
- [ ] Team trained on process

---

**Reference**: See `commits/`, `python/`, `shell/`, `just/`, `sqlalchemy/`, `readme/` modules for prompts to use.

**Philosophy**: Manual integration requires more steps but works universally. Consider upgrading to integrated tools (Claude Code, Cursor) for automation.
