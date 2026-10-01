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

# make unfold ne casse rien en cas de conflit : ~/.zshrc réécrit en vrai fichier
# par un installeur (p10k, Docker…) → échec, et le dossier replié est remis tel quel
unfold_rolls_back_on_conflict() {
  rm -rf "$HOME/.config/zsh"
  ln -s ../dotfiles/dotfiles-public/zsh/.config/zsh "$HOME/.config/zsh"
  rm -f "$HOME/.zshrc"
  echo "# réécrit par un installeur" >"$HOME/.zshrc"
  if make -s unfold >/dev/null 2>&1; then echo "unfold aurait dû échouer"; return 1; fi
  [ -L "$HOME/.config/zsh" ] && [ -r "$HOME/.config/zsh/zinit.sh" ] || { echo "lien non remis"; ls -la "$HOME/.config"; return 1; }
  rm -f "$HOME/.zshrc" # conflit résolu, pour le test suivant
}

# make unfold remplace un dossier replié (lien vers le repo) par un vrai dossier
unfold_replaces_folded_dir() {
  [ -L "$HOME/.config/zsh" ] || {
    rm -rf "$HOME/.config/zsh"
    ln -s ../dotfiles/dotfiles-public/zsh/.config/zsh "$HOME/.config/zsh"
  }
  make -s unfold >/dev/null || return 1
  [ -d "$HOME/.config/zsh" ] && [ ! -L "$HOME/.config/zsh" ] && [ -L "$HOME/.config/zsh/zinit.sh" ] ||
    { ls -la "$HOME/.config"; return 1; }
}

# Un module qui appelle compdef avant compinit voit sa complétion enregistrée
zsh_module_compdef_replayed() {
  local rc
  echo 'compdef _files dotfiles-fakecmd' >"$HOME/.config/shell/local.d/test-compdef.sh"
  in_tty "zsh -ic '[[ \$_comps[dotfiles-fakecmd] == _files ]]'"
  rc=$?
  rm -f "$HOME/.config/shell/local.d/test-compdef.sh"
  return "$rc"
}

# zinit.sh ne charge zinit que si make zsh-plugins a posé son marqueur
# (sinon zinit retenterait les téléchargements à chaque démarrage)
zinit_gated_by_marker() {
  local zdir="$HOME/.local/share/zinit" out rc=0
  mkdir -p "$zdir/zinit.git"
  printf 'zinit() { :; }\necho zinit-charge\n' >"$zdir/zinit.git/zinit.zsh"
  out=$(in_tty "zsh -ic true")
  [ -z "$out" ] || { echo "sans marqueur : $out"; rc=1; }
  touch "$zdir/.dotfiles-ready"
  out=$(in_tty "zsh -ic true")
  [ "$out" = zinit-charge ] || { echo "avec marqueur : '$out'"; rc=1; }
  rm -rf "$zdir"
  return "$rc"
}

# make karabiner : ~/.config/karabiner est un lien de dossier (Karabiner ne suit pas
# un karabiner.json en lien) ; un dossier existant est sauvegardé ; relance sans effet
karabiner_dir_link() {
  local k="$HOME/.config/karabiner" src="$PWD/karabiner/.config/karabiner"
  mkdir -p "$k" && echo '{}' >"$k/karabiner.json"
  make -s karabiner >/dev/null || return 1
  [ -L "$k" ] && [ "$k" -ef "$src" ] || { echo "pas un lien vers le repo"; return 1; }
  [ -f "$k.pre-dotfiles/karabiner.json" ] || { echo "dossier existant non sauvegardé"; return 1; }
  make -s karabiner | grep -q 'déjà lié' || { echo "relance non idempotente"; return 1; }
  rm "$k" && rm -rf "$k.pre-dotfiles"
}

# make clean-links retire les liens morts vers le repo, et seulement eux
clean_links_only_repo() {
  local rc=0
  ln -s ../../dotfiles/dotfiles-public/shell/.config/shell/tools.d/disparu.sh "$HOME/.config/shell/tools.d/disparu.sh"
  ln -s /nulle/part "$HOME/.config/lien-etranger"
  make -s clean-links >/dev/null
  [ ! -L "$HOME/.config/shell/tools.d/disparu.sh" ] || { echo "lien mort vers le repo conservé"; rc=1; }
  [ -L "$HOME/.config/lien-etranger" ] || { echo "lien étranger supprimé"; rc=1; }
  rm -f "$HOME/.config/lien-etranger"
  return "$rc"
}

# make uninstall ne laisse aucun lien vers le repo
uninstall_removes_all_links() {
  local left
  make -s uninstall >/dev/null 2>&1
  left=$(find "$HOME" -type l -lname '*dotfiles-public*' 2>/dev/null)
  [ -z "$left" ] || { echo "liens restants :"; echo "$left"; return 1; }
}

# Le cache de complétion ne doit pas être reconstruit à chaque démarrage. Sur Ubuntu,
# /etc/zsh/zshrc lance son compinit avant le nôtre, avec un autre fpath (plugins) :
# sans skip_global_compinit (~/.zshenv), les deux se renvoient la reconstruction.
zsh_compdump_stable() {
  local dump before after rc=0
  dump="$HOME/.cache/zsh/zcompdump-$(zsh -fc 'echo $ZSH_VERSION')"
  rm -f "$HOME/.zcompdump"
  mkdir -p "$HOME/.fake-completions"
  printf '#compdef dotfiles-fake\n_files\n' >"$HOME/.fake-completions/_dotfiles_fake"
  echo 'fpath=("$HOME/.fake-completions" $fpath)' >"$HOME/.config/shell/local.d/test-fpath.sh"
  in_tty "zsh -ic true" >/dev/null
  before=$(cksum <"$dump" 2>/dev/null)
  sleep 1
  in_tty "zsh -ic true" >/dev/null
  after=$(cksum <"$dump" 2>/dev/null)
  [ -n "$before" ] && [ "$before" = "$after" ] || { echo "zcompdump reconstruit au 2e démarrage"; rc=1; }
  [ ! -e "$HOME/.zcompdump" ] || { echo "compinit global (/etc/zsh/zshrc) lancé en plus du nôtre"; rc=1; }
  rm -rf "$HOME/.fake-completions" "$HOME/.config/shell/local.d/test-fpath.sh"
  return "$rc"
}

# Un vrai fichier à la place d'un lien (créé par l'application ou `git config --global`)
# est sauvegardé en .pre-dotfiles au lieu de bloquer stow
stow_backs_up_real_file() {
  local target=$1 file=$2 dir
  dir=$(dirname "$target/$file")
  rm -f "$target/$file" && mkdir -p "$dir" && echo '{"local": true}' >"$target/$file"
  make -s "$3" >/dev/null || return 1
  [ -L "$target/$file" ] || { echo "$target/$file n'est pas un lien"; return 1; }
  grep -q local "$target/$file.pre-dotfiles" || { echo "sauvegarde absente"; return 1; }
  rm -f "$target/$file.pre-dotfiles"
}

# Valeur d'un réglage du settings.json généré (JSONC : en-tête de commentaires)
vscode_get() {
  node -e 'const fs=require("fs"); const s=new Function("return ("+fs.readFileSync(process.argv[1],"utf8")+"\n)")();
    const v=s[process.argv[2]]; console.log(v===undefined?"<absent>":JSON.stringify(v))' "$HOME/.config/Code/User/settings.json" "$1"
}

# Couche de contexte : étend un objet, remplace une valeur, supprime avec null
vscode_settings_layers() {
  local d="$HOME/.config/vscode/settings.d" rc=0
  mkdir -p "$d"
  cat >"$d/50-test.json" <<'LAYER'
// couche de test
{ "editor.tabSize": 8, "[typescript]": { "editor.tabSize": 3 }, "files.trimTrailingWhitespace": null, }
LAYER
  make -s vscode >/dev/null || return 1
  [ ! -L "$HOME/.config/Code/User/settings.json" ] || { echo "settings.json est encore un lien"; rc=1; }
  [ "$(vscode_get editor.tabSize)" = 8 ] || { echo "tabSize = $(vscode_get editor.tabSize)"; rc=1; }
  [ "$(vscode_get '[typescript]')" = '{"editor.defaultFormatter":"esbenp.prettier-vscode","editor.tabSize":3}' ] ||
    { echo "[typescript] = $(vscode_get '[typescript]')"; rc=1; }
  [ "$(vscode_get files.trimTrailingWhitespace)" = "<absent>" ] || { echo "null n'a pas supprimé"; rc=1; }
  rm -rf "$HOME/.config/vscode"
  return "$rc"
}

# Une modification faite depuis l'interface (fichier généré édité) est sauvegardée
vscode_settings_drift_backup() {
  local f="$HOME/.config/Code/User/settings.json"
  make -s vscode >/dev/null || return 1
  sed -i 's/"editor.tabSize": 2/"editor.tabSize": 4/' "$f"
  make -s vscode >/dev/null || return 1
  grep -q '"editor.tabSize": 4' "$f.pre-dotfiles" || { echo "modification non sauvegardée"; return 1; }
  grep -q '"editor.tabSize": 2' "$f" || { echo "fichier non régénéré"; return 1; }
  rm -f "$f.pre-dotfiles"
}

# Session bash interactive réelle (pseudo-terminal), commandes lues sur l'entrée ;
# sortie sans couleurs ni marqueurs \001 \002
bash_session() {
  printf '%s\n' "$@" exit | LANG=C.UTF-8 script -qec "bash -i" /dev/null |
    tr -d '\r\001\002' | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g'
}

# Prompt : branche, *, ⇡ (en avance sur la branche distante), seulement git via _prompt_git
prompt_git_info() {
  local r out rc=0
  r=$(mktemp -d)
  git init -q --bare "$r/remote.git"
  git clone -q "$r/remote.git" "$r/w" 2>/dev/null
  cd "$r/w" || return 1
  git config user.email t@example.com && git config user.name t
  git commit -q --allow-empty -m 1 && git push -q origin HEAD 2>/dev/null
  git commit -q --allow-empty -m 2 && echo x >f
  out=$(LANG=C.UTF-8 bash -c '. ~/.config/bash/prompt.bash; _prompt_git' | tr -d '\001\002' | sed 's/\x1b\[[0-9;]*m//g')
  [ "$out" = " main* ⇡1" ] || { echo "_prompt_git = '$out'"; rc=1; }
  git config bash.showDirtyState false
  out=$(bash -c '. ~/.config/bash/prompt.bash; _prompt_git' | tr -d '\001\002' | sed 's/\x1b\[[0-9;]*m//g')
  [ "$out" = " main" ] || { echo "showDirtyState=false : '$out'"; rc=1; }
  cd - >/dev/null || return 1
  return "$rc"
}

# Une branche nommée « $(commande) » s'affiche, n'est pas exécutée
prompt_branch_not_executed() {
  local r
  r=$(mktemp -d) && cd "$r" && git init -q && git -c user.email=t@e -c user.name=t commit -q --allow-empty -m i
  git checkout -q -b '$(touch${IFS}/tmp/prompt-pwned)' || { echo "git refuse le nom"; return 1; }
  cd - >/dev/null || return 1
  bash_session "cd $r" | grep -qF '$(touch${IFS}/tmp/prompt-pwned)' || { echo "branche non affichée"; return 1; }
  [ ! -e /tmp/prompt-pwned ] || { echo "commande du nom de branche exécutée"; return 1; }
}

# Durée d'une commande longue, ❯ après une réussite ou un échec
prompt_duration() {
  bash_session "sleep 5" | grep -qE ' [56]s$' || { echo "durée absente"; return 1; }
}

base_cmds="mkcd ll la extract h g git-ls"

echo "== Installation"
check "make minimal" make minimal
check "make unfold : annule tout en cas de conflit" unfold_rolls_back_on_conflict
check "make unfold : déplie un dossier replié" unfold_replaces_folded_dir
check "make vscode : keybindings.json existant sauvegardé" stow_backs_up_real_file "$HOME/.config/Code/User" keybindings.json vscode
check "make vscode : settings.json fusionné par couches" vscode_settings_layers
check "make vscode : réglage modifié depuis l'interface sauvegardé" vscode_settings_drift_backup
check "make git : ~/.config/git/config existant sauvegardé" stow_backs_up_real_file "$HOME/.config/git" config git
check "make karabiner : lien de dossier, sauvegarde, idempotent" karabiner_dir_link
check "make clean-links : seulement les liens morts vers le repo" clean_links_only_repo

echo "== Bash"
check "bash interactif : démarre sans sortie" silent "bash -ic true"
check "bash login : démarre sans sortie" silent "bash -lic true"
check "bash : rechargement sans sortie" silent "bash -ic '. ~/.bashrc'"
check "bash : commandes de base ($base_cmds)" in_tty "bash -ic 'type $base_cmds >/dev/null'"
check "bash : complétion chargée (bash-completion, comme le .bashrc d'Ubuntu)" in_tty "bash -ic 'type _init_completion >/dev/null'"
check "bash : ls fonctionne" in_tty "bash -ic 'ls / >/dev/null'"
check "bash : aucun alias vers un autre outil" no_tool_swapping_alias bash
check "bash : mkcd sans sortie (malgré mkdir -pv)" silent "bash -ic 'mkcd /tmp/mkcd-bash/a'"
check "bash : prompt (branche, *, ⇡, showDirtyState)" prompt_git_info
check "bash : prompt, nom de branche piégé non exécuté" prompt_branch_not_executed
check "bash : prompt, durée d'une commande longue" prompt_duration
check "bash : module actif si l'outil est installé" module_activated_when_installed bash
check "bash : DOTFILES_DEBUG liste les fichiers" debug_lists_files

echo "== Zsh"
check "zsh interactif : démarre sans sortie" silent "zsh -ic true"
check "zsh : commandes de base ($base_cmds)" in_tty "zsh -ic 'type $base_cmds >/dev/null'"
check "zsh : ls fonctionne" in_tty "zsh -ic 'ls / >/dev/null'"
check "zsh : aucun alias vers un autre outil" no_tool_swapping_alias zsh
check "zsh : module actif si l'outil est installé" module_activated_when_installed zsh
check "zsh : complétion d'un module rejouée après compinit" zsh_module_compdef_replayed
check "zsh : plugins chargés seulement après make zsh-plugins" zinit_gated_by_marker
check "zsh : cache de complétion stable entre deux démarrages" zsh_compdump_stable
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

echo "== Contexte (proxy, secret, modèle de dotfiles-private)"

# Shell non interactif avec la config chargée (pour tester des fonctions)
with_config() {
  bash -c ". ~/.config/shell/init.sh; $1"
}

proxy_on_off() {
  with_config 'proxy on 2>/dev/null && exit 1
    DOTFILES_PROXY_URL=http://p.example:3128; proxy on
    [ "$https_proxy" = http://p.example:3128 ] && [ "$no_proxy" = localhost,127.0.0.1 ] || exit 1
    proxy off; [ -z "${https_proxy-}" ] && proxy status | grep -q inactif'
}

# secret / with_secret, avec un faux secret-tool qui range les secrets dans un fichier
secret_roundtrip() {
  local rc
  mkdir -p "$HOME/.local/bin"
  cat >"$HOME/.local/bin/secret-tool" <<'FAKE'
#!/bin/sh
f="$HOME/.fake-secrets"; cmd=$1; name=""
while [ $# -gt 0 ]; do [ "$1" = name ] && name=$2; shift; done
case $cmd in
  store) IFS= read -r v; printf '%s=%s\n' "$name" "$v" >>"$f" ;;
  lookup) grep "^$name=" "$f" 2>/dev/null | tail -n 1 | cut -d= -f2- | grep . ;;
  clear) grep -v "^$name=" "$f" >"$f.tmp"; mv "$f.tmp" "$f" ;;
esac
FAKE
  chmod +x "$HOME/.local/bin/secret-tool"
  with_config 'printf "s3cr3t\n" | secret set jeton
    [ "$(secret get jeton)" = s3cr3t ] || { echo "secret get"; exit 1; }
    with_secret MON_JETON jeton sh -c "[ \"\$MON_JETON\" = s3cr3t ]" || { echo "with_secret"; exit 1; }
    [ -z "${MON_JETON-}" ] || { echo "jeton exporté dans le shell"; exit 1; }
    secret rm jeton; with_secret X jeton true 2>/dev/null && { echo "secret non supprimé"; exit 1; }
    exit 0'
  rc=$?
  rm -f "$HOME/.local/bin/secret-tool" "$HOME/.fake-secrets"
  return "$rc"
}

# Le modèle de dotfiles-private s'installe et remplit les emplacements prévus
template_context() {
  local ctx=$1 email=$2 rc=0
  (cd private-template && stow common "$ctx") || return 1
  silent "bash -ic true" || rc=1
  [ "$(git config user.email)" = "$email" ] || { echo "user.email = $(git config user.email)"; rc=1; }
  if [ "$ctx" = pro ]; then
    in_tty "bash -ic 'proxy status'" | grep -q 'proxy actif : http://proxy.entreprise.example' || { echo "proxy pro inactif"; rc=1; }
  fi
  (cd private-template && stow -D common "$ctx")
  return "$rc"
}

check "proxy on / off / status" proxy_on_off
check "secret set / get / rm et with_secret" secret_roundtrip
check "modèle privé : contexte perso" template_context perso prenom.nom@example.org
check "modèle privé : contexte pro (proxy actif)" template_context pro prenom.nom@entreprise.example

echo "== Désinstallation"
check "make uninstall : plus aucun lien vers le repo" uninstall_removes_all_links

echo
if [ "$failures" -eq 0 ]; then
  echo "Tout est vert."
else
  echo "$failures échec(s)."
  exit 1
fi
