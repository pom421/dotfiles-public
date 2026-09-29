# Linux

# ls : couleurs (GNU, comme le ~/.bashrc par défaut d'Ubuntu), -F suffixe de type (/ * @)
alias ls='ls -F --color=auto'

# Homebrew en premier : les modules de tools.d trouvent ainsi les outils installés par brew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv "$DOTFILES_SHELL")"
fi
