#!/usr/bin/env bash
set -ex

# Every path below is relative to the repo root.
cd "$(dirname "$0")"

for cmd in jq git rsync; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: '$cmd' is required but not found on PATH" >&2; exit 1; }
done

# Shell
cp ~/.bashrc bashrc
cp ~/.zshrc zshrc
cp ~/.zprofile zprofile

# Git
cp ~/.gitignore gitignore
cp ~/.gitconfig gitconfig
git config -f gitconfig --unset user.email || true
git config -f gitconfig --unset user.signingkey || true

# VSCode
vscode="$HOME/Library/Application Support/Code/User"
cp "$vscode/settings.json" vscode_settings.json
cp "$vscode/keybindings.json" vscode_keybindings.json

# Claude
cp ~/.claude/CLAUDE.md claude/instructions.md
# Only the Bash allow-list is synced into the committed settings.json — never
# the whole file, which can carry env vars, API keys, or model routing that
# don't belong in a public repo. `unique` sorts as well as dedupes, matching
# install.sh, so repeated syncs are a no-op.
allow="$(jq -c '.permissions.allow | map(select(startswith("Bash"))) | unique' ~/.claude/settings.json)"
jq --argjson allow "$allow" '.permissions.allow = $allow' claude/settings.json > claude/settings.json.tmp
mv claude/settings.json.tmp claude/settings.json
cp ~/.claude/hooks/* claude/hooks/
mkdir -p claude/skills
# Mirror, so a skill deleted from ~/.claude is deleted here too.
# Excludes evg/evergreen skills: they're work-machine-only, not for the public repo.
rsync -a --delete --exclude='*evg*' --exclude='*evergreen*' ~/.claude/skills/ claude/skills/
