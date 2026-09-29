# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# mkdir + cd
mkcd() {
  command mkdir -p -- "$1" && cd -P -- "$1" || return
}
