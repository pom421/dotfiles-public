# Pour faciliter l'interopérabilité avec Linux (norme freedesktop.org (XDG Base Directory Spec))<D-s>
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Options ZSH
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups

export EDITOR=nvim
export GPG_TTY=$(tty)

# Import autres fichiers de configuration
source "$XDG_CONFIG_HOME/zsh/aliases.sh"
source "$XDG_CONFIG_HOME/zsh/exports.sh"
source "$XDG_CONFIG_HOME/zsh/nvm.sh"
source "$XDG_CONFIG_HOME/zsh/dgfip-proxy.sh"
source "$XDG_CONFIG_HOME/zsh/functions.sh"
source "$XDG_CONFIG_HOME/zsh/next.sh"
source "$XDG_CONFIG_HOME/zsh/local.sh.chezmoiignore"

# Keybindings
#bindkey "^f" autosuggest-accept
#bindkey "^p" history-search-backward
#bindkey "^n" history-search-forward


# Shell integrations
eval "$(fzf --zsh)"

