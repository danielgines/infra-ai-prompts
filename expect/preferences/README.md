# Expect Preferences System

> **Purpose**: Enable customization of Expect automation prompts without modifying base templates.

---

## Concept

The preferences system allows you to:

✅ Use **universal prompts** as-is (work for everyone)
✅ Add **organizational conventions** without polluting base templates
✅ **Compose** multiple preference files for complex environments
✅ **Share** team conventions while keeping personal preferences private
✅ **Version control** team standards separately from personal choices

---

## How to Use

### 1. Copy the Template

```bash
cd expect/preferences
cp preferences_template.md my_preferences.md
```

### 2. Customize Your Preferences

Edit `my_preferences.md` to include:

- Credential management method (environment variables, credential files, SSH keys)
- Timeout standards for different operations
- Logging preferences
- Security policies
- Naming conventions
- Organization-specific patterns
- Target environment specifics (network devices, Unix servers, legacy systems)

### 3. Combine with Base Prompt

**Option A: Manual concatenation**

```bash
# Combine base prompt + your preferences
cat ../Expect_Automation_Instructions.md my_preferences.md > combined_prompt.txt

# Copy to clipboard (macOS)
pbcopy < combined_prompt.txt

# Copy to clipboard (Linux)
xclip -selection clipboard < combined_prompt.txt
```

**Option B: Direct paste** (simpler)

1. Copy base prompt to AI
2. Add: "Also apply these preferences: [paste your preferences file]"

### 4. Apply to Your Scripts

Send the combined prompt to your AI assistant along with your automation requirements.

---

## File Organization

```
preferences/
├── README.md                           # This file
├── preferences_template.md             # Empty template to copy
├── examples/                           # Public examples
│   └── network_automation_preferences.md
└── [your files]                        # Your personal preferences
```

---

## Privacy Options

### Option 1: Keep Preferences Private

Add to `.gitignore`:

```gitignore
# Personal Expect preferences
expect/preferences/*_preferences.md
!expect/preferences/preferences_template.md
!expect/preferences/examples/
```

Your preferences stay local, won't be committed.

### Option 2: Share Team Preferences

```bash
# Create team-wide conventions
cp preferences_template.md team_preferences.md

# Commit to repository
git add team_preferences.md
git commit -m "Add team Expect script conventions"
```

Team members can now use shared standards.

---

## Composition Patterns

### Pattern 1: Layer Preferences

```bash
# Base prompt + general preferences + project-specific
cat ../Expect_Automation_Instructions.md \
    general_preferences.md \
    network_project_preferences.md > prompt.txt
```

### Pattern 2: Environment-Specific

```bash
# Development environment
cat ../Expect_Automation_Instructions.md \
    dev_preferences.md > dev_prompt.txt

# Production environment (stricter security)
cat ../Expect_Automation_Instructions.md \
    prod_preferences.md > prod_prompt.txt
```

### Pattern 3: Target-Specific

```bash
# For network device automation
cat ../Expect_Automation_Instructions.md \
    network_devices_preferences.md > network_prompt.txt

# For Unix server automation
cat ../Expect_Automation_Instructions.md \
    unix_servers_preferences.md > unix_prompt.txt
```

---

## Common Preference Categories

### Security Preferences

Define organization policies:

- Credential management requirements
- Mandatory file permissions
- Audit logging requirements
- Approved authentication methods

### Operational Preferences

Define operational standards:

- Standard timeout values
- Error handling patterns
- Logging verbosity
- Cleanup procedures

### Environment Preferences

Define target environment specifics:

- Common prompt patterns
- Device-specific commands
- Network-specific security requirements
- Legacy system considerations

### Team Conventions

Define team standards:

- Script naming conventions
- Comment standards
- Documentation requirements
- Testing requirements

---

## Example Use Cases

### Use Case 1: Network Engineer

```bash
# Preferences for Cisco device automation
cat ../Expect_Automation_Instructions.md \
    cisco_preferences.md > cisco_prompt.txt
```

### Use Case 2: System Administrator

```bash
# Preferences for server management
cat ../Expect_Automation_Instructions.md \
    server_management_preferences.md > server_prompt.txt
```

### Use Case 3: Security Team

```bash
# High-security environment with strict audit requirements
cat ../Expect_Automation_Instructions.md \
    ../Expect_Security_Standards_Reference.md \
    security_team_preferences.md > security_prompt.txt
```

### Use Case 4: DevOps Team

```bash
# CI/CD automation with SSH key authentication
cat ../Expect_Automation_Instructions.md \
    cicd_preferences.md > cicd_prompt.txt
```

---

## Integration with AI Assistants

### Claude Code / ChatGPT

```
Prompt structure:

1. Base instructions (from Expect_Automation_Instructions.md)
2. Your preferences (from my_preferences.md)
3. Task description
4. Code to generate/modify

Example:
"Using the following Expect automation guidelines and my preferences,
create a script that automates SSH login to multiple servers:

[Paste base instructions]

[Paste your preferences]

Task: Create script that:
- Connects to 3 servers
- Runs 'uptime' command
- Logs output to file
- Uses SSH keys for authentication
"
```

### GitHub Copilot

Add preferences to workspace `.copilot-instructions.md`:

```markdown
# Expect Script Guidelines

[Contents of Expect_Automation_Instructions.md]

## Team Preferences

[Contents of team_preferences.md]
```

---

## Maintenance

### Review Schedule

- **Monthly**: Review preferences for relevance
- **Quarterly**: Update based on team feedback
- **Per project**: Create project-specific preferences as needed
- **Annual**: Major review and cleanup

### Version Control Best Practices

```bash
# Track team preferences
git add team_preferences.md
git commit -m "Update team Expect conventions"

# Keep personal preferences local
echo "my_preferences.md" >> .gitignore
```

---

## Getting Started Checklist

- [ ] Copy `preferences_template.md` to create your preferences file
- [ ] Define credential management method
- [ ] Set timeout standards
- [ ] Configure logging preferences
- [ ] Define security requirements
- [ ] Test with AI assistant
- [ ] Share with team (if applicable)
- [ ] Add to `.gitignore` (if keeping private)

---

## References

- [Expect Automation Instructions](../Expect_Automation_Instructions.md) - Base automation guide
- [Expect Best Practices Guide](../Expect_Best_Practices_Guide.md) - Best practices reference
- [Expect Security Standards](../Expect_Security_Standards_Reference.md) - Security requirements
- [Expect Script Checklist](../Expect_Script_Checklist.md) - Quick reference checklist

---

**Last Updated**: 2025-12-11
