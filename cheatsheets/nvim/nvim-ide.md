# Neovim IDE

*v2 · 2026-11-14* — Page 1/2 · `␣` = leader (Espace) · `C-x` = Ctrl+x · `␣?` = raccourcis du buffer · which-key s'ouvre après `␣`

---

**nvim · IDE**

## Code (LSP)

| Touche | Action |
|---|---|
| `K` | documentation au survol |
| `gd` | aller à la définition |
| `gD` | aller à la déclaration |
| `grr` | références |
| `gri` | implémentations |
| `grt` | définition du type |
| `gai` `gao` | appels entrants / sortants |
| `grn` `␣cr` | renommer partout |
| `gra` `␣ca` | actions (import, correctif…) |
| `gO` | symboles du fichier |
| `C-s` | signature (insertion) |
| `␣uh` | types inférés on/off |
| `C-o` `C-i` | revenir / repartir après un saut |

**Serveurs** : TS/JS `tsc` (TS 7) + `oxlint` · Python `ty` + `ruff` · Rust `rust-analyzer` · YAML, JSON (schémas) · Lua · Bash. Les autres occurrences du symbole sont surlignées.

## Diagnostics

| Touche | Action |
|---|---|
| `␣cd` | message complet de la ligne |
| `]d` `[d` | suivant / précédent (AZERTY) |
| `␣xx` | panneau, tout le projet |
| `␣xX` | panneau, fichier courant |
| `␣fd` `␣fD` | liste fichier / projet |
| `␣xl` | définitions, références (panneau) |
| `␣xq` `␣xL` | quickfix / liste locale |
| `␣xt` `␣st` | TODO, FIXME du projet |

## Complétion (insertion)

| Touche | Action |
|---|---|
| `C-espace` | ouvrir le menu |
| `C-j` `C-k` | proposition suivante / précédente |
| `Entrée` | valider |
| `C-e` | fermer le menu |
| `Tab` `S-Tab` | champ de snippet suivant / précédent |

Sources : LSP, chemins, snippets, mots du buffer ; aussi après `:`. La doc de la proposition s'affiche à côté.

## Rechercher (snacks)

| Touche | Action |
|---|---|
| `␣ff` | fichier par nom |
| `␣fg` | texte dans le projet |
| `␣fx` | mot sous le curseur / sélection |
| `␣fb` `␣fr` | buffers / fichiers récents |
| `␣f/` | lignes du buffer |
| `␣fs` `␣fS` | symboles fichier / projet |
| `␣fh` `␣fk` `␣fc` | aide, raccourcis, commandes |
| `␣fR` | reprendre la dernière recherche |
| `␣fp` | toutes les recherches |

**Dans la liste** : `C-j` `C-k` naviguer · `Tab` sélection multiple · `C-v` `C-s` ouvrir en split vertical / horizontal · `C-q` vers la quickfix.

**Essai** : mêmes recherches avec Telescope sous `␣F…` (`␣Ff` `␣Fg` `␣Fb` `␣Fx` `␣Fr` `␣Fs` `␣FR`).

## Remplacer dans le projet

| Touche | Action |
|---|---|
| `␣sr` | panneau rechercher / remplacer |
| `\r` | appliquer le remplacement |
| `\s` | reporter les lignes éditées |
| `g?` | aide du panneau |

Prérempli avec le mot sous le curseur (ou la sélection), limité aux fichiers du même type. `\` = localleader (AZERTY Mac : ⌥⇧/).

## Formater

| Touche | Action |
|---|---|
| `:w` | formate à l'enregistrement |
| `␣cf` | formater fichier / sélection |
| `gq` | formater un mouvement |
| `␣uf` | auto-formatage on/off (global) |
| `␣uF` | idem, ce buffer seulement |

JS/TS, JSON, YAML, TOML, CSS, Markdown : `oxfmt` (`vp fmt` dans un projet Vite+) · Python `ruff` · Lua `stylua` · shell `shfmt` · Rust `rustfmt`. Lint : `hadolint` (Dockerfile), `actionlint` (workflows GitHub).

## Plan du fichier

| Touche | Action |
|---|---|
| `␣co` | panneau « outline » à droite |
| `␣cn` | navigation dans le plan (popup) |
| `Entrée` | aller au symbole |
| `{` `}` | symbole précédent / suivant |

En haut de l'écran : signature de la fonction en cours (sticky scroll).

## Objets de texte

| Touche | Action |
|---|---|
| `af` `if` | fonction |
| `ac` `ic` | classe |
| `aa` `ia` | argument |
| `ai` `ii` | condition (if) |
| `al` `il` | boucle |
| `ih` | bloc modifié (git) |

> **Exemple** : `daf` supprime la fonction · `cia` réécrit l'argument · `vif` sélectionne le corps.

## Entourer, paires

| Touche | Action |
|---|---|
| `sa` | ajouter : `saiw"` |
| `sd` | supprimer : `sd(` |
| `sr` | remplacer : `sr"'` |

`` ( [ { " ' ` `` se ferment seuls. `s` seul (remplacer un caractère) attend un peu ; sans délai : `cl`.

## Replis

| Touche | Action |
|---|---|
| `za` | replier / déplier le bloc |
| `zM` `zR` | tout replier / déplier |

Blocs calculés par treesitter, tout déplié à l'ouverture.

---

**nvim · IDE**

## Git

| Touche | Action |
|---|---|
| `␣gg` | lazygit |
| `␣gl` `␣gf` | historique : dépôt / fichier |
| `␣gn` `␣gN` | bloc modifié suivant / précédent |
| `]h` `[h` | idem (AZERTY) |
| `␣gp` | aperçu du bloc (avant / après) |
| `␣gs` `␣gr` | indexer / annuler le bloc |
| `␣gS` `␣gR` | indexer / annuler le fichier |
| `␣gb` `␣gB` | blame : ligne / fichier |
| `␣ub` | blame en fin de ligne on/off |
| `␣go` | ouvrir sur GitHub / GitLab |

En visuel, `␣gs` `␣gr` ne traitent que la sélection.

## Diff (façon VS Code)

| Touche | Action |
|---|---|
| `␣gd` | modifications en cours |
| `␣gD` | index (ce qui sera commité) |
| `␣gm` | différences avec main |
| `␣gh` | historique des commits |
| `:CodeDiff pr 12` | revoir une pull request |

Côte à côte, surlignage au caractère près ; indexer un fichier ou un bloc depuis la liste ; résolution de conflits.

## Débogage

| Touche | Action |
|---|---|
| `F5` `␣dc` | lancer / continuer |
| `F9` `␣db` | point d'arrêt |
| `␣dB` | point d'arrêt conditionnel |
| `F10` `␣do` | pas à pas (sans entrer) |
| `F11` `␣di` | pas à pas (en entrant) |
| `S-F11` `␣dO` | sortir de la fonction |
| `␣dC` | continuer jusqu'au curseur |
| `␣de` | valeur sous le curseur |
| `␣dl` `␣dt` | relancer / arrêter |
| `␣du` | panneaux (variables, pile…) |

TS/JS : `node` (fichier courant, ou s'attacher à un `--inspect`) · Python : `debugpy`. Panneaux ouverts avec la session ; lettres de leur barre pour changer d'onglet.

## Tests

| Touche | Action |
|---|---|
| `␣tn` | test sous le curseur |
| `␣tf` `␣ta` | tests du fichier / du projet |
| `␣tl` | relancer le dernier |
| `␣td` | déboguer le test |
| `␣ts` | panneau des tests |
| `␣to` | sortie du test |
| `␣tw` | relancer à chaque modif |
| `␣tS` | arrêter |

vitest (`vp test` dans un projet Vite+) · pytest · cargo test. Résultat ✓ ✗ dans la gouttière.

## Terminal

| Touche | Action |
|---|---|
| `␣tt` | terminal flottant on/off |
| `Échap` `Échap` | mode normal (copier, défiler) |
| `q` | masquer (mode normal) |

## Markdown

| Touche | Action |
|---|---|
| `␣mr` | rendu dans nvim on/off |
| `␣mp` | aperçu dans le navigateur |
| `␣mP` | fermer l'aperçu |

Rendu direct : titres, tableaux, cases, encadrés `> [!NOTE]`. Images et formules LaTeX affichées dans Ghostty. Aperçu navigateur mis à jour à la frappe, avec les diagrammes Mermaid.

## Claude Code

| Touche | Action |
|---|---|
| `␣ac` | ouvrir / fermer |
| `␣af` | aller dans Claude |
| `␣ar` `␣aC` | reprendre / continuer |
| `␣am` | choisir le modèle |
| `␣ab` | fichier dans le contexte |
| `␣as` | envoyer la sélection (visuel) |
| `␣aa` `␣ad` | accepter / refuser le diff |

Claude voit le fichier et la sélection courants. Dans nvim-tree, `␣as` ajoute le fichier sous le curseur.

## Buffers, interface

| Touche | Action |
|---|---|
| `␣bd` `␣bo` | fermer le buffer / les autres |
| `␣un` | historique des notifications |
| `␣?` | raccourcis du buffer |

## Entretien

| Touche | Action |
|---|---|
| `make nvim-update` | MAJ plugins et outils (+7 jours) |
| `NOW=nom` | sans délai (faille de sécurité) |
| `make test-nvim` | banc Ubuntu (Docker) |
| `:Mason` | outils installés (LSP…) |
| `:checkhealth` | diagnostic général |
| `:checkhealth vim.lsp` | serveurs LSP du buffer |
| `:ConformInfo` | formateurs du buffer |

`:Lazy update` ne fait rien (versions figées) : passer par `make nvim-update`, puis committer `lazy-lock.json` et `cooldown.lua`.
