#!/usr/bin/env bash
set -ex

# Every path below is relative to the repo root.
cd "$(dirname "$0")"

command -v git >/dev/null 2>&1 || { echo "error: 'git' is required but not found on PATH" >&2; exit 1; }

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

# Workspace prune schedule (runs hourly, does its work at most once a day).
# macOS uses a LaunchAgent: cron there is deprecated and needs Full Disk Access,
# which makes a plain `crontab -` fail (with an admin-task prompt) on modern Macs.
bin="$HOME/.local/bin"
mkdir -p "$bin"

# BSD cp exits 1 when src and dst are the same file (e.g. when a dotfiles
# manager has symlinked the repo script into place), which aborts the whole
# script under set -e. Skip the copy in that case.
install_file() { # src dst
  [ "$1" -ef "$2" ] || cp "$1" "$2"
  chmod +x "$2"
}
install_file cron/workspace-prune "$bin/workspace-prune"

# Best-effort migration: drop any workspace-prune entry left in cron. Reads the
# crontab first so machines that never had one are left untouched (no write,
# hence no admin-task prompt).
remove_workspace_prune_cron() {
  command -v crontab >/dev/null 2>&1 || return 0
  local existing remaining
  existing="$(crontab -l 2>/dev/null || true)"
  printf '%s\n' "$existing" | grep -q 'workspace-prune' || return 0
  remaining="$(printf '%s\n' "$existing" | grep -Fv 'workspace-prune' || true)"
  if [ -n "$remaining" ]; then
    printf '%s\n' "$remaining" | crontab -
  else
    crontab -r 2>/dev/null || true
  fi
  echo "removed workspace-prune entry from crontab"
}

label="com.podbox.workspace-prune"
if [ "$(uname -s)" = Darwin ]; then
  agents_dir="$HOME/Library/LaunchAgents"
  plist="$agents_dir/$label.plist"
  mkdir -p "$agents_dir" "$HOME/Library/Logs"
  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$bin/workspace-prune</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Minute</key>
    <integer>15</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/workspace-prune.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/workspace-prune.log</string>
</dict>
</plist>
EOF
  # Reload so re-running install.sh picks up changes; ignore "not loaded".
  launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null \
    || launchctl unload "$plist" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist" 2>/dev/null \
    || launchctl load -w "$plist"
  remove_workspace_prune_cron
elif command -v crontab >/dev/null 2>&1; then
  # Replace any previous entry so re-running install.sh stays idempotent.
  # `|| true` keeps `set -e` from aborting the group when there is no crontab
  # yet (grep exits 1 on empty input), which would skip adding the entry.
  cron_line="15 * * * * $bin/workspace-prune"
  {
    crontab -l 2>/dev/null | grep -Fv 'workspace-prune' || true
    echo "$cron_line"
  } | crontab -
fi
