function setup_harpoon()
	local mark = require("harpoon.mark")
	local ui = require("harpoon.ui")

	vim.keymap.set("n", "<leader>a", mark.add_file)
	vim.keymap.set("n", "<C-h>", ui.toggle_quick_menu)
	vim.keymap.set("n", "<C-j>", function() ui.nav_file(1) end)
	vim.keymap.set("n", "<C-k>", function() ui.nav_file(2) end)
	vim.keymap.set("n", "<C-l>", function() ui.nav_file(3) end)
	vim.keymap.set("n", "<C-n>", function() ui.nav_file(4) end)
	vim.keymap.set("n", "<leader><C-j>", function() mark.set_current_at(1) end)
	vim.keymap.set("n", "<leader><C-k>", function() mark.set_current_at(2) end)
	vim.keymap.set("n", "<leader><C-l>", function() mark.set_current_at(3) end)
	vim.keymap.set("n", "<leader><C-n>", function() mark.set_current_at(4) end)
	end


return {
	"ThePrimeagen/harpoon",
	dependencies = {'nvim-lua/plenary.nvim'},
	config = function()
		setup_harpoon()
	end
}
