set -x
cp bashrc ~/.bashrc
cp gitignore ~/.gitignore
cp gitconfig ~/.gitconfig
cp inputrc ~/.inputrc
cp pythonrc ~/.pythonrc
cp pythonrc.py ~/.pythonrc.py
cp pdbrc ~/.pdbrc
cp pypirc ~/.pypirc
mkdir -p ~/.config/matplotlib
cp matplotlibrc ~/.config/matplotlib

code="$HOME/AppData/Roaming/Code/User"
cp keybindings.json $code
cp vscode_settings.json $code/settings.json

conda install -y -c conda-forge  jupyter nodejs
ipython profile create
cp ipython_startup.py ~/.ipython/profile_default/startup/
