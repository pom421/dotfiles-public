-- Fichiers modifiés hors de nvim (Claude dans l'onglet voisin de herdr, lazygit, git pull) :
-- relus tout seuls quand le buffer n'a pas de modification en cours (sinon nvim demande).
-- nvim ne vérifie qu'à certains événements, et herdr ne lui signale pas forcément le retour
-- sur son onglet : vérification aussi chaque seconde, en mode normal.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, { command = "silent! checktime" })
vim.uv.new_timer():start(
  1000,
  1000,
  vim.schedule_wrap(function()
    if vim.api.nvim_get_mode().mode == "n" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end)
)
