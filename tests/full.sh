#!/usr/bin/env bash
# Banc complet : `make full` sur une Ubuntu 24.04 neuve (linuxbrew, Brewfile), puis
# vérifications par outil. Lancé dans le conteneur par `make test-full` (réseau requis).
# Continue après un échec pour tout lister.
set -u
cd "$(dirname "$0")/.." || exit 1

failures=0

# Mêmes aides que tests/smoke.sh
check() {
  local desc=$1 out
  shift
  if out=$("$@" 2>&1); then
    printf 'ok   %s\n' "$desc"
  else
    printf 'FAIL %s\n' "$desc"
    [ -n "$out" ] && printf '%s\n' "$out" | tail -20 | sed 's/^/     | /'
    failures=$((failures + 1))
  fi
}

in_tty() {
  script -qec "$1" /dev/null | tr -d '\r'
  return "${PIPESTATUS[0]}"
}

silent() {
  local out
  out=$(in_tty "$1") || { printf '%s\n' "$out"; return 1; }
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

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
echo "== nvim"
NVIM_CONF=nvim/.config/nvim
DATA=$HOME/.local/share/nvim

plugins_installed() {
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1
  local missing=""
  for p in $(grep -oE '^  "[^"]+"' "$NVIM_CONF/lazy-lock.json" | tr -d ' "'); do
    [ -d "$DATA/lazy/$p" ] || missing="$missing $p"
  done
  [ -z "$missing" ] || { echo "plugins absents :$missing"; return 1; }
}
check "nvim : plugins de lazy-lock.json installés" plugins_installed

# Langages déclarés dans treesitter.lua (bloc `local languages = { … }`)
LANGS=$(sed -n '/^local languages = {/,/^}/p' "$NVIM_CONF/lua/plugins/treesitter.lua" | grep -oE '"[a-z_]+"' | tr -d '"')

parsers_installed() {
  local n
  n=$(echo "$LANGS" | wc -w)
  # nvim-treesitter compile les parsers en tâche de fond au démarrage : on attend
  nvim --headless "+lua vim.wait(300000, function() return #vim.fn.globpath('$DATA/site/parser', '*.so', false, true) >= $n end, 2000)" +qa >/dev/null 2>&1
  local missing=""
  for l in $LANGS; do [ -f "$DATA/site/parser/$l.so" ] || missing="$missing $l"; done
  [ -z "$missing" ] || { echo "parsers absents :$missing"; return 1; }
}
check "nvim : parsers treesitter compilés" parsers_installed

checkhealth_clean() {
  # DISPLAY factice : nvim détecte alors xclip comme sous X11 (pas d'écran dans le conteneur)
  rm -f /tmp/health.txt
  DISPLAY=:0 nvim --headless "+checkhealth" "+w! /tmp/health.txt" +qa >/dev/null 2>&1
  [ -s /tmp/health.txt ] || { echo "rapport :checkhealth absent"; return 1; }
  # Seule alerte admise : pas d'ouvreur d'URL (xdg-open), propre au conteneur sans bureau
  local alerts
  alerts=$(grep -E '❌|⚠️' /tmp/health.txt | grep -vE '^[a-zA-Z_.-]+: ' | grep -v 'vim.ui.open: no handler')
  [ -z "$alerts" ] || { echo "$alerts"; return 1; }
}
check "nvim : :checkhealth sans erreur ni alerte" checkhealth_clean

# Ouvre un fichier dans un vrai terminal ; échoue sur un message d'erreur ou sans coloration
nvim_opens() {
  local file=$1 msg=/tmp/nvim-msg
  rm -f "$msg"
  # Échap ferme un éventuel « Press ENTER », puis on écrit les messages et on quitte
  { sleep 4; printf '\033:redir! > %s | silent messages | redir END | qa!\r' "$msg"; sleep 2; } |
    in_tty "stty cols 120 rows 40; nvim $file '+lua vim.defer_fn(function() vim.api.nvim_echo({{\"coloration: \" .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)}}, true, {}) end, 2500)'" >/dev/null
  # E1568 : le pseudo-terminal ne répond pas à la question de nvim sur la couleur de fond
  if grep -v E1568 "$msg" | grep -qiE 'error|E[0-9]{2,4}:'; then grep -v E1568 "$msg"; return 1; fi
  grep -q 'coloration: true' "$msg" || { echo "pas de coloration treesitter"; cat "$msg"; return 1; }
}

mkdir -p /tmp/f
printf '# Titre\n\n```lua\nlocal x = 1\n```\n\n```js\nconst a = 1;\n```\n' > /tmp/f/t.md
printf 'const a = 1;\n' > /tmp/f/t.js
cp /tmp/f/t.js /tmp/f/t.ts
cp /tmp/f/t.js /tmp/f/t.tsx
printf '#!/bin/bash\necho hi\n' > /tmp/f/t.sh
printf '%s\n' '---@param x string' 'local s = string.format("%s", x)' > /tmp/f/t.lua
for f in t.md t.js t.ts t.tsx t.sh t.lua; do
  check "nvim : ouvre $f sans erreur, avec coloration" nvim_opens "/tmp/f/$f"
done

# ─── Bilan ───────────────────────────────────────────────────────
echo
if [ "$failures" -eq 0 ]; then echo "Tout est ok"; else echo "$failures échec(s)"; fi
exit $((failures > 0))
