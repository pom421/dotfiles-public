# Claude sandbox

*v1 · 2026-11-14* — sbx = Docker Sandboxes · `␣` = leader de nvim · pourquoi et limites : `docs/ide.md`

---

**claude · dans une microVM (sbx)**

## Lancer Claude

| Touche | Action |
|---|---|
| `projet` | onglet `claude` en microVM |
| `claude-vm` | idem, hors herdr |
| `claude-vm ~/pro/app` | pour un autre dossier |
| `claude-vm -- --continue` | options de claude après `--` |
| `PROJET_CLAUDE=host projet` | Claude sur la machine |

**Une microVM par projet**, créée au premier lancement puis reprise (outils installés, historique de Claude). Nom : dossier + empreinte du chemin.

## Ce que voit Claude

| Touche | Action |
|---|---|
| projet | lecture et écriture, même chemin |
| reste du disque | rien (`~/.ssh`, trousseau…) |
| réseau | via un proxy filtrant |
| identifiants | ajoutés par le proxy, hors VM |
| réseau local | non (ni nvim, ni localhost) |

## Ce qui reste exposé

**Secrets du projet** (`.env`) : lisibles. Les garder dans le trousseau (`secret get`).

**Ce que Claude écrit, je l'exécute** plus tard sur la machine : scripts `package.json`, `Makefile`, `.git/hooks`, `.envrc`. Relire avant de lancer.

**Pousser depuis la machine** (onglet git), pas depuis la microVM.

## Travailler avec nvim

| Touche | Action |
|---|---|
| `␣ay` | copier `@fichier` (+ lignes en visuel) |
| `Cmd-V` | coller dans Claude |
| automatique | nvim relit les fichiers modifiés |
| `␣gd` | relire le diff (façon VS Code) |
| `A-3` | lazygit : indexer, committer |

> **Exemple** : `V` `j` `j` `␣ay` → `A-1` → « simplifie ça » `Cmd-V` : `@src/app.ts (lignes 12-14)`.

## Gérer les microVM

| Touche | Action |
|---|---|
| `sbx` | tableau de bord |
| `sbx ls` | lister |
| `sbx stop nom` | arrêter, état gardé |
| `sbx rm nom` | supprimer |
| `sbx prune` | supprimer celles à l'arrêt |
| `sbx exec -it nom bash` | shell dans la VM |
| `sbx ports nom --publish 3000` | publier un port |

## Réseau

| Touche | Action |
|---|---|
| `sbx policy ls` | règles en place |
| `sbx policy allow network docs.rs` | autoriser un site |
| `sbx policy reset` | choisir la politique |

**Balanced** (défaut) : IA, registres de paquets, GitHub… autorisés, le reste bloqué. **Locked Down** : presque rien. **Open** : tout. Une doc bloquée : l'autoriser plutôt que tout ouvrir.

## Mode machine (host)

| Touche | Action |
|---|---|
| `/ide` | dans Claude : lier à nvim |
| `␣as` | envoyer la sélection |
| `␣ab` | fichier dans le contexte |
| `␣aa` `␣ad` | accepter / refuser le diff |
| `/sandbox` | bac à sable natif des commandes |

Code de confiance seulement : Claude a mes droits sur tout le disque.

## Installer (une fois)

**Mac** : `make brew` (cask `docker/tap/sbx`).

**Ubuntu 24.04** (pas de formule brew) : dépôt apt de Docker puis paquet :

```
curl -fsSL https://get.docker.com \
  | sudo REPO_ONLY=1 sh
sudo apt install docker-sbx
sudo usermod -aG kvm $USER
```

Puis se reconnecter. Prérequis : `ls /dev/kvm` (virtualisation active ; dans une VM, imbriquée).

**Puis** : `sbx login` (compte Docker, gratuit), et `/login` dans Claude au premier lancement.

## Pièges

**herdr et l'état de Claude** (travaille, bloqué…) : détecté à l'écran ; à vérifier en microVM, les hooks de `herdr integration` n'y entrent pas.

**Lent sur un gros projet** : `git status`, `node_modules`… passent par le partage de fichiers.

**Signature des commits** : clé absente de la VM. Committer depuis lazygit.
