-- Claude Code dans nvim (même protocole que l'extension VS Code) : Claude voit le fichier et la
-- sélection courants, et ses modifications s'ouvrent en diff, à accepter ou refuser.
-- Nécessite la commande `claude` dans le PATH.
return {
  "coder/claudecode.nvim",
  -- Branche principale (au cooldown près) plutôt que les releases, trop espacées (v0.3.0 → v0.4.0 : 14 mois)
  dependencies = { "folke/snacks.nvim" }, -- terminal de Claude, à droite
  cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeTreeAdd" },
  opts = {},
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code (ouvrir / fermer)" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Aller dans Claude Code" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Reprendre une conversation" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continuer la dernière conversation" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Choisir le modèle" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Ajouter le fichier au contexte" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Envoyer la sélection" },
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Ajouter le fichier", ft = { "NvimTree" } },
    -- Diff proposé par Claude
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accepter la modification" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Refuser la modification" },
  },
}
