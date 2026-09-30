# Dotfiles : `make` ou `make help` pour la liste des cibles.
#
# Profils :
#   make minimal   shell, bash, git (+ zsh s'il est installé) : sans brew, sans réseau, sans sudo
#   make full      minimal + brew + zsh et ses plugins + nvim, vscode, espanso (+ aerospace, karabiner sur Mac)
# Le contexte (perso, pro) vient de dotfiles-private, installé ensuite avec son propre stow.

SHELL := /bin/sh
REPO := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
REPO_NAME := $(notdir $(REPO))
OS := $(shell uname -s)
XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share

# Un brew tout juste installé n'est pas encore dans le PATH du shell appelant
export PATH := $(PATH):/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin

STOW = stow -d "$(REPO)" -t "$(HOME)" --no-folding

MINIMAL_PACKAGES = shell bash git
ifeq ($(OS),Darwin)
  APP_TARGETS = aerospace karabiner
  VSCODE_TARGET = $(HOME)/Library/Application Support/Code/User
else
  APP_TARGETS =
  VSCODE_TARGET = $(XDG_CONFIG_HOME)/Code/User
endif

.DEFAULT_GOAL := help
.PHONY: help minimal full shell bash zsh zsh-plugins git git-tools nvim vscode vscode-unfold \
	espanso aerospace karabiner brew brew-cleanup install-brew backup-rc need-stow \
	unfold clean-links dry-run uninstall check test bench

help:
	@echo "Profils"
	@echo "  minimal        shell, bash, git (+ zsh) : sans brew ni réseau (formation, CI)"
	@echo "  full           minimal + brew, zsh et plugins, nvim, vscode, espanso$(if $(APP_TARGETS), + $(APP_TARGETS))"
	@echo "Paquets"
	@echo "  shell bash zsh git nvim vscode espanso brew$(if $(APP_TARGETS), $(APP_TARGETS))"
	@echo "  zsh-plugins    télécharge zinit et les plugins (réseau), puis les active"
	@echo "  git-tools      active delta / git-lfs dans git s'ils sont installés"
	@echo "  brew-cleanup   liste ce qui est installé par brew mais absent des Brewfiles"
	@echo "Maintenance"
	@echo "  dry-run        montre ce que stow ferait pour le profil full"
	@echo "  unfold         remplace les dossiers repliés par un ancien stow par de vrais dossiers"
	@echo "  vscode-unfold  idem pour VSCode, en gardant l'état écrit par VSCode"
	@echo "  clean-links    supprime les liens morts vers ce repo (fichiers retirés du repo)"
	@echo "  uninstall      retire tous les liens posés par ce repo"
	@echo "  check          shellcheck + gitleaks (s'ils sont installés)"
	@echo "  test           banc Docker Ubuntu 24.04 nu, sans réseau"
	@echo "  bench          temps de démarrage de zsh et bash"

# ─── Profils ─────────────────────────────────────────────────────
minimal: need-stow backup-rc
	$(STOW) $(MINIMAL_PACKAGES)
	@if command -v zsh >/dev/null 2>&1; then $(STOW) zsh; fi
	@$(MAKE) --no-print-directory git-tools

full: install-brew brew minimal zsh git nvim vscode espanso $(APP_TARGETS) clean-links

# ─── Outils communs ──────────────────────────────────────────────
need-stow:
	@command -v stow >/dev/null 2>&1 || \
		{ echo "stow introuvable : sudo apt install stow (Linux), brew install stow (Mac)"; exit 1; }

# Sauvegarde les fichiers de démarrage existants (squelette Ubuntu, fichier réécrit
# par un installeur…) qui empêcheraient stow de poser ses liens
backup-rc:
	@for f in .bashrc .bash_profile .zshrc .p10k.zsh; do \
		if [ -f "$(HOME)/$$f" ] && [ ! -L "$(HOME)/$$f" ]; then \
			mv "$(HOME)/$$f" "$(HOME)/$$f.pre-dotfiles" && echo "sauvegarde : ~/$$f -> ~/$$f.pre-dotfiles"; \
		fi; \
	done

# ─── Shells ──────────────────────────────────────────────────────
shell: need-stow
	$(STOW) shell

bash: shell backup-rc
	$(STOW) bash

zsh: shell backup-rc
	$(STOW) zsh
	@$(MAKE) --no-print-directory zsh-plugins

# Plugins zsh : téléchargés ici (réseau requis), jamais au démarrage du shell.
# Le marqueur .dotfiles-ready autorise zinit.sh à charger les plugins ; il n'est posé
# que si un second démarrage ne télécharge plus rien.
# À relancer après l'ajout d'un plugin dans zsh/.config/zsh/zinit.sh.
ZINIT_HOME = $(XDG_DATA_HOME)/zinit/zinit.git
ZINIT_READY = $(XDG_DATA_HOME)/zinit/.dotfiles-ready

zsh-plugins:
	@command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || \
		{ echo "zsh-plugins : curl ou wget requis (snippets Oh My Zsh)"; exit 1; }
	@rm -f "$(ZINIT_READY)"
	@if [ ! -r "$(ZINIT_HOME)/zinit.zsh" ]; then \
		git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$(ZINIT_HOME)"; \
	fi
	@# Un zsh interactif charge zinit.sh, qui télécharge les plugins manquants
	DOTFILES_ZINIT_INSTALL=1 zsh -ic exit
	@out=$$(DOTFILES_ZINIT_INSTALL=1 zsh -ic exit 2>&1); \
	if printf '%s' "$$out" | grep -qE 'Downloading|ERROR'; then \
		printf '%s\n' "$$out"; echo "zsh-plugins : téléchargement incomplet, plugins non activés"; exit 1; \
	fi
	@touch "$(ZINIT_READY)" && echo "zsh-plugins : plugins activés"

# ─── Git ─────────────────────────────────────────────────────────
# Identité et signature : dotfiles-private. Credential helper : cf. git/.config/git/config
git: need-stow
	$(STOW) git
	@$(MAKE) --no-print-directory git-tools
	@# Hook gitleaks, seulement sur un clone git du repo
	@if git -C "$(REPO)" rev-parse --git-dir >/dev/null 2>&1; then git -C "$(REPO)" config core.hooksPath .githooks; fi

# Active les compléments git selon les outils présents (à relancer après un brew install)
GIT_TOOLS = delta git-lfs

git-tools:
	@mkdir -p "$(XDG_CONFIG_HOME)/git"
	@out="$(XDG_CONFIG_HOME)/git/tools.inc"; \
	echo "# Généré par make git-tools : ne pas éditer" > "$$out"; \
	for t in $(GIT_TOOLS); do \
		if command -v $$t >/dev/null 2>&1; then \
			printf '[include]\n\tpath = %s.inc\n' $$t >> "$$out"; \
			echo "git : $$t activé"; \
		fi; \
	done

# ─── Applications ────────────────────────────────────────────────
nvim: need-stow
	$(STOW) nvim

aerospace: need-stow
	$(STOW) aerospace

# Karabiner ne suit pas un karabiner.json en lien symbolique : tout le dossier
# ~/.config/karabiner est un lien vers le repo (d'où le .stow-local-ignore du paquet).
# Un dossier existant est sauvegardé, jamais supprimé.
karabiner:
	@dest="$(XDG_CONFIG_HOME)/karabiner"; src="$(REPO)/karabiner/.config/karabiner"; \
	if [ -L "$$dest" ] && [ "$$dest" -ef "$$src" ]; then echo "karabiner : déjà lié"; exit 0; fi; \
	if [ -L "$$dest" ]; then rm "$$dest"; \
	elif [ -e "$$dest" ]; then mv "$$dest" "$$dest.pre-dotfiles" && echo "sauvegarde : $$dest -> $$dest.pre-dotfiles"; fi; \
	mkdir -p "$(XDG_CONFIG_HOME)" && ln -s "$$src" "$$dest" && echo "karabiner : $$dest -> $$src"

# Sur Mac, espanso lit ~/Library/Application Support/espanso : lien vers ~/.config/espanso.
# Un dossier existant est sauvegardé, jamais supprimé.
espanso: need-stow
	$(STOW) espanso
	@if [ "$(OS)" = Darwin ]; then \
		lib="$(HOME)/Library/Application Support/espanso"; \
		if [ ! -L "$$lib" ]; then \
			if [ -e "$$lib" ]; then mv "$$lib" "$$lib.pre-dotfiles" && echo "sauvegarde : $$lib -> $$lib.pre-dotfiles"; fi; \
			ln -s "$(XDG_CONFIG_HOME)/espanso" "$$lib"; \
		fi; \
	fi
	@if command -v espanso >/dev/null 2>&1; then espanso restart >/dev/null 2>&1 || true; fi

vscode: need-stow
	@mkdir -p "$(VSCODE_TARGET)"
	stow -d "$(REPO)" -t "$(VSCODE_TARGET)" --no-folding vscode

# Un ancien stow a replié snippets/ et profiles/ de VSCode en liens vers le repo :
# VSCode écrit alors son état (extensions.json, globalStorage…) dans le repo.
# Remplace chaque lien par une copie réelle (l'état y reste), retire de la copie les
# fichiers versionnés, puis stow les relie. En cas d'échec, remet le lien.
# VSCode doit être fermé.
vscode-unfold: need-stow
	@if pgrep -f 'Visual Studio Code.app/Contents/MacO[S]' >/dev/null 2>&1 || pgrep -x code >/dev/null 2>&1; then \
		echo "vscode-unfold : ferme VSCode d'abord"; exit 1; \
	fi
	@cd "$(REPO)" && T="$(VSCODE_TARGET)"; links=""; \
	for d in snippets profiles; do \
		l="$$T/$$d"; \
		[ -L "$$l" ] && [ -d "$$l" ] && [ "$$l" -ef "vscode/$$d" ] || continue; \
		links="$$links $$d=$$(readlink "$$l")"; \
	done; \
	[ -n "$$links" ] || { echo "vscode : rien à déplier"; exit 0; }; \
	for dt in $$links; do \
		d=$${dt%%=*}; rm "$$T/$$d"; cp -Rp "vscode/$$d" "$$T/$$d"; \
		git ls-files "vscode/$$d" | while IFS= read -r f; do rm -f "$$T/$${f#vscode/}"; done; \
	done; \
	if ! stow -d "$(REPO)" -t "$$T" --no-folding vscode; then \
		for dt in $$links; do d=$${dt%%=*}; rm -rf "$$T/$$d"; ln -s "$${dt#*=}" "$$T/$$d"; done; \
		echo "vscode-unfold : échec, liens remis tels quels"; exit 1; \
	fi; \
	for dt in $$links; do echo "déplié : $$T/$${dt%%=*}"; done

# ─── Brew ────────────────────────────────────────────────────────
install-brew:
	@command -v brew >/dev/null 2>&1 || \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@command -v stow >/dev/null 2>&1 || brew install stow

# Brewfile public, puis ceux des contextes (~/.config/brew/Brewfile.*, dotfiles-private).
# Aucune désinstallation : cf. brew-cleanup.
brew: install-brew
	$(STOW) brew
	brew bundle --file="$(REPO)/brew/.config/brew/Brewfile"
	@for f in "$(XDG_CONFIG_HOME)"/brew/Brewfile.*; do \
		[ -r "$$f" ] || continue; echo "brew bundle : $$f"; brew bundle --file="$$f" || exit 1; \
	done
	@$(MAKE) --no-print-directory git-tools

# Liste ce qui est installé mais absent des Brewfiles. Pour désinstaller :
#   brew bundle cleanup --force --file=<fichier affiché>
brew-cleanup:
	@all=$$(mktemp); cat "$(REPO)/brew/.config/brew/Brewfile" "$(XDG_CONFIG_HOME)"/brew/Brewfile.* > "$$all" 2>/dev/null; \
	brew bundle cleanup --file="$$all"; echo "(Brewfiles réunis dans $$all)"

# ─── Maintenance ─────────────────────────────────────────────────
dry-run: need-stow
	$(STOW) -n -v $(MINIMAL_PACKAGES) zsh nvim espanso brew $(if $(filter aerospace,$(APP_TARGETS)),aerospace)

# Un ancien stow sans --no-folding a pu remplacer un dossier entier par un lien
# vers le repo (ex. ~/.config/git -> dotfiles-public/git/.config/git) : les
# outils écrivent alors dans le repo, et stow 2.4 refuse ensuite de le défaire.
# Retire ces liens (jamais le contenu du repo), vérifie avec stow -n, puis relance
# stow sur leurs paquets. En cas de conflit, remet les liens tels quels.
# Karabiner est laissé replié exprès (cf. make karabiner).
unfold: need-stow
	@links=""; pkgs=""; \
	for l in "$(HOME)"/.[!.]* "$(XDG_CONFIG_HOME)"/*; do \
		[ -L "$$l" ] && [ -d "$$l" ] || continue; \
		t=$$(readlink "$$l"); \
		case "$$t" in *"$(REPO_NAME)"/*) ;; *) continue ;; esac; \
		p=$${t#*$(REPO_NAME)/}; p=$${p%%/*}; \
		[ "$$p" = karabiner ] && continue; \
		links="$$links $$l=$$t"; pkgs="$$pkgs $$p"; \
	done; \
	if [ -z "$$pkgs" ]; then echo "rien à déplier"; exit 0; fi; \
	pkgs=$$(printf '%s\n' $$pkgs | sort -u | tr '\n' ' '); \
	restore() { for lt in $$links; do [ -e "$${lt%%=*}" ] || ln -s "$${lt#*=}" "$${lt%%=*}"; done; }; \
	abort() { \
		restore; \
		echo "unfold annulé, rien n'a changé. Déplace les fichiers en conflit ci-dessus"; \
		echo "(ex. mv ~/.zshrc ~/.zshrc.pre-dotfiles) puis relance make unfold."; \
		exit 1; \
	}; \
	for lt in $$links; do rm "$${lt%%=*}"; done; \
	if ! out=$$($(STOW) -n $$pkgs 2>&1); then \
		printf '%s\n' "$$out" | grep -v 'simulation mode' >&2; abort; \
	fi; \
	$(STOW) $$pkgs || abort; \
	for lt in $$links; do echo "déplié : $${lt%%=*}"; done; \
	echo "restow : $$pkgs"

# Liens morts vers ce repo, laissés par des fichiers renommés ou supprimés du repo
clean-links:
	@for d in "$(HOME)" "$(XDG_CONFIG_HOME)" "$(VSCODE_TARGET)"; do \
		[ -d "$$d" ] || continue; \
		depth=""; [ "$$d" = "$(HOME)" ] && depth="-maxdepth 1"; \
		find "$$d" $$depth -type l ! -exec test -e {} \; -print 2>/dev/null | while IFS= read -r l; do \
			case "$$(readlink "$$l")" in *"$(REPO_NAME)"/*) rm "$$l" && echo "lien mort retiré : $$l" ;; esac; \
		done; \
	done

uninstall: need-stow
	-$(STOW) -D $(MINIMAL_PACKAGES) zsh nvim espanso brew aerospace
	-stow -d "$(REPO)" -t "$(VSCODE_TARGET)" -D vscode 2>/dev/null
	@l="$(XDG_CONFIG_HOME)/karabiner"; if [ -L "$$l" ] && [ "$$l" -ef "$(REPO)/karabiner/.config/karabiner" ]; then rm "$$l" && echo "retiré : $$l"; fi
	@echo "Les sauvegardes *.pre-dotfiles sont restées en place."

# zsh/ exclu : shellcheck ne connaît pas zsh
SH_FILES = $(shell cd "$(REPO)" && git ls-files '*.sh' 'bash/.bash*' '.githooks/*' ':!zsh/')

check:
	@if command -v shellcheck >/dev/null 2>&1; then \
		cd "$(REPO)" && shellcheck -s bash -S warning -e SC1090,SC1091 $(SH_FILES) && echo "shellcheck : ok"; \
	else echo "shellcheck absent : ignoré"; fi
	@if command -v gitleaks >/dev/null 2>&1; then \
		cd "$(REPO)" && gitleaks detect --redact --no-banner && echo "gitleaks : ok"; \
	else echo "gitleaks absent : ignoré"; fi

# Banc d'essai : machine Ubuntu 24.04 nue, sans réseau
test:
	docker build -q -f tests/Dockerfile -t dotfiles-test "$(REPO)" >/dev/null
	docker run --rm --network none dotfiles-test

# Temps de démarrage (objectif : < 300 ms)
bench:
	@for sh in zsh bash; do \
		command -v $$sh >/dev/null 2>&1 || continue; \
		echo "$$sh :"; \
		bash -c "TIMEFORMAT='  %3R s'; for i in 1 2 3 4 5; do time $$sh -i -c exit >/dev/null 2>&1; done"; \
	done
