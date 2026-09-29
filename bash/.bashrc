# Bash : seulement ce qui est propre à bash. Le reste est dans ~/.config/shell/ (init.sh)
case $- in *i*) ;; *) return ;; esac # interactif uniquement

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/init.sh"
else
  echo "dotfiles : ~/.config/shell/init.sh introuvable (make bash depuis le repo dotfiles-public)" >&2
fi

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
gitbranch() {
  git branch 2>/dev/null | awk '/^\*/ { print " ("$2")" }'
}
PS1='\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;33m\]$(gitbranch)\[\e[0m\] $ '

# ─── Raccourcis ─────────────────────────────────────────────────────────────
alias reload='. ~/.bashrc'
alias edit='"$EDITOR" ~/.bashrc'

# macOS : pas de message « le shell par défaut est maintenant zsh »
case "$OSTYPE" in darwin*) export BASH_SILENCE_DEPRECATION_WARNING=1 ;; esac
