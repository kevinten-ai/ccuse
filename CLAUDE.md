# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ccuse` is a profile switcher for Claude Code CLI. It supports global profile switching by swapping `settings.json`, project-scoped settings, and session-level provider switching with environment variables.

## Commands

```bash
ccuse claude       # Switch to native Claude profile
ccuse ark          # Switch to Volcengine Ark Agent Plan profile
ccuse volcengine   # Alias for ark
ccuse global kimi  # Explicit global switch
ccuse glm          # Switch to a GLM model through Ark Agent Plan
ccuse kimi         # Switch to Kimi (Moonshot AI) profile
ccuse minimax      # Switch to MiniMax profile
ccuse my-provider  # Switch to a custom profile in PROFILE_DIR
ccuse local kimi   # Print shell exports for a session-level profile
ccuse project kimi # Persist Kimi for the current project only
ccuse ck -c        # Launch Claude Code with Kimi and --continue
ccuse init-claude  # Save current settings.json as claude profile
ccuse init-ark     # Create an Ark Agent Plan profile template
ccuse init-glm     # Create a GLM profile template
ccuse init-kimi    # Create a Kimi profile template
ccuse init-minimax # Create a MiniMax profile template
ccuse list         # List all available profiles
ccuse show         # Show current configuration
ccuse doctor       # Check setup, active scopes, and next steps
ccuse edit <name>  # Edit a profile file
```

## Architecture

- Single Bash script (`ccuse`) plus a Bats regression suite
- Profiles stored as JSON files in `$CLAUDE_DIR/profiles/` (default: `~/.claude/profiles/`)
- Active settings at `$CLAUDE_DIR/settings.json`
- Automatic backup created with `.bak` suffix before switching
- Session-level commands emit or apply env vars without modifying `settings.json`; they require `python3` or `python` to parse profile JSON and clear known provider env vars before applying a profile
- Project-scoped commands write `./.claude/settings.json` and leave global settings untouched
- Automatic file opening after init using `$EDITOR`, `code`, or `nano`

## Supported Providers

| Provider | Base URL | Models |
|----------|----------|--------|
| Claude (Native) | Claude Code account/subscription or api.anthropic.com | claude-opus-4-6, claude-sonnet-4-6, etc. |
| Volcengine Ark | ark.cn-beijing.volces.com/api/plan | doubao-seed-2-0-code-preview-260215 |
| GLM via Ark Agent Plan | ark.cn-beijing.volces.com/api/plan | glm-5.1, glm-4.7, glm-4.7-FlashX |
| Kimi | api.kimi.com/coding/ | kimi-k2.6 |
| MiniMax | api.minimax.io/anthropic | MiniMax-M2.7, MiniMax-M2.7-highspeed |

## Environment Variables

- `CLAUDE_DIR` - Base Claude config directory (default: `~/.claude`)
- `PROFILE_DIR` - Directory for profile JSON files (default: `$CLAUDE_DIR/profiles`)
- `SETTINGS_FILE` - Path to active settings.json (default: `$CLAUDE_DIR/settings.json`)
- `BACKUP_SUFFIX` - Suffix for backup files (default: `.bak`)
