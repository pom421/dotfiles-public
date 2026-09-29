# git-lfs : stockage des gros fichiers (https://git-lfs.com)
# Inclus par tools.inc seulement si git-lfs est installé (make git-tools)
[filter "lfs"]
	process = git-lfs filter-process
	required = true
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
