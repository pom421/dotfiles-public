# Karabiner-Elements : remappage clavier macOS (config : make karabiner, lien de dossier)
[ -d /Applications/Karabiner-Elements.app ] || return 0

alias reset-karabiner='launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server'
