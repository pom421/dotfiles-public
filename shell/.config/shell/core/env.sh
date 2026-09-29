# Premier éditeur disponible (git s'en sert pour les messages de commit)
for EDITOR in nvim vim vi nano; do
  command -v "$EDITOR" >/dev/null 2>&1 && break
done
export EDITOR
export VISUAL="$EDITOR"
