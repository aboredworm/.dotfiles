return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
      { "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Telescope git file search" },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
        end,
        desc = "Telescope grep string",
      },
    },
  },
}
