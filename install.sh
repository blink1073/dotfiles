set -x
cp bash_profile ~/.bash_profile
cp bashrc ~/.bashrc
cp gitignore ~/.gitignore
cp gitconfig ~/.gitconfig
cp inputrc ~/.inputrc
cp pdbrc ~/.pdbrc
cp pypirc ~/.pypirc

mkdir -p $HOME/workspace/jupyter

unameOut="$(uname -s)"
if [[ -x  "$(command -v conda)" ]]; then
   if [[ "${unameOut}" == MINGW* ]];then
        wget https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.sh -O /tmp/miniconda.sh
   else
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
   fi
   bash /tmp/miniconda.sh -b -p $HOME/miniconda
fi

if [[ "${unameOut}" == MINGW* ]]; then
  code="$HOME/AppData/Roaming/Code/User"
  cp keybindings.json $code
  cp vscode_settings.json $code/settings.json
fi

source ~/.bashrc
conda install -y -c conda-forge jupyter nodejs scipy matplotlib pytest twine
ipython profile create
cp ipython_startup.py ~/.ipython/profile_default/startup/
