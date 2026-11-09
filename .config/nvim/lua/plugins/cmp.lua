return {
	"saghen/blink.cmp",
	dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
	version = "1.*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "fallback" }, -- <--- prevents Blink from hijacking Tab
			["<S-Tab>"] = { "fallback" },
			["<C-g>"] = { "show_documentation", "hide_documentation" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<C-f>"] = { "accept", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = { documentation = { auto_show = false }, menu = { auto_show_delay_ms = 50 } },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		snippets = {
			preset = "luasnip",
		},
	},
	opts_extend = { "sources.default" },
}
