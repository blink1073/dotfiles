set -ex
mkdir -p $HOME/workspace/jupyter

cp bash_profile ~/.bash_profile
cp bashrc ~/.bashrc
cp zshrc ~/.zshrc
cp zprofile ~/.zprofile
cp gitignore ~/.gitignore
cp gitconfig ~/.gitconfig
cp pdbrc ~/.pdbrc
cp pypirc ~/.pypirc
cp condarc ~/.condarc
cp jupyterhub_config.py ~/workspace

vscode="$HOME/Library/Application Support/Code/User"
cp vscode_settings.json "$vscode/settings.json"
cp vscode_keybindings.json "$vscode/keybindings.json"

mkdir -p ~/.claude/hooks
cp claude/CLAUDE.md ~/.claude/CLAUDE.md
cp claude/settings.json ~/.claude/settings.json
cp claude/hooks/* ~/.claude/hooks/


python3 -m venv /tmp/ipython-venv
/tmp/ipython-venv/bin/pip install ipython
/tmp/ipython-venv/bin/ipython profile create default
cp ipython_startup.py ~/.ipython/profile_default/startup/
