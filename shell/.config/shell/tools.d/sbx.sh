# sbx (Docker Sandboxes) : Claude Code dans une microVM, qui ne voit que le dossier du projet
command -v sbx >/dev/null 2>&1 || return 0

# Nom de la microVM d'un dossier : son nom + une empreinte du chemin (deux projets homonymes
# n'en partagent pas une), ex. dotfiles-public-1234567
_sbx_nom() {
  local base
  base=$(printf '%s' "${1##*/}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')
  printf '%s-%s' "$base" "$(printf '%s' "$1" | cksum | cut -d' ' -f1)"
}

# Fonction shell (pas un binaire) : `type claude-vm` ou README, « Commandes maison ».
# Fiche : cheatsheets/claude/claude-sandbox. Lancée aussi par `projet` (herdr.sh).
#
# claude-vm [dossier] [-- options de claude] : Claude dans la microVM du projet (créée au premier
# lancement, reprise ensuite). Par défaut, la racine du dépôt git courant.
# HERDR_AGENT : herdr ne voit que sbx ; il lit alors l'écran du pane comme celui de Claude (états
# travaille, bloqué, fini dans sa barre latérale). Sans effet hors de herdr.
claude-vm() {
  local dir
  if [ $# -gt 0 ] && [ "$1" != "--" ]; then dir=$1; shift; else dir=.; fi
  dir=$(cd "$dir" 2>/dev/null && { git rev-parse --show-toplevel 2>/dev/null || pwd; }) ||
    { echo "claude-vm : dossier introuvable" >&2; return 1; }
  HERDR_AGENT=claude sbx run --name "$(_sbx_nom "$dir")" claude "$dir" "$@"
}
