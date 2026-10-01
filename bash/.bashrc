# Bash : seulement ce qui est propre à bash. Le reste est dans ~/.config/shell/ (init.sh)
case $- in *i*) ;; *) return ;; esac # interactif uniquement

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh"
else
  echo "dotfiles : ~/.config/shell/init.sh introuvable (make bash depuis le repo dotfiles-public)" >&2
fi

# Complétion (bash-completion) : ~/.config/bash/pre-tools.bash, chargé par init.sh

# ─── Options ────────────────────────────────────────────────────────────────
set -o noclobber
shopt -s checkwinsize

# bash 4+ uniquement (macOS fournit bash 3.2)
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s autocd
  shopt -s cdspell
fi

# ─── Historique ─────────────────────────────────────────────────────────────
HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:cd:cd -:pwd:exit:clear:history:git status:git st"
HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ─── Prompt ─────────────────────────────────────────────────────────────────
# Style « pure », comme le prompt zsh (cf. ~/.config/bash/prompt.bash). En dernier
# avant les raccourcis : il se place en tête de PROMPT_COMMAND pour lire le code de retour.
[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash/prompt.bash" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/bash/prompt.bash"

# ─── Raccourcis ─────────────────────────────────────────────────────────────
alias reload='. ~/.bashrc'
alias edit='"$EDITOR" ~/.bashrc'

# macOS : pas de message « le shell par défaut est maintenant zsh »
case "$OSTYPE" in darwin*) export BASH_SILENCE_DEPRECATION_WARNING=1 ;; esac
