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
					--c = { bg = colors.contrast, fg = colors.contrast }
					c = { bg = colors.background, fg = colors.background }
				},
				insert = {
					a = { bg = colors.color4, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
				},
				visual = {
					a = { bg = colors.color5, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
				},
				replace = {
					a = { bg = colors.color1, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
				},
				command = {
					a = { bg = colors.color7, fg = colors.color0, bold = true },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
				},
				inactive = {
					a = { bg = colors.color4, fg = colors.color0 },
					b = { bg = colors.color0, fg = colors.color15 },
					c = { bg = colors.background, fg = colors.background }
				},
			}
		end

        local separator = {
            function ()
                return ' '
            end,
            color = { bg = colors.background }
        }
        local function lsp()
            local error_count, warning_count, info_count
            -- On nvim 0.6+ use vim.diagnostic to get lsp generated diagnostic count.
            local diagnostics = vim.diagnostic.get(0)
            local count = { 0, 0, 0, 0 }
            for _, diagnostic in ipairs(diagnostics) do
                if vim.startswith(vim.diagnostic.get_namespace(diagnostic.namespace).name, 'vim.lsp') then
                    count[diagnostic.severity] = count[diagnostic.severity] + 1
                end
            end
            error_count = count[vim.diagnostic.severity.ERROR]
            warning_count = count[vim.diagnostic.severity.WARN]
            info_count = count[vim.diagnostic.severity.INFO]
            --[[return {
                {
                        [[ ,
                        color = {bg = colors.color1, fg = colors.background}
                },
                separator,
                separator
            }]]
            local test = "test"
            return test
        end
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
                            '  ',
                            color = { bg = colors.color15, fg = colors.color0 },
                        },
						color = { bg = colors.contrast, fg = colors.color7 }
					}

				},
				lualine_c = {}, --filler for the middle, has funny fill icons when anything is in there so no use
				lualine_x = { },
				lualine_y = {
                    --[[{
                        function ()
                            return error_cnt() > 0 and '   ' or ''
                        end,
                        color = { bg = colors.color1, fg = colors.background },
                        padding = 0
                    },
                    {
                        function ()
                            return error_cnt() > 0 and ' ' .. error_cnt() .. ' ' or ' '
                        end
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
                        end
                    },
                   separator,
                    {
                        function ()
                            return hint_cnt() > 0 and '   ' or ''
                        end,
                        color = { bg = colors.color2, fg = colors.background },
                        padding = 0
                    },
                    {
                        function ()
                            return hint_cnt() > 0 and ' ' .. hint_cnt() .. ' ' or ''
                        end
                    },]]
                    lsp,
                    {
                        'diagnostics',

                        -- Table of diagnostic sources, available sources are:
                        --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                        -- or a function that returns a table as such:
                        --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                        sources = { 'nvim_lsp' },

                        -- Displays diagnostics for the defined severity types
                        sections = { 'error', 'warn', 'info' },

                        --[[diagnostics_color = {
                            error = 'DiagnosticError', -- Changes diagnostics' error color.
                            warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
                            info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
                        },]]
                        symbols = {error = ' ', warn = ' ', info = ' '},
                        colored = true,           -- Displays diagnostics status in color if set to true.
                        update_in_insert = false, -- Update diagnostics in insert mode.
                        always_visible = false,   -- Show diagnostics even if there are none.
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
			extensions = { tree_ext, term_ext },
		}
	end
}
