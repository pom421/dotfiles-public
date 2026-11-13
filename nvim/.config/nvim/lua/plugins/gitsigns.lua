-- Git dans la gouttière : lignes ajoutées / modifiées / supprimées, et actions sur chaque bloc (hunk)
return {
  "lewis6991/gitsigns.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end
      -- ]h / [h : bloc suivant / précédent ; <leader>gn / gN : idem, plus simple en AZERTY Mac
      map("n", "]h", function() gs.nav_hunk("next") end, "Bloc modifié suivant")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Bloc modifié précédent")
      map("n", "<leader>gn", function() gs.nav_hunk("next") end, "Bloc modifié suivant")
      map("n", "<leader>gN", function() gs.nav_hunk("prev") end, "Bloc modifié précédent")
      map("n", "<leader>gv", gs.preview_hunk_inline, "Voir le bloc (avant / après)")
      map({ "n", "x" }, "<leader>gs", ":Gitsigns stage_hunk<cr>", "Indexer (stage) le bloc ou la sélection")
      map({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<cr>", "Annuler le bloc ou la sélection")
      map("n", "<leader>gS", gs.stage_buffer, "Indexer tout le fichier")
      map("n", "<leader>gR", gs.reset_buffer, "Annuler tout le fichier")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame de la ligne")
      map("n", "<leader>gB", gs.blame, "Blame du fichier")
      map("n", "<leader>ub", gs.toggle_current_line_blame, "Blame en fin de ligne on/off")
      map({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<cr>", "bloc modifié")
    end,
  },
}
