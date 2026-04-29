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

## Pour récupérer un lien en format Wiki depuis une instance de docs (https://docs.numerique.gouv.fr/ ou https://docs.suite.anct.gouv.fr/)
wikidocs() {
  if command -v pbpaste &>/dev/null; then
    local clip_read="pbpaste"
    local clip_write="pbcopy"
  elif command -v xclip &>/dev/null; then
    local clip_read="xclip -selection clipboard -o"
    local clip_write="xclip -selection clipboard"
  elif command -v xsel &>/dev/null; then
    local clip_read="xsel --clipboard --output"
    local clip_write="xsel --clipboard --input"
  else
    echo "Erreur : aucun outil presse-papier trouvé (pbpaste, xclip ou xsel requis)" >&2
    return 1
  fi

  local url=$($clip_read)
  local uuid=$(echo "$url" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}')
  if [[ -z "$uuid" ]]; then
    echo "Erreur : pas d'UUID dans le presse-papier" >&2
    return 1
  fi

  local base=$(echo "$url" | grep -oE 'https://[^/]+')
  local api_url="${base}/api/v1.0/documents/${uuid}/content/?content_format=markdown"
  local title=$(curl -sf "$api_url" | jq -r '.title')
  if [[ -z "$title" || "$title" == "null" ]]; then
    echo "Erreur : titre introuvable (document privé ou instance non compatible ?)" >&2
    return 1
  fi

  local link="[${title}](${url%/}/)"
  echo -n "$link" | $clip_write
  echo "Copié : $link"
}
