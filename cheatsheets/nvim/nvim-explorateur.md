# Neovim explorateur

*v2 · 2026-11-11* — `␣` = leader (Espace) · `C-x` = Ctrl+x · touches valables dans l'arbre · `g?` = aide intégrée

---

**nvim · explorateur (nvim-tree)**

## Ouvrir · fermer · focus

| Touche | Action |
|---|---|
| `␣e` | basculer + révéler |
| `:NvimTreeToggle` | basculer sans révéler |
| `:NvimTreeFocus` | ouvrir et y aller |
| `:NvimTreeFindFile` | révéler fichier actif |
| `q` | fermer l'arbre |
| `g?` | aide intégrée |

## Fenêtres gauche ↔ droite

| Touche | Action |
|---|---|
| `C-h` | aller dans l'arbre |
| `C-l` | revenir au fichier |
| `C-w w` | fenêtre suivante |
| `C-w p` | fenêtre précédente |
| `:NvimTreeResize 40` | largeur 40 |
| `:NvimTreeResize +5` | élargir de 5 |
| `C-w =` | égaliser les splits |

## Se déplacer dans l'arbre

| Touche | Action |
|---|---|
| `j` `k` | ligne suivante / précédente |
| `l` `Entrée` `o` | déplier / ouvrir |
| `h` `BS` | replier le dossier parent |
| `P` | aller au dossier parent |
| `<` `>` | frère précédent / suivant |
| `K` `J` | premier / dernier frère |
| `W` | tout replier |
| `E` | tout déplier |
| `L` | grouper dossiers vides |
| `[c` `]c` | fichier git modifié |
| `[e` `]e` | fichier avec diagnostic |

## Chercher

| Touche | Action |
|---|---|
| `f` | filtrer l'arbre en direct |
| `F` | effacer le filtre |
| `S` | chercher un chemin |
| `/` | recherche vim classique |

**Fichier loin dans l'arbre** : `␣ff` (Telescope) est plus rapide.

## Ouvrir un fichier

| Touche | Action |
|---|---|
| `Entrée` | ouvrir, focus sur fichier |
| `Tab` | aperçu, focus reste arbre |
| `C-v` | split vertical |
| `C-x` | split horizontal |
| `C-t` | nouvel onglet |
| `C-e` | à la place de l'arbre |
| `O` | ouvrir sans choisir fenêtre |
| `s` | ouvrir avec appli macOS |
| `double-clic` | ouvrir à la souris |

> **Exemple** : Parcourir des fichiers : `j` `Tab` `j` `Tab`… puis `Entrée` sur le bon.

## Racine de l'arbre

| Touche | Action |
|---|---|
| `=` | dossier sous curseur = racine |
| `-` | remonter la racine d'un cran |
| `R` | rafraîchir l'arbre |

**`=` remplace `C-]`** (inaccessible en AZERTY Mac). Souris : double clic droit. Chemin précis : `:NvimTreeOpen ~/x`

## Créer · renommer · supprimer

| Touche | Action |
|---|---|
| `a` | créer fichier |
| `a` `nom/` | créer dossier (finir par `/`) |
| `r` | renommer (nom complet) |
| `e` | renommer, garde l'extension |
| `u` | renommer chemin complet |
| `C-r` | renommer, nom effacé |
| `d` | supprimer (définitif) |
| `D` | mettre à la corbeille |

> **Exemple** : `a` → `src/utils/date.lua` → `Entrée` : crée les dossiers manquants et le fichier.

## Copier · couper · coller

| Touche | Action |
|---|---|
| `c` | copier fichier / dossier |
| `x` | couper (pour déplacer) |
| `p` | coller sous le curseur |

**Où colle `p`** : dans le dossier sous le curseur, ou à côté si c'est un fichier.

## Copier un chemin

| Touche | Action |
|---|---|
| `y` | nom du fichier |
| `ge` | nom sans extension |
| `Y` | chemin relatif |
| `gy` | chemin absolu |

Copié dans `"+` → `Cmd+V` ailleurs, `"+p` dans nvim.

## Sélection multiple (marques)

| Touche | Action |
|---|---|
| `m` | marquer / démarquer |
| `bmv` | déplacer les marqués |
| `bd` | supprimer les marqués |
| `bt` | marqués à la corbeille |
| `M` | n'afficher que les marqués |

> **Exemple** : `m` `j` `m` `j` `m` → `bmv` → `archive/` : 3 fichiers déplacés.

## Afficher · masquer

| Touche | Action |
|---|---|
| `H` | fichiers cachés (dotfiles) |
| `I` | fichiers ignorés par git |
| `U` | filtres personnalisés |
| `B` | seulement buffers ouverts |
| `C` | seulement fichiers modifiés |

## Infos · commandes

| Touche | Action |
|---|---|
| `C-k` | infos fichier (taille, date) |
| `.` | commande vim sur le fichier |

## Icônes git

| Touche | Action |
|---|---|
| ✗ | modifié, non indexé |
| ✓ | indexé (`git add`) |
| ★ | nouveau, non suivi |
| ➜ | renommé |
| ◌ | ignoré par git |

## Pièges

**LazyVim ≠ lazy.nvim** : ici nvim-tree, pas neo-tree.

**`C-k` dans l'arbre** = infos, pas « fenêtre du haut » : la touche locale masque ton raccourci.

**`Tab` / `Entrée` sur la 1re ligne** (racine) : remonte la racine d'un cran. Annuler : `=` sur l'ancien dossier.

**`d` est définitif** : préférer `D` (corbeille).

**macOS : `/home` est vide** (montage réseau). Ton dossier : `/Users/<nom>` = `~`.

**`[` `]` en AZERTY** : Option gauche + Maj + `(` `)`. Avec Ctrl, ça ne passe pas.

**`␣e` ferme l'arbre** s'il est ouvert ; pour juste y aller : `C-h`.

## Personnaliser (nvim-tree.lua)

```
require("nvim-tree").setup({
  actions = { remove_file =
    { close_window = false } },
  on_attach = function(b)
    local api = require("nvim-tree.api")
    api.config.mappings
      .default_on_attach(b)
    local t, n = api.tree, api.node
    local map = function(k, f)
      vim.keymap.set("n", k, f,
        { buffer = b })
    end
    map("=", t.change_root_to_node)
    map("h", n.navigate.parent_close)
    map("l", n.open.edit)
  end,
})
```

**`close_window = false`** : après `d`, on passe au fichier suivant au lieu de fermer la fenêtre.

**Sans `default_on_attach`**, tous les raccourcis par défaut disparaissent.
