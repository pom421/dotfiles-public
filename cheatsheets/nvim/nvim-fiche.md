# Fiche Neovim

*v2 · 2026-11-11* — Page 1/2 · `C-x` = Ctrl+x

---

**nvim · mode normal**

## Grammaire

> [n] opérateur [n] mouvement|objet

### Opérateurs

| Touche | Action |
|---|---|
| `d` `c` `y` | supprimer · changer · copier |
| `>` `<` `=` | indenter · désindenter · réindenter |
| `gu` `gU` `g~` | minusc. · majusc. · inverser casse |

**Doublé = ligne entière** : `dd` `cc` `yy` `>>` `g~~`

### Objets texte (i = dedans, a = autour)

| Touche | Action |
|---|---|
| `iw` `aw` | mot |
| `i(` `i{` `i[` | contenu des parenthèses, accolades… |
| `i"` `i'` `` i` `` | contenu des guillemets |
| `it` `at` | contenu d'une balise HTML |
| `ip` `ap` | paragraphe |

Marche **n'importe où dans l'objet** : pas besoin d'être au début.

## Enregistrer · quitter

| Touche | Action |
|---|---|
| `:w` `:wa` | enregistrer · tout enregistrer |
| `:q` | fermer la fenêtre courante |
| `:qa` | tout quitter (arbre compris) |
| `:wqa` | enregistrer puis tout quitter |
| `:qa!` | quitter sans enregistrer |
| `ZZ` `ZQ` | `:wq` · `:q!` (fenêtre courante) |

## Exemples

| Touche | Action |
|---|---|
| `ciw` | changer le mot courant |
| `cw` | changer du curseur à fin du mot |
| `ci"` | changer le texte entre guillemets |
| `di(` | vider les parenthèses |
| `da(` | supprimer parenthèses comprises |
| `cit` | changer le contenu de la balise |
| `yi{` | copier le contenu d'un bloc |
| `d$` `y0` | suppr. jusqu'à fin · copier jusqu'au début |
| `d/hello⏎` | supprimer jusqu'à « hello » |
| `8dd` `32j` | 8 lignes · descendre de 32 |
| `ggdG` | vider le fichier |
| `v%y` | sur ( ou { : copier jusqu'à la paire |

## Mouvements dans la ligne

| Touche | Action |
|---|---|
| `w` `b` `e` | mot suivant · précédent · fin de mot |
| `W` `B` `E` | idem, mots séparés par espaces seulement |
| `0` `^` `$` | début · 1er caractère · fin |
| `fc` `Fc` | sauter sur `c` → / ← |
| `tc` `Tc` | sauter juste avant `c` → / ← |
| `;` `,` | répéter f/t même sens · sens inverse |
| `%` | parenthèse / accolade correspondante |

## Écran et fichier

| Touche | Action |
|---|---|
| `C-d` `C-u` | ½ page ↓ / ↑ |
| `C-f` `C-b` | page entière ↓ / ↑ |
| `C-e` `C-y` | défiler 1 ligne, curseur fixe |
| `zz` `zt` `zb` | ligne au milieu · en haut · en bas |
| `gg` `G` `42G` | début · fin · ligne 42 |
| `{` `}` | paragraphe précédent / suivant |
| `*` `#` | mot sous curseur, suivant / précédent |

### Marques et sauts

| Touche | Action |
|---|---|
| `ma` | poser la marque `a` |
| `` `a `` `'a` | aller à la marque (position · ligne) |
| ``` `` ``` | revenir avant le dernier saut |
| `C-o` `C-i` | saut précédent / suivant (mode normal) |

## Répéter · annuler

| Action | Faire | Rép. | Inv. |
|---|---|---|---|
| Modification | {édit} | . | u |
| Caract. ligne | f t F T | ; | , |
| Recherche → | /motif⏎ | n | N |
| Recherche ← | ?motif⏎ | n | N |
| Substitution | :s/a/b | & | u |
| Macro | qx…q | @x | u |

| Touche | Action |
|---|---|
| `u` `C-r` | annuler · refaire |
| `@@` | rejouer la dernière macro |

## Raccourcis = version longue

| Touche | Action |
|---|---|
| `D` = `d$` | supprimer jusqu'à fin de ligne |
| `C` = `c$` | changer jusqu'à fin de ligne |
| `s` = `cl` | changer le caractère |
| `S` = `cc` | changer toute la ligne |
| `x` = `dl` | supprimer le caractère |
| `Y` = `y$` | copier jusqu'à fin (défaut nvim) |
| `I` = `^i` | insérer en début de ligne |
| `A` = `$a` | insérer en fin de ligne |
| `o` = `A⏎` | nouvelle ligne dessous |
| `O` = `ko` | nouvelle ligne dessus |

## Petites éditions

| Touche | Action |
|---|---|
| `J` | joindre la ligne suivante |
| `gJ` | joindre sans espace |
| `rc` | remplacer 1 caractère par `c` |
| `R` | mode remplacement (écrase) |
| `~` | inverser la casse du caractère |
| `>>` `<<` | indenter / désindenter la ligne |

---

**nvim · visuel, insertion, buffers**

## Mode visuel

| Touche | Action |
|---|---|
| `v` | sélection par caractères |
| `V` | sélection par lignes |
| `C-v` | sélection en bloc (rectangle) |
| `gv` | reprendre la dernière sélection |
| `o` `O` | aller à l'autre bout (O : coins du bloc) |
| `vi{` `vap` | sélectionner un objet texte |

Puis : `d` `c` `y` `>` `U` `u` `~` `:`

## Visuel : coller, bloc

### Coller sur une sélection

| Touche | Action |
|---|---|
| `p` | remplace ; la sélection part dans le registre |
| `P` | remplace sans toucher au registre : coller N fois le même mot |

### Bloc : même texte sur N lignes

| Touche | Action |
|---|---|
| `C-v` `j…` `I` | tape, puis `Esc` : insertion en début de bloc sur toutes les lignes |
| `C-v` `j…` `$A` | idem, en fin de chaque ligne |

## Substitution

| Touche | Action |
|---|---|
| `:s/a/b/` | 1re de la ligne |
| `:s/a/b/g` | toute la ligne |
| `:%s/a/b/g` | tout le fichier |
| `:%s/a/b/gc` | tout, en confirmant |
| `:'<,'>s/a/b/g` | dans la sélection |
| `:noh` | effacer surlignage |

## Mode insertion

### Supprimer avant le curseur

| Touche | Action |
|---|---|
| `C-h` | caractère (= Backspace) |
| `C-w` | mot |
| `C-u` | jusqu'au début de ligne |

Ces 3 marchent aussi dans bash.

### `C-o` + commande : 1 action normale, retour en insertion

| Touche | Action |
|---|---|
| `C-o 0` `C-o $` | début · fin de ligne |
| `C-o w` `C-o b` | mot suivant · précédent |
| `C-o x` | suppr. caractère après |
| `C-o dw` | suppr. mot après |
| `C-o D` | suppr. jusqu'à fin de ligne |
| `C-o zz` | recentrer l'écran |

### Déplacer sans sortir

| Touche | Action |
|---|---|
| `Shift ←→` | mot précédent / suivant |
| `C-g j` `C-g k` | ligne ↓ / ↑, colonne de départ de la saisie |

## Insertion : coller, compléter

### Coller, compléter, indenter

| Touche | Action |
|---|---|
| `C-r "` | coller registre par défaut |
| `C-r 0` | coller dernier yank |
| `C-r +` | coller presse-papier système |
| `C-n` `C-p` | complétion suivante / précédente |
| `C-t` `C-d` | indenter / désindenter la ligne |

## Registres

| Touche | Action |
|---|---|
| `:reg` | lister les registres |
| `""` | défaut (yank, d, c) : `""p` = `p` |
| `"ayy` | copier dans `a` |
| `"Ayy` | ajouter à la fin de `a` |
| `"ap` | coller `a` |
| `"0p` | **dernier yank**, même après un `d` |
| `"+y` `"+p` | presse-papier système |
| `"_d` | supprimer sans rien écraser (trou noir) |

Cas type : `yiw`, aller sur un autre mot, `ciw` puis `C-r 0`.

## Buffers

> Buffer (mémoire) → Window (vue) → Tab (groupe)

| Touche | Action |
|---|---|
| `:ls` | lister |
| `:e fichier` | ouvrir dans la fenêtre courante |
| `:b N` `:b nom` | aller au buffer (Tab complète) |
| `:bn` `:bp` | suivant / précédent |
| `C-^` | basculer vers le buffer alternatif `#` |
| `:bd N` | fermer le buffer |
| `:bwipeout N` | effacer tout (historique, marques) |
| `:w nom` | sauver un buffer sans nom |
| `:saveas nom` | sauver et renommer |

Flags `:ls` : `%` courant · `#` alternatif · `a` actif · `h` caché · `+` modifié

## Fenêtres · onglets

### Fenêtres

| Touche | Action |
|---|---|
| `:sp` `:vsp` | split horizontal / vertical |
| `C-w w` | fenêtre suivante |
| `C-w h/j/k/l` | aller à gauche / bas / haut / droite |
| `C-w q` | fermer la fenêtre (pas le buffer) |
| `C-w o` | garder seulement celle-ci |
| `C-w =` | tailles égales |

### Onglets

| Touche | Action |
|---|---|
| `:tabnew` | nouvel onglet |
| `:tabc` `:tabc!` | fermer · forcer |
| `gt` `gT` `3gt` | suivant · précédent · n°3 |
| `:tabs` | lister (`>` = fenêtre courante) |

### Pièges

| Touche | Action |
|---|---|
| `:q` | ferme la fenêtre, pas le buffer → `:bd` |
| `:bn` | change seulement la fenêtre courante |
| Onglet fermé | buffers toujours en mémoire |

Naviguer entre buffers plutôt qu'abuser des onglets.
