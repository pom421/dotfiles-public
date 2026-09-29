# Chargeur commun, sourcé par ~/.bashrc et ~/.zshrc.
#
# Ordre de chargement :
#   core/*.sh     socle sans dépendance, identique partout
#   os/<os>.sh    darwin ou linux (dont Homebrew, pour que tools.d trouve ses outils)
#   tools.d/*.sh  un fichier par outil, qui ne fait rien si l'outil est absent
#   local.d/*.sh  propre à la machine ou au contexte (perso/pro), fourni par dotfiles-private
#
# Règles pour un module de tools.d :
#   - 1re ligne : garde `command -v X >/dev/null 2>&1 || return 0`
#   - aucune sortie, pas de réseau
#   - pas d'alias qui masque une commande standard (ls, cat, find, rm…)
#   - pas de setopt/shopt : les options du shell vont dans bash/ et zsh/
#
# Diagnostic : DOTFILES_DEBUG=1 zsh -i -c exit   (liste les fichiers chargés)

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Shell courant, pour les outils qui s'initialisent différemment (zoxide init bash|zsh…)
if [ -n "${ZSH_VERSION-}" ]; then
  DOTFILES_SHELL='zsh'
elif [ -n "${BASH_VERSION-}" ]; then
  DOTFILES_SHELL='bash'
else
  DOTFILES_SHELL='sh'
fi

case "${OSTYPE-}" in
  darwin*) _dotfiles_os=darwin ;;
  linux*) _dotfiles_os=linux ;;
  *) _dotfiles_os=unknown ;;
esac

_dotfiles_dir="$XDG_CONFIG_HOME/shell"

# zsh : un dossier vide (local.d) ne doit pas lever « no matches found »
[ "$DOTFILES_SHELL" = zsh ] && setopt null_glob

for _dotfiles_f in \
  "$_dotfiles_dir"/core/*.sh \
  "$_dotfiles_dir/os/$_dotfiles_os.sh" \
  "$_dotfiles_dir"/tools.d/*.sh \
  "$_dotfiles_dir"/local.d/*.sh; do
  [ -r "$_dotfiles_f" ] || continue
  [ -n "${DOTFILES_DEBUG-}" ] && printf 'dotfiles: %s\n' "$_dotfiles_f" >&2
  . "$_dotfiles_f"
done

[ "$DOTFILES_SHELL" = zsh ] && unsetopt null_glob

unset _dotfiles_dir _dotfiles_os _dotfiles_f
