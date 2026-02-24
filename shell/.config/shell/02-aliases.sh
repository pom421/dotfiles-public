#!/bin/sh

# Dotfiles
alias dpu="cd $DOTPUB"
alias dpr="cd $DOTPRIV"
alias stow="stow -t $HOME"


alias ..="cd .."
alias ...=".. && .."

alias ls="ls -GFh --color"
alias ll="ls -alGFh --color"
command -v trash &>/dev/null && alias rm='trash'

# Smart commands
command -v bat &> /dev/null && alias cat="bat"
command -v fd &> /dev/null && alias find="fd"
command -v brew &> /dev/null && alias brewup='brew update; brew upgrade; brew cleanup; brew doctor'
command -v lazygit &> /dev/null && alias lg="lazygit"

# MacOS only
if [ "$OSTYPE" = "darwin" ]; then
    alias aero="killall AeroSpace && open /Applications/AeroSpace.app"
    alias reset-aero="aerospace enable off && aerospace enable on"
    alias reset-karabiner="launchctl kickstart -k gui/`id -u`/org.pqrs.service.agent.karabiner_console_user_server"
fi
