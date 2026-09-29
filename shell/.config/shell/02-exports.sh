# XDG Base Directory Specification
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export DOTPUB="$HOME/dotfiles/dotfiles-public/"
export DOTPRIV="$HOME/dotfiles/dotfiles-private/"

# Premier éditeur disponible (git s'en sert pour les messages de commit)
for EDITOR in nvim vim vi nano; do
  command -v "$EDITOR" >/dev/null 2>&1 && break
done
export EDITOR
export VISUAL="$EDITOR"
export GPG_TTY=$(tty)
export HOMEBREW_BUNDLE_FILE="$HOME/.config/brew/Brewfile"

