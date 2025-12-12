# CLI Tool README Preferences

> **Project Type**: Command-line tool
> **Audience**: Developers and power users
> **Style**: Friendly but technical

---

## Required Sections

- [x] Title with one-line description
- [x] Installation (binaries + from source)
- [x] Quick Start (simplest command)
- [x] Commands Reference
- [x] Configuration file format
- [x] Usage examples (5-10 scenarios)
- [x] Troubleshooting
- [x] Contributing
- [x] License

---

## Badges

Include these badges:
- Build status (GitHub Actions)
- Latest release version
- License
- Platform support (Linux/macOS/Windows)

---

## Installation Format

```markdown
## Installation

### Binary Releases

Download pre-built binaries from [Releases](link):

```bash
# Linux/macOS
curl -L https://github.com/user/tool/releases/latest/download/tool -o tool
chmod +x tool
sudo mv tool /usr/local/bin/
```

```powershell
# Windows (PowerShell)
Invoke-WebRequest -Uri "https://github.com/user/tool/releases/latest/download/tool.exe" -OutFile "tool.exe"
```

### Package Managers

```bash
# Homebrew (macOS/Linux)
brew install tool

# Scoop (Windows)
scoop install tool
```

### From Source

```bash
git clone https://github.com/user/tool.git
cd tool
make install
```

### Verify Installation

```bash
tool --version
# Expected: tool 1.0.0
```
```

---

## Commands Reference Format

```markdown
## Commands

### `tool init`

Initialize a new project.

**Usage**:
```bash
tool init [OPTIONS] [PATH]
```

**Options**:
- `-t, --template <NAME>` - Template to use
- `-f, --force` - Overwrite existing files
- `--dry-run` - Show what would be created

**Examples**:
```bash
# Initialize in current directory
tool init

# Use specific template
tool init --template python ./my-project

# Preview changes
tool init --dry-run
```

### `tool build`

Build the project.

**Usage**:
```bash
tool build [OPTIONS]
```

**Options**:
- `-r, --release` - Build for release
- `-v, --verbose` - Verbose output
- `-o, --output <PATH>` - Output directory

**Examples**:
```bash
# Development build
tool build

# Release build
tool build --release
```
```

---

## Configuration Section

```markdown
## Configuration

Tool uses `.toolrc` in project root or `~/.config/tool/config.yaml`.

### Configuration File Format

```yaml
# .toolrc
project:
  name: "my-project"
  version: "1.0.0"

build:
  target: "release"
  optimize: true

output:
  directory: "./dist"
  format: "json"
```

### Environment Variables

- `TOOL_CONFIG` - Path to config file
- `TOOL_OUTPUT` - Override output directory
- `TOOL_VERBOSE` - Enable verbose logging (1/0)

### Defaults

If no config file exists:
- Output: `./dist`
- Format: `json`
- Optimization: `false`
```

---

## Usage Examples

Provide 7-10 real-world scenarios:

1. Initialize new project
2. Build with custom output
3. Use configuration file
4. Run with environment variables
5. Process multiple files
6. Watch mode for development
7. Deploy to production
8. Troubleshoot common issues
9. Integrate with CI/CD
10. Advanced customization

Each example should show:
- Command with flags
- Expected output
- Explanation of what it does

---

## Troubleshooting Section

```markdown
## Troubleshooting

### Command not found

**Problem**: `tool: command not found`

**Solution**:
```bash
# Add to PATH
export PATH="$PATH:/usr/local/bin"

# Or reinstall
curl -L [url] | sh
```

### Permission denied

**Problem**: `Permission denied` when running

**Solution**:
```bash
chmod +x /path/to/tool
```

### Config file not found

**Problem**: Tool doesn't load config

**Solution**:
1. Check file location: `tool config --show`
2. Create default: `tool init --config`
3. Specify explicitly: `tool --config /path/to/.toolrc`
```

---

**Last Updated**: 2025-12-11
