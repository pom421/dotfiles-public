# delta : pager de diff avec coloration syntaxique (https://github.com/dandavison/delta)
# Inclus par tools.inc seulement si delta est installé (make git-tools)
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	hyperlinks = true
	side-by-side = true
