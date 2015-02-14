cd ~/workspace/dotfiles

cp bashrc ~/.bashrc
cp hub_bash_completion.sh ~/.hub_bash_completion.sh
cp gitignore ~/.gitignore
cp gitconfig ~/.gitconfig
cp hub_bash_completion.sh ~/.hub_bash_completion.sh
cp hgrc ~/.hgrc
cp inputrc ~/.inputrc
cp pythonrc ~/.pythonrc
cp pythonrc.py ~/.pythonrc.py
mkdir ~/.config
mkdir ~/.config/matplotlib
cp matplotlibrc ~/.config/matplotlib
ipython profile create
cp ipython_startup.py ~/.ipython/profile_default/startup/

sublime=~/.config/sublime-text-3/Packages/User
cp Python.sublime-settings $sublime
cp Preferences.sublime-settings $sublime
cp "Default (Linux).sublime-keymap" $sublime
cp debug.sublime-snippet $sublime
cp Anaconda.sublime-settings $sublime
