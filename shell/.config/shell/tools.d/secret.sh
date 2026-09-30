# secret : secrets rangés dans le trousseau du système, jamais dans un fichier ni un repo
#   secret set NOM                   enregistre (saisie masquée)
#   secret get NOM                   affiche le secret
#   secret rm NOM                    supprime
#   with_secret VAR NOM commande…    lance la commande avec VAR=secret, pour elle seule
# macOS : trousseau (security). Linux : Secret Service (secret-tool, paquet libsecret-tools).
case "$OSTYPE" in
  darwin*) command -v security >/dev/null 2>&1 || return 0 ;;
  *) command -v secret-tool >/dev/null 2>&1 || return 0 ;;
esac

secret() {
  local action="${1-}" name="${2-}"
  if [ -z "$name" ]; then
    echo "Usage : secret set|get|rm NOM" >&2
    return 1
  fi
  case "$OSTYPE:$action" in
    darwin*:set) security add-generic-password -U -a "$USER" -s "dotfiles:$name" -w ;;
    darwin*:get) security find-generic-password -a "$USER" -s "dotfiles:$name" -w ;;
    darwin*:rm) security delete-generic-password -a "$USER" -s "dotfiles:$name" >/dev/null ;;
    *:set) secret-tool store --label="dotfiles: $name" service dotfiles name "$name" ;;
    *:get) secret-tool lookup service dotfiles name "$name" ;;
    *:rm) secret-tool clear service dotfiles name "$name" ;;
    *)
      echo "Usage : secret set|get|rm NOM" >&2
      return 1
      ;;
  esac
}

# Ex. dans local.d : snyk() { with_secret SNYK_TOKEN snyk-token snyk "$@"; }
# (env lance le vrai binaire, pas la fonction : pas de boucle)
with_secret() {
  local var="$1" name="$2" value
  shift 2
  value="$(secret get "$name")" && [ -n "$value" ] || {
    echo "with_secret : secret « $name » introuvable (secret set $name)" >&2
    return 1
  }
  env "$var=$value" "$@"
}
