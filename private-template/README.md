# dotfiles-private

Tout ce qui dépend du contexte (perso, pro) ou qui ne doit pas être public.
Le repo public (dotfiles-public) fonctionne seul (mode formation) ; celui-ci ne fait
que remplir les emplacements qu'il prévoit.

> Ce dossier est un **modèle** versionné dans dotfiles-public (`private-template/`).
> Les valeurs sont fictives (`example.org`, `entreprise.example`) : copie-le, puis remplace-les.

## Structure

```
dotfiles-private/
├── .stowrc          --target=~ --no-folding (comme le repo public)
├── common/          toutes les machines
│   └── .config/shell/local.d/   secrets.sh (wrappers with_secret), agent-vm.sh, tchap.sh
├── perso/           Mac perso
│   └── .config/git/git-user     identité + signature perso
└── pro/             poste Ubuntu du boulot
    ├── .config/git/git-user     identité + signature pro
    ├── .config/shell/local.d/   pro.sh (proxy), eclipse.sh
    └── .config/vscode/settings.d/50-pro.json   réglages VSCode pro (proxy, IA coupée…)
```

Un seul paquet de contexte par machine : `perso` et `pro` fournissent tous deux `git-user`.

## Installation

```sh
cd ~/dotfiles/dotfiles-public && make zsh git       # ou make minimal
cd ~/dotfiles/dotfiles-private && stow common perso # Mac perso
cd ~/dotfiles/dotfiles-private && stow common pro   # Ubuntu pro
```

## Ce que le repo public fournit

| Emplacement / fonction | Rôle |
|---|---|
| `~/.config/shell/local.d/*.sh` | chargés en dernier par `init.sh` (bash et zsh), après les outils |
| `~/.config/git/git-user` | identité par défaut de la machine (inclus par la config git publique) |
| `~/.config/git/perso.inc`, `pro.inc` | identité selon le dossier : repos sous `~/perso/` ou `~/pro/` |
| `~/.config/git/local.inc` | réglages git propres à la machine (credential helper…) |
| `proxy on\|off\|status` | proxy HTTP(S) à partir de `DOTFILES_PROXY_URL` et `DOTFILES_NO_PROXY` |
| `secret set\|get\|rm NOM` | trousseau du système (macOS : security, Ubuntu : secret-tool) |
| `with_secret VAR NOM cmd…` | lance `cmd` avec `VAR` = secret, sans l'exporter dans le shell |
| `~/.config/vscode/settings.d/*.json` | couches de réglages VSCode, fusionnées par-dessus le commun par `make vscode` |
| `path_prepend DOSSIER` | ajoute au PATH si le dossier existe, sans doublon |
| `$DOTFILES_SHELL` | `bash` ou `zsh`, pour les outils qui s'initialisent différemment |

Règles d'un fichier de `local.d` : aucune sortie, pas de réseau, garde en première
ligne si un outil est nécessaire (`command -v X >/dev/null 2>&1 || return 0`).

## Secrets

Jamais dans ce repo, même privé. Une fois par machine :

```sh
secret set snyk-token
```

Sur Ubuntu, `secret-tool` vient du paquet `libsecret-tools`.

## Migration depuis l'ancien dotfiles-private

1. Copier ce modèle : `cp -R ~/dotfiles/dotfiles-public/private-template/. ~/dotfiles/dotfiles-private/`
2. **git** : reporter nom, e-mail et clé de l'ancien `git-user` dans `perso/…/git-user`
   (et `pro/…/git-user`). La signature (`gpgsign`) y est déjà : elle a quitté le repo public.
3. **Proxy** : reporter l'ancien bloc proxy/no_proxy de `.bashrc` dans `pro/…/local.d/pro.sh`
   (`DOTFILES_PROXY_URL`, `DOTFILES_NO_PROXY`).
4. **Snyk** : l'ancien `snyk.sh` est remplacé par `common/…/secrets.sh` ; enregistrer le
   jeton avec `secret set snyk-token`. Le jeton révoqué ne doit plus apparaître nulle part.
5. **Espanso** : `dgfip.yml` → `pro/.config/espanso/match/`, `me.yml` → `common/.config/espanso/match/`.
6. **Brew** (facultatif) : paquets propres au boulot dans `pro/.config/brew/Brewfile.pro`,
   installés par `make brew` du repo public.
7. **VSCode** : reporter dans `pro/.config/vscode/settings.d/50-pro.json` les vraies valeurs
   (proxy…), puis `make vscode` dans le repo public pour régénérer `settings.json`.
8. Installer (cf. ci-dessus), ouvrir un shell, vérifier : `git config user.email`, `proxy status`.
9. Supprimer du repo public les modules désormais ici : `tools.d/agent-vm.sh`,
   `tools.d/tchap.sh`, `tools.d/eclipse.sh`.
