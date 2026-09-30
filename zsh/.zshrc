# Powerlevel10k instant prompt : doit rester en tête, avant tout ce qui peut
# écrire à l'écran ou demander une saisie.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# compdef n'existe qu'après compinit, mais les modules (tools.d, brew, docker…) sont
# chargés avant, pour que leur fpath soit pris en compte. Leurs appels sont
# mémorisés ici, puis rejoués après compinit.
typeset -ga _dotfiles_compdefs
compdef() { _dotfiles_compdefs+=("${(j: :)${(@q)@}}") }

# Config commune bash/zsh
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh"
else
  echo "dotfiles : ~/.config/shell/init.sh introuvable (make zsh depuis le repo dotfiles-public)" >&2
fi

# zsh uniquement
source "$XDG_CONFIG_HOME/zsh/zsh-options.sh"
source "$XDG_CONFIG_HOME/zsh/zinit.sh"

# Complétion
# Cache dans ~/.cache/zsh (reconstruit seulement quand les complétions disponibles changent)
[[ -d "$XDG_CACHE_HOME/zsh" ]] || command mkdir -p "$XDG_CACHE_HOME/zsh"
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
for _dotfiles_c in "${_dotfiles_compdefs[@]}"; do eval "compdef $_dotfiles_c"; done
unset _dotfiles_compdefs _dotfiles_c
(( ${+functions[zinit]} )) && zinit cdreplay -q

alias sz='source ~/.zshrc'
alias ez='"$EDITOR" ~/.zshrc'

# Keybindings
#bindkey "^f" autosuggest-accept
#bindkey "^p" history-search-backward
#bindkey "^n" history-search-forward
