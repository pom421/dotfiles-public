# Powerlevel10k instant prompt : doit rester en tête, avant tout ce qui peut
# écrire à l'écran ou demander une saisie.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Config commune bash/zsh
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh"
else
  echo "dotfiles : ~/.config/shell/init.sh introuvable (make zsh depuis le repo dotfiles-public)" >&2
fi

# zsh uniquement
source "$XDG_CONFIG_HOME/zsh/zsh-options.sh"
source "$XDG_CONFIG_HOME/zsh/zinit.sh"

alias sz='source ~/.zshrc'
alias ez='"$EDITOR" ~/.zshrc'

# Keybindings
#bindkey "^f" autosuggest-accept
#bindkey "^p" history-search-backward
#bindkey "^n" history-search-forward
