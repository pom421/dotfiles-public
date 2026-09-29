# Accès rapide aux repos de dotfiles
export DOTPUB="${DOTPUB:-$HOME/dotfiles/dotfiles-public}"
export DOTPRIV="${DOTPRIV:-$HOME/dotfiles/dotfiles-private}"

alias dpu='cd "$DOTPUB"'
alias dpr='cd "$DOTPRIV"'
