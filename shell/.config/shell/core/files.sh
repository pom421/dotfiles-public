# Fichiers. Alias autorisés : la même commande avec des options par défaut.
# Interdit : un autre outil à la place (ls=eza, cat=bat, find=fd…).
# Les fonctions des dotfiles appellent `command rm`, `command mkdir`… pour ne pas hériter de ces options.
alias ll='ls -alFh'
alias la='ls -A'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# Décompresse une archive selon son extension
extract() {
  case "$1" in
    *.tar.gz | *.tgz) tar xzf "$1" ;;
    *.tar.bz2 | *.tbz) tar xjf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.gz) gunzip "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.xz) unxz "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Format non reconnu : $1" >&2 && return 1 ;;
  esac
}
