-- snacks.nvim : collection de petits modules intégrés (même style, même raccourcis)
--   picker   : recherche floue (fichiers, texte, buffers, symboles LSP…), successeur de Telescope
--   words    : surligne les autres occurrences LSP du symbole sous le curseur, comme VS Code
--   notifier : notifications en popup (vim.notify), input : vim.ui.input en fenêtre flottante
--   bigfile  : désactive treesitter et LSP sur les très gros fichiers
--   bufdelete : ferme un buffer sans fermer sa fenêtre
--   lazygit, terminal, gitbrowse : lazygit et un terminal en fenêtre flottante, fichier ouvert sur GitHub
--   image    : images et formules LaTeX affichées dans le markdown (Ghostty, kitty…)
local function pick(name, opts)
  return function() Snacks.picker[name](opts) end
end

return {
  "folke/snacks.nvim",
  version = "2.*",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      win = {
        -- C-j / C-k pour descendre / monter dans la liste, comme dans Telescope
        input = {
          keys = {
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-k>"] = { "list_up", mode = { "i", "n" } },
          },
        },
      },
    },
    words = { enabled = true },
    notifier = { enabled = true },
    input = { enabled = true },
    bigfile = { enabled = true },
    image = { enabled = true },
  },
  keys = {
    -- Recherche
    { "<leader>ff", pick("files"), desc = "Fichiers (nom)" },
    { "<leader>fg", pick("grep"), desc = "Texte dans les fichiers" },
    { "<leader>fx", pick("grep_word"), desc = "Mot sous le curseur / sélection", mode = { "n", "x" } },
    { "<leader>fb", pick("buffers"), desc = "Buffers ouverts" },
    { "<leader>fr", pick("recent"), desc = "Fichiers récents" },
    { "<leader>f/", pick("lines"), desc = "Lignes du buffer" },
    { "<leader>fh", pick("help"), desc = "Aide de nvim" },
    { "<leader>fk", pick("keymaps"), desc = "Raccourcis" },
    { "<leader>fc", pick("commands"), desc = "Commandes" },
    { "<leader>fs", pick("lsp_symbols"), desc = "Symboles du fichier" },
    { "<leader>fS", pick("lsp_workspace_symbols"), desc = "Symboles du projet" },
    { "<leader>fd", pick("diagnostics_buffer"), desc = "Diagnostics du fichier" },
    { "<leader>fD", pick("diagnostics"), desc = "Diagnostics du projet" },
    { "<leader>fR", pick("resume"), desc = "Reprendre la dernière recherche" },
    { "<leader>fp", pick("pickers"), desc = "Toutes les recherches" },
    -- Navigation LSP en liste (aperçu du code) ; gd/gD/grr/gri/grt : cf. plugins/lsp.lua
    -- Buffers
    {
      "<leader>bd",
      function() Snacks.bufdelete() end,
      desc = "Fermer le buffer",
    },
    {
      "<leader>bo",
      function() Snacks.bufdelete.other() end,
      desc = "Fermer les autres",
    },
    -- Git
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Historique (lazygit)" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Historique du fichier (lazygit)" },
    { "<leader>go", function() Snacks.gitbrowse() end, desc = "Ouvrir sur GitHub / GitLab", mode = { "n", "x" } },
    -- Terminal flottant (Échap Échap : mode normal, puis q ou <leader>tt pour le masquer)
    { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Terminal" },
    -- Notifications
    {
      "<leader>un",
      function() Snacks.notifier.show_history() end,
      desc = "Historique des notifications",
    },
  },
}
