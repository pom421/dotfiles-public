.PHONY: shell bash zsh git

shell:
	stow -t $(HOME) shell

bash: shell
	stow -t $(HOME) bash

zsh: shell
	stow -t $(HOME) zsh
