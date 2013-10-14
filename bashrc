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
  cd "$(python -c "import os.path as p, ${1}; \
    print p.dirname(p.realpath(${1}.__file__[:-1]))"
)"
  pwd
}

# advanced cd function
source ~/acd_func.sh

export EDITOR=notepad
export PS1='\[\033[01;32m\]\u \[\033[01;34m\]\W \$ \[\033[00m\]'
export PYTHONSTARTUP=~/.pythonrc
# aliases
alias dprojects='cd ~/Dropbox/projects'
alias dworkspace='cd ~/Dropbox/workspace'
alias pip=pip-2.7
alias u='cd ..;'
alias open=start

export SPYDER_DEBUG=True

alias python3=/c/Python33/python
alias pip3=/c/Python33/Scripts/pip
alias nosetests3=/c/Python33/Scripts/nosetests
