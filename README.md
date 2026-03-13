# ccuse

A profile switcher for [Claude Code](https://claude.ai/code) CLI. Easily switch between different API configurations.

## Installation

```bash
# Clone and make executable
git clone https://github.com/kevinten-ai/ccuse.git
cd ccuse
chmod +x ccuse

# Optional: add to PATH
ln -s $(pwd)/ccuse /usr/local/bin/ccuse
```

## Usage

```bash
ccuse claude       # Switch to native Claude profile
ccuse glm          # Switch to GLM (Zhipu AI) profile
ccuse init-claude  # Save current settings.json as claude profile
ccuse init-glm     # Create a GLM profile template
```

### Quick Start

1. Save your current Claude settings as a profile:
   ```bash
   ccuse init-claude
   ```

2. Create a GLM profile template:
   ```bash
   ccuse init-glm
   ```

3. Edit `~/.claude/profiles/glm.json` and set your Zhipu API key.

4. Switch between profiles:
   ```bash
   ccuse glm   # Use GLM
   ccuse claude # Use native Claude
   ```

## How It Works

- Profiles are stored as JSON files in `~/.claude/profiles/`
- Switching copies the profile to `~/.claude/settings.json`
- Creates automatic backup with `.bak` suffix

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_DIR` | `~/.claude` | Base Claude config directory |
| `PROFILE_DIR` | `$CLAUDE_DIR/profiles` | Directory for profile files |
| `SETTINGS_FILE` | `$CLAUDE_DIR/settings.json` | Path to active settings |
| `BACKUP_SUFFIX` | `.bak` | Suffix for backup files |

## License

MIT
