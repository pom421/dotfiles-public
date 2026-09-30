#!/bin/sh
# Profils VSCode (TypeScript, Markdown…) : VSCode ne sait ni les exporter ni les créer
# en ligne de commande. Ce script versionne ce qui manque au repo :
#   - le registre des profils (nom ↔ dossier), dans User/globalStorage/storage.json
#   - la liste des extensions de chaque profil
# Les réglages, raccourcis et snippets sont déjà versionnés dans vscode/profiles/<dossier>/.
#
#   vscode-profiles.sh export   machine source → vscode/profiles.json
#   vscode-profiles.sh import   vscode/profiles.json → cette machine (VSCode fermé)
#
# L'import déclare chaque profil avec le même dossier que sur la machine source : les
# réglages versionnés sous vscode/profiles/<dossier>/ s'y appliquent donc directement.
# Variables : VSCODE_USER (dossier User de VSCode), REPO (racine de dotfiles-public).
set -eu

: "${VSCODE_USER:?VSCODE_USER non défini}"
: "${REPO:?REPO non défini}"
storage="$VSCODE_USER/globalStorage/storage.json"
export NODE_NO_WARNINGS=1 # avertissements Node (DEP0169) de la CLI de VSCode
profiles="$REPO/vscode/profiles.json"

for cmd in code jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "vscode-profiles : $cmd introuvable" >&2
    [ "$cmd" = code ] && echo "  (dans VSCode : « Shell Command: Install 'code' command in PATH »)" >&2
    exit 1
  }
done

export_profiles() {
  [ -r "$storage" ] || { echo "vscode-profiles : $storage introuvable" >&2; exit 1; }
  # builtin/* (ex. Agents) : profils créés et gérés par VSCode lui-même
  jq -c '.userDataProfiles // [] | .[] | select(.location | startswith("builtin/") | not)' "$storage" | while IFS= read -r p; do
    name=$(printf '%s' "$p" | jq -r .name)
    code --profile "$name" --list-extensions </dev/null |
      jq -R . | jq -s --argjson p "$p" '$p + {extensions: .}'
  done | jq -s 'sort_by(.name)' >"$profiles.tmp"
  mv "$profiles.tmp" "$profiles"
  jq -r '.[] | "\(.name) (\(.location)) : \(.extensions | length) extensions"' "$profiles"
}

import_profiles() {
  [ -r "$profiles" ] || { echo "vscode-profiles : $profiles absent (make vscode-export sur l'autre machine)" >&2; exit 1; }
  mkdir -p "$(dirname "$storage")"
  [ -s "$storage" ] || echo '{}' >"$storage"

  # 1. Registre : ajoute les profils absents, avec leur dossier d'origine
  jq -c '.[] | select(.location | startswith("builtin/") | not) | del(.extensions)' "$profiles" | while IFS= read -r p; do
    loc=$(printf '%s' "$p" | jq -r .location)
    name=$(printf '%s' "$p" | jq -r .name)
    state=$(jq -r --arg l "$loc" --arg n "$name" '
      (.userDataProfiles // []) as $h
      | if any($h[]; .location == $l) then "present"
        elif any($h[]; .name == $n) then "conflit"
        else "absent" end' "$storage")
    case $state in
      present) ;;
      conflit) echo "profil « $name » : existe déjà sous un autre dossier, réglages du repo non appliqués" >&2 ;;
      absent)
        jq --argjson p "$p" '.userDataProfiles = ((.userDataProfiles // []) + [$p])' "$storage" >"$storage.tmp"
        mv "$storage.tmp" "$storage"
        echo "profil « $name » déclaré ($loc)"
        ;;
    esac
  done

  # 2. Extensions manquantes, profil par profil
  jq -r '.[] | select(.location | startswith("builtin/") | not) | .name as $n | .extensions[] | [$n, .] | @tsv' "$profiles" | while IFS="$(printf '\t')" read -r name ext; do
    if ! code --profile "$name" --list-extensions </dev/null | grep -qix "$ext"; then
      code --profile "$name" --install-extension "$ext" </dev/null >/dev/null && echo "« $name » : $ext installée"
    fi
  done
}

case "${1-}" in
  export) export_profiles ;;
  import) import_profiles ;;
  *) echo "Usage : $0 export|import" >&2; exit 1 ;;
esac
