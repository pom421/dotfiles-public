-- Autocomplétion : LSP du langage, chemins, snippets, mots du buffer ; aussi en ligne de commande (:)
-- Moteur de tri flou en Rust (binaire précompilé téléchargé pour la version figée par `version`).
return {
  "saghen/blink.cmp",
  version = "1.*",
  -- Pas de chargement différé : le plugin déclare ses capacités (snippets…) à tous les serveurs
  -- LSP au démarrage ; chargé plus tard, il manquerait aux serveurs déjà lancés
  lazy = false,
  dependencies = { "rafamadriz/friendly-snippets" }, -- snippets prêts à l'emploi, comme dans VS Code
  opts = {
    -- Comme VS Code : Entrée valide, Tab / S-Tab passent d'un champ de snippet à l'autre,
    -- C-espace ouvre le menu, C-e le ferme ; C-j / C-k naviguent (comme dans Telescope)
    keymap = {
      preset = "enter",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      -- coloration treesitter des propositions du LSP
      menu = { draw = { treesitter = { "lsp" } } },
    },
    -- Signature de la fonction pendant la saisie des arguments
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
      providers = {
        -- API de nvim dans les fichiers Lua de cette config (lazydev.nvim), en tête de liste
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
