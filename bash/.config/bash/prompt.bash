# Prompt bash dans le style « pure » du prompt zsh (~/.p10k.zsh) :
#
#   ~/dotfiles/dotfiles-public main* ⇡1 5s
#   ❯
#
# Dossier (bleu), branche git (gris) avec * si des fichiers sont modifiés, ⇡/⇣ en
# avance ou en retard sur la branche distante (cyan), durée de la dernière commande
# au-delà de 5 s (jaune) ; ❯ magenta, ou rouge après un échec ; utilisateur@machine
# seulement en ssh ou en root. Une ligne vide sépare les prompts.
#
# Gros dépôt : `git config bash.showDirtyState false` n'y affiche que la branche.
# DOTFILES_PROMPT_GIT=off coupe les informations git partout.

# Symboles : Unicode seulement si le terminal est en UTF-8
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
  *UTF-8* | *utf8* | *UTF8* | *utf-8*) _prompt_char='❯' _prompt_up='⇡' _prompt_down='⇣' ;;
  *) _prompt_char='>' _prompt_up='^' _prompt_down='v' ;;
esac

# Branche, état et écart avec la branche distante, en un seul appel à git
_prompt_git() {
  [ "${DOTFILES_PROMPT_GIT-}" = off ] && return
  local out line branch="" oid="" ahead=0 behind=0 dirty=""
  if [ "$(git config --bool bash.showDirtyState 2>/dev/null)" = false ]; then
    branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
    printf ' \001\e[90m\002%s\001\e[0m\002' "$branch"
    return
  fi
  out=$(git status --porcelain=v2 --branch 2>/dev/null) || return
  while IFS= read -r line; do
    case "$line" in
      "# branch.head "*) branch=${line#"# branch.head "} ;;
      "# branch.oid "*) oid=${line#"# branch.oid "} ;;
      "# branch.ab "*)
        line=${line#"# branch.ab +"}
        ahead=${line%% *}
        behind=${line##*-}
        ;;
      "#"*) ;;
      *) dirty='*' ;;
    esac
  done <<<"$out"
  [ "$branch" = "(detached)" ] && branch="@${oid:0:7}"
  printf ' \001\e[90m\002%s%s\001\e[0m\002' "$branch" "$dirty"
  [ "$ahead" != 0 ] || [ "$behind" != 0 ] && printf ' \001\e[36m\002'
  [ "$ahead" != 0 ] && printf '%s%s' "$_prompt_up" "$ahead"
  [ "$behind" != 0 ] && printf '%s%s' "$_prompt_down" "$behind"
  [ "$ahead" != 0 ] || [ "$behind" != 0 ] && printf '\001\e[0m\002'
  return 0
}

# Appelé avant chaque prompt (en tête de PROMPT_COMMAND, pour lire le code de retour).
# PS1 est fixe et ne fait que citer des variables : bash ne réinterprète pas leur
# contenu, alors qu'un nom de branche inséré dans PS1 (« $(commande) ») serait exécuté.
# Les couleurs y sont donc en octets bruts (\001 \002 encadrent ce qui ne s'affiche pas).
_prompt() {
  local status=$?
  _prompt_who="" _prompt_took=""
  if [ -n "${SSH_CONNECTION-}" ] || [ "${EUID:-$(id -u)}" = 0 ]; then
    printf -v _prompt_who '\001\e[90m\002%s@%s\001\e[0m\002 ' "$USER" "${HOSTNAME%%.*}"
  fi
  _prompt_gitinfo=$(_prompt_git)
  if [ -n "${_prompt_t0-}" ]; then
    [ $((SECONDS - _prompt_t0)) -ge 5 ] && printf -v _prompt_took ' \001\e[33m\002%ss\001\e[0m\002' $((SECONDS - _prompt_t0))
    unset _prompt_t0
  fi
  if [ "$status" = 0 ]; then
    printf -v _prompt_sym '\001\e[35m\002%s\001\e[0m\002' "$_prompt_char"
  else
    printf -v _prompt_sym '\001\e[31m\002%s\001\e[0m\002' "$_prompt_char"
  fi
}
PS1='\n${_prompt_who}\[\e[34m\]\w\[\e[0m\]${_prompt_gitinfo}${_prompt_took}\n${_prompt_sym} '

# Début de commande : le piège DEBUG s'exécute avant chaque commande, mais ne note
# l'heure que pour la première après un prompt (_prompt_ready, posé en toute fin de
# PROMPT_COMMAND, après les commandes du prompt lui-même). Marche aussi en bash 3.2.
_prompt_preexec() {
  [ -n "${_prompt_ready-}" ] || return 0
  _prompt_ready=""
  _prompt_t0=$SECONDS
}
trap '_prompt_preexec' DEBUG

PROMPT_COMMAND="_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}; _prompt_ready=1"
