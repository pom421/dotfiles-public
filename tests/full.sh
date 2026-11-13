#!/usr/bin/env bash
# Banc complet : `make full` sur une Ubuntu 24.04 neuve (linuxbrew, Brewfile), puis
# vérifications par outil. Lancé dans le conteneur par `make test-full` (réseau requis).
# Continue après un échec pour tout lister.
set -u
cd "$(dirname "$0")/.." || exit 1

failures=0
# shellcheck source=tests/lib.sh
. tests/lib.sh

# ─── Installation ────────────────────────────────────────────────
echo "== make full (plusieurs minutes)"
check "make full" make full
# Sans installation complète, les vérifications suivantes n’ont pas de sens
[ "$failures" -eq 0 ] || { echo; echo "Arrêt : make full a échoué (réseau ?)"; exit 1; }
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Les extensions VSCode sont sautées par le Brewfile lui-même (pas de VSCode dans le conteneur)
check "Brewfile : tout est installé" brew bundle check --verbose --file=brew/.config/brew/Brewfile

# ─── Shells ──────────────────────────────────────────────────────
echo "== shells"
check "bash interactif : démarrage silencieux" silent "bash -ic true"
check "zsh interactif : démarrage silencieux" silent "zsh -ic true"

# ─── nvim ────────────────────────────────────────────────────────
# shellcheck source=tests/nvim.sh
. tests/nvim.sh

# ─── Bilan ───────────────────────────────────────────────────────
echo
if [ "$failures" -eq 0 ]; then echo "Tout est ok"; else echo "$failures échec(s)"; fi
exit $((failures > 0))
