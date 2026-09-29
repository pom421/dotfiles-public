# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# mkdir + cd
mkcd() {
  mkdir -p -- "$1" && cd -P -- "$1" || return
}
