-- Plan du fichier (« Outline » de VS Code) : classes, fonctions… via LSP, sinon treesitter
return {
  "stevearc/aerial.nvim",
  version = "4.*",
  cmd = { "AerialToggle", "AerialNavToggle" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  opts = {
    layout = { default_direction = "right", min_width = 30 },
    -- Le plan suit le curseur
    autojump = false,
    highlight_on_hover = true,
  },
  keys = {
    { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Plan du fichier (outline)" },
    { "<leader>cn", "<cmd>AerialNavToggle<cr>", desc = "Navigation dans le plan (popup)" },
  },
}
