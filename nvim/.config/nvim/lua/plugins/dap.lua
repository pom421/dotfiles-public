-- Débogueur (DAP) : points d'arrêt, pas à pas, variables, pile d'appels
--   JS/TS : vscode-js-debug (celui de VS Code) ; Python : debugpy. Adaptateurs installés par Mason
--   (plugins/mason.lua). Rust : pas de débogueur (codelldb retiré : 144 Mo pour un usage rare).
-- Touches F comme VS Code (sur Mac : fn + F5…), ou <leader>d…
local function dap(fn, ...)
  local args = { ... }
  return function() require("dap")[fn](unpack(args)) end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = { "igorlfs/nvim-dap-view", "mfussenegger/nvim-dap-python" },
    config = function()
      local d = require("dap")

      -- JS / TS (node exécute directement le TypeScript). 127.0.0.1 explicite des deux côtés :
      -- sous Linux, « localhost » peut se résoudre en ::1 alors que l'adaptateur écoute en IPv4
      for _, adapter in ipairs({ "pwa-node", "node" }) do
        d.adapters[adapter] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = { command = "js-debug-adapter", args = { "${port}", "127.0.0.1" } },
        }
      end
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        d.configurations[ft] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Lancer le fichier (node)",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "S'attacher à un processus node (--inspect)",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end

      -- Python : debugpy de Mason (dans son propre environnement virtuel)
      require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
    keys = {
      { "<F5>", dap("continue"), desc = "Débogage : lancer / continuer" },
      { "<F9>", dap("toggle_breakpoint"), desc = "Point d'arrêt" },
      { "<F10>", dap("step_over"), desc = "Pas à pas (sans entrer)" },
      { "<F11>", dap("step_into"), desc = "Pas à pas (en entrant)" },
      { "<S-F11>", dap("step_out"), desc = "Sortir de la fonction" },
      { "<leader>dc", dap("continue"), desc = "Lancer / continuer" },
      { "<leader>db", dap("toggle_breakpoint"), desc = "Point d'arrêt" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Condition : ")) end,
        desc = "Point d'arrêt conditionnel",
      },
      { "<leader>do", dap("step_over"), desc = "Pas à pas (sans entrer)" },
      { "<leader>di", dap("step_into"), desc = "Pas à pas (en entrant)" },
      { "<leader>dO", dap("step_out"), desc = "Sortir de la fonction" },
      { "<leader>dC", dap("run_to_cursor"), desc = "Continuer jusqu'au curseur" },
      { "<leader>dl", dap("run_last"), desc = "Relancer la dernière session" },
      { "<leader>dt", dap("terminate"), desc = "Arrêter" },
      {
        "<leader>de",
        function() require("dap.ui.widgets").hover() end,
        desc = "Valeur sous le curseur",
        mode = { "n", "x" },
      },
    },
  },

  -- Panneaux du débogueur (variables, pile, points d'arrêt, console), ouverts avec la session
  {
    "igorlfs/nvim-dap-view",
    version = "1.*",
    lazy = true,
    opts = { auto_toggle = true },
    keys = { { "<leader>du", "<cmd>DapViewToggle<cr>", desc = "Panneaux du débogueur" } },
  },
}
