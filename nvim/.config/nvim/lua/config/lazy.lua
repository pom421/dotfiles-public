-- Mise en place et installation de lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configuration de lazy.nvim et importation du répertoire `plugins`
require("lazy").setup({ { import = "plugins" } }, {
  -- Cooldown de 7 jours : les versions ne bougent qu'avec `make nvim-update`, qui choisit
  -- dans lazy-lock.json des commits de plus de 7 jours. pin = true neutralise :Lazy update
  -- (et sync), qui prendraient la dernière version ; :Lazy restore applique le lockfile.
  defaults = { pin = true },
  checker = { enabled = false },

  -- thème utilisé lors de l'installation de plugins
  install = { colorscheme = { "tokyonight" } },
  -- désactive la pénible notification au démarrage
  change_detection = {
    notify = false,
  },

  -- aucun plugin n'a besoin de luarocks : évite l'erreur dans :checkhealth
  rocks = { enabled = false },
})
