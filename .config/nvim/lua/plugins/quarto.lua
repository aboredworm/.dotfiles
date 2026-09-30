return {
  "quarto-dev/quarto-nvim",
  ft = { "quarto" },
  dependencies = {
    "jmbuhr/otter.nvim",
    "nvim-treesitter/nvim-treesitter",
    "benlubas/molten-nvim",
  },
  opts = {
    closePreviewOnExit = true,
    lspFeatures = {
      enabled = true,
      chunks = "curly",
      languages = { "r", "python", "julia", "bash", "html" },
      diagnostics = {
        enabled = true,
        triggers = { "BufWritePost" },
      },
      completion = {
        enabled = true,
      },
    },
    codeRunner = {
      enabled = true,
      default_method = "molten",
      ft_runners = {
        python = "molten",
        r = "molten",
        julia = "molten",
        bash = "molten",
      },
      never_run = { "yaml" },
    },
  },
  config = function(_, opts)
    local quarto = require("quarto")
    local runner = require("quarto.runner")
    vim.treesitter.language.register("markdown", "quarto")
    quarto.setup(opts)

    local function map(bufnr, mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "quarto",
      callback = function()
        quarto.activate()
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "quarto",
      callback = function(args)
        map(args.buf, "n", "<localleader>qp", "<cmd>QuartoPreview<cr>", "preview quarto")
        map(args.buf, "n", "<localleader>qP", "<cmd>QuartoPdfPreview<cr>", "preview quarto pdf")
        map(args.buf, "n", "<localleader>qc", "<cmd>QuartoClosePreview<cr>", "close quarto preview")
        map(args.buf, "n", "<localleader>qa", "<cmd>QuartoActivate<cr>", "activate quarto")
        map(args.buf, "n", "<localleader>rc", runner.run_cell, "run cell")
        map(args.buf, "n", "<localleader>ra", runner.run_above, "run cell and above")
        map(args.buf, "n", "<localleader>rA", runner.run_all, "run all matching cells")
        map(args.buf, "n", "<localleader>rl", runner.run_line, "run line")
        map(args.buf, "v", "<localleader>r", runner.run_range, "run visual range")
      end,
    })
    if vim.bo.filetype == "quarto" then
      quarto.activate()
    end

    vim.api.nvim_create_user_command("QuartoPdfPreview", function()
      local buffer_path = vim.api.nvim_buf_get_name(0)
      if buffer_path == "" then
        vim.notify("QuartoPdfPreview requires a file-backed buffer", vim.log.levels.ERROR)
        return
      end

      local pdf_path = buffer_path:gsub("%.qmd$", ".pdf")
      if pdf_path == buffer_path then
        vim.notify("QuartoPdfPreview only supports .qmd files", vim.log.levels.ERROR)
        return
      end

      local quarto_bin = "/Applications/quarto/bin/quarto"
      vim.fn.jobstart({ quarto_bin, "render", buffer_path, "--to", "pdf", "--pdf-engine", "pdflatex", "--no-execute" }, {
        cwd = vim.fn.fnamemodify(buffer_path, ":p:h"),
        on_exit = function(_, exit_code)
          if exit_code ~= 0 then
            vim.schedule(function()
              vim.notify("quarto render exited with code " .. exit_code, vim.log.levels.ERROR)
            end)
            return
          end

          vim.schedule(function()
            vim.fn.jobstart({ "/opt/homebrew/bin/zathura", pdf_path })
          end)
        end,
      })
    end, {})
  end,
}
