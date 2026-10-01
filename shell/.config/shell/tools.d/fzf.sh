# fzf : recherche floue (Ctrl-R, Ctrl-T, Alt-C)
command -v fzf >/dev/null 2>&1 || return 0

# fzf >= 0.48 ; une version plus ancienne ne connaît pas --bash/--zsh et n'est pas branchée
eval "$(fzf --"$DOTFILES_SHELL" 2>/dev/null)"

# bash-completion 2.11 (Ubuntu 24.04) : fzf ne prend la complétion par défaut que s'il y
# trouve le chargeur de la 2.12+ (_comp_complete_load). Face à celui de la 2.11, il la
# laisse, et ps **<Tab> ne lance pas fzf. Il sait pourtant le chaîner : on la lui donne.
if [ "$DOTFILES_SHELL" = bash ] && declare -F __fzf_default_completion >/dev/null; then
  case $(complete -p -D 2>/dev/null) in
    *' -F _completion_loader '*) complete -D -F __fzf_default_completion -o default -o bashdefault ;;
  esac
fi
