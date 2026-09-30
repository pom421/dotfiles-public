# yazi : explorateur de fichiers en terminal
command -v yazi >/dev/null 2>&1 || return 0

# y : lance yazi et se place dans le dossier où on l'a quitté
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then builtin cd -- "$cwd" || return; fi
  command rm -f -- "$tmp"
}
