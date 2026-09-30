return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			defaults = {
				layout_config = {
					horizontal = {
						preview_cutoff = 0,
						preview_width = 0.5,
					},
				},
				file_ignore_patterns = {
					-- Version control
					"^.git/",
					
					-- Virtual environments and package managers
					"^node_modules/",
					"^venv/",
					"^.venv/",
					"^env/",
					"^.env/",
					"^vendor/",
					"^__pycache__/",
					
					-- Build directories
					"^build/",
					"^dist/",
					"^target/",
					"^.gradle/",
					"^out/",
					"^bin/",
                    "[^/]*cache[^/]*/",
					
					-- OS and editor files
					"^.DS_Store$",
					"^thumbs.db$",
					"^.*%.swp$",
					"^.*%.swo$",
					"^.*%.swn$",
					
					-- Binary files (common extensions)
					"^.*%.pyc$",
					"^.*%.class$",
					"^.*%.exe$",
					"^.*%.dll$",
					"^.*%.so$",
					"^.*%.dylib$",
					"^.*%.o$",
					"^.*%.a$",
					"^.*%.jar$",
					"^.*%.war$",
					
					-- Logs and databases
					"^.*%.log$",
					"^.*%.sqlite$",
					"^.*%.db$",
					
					-- Archives
					"^.*%.zip$",
					"^.*%.tar$",
					"^.*%.gz$",
					"^.*%.rar$",
					
					-- Images and media
					"^.*%.png$",
					"^.*%.jpg$",
					"^.*%.jpeg$",
					"^.*%.gif$",
					"^.*%.mp4$",
					"^.*%.mp3$",
					"^.*%.pdf$",
				},
			},
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files({
						hidden = true,
						no_ignore = true,
						no_ignore_parent = true,
						-- Additional filtering for find_files specifically
						find_command = {
							"fd",
							"--type",
							"f",
							"--hidden",
							"--no-ignore",
							"--exclude",
							".git",
							"--exclude",
							"node_modules",
							"--exclude",
							"venv",
							"--exclude",
							".venv",
							"--exclude",
							"env",
							"--exclude",
							"vendor",
							"--exclude",
							"__pycache__",
							"--exclude",
							"build",
							"--exclude",
							"dist",
							"--exclude",
							"target",
						},
					})
				end,
				desc = "Telescope find files (all files, excluding binaries and envs)",
			},

			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Telescope git file search" },

			{
				"<leader>fs",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
				end,
				desc = "Telescope grep string",
			},

			{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Telescope show diagnostics" },
		},
	},
}
