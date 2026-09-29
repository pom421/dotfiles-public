# Tchap : variables d'accès (fichier hors repo). À remplacer par `secret` (phase 5)
[ -r "$XDG_CONFIG_HOME/tchap/secrets.env" ] || return 0

. "$XDG_CONFIG_HOME/tchap/secrets.env"
