return {
  "benlubas/molten-nvim",
  lazy = false,
  build = ":UpdateRemotePlugins",
  ft = { "quarto", "python", "markdown" },
  init = function()
    vim.g.molten_auto_open_output = true
    vim.g.molten_output_virt_lines = false
    vim.g.molten_output_win_border = { "", "━", "", "" }
  end,
}
