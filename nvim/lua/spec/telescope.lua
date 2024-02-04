return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
	},
    cmd = { "Telescope" },
	config = function()
		local t = require ("telescope")
        t.setup {
			defaults = {
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				path_display = { "truncate" },
				winblend = 0,
				border = {},
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" },
			},
			extensions_list = { "themes", "terms" },
		}
        t.load_extension("notify")
	end,
    keys = {
        { "gf", function() require("telescope.builtin").live_grep() end },
        { "ff", function() require("telescope.builtin").find_files() end },
        { "gs", function() require("telescope.builtin").git_status() end },
        { "gt", function() require("telescope.builtin").lsp_references() end }
    }
}
