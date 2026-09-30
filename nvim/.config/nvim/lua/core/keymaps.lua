-- On définit notre touche leader sur espace
vim.g.mapleader = " "

-- Raccourci pour la fonction set
local keymap = vim.keymap.set

-- on utilise ;; pour sortir du monde insertion
keymap("i", ";;", "<ESC>", { desc = "Sortir du mode insertion avec ;;" })

-- on efface le surlignage de la recherche
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Effacer le surlignage de la recherche" })

-- Alt-k / Alt-j déplacent la sélection vers le haut / le bas (mode visuel, v ou V).
-- Pas <S-i>/<S-k> : ils masqueraient I (insertion en bloc) et K (aide) de Vim.
-- Sur Mac, le terminal doit envoyer Option comme Alt (Ghostty : macos-option-as-alt = true).
keymap("x", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Déplace la sélection vers le haut", silent = true })
keymap("x", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Déplace la sélection vers le bas", silent = true })

-- Changement de fenêtre avec Ctrl + déplacement uniquement au lieu de Ctrl-w + déplacement
keymap("n", "<C-h>", "<C-w>h", { desc = "Déplace le curseur dans la fenêtre de gauche" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Déplace le curseur dans la fenêtre du bas" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Déplace le curseur dans la fenêtre du haut" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Déplace le curseur dans la fenêtre droite" })

-- Navigation entre les buffers (plugin bufferline)
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Buffer suivant", silent = true })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer précédent", silent = true })

