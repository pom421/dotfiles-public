# macOS

# ls : -G couleurs (BSD), -F suffixe de type (/ * @)
alias ls='ls -GF'

# Homebrew en premier : les modules de tools.d trouvent ainsi les outils installés par brew
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv "$DOTFILES_SHELL")"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv "$DOTFILES_SHELL")"
fi
