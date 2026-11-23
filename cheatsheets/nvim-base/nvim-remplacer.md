# Remplacer nvim

*v1 · 2026-11-23* — Page 1/1 · `␣` = leader · `⏎` = Entrée

---

**nvim · remplacer un mot à plusieurs endroits**

## Quel outil ?

| Besoin | Faire | Pourquoi |
|---|---|---|
| Renommer une variable, une fonction | `grn` ou `␣cr` | LSP : vraies références, tous les fichiers, pas les homonymes |
| Certaines occurrences, fichier courant | `*` `N` `cgn` … `Esc` `.` | on choisit une par une |
| Toutes, fichier courant | `*` puis `:%s//neuf/g` | d'un coup ; `gc` pour confirmer |
| Texte dans tout le projet | `␣sr` | grug-far : aperçu, puis appliquer |

## Chercher le mot

| Touche | Action |
|---|---|
| `*` `#` | mot sous le curseur, mot entier ↓ ↑ |
| `g*` | sans limite : `user` → `username` |
| visuel `*` | la sélection, telle quelle |
| `/motif⏎` | regex (`\.` = vrai point) |
| `n` `N` | suivante · précédente |
| `␣nh` | effacer le surlignage |

`*` part déjà sur la suivante → `N` pour revenir

## cgn + point

| Touche | Action |
|---|---|
| `gn` | sélectionne le match sous le curseur, sinon le suivant |
| `cgn` | le remplace (insertion) |
| `dgn` | le supprime |
| `.` | refait `cgn` + texte sur le match suivant |

### Choisir au cas par cas

| Touche | Action |
|---|---|
| `n` | aller voir la suivante |
| puis `.` | la changer |
| ou `n` | la laisser, aller à la suivante |

**Tout changer sans regarder** : `.` `.` `.` enchaîne directement

## Pièges

| Touche | Action |
|---|---|
| casse | `*` ignore toujours la casse chez moi : `user` attrape `User`, et `cgn` écrit tel quel → la sauter (`n`) |
| casse stricte | `/User` (majuscule = sensible) ou `/user\C` |
| `-` | fait partie du mot : `*` sur `user` ne trouve pas `user-id` |
| coller le nom | `C-r 0` (dernier yank), pas `C-r +` : `cgn` vient d'y mettre l'ancien mot |
| `.` incomplet | flèches ou souris pendant la saisie : seule la fin est rejouée |

## Tout le fichier : :s

| Touche | Action |
|---|---|
| `:%s//neuf/g` | motif vide = dernière recherche |
| `:%s//neuf/gc` | confirmer chaque fois |
| `y` `n` | remplacer · passer |
| `a` `q` | tout le reste · arrêter |

## Exemple

```
Le client paie.
Fiche client : 12
Le client part.
```

| Touche | Action |
|---|---|
| 1. | sur `client` ligne 1 : `*` `N` |
| 2. | `cgn` `usager` `Esc` → ligne 1 |
| 3. | `n` → ligne 2 : on la garde |
| 4. | `n` → ligne 3, `.` → changée |
