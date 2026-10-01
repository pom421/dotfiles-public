# Chargé par init.sh après os/<os>.sh (PATH et HOMEBREW_PREFIX posés) et avant tools.d.
# Au niveau principal, pas dans une fonction : un `declare` y deviendrait local.

# bash-completion (git, make, apt…) : le ~/.bashrc par défaut d'Ubuntu le chargeait,
# /etc/bash.bashrc ne le fait pas. Version brew d'abord.
# Avant fzf (tools.d/fzf.sh) : fzf enrobe les complétions déjà en place (cd, kill…) et
# la complétion par défaut ; chargé après, bash-completion les écraserait et
# cd **<Tab> ou ps **<Tab> ne lanceraient plus fzf.
if [[ $- == *i* ]] && ! shopt -oq posix; then
  for _f in "${HOMEBREW_PREFIX:-/nonexistent}/etc/profile.d/bash_completion.sh" \
    /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    if [ -r "$_f" ]; then . "$_f"; break; fi
  done
  unset _f
fi
