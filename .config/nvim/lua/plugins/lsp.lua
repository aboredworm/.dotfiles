return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",  -- Optional but recommended for LSP-powered completion
        "hrsh7th/nvim-cmp",      -- Optional: Core completion engine
        "L3MON4D3/LuaSnip",      -- Optional: Snippet engine for completion
        "saadparwaiz1/cmp_luasnip", -- Optional: LuaSnip integration for cmp
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
                "pyright"  -- Ensures pyright is installed via Mason
            },
            handlers = {
                function(server_name) -- Default handler for all servers
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                -- Removed other specific handlers (zls, lua_ls) as they're not needed for Python/pyright
            }
        })

        -- Optional: Set up completion with LSP source (remove if you don't want completion)
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

        -- Diagnostic configuration (optional but improves UX)
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

        -- To enable jump to definition, add this keybinding (e.g., in your init.lua or a keymaps file):
        -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
        -- This assumes the LSP is attached (which it will be for Python files after setup).
        -- Pyright should automatically detect Python roots via pyproject.toml, setup.cfg, etc.
    end
}
