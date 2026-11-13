# Aides communes aux bancs (sourcé par tests/full.sh et tests/nvim.sh).
# Continue après un échec pour tout lister ; le total est dans $failures.
failures=${failures:-0}

check() {
  local desc=$1 out
  shift
  if out=$("$@" 2>&1); then
    printf 'ok   %s\n' "$desc"
  else
    printf 'FAIL %s\n' "$desc"
    [ -n "$out" ] && printf '%s\n' "$out" | tail -20 | sed 's/^/     | /'
    failures=$((failures + 1))
  fi
}

in_tty() {
  script -qec "$1" /dev/null | tr -d '\r'
  return "${PIPESTATUS[0]}"
}

silent() {
  local out
  out=$(in_tty "$1") || { printf '%s\n' "$out"; return 1; }
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}
