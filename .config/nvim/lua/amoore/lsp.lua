vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      },
      completion = {
        completionItem = {
          snippetSupport = true, 
        },
      },
    },
  },
  root_markers = { '.git' },
})

local function open_and_focus_hover()
  local current_win = vim.api.nvim_get_current_win()

  -- Open hover (async)
  vim.lsp.buf.hover()

  -- Small delay so the hover window actually appears
  vim.defer_fn(function()
    -- Look for new floating window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= "" then
        local buf = vim.api.nvim_win_get_buf(win)
        -- skip blink popup windows
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft ~= "cmp-menu" then
          vim.api.nvim_set_current_win(win)

          -- Allow closing with Esc to return
          vim.keymap.set("n", "<Esc>", function()
            vim.api.nvim_set_current_win(current_win)
          end, { buffer = buf, silent = true })
          return
        end
      end
    end
  end, 20) -- 20 ms wait is enough
end


vim.keymap.set("n", "<C-g>", open_and_focus_hover, { silent = true })
vim.keymap.set("i", "<C-g>", function()
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  open_and_focus_hover()
end, { silent = true })


require("lsp.pylsp")
require("lsp.pyright")
require("lsp.elixir")
