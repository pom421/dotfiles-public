XDG_CONFIG_HOME ?= $(HOME)/.config
STOW = stow -t $(HOME)

.PHONY: shell bash zsh git vscode brew-mac brew-linux devbox deps-mac deps-linux install-brew install-devbox install-stow

# ─── Shell de base ───────────────────────────────────────────────
shell:
	$(STOW) shell

bash: shell
	$(STOW) bash

zsh: shell
	$(STOW) zsh

# ─── Git ─────────────────────────────────────────────────────────
git:
	# Pour la conservation du mdp, en mac, utilisation de osxkeychain, pour Linux de store 
	@CRED_HELPER=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "osxkeychain"; else echo "store"; fi) && \
	$(STOW) git && \
	git config --global credential.helper "$$CRED_HELPER"
	# utiliser dotfiles-private `stow -t git` pour ajouter les informations utilisateur

# ─── VSCode ──────────────────────────────────────────────────────
vscode:
	@VSCODE_TARGET=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "$$HOME/Library/Application Support/Code/User"; else echo "$$HOME/.config/Code/User"; fi) && \
	mkdir -p "$$VSCODE_TARGET" && \
	cd $(HOME)/dotfiles/dotfiles-public && \
	stow -t "$$VSCODE_TARGET" vscode

# ─── Bootstrap ───────────────────────────────────────────────────
install-brew:
	@which brew > /dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

install-devbox:
	@which devbox > /dev/null 2>&1 || curl -fsSL https://get.jetify.com/devbox | bash

install-stow:
	@which stow > /dev/null 2>&1 || devbox global add stow

# ─── Devbox ──────────────────────────────────────────────────────
devbox: install-devbox install-stow
	$(STOW) devbox
	devbox global install --config $(XDG_CONFIG_HOME)/devbox

# ─── Brew (casks + vscode extensions) ───────────────────────────
brew: install-brew
	$(STOW) brew-mac
	brew bundle --cleanup --file=$(XDG_CONFIG_HOME)/Brewfile --force

# ─── Installations complètes ─────────────────────────────────────
install-all-mac: devbox brew-mac git zsh vscode

install-all-linux: devbox git zsh
