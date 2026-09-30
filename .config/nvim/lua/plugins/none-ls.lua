return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"mason.nvim",
            "nvimtools/none-ls-extras.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
                    require("none-ls.formatting.jq")
				},
			})

			require("mason-null-ls").setup({
				ensure_installed = { "jq" },
				automatic_installation = true,
			})
		end,
	},
}
