# Neovim mes raccourcis

*v4 · 2026-11-14* — `␣` = leader (Espace) · colonne « Défaut » = nvim sans config · ⚠ = fonction perdue

---

**nvim · ma config vs défaut**

## Extensions installées

| Extension | Rôle | Commandes |
|---|---|---|
| `lazy.nvim` | gère les plugins | `:Lazy` `make nvim-update` |
| `snacks` | recherche, explorateur (essai), terminal | `␣ff` `␣E` `␣tt` |
| `nvim-tree` | explorateur de fichiers | `␣e` → fiche explorateur |
| `bufferline` | buffers en onglets | `S-h` `S-l` `:BufferLinePick` |
| `lualine` | barre d'état | — |
| `treesitter` | coloration, indentation | `:TSInstall rust` `:TSUpdate` |
| `tokyonight` | thème de couleurs | `:colorscheme` |
| `which-key` | popup des raccourcis | `␣?` |

**LSP, complétion, git, débogage, tests…** : fiche **Neovim IDE**.

**lualine** : mode · branche git · chemin relatif · serveurs LSP actifs.

**Diagnostic général** : `:checkhealth`.

## Touche leader

| Touche | Chez moi | Défaut |
|---|---|---|
| `␣` | préfixe de mes raccourcis | avancer d'un caractère |

Leader par défaut : `\`. Perte sans gravité : `l` fait la même chose.

## Mode insertion

| Touche | Chez moi | Défaut |
|---|---|---|
| `;;` | sortir (= `Échap`) | ⚠ écrit `;;` |
| `C-j` `C-k` | menu de complétion : suivant / précédent | hors menu, inchangés |

**Effet de bord** : après `;`, nvim attend 1 s une 2e touche.

> **Exemple** : Écrire `for (;;)` en C/Java : `;` `C-v` `;` (insère le `;` brut).

## Fenêtres

| Touche | Chez moi | Défaut |
|---|---|---|
| `C-h` | fenêtre de gauche | recule d'un caractère |
| `C-j` | fenêtre du bas | descend d'une ligne |
| `C-k` | fenêtre du haut | rien |
| `C-l` | fenêtre de droite | ⚠ efface surlignage + redessine |

Défaut équivalent : `C-w h` `C-w j`… (toujours actif).

## Buffers (onglets)

| Touche | Chez moi | Défaut |
|---|---|---|
| `S-l` | buffer suivant (ordre de la barre) | ⚠ `L` : bas de l'écran |
| `S-h` | buffer précédent | ⚠ `H` : haut de l'écran |
| `␣bd` | fermer le buffer, garder la fenêtre | `:bd` ferme aussi la fenêtre |
| `␣bo` | fermer les autres | — |

Défaut équivalent : `:bn` `:bp` `:bd`. Haut / bas de l'écran : `zt` `zb` déplacent la vue, pas le curseur.

## Recherche (snacks)

| Touche | Chez moi | Défaut |
|---|---|---|
| `␣nh` | effacer le surlignage | `C-l` (masqué chez moi) |
| `␣ff` | chercher un fichier | — |
| `␣fg` | chercher dans le contenu | — |
| `␣fb` | liste des buffers | `:ls` |
| `␣fx` | chercher le mot sous curseur | `*` (fichier courant) |

## Dans les listes (snacks)

| Touche | Chez moi | Défaut |
|---|---|---|
| `C-j` | résultat suivant | `C-n` (toujours actif) |
| `C-k` | résultat précédent | `C-p` (toujours actif) |

## Mode visuel

| Touche | Chez moi | Défaut |
|---|---|---|
| `A-k` | monter la sélection | — |
| `A-j` | descendre la sélection | — |

**Alt = Option droite** uniquement (Ghostty : `macos-option-as-alt = right`).

Défaut équivalent : `:m '>+1` ou `d` puis `p`.

## Explorateur (nvim-tree)

| Touche | Chez moi | Défaut nvim-tree |
|---|---|---|
| `␣e` | basculer + révéler | `:NvimTreeToggle` |
| `=` | dossier = racine | `C-]` (inaccessible AZERTY) |
| `l` | déplier / ouvrir | `Entrée` `o` |
| `h` | replier le dossier | `BS` |
| `C-k` | infos fichier (nvim-tree) | ⚠ masque ma fenêtre du haut |

**`d` sur un fichier ouvert** : passe au suivant au lieu de fermer la fenêtre (`close_window = false`).

## Options qui changent les touches

| Option | Chez moi | Défaut |
|---|---|---|
| `clipboard` | `y` `d` `x` `c` → presse-papier système | restent dans nvim (`"+y`) |
| `iskeyword` | `foo-bar` = 1 mot | 2 mots |
| `smartcase` | `/foo` ignore la casse, `/Foo` non | casse respectée |
| `splitright` | `:vsplit` s'ouvre à droite | à gauche |
| `splitbelow` | `:split` s'ouvre en bas | en haut |
| `undofile` | `u` marche après réouverture | historique perdu |

> **Exemple** : `clipboard` : `yiw` puis `dd` → le `dd` écrase le presse-papier. Supprimer sans écraser : `"_dd`.

> **Exemple** : `iskeyword` : sur `font-size`, `ciw` remplace tout ; `w` saute le mot entier.

## Touches natives redéfinies

| Touche | Chez moi | Défaut |
|---|---|---|
| `gd` `gD` | définition, déclaration (LSP) | déclaration locale / globale (texte) |
| `grr` `gri` `grt` | idem, en liste avec aperçu | liste quickfix |
| `gq` | formateur du langage | coupe les lignes à `textwidth` |
| `s` | entourer : `sa` `sd` `sr` | ⚠ retardé (sinon `cl`) |
