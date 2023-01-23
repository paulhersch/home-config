return {
	'nvim-tree/nvim-tree.lua',
	requires = { 'nvim-tree/nvim-web-devicons' },
	as = 'nvim-tree',
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
			renderer = {
                indent_width = 2,
				indent_markers = {
					enable = false,
					icons = {
						corner = "└",
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
							untracked = "",
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
		Map("n", "<Space>f", "<cmd>NvimTreeToggle<CR>", {})
	end
}
