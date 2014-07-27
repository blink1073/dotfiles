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
  pwd
}

# Change to the directory for a given python module
function cdpy {
  cd "$(python -c "import imp; print(imp.find_module('$1')[1])"
)"
  pwd
}

# aliases
alias u='cd ..;'
alias gd='git diff'
alias gpo='git push origin'
alias gca='git commit -a'
alias gs='git status'

export SPYDER_DEBUG=True

export PATH="/home/silvester/anaconda/bin:$PATH"

# Parse git branch state and display at prompt
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1 | awk '{print $1}') != "nothing" ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}
hg_ps1() {
    hg prompt "{{branch}}{ at {bookmark}}{status}" 2> /dev/null
}

source ~/hg_bash_completion

RED='\[\033[1;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
NO_COLOR='\[\033[0m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' $(hg_ps1)$(parse_git_branch)\n'$NO_COLOR'$ '