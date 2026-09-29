# libpq (psql, pg_dump…) : formule brew « keg-only », absente du PATH par défaut
[ -d "${HOMEBREW_PREFIX-}/opt/libpq/bin" ] || return 0

path_prepend "$HOMEBREW_PREFIX/opt/libpq/bin"
