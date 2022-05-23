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

sublime="$HOME/Library/Application\ Support/Sublime\ Text/Packages/User"
eval cp "*.sublime-settings" $sublime
eval cp "*.sublime-keymap" $sublime

mkdir -p ~/.ipython/profile_default/startup
cp ipython_startup.py ~/.ipython/profile_default/startup/
