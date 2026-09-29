# Karabiner-Elements : remappage clavier macOS
[ -d /Applications/Karabiner-Elements.app ] || return 0

alias reset-karabiner='launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server'
