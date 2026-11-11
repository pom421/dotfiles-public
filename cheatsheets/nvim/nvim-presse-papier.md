# Presse-papier nvim

*v1 · 2026-11-06* — Page 1/2 · `C-x` = Ctrl+x · `Cmd` = touche ⌘ macOS

---

**nvim · presse-papier & registres**

## Cheatsheet

> **Règle d'or** : `y` seul copie dans nvim, pas dans le système. Pour le système → `"+y`.

| Besoin | nvim | macOS 26 | Ubuntu 24 |
|---|---|---|---|
| Copier vers système | `"+y` | `Cmd+C` | `Ctrl+C` (apps) / `Ctrl+Shift+C` (terminal) |
| Coller depuis système | `"+p` | `Cmd+V` | `Ctrl+V` (apps) / `Ctrl+Shift+V` (terminal) |
| Coller un registre en insertion | `C-r +` | `Cmd+V` | `Ctrl+Shift+V` |
| Shell → presse-papier | — | `cmd \| pbcopy` | `cmd \| wl-copy` (Wayland) / `xclip -sel c` (X11) |
| Presse-papier → shell | — | `pbpaste` | `wl-paste` / `xclip -sel c -o` |
| Sélection primaire | `"*` | n'existe pas (`*` = `+`) | surligner → clic molette |
| Basculer vers fichier précédent | `:e #` | — | — |
| Voir les registres | `:reg` | — | — |
| Copier chemin fichier | `:let @+ = expand('%:p')` |  |  |

## Registres les plus utiles

| Touche | Action |
|---|---|
| `"` | défaut |
| `0` | dernier yank |
| `1`–`9` | grosses suppressions |
| `-` | petite suppression |
| `+` `*` | système · primaire (Linux) |
| `a`–`z` `A`–`Z` | perso · ajout |
| `_` | trou noir |
| `%` `#` | fichier · fichier alternatif |
| `.` `:` `/` | dernière insertion · commande · recherche |
| `=` | expression |

## Syntaxe selon le mode

Registre = case mémoire nommée. Toute copie, suppression ou collage passe par l'un d'eux.

| Touche | Action |
|---|---|
| Normal / visuel | `"`+reg+cmd : `"+y` `"ap` `"_d` |
| Insertion | `C-r`+reg : `C-r +` `C-r %` |
| Commande `:` | idem ; `C-r /` = dernière recherche |
| Vimscript | `@`+reg : `:let @+ = @%`, `:echo @+` |
| Lua | `vim.fn.setreg('+', v)` `vim.fn.getreg('+')` |
| Macro | `@a` rejoue `a` · `@:` dernière cmd · `@@` répète |

### `C-r` : seulement en insertion ou commande

- En mode normal, `C-r` = redo, rien à voir
- D'abord `i`, puis `C-r`, relâcher, puis le registre
- Touche `control`, pas `Cmd` sur Mac

## Registres modifiables

| Touche | Action |
|---|---|
| `"` | dernier yank ou suppr. (`y d c x`) → `p` seul |
| `0` | dernier **yank** uniquement → `"0p` après un `dd` qui a écrasé `"` |
| `1`–`9` | suppr. ≥ 1 ligne (`dd`, `d}`), `1` = récente → `"1p` puis `u.` pour remonter |
| `-` | suppr. < 1 ligne (`dw`, `x`) : mot effacé |
| `a`–`z` | stockage perso `"ayy` : plusieurs extraits |
| `A`–`Z` | ajout au minuscule `"Ayy` : accumuler |
| `+` | presse-papier système `"+y` |
| `*` | primaire Linux (clic molette) ; = `+` sur macOS |
| `_` | trou noir `"_d` : suppr. sans perdre son yank |

## Registres en lecture seule

| Touche | Action |
|---|---|
| `%` | fichier courant (relatif) · `"%p` |
| `#` | fichier alternatif · `:e #` |
| `.` | dernier texte inséré · `".p` |
| `:` | dernière commande · `@:` |
| `/` | dernière recherche · `C-r /` dans `:s` |
| `=` | expression |

**Insertion** : `i` `C-r` `=` `5*8` `⏎` → `40` **Normal** : `"=5*8` `⏎` `p`

## Fichier alternatif #

- **Buffer** = fichier en mémoire ; **fenêtre** = zone d'écran qui affiche un buffer
- `#` = dernier buffer affiché **dans la fenêtre courante** ; chaque fenêtre a le sien
- Mis à jour par `:e autre.md`, `:b 3`, `gf`, saut vers un autre fichier (`gd`, `C-o`)
- `nvim a.md` puis `:e b.md` → `#` = `a.md` ; `:e #` revient, `#` = `b.md` → va-et-vient
- Jamais changé de fichier → `#` vide, `:e #` = erreur
- `:split` → la nouvelle fenêtre hérite du `#`
- `C-^` peu pratique en AZERTY :

```
vim.keymap.set('n', '<leader><leader>', '<C-^>')
```

Vérifier : `:ls` (courant `%`, alternatif `#`) ou `:echo @#`

## Modificateurs de chemin

`expand('%:…')` · combinables, de gauche à droite

| Touche | Action |
|---|---|
| `:p` `:h` `:t` | absolu · dossier parent · nom seul |
| `:r` `:e` | sans extension · extension |

Lancé depuis `/Users/po/notes`, fichier `projets/idgfip.md` :

| Touche | Action |
|---|---|
| `@%` `expand('%')` | `projets/idgfip.md` |
| `expand('%:p')` | `/Users/po/notes/projets/idgfip.md` |
| `expand('%:p:h')` | `/Users/po/notes/projets` |
| `expand('%:t')` | `idgfip.md` |
| `expand('%:t:r')` | `idgfip` |
| `expand('%:e')` | `md` |

## Inspecter

| Touche | Action |
|---|---|
| `:reg` `:reg +` | tous · un seul |
| `:echo @+` | contenu brut |

Colonne Type : `c` caractères · `l` lignes · `b` bloc ; `^J` = saut de ligne

---

**nvim · config, macOS, Ubuntu, dépannage**

## Config du presse-papier

nvim ne parle pas au système lui-même : il délègue à un outil externe (« provider »).

### Provider utilisé

| Touche | Action |
|---|---|
| macOS | `pbcopy` / `pbpaste`, déjà installés |
| Ubuntu Wayland | `wl-copy` / `wl-paste` (paquet `wl-clipboard`) |
| Ubuntu X11 | `xclip` ou `xsel` |
| Vérifier | `:checkhealth provider` → Clipboard `:echo has('clipboard')` → `1` |

### `y` / `p` système par défaut (`init.lua`)

```
vim.opt.clipboard = "unnamedplus"
```

| Touche | Action |
|---|---|
| `unnamedplus` | registre `"` lié à `+` |
| `unnamed` | lié à `*` (sélection primaire Linux) |

**Inconvénient** : chaque `dd` / `x` écrase aussi le presse-papier système ; parade : `"_d`

### Raccourci : copier le chemin du fichier

```
vim.keymap.set('n', '<leader>cp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Copié : ' .. path)
end, { desc = 'Copier chemin absolu' })
```

### Test minimal

| Touche | Action |
|---|---|
| 1. | `:let @+ = 'test'` |
| 2. | `:echo @+` → `test` |
| 3. | shell : `pbpaste` (macOS) ou `wl-paste` (Ubuntu) → `test` |

## macOS 26

Un seul presse-papier (« pasteboard »), le même partout, terminal compris. Touche clé : **`Cmd`, jamais `Ctrl`**.

### Raccourcis

| Touche | Action |
|---|---|
| `Cmd+C` `X` `V` | copier / couper / coller, y compris Terminal, iTerm2, Ghostty… |
| `Cmd+Shift+V` | coller sans mise en forme (Chrome, Slack, Electron) |
| `Cmd+Opt+Shift+V` | idem, apps Apple |
| `Ctrl+Shift+V` | ne colle rien (raccourci Linux) |

### Ligne de commande

| Touche | Action |
|---|---|
| `cmd \| pbcopy` | sortie → presse-papier |
| `pbpaste` | affiche le presse-papier |
| `pbpaste > f.txt` | l'écrit dans un fichier |
| `pwd \| pbcopy` | copier le dossier courant |
| `pbcopy < f.txt` | copier le contenu d'un fichier |
| `pbpaste \| wc -l` | compter les lignes copiées |

### Avec nvim

- `"+` et `"*` = même presse-papier
- `"+y` dans nvim → `Cmd+V` ou `pbpaste` ailleurs
- `Cmd+C` ailleurs → `"+p` dans nvim, ou `Cmd+V` en insertion
- Sans quitter : `:r !pbpaste` insère sous la ligne courante

## Ubuntu 24.04

Deux presse-papiers indépendants, et un serveur graphique (Wayland par défaut, ou X11) qui décide quel outil marche.

### Les deux presse-papiers

|  | CLIPBOARD | PRIMARY |
|---|---|---|
| Rempli par | `Ctrl+C` (apps), `Ctrl+Shift+C` (terminal) | simple surlignage souris |
| Collé par | `Ctrl+V` / `Ctrl+Shift+V` | clic molette |
| Registre | `"+` | `"*` |

**Pourquoi `Ctrl+Shift` dans le terminal** : `Ctrl+C` y envoie déjà un signal d'interruption.

**Connaître sa session** : `echo $XDG_SESSION_TYPE` → `wayland` ou `x11`

### Outils en ligne de commande

|  | Wayland | X11 |
|---|---|---|
| Installer | `sudo apt install wl-clipboard` | `sudo apt install xclip` |
| Copier | `cmd \| wl-copy` | `cmd \| xclip -sel c` |
| Coller | `wl-paste` | `xclip -sel c -o` |
| Primaire | `wl-copy -p` / `wl-paste -p` | `xclip` / `xclip -o` |

### Alias pour retrouver macOS (`~/.bashrc`, `~/.zshrc`)

```
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'
```

## Pièges et dépannage

| Symptôme | Cause | Correctif |
|---|---|---|
| `y` puis collage ailleurs : rien | `y` écrit dans `"`, pas dans `+` | `"+y` ou `clipboard=unnamedplus` |
| `Ctrl+Shift+V` ne colle rien sur Mac | raccourci Linux | `Cmd+V` |
| `:let @+ = …` sans réaction | normal : pas de message = succès | vérifier avec `:echo @+` |
| Le texte de la commande se retrouve dans le fichier | tapée en mode insertion (visible dans `".`) | `Esc` avant `:`, puis `u` |
| `"+` vide alors que copié | autre copie (`Cmd+C`, `dd` avec unnamedplus) a écrasé | recopier ; `"_d` pour supprimer sans écraser |
| `clipboard: No provider` | aucun outil installé (Linux) | `wl-clipboard` ou `xclip` |
| Ubuntu : copie OK dans nvim, pas ailleurs | `xclip` utilisé sous Wayland | installer `wl-clipboard`, relancer nvim |
| `p` colle la ligne supprimée, pas le mot copié | `dd` a écrasé `"` | `"0p` |
| Chemin incomplet avec `@%` | `%` est relatif au dossier de lancement | `expand('%:p')` |
| nvim via SSH : `"+` ne remonte pas | presse-papier distant ≠ local | nvim ≥ 0.10 gère OSC 52 si le terminal le supporte |

> **Réflexe de diagnostic** : `:reg` → `:checkhealth provider` → test `:let @+ = 'test'` + `pbpaste` / `wl-paste`
