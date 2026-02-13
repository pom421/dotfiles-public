.PHONY: shell bash zsh git vscode

shell:
	stow -t $(HOME) shell

bash: shell
	stow -t $(HOME) bash

zsh: shell
	stow -t $(HOME) zsh

vscode:
	VSCODE_TARGET="$$(case $$(uname -s) in Darwin) echo "$$HOME/Library/Application Support/Code/User" ;; *) echo "$$HOME/.config/Code/User" ;; esac)" && \
	mkdir -p "$$VSCODE_TARGET" && \
	cd $(HOME)/dotfiles/dotfiles-public && \
	stow -t "$$VSCODE_TARGET" vscode

