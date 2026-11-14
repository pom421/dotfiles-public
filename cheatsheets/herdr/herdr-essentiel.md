# herdr essentiel

*v1 · 2026-11-14* — `C-b` = préfixe (Ctrl+b, relâcher, puis la touche) · `A-1` = Option droite+1 · philosophie : `docs/ide.md`

---

**herdr · projets, onglets, agents**

## Lancer · revenir

| Touche | Action |
|---|---|
| `projet` | projet du dossier courant |
| `projet ~/pro/app` | projet d'un dossier |
| `projet app` | par son nom (zoxide) |
| `herdr` | revenir dans la session |
| `C-b q` | détacher (tout continue) |
| `herdr server stop` | tout arrêter |

**`projet` ne duplique rien** : si le projet est ouvert, il y retourne.

## Les 4 onglets d'un projet

| Touche | Action |
|---|---|
| `A-1` | `claude` : Claude (microVM) |
| `A-2` | `nvim` : l'éditeur |
| `A-3` | `git` : lazygit |
| `A-4` | `term` : shell libre |

Aussi `C-b 1`…`C-b 9`. Un programme quitté (`:q`, `q`) laisse le shell de l'onglet : relancer `nvim`, `lazygit`…

## Onglets

| Touche | Action |
|---|---|
| `C-b n` `C-b p` | suivant / précédent |
| `C-b c` | nouvel onglet |
| `C-b T` | renommer |
| `C-b X` | fermer |

## Projets (workspaces)

| Touche | Action |
|---|---|
| `C-b w` | choisir un projet |
| `C-b g` | aller à… (projet, onglet) |
| `C-b N` | nouveau, vide |
| `C-b W` | renommer |
| `C-b D` | fermer le projet |
| `C-b b` | barre latérale on/off |

## Panneaux (dans un onglet)

| Touche | Action |
|---|---|
| `C-b v` | couper à droite |
| `C-b -` | couper en dessous |
| `C-b h` `j` `k` `l` | aller au panneau |
| `C-b Tab` | panneau suivant |
| `C-b z` | plein écran on/off |
| `C-b r` | redimensionner (flèches) |
| `C-b x` | fermer le panneau |

> **Exemple** : Onglet claude → `C-b v` → `npm run dev` : le serveur tourne à côté de Claude.

## Agents (barre latérale)

| Touche | Action |
|---|---|
| working | Claude travaille |
| blocked | attend ma réponse |
| done | a fini, pas encore vu |
| idle | au repos |

| Touche | Action |
|---|---|
| `C-b o` | aller à l'agent qui a notifié |

L'état remonte au projet : on voit d'un coup d'œil quel projet attend.

## Texte · souris

| Touche | Action |
|---|---|
| `C-b e` | historique du panneau dans l'éditeur |
| molette | défiler |
| clic | choisir panneau, onglet, projet |
| bordure | glisser pour redimensionner |

`C-b e` : chercher, copier dans une longue sortie avec les touches de nvim.

## Réglages · aide

| Touche | Action |
|---|---|
| `C-b ?` | toutes les touches |
| `C-b s` | réglages |
| `C-b R` | relire la config |
| `herdr config check` | valider la config |
| `herdr --default-config` | toutes les options |

Config : `herdr/.config/herdr/config.toml` du repo (`make herdr`).

## Rôles : herdr ou nvim ?

**herdr** découpe entre programmes : Claude, nvim, lazygit, un serveur.

**nvim** découpe le code : splits, explorateur, diagnostics, diff, débogage. Ses fenêtres partagent LSP, registres et undo.

**Un seul nvim par projet** : deux nvim = deux fois les serveurs LSP en mémoire.

## Pièges

**`C-b` dans nvim** (page précédente) est pris par herdr : utiliser `C-u`.

**`A-1` sur Mac** : Option **droite** (Option gauche tape les caractères AZERTY).

**Redémarrer le serveur** arrête les programmes : herdr recrée projets et onglets, avec des shells neufs.

**`C-b X`, `C-b D`** (majuscules) ferment ; `C-b x` ne ferme qu'un panneau.
