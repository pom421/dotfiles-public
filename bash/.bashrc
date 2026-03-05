# Source configuration commune
if [ -d "$HOME/.config/shell" ]; then
  for f in "$HOME/.config/shell"/*.sh; do source "$f"; done
else
  echo "Erreur: Le répertoire $HOME/.config/shell n'existe pas. Utilisez: stow -t $HOME shell"
  return 1
fi

# Bash-spécifique
alias sb="source ~/.bashrc"
alias eb="nvim ~/.bashrc"
eval "$(fzf --bash)"

[ -f /Users/pom/.docker/init-bash.sh ] && source /Users/pom/.docker/init-bash.sh 

# CapsLock = escape
setxkbmap -option caps:escape
# ---------------------------------
# ─── Options ────────────────────────────────────────────────────────────────

set -o noclobber # évite d'écraser un fichier avec >
shopt -s autocd # tape un chemin pour y aller directement
shopt -s cdspell # corrige les petites fautes de frappe dans cd
shopt -s checkwinsize # met à jour LINES/COLUMNS après chaque commande
shopt -s histappend # ajoute à l'historique sans l'écraser

# ─── Historique ─────────────────────────────────────────────────────────────

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth # ignore les doublons et les lignes avec espace

# ─── Prompt ─────────────────────────────────────────────────────────────────

# user@host:dir (branche git si dispo) $
gitbranch() {
  git branch 2>/dev/null | awk '/^*/ { print " ("$2")" }'
}

PS1='\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;33m\]$(gitbranch)\[\e[0m\] $ '

# ─── Aliases ─────────────────────────────────────────────────────────────────

alias ls='ls --color=auto'
alias ll='ls -lAh --group-directories-first'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'


# ─── PATH ────────────────────────────────────────────────────────────────────

export PATH="$HOME/.local/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export ECLIPSE_INSTALL="$HOME/soda/atelierjava/jdk/ide/v2020_06/eclipse"
export PATH="$BUN_INSTALL/bin:$ECLIPSE_INSTALL:$PATH"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Pour Rust/cargo
. "$HOME/.cargo/env"

# ─── Fonctions utiles ────────────────────────────────────────────────────────

# Crée un dossier et s'y déplace

mkcd() { mkdir -p "$1" && cd "$1"; }


# Git wrapper
g(){
  if "$1"; then 
    git "$1"
  else
    git status
  fi
}

# Yazi wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


# Extrait n'importe quelle archive

extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2|*.tbz) tar xjf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.gz) gunzip "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.xz) unxz "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Format non reconnu : $1" ;;
  esac
}

# Cherche dans l'historique

h() { history | grep "$1"; }
