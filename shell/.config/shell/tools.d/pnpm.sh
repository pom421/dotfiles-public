# pnpm : binaires globaux dans PNPM_HOME
case "$OSTYPE" in
  darwin*) export PNPM_HOME="$HOME/Library/pnpm" ;;
  *) export PNPM_HOME="$XDG_DATA_HOME/pnpm" ;;
esac
[ -d "$PNPM_HOME" ] || { unset PNPM_HOME; return 0; }

path_prepend "$PNPM_HOME"
