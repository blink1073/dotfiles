# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    brew
    docker
    npm
    macos
    bgnotify
    history-substring-search
)

source $ZSH/oh-my-zsh.sh

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP


# Add the current host alias if available
if [ -f ~/.current_host ]; then
   source ~/.current_host
fi


if [ -f /usr/local/bin/brew ];then
    brew_prefix=/usr/local
else
    brew_prefix=/opt/homebrew
fi

eval $(${brew_prefix}/bin/brew shellenv)
source ${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PYMONGOCRYPT_LIB=$HOME/libmongocrypt-all/macos/nocrypto/lib/libmongocrypt.dylib
export PATH="$HOME/workspace/clusters/mongodb-macos-aarch64-enterprise-6.0.0/bin/:$PATH"
export PYTHON=/Library/Frameworks/Python.framework/Versions/3.10/bin/python3

source ~/.bashrc

# bind the Control-P/N keys for use in EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey \^U backward-kill-line
