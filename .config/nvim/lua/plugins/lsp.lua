-- Function to open LSP hover in a vertical split
local function open_hover_in_vsplit()
  -- Use the current buffer's LSP client to get position encoding
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    print("No LSP clients attached")
    return
  end
  -- Default to utf-16 (common for LSP servers like pyright)
  local position_encoding = clients[1].offset_encoding or "utf-16"

  -- Request hover with explicit position encoding
  local hover_result = vim.lsp.buf_request_sync(
    0,
    'textDocument/hover',
    vim.lsp.util.make_position_params(0, position_encoding),
    1000
  )
  if not hover_result or vim.tbl_isempty(hover_result) then
    print("No hover information available")
    return
  end

  local contents = hover_result[1].result.contents
  local lines = type(contents) == 'string' and vim.split(contents, '\n') or vim.lsp.util.convert_input_to_markdown_lines(contents)

  vim.cmd('vsplit')
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",  
        "hrsh7th/nvim-cmp",      
        "L3MON4D3/LuaSnip",      
        "saadparwaiz1/cmp_luasnip", 
    },

    config = function()
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
            },
            handlers = {
                function(server_name) 
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
            }
        })

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-f>'] = cmp.mapping.confirm({ select = true }),
                ['<C-k>'] = cmp.mapping.complete(),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
                ['<C-g>'] = cmp.mapping(open_hover_in_vsplit, { 'i' }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if require('luasnip').expand_or_jumpable() then
                        require('luasnip').expand_or_jump()
                    elseif cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if require('luasnip').jumpable(-1) then
                        require('luasnip').jump(-1)
                    elseif cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

    end
}
