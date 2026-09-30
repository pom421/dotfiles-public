# Outils qui attendent un jeton dans l'environnement : le jeton est lu dans le
# trousseau au lancement de la commande, jamais exporté dans le shell.
# À enregistrer une fois par machine : secret set snyk-token
command -v with_secret >/dev/null 2>&1 || return 0

if command -v snyk >/dev/null 2>&1; then
  snyk() { with_secret SNYK_TOKEN snyk-token snyk "$@"; }
fi
