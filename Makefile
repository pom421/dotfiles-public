XDG_CONFIG_HOME ?= $(HOME)/.config
BREW_BIN = $$( if [ -x /opt/homebrew/bin/brew ]; then echo /opt/homebrew/bin/brew; elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then echo /home/linuxbrew/.linuxbrew/bin/brew; elif [ -x /usr/local/bin/brew ]; then echo /usr/local/bin/brew; fi )
STOW_BIN = $$( if command -v stow >/dev/null 2>&1; then command -v stow; elif [ -x /opt/homebrew/bin/stow ]; then echo /opt/homebrew/bin/stow; elif [ -x /home/linuxbrew/.linuxbrew/bin/stow ]; then echo /home/linuxbrew/.linuxbrew/bin/stow; elif [ -x /usr/local/bin/stow ]; then echo /usr/local/bin/stow; fi )
STOW = $(STOW_BIN) -t $(HOME)

.PHONY: shell bash zsh git vscode brew deps-mac deps-linux install-brew install-stow

# ─── Shell de base ───────────────────────────────────────────────
shell: install-stow
	$(STOW) shell

bash: shell
	$(STOW) bash

zsh: shell
	$(STOW) zsh

# ─── Git ─────────────────────────────────────────────────────────
git: install-stow
	# Pour la conservation du mdp, en mac, utilisation de osxkeychain, pour Linux de store
	@CRED_HELPER=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "osxkeychain"; else echo "store"; fi) && \
	$(STOW) git && \
	git config --global credential.helper "$$CRED_HELPER"
	# utiliser dotfiles-private `stow -t git` pour ajouter les informations utilisateur

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
	# Nécessaire car brew n'est pas encore dans le PATH (il faut que bash soit lancé)
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
	$(BREW_BIN) bundle --cleanup --file=$(XDG_CONFIG_HOME)/Brewfile --force

# ─── Installations complètes ─────────────────────────────────────
install-all: brew git bash vscode
