# Homebrew : le PATH est posé par os/<os>.sh, ici seulement le confort
command -v brew >/dev/null 2>&1 || return 0

export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brew/Brewfile"
alias brewup='brew update && brew upgrade && brew cleanup && brew doctor'
