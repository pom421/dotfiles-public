-- LSP natif de nvim (0.11+) : nvim-lspconfig ne sert qu'à fournir les configs de chaque serveur
-- (dossier lsp/ du plugin), activées ici par vim.lsp.enable. Les serveurs viennent de Mason.
-- Raccourcis natifs : K (doc), grn (renommer), gra (actions), grr (références),
-- gri (implémentations), grt (type), gO (symboles), C-s en insertion (signature).
local servers = {
  "tsc", -- TypeScript 7 : cherche un tsc ≥ 7 dans node_modules/.bin, sinon celui de Mason
  "oxlint", -- lint JS/TS, si le projet a un .oxlintrc.json ou un vite.config (Vite+)
  "ty",
  "ruff",
  "yamlls",
  "jsonls",
  "html",
  "cssls",
  "lua_ls",
  "bashls",
  -- Rust : rust-analyzer est lancé par rustaceanvim (plus bas)
}

return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "b0o/SchemaStore.nvim" },
    config = function()
      -- YAML et JSON : schémas du catalogue SchemaStore (GitHub Actions, docker-compose,
      -- package.json, tsconfig…), pour la complétion et la validation
      vim.lsp.config("yamlls", {
        -- sans yaml.docker-compose, yaml.gitlab… : filetypes que nvim ne produit pas (alerte de :checkhealth)
        filetypes = { "yaml" },
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" }, -- remplacé par SchemaStore.nvim
            schemas = require("schemastore").yaml.schemas(),
            keyOrdering = false,
            format = { enable = false }, -- formatage : oxfmt (conform.nvim)
          },
        },
      })
      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { workspace = { checkThirdParty = false } } },
      })

      vim.lsp.enable(servers)

      -- Bordures arrondies pour toutes les fenêtres flottantes (doc, signature, diagnostics)
      vim.o.winborder = "rounded"

      vim.diagnostic.config({
        severity_sort = true,
        -- message en fin de ligne, seulement pour la ligne du curseur (sinon trop chargé)
        virtual_text = { current_line = true, prefix = "●" },
        -- icônes Nerd Font (cercle croix, triangle, info, ampoule)
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "\u{f057}",
            [vim.diagnostic.severity.WARN] = "\u{f071}",
            [vim.diagnostic.severity.INFO] = "\u{f05a}",
            [vim.diagnostic.severity.HINT] = "\u{f0335}",
          },
        },
        float = { source = true },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          -- ty fournit la doc au survol (K) ; celle de ruff ne ferait que doublon
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          -- Navigation par snacks.picker : saut direct s'il n'y a qu'un résultat, sinon liste
          -- avec aperçu (remplace les versions natives de grr, gri, grt)
          map("gd", function() Snacks.picker.lsp_definitions() end, "Aller à la définition")
          map("gD", function() Snacks.picker.lsp_declarations() end, "Aller à la déclaration")
          map("grr", function() Snacks.picker.lsp_references() end, "Références")
          map("gri", function() Snacks.picker.lsp_implementations() end, "Implémentations")
          map("grt", function() Snacks.picker.lsp_type_definitions() end, "Définition du type")
          map("gai", function() Snacks.picker.lsp_incoming_calls() end, "Appels entrants")
          map("gao", function() Snacks.picker.lsp_outgoing_calls() end, "Appels sortants")
          -- Équivalents <leader>c… des raccourcis natifs gr…, listés par which-key
          map("<leader>ca", vim.lsp.buf.code_action, "Actions de code", { "n", "x" })
          map("<leader>cr", vim.lsp.buf.rename, "Renommer le symbole")
          map("<leader>cd", vim.diagnostic.open_float, "Diagnostic de la ligne")
          map(
            "<leader>uh",
            function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
            end,
            "Types inférés (inlay hints) on/off"
          )
        end,
      })
    end,
  },

  -- Schémas JSON et YAML (catalogue schemastore.org)
  { "b0o/SchemaStore.nvim", lazy = true },

  -- Rust : lance et configure rust-analyzer (Mason), avec ses extras (macros, runnables, débogage)
  {
    "mrcjkb/rustaceanvim",
    version = "9.*",
    lazy = false, -- le plugin se charge lui-même à l'ouverture d'un fichier Rust
    -- Pas de débogueur Rust (codelldb retiré, trop lourd pour un usage rare)
    init = function() vim.g.rustaceanvim = { dap = { adapter = false } } end,
  },

  -- Lua : complétion et types de l'API de nvim et des plugins, pour éditer cette config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
}
