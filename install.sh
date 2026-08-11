set -ex

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
cp claude/settings.json ~/.claude/settings.json
cp claude/hooks/* ~/.claude/hooks/
cp -r claude/skills/* ~/.claude/skills/
