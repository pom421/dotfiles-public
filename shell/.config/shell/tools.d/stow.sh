# GNU Stow : installe les dotfiles par liens symboliques
command -v stow >/dev/null 2>&1 || return 0

# Cible ~ quel que soit le repo (public ou privé), sans replier les dossiers
alias stow='stow --target="$HOME" --no-folding'
