# npq : audit des paquets npm avant installation
command -v npq >/dev/null 2>&1 || return 0

export NPQ_PKG_MGR=bun
