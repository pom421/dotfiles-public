# fzf : recherche floue (Ctrl-R, Ctrl-T, Alt-C)
command -v fzf >/dev/null 2>&1 || return 0

# fzf >= 0.48 ; une version plus ancienne ne connaît pas --bash/--zsh et n'est pas branchée
eval "$(fzf --"$DOTFILES_SHELL" 2>/dev/null)"
