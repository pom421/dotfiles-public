# Lu par tous les zsh, avant /etc/zsh/zshrc.
# Ubuntu/Debian : /etc/zsh/zshrc lance compinit avant ~/.zshrc, avec un fpath sans
# les plugins ; les deux compinit se renvoyaient la reconstruction du cache de
# complétion à chaque démarrage (≈ 0,5 s). ~/.zshrc lance compinit lui-même.
skip_global_compinit=1
