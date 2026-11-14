# Snacks recherche

*v1 · 2026-11-14* — `␣` = leader (Espace) · `C-x` = Ctrl+x · `A-x` = Option droite+x · explorateur : fiche à part

---

**snacks · recherche, listes, git**

## Fichiers · texte

| Touche | Action |
|---|---|
| `␣ff` | fichier par nom |
| `␣fg` | texte dans le projet |
| `␣fx` | mot sous le curseur / sélection |
| `␣fb` | buffers ouverts |
| `␣fr` | fichiers récents |
| `␣f/` | lignes du buffer |
| `␣fR` | reprendre la dernière recherche |
| `␣fp` | toutes les recherches |

> **Exemple** : `␣fg` `useState` → `Tab` `Tab` → `C-q` : les 2 résultats dans la quickfix.

## Code · aide

| Touche | Action |
|---|---|
| `␣fs` `␣fS` | symboles fichier / projet |
| `␣fd` `␣fD` | diagnostics fichier / projet |
| `gd` `grr` `gri` | définition, références… (LSP) |
| `␣st` | TODO, FIXME du projet |
| `␣fh` | aide de nvim |
| `␣fk` | raccourcis |
| `␣fc` | commandes |

Une seule réponse (une définition) : saut direct, sans liste.

## Dans une liste

| Touche | Action |
|---|---|
| `texte` | filtre (champ du haut) |
| `C-j` `C-k` | résultat suivant / précédent |
| `Entrée` | ouvrir |
| `C-v` `C-s` | split vertical / horizontal |
| `S-Entrée` | choisir la fenêtre |
| `Tab` `S-Tab` | sélection multiple |
| `C-a` | tout sélectionner |
| `C-q` | vers la quickfix |
| `C-f` `C-b` | défiler l'aperçu |
| `C-d` `C-u` | défiler la liste |
| `C-↑` `C-↓` | recherches précédentes |
| `Échap` `Échap` | fermer |
| `?` | toutes les touches (mode normal) |

## Options de la liste

| Touche | Action |
|---|---|
| `A-h` | fichiers cachés on/off |
| `A-i` | fichiers ignorés (git) on/off |
| `A-p` | aperçu on/off |
| `A-m` | plein écran on/off |
| `A-r` | expression régulière on/off |
| `C-g` | `␣fg` : filtrer les résultats |

**`C-g` dans `␣fg`** : fige la recherche, le texte tapé filtre alors les lignes trouvées.

## Saisie du filtre

| Touche | Action |
|---|---|
| `foo bar` | les deux mots, dans l'ordre voulu |
| `'foo` | texte exact (pas flou) |
| `^foo` `foo$` | commence / finit par |
| `!foo` | exclure |
| `foo \| bar` | l'un ou l'autre |
| `C-r` `C-w` | insérer le mot sous le curseur |

## Git (lazygit)

| Touche | Action |
|---|---|
| `␣gg` | lazygit flottant |
| `␣gl` | historique du dépôt |
| `␣gf` | historique du fichier |
| `␣go` | ouvrir sur GitHub / GitLab |

Dans herdr, l'onglet `git` fait le même travail : `␣gg` sert pour un commit rapide sans quitter nvim.

## GitHub (gh)

| Touche | Action |
|---|---|
| `␣gi` `␣gI` | issues : ouvertes / toutes |
| `␣gp` `␣gP` | pull requests : ouvertes / toutes |
| `A-b` | ouvrir dans le navigateur |
| `C-y` | copier le lien |

Prérequis : `gh auth login`.

## Issue · PR ouverte

| Touche | Action |
|---|---|
| `Entrée` | actions (revue, fusion, checkout…) |
| `a` | commenter |
| `i` | modifier |
| `c` `o` | fermer / rouvrir |

Revue ligne à ligne d'une PR : `:CodeDiff pr 12` (fiche IDE).

## Interface

| Touche | Action |
|---|---|
| `␣e` | explorateur (fiche à part) |
| `␣bd` `␣bo` | fermer le buffer / les autres |
| `␣tt` | terminal flottant on/off |
| `␣un` | historique des notifications |

**`␣bd` garde la fenêtre** (et la disposition) ; `:bd` la ferme.

## Automatique

**words** : autres occurrences du symbole surlignées (LSP).

**bigfile** : très gros fichier ouvert sans treesitter ni LSP.

**image** : images et formules du markdown dans Ghostty.

**input**, **notifier** : questions et messages en fenêtres flottantes.

## Pièges

**Deux fenêtres** : le filtre (mode insertion) et la liste. Premier `Échap` : mode normal, on peut utiliser `j` `k` ; second : ferme.

**`A-…` sur Mac** : Option **droite** uniquement (Ghostty).

**Fichier absent de `␣ff`** : caché ou ignoré par git → `A-h` / `A-i`.
