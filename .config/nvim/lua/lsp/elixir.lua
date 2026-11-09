local caps = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok and blink.get_lsp_capabilities then
	caps = blink.get_lsp_capabilities(caps) -- or blink.get_lsp_capabilities()
end

vim.lsp.config("elixirls", {
	cmd = { "elixirls" },
	capabilities = caps,
	settings = {
		elixirLS = {
			dialyzerEnabled = true,
			fetchDeps = false,
			suggestSpecs = true,
		},
	},
	on_attach = function(client, bufnr)
		-- Disable formatting so it doesn't shift your code
		vim.bo[bufnr].formatexpr = ""
		-- Keep your preferred indentation
		vim.bo[bufnr].tabstop = 2
		vim.bo[bufnr].shiftwidth = 2
		vim.bo[bufnr].expandtab = true
	end,
})
