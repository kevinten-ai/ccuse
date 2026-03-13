---
name: ccuse
description: Install and configure ccuse - a profile switcher for Claude Code CLI. Use when the user wants to switch between different AI providers (Claude, GLM/Zhipu, Kimi/Moonshot) in Claude Code, or mentions ccuse, profile switching, or using alternative API providers.
---

# ccuse

ccuse is a profile switcher for Claude Code CLI. It allows you to easily switch between different API configurations - native Anthropic Claude, GLM (Zhipu AI), or Kimi (Moonshot AI).

## Installation

Run this command to install ccuse:

```bash
# Download and install
curl -fsSL https://raw.githubusercontent.com/kevinten-ai/ccuse/main/ccuse -o ~/.local/bin/ccuse && chmod +x ~/.local/bin/ccuse

# Verify installation
ccuse --help
```

If `~/.local/bin` is not in your PATH, add it:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Quick Setup

### Step 1: Save your current Claude settings

```bash
ccuse init-claude
```

This creates a backup of your current `settings.json` as the `claude` profile.

### Step 2: Create a provider profile

Choose one or more providers to configure:

**GLM (Zhipu AI):**
```bash
ccuse init-glm
```
Get your API key from: https://open.bigmodel.cn/

**Kimi (Moonshot AI):**
```bash
ccuse init-kimi
```
Get your API key from: https://platform.moonshot.cn/console/api-keys

The init command will:
1. Create a profile template in `~/.claude/profiles/`
2. Display available models and instructions
3. **Automatically open the file for editing**

### Step 3: Set your API key

After running init, the profile file opens automatically. Replace the placeholder:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY_HERE",
    ...
  }
}
```

Save and close the file.

### Step 4: Switch profiles

```bash
ccuse glm     # Use GLM (Zhipu AI)
ccuse kimi    # Use Kimi (Moonshot AI)
ccuse claude  # Back to native Claude
```

## Commands

| Command | Description |
|---------|-------------|
| `ccuse claude` | Switch to native Claude profile |
| `ccuse glm` | Switch to GLM (Zhipu AI) profile |
| `ccuse kimi` | Switch to Kimi (Moonshot AI) profile |
| `ccuse init-claude` | Save current settings as claude profile |
| `ccuse init-glm` | Create or reconfigure a GLM profile |
| `ccuse init-kimi` | Create or reconfigure a Kimi profile |
| `ccuse list` | List all available profiles (shows active) |
| `ccuse show` | Show current configuration |
| `ccuse edit <name>` | Edit a profile file |
| `ccuse remove <name>` | Remove a profile |

## Available Models

### GLM (Zhipu AI)

| Model | Description | Context |
|-------|-------------|---------|
| `GLM-5` | Latest flagship, coding aligned with Claude Opus 4.5 | 200K |
| `GLM-4.7` | High intelligence, better coding & aesthetics | 200K |
| `GLM-4.7-FlashX` | Lightweight, fast, cost-effective | 200K |

### Kimi (Moonshot AI)

| Model | Description | Context |
|-------|-------------|---------|
| `kimi-k2.5` | Latest, most intelligent, multimodal | 256K |
| `kimi-k2-0905-preview` | Enhanced agentic coding | 256K |
| `kimi-k2-turbo-preview` | High speed (60-100 tokens/s) | 256K |

## How It Works

```
~/.claude/
├── settings.json      # Active configuration
├── settings.json.bak  # Automatic backup
└── profiles/
    ├── claude.json    # Native Claude profile
    ├── glm.json       # GLM profile
    └── kimi.json      # Kimi profile
```

When you run `ccuse <name>`:
1. Creates a backup of current `settings.json`
2. Copies the profile to `settings.json`
3. Claude Code uses the new configuration immediately

### Reconfiguring a profile

If a profile already exists, you can reconfigure it:

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

## Troubleshooting

**Profile not found:**
```
Missing profile file: ~/.claude/profiles/glm.json
Run: ccuse init-glm
```
Run the init command as suggested.

**API key errors:**
Make sure you've replaced `YOUR_ZHIPU_API_KEY` or `YOUR_KIMI_API_KEY` with your actual API key.

**Editor not opening:**
Set your preferred editor:
```bash
export EDITOR=vim  # or code, nano, etc.
```

## More Information

- Repository: https://github.com/kevinten-ai/ccuse
- License: MIT
