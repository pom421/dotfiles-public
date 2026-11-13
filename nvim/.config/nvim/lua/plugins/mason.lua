-- Mason installe les outils des langages (serveurs LSP, formateurs, linters, débogueurs)
-- dans ~/.local/share/nvim/mason, pareil sur Mac et Linux, et met leur dossier bin en tête du PATH de nvim.
--
-- Cooldown : le registre Mason est figé sur une release de plus de 7 jours (config/cooldown.lua,
-- avancé par `make nvim-update`), donc chaque outil est à la version qu'elle référence.
-- Correctif de sécurité urgent : fixer la version d'un outil, ex. { "ruff", version = "0.17.5" }.

-- Noms des paquets Mason (:Mason pour les parcourir)
local tools = {
  -- serveurs LSP
  "tsc", -- TypeScript 7 natif (tsc --lsp) : TS, JS, TSX, JSX
  "oxlint", -- lint JS/TS (celui de Vite+, qui passe par `vp lint` s'il est dans le projet)
  "ty", -- Python : typage, navigation (Astral)
  "ruff", -- Python : lint et format (Astral)
  "rust-analyzer",
  "yaml-language-server",
  "json-lsp",
  "lua-language-server",
  "bash-language-server",
  -- linters (shellcheck est utilisé par bash-language-server ; hadolint, actionlint : nvim-lint)
  "shellcheck",
  "hadolint",
  "actionlint",
  -- formateurs
  "oxfmt", -- JS/TS, JSON, YAML, TOML, CSS, Markdown (hors projet Vite+, qui a le sien)
  "stylua",
  "shfmt",
  -- débogueurs (plugins/dap.lua)
  "js-debug-adapter",
  "debugpy",
}

-- Dépendances npm et pip des outils, elles aussi publiées depuis au moins 7 jours
local cooldown_env = { npm_config_min_release_age = "7", PIP_UPLOADED_PRIOR_TO = "P7D" }

--- Installe les outils manquants et cale les autres sur la version du registre.
---@param on_done fun(errors: string[], installed: string[])
local function sync(on_done)
  local registry = require("mason-registry")
  local saved = {}
  for k, v in pairs(cooldown_env) do
    saved[k], vim.env[k] = vim.env[k], v
  end
  local function finish(errors, installed)
    for k in pairs(cooldown_env) do
      vim.env[k] = saved[k]
    end
    on_done(errors, installed)
  end

  registry.refresh(vim.schedule_wrap(function(ok, err)
    if not ok then
      return finish({ "registre Mason : " .. vim.inspect(err) }, {})
    end
    local pending, errors, installed = 0, {}, {}
    for _, tool in ipairs(tools) do
      local spec = type(tool) == "string" and { tool } or tool
      local found, pkg = pcall(registry.get_package, spec[1])
      if not found then
        table.insert(errors, spec[1] .. " : absent du registre")
      else
        local version = spec.version or pkg:get_latest_version()
        if pkg:get_installed_version() ~= version and not pkg:is_installing() then
          pending = pending + 1
          pkg:install(
            { version = version },
            vim.schedule_wrap(function(success, e)
              if success then
                table.insert(installed, spec[1] .. " " .. version)
              else
                table.insert(errors, spec[1] .. " : " .. vim.inspect(e))
              end
              pending = pending - 1
              if pending == 0 then
                finish(errors, installed)
              end
            end)
          )
        end
      end
    end
    if pending == 0 then
      finish(errors, installed)
    end
  end))
end

return {
  "mason-org/mason.nvim",
  lazy = false, -- PATH vers les outils dès le démarrage, avant le lancement des serveurs LSP
  opts = {
    registries = { "github:mason-org/mason-registry@" .. require("config.cooldown").mason_registry },
  },
  config = function(_, opts)
    require("mason").setup(opts)

    -- :MasonSync, bloquant en mode headless (make nvim-update, bancs de test) : code 1 en cas d'échec
    vim.api.nvim_create_user_command("MasonSync", function()
      local result
      sync(function(errors, installed) result = { errors = errors, installed = installed } end)
      if #vim.api.nvim_list_uis() > 0 then
        return
      end
      vim.wait(20 * 60 * 1000, function() return result ~= nil end, 200)
      result = result or { errors = { "délai dépassé" }, installed = {} }
      for _, line in ipairs(result.installed) do
        io.stdout:write("Mason : installé " .. line .. "\n")
      end
      if #result.errors > 0 then
        io.stderr:write("Mason : échec\n  " .. table.concat(result.errors, "\n  ") .. "\n")
        vim.cmd.cquit(1)
      end
    end, { desc = "Installe les outils Mason aux versions du registre figé", bar = true })

    -- Au démarrage (avec interface) : installe ce qui manque, en tâche de fond
    if #vim.api.nvim_list_uis() > 0 then
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          sync(function(errors, installed)
            if #installed > 0 then
              vim.notify("Installé : " .. table.concat(installed, ", "), vim.log.levels.INFO, { title = "Mason" })
            end
            if #errors > 0 then
              vim.notify(table.concat(errors, "\n"), vim.log.levels.ERROR, { title = "Mason" })
            end
          end)
        end,
      })
    end
  end,
}
