-- lua/lsp/pylsp.lua

vim.lsp.config('pylsp', {
  cmd = { 'pylsp' },
  filetypes = { 'python' },

  settings = {
    pylsp = {
      plugins = {
        jedi_completion = {
          enabled = true,
          fuzzy = true,
          include_params = true,  
        },
        jedi_definition = { enabled = true },
        jedi_hover = { enabled = true },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = { enabled = true, all_scopes = true },
        pyflakes = { enabled = true },
        mccabe   = { enabled = false },
        pycodestyle = { enabled = false },
      },
    },
  },
})

