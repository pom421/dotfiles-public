XDG_CONFIG_HOME ?= $(HOME)/.config
BREW_BIN = $$( if [ -x /opt/homebrew/bin/brew ]; then echo /opt/homebrew/bin/brew; elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then echo /home/linuxbrew/.linuxbrew/bin/brew; elif [ -x /usr/local/bin/brew ]; then echo /usr/local/bin/brew; fi )
STOW_BIN = $$( if command -v stow >/dev/null 2>&1; then command -v stow; elif [ -x /opt/homebrew/bin/stow ]; then echo /opt/homebrew/bin/stow; elif [ -x /home/linuxbrew/.linuxbrew/bin/stow ]; then echo /home/linuxbrew/.linuxbrew/bin/stow; elif [ -x /usr/local/bin/stow ]; then echo /usr/local/bin/stow; fi )
STOW = $(STOW_BIN) -t $(HOME)

.PHONY: shell bash zsh git vscode brew deps-mac deps-linux install-brew install-stow espanso minimal test git-tools unfold
# ─── Shell de base ───────────────────────────────────────────────
shell: install-stow
	$(STOW) shell

bash: shell
	$(STOW) bash

zsh: shell
	$(STOW) zsh

# ─── Git ─────────────────────────────────────────────────────────
# Identité et signature : dotfiles-private. Credential helper : cf. git/.config/git/config
git: install-stow
	$(STOW) --no-folding git
	@$(MAKE) --no-print-directory git-tools
	@# Hook gitleaks, seulement sur un clone git du repo
	@if git rev-parse --git-dir >/dev/null 2>&1; then git config core.hooksPath .githooks; fi

# Active les compléments git selon les outils présents (à relancer après un brew install)
GIT_TOOLS = delta git-lfs

git-tools:
	@out="$(XDG_CONFIG_HOME)/git/tools.inc"; \
	echo "# Généré par make git-tools : ne pas éditer" > "$$out"; \
	for t in $(GIT_TOOLS); do \
		if command -v $$t >/dev/null 2>&1; then \
			printf '[include]\n\tpath = %s.inc\n' $$t >> "$$out"; \
			echo "git : $$t activé"; \
		fi; \
	done

# ─── VSCode ──────────────────────────────────────────────────────
vscode: install-stow
	# stow -t nécessaire car vscode doit cibler le dossier de configuration de VSCode
	@VSCODE_TARGET=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "$$HOME/Library/Application Support/Code/User"; else echo "$$HOME/.config/Code/User"; fi) && \
	mkdir -p "$$VSCODE_TARGET" && \
	cd $(HOME)/dotfiles/dotfiles-public && \
	"$(STOW_BIN)" -t "$$VSCODE_TARGET" vscode


# ─── Bootstrap ───────────────────────────────────────────────────
install-brew:
	@if [ -n "$(BREW_BIN)" ]; then \
			echo "brew deja installe"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

install-stow: install-brew
	@if [ -z "$(STOW_BIN)" ]; then \
		BREW="$(BREW_BIN)"; \
		if [ -z "$$BREW" ]; then \
			echo "brew introuvable"; \
			exit 1; \
		fi; \
		$$BREW install stow; \
	fi

# ─── Brew (casks + vscode extensions) ───────────────────────────
brew: install-stow
	@OS=$$(uname -s); \
	if [ "$$OS" = "Darwin" ]; then \
		$(STOW) brew-mac; \
	elif [ "$$OS" = "Linux" ]; then \
		$(STOW) brew-linux; \
	else \
		echo "OS non supporte: $$OS"; \
		exit 1; \
	fi
	$(BREW_BIN) bundle --cleanup --file=$(XDG_CONFIG_HOME)/brew/Brewfile --force

# --- Espanso ------------------------------------------------------
espanso:
	@OS=$$(uname -s); \
	if [ "$$OS" = "Darwin" ]; then \
	  $(STOW) espanso; \
	  espanso stop 2>/dev/null || true; \
	  if [ ! -L "$$HOME/Library/Application Support/espanso" ]; then \
	    rm -rf "$$HOME/Library/Application Support/espanso"; \
	    ln -s "$$HOME/.config/espanso" "$$HOME/Library/Application Support/espanso"; \
	  fi; \
	  espanso start; \
	fi

# ─── Minimal : sans brew ni réseau (formation, CI) ───────────────
MINIMAL_PACKAGES = shell bash git

minimal:
	@command -v stow >/dev/null 2>&1 || { echo "stow introuvable : sudo apt install stow (Linux) ou brew install stow (Mac)"; exit 1; }
	@# Sauvegarde les fichiers existants (ex. squelette Ubuntu) qui bloqueraient stow
	@for f in .bashrc .bash_profile .zshrc; do \
		if [ -f "$(HOME)/$$f" ] && [ ! -L "$(HOME)/$$f" ]; then \
			mv "$(HOME)/$$f" "$(HOME)/$$f.pre-dotfiles" && echo "sauvegarde : ~/$$f -> ~/$$f.pre-dotfiles"; \
		fi; \
	done
	stow --no-folding -t $(HOME) $(MINIMAL_PACKAGES)
	@if command -v zsh >/dev/null 2>&1; then stow --no-folding -t $(HOME) zsh; fi
	@$(MAKE) --no-print-directory git-tools

# ─── Dépliage (migration vers --no-folding) ──────────────────────
# Un ancien stow sans --no-folding a pu remplacer un dossier entier par un lien
# vers le repo (ex. ~/.config/git -> dotfiles-public/git/.config/git) : les
# outils écrivent alors dans le repo, et stow 2.4 refuse ensuite de le défaire.
# Retire ces liens (jamais le contenu du repo), vérifie avec stow -n, puis relance
# stow sur leurs paquets. En cas de conflit, remet les liens tels quels.
REPO_NAME = $(notdir $(CURDIR))

unfold:
	@links=""; pkgs=""; \
	for l in "$(HOME)"/.[!.]* "$(HOME)"/.config/*; do \
		[ -L "$$l" ] && [ -d "$$l" ] || continue; \
		t=$$(readlink "$$l"); \
		case "$$t" in *"$(REPO_NAME)"/*) ;; *) continue ;; esac; \
		p=$${t#*$(REPO_NAME)/}; \
		links="$$links $$l=$$t"; pkgs="$$pkgs $${p%%/*}"; \
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
	if ! out=$$(stow -n --no-folding -t "$(HOME)" $$pkgs 2>&1); then \
		printf '%s\n' "$$out" | grep -v 'simulation mode' >&2; abort; \
	fi; \
	stow --no-folding -t "$(HOME)" $$pkgs || abort; \
	for lt in $$links; do echo "déplié : $${lt%%=*}"; done; \
	echo "restow : $$pkgs"

# ─── Tests : machine Ubuntu 24.04 nue, sans réseau ───────────────
test:
	docker build -q -f tests/Dockerfile -t dotfiles-test . >/dev/null
	docker run --rm --network none dotfiles-test

# ─── Installations complètes ─────────────────────────────────────
install-all: brew git bash vscode
