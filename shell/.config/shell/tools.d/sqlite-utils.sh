# sqlite-utils : complétion (en zsh, compdef est rejoué après compinit, cf. ~/.zshrc)
command -v sqlite-utils >/dev/null 2>&1 || return 0

eval "$(_SQLITE_UTILS_COMPLETE="${DOTFILES_SHELL}_source" sqlite-utils)"
