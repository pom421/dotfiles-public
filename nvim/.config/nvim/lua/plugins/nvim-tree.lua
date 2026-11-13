return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      actions = { remove_file = { close_window = false } },

      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        -- On garde tous les raccourcis par défaut de nvim-tree
        api.config.mappings.default_on_attach(bufnr)

        -- = : le dossier sous le curseur devient la racine (C-] inaccessible en AZERTY Mac)
        -- fait la paire avec - (remonter la racine d'un cran)
        vim.keymap.set("n", "=", api.tree.change_root_to_node, {
          buffer = bufnr,
          desc = "nvim-tree: CD",
          noremap = true,
          silent = true,
          nowait = true,
        })

        -- h / l façon LazyVim : replier le dossier / ouvrir ou déplier
        vim.keymap.set("n", "h", api.node.navigate.parent_close, {
          buffer = bufnr,
          desc = "nvim-tree: Close Directory",
          noremap = true,
          silent = true,
          nowait = true,
        })
        vim.keymap.set("n", "l", api.node.open.edit, {
          buffer = bufnr,
          desc = "nvim-tree: Open",
          noremap = true,
          silent = true,
          nowait = true,
        })
      end,
    })

    -- On utilise <leader>e pour ouvrir/fermer l'explorateur
    vim.keymap.set(
      "n",
      "<leader>e",
      "<cmd>NvimTreeFindFileToggle<CR>",
      { desc = "Ouverture/fermeture de l'explorateur de fichiers" }
    )
  end,
}
