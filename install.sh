#!/usr/bin/env bash
set -ex

# Every path below is relative to the repo root.
cd "$(dirname "$0")"

for cmd in jq git npm; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: '$cmd' is required but not found on PATH" >&2; exit 1; }
done

# Workspace
mkdir -p $HOME/workspace/jupyter

# Shell
cp bash_profile ~/.bash_profile
cp bashrc ~/.bashrc
cp zshrc ~/.zshrc
cp zprofile ~/.zprofile

# Git
cp gitignore ~/.gitignore
git_email=$(git config --global user.email 2>/dev/null || true)
git_signingkey=$(git config --global user.signingkey 2>/dev/null || true)
cp gitconfig ~/.gitconfig
[ -n "$git_email" ] && git config --global user.email "$git_email"
[ -n "$git_signingkey" ] && git config --global user.signingkey "$git_signingkey"

# Python
cp pdbrc ~/.pdbrc
cp pypirc ~/.pypirc
cp condarc ~/.condarc
cp jupyterhub_config.py ~/workspace

# VSCode
vscode="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode"
cp vscode_settings.json "$vscode/settings.json"
cp vscode_keybindings.json "$vscode/keybindings.json"

# Claude
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/skills
cp agents/AGENTS.md ~/.claude/CLAUDE.md
if [ -f ~/.claude/settings.json ]; then
  # Merge the repo's Bash allow/deny lists into the existing file, keeping
  # everything else already on this machine (env vars, model routing,
  # extra non-Bash entries, etc.) untouched.
  repo_bash_allow=$(jq -c '.permissions.allow' claude/settings.json)
  existing_non_bash_allow=$(jq -c '[.permissions.allow[]? | select(startswith("Bash") | not)]' ~/.claude/settings.json)
  repo_bash_deny=$(jq -c '.permissions.deny' claude/settings.json)
  existing_non_bash_deny=$(jq -c '[.permissions.deny[]? | select(startswith("Bash") | not)]' ~/.claude/settings.json)
  jq --argjson bash_allow "$repo_bash_allow" --argjson other "$existing_non_bash_allow" \
     --argjson bash_deny "$repo_bash_deny" --argjson other_deny "$existing_non_bash_deny" \
    '.permissions.allow = ($bash_allow + $other | unique)
     | .permissions.deny = ($bash_deny + $other_deny | unique)' \
    ~/.claude/settings.json > /tmp/claude_settings_merged.json
  mv /tmp/claude_settings_merged.json ~/.claude/settings.json
else
  cp claude/settings.json ~/.claude/settings.json
fi
cp agents/hooks/* ~/.claude/hooks/
cp -r agents/skills/* ~/.claude/skills/

# OpenCode
opencode_dir="$HOME/.config/opencode"
mkdir -p "$opencode_dir/plugins"
if [ -f "$opencode_dir/opencode.jsonc" ]; then
  tmp=$(mktemp)
  jq --slurpfile repo opencode/opencode.jsonc '
    .permission.bash = ($repo[0].permission.bash + ((.permission.bash // {}) | to_entries | map(select($repo[0].permission.bash[.key] == null)) | from_entries))
  ' "$opencode_dir/opencode.jsonc" > "$tmp"
  mv "$tmp" "$opencode_dir/opencode.jsonc"
else
  cp opencode/opencode.jsonc "$opencode_dir/opencode.jsonc"
fi
# Model settings are per-machine and not tracked in the repo.
missing=()
jq -e '.model' "$opencode_dir/opencode.jsonc" >/dev/null 2>&1 || missing+=("model")
jq -e '.agent.reviewer.model' "$opencode_dir/opencode.jsonc" >/dev/null 2>&1 || missing+=("agent.reviewer.model")
if [ ${#missing[@]} -gt 0 ]; then
  {
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "WARNING: opencode model settings are missing: ${missing[*]}"
    echo "Set them in $opencode_dir/opencode.jsonc. Each machine sets its own."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  } >&2
fi
mkdir -p "$opencode_dir/agent"
cp opencode/agent/reviewer.md "$opencode_dir/agent/reviewer.md"
cp agents/AGENTS.md "$opencode_dir/AGENTS.md"
cp opencode/tui.json "$opencode_dir/tui.json"
cp opencode/package.json "$opencode_dir/package.json"
cp opencode/package-lock.json "$opencode_dir/package-lock.json"
cp -r opencode/plugins/* "$opencode_dir/plugins/"
npm ci --prefix "$opencode_dir"

# Sandbox CLI (podbox + opencode-sandbox)
sandbox_bin="$HOME/.local/bin"
mkdir -p "$sandbox_bin"
cp sandbox/podbox sandbox/opencode-sandbox "$sandbox_bin/"
chmod +x "$sandbox_bin/podbox" "$sandbox_bin/opencode-sandbox"

# Workspace prune cron (runs hourly, does its work at most once a day)
cp cron/workspace-prune "$sandbox_bin/workspace-prune"
chmod +x "$sandbox_bin/workspace-prune"
if command -v crontab >/dev/null 2>&1; then
  # Replace any previous entry so re-running install.sh stays idempotent.
  cron_line='15 * * * * $HOME/.local/bin/workspace-prune'
  (crontab -l 2>/dev/null | grep -Fv 'workspace-prune'; echo "$cron_line") | crontab -
fi
