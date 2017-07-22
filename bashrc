
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
    npm version patch
    git push origin master && git push origin --tags 
    npm publish
}

function npm-minor {
    git checkout master && git pull
    npm update
    npm version minor
    git push origin master && git push origin --tags 
    npm publish
}

function npm-preminor {
    git checkout master && git pull
    npm update
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
    npm version patch
    git push origin $1 && git push origin --tags
    npm publish
}

function py-release {
    local version=`python setup.py --version 2>/dev/null`
    git commit -a -m "Release $version"
    git tag v$version; true;
    git push origin --all 
    git push origin --tags
    rm -rf dist
    python setup.py sdist
    python setup.py bdist_wheel --universal
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
    source activate lab-test
    pip uninstall -y jupyterlab
    pip install --pre jupyterlab 
    cd ~/workspace
    jupyter lab --core-mode
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
alias met="cd ~/workspace/metabolite-atlas/metatlas"
alias spy="cd ~/workspace/spyder-ide"
alias spyi="cd ~/workspace/spyder-ide/spyderlib/utils/introspection"
alias ph="cd ~/workspace/phosphor"
alias ws="cd ~/workspace"
alias kbase="source activate kbase; kbase-narrative"
alias oct="cd ~/workspace/oct2py"
alias imio="cd ~/workspace/imageio"
alias jjs="cd ~/workspace/jupyter/services"
alias jp='cd ~/workspace/jupyter'
alias jsnb='cd ~/workspace/jupyter/js-notebook';
alias jsui='cd ~/workspace/jupyter/ui';
alias jsp='cd ~/workspace/jupyter/plugins';
alias jnb='cd ~/workspace/jupyter/notebook';
alias lab='cd ~/workspace/jupyter/lab';
alias srv='cd ~/workspace/jupyter/services';

alias gca='git commit -a --verbose'
alias gs='git status'
alias gsv='git status --verbose'
alias gpu='git pull upstream master && git push upstream master'
alias gpo='git push origin --tags && git push origin'
alias gpa='git push origin --tags && git push origin --all'
alias gp='git push origin'
alias gu='git pull upstream'
alias gb='git branch'
alias gd='git diff'
alias ga='git add'
alias gc='git commit --verbose'
alias gr='git remote -v'

alias mocha-debug="pkill node; node-debug _mocha"
alias jupyter-notebook='jupyter notebook --NotebookApp.ignore_minified_js=True'

alias edison="ssh silvest@corigrid.nersc.gov"
alias cori="ssh silvest@corigrid.nersc.gov"

#eval "$(hub alias -s)"

#source ~/.hub_bash_completion.sh

alias hc='hg commit --verbose'
alias hs='hg status'
alias hsv='hg status --verbose'
alias hpo='hg push origin'
alias hb='hg branches'
alias hco='hg checkout'
alias hd='hg diff'
alias hp='hg push'
alias ha='hg add'
alias octave='octave-cli'

source ~/hg_bash_completion

export SPYDER_DEBUG=True
export PED_EDITOR=subl
export TMPDIR='/tmp'
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"
export PATH="/usr/texbin:$PATH"
export PATH="$PATH:/Applications/Octave.app/Contents/Resources/usr/bin/"

function search() {
    grep -irn --exclude-dir=node_modules "$1" .
}

function searchsensitive() {
    grep -rn --exclude-dir=node_modules "$1" .
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


# build up PS1 with source control annotation
function source_control {
  echo `/usr/bin/python  -c """
import re
import sys
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

export PS1=$GREEN'\u: '$BLUE'\w'$YELLOW' `source_control`\n'$NO_COLOR'$ '
export PROMPT_COMMAND='echo'

# added by travis gem
[ -f /Users/ssilvester/.travis/travis.sh ] && source /Users/ssilvester/.travis/travis.sh
