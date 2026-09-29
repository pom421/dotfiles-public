# Plugins zsh (zinit). Téléchargés par `make zsh-plugins`, jamais au démarrage du shell :
# zinit retente à chaque démarrage un plugin qui manque, ce qui bloque derrière un proxy.
# Le marqueur .dotfiles-ready n'est posé qu'une fois tous les plugins présents ; sans
# lui (machine de formation, hors ligne), zsh démarre nu mais propre.
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]] || [[ ! -e "${ZINIT_HOME:h}/.dotfiles-ready" && -z "${DOTFILES_ZINIT_INSTALL-}" ]]; then
  PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '
  return 0
fi

export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zinit"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || command mkdir -p "$ZSH_CACHE_DIR/completions"

source "$ZINIT_HOME/zinit.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# powerlevel10k is a zsh theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# plugin zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab


zinit snippet OMZP::git
zinit snippet OMZP::command-not-found
zinit snippet OMZP::ansible
zinit snippet OMZP::gh
# Patch: prevent error if _gh completion file is missing
#if [[ -f "$HOME/.cache/zinit/completions/_gh" ]]; then
#  fpath=($HOME/.cache/zinit/completions $fpath)
#  autoload -Uz _gh && compdef _gh gh
#fi

# add gitignore by using `gi node`
zinit snippet OMZP::gitignore
zinit snippet OMZP::ssh
## Type Esc ESC to add sudo to the start of the command line
zinit snippet OMZP::sudo
# show tldr doc for command by using Esc + tldr
zinit snippet OMZP::tldr
zinit snippet OMZP::chezmoi
