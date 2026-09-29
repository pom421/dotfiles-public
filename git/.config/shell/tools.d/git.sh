# git : raccourcis shell (la config git est dans ~/.config/git/)
command -v git >/dev/null 2>&1 || return 0

# g : git status court sans argument, sinon git <commande>
# (syntaxe `function` obligatoire : avec g() {, zsh échoue sur l'alias g du plugin OMZ git
# au rechargement, « defining function based on alias », et ignore la suite du fichier)
function g {
  if [ $# -gt 0 ]; then
    git "$@"
  else
    git status -s -b
  fi
}

# Dernière activité de chaque branche
git-ls() {
  git for-each-ref --sort=-committerdate --format='%(refname:short) last activity was %(committerdate:relative)' refs/heads refs/remotes
}
