return {
    'nvim-lualine/lualine.nvim',
    --requires = 'Everblush/everblush.nvim',
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
        local colors = require "azul.core".get_colors()
        require("lualine").setup {
            options = {
                section_separators = { left = '', right = ''},
                icons_enabled = true,
                theme = {
                    --personalized version of everblushs lualine theme
                    normal = {
                        a = { bg = colors.color4, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                    insert = {
                        a = { bg = colors.color2, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                    visual = {
                        a = { bg = colors.color5, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                    replace = {
                        a = { bg = colors.color1, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                    command = {
                        a = { bg = colors.color7, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                    inactive = {
                        a = { bg = colors.color4, fg = colors.background },
                        b = { bg = colors.color0, fg = colors.color7 },
                        c = { bg = colors.contrast, fg = colors.contrast }
                    },
                },
                disabled_filetypes = { 'packer' },
                globalstatus = false,
            },
            sections = {
                lualine_a = {
                    {
                        'mode',
                        seperator = { left = '', right = '' },
                    }
                },
                lualine_b = {
                    {
                        'filename',
                        color = { bg = colors.color0, fg = colors.color4 },
                        separator = { left = '', right = ''},
                        symbols = {
                            readonly = '(readonly)',
                            modified = ' [+]',
                            unnamed = 'unnamed'
                        }
                    },
                    {
                        'branch',
                        color = { bg = colors.contrast, fg = colors.color7 }
                    }
                },
                lualine_c = { }, --filler for the middle
                lualine_x = { },
                lualine_y = {
                    {
                        'diagnostics',
                        color = { bg = colors.contrast },
                        sources = { 'nvim_lsp', 'nvim_diagnostic' },
                        sections = { 'error', 'warn' },
                        colored = true,
                        symbols = { error = '✗ ', warn = '！' },
                        separator = { left = '', right = ''},
                    },
                    {
                        'filetype',
                        color = { bg = colors.color0, fg = colors.color4 }
                    }
                },
                lualine_z = {}
                --lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = { 'filename' },
                lualine_c = {},
                lualine_x = {},
                --lualine_y = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
            tabline = { },
            extensions = { nvimtree_extension },
        }
    end
}
