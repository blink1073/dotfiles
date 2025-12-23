
export TWINE_USERNAME=__token__

# Set the limit of open files to be a high number.
ulimit -n 10240

# Use the github token if available
if [ -f ~/.gh_token ]; then
   source ~/.gh_token
fi


function prep-release {
    tmp-env --checkout $1 build twine
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
    pip install pipx
    local version=$(pipx run hatch version || pipx run tbump current-version)
    git commit -a -m "Release $version"
    git tag -a $version -m "$version"; true;
    git push --all
    git push --tags
}

function py-release {
    rm -rf dist build
    pip install pipx
    pipx run build .
    py-tag
    pipx run twine check dist/* && pipx run twine upload dist/*
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

alias run-in-docker="docker run -it -v $(pwd):/usr/src/project jupyter/minimal-notebook:latest /bin/bash"
alias el="ls $HOME/workspace/.venvs"
alias pymongo="workon mongo-python-driver"
alias mongoarrow="workon mongo-arrow"
alias motor="workon motor"
export DRIVERS_TOOLS="$HOME/workspace/drivers-evergreen-tools"
alias run-server="$HOME/workspace/drivers-evergreen-tools/.evergreen/orchestration/drivers-orchestration run"

alias python3.8 'uv run --python=3.8 python3'
alias python3.9 'uv run --python=3.9 python3'
alias python3.10 'uv run --python=3.10 python3'
alias python3.11 'uv run --python=3.11 python3'
alias python3.12 'uv run --python=3.12 python3'
alias python3.13 'uv run --python=3.13 python3'
alias python3 python3.12

export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"

function search() {
    git --no-pager grep -i -n $1 -- ':!uv.lock'
}

function searchsensitive() {
    git --no-pager grep -n $1 -- ':!uv.lock'
}


function ea() {
    source $HOME/.venvs/$1/bin/activate
}


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
    branch=${1:-$(get_default_branch)}
    git fetch upstream ${branch}
    git rebase -i upstream/${branch}
}

function gpr() {
    git checkout $(get_default_branch)
    git branch -D pr/$1 2>/dev/null
    git fetch upstream pull/$1/head:pr/$1
    git checkout pr/$1
    bell
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


# Completion for just
_just() {
    local -a recipes
    # Only provide custom completions if the command is exactly 'just'  
    if [[ $words[1] == just && $CURRENT -eq 2 ]]; then 
        if [[ -f justfile ]]; then
            recipes=(${(z)$(just --summary 2>/dev/null)})
            _describe 'recipe' recipes
        fi
    else  
        # Use default completion (fall back to _default or another suitable completer)  
        _default  
    fi  
}
compdef _just just

# ========================================
# # tmp-env command for throwaway venvs
# ========================================

# Usage: tmp-env [-p 3.12] [requests]
tmp-env() {
  emulate -L zsh
  set -u

  # Parse: optional -p/--python VERSION ; then optional packages
  # optional --checkout repo ; a repo to check out
  local py=""
  local checkout=""
  local -a pkgs=()
  while (( $# )); do
    case "$1" in
      -p|--python) py=$2; shift 2 ;;
      --checkout) checkout=$2; shift 2 ;;
      --) shift; break ;;  # stop option parsing
      *) pkgs+=("$1"); shift ;;
    esac
  done

  command -v uv >/dev/null || { print -ru2 "uv not found"; return 127; }

  # Create a unique temp dir
  local dir
  dir=$(mktemp -d -t tmp-env.XXXXXXXX) || { print -ru2 "mktemp failed"; return 1; }

  # Create the venv with uv
  local -a venv_args=(--seed)
  [[ -n $py ]] && venv_args+=(--python "$py")
  venv_args+=("$dir")
  uv venv --quiet "${venv_args[@]}" || { rmdir "$dir"; return 1; }

  # Pre-install packages *into this venv specifically*
  if (( ${#pkgs[@]} )); then
    uv pip install --python "$dir/bin/python" "${pkgs[@]}"
  fi

  # Minimal ZDOTDIR so the child shell auto-activates & aliases deactivate->exit
  local zd="$dir/_zdotdir"
  mkdir -p "$zd" || { rm -rf "$dir"; return 1; }
  cat > "$zd/.zshrc" <<'EOS'
[[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"  # Keep user's config
cd "$TMPVENV_DIR"
source "./bin/activate"  # Activate the temp venv
[[ -n $CHECKOUT_REPO ]] && git clone gh:$CHECKOUT_REPO ./checkout && cd ./checkout
alias deactivate='exit'  # 'deactivate' ends the shell so cleanup runs
print -P "Activated temp venv at:%f %F{cyan}$TMPVENV_DIR%f"
print -P "Type %F{green}deactivate%f or %F{green}exit%f to deactivate and delete it."
EOS

  # Launch child interactive zsh that reads our tiny .zshrc
  TMPVENV_DIR="$dir" ZDOTDIR="$zd" CHECKOUT_REPO="$checkout" zsh -i
  local ec=$?

  # Cleanup after child shell closes
  [[ -d $dir ]] && rm -rf -- "$dir"
  return $ec
}


workon() {
    local name=$1
    if [ ! -d $HOME/workspace/$name ];
    then
        echo "ERROR: \"$HOME/workspace/$name\" not found!"
        return 1
    fi
    cd ~/workspace/$name
    if [ ! -f .envrc ]; then
        echo "test -d .venv || uv venv --seed --python 3.9" > .envrc
        echo "source .venv/bin/activate" >> .envrc
        direnv allow .
    fi
}
alias wo=workon

edit() {
    local curpath=$(pwd)
    while [ ! -d "$curpath/.git" ]
    do
        curpath=$(dirname ${curpath})
    done
    code $curpath
}


alias ubuntu="docker run -it -e GRANT_SUDO=yes --user root jupyter/minimal-notebook bash"

export PROMPT_COMMAND='echo'
