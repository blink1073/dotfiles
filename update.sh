
cp ~/.bashrc bashrc
cp ~/.gitignore gitignore
cp ~/.gitconfig gitconfig
cp ~/.inputrc inputrc
cp ~/.pythonrc pythonrc
cp ~/.pythonrc.py pythonrc.py
cp ~/.config/matplotlib/matplotlibrc .
cp ~/.zshrc zshrc
cp ~/.zprofile zprofile
cp ~/.ipython/profile_default/startup/ipython_startup.py .

sublime="$HOME/Library/Application\ Support/Sublime\ Text\ 3/Packages/User"
eval cp "$sublime/*.sublime-settings" .
eval cp "$sublime/*.sublime-keymap" .
