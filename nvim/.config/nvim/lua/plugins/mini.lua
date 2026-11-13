-- Modules de mini.nvim, chacun dans son dépôt
return {
  -- Ferme automatiquement ( [ { " ' `
  { "nvim-mini/mini.pairs", version = "*", event = "InsertEnter", opts = {} },

  -- Entourer : sa (ajouter), sd (supprimer), sr (remplacer), ex. saiw" , sd( , sr"'
  -- s seul (remplacer un caractère) marche encore, après un court délai ; sans délai : cl
  -- Sans les variantes « prochain / précédent » (sdn, sdl…), qui retardent sd, sr… (which-key)
  {
    "nvim-mini/mini.surround",
    version = "*",
    event = "VeryLazy",
    opts = { mappings = { suffix_last = "", suffix_next = "" } },
  },

  -- Icônes (which-key, et nvim-web-devicons pour les autres plugins)
  { "nvim-mini/mini.icons", version = "*", lazy = true, opts = {} },
}
