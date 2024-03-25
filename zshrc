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
    keychain
    gpg-agent
)

source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

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

function evg-patch() {
    evergreen patch -y "$@" -d "$(git rev-parse --abbrev-ref HEAD)-$(git rev-parse --short HEAD)"
}

source ~/.bashrc

# bind the Control-P/N keys for use in EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey \^U backward-kill-line
