#!/usr/bin/env bash
# Vérifications de nvim sur une Ubuntu où la config est installée (make nvim) : plugins,
# parsers, :checkhealth, coloration. Lancé par tests/full.sh et par `make test-nvim`.
set -u
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=tests/lib.sh
. tests/lib.sh

echo "== nvim"
NVIM_CONF=nvim/.config/nvim
DATA=$HOME/.local/share/nvim

formulas_in_brewfile() {
  local missing=""
  for f in $(grep -v '^#' tests/nvim-formulas.txt); do
    grep -qE "^\s*brew \"$f\"" brew/.config/brew/Brewfile || missing="$missing $f"
  done
  [ -z "$missing" ] || { echo "absentes du Brewfile :$missing"; return 1; }
}
check "formules de tests/nvim-formulas.txt présentes dans le Brewfile" formulas_in_brewfile

# Installe les plugins puis les cale sur lazy-lock.json (pin = true : c'est le lockfile qui décide)
plugins_locked() {
  nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1
  local bad=""
  while IFS=' ' read -r name commit; do
    [ "$(git -C "$DATA/lazy/$name" rev-parse HEAD 2>/dev/null)" = "$commit" ] || bad="$bad $name"
  done < <(sed -nE 's/^  "([^"]+)": \{ "branch": "[^"]*", "commit": "([0-9a-f]+)" \},?$/\1 \2/p' "$NVIM_CONF/lazy-lock.json")
  [ -z "$bad" ] || { echo "plugins absents ou pas au commit du lockfile :$bad"; return 1; }
}
check "nvim : plugins installés aux commits de lazy-lock.json" plugins_locked

# Langages déclarés dans treesitter.lua (bloc `local languages = { … }`)
LANGS=$(sed -n '/^local languages = {/,/^}/p' "$NVIM_CONF/lua/plugins/treesitter.lua" | sed 's/--.*//' | grep -oE '"[a-z_0-9]+"' | tr -d '"')

parsers_installed() {
  local list
  list=$(printf "'%s'," $LANGS)
  # nvim-treesitter compile les parsers en tâche de fond au démarrage : on attend chacun
  # (pas un nombre de fichiers : certains en tirent d'autres, ex. xml → dtd)
  # Jusqu'à 3 sessions : chaque démarrage relance l'installation de ceux qui manquent (un
  # téléchargement ou une compilation peut échouer ponctuellement, comme au premier lancement réel)
  local missing try
  for try in 1 2 3; do
    nvim --headless "+lua vim.wait(600000, function() for _, l in ipairs({ $list }) do if vim.uv.fs_stat('$DATA/site/parser/' .. l .. '.so') == nil then return false end end return true end, 2000)" +qa >/tmp/ts-install.log 2>&1
    missing=""
    for l in $LANGS; do [ -f "$DATA/site/parser/$l.so" ] || missing="$missing $l"; done
    [ -z "$missing" ] && return 0
    echo "session $try, parsers absents :$missing"
    grep -iE 'error|fail' /tmp/ts-install.log | tail -5
  done
  return 1
}
check "nvim : parsers treesitter compilés" parsers_installed

check "nvim : outils Mason installés (:MasonSync)" nvim --headless "+MasonSync" +qa

checkhealth_clean() {
  # Dans un vrai terminal : avec une interface, les plugins chargés à l'événement VeryLazy
  # (which-key…) le sont aussi, et snacks remplace vim.ui.input / select.
  # DISPLAY factice : nvim détecte alors xclip comme sous X11 (pas d'écran dans le conteneur)
  rm -f /tmp/health.txt
  in_tty "stty cols 120 rows 40; DISPLAY=:0 nvim '+lua vim.defer_fn(function() vim.cmd(\"checkhealth\"); vim.cmd(\"w! /tmp/health.txt\"); vim.cmd(\"qa!\") end, 5000)'" >/dev/null
  [ -s /tmp/health.txt ] || { echo "rapport :checkhealth absent"; return 1; }
  # Alertes admises :
  # - conteneur : pas d'ouvreur d'URL (xdg-open), terminal sans protocole d'images (kitty, Ghostty…)
  # - Mason : langages qu'il sait gérer mais dont on n'installe aucun outil (Go, PHP, Java…)
  # - snacks : ses modules non activés (« setup {disabled} ») ; snacks.image : pas de ghostscript
  #   (aperçu des PDF, inutile) ni de mmdc (Mermaid : aperçu navigateur), ni de parsers typst, vue, svelte,
  #   norg (images dans ces fichiers)
  # - blink.cmp : rappel que certaines sources s'activent à la volée (ligne de commande)
  # - which-key : gc / gcc, recouvrement des raccourcis natifs de commentaire
  local alerts
  alerts=$(grep -E '❌|⚠️' /tmp/health.txt | grep -vE '^[a-zA-Z_.-]+: ' | grep -vE \
    -e 'vim.ui.open: no handler|does not support the kitty graphics protocol|None of the tools found: .kitty., .wezterm., .ghostty.' \
    -e 'WARNING (Go|cargo|luarocks|Composer|PHP|javac|java|julia|Ruby|RubyGem|gem): not available' \
    -e 'setup \{disabled\}' \
    -e "Tool not found: 'gs'|\`gs\` is required to render PDF|Tool not found: 'mmdc'|\`mmdc\` is required" \
    -e 'Missing Treesitter languages|Image rendering in docs with missing treesitter' \
    -e 'Some providers may show up as "disabled"' \
    -e 'In mode `n`, <gc> overlaps with <gcc>')
  [ -z "$alerts" ] || { echo "$alerts"; return 1; }
}
check "nvim : :checkhealth sans erreur ni alerte" checkhealth_clean

# Ouvre un fichier dans un vrai terminal ; échoue sur un message d'erreur ou sans coloration
nvim_opens() {
  local file=$1 msg=/tmp/nvim-msg
  rm -f "$msg"
  # Échap ferme un éventuel « Press ENTER », puis on écrit les messages et on quitte
  { sleep 4; printf '\033:redir! > %s | silent messages | redir END | qa!\r' "$msg"; sleep 2; } |
    in_tty "stty cols 120 rows 40; nvim $file '+lua vim.defer_fn(function() vim.api.nvim_echo({{\"coloration: \" .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)}}, true, {}) end, 2500)'" >/dev/null
  # E1568 : le pseudo-terminal ne répond pas à la question de nvim sur la couleur de fond
  if grep -v E1568 "$msg" | grep -qiE 'error|E[0-9]{2,4}:'; then grep -v E1568 "$msg"; return 1; fi
  grep -q 'coloration: true' "$msg" || { echo "pas de coloration treesitter"; cat "$msg"; return 1; }
}

F=/tmp/f
mkdir -p $F
printf '# Titre\n\n```lua\nlocal x = 1\n```\n\n```js\nconst a = 1;\n```\n' > $F/t.md
printf 'const a = 1;\n' > $F/t.js
cp $F/t.js $F/t.ts
cp $F/t.js $F/t.tsx
printf '#!/bin/bash\necho hi\n' > $F/t.sh
printf '%s\n' '---@param x string' 'local s = string.format("%s", x)' > $F/t.lua
for f in t.md t.js t.ts t.tsx t.sh t.lua; do
  check "nvim : ouvre $f sans erreur, avec coloration" nvim_opens "$F/$f"
done

# Les autres langages, sans terminal (plus rapide) : coloration treesitter active
colored() {
  local bad="" f r
  for f in "$@"; do
    echo "x" > "$F/$f"
    r=$(nvim --headless "$F/$f" "+lua io.stdout:write(tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil))" +qa 2>&1)
    [ "$r" = true ] || bad="$bad $f"
  done
  [ -z "$bad" ] || { echo "sans coloration :$bad"; return 1; }
}
check "nvim : coloration py rs go java c cpp cs scala rb" colored t.py t.rs t.go t.java t.c t.cpp t.cs t.scala t.rb
check "nvim : coloration jsx yaml json toml xml xslt xsd csv sql Dockerfile" \
  colored t.jsx t.yaml t.json t.toml t.xml t.xslt t.xsd t.csv t.sql Dockerfile

# ─── LSP ─────────────────────────────────────────────────────────
# Petit projet (git, package.json, pyproject.toml) avec une erreur par fichier :
# le serveur doit s'attacher et la signaler
P=/tmp/proj
rm -rf $P && mkdir -p $P/.github/workflows && git -C $P init -q
echo '{"name":"t","version":"1.0.0"}' > $P/package.json
echo '{}' > $P/package-lock.json
echo '{"compilerOptions":{"strict":true}}' > $P/tsconfig.json
echo '{"rules":{}}' > $P/.oxlintrc.json
printf '[project]\nname = "t"\nversion = "0.1.0"\n' > $P/pyproject.toml
printf 'const a: number = "x";\nexport {};\n' > $P/t.ts
printf 'import os\nx: int = "a"\n' > $P/t.py
printf 'on: push\njobs:\n  a:\n    runs-on: 3\n' > $P/.github/workflows/ci.yml
printf 'local x = 1\n' > $P/t.lua
printf '#!/bin/bash\necho $1\n' > $P/t.sh

# lsp_attached <fichier> <serveur>… : serveurs attachés et au moins un diagnostic
lsp_attached() {
  local file=$1 out
  shift
  out=$(cd $P && nvim --headless "$file" "+lua vim.wait(60000, function() return #vim.diagnostic.get(0) > 0 end, 200); vim.wait(1000); local n = {} for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do n[#n + 1] = c.name end; io.stdout:write(table.concat(n, ',') .. ' diagnostics=' .. #vim.diagnostic.get(0))" +qa 2>&1)
  for s in "$@"; do [[ ",${out%% *}," == *",$s,"* ]] || { echo "$s absent : $out"; return 1; }; done
  [[ $out != *"diagnostics=0" ]] || { echo "aucun diagnostic : $out"; return 1; }
}
check "LSP TypeScript : tsc (TS 7) + oxlint" lsp_attached t.ts tsc oxlint
check "LSP Python : ty + ruff" lsp_attached t.py ty ruff
check "LSP YAML : yamlls + schéma GitHub Actions" lsp_attached .github/workflows/ci.yml yamlls
check "LSP Lua : lua_ls" lsp_attached t.lua lua_ls
check "LSP Bash : bashls + shellcheck" lsp_attached t.sh bashls
# jsonls : pas de diagnostic sur un JSON valide, on vérifie seulement l'attache
json_attached() {
  local out
  out=$(cd $P && nvim --headless package.json "+lua vim.wait(30000, function() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 end, 200); io.stdout:write(vim.lsp.get_clients({ bufnr = 0 })[1].name)" +qa 2>&1)
  [ "$out" = jsonls ] || { echo "$out"; return 1; }
}
check "LSP JSON : jsonls" json_attached
# ─── Complétion ──────────────────────────────────────────────────
# Tape « mess » sous `const message = …` (via la boucle principale de nvim : un feedkeys bloquant
# ne laisserait pas le LSP répondre) ; blink.cmp doit proposer `message`, venu du LSP
completes() {
  printf 'const message = "x";\nexport {};\n' > $P/c.ts
  cat > /tmp/complete.lua <<'EOF'
vim.defer_fn(function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Gomess", true, false, true), "t", false)
end, 5000)
vim.defer_fn(function()
  for _, item in ipairs(require("blink.cmp.completion.list").items or {}) do
    if item.label == "message" and item.source_id == "lsp" then io.stdout:write("ok") end
  end
  vim.cmd("qa!")
end, 10000)
EOF
  local out
  out=$(cd $P && nvim --headless c.ts "+luafile /tmp/complete.lua" 2>&1)
  [[ $out == *ok* ]] || { echo "pas de proposition « message » du LSP : $out"; return 1; }
}
check "complétion : blink.cmp propose les symboles du LSP" completes

# ─── Navigation ──────────────────────────────────────────────────
# gd (snacks.picker) depuis l'appel de hello() ligne 2 : saut à sa définition, ligne 1
goes_to_definition() {
  printf 'export function hello(): string { return "x"; }\nexport const y = hello();\n' > $P/n.ts
  local out
  out=$(cd $P && nvim --headless n.ts "+lua vim.wait(30000, function() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 end); vim.wait(2000); vim.api.nvim_win_set_cursor(0, { 2, 17 }); vim.cmd('normal gd'); vim.wait(3000, function() return vim.api.nvim_win_get_cursor(0)[1] == 1 end); io.stdout:write('ligne ' .. vim.api.nvim_win_get_cursor(0)[1])" +qa 2>&1)
  [ "$out" = "ligne 1" ] || { echo "après gd : $out (attendu : ligne 1)"; return 1; }
}
check "navigation : gd va à la définition (TypeScript)" goes_to_definition

# ─── Formatage (conform.nvim) et lint (nvim-lint) ────────────────
# formats <fichier> <contenu> <attendu> : contenu formaté à l'enregistrement
formats() {
  printf '%b' "$2" > "$P/$1"
  (cd $P && nvim --headless "$1" +w +qa >/dev/null 2>&1)
  local got
  got=$(cat "$P/$1")
  [ "$got" = "$(printf '%b' "$3")" ] || { printf 'obtenu :\n%s\n' "$got"; return 1; }
}
check "format : TypeScript (oxfmt)" formats f.ts 'const   a = {b:1,\n  c:2}\n' 'const a = { b: 1, c: 2 };'
check "format : YAML (oxfmt)" formats f.yaml 'a:   1\nb:\n    - x\n' 'a: 1\nb:\n  - x'
check "format : Python (ruff, imports triés)" formats f.py 'import sys,os\nx=1\n' 'import os\nimport sys\n\nx = 1'
check "format : Lua (stylua)" formats f.lua 'local  t = {a=1}\n' 'local t = { a = 1 }'
check "format : shell (shfmt)" formats f.sh 'if true; then\necho  "x"\nfi\n' 'if true; then\n  echo "x"\nfi'
# Projet Vite+ : c'est le vp du projet qui formate (ici un faux vp, qui marque sa sortie)
formats_with_vp() {
  mkdir -p $P/vite/node_modules/.bin
  printf '#!/bin/sh\necho "// vp $1"\ncat\n' > $P/vite/node_modules/.bin/vp
  chmod +x $P/vite/node_modules/.bin/vp
  formats vite/g.ts 'const x = 1;\n' '// vp fmt\nconst x = 1;'
}
check "format : projet Vite+ → vp fmt" formats_with_vp

# lints <fichier> <source> : un diagnostic de cette source
lints() {
  local out
  out=$(cd $P && nvim --headless "$1" "+lua vim.wait(20000, function() for _, d in ipairs(vim.diagnostic.get(0)) do if d.source == '$2' then return true end end end, 200); for _, d in ipairs(vim.diagnostic.get(0)) do io.stdout:write(d.source .. ' ') end" +qa 2>&1)
  [[ $out == *"$2"* ]] || { echo "pas de diagnostic $2 : $out"; return 1; }
}
printf 'FROM ubuntu\nRUN apt-get install curl\n' > $P/Dockerfile
printf 'on: push\njobs:\n  a:\n    runs-on: ubuntu-latest\n    steps:\n      - run: echo ${{ github.foo.bar }}\n' > $P/.github/workflows/lint.yml
check "lint : Dockerfile (hadolint)" lints Dockerfile hadolint
check "lint : GitHub Actions (actionlint)" lints .github/workflows/lint.yml actionlint

# ─── Git ─────────────────────────────────────────────────────────
# gitsigns : une ligne modifiée par rapport au commit apparaît comme telle
git_signs() {
  local out
  git -C $P add t.lua && git -C $P -c user.name=t -c user.email=t@t commit -qm init
  printf 'local x = 2\n' > $P/t.lua
  out=$(cd $P && nvim --headless t.lua "+lua vim.wait(10000, function() return (vim.b.gitsigns_status_dict or {}).changed == 1 end, 200); io.stdout:write(vim.inspect(vim.b.gitsigns_status_dict))" +qa 2>&1)
  [[ $out == *"changed = 1"* ]] || { echo "$out"; return 1; }
}
check "git : gitsigns signale la ligne modifiée" git_signs

# Commandes des plugins chargés à la demande (codediff, claudecode, markdown)
loads() {
  local out
  out=$(cd $P && nvim --headless doc.md "+lua require('lazy').load({ plugins = { 'codediff.nvim', 'claudecode.nvim', 'render-markdown.nvim', 'live-preview.nvim' } }); local t = {} for _, c in ipairs({ 'CodeDiff', 'ClaudeCode', 'RenderMarkdown', 'LivePreview' }) do t[#t + 1] = c .. '=' .. vim.fn.exists(':' .. c) end; io.stdout:write(table.concat(t, ' '))" +qa! 2>&1)
  [[ $out == *"CodeDiff=2 ClaudeCode=2 RenderMarkdown=2 LivePreview=2"* ]] || { echo "$out"; return 1; }
}
printf '# Titre\n\n- [ ] tâche\n' > $P/doc.md
check "codediff, claudecode, render-markdown, live-preview : commandes disponibles" loads

# ─── Débogage (nvim-dap) ─────────────────────────────────────────
# Point d'arrêt ligne 2, lancement de la 1re configuration : arrêt attendu sur la ligne 2
cat > /tmp/dap.lua <<'EOF'
local dap = require("dap")
vim.api.nvim_win_set_cursor(0, { 2, 0 })
dap.toggle_breakpoint()
dap.run(dap.configurations[vim.bo.filetype][1])
vim.wait(60000, function() return dap.session() ~= nil and dap.session().current_frame ~= nil end, 100)
local s = dap.session()
io.stdout:write("ligne=" .. tostring(s and s.current_frame and s.current_frame.line))
dap.terminate()
vim.wait(1000)
vim.cmd("qa!")
EOF
debugs() {
  local out
  out=$(cd $P && nvim --headless "$1" "+luafile /tmp/dap.lua" 2>&1)
  [[ $out == *"ligne=2"* ]] || { echo "$out" | tail -5; return 1; }
}
printf 'const a = 1;\nconst b = a + 1;\nconsole.log(b);\n' > $P/d.ts
printf 'a = 1\nb = a + 1\nprint(b)\n' > $P/d.py
check "débogage : TypeScript (js-debug-adapter, node)" debugs d.ts
check "débogage : Python (debugpy)" debugs d.py

# ─── Tests (neotest) ─────────────────────────────────────────────
# Projet vitest (installé avec le même cooldown de 7 jours) : un test réussi, un en échec
neotest_vitest() {
  local V=/tmp/vt
  rm -rf $V && mkdir -p $V && git -C $V init -q
  echo '{"name":"vt","type":"module"}' > $V/package.json
  (cd $V && npm_config_min_release_age=7 npm install -D vitest --silent >/dev/null 2>&1) || { echo "npm install vitest"; return 1; }
  printf 'import { test, expect } from "vitest";\ntest("ok", () => { expect(1 + 1).toBe(2); });\ntest("ko", () => { expect(1).toBe(2); });\n' > $V/a.test.ts
  cat > /tmp/neotest.lua <<'EOF'
local neotest = require("neotest")
vim.defer_fn(function() neotest.run.run(vim.fn.expand("%:p")) end, 5000)
vim.defer_fn(function()
  for _, id in ipairs(neotest.state.adapter_ids()) do
    local c = neotest.state.status_counts(id, { buffer = vim.api.nvim_get_current_buf() })
    if c then io.stdout:write("passed=" .. c.passed .. " failed=" .. c.failed) end
  end
  vim.cmd("qa!")
end, 40000)
EOF
  local out
  out=$(cd $V && nvim --headless a.test.ts "+luafile /tmp/neotest.lua" 2>&1)
  [[ $out == *"passed=1 failed=1"* ]] || { echo "$out" | tail -5; return 1; }
}
check "tests : neotest + vitest" neotest_vitest

# Pas de toolchain Rust dans le conteneur : on vérifie seulement le serveur
check "LSP Rust : rust-analyzer installé" test -x "$DATA/mason/bin/rust-analyzer"

# Exécuté directement (make test-nvim) : bilan ici ; sourcé par full.sh : c'est lui qui conclut
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo
  if [ "$failures" -eq 0 ]; then echo "Tout est ok"; else echo "$failures échec(s)"; fi
  exit $((failures > 0))
fi
