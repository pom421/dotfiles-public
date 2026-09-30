# wikidocs : copie un lien Docs (La Suite) au format Markdown, titre compris
{ command -v curl && command -v jq; } >/dev/null 2>&1 || return 0

# Instances : https://docs.numerique.gouv.fr/, https://docs.suite.anct.gouv.fr/
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

  # eval : ces commandes ont des arguments, que zsh ne découpe pas dans une variable
  local url uuid base api_url title
  url=$(eval "$clip_read")
  uuid=$(echo "$url" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}')
  if [[ -z "$uuid" ]]; then
    echo "Erreur : pas d'UUID dans le presse-papier" >&2
    return 1
  fi

  base=$(echo "$url" | grep -oE 'https://[^/]+')
  api_url="${base}/api/v1.0/documents/${uuid}/content/?content_format=markdown"
  title=$(curl -sf "$api_url" | jq -r '.title')
  if [[ -z "$title" || "$title" == "null" ]]; then
    echo "Erreur : titre introuvable (document privé ou instance non compatible ?)" >&2
    return 1
  fi

  local link="[${title}](${url%/}/)"
  printf '%s' "$link" | eval "$clip_write"
  echo "Copié : $link"
}
