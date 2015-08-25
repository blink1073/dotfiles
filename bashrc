export HISTCONTROL=ignoreboth
export HISTFILESIZE=10000
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
  cd "$(python -c "import imp; print(imp.find_module('$1')[1])"
)"
}

function edit {
   subl $@ || gedit $@ &
}

# aliases
alias u='cd ..;'
alias ll='ls -lGh'
alias la='ls -aG'
alias ls='ls -G'

alias nano="nano -c"
alias mpl="cd ~/workspace/matplotlib/lib/matplotlib/backends"
alias sk="cd ~/workspace/scikit-image/skimage"
alias met="cd ~/workspace/metabolite-atlas/metatlas"
alias spy="cd ~/workspace/spyder-ide"
alias ph="cd ~/workspace/phosphor"
alias pt="cd ~/workspace/phosphor-terminal"
alias ppg="cd ~/workspace/playground"
alias ws="cd ~/workspace"
alias kbase="source activate kbase; kbase-narrative"
alias pnb="cd ~/workspace/phosphor-notebook"
alias oct="cd ~/workspace/oct2py"
alias imio="cd ~/workspace/imageio"
alias jjs="cd ~/workspace/jupyter-js-services"

alias gca='git commit -a --verbose'
alias gs='git status'
alias gsv='git status --verbose'
alias gpo='git push origin'
alias gp='git push origin'
alias gu='git pull upstream'
alias gb='git branch'
alias gd='git diff'
alias ga='git add'
alias gc='git commit --verbose'
alias gr='git remote -v'

alias mocha-debug="node-debug _mocha"

eval "$(hub alias -s)"

source ~/.hub_bash_completion.sh

alias hc='hg commit --verbose'
alias hs='hg status'
alias hsv='hg status --verbose'
alias hpo='hg push origin'
alias hb='hg branches'
alias hco='hg checkout'
alias hd='hg diff'
alias hp='hg push'
alias ha='hg add'

source ~/hg_bash_completion

export SPYDER_DEBUG=True
export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"


function search() {
    grep -irn "$1" .
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


# build up PS1 with source control annotation
function source_control {
  echo `python  -c """
import re
import subprocess as sp
output=''
try:
    git_text = sp.check_output(['git', 'status', '-b',
        '-s'], stderr=sp.STDOUT).decode('utf-8', 'replace')
except (sp.CalledProcessError, OSError):
    pass
else:
    match = re.match('## (.*)', git_text)
    if match:
        match = match.groups()[0]
        if '...' in match:
            match, _, _ = match.partition('...')
        output = '(%s) %s' % (match, len(git_text.splitlines()) - 1)
print(output)"""`
}


# build up PS1 with source control annotation
function source_control {
  echo `python  -c """
import re
import subprocess as sp
output=''
try:
    git_text = sp.check_output(['git', 'status', '-b',
        '-s'], stderr=sp.STDOUT).decode('utf-8', 'replace')
except (sp.CalledProcessError, OSError):
    pass
else:
    match = re.match('## (.*)', git_text)
    if match:
        match = match.groups()[0]
        if '...' in match:
            match, _, _ = match.partition('...')
        output = '(%s) %s' % (match, len(git_text.splitlines()) - 1)
print(output)"""`
}

RED='\[\033[0;31m\]'
GREEN='\[\033[00;32m\]'
YELLOW='\[\033[00;33m\]'
BLUE='\[\033[00;34m\]'
NO_COLOR='\[\033[0m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' $(source_control)\n'$NO_COLOR'$ '
export PROMPT_COMMAND='echo'

# added by travis gem
[ -f /Users/ssilvester/.travis/travis.sh ] && source /Users/ssilvester/.travis/travis.sh
