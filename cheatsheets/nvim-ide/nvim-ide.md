# Neovim IDE

*v11 · 2026-11-25* — Page 1/2 · `␣` = leader (Espace) · `C-x` = Ctrl+x · `␣?` = raccourcis du buffer · which-key s'ouvre après `␣`

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

**Serveurs** : TS/JS `tsc` (TS 7) + `oxlint` · Python `ty` + `ruff` · HTML, CSS · YAML, JSON (schémas) · Lua · Bash. React (TSX/JSX) : par `tsc`, avec `@types/react` dans le projet. Les autres occurrences du symbole sont surlignées.

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
| `Entrée` | valider la proposition choisie ; rien de choisi = saut de ligne |
| `C-e` | fermer le menu |
| `Tab` `S-Tab` | champ de snippet suivant / précédent |

Sources : LSP, chemins, snippets, mots du buffer ; aussi après `:`. La doc de la proposition s'affiche à côté.

**Valider = point d'annulation** : `u` revient au texte tapé avant la complétion.

## Rechercher (snacks)

| Touche | Action |
|---|---|
| `␣ff` | fichier par nom |
| `␣fg` | texte dans le projet |
| `␣fx` | mot sous le curseur / sélection |
| `␣fb` `␣fr` | buffers / fichiers récents |
| `␣fs` `␣fS` | symboles fichier / projet |
| `␣fp` | toutes les recherches |

Dans la liste : `C-j` `C-k`, `Tab` sélection, `C-q` quickfix. **Suite : fiche snacks.**

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

JS/TS, JSON, YAML, TOML, CSS, Markdown : `oxfmt` (`vp fmt` dans un projet Vite+) · Python `ruff` · Lua `stylua` · shell `shfmt`. Lint : `hadolint` (Dockerfile), `actionlint` (workflows GitHub).

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
| `␣gv` | voir le bloc (avant / après) |
| `␣gs` `␣gr` | indexer / annuler le bloc |
| `␣gS` `␣gR` | indexer / annuler le fichier |
| `␣gb` `␣gB` | blame : ligne / fichier |
| `␣ub` | blame en fin de ligne on/off |
| `␣go` | ouvrir sur GitHub / GitLab |
| `␣gi` `␣gI` | issues GitHub : ouvertes / toutes |
| `␣gp` `␣gP` | pull requests : ouvertes / toutes |

En visuel, `␣gs` `␣gr` ne traitent que la sélection. Issue ou PR ouverte : commenter, revue, fusion, checkout (`g?`).

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

vitest (`vp test` dans un projet Vite+) · pytest. Résultat ✓ ✗ dans la gouttière.

## Markdown

| Touche | Action |
|---|---|
| `gf` | suivre le lien (fichier ou web) |
| `C-o` | revenir après le lien |
| `␣mr` | rendu dans nvim on/off |
| `␣mp` | aperçu dans le navigateur |
| `␣mP` | fermer l'aperçu |

Rendu direct : titres, tableaux, cases, encadrés `> [!NOTE]`. Images et formules LaTeX affichées dans Ghostty. Aperçu navigateur mis à jour à la frappe, avec les diagrammes Mermaid.

## Claude Code

| Touche | Action |
|---|---|
| `␣ay` | copier `@fichier` (+ lignes en visuel) |
| `␣ab` | fichier dans le contexte (/ide) |
| `␣as` | envoyer la sélection (/ide) |
| `␣aa` `␣ad` | accepter / refuser le diff (/ide) |

Claude tourne dans l'onglet `claude` de herdr, en microVM : fiche claude. Les fichiers qu'il modifie sont relus tout seuls. `/ide` : seulement avec Claude sur la machine.

## Buffers, interface

| Touche | Action |
|---|---|
| `␣bd` `␣bo` | fermer le buffer / les autres |
| `␣e` | explorateur de fichiers |
| `␣un` | historique des notifications |
| `␣?` | raccourcis du buffer |

## Entretien

| Touche | Action |
|---|---|
| `make nvim-sync` | après un `git pull` |
| `make nvim-update` | MAJ plugins et outils (+7 jours) |
| `:checkhealth vim.lsp` | serveurs LSP du buffer |

Le reste : fiche entretien.
