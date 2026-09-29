# Ajoute un dossier en tête du PATH, s'il existe et n'y est pas déjà.
# Disponible pour tous les modules (core est chargé en premier).
path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
  export PATH
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/lab/scripts"
