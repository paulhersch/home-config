return {
	'nvim-telescope/telescope.nvim',
	version = '0.1.0',
	dependencies = {
		'nvim-lua/plenary.nvim',
	},
    cmd = { "Telescope" },
	config = function()
		local t = require ("telescope")
        t.setup {
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
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
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = { "node_modules" },
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				path_display = { "truncate" },
				winblend = 0,
				border = {},
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				-- Developer configurations: Not meant for general override
				buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
			},
			extensions_list = { "themes", "terms" },
		}
        t.load_extension("notify")
	end,
    keys = {
        { "gf", "<cmd>Telescope live_grep<CR>" },
        { "ff", "<cmd>Telescope find_files<CR>" },
        { "fb", "<cmd>Telescope buffers<CR>" },
        { "gt", "<cmd>Telescope lsp_references<CR>" }
    }
}
