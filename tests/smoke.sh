#!/usr/bin/env bash
# Test de fumée : la config minimale doit fonctionner sur une machine nue
# (pas de brew, pas d'outils de confort, pas de réseau, pas de repo privé).
# Lancé dans le conteneur par `make test`. Continue après un échec pour tout lister.
set -u
cd "$(dirname "$0")/.." || exit 1

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

# Échoue si la commande que git lancera (éditeur, pager), vue depuis un bash
# configuré (donc avec $EDITOR des dotfiles), n'existe pas
git_var_exists() {
  local cmd
  cmd=$(in_tty "bash -ic 'git var $1'" | tail -n 1) || return 1
  command -v "${cmd%% *}" >/dev/null || { echo "$1 = $cmd : commande introuvable"; return 1; }
}

# Échoue si un credential helper configuré n'existe pas
credential_helpers_exist() {
  local h
  while read -r h; do
    case $h in '' | '!'* | /*) continue ;; esac # vide = remise à zéro ; shell ou chemin : non vérifié
    [ -x "$(git --exec-path)/git-credential-${h%% *}" ] || command -v "git-credential-${h%% *}" >/dev/null ||
      { echo "credential.helper = $h : git-credential-${h%% *} introuvable"; return 1; }
  done < <(git config --get-all credential.helper)
}

# Sans identité configurée, git doit refuser le commit plutôt que d'en deviner une
# ($EMAIL, user@hostname). $EMAIL est posé pour que la devinette réussisse sans useConfigOnly.
commit_refused_without_identity() {
  local r out
  r=$(mktemp -d)
  git -C "$r" init -q
  out=$(EMAIL=devine@example.com git -C "$r" -c commit.gpgsign=false commit -q --allow-empty -m test 2>&1)
  printf '%s\n' "$out" | grep -q 'auto-detection is disabled' || { printf '%s\n' "${out:-commit accepté}"; return 1; }
}

# make git-tools doit activer delta quand il est installé (faux delta = cat)
delta_activated_when_installed() {
  local bin pager
  bin=$(mktemp -d)
  printf '#!/bin/sh\nexec cat\n' >"$bin/delta"
  chmod +x "$bin/delta"
  PATH="$bin:$PATH" make -s git-tools >/dev/null || return 1
  pager=$(git config core.pager)
  rm -rf "$bin"
  make -s git-tools >/dev/null # retour à l'état sans delta
  [ "$pager" = delta ] || { echo "core.pager = '$pager' (attendu : delta)"; return 1; }
}

# Un module de tools.d s'active quand l'outil est présent (faux lazygit dans ~/.local/bin)
module_activated_when_installed() {
  local shell=$1 rc
  mkdir -p "$HOME/.local/bin"
  printf '#!/bin/sh\n' >"$HOME/.local/bin/lazygit"
  chmod +x "$HOME/.local/bin/lazygit"
  in_tty "$shell -ic 'alias lg >/dev/null'"
  rc=$?
  rm -f "$HOME/.local/bin/lazygit"
  return "$rc"
}

# DOTFILES_DEBUG=1 affiche les fichiers chargés
debug_lists_files() {
  in_tty "DOTFILES_DEBUG=1 bash -ic true" | grep -q 'shell/core/nav.sh'
}

# Un alias qui porte le nom d'une commande doit lancer cette même commande
# (ls='ls -F' oui, ls=eza non)
no_tool_swapping_alias() {
  local name value bad=""
  while IFS='=' read -r name value; do
    command -v "$name" >/dev/null 2>&1 || continue
    [ "${value%% *}" = "$name" ] || bad="$bad $name=$value"
  done < <(in_tty "$1 -ic alias" | sed -e 's/^alias //' -e "s/'//g")
  [ -z "$bad" ] || { echo "alias vers un autre outil :$bad"; return 1; }
}

# make unfold remplace un dossier replié (lien vers le repo) par un vrai dossier
unfold_replaces_folded_dir() {
  rm -rf "$HOME/.config/zsh"
  ln -s ../dotfiles/dotfiles-public/zsh/.config/zsh "$HOME/.config/zsh"
  make -s unfold >/dev/null || return 1
  [ -d "$HOME/.config/zsh" ] && [ ! -L "$HOME/.config/zsh" ] && [ -L "$HOME/.config/zsh/zinit.sh" ] ||
    { ls -la "$HOME/.config"; return 1; }
}

base_cmds="mkcd ll la extract h g git-ls"

echo "== Installation"
check "make minimal" make minimal
check "make unfold : déplie un dossier replié" unfold_replaces_folded_dir

echo "== Bash"
check "bash interactif : démarre sans sortie" silent "bash -ic true"
check "bash login : démarre sans sortie" silent "bash -lic true"
check "bash : rechargement sans sortie" silent "bash -ic '. ~/.bashrc'"
check "bash : commandes de base ($base_cmds)" in_tty "bash -ic 'type $base_cmds >/dev/null'"
check "bash : ls fonctionne" in_tty "bash -ic 'ls / >/dev/null'"
check "bash : aucun alias vers un autre outil" no_tool_swapping_alias bash
check "bash : mkcd sans sortie (malgré mkdir -pv)" silent "bash -ic 'mkcd /tmp/mkcd-bash/a'"
check "bash : module actif si l'outil est installé" module_activated_when_installed bash
check "bash : DOTFILES_DEBUG liste les fichiers" debug_lists_files

echo "== Zsh"
check "zsh interactif : démarre sans sortie" silent "zsh -ic true"
check "zsh : commandes de base ($base_cmds)" in_tty "zsh -ic 'type $base_cmds >/dev/null'"
check "zsh : ls fonctionne" in_tty "zsh -ic 'ls / >/dev/null'"
check "zsh : aucun alias vers un autre outil" no_tool_swapping_alias zsh
check "zsh : module actif si l'outil est installé" module_activated_when_installed zsh
check "zsh : git.sh se charge malgré l'alias g d'OMZ" silent "zsh -fc 'alias g=git; source ~/.config/shell/tools.d/git.sh'"

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
check "git : credential helper disponible" credential_helpers_exist
check "git : commit refusé sans identité" commit_refused_without_identity
check "git : delta activé s'il est installé" delta_activated_when_installed

echo
if [ "$failures" -eq 0 ]; then
  echo "Tout est vert."
else
  echo "$failures échec(s)."
  exit 1
fi
