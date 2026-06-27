---
name: ccuse
description: Install and configure ccuse - a profile switcher for Claude Code CLI. Use when the user wants to switch between different AI providers (Claude, Volcengine Ark Coding Plan, GLM/Zhipu, Kimi/Moonshot, MiniMax) in Claude Code, or mentions ccuse, profile switching, or using alternative API providers.
---

# ccuse

ccuse is a profile switcher for Claude Code CLI. It supports native Claude Code account/subscription mode, Anthropic API profiles, Volcengine Ark Coding Plan, GLM (Zhipu AI), Kimi (Moonshot AI), and MiniMax profiles.

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
Use this profile for native Claude Code account/subscription mode; it does not need a third-party API key.

### Step 2: Create a provider profile

Choose one or more providers to configure:

**Volcengine Ark Coding Plan:**
```bash
ccuse init-ark
```
Use your Ark Coding Plan API key from the Volcengine console.

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

**MiniMax:**
```bash
ccuse init-minimax
```
Get your API key from: https://www.minimax.io/

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
ccuse ark     # Use Volcengine Ark Coding Plan
ccuse glm     # Use GLM (Zhipu AI)
ccuse kimi    # Use Kimi (Moonshot AI)
ccuse minimax # Use MiniMax
ccuse claude  # Back to native Claude
```

## Commands

| Command | Description |
|---------|-------------|
| `ccuse claude` | Switch to native Claude profile |
| `ccuse ark` / `volcengine` | Switch to Volcengine Ark Coding Plan profile |
| `ccuse global <profile>` / `g` | Explicitly switch the global default |
| `ccuse glm` | Switch to GLM (Zhipu AI) profile |
| `ccuse kimi` | Switch to Kimi (Moonshot AI) profile |
| `ccuse minimax` | Switch to MiniMax profile |
| `ccuse <profile>` | Switch to a custom profile in `~/.claude/profiles/` |
| `eval "$(ccuse local <profile>)"` | Load profile env vars into current shell session |
| `ccuse project <profile>` / `p` | Persist a profile for the current project in `./.claude/settings.json` |
| `ccuse start <profile> [-c]` | Launch Claude Code with profile env vars |
| `ccuse cc` / `ca` / `ck` / `cg` / `cm` | Launch Claude Code with claude/ark/kimi/glm/minimax |
| `ccuse init-claude` | Save current settings as claude profile |
| `ccuse init-ark` | Create or reconfigure an Ark Coding Plan profile |
| `ccuse init-volcengine` | Alias for `ccuse init-ark` |
| `ccuse init-glm` | Create or reconfigure a GLM profile |
| `ccuse init-kimi` | Create or reconfigure a Kimi profile |
| `ccuse init-minimax` | Create or reconfigure a MiniMax profile |
| `ccuse list` / `ls` | List all available profiles (shows active) |
| `ccuse show` / `config` / `current` | Show current configuration |
| `ccuse doctor` / `status` | Check setup, active scopes, and next steps |
| `ccuse edit <name>` | Create or edit a profile file |
| `ccuse remove <name>` / `rm` / `delete` | Remove a profile |

Session-level commands (`local`, `start`, `cc`, `ca`, `ck`, `cg`, `cm`) require `python3` or `python` to parse profile JSON safely. They clear known provider env vars before applying the selected profile, so native Claude Code subscription mode is not polluted by a previous third-party provider.

## Available Models

### Volcengine Ark Coding Plan

| Model | Description | Context |
|-------|-------------|---------|
| `doubao-seed-2-0-code-preview-260215` | Coding Plan compatible code model | See Volcengine model docs |

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

```
~/.claude/
├── settings.json      # Active configuration
├── settings.json.bak  # Automatic backup
└── profiles/
    ├── claude.json    # Native Claude profile
    ├── ark.json       # Volcengine Ark Coding Plan profile
    ├── glm.json       # GLM profile
    └── kimi.json      # Kimi profile
```

When you run `ccuse <name>`:
1. Creates a backup of current `settings.json`
2. Copies the profile to `settings.json`
3. Claude Code uses the new configuration immediately

MiniMax profiles are stored alongside the others as `~/.claude/profiles/minimax.json`.

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
Make sure you've replaced `YOUR_ARK_API_KEY`, `YOUR_ZHIPU_API_KEY`, `YOUR_KIMI_API_KEY`, or `YOUR_MINIMAX_API_KEY` with your actual API key.

**Editor not opening:**
Set your preferred editor:
```bash
export EDITOR=vim  # or code, nano, etc.
```

## More Information

- Repository: https://github.com/kevinten-ai/ccuse
- License: MIT
