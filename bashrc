export HISTCONTROL=ignoreboth
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
  cd "$(python -c "import site; \
    print site.getsitepackages()[-1]"
)"
}

# Change to the directory for a given python module
function cdpy {
  cd "$(python -c "import imp; print(imp.find_module('$1')[1])"
)"
}

function edit {
   subl $@ || gedit $@ &
}

# aliases
alias u='cd ..;'
alias ll='ls -l'
alias la='ls -a'
alias xclip="xclip -selection c"

alias search="grep -rinI"
alias nano="nano -c"

alias gca='git commit -a --verbose'
alias gs='git status --verbose'
alias gpo='git push origin'

source ~/.git-completion.sh
source ~/hg_bash_completion

__git_complete gco _git_checkout
__git_complete gd _git_diff
__git_complete gp _git_push

export SPYDER_DEBUG=True
export PATH="/home/silvester/anaconda/bin:$PATH"

# build up PS1 with source control annotation
function hg_dirty() {
    expr $(hg status 2> /dev/null | egrep "^(M| ?)" | wc -l)
}

function hg_bookmark() {
   expr 2> /dev/null $(hg bookmark 2> /dev/null | awk '$1 == "*" {print "", $2}')
}

hg_branch() {
    hg branch 2> /dev/null | awk -v b=$(hg_bookmark) -v d=$(hg_dirty) '{print $1 " " b " " d}'
}

function git_dirty {
  # Get number of total uncommited files
  expr $(git status --porcelain 2>/dev/null| egrep "^(M| M|?| ?)" | wc -l)
}

git_branch() {
   git branch --no-color 2> /dev/null | awk -v d=$(git_dirty) '$1 == "*" {print $2 " " d}'
}

source_control() {
    echo "$(git_branch)$(hg_branch)"
}


RED='\[\033[1;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
NO_COLOR='\[\033[0m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' $(source_control)\n'$NO_COLOR'$ '
