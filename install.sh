#!/usr/bin/env bash
set -ex

# Every path below is relative to the repo root.
cd "$(dirname "$0")"

for cmd in jq git; do
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

# IPython
python3 -m venv /tmp/ipython-venv
/tmp/ipython-venv/bin/pip install ipython
/tmp/ipython-venv/bin/ipython profile create default
cp ipython_startup.py ~/.ipython/profile_default/startup/

# VSCode
vscode="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode"
cp vscode_settings.json "$vscode/settings.json"
cp vscode_keybindings.json "$vscode/keybindings.json"

# Claude
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/skills
cp claude/instructions.md ~/.claude/CLAUDE.md
if [ -f ~/.claude/settings.json ]; then
  existing_non_bash_allow=$(jq '[.permissions.allow[]? | select(startswith("Bash") | not)]' ~/.claude/settings.json)
  jq --argjson existing "$existing_non_bash_allow" \
    '.permissions.allow += $existing | .permissions.allow |= unique' \
    claude/settings.json > /tmp/claude_settings_merged.json
  mv /tmp/claude_settings_merged.json ~/.claude/settings.json
else
  cp claude/settings.json ~/.claude/settings.json
fi
cp claude/hooks/* ~/.claude/hooks/
cp -r claude/skills/* ~/.claude/skills/
