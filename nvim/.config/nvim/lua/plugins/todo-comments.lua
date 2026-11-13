-- TODO, FIXME, HACK, NOTE… surlignés dans le code, et listés dans tout le projet
return {
  "folke/todo-comments.nvim",
  version = "*",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "TODO du projet" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODO du projet (panneau)" },
  },
}
