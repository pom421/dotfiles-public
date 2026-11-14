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

# ─── herdr ───────────────────────────────────────────────────────
# Après nvim : l'onglet nvim de projet trouve les plugins déjà installés
echo "== herdr"
check "herdr : config valide" herdr config check
# projet ouvre un workspace à 4 onglets (claude, nvim, git, term), et y revient sans doublon
projet_opens_tabs() {
  local out
  out=$(HERDR_SESSION=banc HERDR_ENV=1 bash -ic 'cd ~/dotfiles/dotfiles-public && projet && projet; sleep 1
    herdr workspace list | jq -r ".result.workspaces | length"
    herdr tab list --workspace w1 | jq -r "[.result.tabs[].label] | join(\" \")"
    herdr server stop' 2>&1)
  [[ $out == *$'1\nclaude nvim git term'* ]] || { echo "$out" | tail -5; return 1; }
}
check "herdr : projet ouvre les onglets claude, nvim, git, term" projet_opens_tabs

# ─── Bilan ───────────────────────────────────────────────────────
echo
if [ "$failures" -eq 0 ]; then echo "Tout est ok"; else echo "$failures échec(s)"; fi
exit $((failures > 0))
