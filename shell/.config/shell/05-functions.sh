#!/bin/sh

# fonction md : mkdir + cd
mkcd() {
    mkdir -p -- "$1" && cd -P -- "$1"
}

# affiche le process qui utilise tel port
function show-port() {
    echo "Command: lsof -nP -iTCP:$1 | grep LISTEN"
    lsof -nP -iTCP:$1 | grep LISTEN
    echo "Hint: type listening"
}


# liste les process qui utilisent un port.
# ex: listening 80
function listening() {
    if [ $# -eq 0 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

function git-ls() {
  for branch in `git branch -a`
    do
    if [ $branch != "*" ]; then
        hasAct=$(git log --abbrev-commit --date=relative -1 $branch)
        lastActivity=$(echo "$hasAct" | grep Date: | sed 's/Date: //')
        echo "$branch last activity was $lastActivity"
    fi
    done
}

# Yazi call which cd the directory on yazi exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	if [ -n "$ZSH_VERSION" ]; then
		IFS= read -r -d '' cwd < "$tmp"
	else
		IFS= read -r -d '' cwd < "$tmp"
	fi
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
