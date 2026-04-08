set -ex

cp ~/.bashrc bashrc
cp ~/.gitignore gitignore
cp ~/.gitconfig gitconfig
cp ~/.zshrc zshrc
cp ~/.zprofile zprofile
cp ~/.ipython/profile_default/startup/ipython_startup.py .

vscode="$HOME/Library/Application Support/Code/User"
cp "$vscode/settings.json" vscode_settings.json
cp "$vscode/keybindings.json" vscode_keybindings.json

cp ~/.claude/CLAUDE.md claude/CLAUDE.md
cp ~/.claude/settings.json claude/settings.json
cp ~/.claude/hooks/* claude/hooks/
