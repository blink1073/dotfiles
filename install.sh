set -x
cp bash_profile ~/.bash_profile
cp bashrc ~/.bashrc
cp gitignore ~/.gitignore
cp gitconfig ~/.gitconfig
cp inputrc ~/.inputrc
cp pdbrc ~/.pdbrc
cp pypirc ~/.pypirc
mkdir -p ~/.config/matplotlib
cp matplotlibrc ~/.config/matplotlib

mkdir -p $HOME/workspace/jupyter

code="$HOME/AppData/Roaming/Code/User"
cp keybindings.json $code
cp vscode_settings.json $code/settings.json

source ~/.bashrc
conda install -y -c conda-forge jupyter nodejs matplotlib pytest twine
ipython profile create
cp ipython_startup.py ~/.ipython/profile_default/startup/
