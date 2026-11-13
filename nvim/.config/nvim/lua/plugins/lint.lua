-- Linters sans serveur LSP (les autres langages ont le leur : oxlint, ruff, shellcheck via bashls…)
--   hadolint   : Dockerfile (bonnes pratiques : versions figées, couches, sudo…)
--   actionlint : workflows GitHub Actions (syntaxe, expressions ${{ }}, scripts shell)
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = { dockerfile = { "hadolint" } }

    -- Différé : à BufReadPost, le filetype (qui désigne le linter) n'est pas encore connu
    local function try_lint()
      vim.schedule(function() lint.try_lint() end)
      if vim.api.nvim_buf_get_name(0):match("/%.github/workflows/[^/]+%.ya?ml$") then
        vim.schedule(function() lint.try_lint("actionlint") end)
      end
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = try_lint,
    })
    -- Le plugin se charge sur l'un de ces événements : le fichier qui l'a déclenché est déjà ouvert
    try_lint()
  end,
}
