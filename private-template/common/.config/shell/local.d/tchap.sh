# Tchap : variables d'accès (fichier hors repo). Si elles ne servent qu'à une commande,
# préférer un wrapper with_secret (cf. secrets.sh) pour ne pas les exporter partout.
[ -r "$XDG_CONFIG_HOME/tchap/secrets.env" ] || return 0

. "$XDG_CONFIG_HOME/tchap/secrets.env"
