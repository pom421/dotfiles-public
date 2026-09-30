# Dotfiles

Mes dotfiles pour macOS (perso) et Ubuntu (boulot), en bash et zsh, installés avec
[GNU Stow](https://www.gnu.org/software/stow/). Trois principes :

- **Fonctionne partout, même nu** : sur une machine sans brew ni outils (formation,
  serveur), `make minimal` donne un bash, un zsh et un git fonctionnels, sans réseau.
- **Un outil = un endroit** : tout ce qui concerne un outil (alias, fonctions, PATH,
  complétion) est dans un seul fichier, qui ne fait rien si l'outil est absent.
- **Rien de personnel ici** : identités, proxy, secrets et réglages pro vivent dans
  un repo privé, qui ne fait que remplir les emplacements prévus ici.

## Installation

```sh
git clone https://github.com/pom421/dotfiles-public ~/dotfiles/dotfiles-public
cd ~/dotfiles/dotfiles-public
make            # liste des cibles
```

| Situation | Commande |
|---|---|
| Machine de formation, serveur, CI | `make minimal` (il faut seulement `stow` : `sudo apt install stow`) |
| Mac ou Ubuntu complet | `make full` (installe brew si besoin, puis tout le reste) |
| Contexte perso / pro | ensuite, dans dotfiles-private : `stow common perso` ou `stow common pro` |

### Ubuntu : le minimum avec apt, le reste avec brew

Seuls les prérequis de l'installeur Homebrew viennent d'apt (il clone son dépôt avec
git, avant que brew n'existe), plus `libsecret-tools` pour la fonction `secret`, qui
doit parler au trousseau de la session. Tout le reste, git et zsh compris, vient du
Brewfile et passe devant dans le PATH.

```sh
sudo apt install -y build-essential procps curl file git libsecret-tools
make full
```

zsh vient alors de brew. Pour en faire le shell de connexion, il doit être déclaré
dans `/etc/shells` :

```sh
echo /home/linuxbrew/.linuxbrew/bin/zsh | sudo tee -a /etc/shells
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh
```

Les fichiers existants qui gênent (`~/.bashrc` d'Ubuntu, `~/.zshrc` réécrit par un
installeur…) sont sauvegardés en `*.pre-dotfiles`, jamais supprimés.

## Organisation

Chaque dossier à la racine est un paquet stow, relié dans `~` par `make <paquet>`.

```
shell/.config/shell/
├── init.sh        chargé par ~/.bashrc et ~/.zshrc
├── core/          socle sans dépendance : navigation, fichiers, historique, éditeur, PATH, proxy
├── os/            darwin.sh, linux.sh (dont Homebrew, avant les outils)
├── tools.d/       un fichier par outil : fzf.sh, zoxide.sh, nvm.sh, secret.sh…
└── local.d/       vide ici, rempli par dotfiles-private (chargé en dernier)
bash/  zsh/        ce qui est propre à chaque shell (options, prompt, plugins zsh)
git/               config git portable + includes (tools.inc, git-user, perso.inc, pro.inc)
nvim/ vscode/ espanso/ aerospace/ karabiner/ brew/
private-template/  modèle du repo privé, avec la marche à suivre
tests/             banc Docker : Ubuntu 24.04 nu, sans réseau
```

Un paquet qui a sa propre config peut aussi apporter son module shell :
`git/.config/shell/tools.d/git.sh` atterrit dans `~/.config/shell/tools.d/`.

### Où mettre quoi ?

1. Ça contient une identité, une adresse interne, un secret ou c'est propre au boulot ?
   → **dotfiles-private** (`local.d/`, `git-user`, `Brewfile.pro`). Un secret : `secret set NOM`.
2. Ça ne concerne qu'un outil (alias, fonction, init, complétion) ?
   → `tools.d/<outil>.sh`, ou le paquet de l'outil s'il en a un (`git/`, `nvim/`…).
3. Ça ne dépend que de l'OS ? → `os/darwin.sh` ou `os/linux.sh`.
4. Ça ne dépend que du shell (options, prompt) ? → `bash/.bashrc` ou `zsh/`.
5. Ça marche partout sans rien installer ? → `core/`.

### Règles d'un module de `tools.d`

```sh
# yazi : explorateur de fichiers en terminal
command -v yazi >/dev/null 2>&1 || return 0   # garde : rien si l'outil est absent

y() { … }
```

- aucune sortie, pas de réseau au démarrage ;
- un alias peut ajouter des options à sa commande (`ll='ls -alFh'`, `rm='rm -Iv'`),
  jamais la remplacer par un autre outil (`ls=eza`, `cat=bat`) — vérifié par `make test` ;
- les fonctions appellent `command rm`, `command mkdir`… pour ne pas hériter de ces options ;
- `$DOTFILES_SHELL` (`bash` ou `zsh`) pour les outils qui s'initialisent différemment ;
- `compdef` peut être appelé librement en zsh : il est rejoué après `compinit`.

## Au quotidien

| Besoin | Commande |
|---|---|
| Quels fichiers sont chargés ? | `DOTFILES_DEBUG=1 zsh -i -c exit` |
| Temps de démarrage | `make bench` |
| Proxy du boulot | `proxy on`, `proxy off`, `proxy status` |
| Secret dans le trousseau | `secret set NOM`, `with_secret VAR NOM commande…` |
| Après un `brew install delta` / `git-lfs` | `make git-tools` |
| Après l'ajout d'un plugin zsh | `make zsh-plugins` (le shell ne télécharge jamais rien) |
| Fichier supprimé du repo | `make clean-links` |
| Paquets brew en trop | `make brew-cleanup` (liste seulement) |
| Profils VSCode modifiés (Mac) | `make vscode-export`, puis commit de `vscode/profiles.json` |
| Retrouver les profils VSCode ailleurs | `make vscode-import` (VSCode fermé) |
| Vérifier avant de pousser | `make check` (shellcheck, gitleaks) et `make test` (Docker) |

## Migration depuis l'ancienne version

Un ancien `stow` sans `--no-folding` a pu relier des dossiers entiers au repo : les
outils écrivent alors dans le repo. `make unfold` (et `make vscode-unfold`, VSCode
fermé) les remplace par de vrais dossiers, et annule tout en cas de conflit.
Karabiner est l'exception : il exige que `~/.config/karabiner` soit un lien de dossier
(`make karabiner`).

## Inspirations

- https://github.com/shakeelmohamed/stow-dotfiles/tree/main
