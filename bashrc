
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=100000
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# Enable bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Use the github token if available
if [ -f ~/.gh_token ]; then
   source ~/.gh_token
fi


function clean-jlab {
    git clean -dfx
    pip install -v -e .
    jlpm run build
    bell
}

# Change to Python's site-packages directory.
function cdsite {
  cd "$(python -c "import site; print(site.getsitepackages()[0])")"
}

# Change to the directory for a given python module
function cdpy {
  cd "$(python -c "from importlib.util import find_spec; import os; print(find_spec('$1').submodule_search_locations[0])")" 2>/dev/null || cd "$(python -c "import imp, os; print(os.path.dirname(imp.find_module('$1')[1]))")"
}

function edit {
   code $@ || gedit $@ &
}

function py-tag {
    git pull
    local version=`python setup.py --version 2>/dev/null`
    git commit -a -m "Release $version"
    git tag $version; true;
    git push --all
    git push --tags
}

function py-release {
    rm -rf dist build
    pip install twine
    if [ -f ./pyproject.toml ]; then
        pip install pep517
        python -m pep517.build .
    else
        python setup.py sdist
        if [ ! -f ./setup.cfg ]; then
            python setup.py bdist_wheel --universal;
        else
            python setup.py bdist_wheel;
        fi
    fi
    py-tag
    pip install twine
    twine check dist/* && twine upload dist/*
    bell
}

function conda-release {
    # Get metadata - copy sha to clipboard
    shasum -a 256 dist/*.tar.gz | awk '{printf $1;}' | pbcopy
    local name=`python setup.py --name 2>/dev/null`
    local version=`python setup.py --version 2>/dev/null`
    local branch=`git rev-parse --abbrev-ref HEAD`
    # Open the feedstock in the browser
    open https://github.com/conda-forge/$name-feedstock
    # Create a branch
    cd ~/workspace/jupyter/$name-feedstock
    git fetch upstream $branch
    git checkout -b "release-$version" upstream/$branch
    # Open the recipe for editing
    code recipe/meta.yaml
}

function gra {
    if [[ $# -ne 1 ]]; then
        echo "Specify user"
    fi
    local name=$1
    if [[ $# -eq 2 ]]; then
        name=$2
    fi
    local origin=$(git remote get-url origin)
    local repo=$(basename $origin .git)
    git remote add $name git@github.com:$1/$repo
    git fetch $name
    bell
}

function jl1 {
    conda activate jlab-1.2.x
    cd ~/workspace/jupyter/jlab-1.2.x
}


function jl2 {
    conda activate jlab-2.x
    cd ~/workspace/jupyter/jlab-2.x
}


function jlm {
    conda activate jlab-master
    cd ~/workspace/jupyter/jlab-master
}

function jlp1 {
    conda activate jlab-pip-1.2
}

function jlp2 {
    conda activate jlab-pip-2.0
}

function jlp3 {
    conda activate jlab-pip-3.0
}


# aliases
alias u='cd ..;'
alias ll='ls -lGh'
alias la='ls -aG'
alias ls='ls -aG'

alias ..='cd ..'
alias ...='cd ../..'

alias ws="cd ~/workspace && ls -ltr"
alias jp='cd ~/workspace/jupyter && ls -ltr'
alias jpa='cd ~/workspace/jupyter/admin && ls -ltr'
alias lab='lab-master'
alias dot='cd ~/workspace/dotfiles'
alias hub='jupyterhub'
alias octave='octave-cli'
alias bel='tput bel'

alias gca='git commit -a --verbose'
alias gs='git status'
alias gsv='git status --verbose'
alias gpu='git pull upstream master && git push upstream master'
alias gpo='git push origin'
alias gpa='git push origin --all'
alias gu='git pull upstream'
alias gb="git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads | tac"
alias gd='git diff'
alias ga='git add'
alias gc='git commit --verbose'
alias gr='git remote -v'
alias gprb='git pull --rebase'

export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"


function search() {
    grep -irn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=lib --exclude-dir=__pycache__ --exclude="*.js.map"  --exclude="*.min.js" --exclude="*.html" --exclude="*.bundle.js"   "$1" .
}

function searchsensitive() {
    grep -rn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=lib --exclude-dir=__pycache__ --exclude="*.js.map" --exclude="*.html" --exclude="*.min.js" --exclude="*.bundle.js" "$1" .
}

function bell() {
    tput bel
    say "I finished that long thing I did"
}

function gn() {
    branch=${2:-master}
    git fetch upstream ${branch}
    git checkout -b "$1" upstream/${branch}
    bell
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
    bell
}

function gprelease() {
    git fetch upstream prerelease
    git checkout -b "$1" upstream/prerelease
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
    git branch -r --merged upstream/master | grep 'origin/' | grep -v master | grep -v gh-pages | sed 's/origin\///' | xargs -n 1 git push --delete origin --no-verify
    bell
}

function gdel() {
    git co master
    for var in "$@"
    do
        git branch -D "$var"
        git push origin ":$var"
    done
    bell
}

function gclone() {
    git clone git@github.com:blink1073/$2
    cd $2
    git remote add upstream git@github.com:$1/$2
    git pull upstream master
    git push origin -f
    bell
}


function gclonea() {
    git clone git@github.com:$1/$2
    cd $2
    git remote add upstream git@github.com:$1/$2
    git pull upstream master
    git push origin -f
    bell
}

tmp-conda() {
    local name="$(openssl rand -hex 12)"
    conda create -y -p /tmp/conda_envs/${name} notebook python=3.6
    conda activate /tmp/conda_envs/${name}
    bell
}


alias ubuntu="docker run -it -e GRANT_SUDO=yes --user root jupyter/minimal-notebook bash"

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
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[00;33m\]'
BLUE='\[\033[01;34m\]'
NO_COLOR='\[\033[00m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' `source_control`\n'$NO_COLOR'$ '
export PROMPT_COMMAND='echo'

