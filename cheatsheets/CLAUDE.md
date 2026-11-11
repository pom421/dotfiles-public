# Cheatsheets — préférences

## Objectif
- Cheatsheets adaptées à moi et à mes outils (neovim, bash…)
- Partir de mes notes : corriger les erreurs, dédoublonner, regrouper par thème
- Ajouter les indispensables manquants, sans marqueur visuel (pas d'étoiles)
- Ignorer les spécificités d'outils que je n'utilise pas (ex. bugs VS Code)

## Source de vérité : ma config
- Les fiches vivent dans `dotfiles-public/cheatsheets/` ; la config de chaque outil est dans `../<outil>/` (ex. `../nvim/.config/nvim/`)
- Toujours lire la config réelle avant d'écrire une fiche : mes raccourcis, surcharges et plugins priment sur les défauts
- Vérifier les défauts dans le code installé (plugin, `nvim --clean`…) plutôt que de mémoire
- Quand je modifie une config, mettre à jour les fiches concernées (et inversement)
- **Repo public** : ne jamais reprendre le contenu de `dotfiles-private` (contexte perso/pro, chemins, identités)

## Organisation
- Par domaine (ex. nvim) : **1 fiche générique** + des **fiches thématiques** pour approfondir
- Générique = l'essentiel du domaine, 2 pages max
- Thématique = un sous-sujet en détail (ex. registres, macros, buffers), sans répéter la générique
- Nommage fichiers : `<outil>-essentiel` (générique), `<outil>-<thème>` (thématique), ex. `nvim-essentiel`, `nvim-registres`
- Titre de la fiche : « Neovim essentiel », « Neovim registres »…
- Vérifier le vrai périmètre des notes avant de nommer

## Sorties
- Toujours **3 exports : PDF + HTML + Markdown**, même contenu
- Le HTML est la source : PDF et Markdown sont générés depuis lui
- `make cheatsheets` (racine du repo) régénère tous les PDF et Markdown ; une seule fiche : `node cheatsheets/outils/build.ts <fiche>.html`
- Versionnés : HTML + Markdown (consultation rapide dans nvim). **PDF non versionnés** (`.gitignore`)
- PDF = la version de référence pour imprimer
- **Numéro de version** en petit dans l'en-tête de chaque page : `vN · AAAA-MM-JJ` (fin de la légende, `<span class="ver">`)
- À chaque modification du contenu : N + 1 et date du jour, identiques en PDF et HTML
- HTML : imprimable directement depuis le navigateur (pas depuis claude.ai : l'iframe ignore `@page`)

## Impression
- A4 **paysage**, 4 colonnes, marges 0 côté `@page` (padding interne ~7–8 mm)
- Nombre de pages minimal, colonnes équilibrées, pas de colonne vide
- Sections insécables (`break-inside: avoid`). Si une section bloque l'équilibre → la scinder
- Rendu imprimé toujours clair, même si l'écran est en mode sombre
- Lisible une fois imprimé : corps ~10 pt

## Lisibilité
- Raccourcis en capsules monospace (`kbd`), bien distincts de la description
- Description courte : 3 à 6 mots
- Une ligne = un raccourci ; tableaux à 2 colonnes (touche · action)
- Titres de section courts, couleur d'accent sobre

## Exemples
- Ponctuellement, un exemple court quand il clarifie (ex. `yiw` → `ciw` → `C-r 0`)
- Dans un **encadré visuellement différent** du reste (fond, bordure ou style), pour casser la monotonie
- Pas plus de 1 ou 2 par section

## Pièges techniques déjà rencontrés
- Feuille : `box-sizing: border-box` et hauteur 209 mm (pas 210), sinon page blanche ajoutée
- Polices Google Fonts : les embarquer en data URI pour générer le PDF, sinon police de repli (fait par `build.py`)
- Clavier AZERTY Mac : les raccourcis avec `[ ]` (et Ctrl + `[ ]`) sont pénibles ou inaccessibles, le signaler
- Vérifier le PDF généré : nombre de pages, débordements, rendu de chaque page

## Style de réponse
- Concis, listes à puces
- Rôle de mentor : signaler mes erreurs et expliquer brièvement
