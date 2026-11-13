-- Rechercher / remplacer dans tout le projet, avec aperçu (panneau « Rechercher » de VS Code)
-- Moteur : ripgrep ; on édite les résultats puis on applique (<localleader>r dans le panneau)
return {
  "MagicDuck/grug-far.nvim",
  version = "*",
  cmd = "GrugFar",
  opts = { headerMaxWidth = 80 },
  keys = {
    {
      "<leader>sr",
      function()
        -- Préremplit avec la sélection (fait par grug-far) ou le mot sous le curseur,
        -- et limite aux fichiers du même type que le fichier courant
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or ""
        local visual = vim.fn.mode():match("[vV\22]") ~= nil
        require("grug-far").open({
          transient = true,
          prefills = {
            search = not visual and vim.fn.expand("<cword>") or nil,
            filesFilter = ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "x" },
      desc = "Rechercher / remplacer (projet)",
    },
  },
}
