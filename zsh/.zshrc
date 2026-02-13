# Source configuration commune
if [ -d "$HOME/.config/shell" ]; then
    for f in "$HOME/.config/shell"/*.sh; do source "$f"; done
else
    echo "Erreur: Le répertoire ~/.config/shell n'existe pas. Utilisez: stow -t \$HOME shell"
    return 1
fi

# ZSH-spécifique
source "$XDG_CONFIG_HOME/zsh/zsh-options.sh"
source "$XDG_CONFIG_HOME/zsh/zinit.sh"
source "$XDG_CONFIG_HOME/zsh/nvm-autouse.sh"
source "$XDG_CONFIG_HOME/zsh/snyk.sh" # dans dotfiles-private

alias sz="source ~/.zshrc"
alias ez="nvim ~/.zshrc"

# Keybindings
#bindkey "^f" autosuggest-accept
#bindkey "^p" history-search-backward
#bindkey "^n" history-search-forward

# Shell integrations
eval "$(fzf --zsh)"
