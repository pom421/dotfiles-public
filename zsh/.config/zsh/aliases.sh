alias ls="ls -GFh --color"
alias ll="ls -alGFh --color"
alias ..="cd .."
alias ...=".. && .."
alias cat="bat"
#alias find="fd"
alias brewup='brew update; brew upgrade; brew cleanup; brew doctor'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias fabric='fabric-ai'
alias aero="killall AeroSpace && open /Applications/AeroSpace.app"
alias reset-aero="aerospace enable off && aerospace enable on"
alias reset-karabiner="launchctl kickstart -k gui/`id -u`/org.pqrs.service.agent.karabiner_console_user_server"
alias lg="lazygit"

alias sz="source ~/.zshrc"
alias ez="nvim ~/.zshrc"

alias dpu="cd ~/dotfiles/dotfiles-public/"
alias dpr="cd ~/dotfiles/dotfiles-private/"
alias stow="stow -t ~"
