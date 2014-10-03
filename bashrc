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

alias nano="nano -c"
alias scilab='Scilex'

function ipython {
    if [ "$#" -eq 0 ]; then
        trap '' 2;
        /c/Users/silvester/Anaconda/Scripts/ipython;
        trap 2;
    else
        /c/Users/silvester/Anaconda/Scripts/ipython $@;
    fi
}

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

source ~/.git-completion.sh

__git_complete gco _git_checkout
__git_complete gd _git_diff
__git_complete gp _git_push

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
export PATH="/home/silvester/anaconda/bin:$PATH"

function find() {
    /usr/bin/find . -name "$1"
}

function search() {
    grep -irn "$1" .
}

# build up PS1 with source control annotation
function source_control {
  echo `python  -c """
import re
import subprocess as sp
output=''
try:
    git_text = sp.check_output('git status -b -s', stderr=sp.STDOUT)
except sp.CalledProcessError:
    pass
else:
    match = re.match('## ([a-zA-Z-_0-9]*)', git_text)
    if match:
        output = '%s %s' % (match.groups()[0],
                                           len(git_text.splitlines()) - 1)
if not output:
    try:
        hg_text = sp.check_output('hg summary', stderr=sp.STDOUT)
    except sp.CalledProcessError:
        pass
    else:
        match = re.search('branch: ([a-zA-Z-_0-9]*)', hg_text)
        if 'commit: (clean)' in hg_text and match:
            print('%s 0' % match.groups()[0])
        elif match:
            lines = hg_text.splitlines()
            for line in lines:
                if line.startswith('commit:'):
                    numbers = re.findall('\d+', line)
                    dirty = sum(int(n) for n in numbers)
                    output = '%s %s' % (match.groups()[0], dirty)
print(output)"""`
}

RED='\[\033[1;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
NO_COLOR='\[\033[0m\]'

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' $(source_control)\n'$NO_COLOR'$ '
