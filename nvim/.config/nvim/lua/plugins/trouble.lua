-- Panneau de listes (comme « Problèmes » de VS Code) : diagnostics, références, quickfix…
return {
  "folke/trouble.nvim",
  version = "3.*",
  cmd = "Trouble",
  opts = {},
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics du projet" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics du fichier" },
    { "<leader>xl", "<cmd>Trouble lsp toggle win.position=right<cr>", desc = "Définitions, références… (LSP)" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Liste quickfix" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Liste locale" },
  },
}
