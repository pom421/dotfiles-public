# zoxide : cd intelligent (z, zi)
command -v zoxide >/dev/null 2>&1 || return 0

eval "$(zoxide init "$DOTFILES_SHELL")"
