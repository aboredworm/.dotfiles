local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local root_markers = {
  'pyrightconfig.json',
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  '.git',
}

vim.lsp.config('pyright', {
  cmd = { mason_bin .. '/pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local root = bufname ~= '' and vim.fs.root(bufname, root_markers) or nil
    on_dir(root or vim.fn.getcwd())
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic', -- or 'strict'
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
      },
    },
  },
  on_attach = function(client)
    -- disable completion provider
    client.server_capabilities.completionProvider = nil
    client.server_capabilities.definitionProvider = false
  end,
})
