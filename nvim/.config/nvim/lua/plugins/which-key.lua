-- Popup des raccourcis disponibles après une touche préfixe (<leader>, g, z, ", C-w…)
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-mini/mini.icons" }, -- icônes des groupes et commandes
  opts = {
    preset = "helix", -- popup en bas à droite, ne masque pas le code
    spec = {
      { "<leader>a", group = "IA (Claude Code)" },
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "débogage" },
      { "<leader>f", group = "rechercher (snacks)" },
      { "<leader>F", group = "rechercher (Telescope, essai)" },
      { "<leader>g", group = "git" },
      { "<leader>m", group = "markdown" },
      { "<leader>s", group = "rechercher / remplacer" },
      { "<leader>t", group = "terminal, tests" },
      { "<leader>u", group = "interface (on/off)" },
      { "<leader>x", group = "diagnostics, listes" },
      { "ga", group = "appels (LSP)" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Raccourcis du buffer",
    },
  },
}
