# herdr : multiplexeur de terminal qui reconnaît les agents (philosophie : docs/ide.md du repo)
command -v herdr >/dev/null 2>&1 || return 0

# Fonction shell (pas un binaire) : `type projet` ou README, « Commandes maison ».
# Fiches : cheatsheets/herdr/ (herdr-essentiel) et cheatsheets/claude/ (claude-sandbox).
#
# projet [dossier] : ouvre le projet dans herdr, ou y revient s'il est déjà ouvert.
# Un workspace par projet, 4 onglets : 1 claude, 2 nvim, 3 git (lazygit), 4 term.
# Dossier : la racine du dépôt git ; un nom connu de zoxide marche aussi (projet dotfiles).
# Claude tourne dans une microVM (comme claude-vm, sbx.sh) si sbx est installé ; PROJET_CLAUDE=host le lance
# sur la machine, avec le lien /ide vers nvim mais sans l'isolation.
# Dans la microVM, HERDR_AGENT=claude fait suivre son état par herdr (voir claude-vm).
projet() {
  local dir label ws tab pane t cmd
  command -v jq >/dev/null 2>&1 || { echo "projet : jq requis (make brew)" >&2; return 1; }
  dir=${1:-.}
  if [ ! -d "$dir" ] && command -v zoxide >/dev/null 2>&1; then dir=$(zoxide query "$dir" 2>/dev/null); fi
  dir=$(cd "${dir:-/nonexistent}" 2>/dev/null && { git rev-parse --show-toplevel 2>/dev/null || pwd; }) ||
    { echo "projet : dossier introuvable : $1" >&2; return 1; }
  label=${dir##*/}

  # Serveur herdr (sessions persistantes) : démarré en arrière-plan s'il ne tourne pas
  if ! herdr workspace list >/dev/null 2>&1; then
    (herdr server >/dev/null 2>&1 &)
    for t in 1 2 3 4 5 6 7 8 9 10; do
      herdr workspace list >/dev/null 2>&1 && break
      sleep 0.5
    done
  fi

  ws=$(herdr workspace list 2>/dev/null |
    jq -r --arg l "$label" '[.result.workspaces[] | select(.label == $l)][0].workspace_id // empty')
  if [ -n "$ws" ]; then
    herdr workspace focus "$ws" >/dev/null
  else
    if [ "${PROJET_CLAUDE:-vm}" != host ] && command -v sbx >/dev/null 2>&1; then
      cmd="HERDR_AGENT=claude sbx run --name $(_sbx_nom "$dir") claude '$dir'"
    else
      cmd=claude
    fi
    ws=$(herdr workspace create --cwd "$dir" --label "$label" --focus) || return 1
    tab=$(printf '%s' "$ws" | jq -r .result.tab.tab_id)
    pane=$(printf '%s' "$ws" | jq -r .result.root_pane.pane_id)
    ws=$(printf '%s' "$ws" | jq -r .result.workspace.workspace_id)
    herdr tab rename "$tab" claude >/dev/null
    herdr pane run "$pane" "$cmd" >/dev/null
    for t in nvim:nvim git:lazygit term:; do
      pane=$(herdr tab create --workspace "$ws" --cwd "$dir" --label "${t%%:*}" --no-focus |
        jq -r .result.root_pane.pane_id)
      [ -z "${t#*:}" ] || herdr pane run "$pane" "${t#*:}" >/dev/null
    done
  fi

  # Hors de herdr : on s'y attache (le workspace du projet est au premier plan)
  [ -n "$HERDR_ENV" ] || herdr
}
