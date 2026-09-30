return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "general"
    vim.g.vimtex_view_general_viewer = "/opt/homebrew/bin/zathura"
    vim.g.vimtex_view_general_options = "@pdf"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_automatic = 1
    vim.g.vimtex_view_enabled = 1
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = "build/tex",
      out_dir = "build/tex",
    }
  end,
  config = function()
    local function map(bufnr, lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "plaintex" },
      callback = function(args)
        map(args.buf, "<localleader>lc", "<cmd>VimtexCompile<cr>", "compile latex")
        map(args.buf, "<localleader>lv", "<cmd>VimtexView<cr>", "view pdf")
        map(args.buf, "<localleader>ls", "<cmd>VimtexStop<cr>", "stop latex")
        map(args.buf, "<localleader>lx", "<cmd>VimtexClean<cr>", "clean latex aux")
        map(args.buf, "<localleader>lX", "<cmd>VimtexClean!<cr>", "clean latex output")
      end,
    })
  end,
}
