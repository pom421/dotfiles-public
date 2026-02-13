## Dotfiles

Here are my dotfiles, for mac and Linux, in bash and zsh (at least, it's the objective).

I use stow which is pretty simple.
For some more advanced usage, the use of Make is necessary, like in cases where dependancies are needed (zsh needs shell, for example).

## Usage

```shell
make zsh # install shell (common aliases, etc..) and zsh

make bash # install shell (common aliases, etc..) and bash

make git # install git 

make vscode # install vscode configuration, with caring if the OS is MacOS or Linux
```

## TODO

- [ ] VSCode (see ~/Library/Application Support/Code/User/profiles/cf5ad2a/settings.json for TS and ~/Library/Application Support/Code/User/profiles/-330303e4/settings.json for MD)
- [ ] karabiner
- [ ] aerospace
- [ ] nvim
- [ ] Obsidian


### Inspirations

- https://github.com/shakeelmohamed/stow-dotfiles/tree/main
