-- Tests : lancer le test sous le curseur, le fichier ou tout le projet ; résultats dans la gouttière
--   JS/TS : vitest (`vp test` dans un projet Vite+) ; Python : pytest ; Rust : cargo test (rustaceanvim)

--- Binaire du projet (node_modules/.bin), en remontant depuis dir (par défaut le dossier courant)
local function local_bin(name, dir)
  return vim.fs.find("node_modules/.bin/" .. name, { upward = true, path = dir or vim.fn.getcwd(), type = "file" })[1]
end

return {
  "nvim-neotest/neotest",
  version = "5.*",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-python",
  },
  config = function()
    local vitest = require("neotest-vitest")({
      vitestCommand = function()
        local vp = local_bin("vp")
        if vp then
          return vp .. " test"
        end
        return local_bin("vitest") or "npx vitest"
      end,
    })
    -- L'adaptateur ne reconnaît un fichier de test que si package.json dépend de `vitest` (même avec
    -- son option is_test_file) ; un projet Vite+ ne dépend que de `vite-plus`, qui fournit `vp test`
    local is_vitest_file = vitest.is_test_file
    vitest.is_test_file = function(path)
      if is_vitest_file(path) then
        return true
      end
      local test_name = path:match("%.test%.[cm]?[jt]sx?$") or path:match("%.spec%.[cm]?[jt]sx?$")
      return test_name ~= nil and local_bin("vp", vim.fs.dirname(path)) ~= nil
    end

    require("neotest").setup({
      adapters = {
        vitest,
        require("neotest-python"),
        require("rustaceanvim.neotest"),
      },
    })
  end,
  keys = {
    { "<leader>tn", function() require("neotest").run.run() end, desc = "Lancer le test sous le curseur" },
    {
      "<leader>tf",
      function() require("neotest").run.run(vim.fn.expand("%")) end,
      desc = "Lancer les tests du fichier",
    },
    { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Lancer tous les tests" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Relancer le dernier" },
    { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Déboguer le test" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Panneau des tests" },
    { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Sortie du test" },
    {
      "<leader>tw",
      function() require("neotest").watch.toggle(vim.fn.expand("%")) end,
      desc = "Relancer à chaque modif",
    },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Arrêter" },
  },
}
