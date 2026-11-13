-- Diffs git à la façon de VS Code : côte à côte, surlignage au caractère près, liste des fichiers
-- modifiés, indexation (stage) par fichier ou par bloc, historique, résolution de conflits.
-- (diffview.nvim, la référence historique, n'est plus maintenu depuis 2024)
return {
  "esmuellert/codediff.nvim",
  version = "*",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Diff des modifications (explorateur)" },
    { "<leader>gD", "<cmd>CodeDiff --staged<cr>", desc = "Diff de l'index (stage)" },
    { "<leader>gm", "<cmd>CodeDiff main<cr>", desc = "Diff avec main" },
    { "<leader>gh", "<cmd>CodeDiff history<cr>", desc = "Historique des commits (diffs)" },
  },
}
