-- Lien entre nvim et Claude Code (même protocole que l'extension VS Code). Claude ne tourne pas
-- dans nvim mais dans l'onglet claude de herdr (docs/ide.md) : ce plugin n'est que le serveur
-- auquel Claude se connecte par /ide. Il voit alors le fichier et la sélection courants, et ses
-- modifications s'ouvrent ici en diff, à accepter ou refuser.
-- Seulement avec Claude sur la machine (PROJET_CLAUDE=host) : la microVM (sbx) n'a pas accès au
-- réseau local. Dans les deux cas, ␣ay (core/keymaps.lua) copie une référence à coller dans Claude.
return {
  "coder/claudecode.nvim",
  -- Branche principale (au cooldown près) plutôt que les releases, trop espacées (v0.3.0 → v0.4.0 : 14 mois)
  event = "VeryLazy", -- serveur prêt dès le démarrage, pour /ide
  opts = { terminal = { provider = "none" } },
  keys = {
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Ajouter le fichier au contexte (/ide)" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Envoyer la sélection (/ide)" },
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Ajouter le fichier (/ide)", ft = { "snacks_picker_list" } },
    -- Diff proposé par Claude
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accepter la modification" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Refuser la modification" },
  },
}
