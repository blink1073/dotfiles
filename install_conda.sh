set -ex
unameOut="$(uname -s)"
if [[ "${unameOut}" == MINGW* ]];then
   curl https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe -o /tmp/miniconda.exe
   echo "\n\n** Please install to $HOME/miniconda **\n\n"
   /tmp/miniconda.exe
else
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p $HOME/miniconda
fi
