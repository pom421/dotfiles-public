XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Source configuration commune
if [ -d "$XDG_CONFIG_HOME/shell" ]; then
    for f in "$XDG_CONFIG_HOME/shell"/*.sh; do 
        echo "source $f;"
        source "$f"; done
else
    echo "Erreur: Le répertoire $XDG_CONFIG_HOME/shell n'existe pas. Utilisez: stow -t \$HOME shell"
    return 1
fi

# ZSH-spécifique
source "$XDG_CONFIG_HOME/zsh/zsh-options.sh"
source "$XDG_CONFIG_HOME/zsh/zinit.sh"
source "$XDG_CONFIG_HOME/zsh/nvm-autouse.sh"
#source "$XDG_CONFIG_HOME/zsh/snyk.sh" # dans dotfiles-private

alias sz="source ~/.zshrc"
alias ez="nvim ~/.zshrc"

# Keybindings
#bindkey "^f" autosuggest-accept
#bindkey "^p" history-search-backward
#bindkey "^n" history-search-forward

# Shell integrations
eval "$(fzf --zsh)"
source /Users/pom/cli/agent-vm/agent-vm.sh # zsh


if [[ "$OSTYPE" == "darwin"* ]]; then
   alias aero="killall AeroSpace && open /Applications/AeroSpace.app"
fi
