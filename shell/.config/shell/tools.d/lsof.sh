# lsof : qui écoute sur quel port
command -v lsof >/dev/null 2>&1 || return 0

# Process qui écoute sur un port. Ex : show-port 8080
show-port() {
  echo "Command: lsof -nP -iTCP:$1 | grep LISTEN"
  lsof -nP -iTCP:"$1" | grep LISTEN
  echo "Hint: type listening"
}

# Liste les process en écoute, filtrés par motif. Ex : listening node
listening() {
  if [ $# -eq 0 ]; then
    lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color "$1"
  else
    echo "Usage: listening [pattern]"
  fi
}
