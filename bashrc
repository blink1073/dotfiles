
export PYTEST_ADDOPTS='--pdbcls=IPython.terminal.debugger:Pdb'

# Set the limit of open files to be a high number.
ulimit -n 10240

# Use the github token if available
if [ -f ~/.gh_token ]; then
   source ~/.gh_token
fi


function prep-release {
    repo=$1
    target="/tmp/$1-$(openssl rand -hex 12)"
    mkdir -p $target
    git clone git@github.com:$1.git $target
    tmp-conda
    cd $target
}


function clean-jlab {
    git clean -dfx
    pip install -v -U -e .
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
    pip install -U tbump hatchling
    local version=$(tbump current-version || hatchling version)
    git commit -a -m "Release $version"
    git tag -a $version -m "$version"; true;
    git push --all
    git push --tags
}

function py-release {
    rm -rf dist build
    pip install twine
    if [ -f ./pyproject.toml ]; then
        pip install build
        python -m build .
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
alias dot='cd ~/workspace/dotfiles'
alias hub='jupyterhub'
alias octave='octave-cli'
alias bel='tput bel'

alias gs='git status'
alias gsv='git status --verbose'
alias gpo='git push origin'
alias gu='git pull upstream'
alias gb="git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads | tail -r"
alias gd='git diff'
alias ga='git add'
alias gc='git commit --verbose'
alias gr='git remote -v'
alias gprb='git pull --rebase'
alias gnvm="git reset --soft HEAD~1"

alias cl="conda env list"
alias ca="conda activate"
alias cda="conda deactivate"
alias docker="podman"
alias code="subl -a"
alias pymongo="workon mongo-python-driver"
alias mongoarrow="workon mongo-arrow"
alias motor="workon motor"
alias start420="ca base && cd ~/workspace/clusters/420_psa_tls && ./init"
alias start440="ca base && cd ~/workspace/clusters/440_psa_tls && ./init"
alias start500="ca base && cd ~/workspace/clusters/500_psa_tls && ./init"
alias start520="ca base && cd ~/workspace/clusters/520_psa_tls && ./init"
alias start600="ca base && cd ~/workspace/clusters/600_alpha_psa_lts && ./init"

export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"


alias search="git --no-pager grep -i -n"
alias searchsensitive="git --no-pager grep -n"


function bell() {
    tput bel
    say "I finished that long thing I did" 2>/dev/null
}



unalias gca 2>/dev/null
function gca() {
    # Allow for pre-commit auto-fixes.
    git commit -a -m "${@: -1}" || git commit -a -m "${@: -1}"
}


function gpa() {
    # get to the last arg in case we accidently include -m
    gca $@ && git push origin
}


function get_default_branch() {
    git remote show upstream | grep 'HEAD branch' | cut -d' ' -f5
}


function gn() {
    branch=${2:-$(get_default_branch)}
    gupdate ${branch}
    git checkout -b "$1" upstream/${branch}
    bell
}


unalias grb 2>/dev/null
function grb() {
    default_branch=$(get_default_branch)
    git fetch upstream ${default_branch}
    git rebase -i upstream/${default_branch}
}

function gpr() {
    git checkout $(get_default_branch)
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
    default_branch=$(get_default_branch)
    git co ${default_branch}
    git fetch origin
    git fetch upstream
    # remove PR branches
    git branch | grep pr\/ | xargs -n 1 git branch -D
    # remove local merged branches
    git branch --merged upstream/${default_branch} | sed 's/\*/ /' | grep -v ${default_branch} | xargs -n 1 git branch -d
    # remove remote merged branches
    git branch -r --merged upstream/${default_branch} | grep 'origin/' | grep -v ${default_branch} | grep -v gh-pages | sed 's/origin\///' | xargs -n 1 git push --delete origin --no-verify
    bell
}

function gdel() {
    default_branch=$(get_default_branch)
    git co ${default_branch}
    for var in "$@"
    do
        git branch -D "$var"
        git push origin ":$var"
    done
    bell
}

function gdeltag() {
    git tag -d $1
    git push --delete origin $1
}

function gclone() {
    local user=$(git config  github.user)
    git clone git@github.com:$user/$2 || return 1
    cd $2
    git remote add upstream git@github.com:$1/$2.git
    default_branch=$(get_default_branch)
    git pull upstream ${default_branch} -X theirs
    bell
}


function gclonea() {
    git clone git@github.com:$1/$2  || return 1
    cd $2
    git remote add upstream git@github.com:$1/$2.git
    default_branch=$(get_default_branch)
    git pull upstream ${default_branch}
    bell
}


function gupdate() {
    local current=$(git branch --show-current)
    local default=$(get_default_branch)
    local target=${1:-$default}
    local dirty="false"
    if [[ $(git diff --stat) != '' ]]; then
        dirty="true"
        git stash
    fi
    git fetch origin $target
    git checkout $target
    git pull upstream $target -X theirs
    git push origin $target --no-verify -f
    git checkout $current
    if [[ ${dirty} == "true" ]]; then
        git stash apply
    fi
}


unalias gra 2>/dev/null
function gra {
    if [[ $# -ne 1 ]]; then
        echo "Specify user"
    fi
    local name=$1
    if [[ $# -eq 2 ]]; then
        name=$2
    fi
    local upstream=$(git remote get-url upstream)
    local repo=$(basename $upstream .git)
    git remote add $name git@github.com:$1/$repo
    git fetch $name
    bell
}


tmp-conda() {
    local name="$(openssl rand -hex 12)"
    conda create -y -p /tmp/conda_envs/${name} ipykernel python=3.10 ipdb
    conda activate /tmp/conda_envs/${name}
    bell
}


workon() {
    local name=$1
    local env=${name}_env
    if [ ! -d ~/workspace/$name ];
    then
        echo "ERROR: \"$HOME/workspace/$name\" not found!"
        return 1
    fi
    cd ~/workspace/$name
    local check_env=$(conda env list | grep $env)
    if [ -z "${check_env}" ]; then
        conda create -y -n $env python=3.10 jupyterlab ipdb nodejs
        conda activate $env
        pip install -e ".[test]"; true
    else
        conda activate $env
    fi
    if [ ! -f "pyrightconfig.json" ]; then
        echo "{\"venvPath\":\"$HOME/miniconda/envs\",\"venv\": \"$env\"}" > pyrightconfig.json
    fi
    if [ ! -f "$name.sublime-project" ]; then
        echo "{\"folders\":[{\"path\": \".\"}]}" >> "$name.sublime-project"
    fi
}
alias wo=workon

edit() {
    local curpath=$(pwd)
    while [ ! -d "$curpath/.git" ]
    do
        curpath=$(dirname ${curpath})
    done
    local name=$(basename $curpath)
    if [ -f "${curpath}/${name}.sublime-project" ];
    then
        subl "${curpath}/${name}.sublime-project"
    else
        echo "No sublime project found in ${curpath}"
    fi
}


tmp-conda-full() {
    local name="$(openssl rand -hex 12)"
    conda create -y -p /tmp/conda_envs/${name} notebook python=3.8 ipdb nodejs
    conda activate /tmp/conda_envs/${name}
    bell
}


alias ubuntu="docker run -it -e GRANT_SUDO=yes --user root jupyter/minimal-notebook bash"

export PROMPT_COMMAND='echo'
