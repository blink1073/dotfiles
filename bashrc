
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=100000
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# Shortcuts for common operations
alias build_inplace='python setup.py build_ext --inplace'
alias build_clean='find . -name *.so -or -name *.pyc | xargs rm; rm -rf build'
alias pstats='python -m pstats'


# Change to Python's site-packages directory.
function cdsite {
  cd "$(python -c "import site; print(site.getsitepackages()[0])")"
}

# Change to the directory for a given python module
function cdpy {
  cd "$(python -c "import imp, os; print(imp.find_module('$1')[1])")" 2>/dev/null || cd "$(python -c "import imp, os; print(os.path.dirname(imp.find_module('$1')[1]))")"
}

function edit {
   subl $@ || gedit $@ &
}

function npm-patch {
    git checkout master && git pull
    npm update
    npm run build
    npm version patch
    git push origin master && git push origin --tags
    npm publish
}

function npm-minor {
    git checkout master && git pull
    npm update
    npm run build
    npm version minor
    git push origin master && git push origin --tags
    npm publish
}

function npm-preminor {
    git checkout master && git pull
    npm update
    npm run build
    npm version preminor
    git push origin master && git push origin --tags
    npm publish --tag next
}

function npm-backport {
    # Check out the backport branch itself and git pull origin branch
    if [ "$#" -ne 1 ]; then
        echo "Specify the backport branch"
    fi
    git checkout $1
    git pull origin $1
    npm update
    npm run build
    npm version patch
    git push origin $1 && git push origin --tags
    npm publish
}

function py-tag {
    git pull
    local version=`python setup.py --version 2>/dev/null`
    git commit -a -m "Release $version"
    git tag v$version; true;
    git push --all
    git push --tags
}

function py-release {
    rm -rf dist build
    python setup.py sdist
    if [ ! -f ./setup.cfg ]; then
        python setup.py bdist_wheel --universal;
    else
        python setup.py bdist_wheel;
    fi
    py-tag
    python setup.py register
    twine upload dist/*
}

function conda-release {
    shasum -a 256 dist/*.tar.gz | awk '{printf $1;}' | pbcopy
    local name=`python setup.py --name 2>/dev/null`
    local version=`python setup.py --version 2>/dev/null`
    open https://github.com/conda-forge/$name-feedstock
    cd ~/workspace/$name-feedstock
    git fetch upstream master
    git checkout -b "release-$version" upstream/master
    subl recipe/meta.yaml
}

function lab-test {
    conda create -n lab-test python || true
    source activate lab-test
    pip uninstall -y jupyterlab
    pip uninstall -y jupyterlab_launcher
    rm -rf ~/anaconda/envs/lab-test/share/jupyter/lab
    rm -rf ~/Library/Caches/pip/
    cd ~/workspace
}


function gra {
    if [ "$#" -ne 1 ]; then
        echo "Specify user"
    fi
    local name=$1
    if [ "$#" -e 2 ]; then
        name=$2
    fi
    local origin=$(git remote get-url origin)
    local repo=$(basename $origin .git)
    git remote add $name https://github.com/$1/$repo
    git fetch $name
}


# aliases
alias u='cd ..;'
alias ll='ls -lGh'
alias la='ls -aG'
alias ls='ls -G'

alias ..='cd ..'
alias ...='cd ../..'

alias nano="nano -c"
alias mpl="cd ~/workspace/matplotlib/lib/matplotlib"
alias sk="cd ~/workspace/scikit-image/skimage"
alias ph="cd ~/workspace/phosphor"
alias ws="cd ~/workspace"
alias jp='cd ~/workspace/jupyter'
alias jpa='cd ~/workspace/jupyter/admin/jupyterlab'
alias lab='cd ~/workspace/jupyter/lab';

alias gca='git commit -a --verbose'
alias gs='git status'
alias gsv='git status --verbose'
alias gpu='git pull upstream master && git push upstream master'
alias gpo='git push origin'
alias gpa='git push origin --all'
alias gp='git push origin'
alias gu='git pull upstream'
alias gb='git branch'
alias gd='git diff'
alias ga='git add'
alias gc='git commit --verbose'
alias gr='git remote -v'

alias jlab="jupyter lab --NotebookApp.base_url=/foo/"
alias octave='octave-cli'
alias subl=code

export PED_EDITOR=subl
export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.config/yarn/global:$PATH"
export PATH="/usr/texbin:$PATH"
export PATH="$PATH:/Applications/Octave.app/Contents/Resources/usr/bin/"

function search() {
    grep -irn --exclude-dir=node_modules --exclude-dir=.git --exclude="*.js.map" "$1" .
}

function searchsensitive() {
    grep -rn --exclude-dir=node_modules --exclude-dir=.git --exclude="*.js.map" "$1" .
}

function gn() {
    git fetch upstream master
    git checkout -b "$1" upstream/master
}

function grb() {
    git fetch upstream master
    git rebase -i upstream/master
}

function gpr() {
    git checkout master
    git branch -D pr/$1 2>/dev/null
    git fetch upstream pull/$1/head:pr/$1
    git checkout pr/$1
}

function gprune() {
    git co master
    git fetch origin
    git fetch upstream
    # remove PR branches
    git branch | grep pr\/ | xargs -n 1 git branch -D
    # remove local merged branches
    git branch --merged upstream/master | sed 's/\*/ /' | grep -v master | xargs -n 1 git branch -d
    # remove remote merged branches
    git branch -r --merged upstream/master | grep 'origin/' | grep -v master | grep -v gh-pages | sed 's/origin\///' | xargs -n 1 git push --delete origin
}

function gdel() {
    git co master
    for var in "$@"
    do
        git branch -D "$var"
        git push origin ":$var"
    done
}

function gclone() {
    git clone https://github.com/blink1073/$2
    cd $2
    git remote add upstream https://github.com/$1/$2
    git pull upstream master
    git push origin -f
}


function gclonea() {
    git clone https://github.com/$1/$2
    cd $2
    git remote add upstream https://github.com/$1/$2
    git pull upstream master
    git push origin -f
}


# build up PS1 with source control annotation
function source_control {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"
  local on_rebase="interactive rebase in progress;*"
  local lines="$(git status -s 2> /dev/null | wc -l | tr -d '[:space:]')"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "($branch) $lines"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "($commit) $lines"
  elif [[ $git_status =~ $on_rebase ]]; then
    echo "(* rebasing *)"
  elif [[ $git_status ]]; then
    echo "(*unknown state*)"
  fi
}

RED='\[\033[0;31m\]'
GREEN='\[\033[00;32m\]'
YELLOW='\[\033[00;33m\]'
BLUE='\[\033[00;34m\]'
NO_COLOR='\[\033[0m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' `source_control`\n'$NO_COLOR'$ '
export PROMPT_COMMAND='echo'

if [ -n "$CONDA_DEFAULT_ENV" ]; then
    source activate $CONDA_DEFAULT_ENV
fi

source $HOME/Miniconda3/Scripts/activate base
