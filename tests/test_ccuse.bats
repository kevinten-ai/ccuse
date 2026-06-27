#!/usr/bin/env bats

setup() {
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  export CLAUDE_DIR="$TEMP_DIR/.claude"
  export PROFILE_DIR="$CLAUDE_DIR/profiles"
  export SETTINGS_FILE="$CLAUDE_DIR/settings.json"
  export BACKUP_SUFFIX=".bak"
  export EDITOR=:
  mkdir -p "$PROFILE_DIR"

  CCUSE_BIN="$BATS_TEST_DIRNAME/../ccuse"
  export CCUSE_BIN

  FAKE_BIN="$TEMP_DIR/bin"
  mkdir -p "$FAKE_BIN"
  cat > "$FAKE_BIN/claude" <<'SH'
#!/usr/bin/env bash
echo "fake claude launched"
echo "args: $*"
echo "MODEL: ${MODEL:-}"
echo "ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL:-}"
SH
  chmod +x "$FAKE_BIN/claude"
  export PATH="$FAKE_BIN:$PATH"
}

teardown() {
  rm -rf "$TEMP_DIR"
}

# ============================================================================
# Help / Usage
# ============================================================================

@test "help: --help exits 0 and shows usage" {
  run bash "$CCUSE_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"ccuse claude"* ]]
  [[ "$output" == *"ccuse ark"* ]]
  [[ "$output" == *"ccuse ca"* ]]
  [[ "$output" == *"ccuse glm"* ]]
  [[ "$output" == *"ccuse kimi"* ]]
  [[ "$output" == *"ccuse minimax"* ]]
  [[ "$output" == *"ccuse global"* ]]
  [[ "$output" == *"ccuse project"* ]]
  [[ "$output" == *"ccuse doctor"* ]]
  [[ "$output" == *"ccuse <profile>"* ]]
}

@test "help: -h exits 0 and shows usage" {
  run bash "$CCUSE_BIN" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "help: no arguments exits 0 and shows usage" {
  run bash "$CCUSE_BIN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "help: unknown command exits 2 and shows usage" {
  run bash "$CCUSE_BIN" unknown-cmd
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown command"* ]]
  [[ "$output" == *"Usage:"* ]]
}

# ============================================================================
# Profile Switching (apply_profile)
# ============================================================================

@test "switch: claude profile applies successfully" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  run bash "$CCUSE_BIN" claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: claude"* ]]
  [ -f "$SETTINGS_FILE" ]
}

@test "switch: ark profile applies successfully" {
  cat > "$PROFILE_DIR/ark.json" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://ark.cn-beijing.volces.com/api/coding"}}
JSON
  run bash "$CCUSE_BIN" ark
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: ark"* ]]
  [ -f "$SETTINGS_FILE" ]
}

@test "switch: glm profile applies successfully" {
  cat > "$PROFILE_DIR/glm.json" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://open.bigmodel.cn/api/anthropic"}}
JSON
  run bash "$CCUSE_BIN" glm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: glm"* ]]
  [ -f "$SETTINGS_FILE" ]
}

@test "switch: kimi profile applies successfully" {
  cat > "$PROFILE_DIR/kimi.json" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://api.kimi.com/coding/"}}
JSON
  run bash "$CCUSE_BIN" kimi
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: kimi"* ]]
}

@test "switch: minimax profile applies successfully" {
  cat > "$PROFILE_DIR/minimax.json" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://api.minimax.io/anthropic"}}
JSON
  run bash "$CCUSE_BIN" minimax
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: minimax"* ]]
}

@test "switch: missing profile exits 1 with helpful message" {
  [ -d "$PROFILE_DIR" ]
  [ ! -f "$PROFILE_DIR/claude.json" ]
  run bash "$CCUSE_BIN" claude
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
  [[ "$output" == *"Run: ccuse init-claude"* ]]
}

@test "switch: custom profile applies successfully" {
  echo '{"env":{"MODEL":"custom-model"}}' > "$PROFILE_DIR/my-provider.json"
  run bash "$CCUSE_BIN" my-provider
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: my-provider"* ]]
  run cat "$SETTINGS_FILE"
  [[ "$output" == *"custom-model"* ]]
}

@test "global: explicit global command applies profile" {
  echo '{"env":{"MODEL":"kimi-k2.6"}}' > "$PROFILE_DIR/kimi.json"
  run bash "$CCUSE_BIN" global kimi
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: kimi"* ]]
  run cat "$SETTINGS_FILE"
  [[ "$output" == *"kimi-k2.6"* ]]
}

@test "global: g alias applies profile" {
  echo '{"env":{"MODEL":"glm-5.1"}}' > "$PROFILE_DIR/glm.json"
  run bash "$CCUSE_BIN" g glm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to profile: glm"* ]]
}

@test "global: no profile shows usage" {
  run bash "$CCUSE_BIN" global
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: ccuse global"* ]]
}

@test "switch: rejects invalid profile name" {
  run bash "$CCUSE_BIN" "../bad"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid profile name"* ]]
}

@test "switch: backup is created before applying" {
  echo '{"old":true}' > "$SETTINGS_FILE"
  echo '{}' > "$PROFILE_DIR/claude.json"
  run bash "$CCUSE_BIN" claude
  [ "$status" -eq 0 ]
  [ -f "${SETTINGS_FILE}.bak" ]
}

@test "switch: claude profile warns if it contains third-party base url" {
  cat > "$PROFILE_DIR/claude.json" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://third.party/api"}}
JSON
  run bash -c 'echo "n" | bash "$CCUSE_BIN" claude'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Warning: claude profile contains ANTHROPIC_BASE_URL"* ]]
}

# ============================================================================
# Profile Initialization
# ============================================================================

@test "init-claude: creates empty profile when no settings exist" {
  run bash "$CCUSE_BIN" init-claude
  [ "$status" -eq 0 ]
  [ -f "$PROFILE_DIR/claude.json" ]
  run bash -c "cat \"$PROFILE_DIR/claude.json\""
  [[ "$output" == *"{"* ]]
}

@test "init-claude: saves current settings when they exist" {
  echo '{"env":{"FOO":"bar"}}' > "$SETTINGS_FILE"
  run bash "$CCUSE_BIN" init-claude
  [ "$status" -eq 0 ]
  run cat "$PROFILE_DIR/claude.json"
  [[ "$output" == *"FOO"* ]]
}

@test "init-claude: strips third-party config from current settings" {
  cat > "$SETTINGS_FILE" <<'JSON'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "secret",
    "ANTHROPIC_BASE_URL": "https://third.party/api",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5",
    "KEEP_THIS": "yes"
  }
}
JSON
  run bash "$CCUSE_BIN" init-claude
  [ "$status" -eq 0 ]
  run cat "$PROFILE_DIR/claude.json"
  [[ "$output" == *"KEEP_THIS"* ]]
  [[ "$output" != *"ANTHROPIC_BASE_URL"* ]]
  [[ "$output" != *"ANTHROPIC_AUTH_TOKEN"* ]]
}

@test "init-claude: asks to reconfigure and backs up existing profile" {
  echo '{"existing":true}' > "$PROFILE_DIR/claude.json"
  run bash -c 'echo "y" | bash "$CCUSE_BIN" init-claude'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Backup created"* ]]
  [ -f "$PROFILE_DIR/claude.json.bak."* ]
}

@test "init-claude: keeps existing profile when user declines" {
  echo '{"existing":true}' > "$PROFILE_DIR/claude.json"
  run bash -c 'echo "n" | bash "$CCUSE_BIN" init-claude'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Keeping existing profile"* ]]
  run cat "$PROFILE_DIR/claude.json"
  [[ "$output" == *"existing"* ]]
}

@test "init-glm: creates template with correct models" {
  run bash "$CCUSE_BIN" init-glm
  [ "$status" -eq 0 ]
  [ -f "$PROFILE_DIR/glm.json" ]
  run cat "$PROFILE_DIR/glm.json"
  [[ "$output" == *"glm-5.1"* ]]
  [[ "$output" == *"open.bigmodel.cn"* ]]
  [[ "$output" == *"YOUR_ZHIPU_API_KEY"* ]]
}

@test "init-ark: creates template with correct models" {
  run bash "$CCUSE_BIN" init-ark
  [ "$status" -eq 0 ]
  [ -f "$PROFILE_DIR/ark.json" ]
  run cat "$PROFILE_DIR/ark.json"
  [[ "$output" == *"doubao-seed-2-0-code-preview-260215"* ]]
  [[ "$output" == *"ark.cn-beijing.volces.com/api/coding"* ]]
  [[ "$output" == *"YOUR_ARK_API_KEY"* ]]
}

@test "init-kimi: creates template with correct models" {
  run bash "$CCUSE_BIN" init-kimi
  [ "$status" -eq 0 ]
  [ -f "$PROFILE_DIR/kimi.json" ]
  run cat "$PROFILE_DIR/kimi.json"
  [[ "$output" == *"kimi-k2.6"* ]]
  [[ "$output" == *"api.kimi.com"* ]]
  [[ "$output" == *"YOUR_KIMI_API_KEY"* ]]
}

@test "init-minimax: creates template with correct models" {
  run bash "$CCUSE_BIN" init-minimax
  [ "$status" -eq 0 ]
  [ -f "$PROFILE_DIR/minimax.json" ]
  run cat "$PROFILE_DIR/minimax.json"
  [[ "$output" == *"MiniMax-M2.7"* ]]
  [[ "$output" == *"api.minimax.io"* ]]
  [[ "$output" == *"YOUR_MINIMAX_API_KEY"* ]]
}

# ============================================================================
# Local Profile Commands
# ============================================================================

@test "local: outputs exports for current shell session" {
  cat > "$PROFILE_DIR/kimi.json" <<'JSON'
{"env":{"MODEL":"kimi-k2.6"}}
JSON
  run bash "$CCUSE_BIN" local kimi
  [ "$status" -eq 0 ]
  [[ "$output" == *"kimi-k2.6"* ]]
  [[ "$output" == *"export MODEL=kimi-k2.6"* ]]
  [[ "$output" == *"eval \"\$(ccuse local kimi)\""* ]]
  [ ! -f "./.claude/settings.json" ]
}

@test "local: claude profile outputs unsets for native subscription mode" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  run bash "$CCUSE_BIN" local claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"unset ANTHROPIC_BASE_URL"* ]]
  [[ "$output" == *"unset ANTHROPIC_AUTH_TOKEN"* ]]
}

@test "local: fails for missing profile" {
  run bash "$CCUSE_BIN" local nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
}

@test "local: rejects invalid env variable names" {
  cat > "$PROFILE_DIR/bad-env.json" <<'JSON'
{"env":{"BAD-NAME":"value"}}
JSON
  run bash "$CCUSE_BIN" local bad-env
  [ "$status" -eq 1 ]
  [[ "$output" == *"invalid environment variable name"* ]]
}

@test "local: rejects non-object env" {
  cat > "$PROFILE_DIR/bad-env.json" <<'JSON'
{"env":["ANTHROPIC_BASE_URL"]}
JSON
  run bash "$CCUSE_BIN" local bad-env
  [ "$status" -eq 1 ]
  [[ "$output" == *"profile env must be a JSON object"* ]]
}

@test "local rm: outputs unsets for current shell session" {
  run bash "$CCUSE_BIN" local rm
  [ "$status" -eq 0 ]
  [[ "$output" == *"unset ANTHROPIC_BASE_URL"* ]]
  [[ "$output" == *"unset ANTHROPIC_AUTH_TOKEN"* ]]
  [[ "$output" == *"eval \"\$(ccuse local rm)\""* ]]
}

@test "local remove and reset aliases output unsets" {
  run bash "$CCUSE_BIN" local remove
  [ "$status" -eq 0 ]
  [[ "$output" == *"unset ANTHROPIC_BASE_URL"* ]]

  run bash "$CCUSE_BIN" local reset
  [ "$status" -eq 0 ]
  [[ "$output" == *"unset ANTHROPIC_BASE_URL"* ]]
}

@test "local show: displays current shell environment" {
  export ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
  run bash "$CCUSE_BIN" local show
  [ "$status" -eq 0 ]
  [[ "$output" == *"api.kimi.com"* ]]
}

@test "local current alias displays current shell environment" {
  export ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
  run bash "$CCUSE_BIN" local current
  [ "$status" -eq 0 ]
  [[ "$output" == *"api.kimi.com"* ]]
}

@test "local show: indicates when no session env vars exist" {
  run bash "$CCUSE_BIN" local show
  [ "$status" -eq 0 ]
  [[ "$output" == *"no Claude-specific environment variables set"* ]]
}

@test "local: no subcommand shows usage" {
  run bash "$CCUSE_BIN" local
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: ccuse local"* ]]
}

# ============================================================================
# Project-Scoped Profiles
# ============================================================================

@test "project: applies profile to current project settings" {
  cat > "$PROFILE_DIR/kimi.json" <<'JSON'
{"env":{"MODEL":"kimi-k2.6"}}
JSON
  run bash "$CCUSE_BIN" project kimi
  [ "$status" -eq 0 ]
  [[ "$output" == *"Applied project profile: kimi"* ]]
  [ -f "./.claude/settings.json" ]
  run cat "./.claude/settings.json"
  [[ "$output" == *"kimi-k2.6"* ]]
}

@test "project: p alias applies profile" {
  cat > "$PROFILE_DIR/glm.json" <<'JSON'
{"env":{"MODEL":"glm-5.1"}}
JSON
  run bash "$CCUSE_BIN" p glm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Applied project profile: glm"* ]]
  [ -f "./.claude/settings.json" ]
}

@test "project: creates backup before replacing settings" {
  mkdir -p ./.claude
  echo '{"old":true}' > ./.claude/settings.json
  echo '{"env":{"MODEL":"MiniMax-M2.7"}}' > "$PROFILE_DIR/minimax.json"
  run bash "$CCUSE_BIN" project minimax
  [ "$status" -eq 0 ]
  [ -f "./.claude/settings.json.bak" ]
}

@test "project show: displays project configuration" {
  mkdir -p ./.claude
  cat > ./.claude/settings.json <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://api.kimi.com/coding/"}}
JSON
  run bash "$CCUSE_BIN" project show
  [ "$status" -eq 0 ]
  [[ "$output" == *"api.kimi.com"* ]]
}

@test "project rm: removes project configuration" {
  mkdir -p ./.claude
  echo '{"env":{"MODEL":"kimi-k2.6"}}' > ./.claude/settings.json
  run bash "$CCUSE_BIN" project rm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed project configuration"* ]]
  [ ! -f "./.claude/settings.json" ]
}

@test "project: fails for missing profile" {
  run bash "$CCUSE_BIN" project nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
}

@test "project: no subcommand shows usage" {
  run bash "$CCUSE_BIN" project
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: ccuse project"* ]]
}

# ============================================================================
# List Profiles
# ============================================================================

@test "list: shows available profiles and marks active" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  echo '{}' > "$PROFILE_DIR/glm.json"
  cp "$PROFILE_DIR/claude.json" "$SETTINGS_FILE"
  run bash "$CCUSE_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
  [[ "$output" == *"glm"* ]]
}

@test "list: shows message when no profiles exist" {
  run bash "$CCUSE_BIN" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"no profiles found"* ]]
}

@test "list: ls alias works" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  run bash "$CCUSE_BIN" ls
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
}

# ============================================================================
# Show Configuration
# ============================================================================

@test "show: displays current configuration" {
  cat > "$SETTINGS_FILE" <<'JSON'
{"env":{"ANTHROPIC_BASE_URL":"https://api.kimi.com/coding/"}}
JSON
  run bash "$CCUSE_BIN" show
  [ "$status" -eq 0 ]
  [[ "$output" == *"api.kimi.com"* ]]
}

@test "show: handles missing settings file" {
  run bash "$CCUSE_BIN" show
  [ "$status" -eq 0 ]
  [[ "$output" == *"No settings file found"* ]]
}

@test "show: masks api keys in output" {
  cat > "$SETTINGS_FILE" <<'JSON'
{"env":{"ANTHROPIC_AUTH_TOKEN":"sk-secret-key-value"}}
JSON
  run bash "$CCUSE_BIN" show
  [ "$status" -eq 0 ]
  [[ "$output" == *"****"* ]]
}

@test "show: config alias works" {
  cat > "$SETTINGS_FILE" <<'JSON'
{"env":{"FOO":"bar"}}
JSON
  run bash "$CCUSE_BIN" config
  [ "$status" -eq 0 ]
  [[ "$output" == *"bar"* ]]
}

@test "show: current alias works" {
  cat > "$SETTINGS_FILE" <<'JSON'
{"env":{"FOO":"bar"}}
JSON
  run bash "$CCUSE_BIN" current
  [ "$status" -eq 0 ]
  [[ "$output" == *"bar"* ]]
}

# ============================================================================
# Doctor
# ============================================================================

@test "doctor: shows setup status and next steps" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  cp "$PROFILE_DIR/claude.json" "$SETTINGS_FILE"
  run bash "$CCUSE_BIN" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"ccuse doctor"* ]]
  [[ "$output" == *"Claude Code CLI: found"* ]]
  [[ "$output" == *"Python JSON parser:"* ]]
  [[ "$output" == *"Active global profile: claude"* ]]
  [[ "$output" == *"Common next steps"* ]]
}

@test "doctor: status alias works" {
  run bash "$CCUSE_BIN" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"ccuse doctor"* ]]
}

# ============================================================================
# Remove Profile
# ============================================================================

@test "remove: deletes profile file" {
  echo '{}' > "$PROFILE_DIR/old.json"
  run bash -c 'echo "y" | bash "$CCUSE_BIN" remove old'
  [ "$status" -eq 0 ]
  [ ! -f "$PROFILE_DIR/old.json" ]
}

@test "remove: warns when deleting active profile" {
  echo '{}' > "$PROFILE_DIR/active.json"
  cp "$PROFILE_DIR/active.json" "$SETTINGS_FILE"
  run bash -c 'echo "y" | bash "$CCUSE_BIN" remove active'
  [ "$status" -eq 0 ]
  [[ "$output" == *"currently active profile"* ]]
}

@test "remove: fails for missing profile" {
  run bash "$CCUSE_BIN" remove nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Profile not found"* ]]
}

@test "remove: rm alias works" {
  echo '{}' > "$PROFILE_DIR/todelete.json"
  run bash -c 'echo "y" | bash "$CCUSE_BIN" rm todelete'
  [ "$status" -eq 0 ]
  [ ! -f "$PROFILE_DIR/todelete.json" ]
}

@test "remove: delete alias works" {
  echo '{}' > "$PROFILE_DIR/todelete.json"
  run bash -c 'echo "y" | bash "$CCUSE_BIN" delete todelete'
  [ "$status" -eq 0 ]
  [ ! -f "$PROFILE_DIR/todelete.json" ]
}

# ============================================================================
# Quick Start Aliases
# ============================================================================

@test "quick: cc launches claude profile" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  run bash "$CCUSE_BIN" cc
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: claude"* ]]
  [[ "$output" == *"fake claude launched"* ]]
}

@test "quick: ck launches kimi profile" {
  cat > "$PROFILE_DIR/kimi.json" <<'JSON'
{"env":{"MODEL":"kimi-k2.6"}}
JSON
  run bash "$CCUSE_BIN" ck
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: kimi"* ]]
  [[ "$output" == *"MODEL: kimi-k2.6"* ]]
}

@test "quick: ca launches ark profile" {
  cat > "$PROFILE_DIR/ark.json" <<'JSON'
{"env":{"MODEL":"doubao-seed-2-0-code-preview-260215"}}
JSON
  run bash "$CCUSE_BIN" ca
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: ark"* ]]
  [[ "$output" == *"MODEL: doubao-seed-2-0-code-preview-260215"* ]]
}

@test "quick: cg launches glm profile" {
  cat > "$PROFILE_DIR/glm.json" <<'JSON'
{"env":{"MODEL":"glm-5.1"}}
JSON
  run bash "$CCUSE_BIN" cg
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: glm"* ]]
  [[ "$output" == *"MODEL: glm-5.1"* ]]
}

@test "quick: cm launches minimax profile" {
  cat > "$PROFILE_DIR/minimax.json" <<'JSON'
{"env":{"MODEL":"MiniMax-M2.7"}}
JSON
  run bash "$CCUSE_BIN" cm
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: minimax"* ]]
  [[ "$output" == *"MODEL: MiniMax-M2.7"* ]]
}

@test "quick: fails when profile is missing" {
  run bash "$CCUSE_BIN" cc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
}

# ============================================================================
# Start Session
# ============================================================================

@test "start: fails without profile argument" {
  run bash "$CCUSE_BIN" start
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: ccuse start"* ]]
}

@test "start: fails for missing profile" {
  run bash "$CCUSE_BIN" start nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
}

@test "start: s alias works with missing profile" {
  run bash "$CCUSE_BIN" s nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing profile file"* ]]
}

@test "start: supports custom profile" {
  cat > "$PROFILE_DIR/my-provider.json" <<'JSON'
{"env":{"MODEL":"custom-model"}}
JSON
  run bash "$CCUSE_BIN" start my-provider -c --debug
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading profile env vars: my-provider"* ]]
  [[ "$output" == *"args: --continue --debug"* ]]
  [[ "$output" == *"MODEL: custom-model"* ]]
}

@test "start: claude clears inherited provider env vars" {
  echo '{}' > "$PROFILE_DIR/claude.json"
  export ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
  run bash "$CCUSE_BIN" start claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"fake claude launched"* ]]
  [[ "$output" == *"ANTHROPIC_BASE_URL: "* ]]
  [[ "$output" != *"ANTHROPIC_BASE_URL: https://api.kimi.com/coding/"* ]]
}

# ============================================================================
# Edit Profile
# ============================================================================

@test "edit: fails without profile name" {
  run bash "$CCUSE_BIN" edit
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: ccuse edit"* ]]
}

@test "edit: creates missing custom profile" {
  export EDITOR=:
  run bash "$CCUSE_BIN" edit my-provider
  [ "$status" -eq 0 ]
  [[ "$output" == *"Created profile"* ]]
  [ -f "$PROFILE_DIR/my-provider.json" ]
}

@test "edit: rejects invalid profile name" {
  run bash "$CCUSE_BIN" edit "../bad"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid profile name"* ]]
}

@test "edit: rejects reserved custom profile name" {
  run bash "$CCUSE_BIN" edit remove
  [ "$status" -eq 1 ]
  [[ "$output" == *"reserved for a ccuse command or alias"* ]]
}
