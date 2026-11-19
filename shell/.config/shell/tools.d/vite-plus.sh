# Vite+ (vp) : shims (node, pnpm, CLI globaux…) dans ~/.local/share/vite-plus/bin,
# PATH et complétion posés par le fichier env que crée `make vite-plus`
command -v vp >/dev/null 2>&1 || return 0
[ -r "$XDG_CONFIG_HOME/vite-plus/env" ] || return 0

. "$XDG_CONFIG_HOME/vite-plus/env"
