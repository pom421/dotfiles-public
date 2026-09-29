# AeroSpace : gestionnaire de fenêtres macOS
command -v aerospace >/dev/null 2>&1 || return 0

alias aero='killall AeroSpace && open /Applications/AeroSpace.app'
alias reset-aero='aerospace enable off && aerospace enable on'
