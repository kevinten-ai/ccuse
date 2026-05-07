# ccuse

A profile switcher for [Claude Code](https://claude.ai/code) CLI. Switch between native Claude Code account/subscription mode and compatible API providers globally, per project, or for one temporary shell session.

## Quick Install

> **Copy this prompt and ask your Claude Code:**

```
Install ccuse by running:
curl -fsSL https://raw.githubusercontent.com/kevinten-ai/ccuse/main/ccuse -o ~/.local/bin/ccuse && chmod +x ~/.local/bin/ccuse && ccuse --help
```

## Supported Providers

| Provider | Command | API Source | Models |
|----------|---------|------------|--------|
| Claude (Native) | `ccuse claude` | Claude Code account/subscription or Anthropic API | claude-opus-4-6, claude-sonnet-4-6, etc. |
| GLM | `ccuse glm` | [Zhipu AI](https://open.bigmodel.cn/) | GLM-5.1, GLM-4.7, GLM-4.7-FlashX |
| Kimi | `ccuse kimi` | [Moonshot AI](https://platform.moonshot.cn/) | kimi-k2.6 |
| MiniMax | `ccuse minimax` | [MiniMax](https://www.minimax.io/) | MiniMax-M2.7, MiniMax-M2.7-highspeed |

## Installation

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/kevinten-ai/ccuse/main/ccuse -o ~/.local/bin/ccuse && chmod +x ~/.local/bin/ccuse
```

### Install via Claude Code Skill

Tell Claude Code: *"Install ccuse skill"* or run:

```bash
# Read and follow the skill instructions
curl -fsSL https://raw.githubusercontent.com/kevinten-ai/ccuse/main/skill/SKILL.md
```

### Manual Install

```bash
# Clone and setup
git clone https://github.com/kevinten-ai/ccuse.git
cd ccuse
chmod +x ccuse

# Add to PATH (choose one)
ln -s $(pwd)/ccuse /usr/local/bin/ccuse  # System-wide
# OR
ln -s $(pwd)/ccuse ~/.local/bin/ccuse     # User-local
```

### Verify Installation

```bash
ccuse --help
```

## Quick Start

### Step 1: Check your setup

```bash
ccuse doctor
```

Use this first if you are not sure whether Claude Code, Python, profiles, or project settings are ready.

### Step 2: Save your current Claude settings

```bash
ccuse init-claude
```

This creates a clean `claude` profile from your current Claude Code settings. Use it for native Claude Code account/subscription mode, including Pro/Max logins. No third-party API key is required for this profile.

### Step 3: Create additional profiles

```bash
# Create GLM profile
ccuse init-glm

# Create Kimi profile
ccuse init-kimi

# Create MiniMax profile
ccuse init-minimax
```

The init commands will:
1. Create a profile template in `~/.claude/profiles/`
2. Display instructions for getting your API key
3. **Automatically open the file for editing** (if an editor is available)

### Step 4: Set your API keys

After running init commands, the profile file will open automatically. Replace the placeholder:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY_HERE",
    ...
  }
}
```

**Get your API keys from:**
- GLM: https://open.bigmodel.cn/
- Kimi: https://platform.moonshot.cn/
- MiniMax: https://www.minimax.io/

### Step 5: Choose where to use a profile

```bash
ccuse start kimi -c       # Use Kimi once for this launch
ccuse project kimi        # Use Kimi whenever Claude Code runs in this repo
ccuse global kimi         # Use Kimi globally
ccuse global claude       # Back to native Claude subscription mode globally
```

## Which Command Should I Use?

| Goal | Command |
|------|---------|
| Keep native Claude Code subscription as default | `ccuse init-claude && ccuse global claude` |
| Try Kimi/GLM/MiniMax once | `ccuse start kimi -c` |
| Use a provider only in the current terminal | `eval "$(ccuse local kimi)"` |
| Persist a provider for one repository | `ccuse project kimi` |
| Change the global default everywhere | `ccuse global kimi` |
| See what is active | `ccuse doctor` |

## Commands

### Global Profile Switching

| Command | Aliases | File impact | Description |
|---------|---------|-------------|-------------|
| `ccuse claude` | `ccuse global claude` | Writes `settings.json` | Switch to native Claude profile |
| `ccuse glm` | `ccuse global glm` | Writes `settings.json` | Switch to GLM (Zhipu AI) profile |
| `ccuse kimi` | `ccuse global kimi` | Writes `settings.json` | Switch to Kimi (Moonshot AI) profile |
| `ccuse minimax` | `ccuse global minimax` | Writes `settings.json` | Switch to MiniMax profile |
| `ccuse <profile>` | - | Writes `settings.json` | Switch to any custom profile in `$PROFILE_DIR` |
| `ccuse init-claude` | - | Writes `claude.json` | Save current settings as a clean Claude profile |
| `ccuse init-glm` | - | Writes `glm.json` | Create or reconfigure a GLM profile |
| `ccuse init-kimi` | - | Writes `kimi.json` | Create or reconfigure a Kimi profile |
| `ccuse init-minimax` | - | Writes `minimax.json` | Create or reconfigure a MiniMax profile |
| `ccuse list` | `ccuse ls` | Read-only | List all available profiles and mark the active one |
| `ccuse show` | `ccuse config`, `ccuse current` | Read-only | Show current Claude Code configuration with secrets masked |
| `ccuse doctor` | `ccuse status` | Read-only | Check setup, active scopes, and next steps |
| `ccuse edit <name>` | - | Creates if missing | Open a profile file for editing |
| `ccuse remove <name>` | `ccuse rm <name>`, `ccuse delete <name>` | Deletes profile JSON | Remove a profile after confirmation |

### Session-Level Environment Variables (No File Changes)

These commands require `python3` or `python` so profile JSON can be parsed safely.

| Command | Aliases | File impact | Description |
|---------|---------|-------------|-------------|
| `eval "$(ccuse local <profile>)"` | - | No file changes | Load profile env vars into the current shell |
| `eval "$(ccuse local rm)"` | `remove`, `reset` | No file changes | Unset Claude-related env vars in the current shell |
| `ccuse local show` | `ccuse local current` | Read-only | Show current shell's Claude env vars with secrets masked |
| `ccuse start <profile> [-c]` | `ccuse s <profile> [-c]` | No file changes | Load env vars and launch Claude Code |
| `ccuse cc [-c]` | - | No file changes | Quick start: claude profile + launch |
| `ccuse ck [-c]` | - | No file changes | Quick start: kimi profile + launch |
| `ccuse cg [-c]` | - | No file changes | Quick start: glm profile + launch |
| `ccuse cm [-c]` | - | No file changes | Quick start: minimax profile + launch |

The `-c` or `--continue` flag resumes your last Claude Code conversation. `local` prints shell commands for you to `eval`; `start` and the quick aliases set env vars only for the Claude Code process they launch. These commands first clear known provider env vars, then load the selected profile, so `ccuse local claude` and `ccuse start claude` work for native Claude Code subscription mode even after using Kimi/GLM/MiniMax. None of these commands modify `settings.json`.

### Project-Scoped Persistent Profiles

Use these when one repository or working directory should keep using a specific provider without changing the global Claude Code profile.

| Command | Aliases | File impact | Description |
|---------|---------|-------------|-------------|
| `ccuse project <profile>` | `ccuse p <profile>` | Writes `./.claude/settings.json` | Persist a profile for the current project |
| `ccuse project show` | `ccuse project current` | Read-only | Show the current project profile |
| `ccuse project rm` | `remove`, `reset` | Deletes `./.claude/settings.json` | Remove the project-specific profile |

Example:

```bash
ccuse project kimi   # This project keeps using Kimi
ccuse claude         # Global default can still be native Claude subscription mode
```

## Available Models

### GLM (Zhipu AI)

| Model | Description | Context |
|-------|-------------|---------|
| `GLM-5.1` | Latest flagship, best overall performance | 200K |
| `GLM-4.7` | High intelligence, better coding & aesthetics | 200K |
| `GLM-4.7-FlashX` | Lightweight, fast, cost-effective | 200K |

### Kimi (Moonshot AI)

| Model | Description | Context |
|-------|-------------|---------|
| `kimi-k2.6` | Latest, most intelligent, multimodal | 256K |

### MiniMax

| Model | Description | Context |
|-------|-------------|---------|
| `MiniMax-M2.7` | Latest, high intelligence | 200K |
| `MiniMax-M2.7-highspeed` | Faster response variant | 200K |

## How It Works

### Global Profiles

```
~/.claude/
├── settings.json      # Active global configuration
├── settings.json.bak  # Automatic backup
└── profiles/
    ├── claude.json    # Native Claude Code account/subscription profile
    ├── glm.json       # GLM profile
    ├── kimi.json      # Kimi profile
    └── minimax.json   # MiniMax profile
```

When you run `ccuse <name>`:
1. Creates a backup of current `settings.json`
2. Copies the profile to `settings.json`
3. Claude Code uses the new configuration on next run

### Session-Level Profiles

When you run `eval "$(ccuse local <name>)"`:
1. Profile environment variables are loaded into the current shell session
2. No files are modified - `settings.json` stays unchanged
3. Claude Code reads these environment variables when launched from that shell

```bash
# Load env vars into current shell (no files changed)
eval "$(ccuse local kimi)"

# Launch Claude Code with these env vars active
claude

# Or use the one-shot shortcut
ccuse ck -c   # Load Kimi env vars and launch Claude with --continue
```

Use `ccuse local show` to inspect the active shell env vars, and `eval "$(ccuse local rm)"` to clear them.

### Project Profiles

When you run `ccuse project <name>`:
1. Creates `./.claude/settings.json` in the current working directory
2. Leaves the global `~/.claude/settings.json` untouched
3. Claude Code runs from this project use the project profile until you run `ccuse project rm`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_DIR` | `~/.claude` | Base Claude config directory |
| `PROFILE_DIR` | `$CLAUDE_DIR/profiles` | Directory for profile files |
| `SETTINGS_FILE` | `$CLAUDE_DIR/settings.json` | Path to active settings |
| `BACKUP_SUFFIX` | `.bak` | Suffix for backup files |
| `PROJECT_CLAUDE_DIR` | `.claude` | Current project Claude config directory |
| `PROJECT_SETTINGS_FILE` | `$PROJECT_CLAUDE_DIR/settings.json` | Current project settings path |

## Adding Custom Profiles

You can create custom profiles for any Anthropic-compatible API:

1. Create or open a JSON file in `~/.claude/profiles/`. Profile names must start with a letter or number and may contain letters, numbers, dots, underscores, and hyphens. Custom profile names cannot reuse built-in commands or aliases such as `global`, `project`, `local`, `start`, `doctor`, `list`, `show`, `edit`, `remove`, `cc`, `ck`, `cg`, or `cm`.

```bash
ccuse edit my-provider
```

2. Add your configuration:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://your-api-endpoint/v1",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

3. Use it:

```bash
ccuse global my-provider          # Global switch
ccuse my-provider                 # Short global switch
eval "$(ccuse local my-provider)" # Session-only switch
ccuse project my-provider         # Project-only persistent switch
ccuse start my-provider -c        # Launch Claude Code with this profile
```

## Troubleshooting

### Profile not found

```
Missing profile file: ~/.claude/profiles/glm.json
Run: ccuse init-glm
```

Run the init command as suggested to create the profile.

### Reconfiguring a profile

If you want to reset a profile to its default template:

```bash
ccuse init-glm
# Profile already exists: ~/.claude/profiles/glm.json
# Do you want to reconfigure it? [y/N] y
# Backup created: ~/.claude/profiles/glm.json.bak.20240313120000
```

The old profile is backed up with a timestamp before creating the new template.

### Removing a profile

```bash
ccuse remove glm
# Removing profile: glm
# Are you sure? [y/N] y
# Profile removed: glm
```

### API key errors

Make sure you've replaced `YOUR_ZHIPU_API_KEY`, `YOUR_KIMI_API_KEY`, or `YOUR_MINIMAX_API_KEY` with your actual API key in the profile file.

### Editor not opening

The script uses these editors in order:
1. `$EDITOR` environment variable
2. VS Code (`code`)
3. `nano`

Set your preferred editor:
```bash
export EDITOR=vim  # or code, nano, etc.
```

## Testing

ccuse includes a comprehensive test suite using [bats-core](https://github.com/bats-core/bats-core):

```bash
# Install bats (requires npm)
npm install -g bats

# Run all tests
bats tests/test_ccuse.bats
```

## License

MIT
