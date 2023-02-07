return {
	'nvim-lualine/lualine.nvim',
	requires = {
		'kyazdani42/nvim-web-devicons',
	},
	as = 'lualine',
	config = function()
		local colors = require "azul.core".get_colors()
        local lualine = require("lualine")

        local tree_ext = {
            filetypes = { 'NvimTree' },
            sections = {
                lualine_b = {
                    {
                        function ()
                            return " "
                        end,
                        color = { bg = colors.color4, fg = colors.background }
                    },
                    function ()
                        return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
                    end
                }
            },
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
					c = { bg = colors.background, fg = colors.background }
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
				insert = {
					a = { bg = colors.color4, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background },
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
				visual = {
					a = { bg = colors.color5, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
				replace = {
					a = { bg = colors.color1, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
				command = {
					a = { bg = colors.color7, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
				inactive = {
					a = { bg = colors.color4, fg = colors.color0 },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
					--c = { bg = colors.contrast, fg = colors.contrast }
				},
			}
		end

        local separator = {
            function ()
                return ' '
            end,
            color = { bg = colors.background }
        }

        --stuff for diagnostics
        local lsp_count = { 0, 0, 0, 0 }
        local function err_cnt()
            return lsp_count[vim.diagnostic.severity.ERROR]
        end
        local function warn_cnt()
            return lsp_count[vim.diagnostic.severity.WARN]
        end
        local function inf_cnt()
            return lsp_count[vim.diagnostic.severity.INFO]
        end
        local function update_lsp()
            lsp_count = { 0, 0, 0, 0 }
            local diagnostics = vim.diagnostic.get(0)
            for _, diagnostic in ipairs(diagnostics) do
                if vim.startswith(vim.diagnostic.get_namespace(diagnostic.namespace).name, 'vim.lsp') then
                    lsp_count[diagnostic.severity] = lsp_count[diagnostic.severity] + 1
                end
            end
        end

        vim.api.nvim_create_autocmd({"DiagnosticChanged"}, {
            callback = update_lsp
        })

        lualine.setup {
            options = {
                section_separators = { left = '', right = ''},
                component_separators = { left = '', right = ''},
                icons_enabled = true,
                disabled_filetypes = { 'packer' },
                globalstatus = true,
                theme = lline_colors()
            },
            sections = {
                lualine_a = {
                    {
                        function ()
                            return ' '
                        end
                    },
                },
                lualine_b = {
                    {
                        'mode',
                        fmt = function (mode)
                            return (mode:lower()):gsub("^%l", string.upper)
                        end
                    },
                    separator,
                    {
                        'filetype',
                        icon_only = true,
                        colored = false,
                        separator = { left = '', right = ''},
                        color = { bg = colors.color4, fg = colors.color0 },
                        padding = { left = 1, right = 2 }
					},
					{
						'filename',
						symbols = {
							readonly = '',
							modified = '',
							unnamed = 'unnamed'
						},
					},
					{
						function ()
							return vim.fn.getbufinfo(vim.api.nvim_get_current_buf())[1].changed == 1 and ' + ' or ''
						end,
						color = { bg = colors.color8, fg = colors.foreground},
                        padding = 0
					},
                    separator,
					{
						'branch',
						icon = {
                            '  ',
                            color = { bg = colors.color5, fg = colors.color0 },
                        },
						--color = { bg = colors.contrast, fg = colors.color7 }
					}

				},
				lualine_c = {}, --filler for the middle, has funny fill icons when anything is in there so no use
				lualine_x = { },
				lualine_y = {
                    {
                        function ()
                            return err_cnt() > 0 and '   ' or ''
                        end,
                        color = { bg = colors.color1, fg = colors.background },
                        padding = 0
                    },
                    {
                        function ()
                            return err_cnt() > 0 and ' ' .. err_cnt() .. ' ' or ''
                        end,
                        padding = 0
                    },
                    separator,
                    {
                        function ()
                            return warn_cnt() > 0 and '   ' or ''
                        end,
                        color = { bg = colors.color3, fg = colors.background },
                        padding = 0
                    },
                    {
                        function ()
                            return warn_cnt() > 0 and ' ' .. warn_cnt() .. ' ' or ''
                        end,
                        padding = 0
                    },
                    separator,
                    {
                        function ()
                            return inf_cnt() > 0 and '   ' or ''
                        end,
                        color = { bg = colors.color2, fg = colors.background },
                        padding = 0
                    },
                    {
                        function ()
                            return inf_cnt() > 0 and ' ' .. inf_cnt() .. ' ' or ''
                        end,
                        padding = 0
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
