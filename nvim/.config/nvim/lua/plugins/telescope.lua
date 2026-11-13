return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- fzf implémentation en C pour plus de rapidité
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {

        -- Parce que c'est joli
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { ".git/", "node_modules" },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- Essai temporaire : mêmes recherches que snacks.picker (<leader>f…), sous <leader>F…, pour comparer.
    -- Si Telescope ne sert plus, supprimer ce fichier.
    local keymap = vim.keymap
    keymap.set("n", "<leader>Ff", "<cmd>Telescope find_files<cr>", { desc = "Fichiers (nom)" })
    keymap.set("n", "<leader>Fg", "<cmd>Telescope live_grep<cr>", { desc = "Texte dans les fichiers" })
    keymap.set("n", "<leader>Fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers ouverts" })
    keymap.set("n", "<leader>Fx", "<cmd>Telescope grep_string<cr>", { desc = "Mot sous le curseur" })
    keymap.set("n", "<leader>Fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fichiers récents" })
    keymap.set("n", "<leader>Fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Symboles du fichier" })
    keymap.set("n", "<leader>FR", "<cmd>Telescope resume<cr>", { desc = "Reprendre la dernière recherche" })
  end,
}
