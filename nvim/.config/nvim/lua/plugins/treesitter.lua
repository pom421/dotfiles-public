-- Branche main : la branche master est figée et incompatible avec nvim 0.12
-- (erreur « attempt to call method 'range' » dans les blocs de code markdown).
-- Prérequis : tree-sitter-cli (brew install tree-sitter-cli) et un compilateur C.
local languages = {
  "java", "c", "lua", "vim", "vimdoc", "query", "elixir", "heex",
  "javascript", "typescript", "tsx", "html", "yaml",
  "markdown", "markdown_inline", "bash", "json",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- Installe les parsers manquants (asynchrone, ne fait rien s'ils sont déjà là)
    require("nvim-treesitter").install(languages)

    -- Un langage peut correspondre à plusieurs filetypes (ex. bash → sh)
    local filetypes = {}
    for _, lang in ipairs(languages) do
      vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function(args)
        -- pcall : pas d'erreur si le parser est encore en cours d'installation
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
