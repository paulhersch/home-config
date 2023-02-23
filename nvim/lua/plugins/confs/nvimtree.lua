return {
	'nvim-tree/nvim-tree.lua',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	name = 'nvim-tree',
    cmd = { "NvimTreeOpen", "NvimTreeToggle" },
	config = function()
		require('nvim-tree').setup ({
			--disable standard file browser and replace with nvim-tree
			disable_netrw = true,
			hijack_netrw = true,
			hijack_cursor = true, --sets cursor to start of line
			update_cwd = true,
			diagnostics = {
				enable = true,
				icons = {
					hint = "",
					info = "",
					warning = " ",
					error = " ",
				},
			},
			update_focused_file = {
				enable = true,
				update_cwd = false
			},
			view = {
				adaptive_size = true,
				hide_root_folder = true
			},
            git = { ignore = false },
			renderer = {
                indent_width = 2,
				indent_markers = {
					enable = true,
					icons = {
						corner = "╰",
						edge = "│",
						item = "├",
						none = " ",
					},
				},
				icons = {
					padding = "  ",
					glyphs = {
						default = "",
						symlink = "",
						git = {
                            renamed = "",
							staged = "",
							unmerged = "",
							unstaged = "",
							untracked = "",
                            deleted = "",
                            ignored = ""
						},
						folder = {
							arrow_open = "",
							arrow_closed = "",
							default = "",
							empty = "",
							open = "",
							symlink = "",
						}
					}
				}
			}
		})
	end,
    keys = {
        { "<Space>f", "<cmd>NvimTreeToggle<CR>" }
    }
}
