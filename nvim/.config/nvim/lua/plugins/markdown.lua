-- Documentation (markdown) affichée directement
--   Dans nvim : render-markdown (titres, tableaux, listes, cases, encadrés…) + snacks.image
--     (images, formules LaTeX ; terminal Ghostty, kitty ou WezTerm)
--   Dans le navigateur : live-preview, mis à jour à la frappe, défilement synchronisé, diagrammes Mermaid
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    version = "8.*",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {
      completions = { blink = { enabled = true } }, -- cases à cocher, encadrés (> [!NOTE])
      latex = { enabled = false }, -- formules : snacks.image (plugins/snacks.lua)
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Rendu dans nvim on/off", ft = "markdown" },
    },
  },

  {
    "brianhuster/live-preview.nvim",
    version = "*",
    cmd = "LivePreview",
    dependencies = { "folke/snacks.nvim" }, -- :LivePreview pick (choisir le fichier)
    keys = {
      { "<leader>mp", "<cmd>LivePreview start<cr>", desc = "Aperçu dans le navigateur", ft = "markdown" },
      { "<leader>mP", "<cmd>LivePreview close<cr>", desc = "Fermer l'aperçu", ft = "markdown" },
    },
  },
}
