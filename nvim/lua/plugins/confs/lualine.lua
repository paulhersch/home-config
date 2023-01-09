return {
	'nvim-lualine/lualine.nvim',
	requires = {
		'kyazdani42/nvim-web-devicons',
	},
	as = 'lualine',
	config = function()
		local colors = require "azul.core".get_colors()
		local lualine = require("lualine")

		local function short_cwd()
			return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
		end

		local tree_ext = {
			filetypes = { 'NvimTree' },
			sections = {
				lualine_a = { short_cwd }
			},
			inactive_sections = {
				lualine_b = { short_cwd }
			}
		}
		local term_ext = {
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

		local function lline_colors()
			return {
				--personalized version of everblushs lualine theme
				normal = {
					a = { bg = colors.color2, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
				insert = {
					a = { bg = colors.color4, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
				visual = {
					a = { bg = colors.color5, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
				replace = {
					a = { bg = colors.color1, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
				command = {
					a = { bg = colors.color7, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
				inactive = {
					a = { bg = colors.color4, fg = colors.color0 },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.contrast, fg = colors.contrast }
				},
			}
		end

		lualine.setup {
			options = {
				section_separators = { left = '', right = ''},
				component_separators = { left = '', right = ''},
				icons_enabled = true,
				disabled_filetypes = { 'packer' },
				globalstatus = true,
				theme = lline_colors()
			},
			sections = {
				lualine_a = {
					{
						'mode',
						fmt = function (mode)
							return '  ' .. mode
						end,
					},
				},
				lualine_b = {
					{
						--funny random seperator like nvchad does it
						function ()
							return ''
						end,
						padding = 0,
						color = { bg = colors.color8, fg = colors.color0 }
					},
					{
						'filetype',
						icon_only = true,
						colored = false,
						separator = { left = '', right = ''},
					},
					{
						'filename',
						symbols = {
							readonly = '-',
							modified = '+',
							unnamed = 'unnamed'
						},
					},
					{
						--component_separators doesnt do what i want
						function ()
							return ''
						end,
						color = { bg = colors.contrast, fg = colors.color0 },
						padding = 0
					},
					{
						'branch',
						icon = ' ',
						color = { bg = colors.contrast, fg = colors.color7 }
					}
				},
				lualine_c = {}, --filler for the middle, has funny fill icons when anything is in there so no use
				lualine_x = { },
				lualine_y = {
					{
						'diagnostics',
						--color = { bg = colors.contrast },
						sources = { 'nvim_lsp', 'nvim_diagnostic' },
						sections = { 'error', 'warn' },
						colored = true,
						symbols = { error = ' ', warn = ' ', info = ' ' },
						separator = { left = '', right = ''},
						update_in_insert = true
					},
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
			extensions = { tree_ext, term_ext },
		}
	end
}
