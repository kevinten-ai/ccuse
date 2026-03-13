# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ccuse` is a profile switcher for Claude Code CLI. It allows switching between different Claude API configurations (e.g., native Anthropic, GLM/Zhipu AI, Kimi/Moonshot AI) by swapping the `settings.json` file.

## Commands

```bash
ccuse claude       # Switch to native Claude profile
ccuse glm          # Switch to GLM (Zhipu AI) profile
ccuse kimi         # Switch to Kimi (Moonshot AI) profile
ccuse init-claude  # Save current settings.json as claude profile
ccuse init-glm     # Create a GLM profile template
ccuse init-kimi    # Create a Kimi profile template
ccuse list         # List all available profiles
ccuse edit <name>  # Edit a profile file
```

## Architecture

- Single bash script (`ccuse`) with no dependencies
- Profiles stored as JSON files in `$CLAUDE_DIR/profiles/` (default: `~/.claude/profiles/`)
- Active settings at `$CLAUDE_DIR/settings.json`
- Automatic backup created with `.bak` suffix before switching
- Automatic file opening after init using `$EDITOR`, `code`, or `nano`

## Supported Providers

| Provider | Base URL | Models |
|----------|----------|--------|
| Claude (Native) | api.anthropic.com | claude-opus-4-6, claude-sonnet-4-6, etc. |
| GLM | open.bigmodel.cn/api/anthropic | glm-5, glm-4.7 |
| Kimi | api.moonshot.cn/v1 | moonshot-v1-8k |

## Environment Variables

- `CLAUDE_DIR` - Base Claude config directory (default: `~/.claude`)
- `PROFILE_DIR` - Directory for profile JSON files (default: `$CLAUDE_DIR/profiles`)
- `SETTINGS_FILE` - Path to active settings.json (default: `$CLAUDE_DIR/settings.json`)
- `BACKUP_SUFFIX` - Suffix for backup files (default: `.bak`)
