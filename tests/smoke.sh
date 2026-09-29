#!/usr/bin/env bash
# Test de fumée : la config minimale doit fonctionner sur une machine nue
# (pas de brew, pas d'outils de confort, pas de réseau, pas de repo privé).
# Lancé dans le conteneur par `make test`. Continue après un échec pour tout lister.
set -u
cd "$(dirname "$0")/.."

failures=0

# check "description" commande... : affiche ok/FAIL, et la sortie en cas d'échec
check() {
  local desc=$1 out
  shift
  if out=$("$@" 2>&1); then
    printf 'ok   %s\n' "$desc"
  else
    printf 'FAIL %s\n' "$desc"
    [ -n "$out" ] && printf '%s\n' "$out" | head -20 | sed 's/^/     | /'
    failures=$((failures + 1))
  fi
}

# Lance une commande dans un pseudo-terminal (shells interactifs, pager git)
in_tty() {
  script -qec "$1" /dev/null | tr -d '\r'
  return "${PIPESTATUS[0]}"
}

# Échoue si la commande écrit quoi que ce soit (erreur ou sortie parasite)
silent() {
  local out
  out=$(in_tty "$1") || { printf '%s\n' "$out"; return 1; }
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# Lance dans un pseudo-terminal et échoue sur un message d'erreur git,
# même si le code retour vaut 0 (ex. pager introuvable : git continue sans)
git_tty() {
  local out
  out=$(in_tty "$1")
  local rc=$?
  printf '%s\n' "$out"
  [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -qE '^(error|fatal):'
}

# Échoue si la commande configurée pour git (éditeur, pager) n'existe pas
git_var_exists() {
  local cmd
  cmd=$(git var "$1") || return 1
  command -v "${cmd%% *}" >/dev/null || { echo "$1 = $cmd : commande introuvable"; return 1; }
}

echo "== Installation"
check "make minimal" make minimal

echo "== Bash"
check "bash interactif : démarre sans sortie" silent "bash -ic true"
check "bash login : démarre sans sortie" silent "bash -lic true"
check "bash : la config est chargée (mkcd)" in_tty "bash -ic 'type mkcd >/dev/null'"
check "bash : ls fonctionne" in_tty "bash -ic 'ls / >/dev/null'"

echo "== Zsh"
check "zsh interactif : démarre sans sortie" silent "zsh -ic true"
check "zsh : la config est chargée (mkcd)" in_tty "zsh -ic 'type mkcd >/dev/null'"

echo "== Git"
repo=$(mktemp -d)
git -C "$repo" init -q
git -C "$repo" config user.name "Test"
git -C "$repo" config user.email "test@example.com"
echo a >"$repo/f"
git -C "$repo" add f
git -C "$repo" -c commit.gpgsign=false commit -qm init  # commit de base, hors test

check "git : la config globale se lit" git config --global --list
check "git : l'éditeur existe" git_var_exists GIT_EDITOR
check "git : le pager existe" git_var_exists GIT_PAGER
echo b >"$repo/f"
check "git diff (pager)" git_tty "git -C $repo diff"
check "git log (pager)" git_tty "git -C $repo log -1"
check "git add -p" git_tty "printf 'y\n' | script -qec 'git -C $repo add -p' /dev/null"
check "git commit" git -C "$repo" commit -qam "second"

echo
if [ "$failures" -eq 0 ]; then
  echo "Tout est vert."
else
  echo "$failures échec(s)."
  exit 1
fi
