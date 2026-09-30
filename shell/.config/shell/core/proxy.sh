# Proxy HTTP(S) à la demande : proxy on | off | status
# L'adresse vient du contexte (dotfiles-private, local.d/) :
#   DOTFILES_PROXY_URL=http://proxy.example.com:3128
#   DOTFILES_NO_PROXY=localhost,127.0.0.1,.example.com   (facultatif)
proxy() {
  case "${1:-status}" in
    on)
      if [ -z "${DOTFILES_PROXY_URL-}" ]; then
        echo "proxy : DOTFILES_PROXY_URL non défini (à mettre dans ~/.config/shell/local.d/)" >&2
        return 1
      fi
      export http_proxy="$DOTFILES_PROXY_URL" https_proxy="$DOTFILES_PROXY_URL"
      export HTTP_PROXY="$DOTFILES_PROXY_URL" HTTPS_PROXY="$DOTFILES_PROXY_URL"
      export no_proxy="${DOTFILES_NO_PROXY:-localhost,127.0.0.1}"
      export NO_PROXY="$no_proxy"
      ;;
    off)
      unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
      ;;
    status)
      if [ -n "${https_proxy-}" ]; then
        echo "proxy actif : $https_proxy (sauf $no_proxy)"
      else
        echo "proxy inactif"
      fi
      ;;
    *)
      echo "Usage : proxy [on|off|status]" >&2
      return 1
      ;;
  esac
}
