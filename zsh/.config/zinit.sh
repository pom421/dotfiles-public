export ZSH_CACHE_DIR="${HOME}/.cache/zinit"
# Zinit is a plugin manager for zsh
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
[ -n "$ZSH_CACHE_DIR" ] && [ ! -d "$ZSH_CACHE_DIR" ] && mkdir -p "$ZSH_CACHE_DIR/completions"

source "${ZINIT_HOME}/zinit.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /Users/pom/.docker/init-zsh.sh || true # Added by Docker Desktop

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Load completions
autoload -U compinit && compinit
# add autocompletion for sqlite-utils
eval "$(_SQLITE_UTILS_COMPLETE=zsh_source sqlite-utils)"

# Completion styling
zstyle ":completion:*" matcher-list 'm:{a-z}={A-Z}'
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no
zstyle ":fzf-tab:complete:cd:*" fzf-preview "ls --color $realpath"

