return {
	'nvim-lualine/lualine.nvim',
	requires = {
		'kyazdani42/nvim-web-devicons',
	},
	as = 'lualine',
	config = function()
		local function short_cwd()
			return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
		end

		local nvimtree_extension = {
			filetypes = { 'NvimTree' },
			sections = {
				lualine_a = { short_cwd }
			},
			inactive_sections = {
				lualine_b = { short_cwd }
			}
		}
		local toggleterm_extension = {
			filetypes = { 'toggleterm' },
			sections = {
				lualine_a = { function ()
					return "Terminal"
				end }
			},
			inactive_sections = {
				lualine_b = { function ()
					return "Terminal"
				end }
			}
		}
		local colors = require "azul.core".get_colors()
		require("lualine").setup {
			options = {
				section_separators = { left = '', right = ''},
				icons_enabled = true,
				theme = {
					--personalized version of everblushs lualine theme
					normal = {
						a = { bg = colors.color2, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
					insert = {
						a = { bg = colors.color4, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
					visual = {
						a = { bg = colors.color5, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
					replace = {
						a = { bg = colors.color1, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
					command = {
						a = { bg = colors.color7, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
					inactive = {
						a = { bg = colors.color4, fg = colors.color0 },
						b = { bg = colors.color0, fg = colors.color7 },
						c = { bg = colors.contrast, fg = colors.contrast }
					},
				},
				disabled_filetypes = { 'packer' },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						'mode',
						seperator = { left = '', right = '' },
						fmt = function ()
							return ' '
						end,
						padding = 0
					}
				},
				lualine_b = {
					{
						'filename',
						color = { fg = colors.color4 },
						separator = { left = '', right = ''},
						symbols = {
							readonly = '',
							modified = '',
							unnamed = 'unnamed'
						}
					},
					{
						'branch',
						color = { bg = colors.contrast, fg = colors.color7 },
						icon = '',
						padding = { right = 1 }
					}
				},
				lualine_c = { }, --filler for the middle
				lualine_x = { },
				lualine_y = {
					{
						'diagnostics',
						--color = { bg = colors.contrast },
						sources = { 'nvim_lsp', 'nvim_diagnostic' },
						sections = { 'error', 'warn' },
						colored = true,
						symbols = { error = ' ', warn = ' ' },
						separator = { left = '', right = ''},
						update_in_insert = true
					},
					{
						'filetype',
						--color = { bg = colors.color0, fg = colors.foreground }
					}
				},
				lualine_z = {}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = { 'filename' },
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {}
			},
			tabline = { },
			extensions = { nvimtree_extension, toggleterm_extension },
		}
	end
}
