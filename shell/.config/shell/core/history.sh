# Cherche dans l'historique (fc marche pareil en bash et zsh)
h() {
  fc -l 1 | grep -- "$1"
}
