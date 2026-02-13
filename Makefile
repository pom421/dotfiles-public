.PHONY: shell bash zsh git vscode

shell:
	stow -t $(HOME) shell

bash: shell
	stow -t $(HOME) bash

zsh: shell
	stow -t $(HOME) zsh

git:
	@CRED_HELPER=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "osxkeychain"; else echo "store"; fi) && \
	stow -t $(HOME) git && \
	git config --global credential.helper "$$CRED_HELPER"

vscode:
	@VSCODE_TARGET=$$(if [ "$$(uname -s)" = "Darwin" ]; then echo "$$HOME/Library/Application Support/Code/User"; else echo "$$HOME/.config/Code/User"; fi) && \
	mkdir -p "$$VSCODE_TARGET" && \
	cd $(HOME)/dotfiles/dotfiles-public && \
	stow -t "$$VSCODE_TARGET" vscode
