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
    direnv
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

export PYMONGOCRYPT_LIB=$HOME/libmongocrypt-all/macos/nocrypto/lib/libmongocrypt.dylib
export PATH="$HOME/workspace/clusters/mongodb-macos-aarch64-enterprise-6.0.0/bin/:$PATH"
export AWS_PROFILE="drivers-test-secrets-role-857654397073"
export DRIVERS_TOOLS="$HOME/workspace/drivers-evergreen-tools"
export MDB_SPECS="$HOME/workspace/specifications"

function evg-patch() {
    evergreen patch -y "$@" --browse -d "$(git rev-parse --abbrev-ref HEAD)-$(git rev-parse --short HEAD)"
}

source ~/.bashrc

# bind the Control-P/N keys for use in EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey \^U backward-kill-line


export GOPATH=$(go env GOPATH)
export PATH=$PATH:$(go env GOPATH)/bin

export NVM_DIR="$HOME/workspace/drivers-evergreen-tools/.evergreen/github_app"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/steve.silvester/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/steve.silvester/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/steve.silvester/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/steve.silvester/Downloads/google-cloud-sdk/completion.zsh.inc'; fi