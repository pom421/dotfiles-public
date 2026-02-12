# fonction md : mkdir + cd
md() {
    mkdir -p -- "$1" && cd -P -- "$1"
}

function showFiles() {
    defaults write com.apple.Finder AppleShowAllFiles true
    killall Finder
}

function hideFiles() {
    defaults write com.apple.Finder AppleShowAllFiles true
    killall Finder
}

function remove-dstore() {
    find . -name '.DS_Store' -type f -delete
}

# affiche le process qui utilise tel port
function show-port() {
    echo "Command: lsof -nP -iTCP:$1 | grep LISTEN"
    lsof -nP -iTCP:$1 | grep LISTEN
    echo "Hint: type listening"
}

function show-process() {
    echo "Command: ps aux | grep $1"
    ps aux | grep $1
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
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
