XDG_CONFIG_HOME ?= $(HOME)/.config
STOW = stow -t $(HOME)

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
	stow -t "$$VSCODE_TARGET" vscode


# ─── Bootstrap ───────────────────────────────────────────────────
install-brew:
	@which brew > /dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

install-stow: install-brew
	# Nécessaire car brew n'est pas encore dans le PATH (il faut que bash soit lancé)
	@if ! which stow > /dev/null 2>&1; then \
		BREW=$$(which brew 2>/dev/null \
			|| ls /opt/homebrew/bin/brew \
			|| ls /home/linuxbrew/.linuxbrew/bin/brew \
			|| ls /usr/local/bin/brew); \
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
	brew bundle --cleanup --file=$(XDG_CONFIG_HOME)/Brewfile --force

# ─── Installations complètes ─────────────────────────────────────
install-all: brew git bash vscode
