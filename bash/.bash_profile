# Shell de login bash (Terminal macOS, ssh) : même config qu'un shell interactif
[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Vite+ bin (https://viteplus.dev), seulement s’il est installé (absent sous Linux)
[ -r "$HOME/.config/vite-plus/env" ] && . "$HOME/.config/vite-plus/env"
