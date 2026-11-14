# Snacks explorateur

*v5 · 2026-11-14* — `␣` = leader (Espace) · `C-x` = Ctrl+x · touches valables dans la liste · `?` = aide intégrée

---

**nvim · explorateur (snacks)**

## Ouvrir · fermer · focus

| Touche | Action |
|---|---|
| `␣e` | ouvrir / fermer |
| `nvim .` | ouvre l'explorateur (remplace netrw) |
| `q` `Échap` | fermer l'explorateur |
| `?` | aide intégrée |

**Le fichier actif est révélé** automatiquement dans l'arbre.

## Fenêtres gauche ↔ droite

| Touche | Action |
|---|---|
| `C-h` | aller dans l'explorateur |
| `C-l` | revenir au fichier |
| `C-w w` | fenêtre suivante |
| `C-w >` `C-w <` | élargir / rétrécir |
| `C-w =` | égaliser les splits |

## Se déplacer dans l'arbre

| Touche | Action |
|---|---|
| `j` `k` | ligne suivante / précédente |
| `l` `Entrée` | déplier / ouvrir |
| `h` | replier le dossier |
| `Z` | tout replier |
| `gg` `G` | début / fin de liste |
| `C-d` `C-u` | défiler |
| `]g` `[g` | fichier git modifié |
| `]d` `[d` | fichier avec diagnostic |
| `]e` `[e` | fichier avec erreur |
| `]w` `[w` | fichier avec alerte |

## Filtrer

| Touche | Action |
|---|---|
| `/` | aller dans le champ filtre |
| `texte` | filtre tout l'arbre |
| `Échap` | retour à la liste |
| `␣/` | texte dans ce dossier (grep) |

**Le filtre cherche aussi dans les dossiers fermés** et les déplie.

> **Exemple** : `/` `date` → `Entrée` : ouvre `src/utils/date.lua`.

## Ouvrir un fichier

| Touche | Action |
|---|---|
| `Entrée` `l` | ouvrir |
| `P` | aperçu oui / non |
| `C-v` | split vertical |
| `C-s` | split horizontal |
| `S-Entrée` | choisir la fenêtre |
| `o` | ouvrir avec appli système |
| `double-clic` | ouvrir à la souris |

## Dossier courant (racine)

| Touche | Action |
|---|---|
| `.` | dossier sous curseur = racine |
| `BS` | remonter la racine d'un cran |
| `C-c` | dossier de l'onglet (`:tcd`) |
| `u` | rafraîchir |

**`.` change aussi le dossier de travail** de nvim (`:pwd`) : `␣ff` y cherche ensuite.

## Créer · renommer · supprimer

| Touche | Action |
|---|---|
| `a` | créer fichier |
| `a` `nom/` | créer dossier (finir par `/`) |
| `r` | renommer |
| `d` | mettre à la corbeille |

> **Exemple** : `a` → `src/utils/date.lua` → `Entrée` : crée les dossiers manquants et le fichier.

## Sélection multiple

| Touche | Action |
|---|---|
| `Tab` | sélectionner, ligne suivante |
| `S-Tab` | idem, ligne précédente |
| `V` `j`… | sélection visuelle |
| `C-a` | tout sélectionner |

`d`, `m`, `c`, `y` agissent sur la sélection, sinon sur la ligne.

## Déplacer · copier

| Touche | Action |
|---|---|
| `m` | déplacer la sélection ici |
| `c` | copier la sélection ici |
| `m` (sans sélection) | renommer / déplacer |
| `c` (sans sélection) | copier sous un nom |
| `y` puis `p` | copier, coller ailleurs |

> **Exemple** : `Tab` `Tab` `Tab` → aller sur `archive/` → `m` : 3 fichiers déplacés.

## Afficher · masquer

| Touche | Action |
|---|---|
| `H` | fichiers cachés (dotfiles) |
| `I` | fichiers ignorés par git |

## Autres actions

| Touche | Action |
|---|---|
| `C-t` | terminal dans ce dossier |
| `C-q` | sélection → liste quickfix |
| `␣as` | fichier → contexte de Claude |

## Pièges

**Deux fenêtres** : le champ filtre en haut, la liste en dessous. Les touches de cette fiche marchent dans la liste ; `/` passe de l'une à l'autre.

**`Échap` dans la liste ferme l'explorateur** ; pour juste revenir au fichier : `C-l`.

**`d` va à la corbeille** (`trash` sur macOS, `gio trash` sous Ubuntu) ; sans ces commandes, suppression définitive (`:checkhealth snacks`).

**`C-j` `C-k`** descendent / montent dans la liste, pas de fenêtre en dessous / au-dessus.

**`[` `]` en AZERTY** : Option gauche + Maj + `(` `)`. Avec Ctrl, ça ne passe pas.

**macOS : `/home` est vide** (montage réseau). Ton dossier : `/Users/<nom>` = `~`.

## Ma config (snacks.lua)

```
opts = {
  explorer = { enabled = true },
},
keys = {
  { "<leader>e",
    function() Snacks.explorer() end },
}
```

**`enabled = true`** : `nvim dossier` ouvre l'explorateur à la place de netrw.
