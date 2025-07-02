function treesitter_setup()  -- This stays as a separate function
    local configs = require("nvim-treesitter.configs")

    configs.setup({
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = { "c", "lua", "python", "vim", "vimdoc", "query", "markdown", "markdown_inline" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        highlight = {
            enable = true,

            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        }  -- Fixed missing comma and proper table closure
    })
end

return {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()  -- Changed from direct function call to a function wrapper
        treesitter_setup()
    end
}

