# Commit Message Preferences Template

> **Purpose**: Customize commit message conventions for your project/team.
> **Usage**: Copy this file and fill in your preferences.

---

## Project Information

**Project Name**: [Your Project Name]
**Repository**: [GitHub/GitLab URL]
**Team**: [Team Name]
**Last Updated**: [YYYY-MM-DD]

---

## Standard Scopes

Define the standard scopes used in your project:

### Feature Scopes

List domain/feature-specific scopes:

**Example**:
```
- `auth` - Authentication and authorization
- `user` - User management
- `payment` - Payment processing
- `product` - Product catalog
- `order` - Order management
```

**Your scopes**:
```
- `[scope]` - [Description]
- `[scope]` - [Description]
- `[scope]` - [Description]
```

### Layer Scopes

List architectural layer scopes:

**Example**:
```
- `api` - REST API endpoints
- `ui` - User interface components
- `db` - Database schema and queries
- `cli` - Command-line interface
```

**Your scopes**:
```
- `[scope]` - [Description]
- `[scope]` - [Description]
```

### Infrastructure Scopes

List infrastructure-related scopes:

**Example**:
```
- `config` - Configuration files
- `docker` - Docker and containerization
- `k8s` - Kubernetes deployments
- `ci` - CI/CD pipelines
- `deploy` - Deployment scripts
```

**Your scopes**:
```
- `[scope]` - [Description]
- `[scope]` - [Description]
```

### When to Omit Scope

Document when scope should be omitted:

**Example**:
```
Omit scope when:
- Change affects entire project (e.g., `chore: update dependencies`)
- Documentation at root level (e.g., `docs: update README`)
- Changes span multiple unrelated scopes
```

**Your rules**:
```
[Define your rules for omitting scope]
```

---

## Custom Commit Types

If your project extends Conventional Commits with custom types:

**Example**:
```
- `security` - Security fixes and updates
- `a11y` - Accessibility improvements
- `i18n` - Internationalization
- `content` - Content updates (CMS, copy changes)
```

**Your custom types**:
```
- `[type]` - [Description and when to use]
- `[type]` - [Description and when to use]
```

---

## Header Format Conventions

### Length Requirements

**Default**: ≤50 characters (recommended), ≤72 characters (maximum)

**Your preference**:
```
- Recommended: [XX] characters
- Maximum: [XX] characters
```

### Capitalization

**Default**: Lowercase type and scope, sentence case subject

**Your preference**:
```
- Type: [lowercase / UPPERCASE / PascalCase]
- Scope: [lowercase / UPPERCASE / PascalCase]
- Subject: [sentence case / lowercase / Title Case]
```

### Punctuation

**Default**: No period at end of header

**Your preference**:
```
- Period at end: [Yes / No]
- Other punctuation rules: [Describe]
```

### Emoji Usage

**Default**: No emojis

**Your preference**:
```
- Use emojis: [Yes / No]
- Emoji format:
  - ✨ feat:
  - 🐛 fix:
  - 📝 docs:
  - [Add more if applicable]
```

---

## Body Format Conventions

### When Body is Required

**Default**: Required for breaking changes, complex changes, performance improvements

**Your requirements**:
```
Body is required for:
- [ ] All commits
- [ ] Breaking changes
- [ ] Commits affecting >X files
- [ ] Commits with >X lines changed
- [ ] [Other requirements]
```

### Body Structure

**Your preference for body content**:
```
- Bullet points: [Required / Optional / Never]
- Metrics for performance changes: [Required / Optional]
- Root cause analysis for bug fixes: [Required / Optional]
- Links to documentation: [Required / Optional]
```

### Line Wrapping

**Default**: 72 characters

**Your preference**:
```
- Line wrap at: [XX] characters
- Hard wrap or soft wrap: [Hard / Soft]
```

---

## Footer Conventions

### Breaking Changes

**Your format**:
```
BREAKING CHANGE: [Description]

[Migration guide / upgrade path]

[Link to documentation if available]
```

**Requirements**:
```
- Requires: [Team lead approval / PR review / Documentation]
- Communication: [Slack channel / Email / Meeting]
- Documentation: [Required / Optional]
```

### Issue References

**Your issue tracker**: [GitHub / GitLab / Jira / Azure DevOps / Other]

**Format**:
```
Example formats:
- GitHub: Closes #123
- Jira: Closes PROJECT-123
- GitLab: Closes #123

Your format: [Specify]
```

**Keywords**:
```
To close issues: [Closes / Fixes / Resolves]
To reference: [Refs / See / Related to]
```

### Co-Authors

**Your requirement**:
```
- Required for: [Pair programming / Mob programming / Always / Never]
- Format: Co-authored-by: Name <email@example.com>
```

### Sign-Off

**Your requirement**:
```
- Signed-off-by required: [Yes / No]
- When: [All commits / Production commits / Compliance-related]
- How: git commit -s
```

### Custom Footers

If your project uses custom footers:

**Example**:
```
- Change-Id: CR-2024-0123 (Change Request tracking)
- Reviewed-by: John Doe (Code review attribution)
- Tested-by: QA Team (Testing verification)
```

**Your custom footers**:
```
- [Footer-Name]: [Description and format]
- [Footer-Name]: [Description and format]
```

---

## Commit Frequency and Granularity

### Commit Size Preference

**Your preference**:
```
- Preferred commit size: [Small atomic commits / Medium logical units / Large feature-complete]
- Maximum files per commit: [X files]
- Maximum lines per commit: [X lines]
```

### WIP Commits

**Your policy**:
```
- WIP commits allowed on: [Feature branches / Never / Always]
- WIP format: [WIP: [type(scope)] description / wip(scope): description]
- Must be cleaned up: [Before merge / Before review / Never]
```

### Fixup Commits

**Your policy**:
```
- Fixup commits during review: [Allowed / Discouraged / Required]
- Format: fixup! original commit message
- Auto-squash before merge: [Yes / No]
```

---

## Branch-Specific Conventions

### Main/Master Branch

**Your requirements**:
```
- All commits must: [Pass tests / Have PR approval / Include issue reference]
- Commit message quality: [Strict / Standard / Relaxed]
- Squash vs Rebase: [Squash merge / Rebase merge / Merge commit]
```

### Feature Branches

**Your conventions**:
```
- Naming: [feature/description / feat-description / other]
- Commit frequency: [Often / Moderate / Milestone-based]
- Clean up history: [Required before merge / Optional]
```

### Release Branches

**Your conventions**:
```
- Naming: [release/version / v1.0.0 / other]
- Allowed commit types: [fix, chore only / All types]
- Special footer: [Release-Notes: description / Not required]
```

---

## Automated Tool Configuration

### Commitlint

**Your rules**:
```
- Header max length: [XX] characters
- Type enum: [feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert]
- Scope enum: [List your scopes]
- Custom rules: [Describe any custom validations]
```

### Conventional Changelog

**Your configuration**:
```
- Preset: [angular / atom / ember / eslint / other]
- Custom sections: [security, a11y, etc.]
- Issue URL format: [GitHub / Jira URL pattern]
```

### Semantic Release

**Your configuration**:
```
- Release branches: [main, next, beta]
- Version bump rules:
  - feat → [minor / patch]
  - fix → [patch]
  - BREAKING CHANGE → [major]
```

---

## Team Workflow Integration

### Code Review Requirements

**Your requirements**:
```
- Commit quality check: [Reviewer verifies messages / Automated only]
- Require rebase if: [Messages don't follow convention / Always / Never]
- Approval needed for: [Breaking changes / All commits to main]
```

### CI/CD Integration

**Your configuration**:
```
- Commit message triggers:
  - [skip ci] - Skip CI pipeline
  - [ci deploy] - Deploy to staging
  - [ci release] - Trigger release process
  - [Other custom triggers]
```

### Documentation Generation

**Your configuration**:
```
- Changelog generation: [Automated on release / Manual / Both]
- Release notes: [From commits / Manual curation]
- API docs updates: [Automated from commits / Manual]
```

---

## Monorepo-Specific Conventions

If your project is a monorepo:

### Package Scoping

**Your format**:
```
Example: feat(packages/web): add login page
         fix(apps/mobile): resolve crash on startup

Your format: [Specify]
```

### Cross-Package Changes

**Your convention**:
```
When change affects multiple packages:
- Use scope: [root / multiple / shared / omit]
- List affected packages in: [Body / Footer]
- Example: [Provide example]
```

### Independent Versioning

**Your strategy**:
```
- Each package versioned: [Independently / Together]
- Commit types per package: [Standard / Package-specific]
- Release coordination: [Describe process]
```

---

## Compliance and Audit Requirements

If your project has compliance requirements:

### Audit Trail

**Your requirements**:
```
- Change request reference: [Required / Optional]
- Approver sign-off: [Required / Optional]
- Audit category: [Required in footer / Not required]
```

### Security-Related Commits

**Your requirements**:
```
- Security fixes type: [fix / security]
- Disclosure: [Private initially / Public]
- Required reviews: [Security team / Standard review]
```

### Data Privacy

**Your requirements**:
```
- PII-related changes: [Require DPO review / Standard]
- Data migration commits: [Require special footer / Standard]
- GDPR compliance notes: [Required / Optional]
```

---

## Examples

Provide examples of good commit messages for your project:

### Example 1: Feature Addition
```
feat(auth): add OAuth2 authentication

Implements OAuth2 flow for Google and GitHub providers.
Users can now sign in using their social accounts.

Closes #1234
```

### Example 2: Bug Fix
```
fix(payment): handle timeout in transaction processing

Root cause: Stripe API calls were timing out after 5 seconds.
Solution: Increased timeout to 30 seconds and added retry logic.

Fixes #5678
```

### Example 3: Breaking Change
```
feat(api): migrate to REST API v2

BREAKING CHANGE: API endpoints moved to /v2/ namespace.

Migration guide: https://docs.example.com/migration-v2
All endpoints prefixed with /v2/ (e.g., /v2/users instead of /users).
Old v1 endpoints deprecated, will be removed in 3 months.

Closes #9999
```

### Example 4: Refactoring
```
refactor(db): extract query builder to separate module

Improves code reusability and testability.
No functional changes.

Reviewed-by: Jane Doe
```

---

## Quick Reference Card

Create a quick reference for your team:

```
HEADER: <type>(<scope>): <subject>
  Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
  Scopes: [Your scopes: auth, api, ui, db, ...]
  Subject: Imperative mood, ≤[XX] chars, no period

BODY: (optional)
  - Wrap at [XX] chars
  - Explain what and why
  - Use bullet points

FOOTER: (optional)
  - BREAKING CHANGE: description
  - Closes #[issue-number]
  - Co-authored-by: Name <email>
```

---

## Additional Notes

Add any project-specific notes or conventions:

```
[Your additional notes here]
```

---

**Template Version**: 1.0
**Last Updated**: 2025-12-11
