# L'IDE : philosophie

Mon environnement de développement n'est pas un seul programme. C'est une chaîne de petits outils,
chacun avec **un rôle** et un seul. Ce mémo explique ce découpage et les choix qui vont avec. Les
touches sont dans les fiches (`cheatsheets/`).

```
Ghostty    la fenêtre : police, couleurs, clavier (Option droite = Alt)
└─ herdr   les projets : un workspace par projet, des onglets, des sessions qui survivent
   ├─ 1 claude   Claude Code, enfermé dans une microVM (sbx)
   ├─ 2 nvim     l'éditeur : lire, écrire, naviguer dans le code
   ├─ 3 git      lazygit : relire, indexer, committer, pousser
   └─ 4 term     un shell libre : serveur de dev, tests, commandes ponctuelles
```

`projet` (dans un dossier, ou `projet dotfiles` avec zoxide) ouvre ce workspace, ou y revient s'il
existe déjà. Les onglets ont toujours le même numéro, d'où `Alt+1` … `Alt+4` sans réfléchir.

## Qui fait quoi

| Besoin | Outil | Pas |
|---|---|---|
| Plusieurs projets ouverts, persistants | herdr (workspaces) | onglets Ghostty, sessions nvim |
| Passer de l'éditeur à Claude ou à git | herdr (onglets) | terminal dans nvim |
| Voir où en est chaque agent | herdr (barre latérale : travaille, bloqué, fini) | aller voir chaque onglet |
| Éditer, naviguer, refactorer | nvim | Claude pour une modif de 3 lignes |
| Panneaux d'interface : explorateur, diagnostics, plan, diff, débogage, tests | splits de nvim | splits de herdr |
| Comparer deux fichiers, coder le test à côté de l'implémentation | splits de nvim | deux nvim dans deux panneaux herdr |
| Faire tourner un serveur à côté de Claude | split de herdr (onglet claude ou term) | `:terminal` |
| Relire et committer le travail de Claude | lazygit (onglet git), `␣gd` dans nvim | laisser Claude committer et pousser |

### Les splits : herdr ou nvim ?

D'accord avec l'idée de départ, avec une nuance. herdr gère la **disposition du travail** (quel
outil est à l'écran). nvim gère la **disposition du code**.

- **herdr** découpe entre programmes différents : Claude à gauche, le serveur de dev à droite.
- **nvim** découpe entre buffers d'un même projet. Ses fenêtres partagent tout : serveurs LSP,
  registres (copier-coller), historique des sauts, undo. Deux nvim dans deux panneaux herdr, ce sont
  deux fois les serveurs LSP en mémoire, et un `yy` d'un côté qui ne se colle pas de l'autre.

Règle simple : **un seul nvim par projet**. On y splitte pour comparer du code, et ses panneaux
d'interface (explorateur `␣e`, diagnostics `␣xx`, diff `␣gd`…) s'ouvrent dedans. Le reste va dans un
onglet ou un panneau herdr.

Ce qui reste dans nvim par commodité, sans être la voie normale : le terminal flottant `␣tt` et
lazygit flottant `␣gg`, pour une commande ou un commit sans quitter le fichier.

## Claude dans une microVM

Claude Code lit, écrit et lance des commandes. Sur la machine, il le fait avec mes droits : clés SSH,
jetons dans `~/.npmrc`, trousseau, autres projets. Une erreur, une dépendance piégée ou une
injection de prompt suffisent pour qu'il les lise ou les envoie ailleurs.

Il tourne donc dans une **microVM** Docker Sandboxes (`sbx`) : un vrai noyau à part, pas un simple
conteneur. Elle ne voit que le dossier du projet, monté **au même chemin** que sur la machine (les
chemins dans ses réponses restent valables dans nvim). Son réseau passe par un proxy filtrant. Mes
identifiants Claude n'y entrent pas : le proxy les ajoute aux requêtes en sortie.

### Ce que la microVM protège, et ce qu'elle ne protège pas

- **Protégé** : tout ce qui est hors du projet (`~/.ssh`, `~/.config`, les autres dépôts, le
  trousseau), et la machine elle-même (Claude peut casser sa VM, pas mon système).
- **Exposé** : tout le dossier du projet, en lecture et en écriture. D'où :
  - pas de secret dans le projet (`.env` avec de vrais jetons) : ils restent dans le trousseau
    (`secret get`, module `secret.sh`) ;
  - **ce que Claude écrit s'exécute plus tard sur la machine** quand c'est moi qui le lance :
    scripts de `package.json`, `Makefile`, hooks dans `.git/hooks`, `.envrc`. Relire avant de lancer
    (lazygit montre tout, `.git/hooks` compris s'il change : `ls -la .git/hooks`) ;
  - le `git push` se fait depuis la machine (onglet git), pas depuis la microVM.

### Deux modes

| | microVM (défaut) | machine (`PROJET_CLAUDE=host projet`) |
|---|---|---|
| Isolation | forte : VM, proxy réseau | faible : bac à sable de Claude (`/sandbox`) pour ses commandes seulement |
| Lien avec nvim (`/ide`) : sélection, diffs à accepter | non (la VM n'atteint pas le réseau local) | oui |
| Suivi dans herdr (travaille, bloqué, fini) | oui, en lisant l'écran du pane (`HERDR_AGENT=claude`) | oui, par les hooks (`herdr integration install claude`) |
| Pour quoi | travail autonome, dépendances inconnues, code d'autrui | aller-retour serré sur du code de confiance |

Dans les deux modes, `␣ay` dans nvim copie une référence (`@src/app.ts (lignes 10-20)`) à coller dans
Claude, et nvim recharge tout seul les fichiers que Claude modifie.

### Alternatives écartées

| Outil | Pourquoi pas en premier choix |
|---|---|
| agent-vm (Lima, utilisé avant) | VM complète par projet : 4 Go de RAM et des Go de disque chacune ; identifiants Claude stockés dans la VM ; projet d'une seule personne |
| `/sandbox` de Claude Code seul | pas de VM : limite les commandes lancées par Claude, pas ses lectures ; reste le mode « machine » |
| Devcontainer, Docker simple | noyau partagé avec la machine (Docker Desktop sur Mac : une VM pour tous les conteneurs) |
| Apple `container` | microVM, mais macOS seulement |
| Cloud (E2B, Daytona…) | le code part chez un tiers, coût à l'usage |

sbx gagne sur le duo sécurité / confort : microVM par projet, mêmes chemins, identifiants hors de la
VM, Mac et Ubuntu 24.04, gratuit en local. Ses limites : compte Docker obligatoire, KVM requis sous
Linux (pas de microVM dans une VM sans virtualisation imbriquée), outil jeune qui bouge vite.

## Le flux de travail

1. `projet` : le workspace s'ouvre, Claude démarre dans l'onglet 1.
2. Demander à Claude. Pendant qu'il travaille, lire le code dans l'onglet 2 ; la barre de herdr
   signale quand il attend une réponse ou a fini.
3. Relire : `␣gd` (diff façon VS Code) dans nvim, ou l'onglet 3 (lazygit) fichier par fichier.
4. Committer dans lazygit, pousser depuis la machine.
5. Fermer le terminal ou détacher (`C-b q`) : tout continue. `projet` ou `herdr` pour revenir.

## Mac et Ubuntu

Même chaîne sur les deux, installée par `make full` : Ghostty, herdr, nvim et lazygit viennent du
Brewfile. Seule exception : sbx sous Linux, paquet apt `docker-sbx` du dépôt Docker (pas de formule
brew), documenté dans `cheatsheets/claude/claude-sandbox`.

## Où sont les réglages

| Outil | Config | Fiche |
|---|---|---|
| herdr | `herdr/.config/herdr/config.toml`, `shell/.config/shell/tools.d/herdr.sh` (`projet`) | `cheatsheets/herdr/` |
| sbx | `shell/.config/shell/tools.d/sbx.sh` (`claude-vm`) | `cheatsheets/claude/` |
| nvim | `nvim/.config/nvim/` | `cheatsheets/nvim-*/` |
| Ghostty | `ghostty/.config/ghostty/config` | — |
