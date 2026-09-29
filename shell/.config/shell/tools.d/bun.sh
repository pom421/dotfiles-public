# bun : runtime JavaScript, binaires globaux dans ~/.bun/bin
[ -d "$HOME/.bun" ] || return 0

export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"
