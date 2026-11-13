-- Branche main : la branche master est figée et incompatible avec nvim 0.12
-- (erreur « attempt to call method 'range' » dans les blocs de code markdown).
-- Prérequis : tree-sitter-cli (brew install tree-sitter-cli) et un compilateur C.
-- stylua: ignore
local languages = {
  -- nvim et shell
  "lua", "luadoc", "printf", "vim", "vimdoc", "query", "bash",
  -- web
  "javascript", "typescript", "tsx", "jsdoc", "html", "css", "scss", "graphql",
  -- langages
  "python", "rust", "go", "gomod", "gosum", "gowork", "java", "c", "cpp", "c_sharp",
  "scala", "ruby", "elixir", "heex",
  -- données et configuration (xml couvre aussi xslt, xsd et svg)
  "json", "json5", "yaml", "toml", "xml", "dtd", "csv", "tsv", "ini", "properties",
  "sql", "proto", "hcl", "terraform", "dockerfile", "make", "jq", "editorconfig", "ssh_config",
  -- documentation
  "markdown", "markdown_inline", "comment", "regex", "latex",
  -- git
  "diff", "gitcommit", "git_config", "git_rebase", "gitignore", "gitattributes",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Installe les parsers manquants (asynchrone, ne fait rien s'ils sont déjà là)
      require("nvim-treesitter").install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- pcall : pas d'erreur sans parser pour ce filetype, ou s'il est en cours d'installation
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            -- Repli du code selon la syntaxe (zc, zo, za…), tout déplié à l'ouverture (foldlevel)
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },

  -- Objets de texte selon la syntaxe : vaf (fonction), cic (classe), dia (argument)…
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local objets = {
        f = { "@function", "fonction" },
        c = { "@class", "classe" },
        a = { "@parameter", "argument" },
        i = { "@conditional", "condition" },
        l = { "@loop", "boucle" },
      }
      for touche, o in pairs(objets) do
        vim.keymap.set(
          { "x", "o" },
          "a" .. touche,
          function() select(o[1] .. ".outer", "textobjects") end,
          { desc = o[2] .. " (autour)" }
        )
        vim.keymap.set(
          { "x", "o" },
          "i" .. touche,
          function() select(o[1] .. ".inner", "textobjects") end,
          { desc = o[2] .. " (intérieur)" }
        )
      end
    end,
  },

  -- Garde en haut de l'écran la signature de la fonction ou classe en cours (« sticky scroll »)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = { max_lines = 3 },
  },
}
