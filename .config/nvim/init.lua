local python3_host_prog = vim.env.NVIM_PYTHON3_HOST_PROG
  or vim.fn.stdpath("config") .. "/.venv/bin/python3"
  or vim.fn.expand("~/.virtualenvs/neovim/bin/python3")

if python3_host_prog and vim.fn.executable(python3_host_prog) == 1 then
  vim.g.python3_host_prog = python3_host_prog
end

local jupyter_dir = vim.fn.stdpath("config") .. "/.jupyter"
local jupyter_runtime_dir = jupyter_dir .. "/runtime"
vim.fn.mkdir(jupyter_runtime_dir, "p")
vim.env.JUPYTER_CONFIG_DIR = jupyter_dir
vim.env.JUPYTER_RUNTIME_DIR = jupyter_runtime_dir

require("amoore")
require("config.lazy")

-- Snippets
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/snippets"})
