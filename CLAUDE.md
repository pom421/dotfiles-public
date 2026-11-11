# Dotfiles publics — règles

Repo public (Mac + Ubuntu 24.04) : jamais de contenu de `dotfiles-private` (contexte perso/pro, identités, chemins).
Fiches (cheatsheets) : voir `cheatsheets/CLAUDE.md`.

## Installation des outils
- **Toujours via brew** (`brew/.config/brew/Brewfile`), Mac et Linux, si la formule existe avec un bottle Linux
- Propre à un OS : bloc `if OS.mac?` / `if OS.linux?` du Brewfile
- apt seulement en dernier recours (formule absente), en le documentant
- Une config qui dépend d'un outil (ex. nvim-treesitter → `tree-sitter-cli`) l'ajoute au Brewfile dans le même commit

## Scripts
- **Bash ou TypeScript/Node uniquement** (pas de Python) : c'est ce que je sais relire
- TypeScript exécuté directement par Node (≥ 23.6), sans compilation ni dépendance npm (pas de `package.json`)
- Syntaxe effaçable seulement (pas d'`enum`, pas de `namespace`), imports locaux avec l'extension `.ts`
- Vérifier le typage en `--strict` avant de livrer
