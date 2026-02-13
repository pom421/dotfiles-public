# Source configuration commune
if [ -d "$HOME/.config/shell" ]; then
    for f in "$HOME/.config/shell"/*.sh; do source "$f"; done
else
    echo "Erreur: Le répertoire $HOME/.config/shell n'existe pas. Utilisez: stow -t \$HOME shell"
    return 1
fi

# Bash-spécifique
alias sb="source ~/.bashrc"
alias eb="nvim ~/.bashrc"
eval "$(fzf --bash)"

source /Users/pom/.docker/init-bash.sh || true # Added by Docker Desktop
