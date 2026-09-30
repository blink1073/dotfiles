# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    brew
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

export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export AWS_PROFILE="drivers-test"
export DRIVERS_TOOLS="$HOME/workspace/drivers-evergreen-tools"
export MDB_SPECS="$HOME/workspace/specifications"

function evg-patch() {
    evergreen patch -y "$@" --browse -d "$(git rev-parse --abbrev-ref HEAD)-$(git rev-parse --short HEAD)"
}

source ~/.bashrc

export GOPATH=$(go env GOPATH)
export PATH=$PATH:$(go env GOPATH)/bin

export NVM_DIR="$HOME/workspace/drivers-evergreen-tools/.evergreen/github_app"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# The following line enables Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)

# Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE="$HOME/miniforge3/bin/mamba";
export MAMBA_ROOT_PREFIX="$HOME/miniforge3";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# bind the Control-P/N keys for use in EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey \^U backward-kill-line

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
