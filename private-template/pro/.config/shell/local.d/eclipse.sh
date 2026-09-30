# Eclipse de l'atelier Java
[ -d "$HOME/soda/atelierjava/jdk/ide/v2020_06/eclipse" ] || return 0

export ECLIPSE_INSTALL="$HOME/soda/atelierjava/jdk/ide/v2020_06/eclipse"
path_prepend "$ECLIPSE_INSTALL"
