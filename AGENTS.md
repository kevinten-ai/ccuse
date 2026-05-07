# Repository Guidelines

## Project Structure & Module Organization

`ccuse` is the main Bash CLI entrypoint. Keep command parsing, profile initialization, and helper functions in this file unless a split becomes clearly necessary. `tests/test_ccuse.bats` contains the Bats test suite and uses temporary Claude configuration directories to avoid touching a real `~/.claude`. `README.md` is the user-facing documentation, `CLAUDE.md` contains Claude Code guidance, `skill/SKILL.md` defines the installable skill, and `docs/` stores documentation assets such as `workflow.png`.

## Build, Test, and Development Commands

```bash
chmod +x ccuse
bash ccuse --help
bats tests/test_ccuse.bats
```

`chmod +x ccuse` restores executable mode after checkout if needed. `bash ccuse --help` is the quickest smoke test for syntax and usage output. `bats tests/test_ccuse.bats` runs the full regression suite; install Bats first with `npm install -g bats` if it is not available.

## Coding Style & Naming Conventions

Use Bash with `set -euo pipefail`. Prefer small functions with `snake_case` names, quoted variable expansions, and explicit local variables (`local name="$1"`). Follow the existing two-space indentation inside functions and conditionals. Keep command names user-oriented and short, for example `init-kimi`, `local show`, and `remove`. Profile files are JSON and use lowercase provider names under `$CLAUDE_DIR/profiles/`, such as `glm.json` or `minimax.json`.

## Testing Guidelines

Add or update Bats tests for every behavior change. Name tests with an area prefix and expected behavior, for example `@test "switch: missing profile exits 1 with helpful message"`. Tests should set `CLAUDE_DIR`, `PROFILE_DIR`, and `SETTINGS_FILE` to temporary paths and must not require real API keys, real Claude settings, or network access.

## Commit & Pull Request Guidelines

Recent history uses concise imperative commits, sometimes with Conventional Commit prefixes such as `fix:`. Use messages like `fix: mask API keys in show output` or `Add MiniMax profile tests`. Pull requests should include a short description, the user-visible commands or flows affected, test results (`bats tests/test_ccuse.bats`), and README or skill updates when commands, providers, or install steps change. Include screenshots only for documentation image changes.

## Security & Configuration Tips

Do not commit real API keys, generated profile JSON with secrets, or local `.claude` settings. Preserve masking in commands that display configuration. When changing profile switching, keep backups and temporary test directories intact so contributors do not overwrite user configuration during development.
