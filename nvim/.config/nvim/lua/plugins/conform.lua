-- Formatage à l'enregistrement (<leader>uf pour le couper), ou à la demande (<leader>cf)
--   JS/TS, JSON, YAML, TOML, CSS, HTML, Markdown : oxfmt (Prettier, en Rust), celui de Vite+
--     (`vp fmt`) dans un projet Vite+, sinon celui du projet, sinon celui de Mason
--   Python : ruff ; Lua : stylua ; shell : shfmt ; Rust : rustfmt (de la toolchain)
--   Autres : le formateur du serveur LSP s'il en a un
local web = { "oxfmt" }

--- Binaire du projet (node_modules/.bin), en remontant depuis le fichier
local function local_bin(name, dir)
  return vim.fs.find("node_modules/.bin/" .. name, { upward = true, path = dir, type = "file" })[1]
end

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      javascript = web,
      javascriptreact = web,
      typescript = web,
      typescriptreact = web,
      json = web,
      jsonc = web,
      json5 = web,
      yaml = web,
      toml = web,
      css = web,
      scss = web,
      html = web,
      graphql = web,
      markdown = web,
      python = { "ruff_organize_imports", "ruff_format" },
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      rust = { "rustfmt" },
    },
    formatters = {
      oxfmt = {
        command = function(_, ctx) return local_bin("vp", ctx.dirname) or local_bin("oxfmt", ctx.dirname) or "oxfmt" end,
        args = function(_, ctx)
          local args = { "--stdin-filepath", ctx.filename }
          if local_bin("vp", ctx.dirname) then
            table.insert(args, 1, "fmt")
          end
          return args
        end,
      },
      shfmt = { prepend_args = { "-i", "2", "-ci" } }, -- 2 espaces, case indentés (style du repo)
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
        return
      end
      return { timeout_ms = 1500 }
    end,
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- gq formate avec conform
  end,
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true }) end,
      mode = { "n", "x" },
      desc = "Formater (fichier ou sélection)",
    },
    {
      "<leader>uf",
      function()
        vim.g.autoformat = vim.g.autoformat == false
        vim.notify("Formatage à l'enregistrement : " .. (vim.g.autoformat and "oui" or "non"))
      end,
      desc = "Formatage à l'enregistrement on/off",
    },
    {
      "<leader>uF",
      function()
        vim.b.autoformat = vim.b.autoformat == false
        vim.notify("Formatage à l'enregistrement (ce buffer) : " .. (vim.b.autoformat and "oui" or "non"))
      end,
      desc = "Idem, pour ce buffer seulement",
    },
  },
}
