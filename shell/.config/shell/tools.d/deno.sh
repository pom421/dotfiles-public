# deno : binaires installés par `deno install`
[ -d "$HOME/.deno/bin" ] || return 0

path_prepend "$HOME/.deno/bin"
