# Neovim entretien

*v1 · 2026-11-14* — Commandes `make` : à la racine de `dotfiles-public` · config : `nvim/.config/nvim/` du repo

---

**nvim · entretien**

## Après un git pull

| Touche | Action |
|---|---|
| `make nvim-sync` | tout caler sur la config |

Enchaîne : liens de config (stow), liens morts retirés, plugins au commit de `lazy-lock.json`, outils Mason et parsers de la config. **Ce qui a été retiré de la config est désinstallé** (plugins, outils, parsers).

> **Exemple** : Rust retiré sur le Mac → `git pull` puis `make nvim-sync` sur le poste Ubuntu : rust-analyzer, rustaceanvim et le parser partent.

## Mettre à jour

| Touche | Action |
|---|---|
| `make nvim-update` | plugins et outils (+7 jours) |
| `NOW=snacks.nvim` | sans délai (faille de sécurité) |
| `make test-nvim` | banc Ubuntu (Docker, ~15 min) |
| `git commit` | `lazy-lock.json` + `cooldown.lua` |

**Délai de 7 jours** : seules les versions publiées depuis une semaine sont prises (attaque de la chaîne d'approvisionnement). Les autres machines suivent avec `make nvim-sync`.

## Ajouter un langage

| Touche | Action |
|---|---|
| `treesitter.lua` | parser → `languages` |
| `mason.lua` | serveur, formateur → `tools` |
| `lsp.lua` | serveur → `servers` |
| `conform.lua` | formateur par filetype |
| `make nvim-sync` | installer |
| `tests/nvim.sh` | un test, puis `make test-nvim` |

Noms : `:Mason` (paquets), `:h lspconfig-all` (serveurs). **Retirer** : l'enlever des listes, puis `make nvim-sync`.

## Diagnostiquer

| Touche | Action |
|---|---|
| `:checkhealth` | tout (long) |
| `:checkhealth vim.lsp` | serveurs LSP du buffer |
| `:ConformInfo` | formateurs du buffer |
| `:Mason` | outils installés |
| `:Lazy` | plugins, temps de chargement |
| `:messages` `␣un` | messages / notifications |
| `:lua =vim.bo.filetype` | filetype du buffer |
| `nvim --clean` | nvim sans config |

## Où sont les choses

| Touche | Action |
|---|---|
| `~/.config/nvim` | liens vers le repo (stow) |
| `~/.local/share/nvim/lazy` | plugins (150 Mo) |
| `…/nvim/mason` | outils (450 à 500 Mo) |
| `…/nvim/site/parser` | parsers (45 Mo) |
| `~/.local/state/nvim` | journaux (`lsp.log`…), undo |
| `~/.cache/nvim` | cache, effaçable |

## Réparer

| Touche | Action |
|---|---|
| `:TSSync` | réinstaller les parsers manquants |
| `:MasonSync` | idem pour les outils |
| `:Lazy restore` | plugins au commit du lock |

**Repartir de zéro** : `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim`, puis `make nvim-sync` (≈ 5 min).

## Pièges

**`:Lazy update` ne fait rien** : versions figées. Passer par `make nvim-update`.

**`:MasonInstall`, `:TSInstall` à la main** : pour essayer seulement. Absents de la config, ils sont retirés au prochain `make nvim-sync`.

**Brew à part** : nvim, node, ripgrep… viennent du Brewfile (`make brew`), sans délai de 7 jours.

**Ancien lien après un fichier supprimé** du repo : `make clean-links` (déjà fait par `make nvim-sync`).
