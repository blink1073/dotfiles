set -ex

# Shell
cp ~/.bashrc bashrc
cp ~/.zshrc zshrc
cp ~/.zprofile zprofile

# Git
cp ~/.gitignore gitignore
cp ~/.gitconfig gitconfig
git config -f gitconfig --unset user.email
git config -f gitconfig --unset user.signingkey

# IPython
cp ~/.ipython/profile_default/startup/ipython_startup.py .

# VSCode
vscode="$HOME/Library/Application Support/Code/User"
cp "$vscode/settings.json" vscode_settings.json
cp "$vscode/keybindings.json" vscode_keybindings.json

# Claude
cp ~/.claude/CLAUDE.md claude/CLAUDE.md
cp ~/.claude/settings.json claude/settings.json
cp ~/.claude/hooks/* claude/hooks/
