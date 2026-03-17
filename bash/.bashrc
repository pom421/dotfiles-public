# Source configuration commune
if [ -d "$HOME/.config/shell" ]; then
  for f in "$HOME/.config/shell"/*.sh; do source "$f"; done
else
  echo "Erreur: Le répertoire $HOME/.config/shell n'existe pas. Utilisez: stow -t $HOME shell"
  return 1
fi

# ─── PATH ────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# macOS uniquement
if [[ "$OSTYPE" == "darwin"* ]]; then
  export ECLIPSE_INSTALL="$HOME/soda/atelierjava/jdk/ide/v2020_06/eclipse"
  export PATH="$ECLIPSE_INSTALL:$PATH"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# ─── Docker ──────────────────────────────────────────────────────────────────
# macOS uniquement
if [[ "$OSTYPE" == "darwin"* ]]; then
  [ -f /Users/pom/.docker/init-bash.sh ] && source /Users/pom/.docker/init-bash.sh
fi

# ─── Options ────────────────────────────────────────────────────────────────
set -o noclobber
shopt -s checkwinsize
shopt -s histappend

# bash 4+ uniquement
if (( BASH_VERSINFO[0] >= 4 )); then
  shopt -s autocd
  shopt -s cdspell
fi

# ─── Historique ─────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth

# ─── Prompt ─────────────────────────────────────────────────────────────────
gitbranch() {
  git branch 2>/dev/null | awk '/^*/ { print " ("$2")" }'
}
PS1='\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;33m\]$(gitbranch)\[\e[0m\] $ '

# ─── Aliases ────────────────────────────────────────────────────────────────
alias reload="source ~/.bashrc"
alias edit="nvim ~/.bashrc"
alias lls='ls'
alias ls='eza'
alias ll='eza -lah --group-directories-first'
alias la='eza -a'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# ─── Fonctions ───────────────────────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }

g() {
  if [ -n "$1" ]; then
    git "$1"
  else
    git status
  fi
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

extract() {
  case "$1" in
    *.tar.gz|*.tgz)  tar xzf "$1" ;;
    *.tar.bz2|*.tbz) tar xjf "$1" ;;
    *.tar.xz)        tar xJf "$1" ;;
    *.tar)           tar xf  "$1" ;;
    *.zip)           unzip   "$1" ;;
    *.gz)            gunzip  "$1" ;;
    *.bz2)           bunzip2 "$1" ;;
    *.xz)            unxz    "$1" ;;
    *.7z)            7z x    "$1" ;;
    *)               echo "Format non reconnu : $1" ;;
  esac
}

h() { history | grep "$1"; }

# ─── Divers ──────────────────────────────────────────────────────────────────
# macOS uniquement
if [[ "$OSTYPE" == "darwin"* ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
fi

