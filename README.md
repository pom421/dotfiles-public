# Dotfiles

Mes dotfiles pour macOS (perso, zsh) et Ubuntu (boulot, bash), installés avec
[GNU Stow](https://www.gnu.org/software/stow/). Trois principes :

- **Fonctionne partout, même nu** : sur une machine sans brew ni outils (formation,
  serveur), `make minimal` donne un bash, un zsh et un git fonctionnels, sans réseau.
- **Un outil = un endroit** : tout ce qui concerne un outil (alias, fonctions, PATH,
  complétion) est dans un seul fichier, qui ne fait rien si l'outil est absent.
- **Rien de personnel ici** : identités, proxy, secrets et réglages pro vivent dans
  un repo privé, qui ne fait que remplir les emplacements prévus ici.

## Installation

Le repo se clone toujours au même endroit, puis `make` liste les cibles :

```sh
git clone https://github.com/pom421/dotfiles-public ~/dotfiles/dotfiles-public
cd ~/dotfiles/dotfiles-public
make
```

`make full` fait tout ce qu'il faut pour le système sur lequel il tourne (il détecte
l'OS). Il peut être relancé sans risque : les liens déjà posés sont laissés tels quels,
et les fichiers existants qui gênent (`~/.bashrc` d'Ubuntu, `~/.zshrc` réécrit par un
installeur…) sont sauvegardés en `*.pre-dotfiles`, jamais supprimés.

### Différences entre Mac et Linux

| | macOS (perso) | Ubuntu (boulot) |
|---|---|---|
| Shell | zsh, avec zinit, Powerlevel10k et plugins | bash, avec bash-completion |
| Avant brew | outils en ligne de commande Xcode (git, make) | quelques paquets apt (cf. plus bas) |
| Homebrew | `/opt/homebrew` | `/home/linuxbrew/.linuxbrew` |
| Brewfile | outils communs + applications (casks), tart, borders, trash | outils communs |
| Applications | Ghostty, VSCode, espanso, AeroSpace, Karabiner | Ghostty, VSCode, espanso |
| Config VSCode | `~/Library/Application Support/Code/User` | `~/.config/Code/User` |
| Réglages VSCode | commun + couche perso (IA, GitHub…) | commun + couche pro (proxy, IA coupée…) |
| Profils VSCode | machine source : `make vscode-export` | machine cible : `make vscode-import` |
| Secrets (`secret`) | trousseau macOS (`security`) | trousseau GNOME (`secret-tool`) |
| Contexte privé | `stow common perso` | `stow common pro` (identité pro, proxy) |
| `ls` | `ls -GF` (couleurs BSD) | `ls -F --color=auto` (couleurs GNU) |

Tout le reste est commun : la config `shell/` (alias, fonctions, modules d'outils) est
chargée à l'identique par zsh sur Mac et par bash sur Linux, et la config git est la même.

### macOS

**Première installation**

```sh
xcode-select --install
git clone https://github.com/pom421/dotfiles-public ~/dotfiles/dotfiles-public
cd ~/dotfiles/dotfiles-public
make full
cd ~/dotfiles/dotfiles-private
stow common perso
exec zsh
```

- `xcode-select --install` fournit git et make, nécessaires avant brew.
- `make full` installe brew s'il manque, le Brewfile, zsh et ses plugins, git, nvim,
  VSCode, espanso, Ghostty, AeroSpace et Karabiner.
- Le repo privé apporte l'identité git (avec la signature GPG) et les secrets : cf.
  `private-template/README.md`.

**Mise à jour** : `git pull` puis `make full`.

**Particularités**

- Karabiner exige que `~/.config/karabiner` soit un lien de **dossier** vers le repo
  (il ne recharge pas un `karabiner.json` en lien) : c'est ce que fait `make karabiner`.
- Ghostty : la config du repo va dans `~/.config/ghostty/config` ; celle de
  `~/Library/Application Support/com.mitchellh.ghostty/` est mise de côté, car elle
  aurait le dernier mot. L'Option **droite** sert d'Alt (Alt-j / Alt-k dans nvim),
  l'Option gauche garde les caractères AZERTY (`| { } [ ] ~ \`).
- VSCode : cf. la section [VSCode](#vscode) pour le travail entre les deux machines.

### Linux (Ubuntu)

**Prérequis** : apt ne fournit que ce dont l'installeur Homebrew a besoin avant que brew
n'existe (il clone son dépôt avec git), plus `libsecret-tools`, en version native pour
parler au trousseau de la session. Tout le reste vient du Brewfile, git compris (celui de
brew passe ensuite devant dans le PATH).

```sh
sudo apt install -y build-essential procps curl file git libsecret-tools
```

- `build-essential` : compilateur et `make`, pour les rares formules sans binaire
  précompilé et pour lancer `make` avant brew ;
- `procps` (`ps`, `pgrep`) et `file` : utilisés par brew ; déjà présents sur une Ubuntu
  de bureau ;
- `curl` et `git` : télécharger et cloner Homebrew, cloner ce repo.

**Derrière le proxy du boulot**, `echo $https_proxy` doit afficher le proxy avant
`make full` : brew et git en ont besoin pour télécharger. Une fois le repo privé en
place, `proxy on` s'en charge à chaque ouverture de shell.

**Première installation**

```sh
git clone https://github.com/pom421/dotfiles-public ~/dotfiles/dotfiles-public
cd ~/dotfiles/dotfiles-public
make full
cd ~/dotfiles/dotfiles-private
stow common pro
secret set snyk-token
exec bash
```

Puis, VSCode fermé, `make vscode-import` recrée les profils (TypeScript, Python…) avec
leurs réglages et leurs extensions.

**Depuis une ancienne installation de ces dotfiles**

```sh
cd ~/dotfiles/dotfiles-public
git pull --ff-only
make install-brew
make unfold
make clean-links
make full
exec bash
```

- `make install-brew` passe en premier : stow vient désormais de brew.
- `make unfold` : un ancien `stow` sans `--no-folding` a pu relier des dossiers entiers
  au repo (les outils écrivaient alors dans le repo) ; il les remplace par de vrais
  dossiers, et annule tout en cas de conflit. Idem pour VSCode avec
  `make vscode-unfold`, VSCode fermé.
- Si `git pull` refuse (historique réécrit lors de la purge des secrets), et seulement
  si `git status` est propre : `git fetch origin && git reset --hard origin/main`.
- Relire `~/.bashrc.pre-dotfiles` : l'ancien bloc proxy s'y trouve sans doute, à
  reporter dans le repo privé.

**Particularités**

- bash reste le shell de connexion. bash-completion est chargé par notre `.bashrc`,
  comme le faisait le `~/.bashrc` d'Ubuntu qu'il remplace.
- Sans session graphique (ssh), `secret-tool` n'a pas de trousseau : `secret` ne
  fonctionne alors pas.

### Machine de formation, serveur, CI

```sh
sudo apt install -y stow
git clone https://github.com/pom421/dotfiles-public ~/dotfiles/dotfiles-public
cd ~/dotfiles/dotfiles-public
make minimal
```

Sans brew, sans réseau, sans repo privé : bash (et zsh s'il est installé) avec la config
commune, et un git fonctionnel. Aucune identité git n'est devinée : la donner par repo
(`git config user.email …`) avant de commiter.

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
| Quels fichiers sont chargés ? | `DOTFILES_DEBUG=1 zsh -i -c exit` (ou `bash`) |
| Temps de démarrage | `make bench` |
| Proxy du boulot | `proxy on`, `proxy off`, `proxy status` |
| Secret dans le trousseau | `secret set NOM`, `with_secret VAR NOM commande…` |
| Après un `brew install delta` / `git-lfs` | `make git-tools` |
| Après l'ajout d'un plugin zsh | `make zsh-plugins` (le shell ne télécharge jamais rien) |
| Fichier supprimé du repo | `make clean-links` |
| Paquets brew en trop | `make brew-cleanup` (liste seulement) |
| VSCode (réglages, extensions, profils) | cf. [VSCode](#vscode) |
| Vérifier avant de pousser | `make check` (shellcheck, gitleaks) et `make test` (Docker) |

## VSCode

Le but : la même expérience d'édition et les mêmes extensions sur les deux machines,
avec des règles d'environnement (proxy, IA, forge, sécurité) propres à chaque contexte.

### Ce qui est partagé, et comment

| Élément | Où | Arrive sur la machine par |
|---|---|---|
| Réglages d'édition | `vscode/settings.json` (commun) | `make vscode` (fichier généré) |
| Réglages de contexte (IA, proxy, forge, sécurité) | dotfiles-private, `perso/` ou `pro/` : `.config/vscode/settings.d/50-*.json` | `stow common perso` (ou `pro`), puis `make vscode` |
| Réglages d'une seule machine | `~/.config/vscode/settings.d/90-local.json`, hors de tout repo | `make vscode` |
| Raccourcis, snippets | `vscode/keybindings.json`, `vscode/snippets/` | liens vers le repo |
| Réglages d'un profil (TypeScript, Doc Writer…) | `vscode/profiles/<dossier>/` | liens vers le repo |
| Liste des profils et extensions de chacun | `vscode/profiles.json` | `make vscode-import` |
| Extensions du profil par défaut | Brewfile (`vscode "…"`) | `make brew` |

### Réglages par couches

`settings.json` n'est pas un lien mais un fichier **généré** par `make vscode`, qui
fusionne dans l'ordre (la dernière couche l'emporte) :

1. `vscode/settings.json` : commun à toutes les machines ;
2. `vscode/settings.d/darwin.json` ou `linux.json` : ce qui dépend de l'OS (facultatif) ;
3. `~/.config/vscode/settings.d/*.json` : le contexte, fourni par dotfiles-private
   (`50-pro.json` : proxy, IA coupée…), puis la machine (ex. `90-local.json`).

Un objet étend celui de la couche précédente, une autre valeur le remplace, `null` le
supprime. Un réglage changé depuis l'interface de VSCode n'est pas perdu : `make vscode`
le sauvegarde en `settings.json.pre-dotfiles`, et `make vscode-settings-drift` le montre
avant, pour le reporter dans la bonne couche. Raccourcis, snippets et profils restent
des liens vers le repo.

### Où ranger un réglage

1. Expérience d'édition (éditeur, langages, apparence, comportement d'une extension
   d'édition), télémétrie → **commun** : `vscode/settings.json`.
2. Règle d'environnement (réseau, proxy, sécurité, forge, IA, mises à jour) → **couche de
   contexte**, dans dotfiles-private (`perso/` ou `pro/`).
3. Ne dépend que de l'OS → `vscode/settings.d/darwin.json` ou `linux.json`.
4. Propre à une seule machine → `~/.config/vscode/settings.d/90-local.json`.

Jamais dans le repo : chemins absolus, adresses internes, et ce qu'une extension écrit
pour elle-même (ex. `yaml.schemas` de Continue, qui contient un chemin versionné).

### Workflow entre les deux machines

Toute modification passe par un commit sur la machine où elle est faite ; l'autre machine
la récupère avec `git pull`, puis `make vscode`.

**Un réglage d'édition, changé depuis l'interface de VSCode**

```sh
cd ~/dotfiles/dotfiles-public
make vscode-settings-drift
```

La commande liste ce qui a changé depuis la dernière génération. Reporter les réglages
voulus dans `vscode/settings.json` (ou dans une couche de contexte, cf. ci-dessus), puis :

```sh
make vscode
git commit -am "vscode: …"
git push
```

Plus simple encore : modifier directement `vscode/settings.json`, puis `make vscode`.

**Un réglage de contexte** : le modifier dans dotfiles-private (`perso/…/50-perso.json`
ou `pro/…/50-pro.json`), commit et push dans ce repo, puis `make vscode` dans le repo
public, sur chaque machine de ce contexte.

**Un raccourci ou un snippet existant** : le modifier depuis VSCode suffit, le fichier est
un lien vers le repo. Commit et push ; sur l'autre machine, `git pull`.

**Un nouveau fichier de snippets** : VSCode le crée hors du repo, dans son dossier
`snippets/`. Le déplacer dans `vscode/snippets/` (ou `vscode/profiles/<location>/snippets/`
pour un profil), puis `make vscode`, commit et push ; sur l'autre machine, `git pull` et
`make vscode`.

**Une extension**

- Dans le profil par défaut : ajouter `vscode "éditeur.extension"` au Brewfile, puis
  `make brew` ; sur l'autre machine, `git pull` et `make brew`.
- Dans un profil (TypeScript…) : l'installer depuis VSCode dans ce profil, puis
  `make vscode-export` et commit de `vscode/profiles.json` ; sur l'autre machine,
  `git pull` puis, VSCode fermé, `make vscode-import`.

**Un nouveau profil** : le créer dans VSCode, puis `make vscode-export` et commit de
`vscode/profiles.json`. Pour versionner aussi ses réglages, déplacer son `settings.json`
dans le repo (le dossier est la `location` indiquée dans `profiles.json`) :

```sh
mv "<dossier User de VSCode>/profiles/<location>/settings.json" vscode/profiles/<location>/
make vscode
```

Sur l'autre machine : `git pull` puis, VSCode fermé, `make vscode-import`.

**Après chaque `git pull`** : `make vscode` (régénère `settings.json`, relie les nouveaux
fichiers), et `make vscode-import` si `vscode/profiles.json` a changé.

### Pièges

- `make vscode` remplace une modification faite depuis l'interface : elle est sauvegardée
  en `settings.json.pre-dotfiles`, mais une seule fois. Lancer `make vscode-settings-drift`
  avant, pour la reporter.
- Une extension qui écrit dans les réglages (Continue et `yaml.schemas`) : la modification
  apparaît dans `make vscode-settings-drift` ; ne pas la recopier dans le commun.
- `make vscode-import` et `make vscode-unfold` demandent VSCode fermé.
- Pour comparer deux fichiers de réglages quelconques (ex. après une longue divergence) :
  `node scripts/vscode-settings-diff.mjs <A> <B>`.

## Inspirations

- https://github.com/shakeelmohamed/stow-dotfiles/tree/main
