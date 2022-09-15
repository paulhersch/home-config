require("nvim-tree").setup {
    --disable standard file browser and replace with nvim-tree
    disable_netrw = true,
    hijack_netrw = true,

    --autostart
    open_on_tab = true,
    open_on_setup = true,

    hijack_cursor = true, --sets cursor to start of line
    update_cwd = true,
    diagnostics = {
        enable = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
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
        indent_markers = {
            enable = false,
            icons = {
                corner = "└",
                edge = "│",
                item = "│",
                none = " ",
            },
        },
        icons = {
            padding = " ",
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    renamed = "➜",
                    staged = "✓",
                    unmerged = "",
                    unstaged = "✗",
                    untracked = "★",
                },
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                    default = "",
                    empty = "",
                    open = "",
                    symlink = "",
                }
            }
        }
    }
}

require('bufferline').setup{
    animation = false,
    auto_hide = true,
    icon_separator_active = '┃',-- vim.opt.fillchars.vert,
    icon_separator_inactive ='┃',-- vim.opt.fillchars.vert
}

local nvim_tree_events = require('nvim-tree.events')
local bufferline_state = require('bufferline.state')

local function get_tree_size()
    return require('nvim-tree.view').View.width
end

nvim_tree_events.subscribe("TreeOpen", function()
    bufferline_state.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("Resize", function()
    bufferline_state.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("TreeClose", function()
    bufferline_state.set_offset(0)
end)

require("gitsigns").setup()

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
local evblush = require "everblush.core".get_colors()
require("lualine").setup {
    options = {
        section_separators = { left = '', right = ''},
        icons_enabled = true,
        theme = {
            --personalized version of everblushs lualine theme
            normal = {
                a = { bg = evblush.color4, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
            insert = {
                a = { bg = evblush.color2, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
            visual = {
                a = { bg = evblush.color5, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
            replace = {
                a = { bg = evblush.color1, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
            command = {
                a = { bg = evblush.color7, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
            inactive = {
                a = { bg = evblush.color4, fg = evblush.background },
                b = { bg = evblush.color0, fg = evblush.color7 },
                c = { bg = evblush.contrast, fg = evblush.background }
            },
        },
        disabled_filetypes = { 'packer' },
        globalstatus = true,
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
                color = { bg = evblush.color0, fg = evblush.color4 },
                separator = { left = '', right = ''},
                symbols = {
                    readonly = '(readonly)',
                    modified = ' [+]',
                    unnamed = 'unnamed'
                }
            },
            {
                'branch',
                color = { bg = evblush.contrast, fg = evblush.color7 }
            }
        },
        lualine_c = { }, --filler for the middle
        lualine_x = { },
        lualine_y = {
            {
                'diagnostics',
                color = { bg = evblush.contrast },
                sources = { 'nvim_lsp', 'nvim_diagnostic' },
                sections = { 'error', 'warn' },
                colored = true,
                symbols = { error = '✗ ', warn = '！' },
                separator = { left = '', right = ''},
            },
            {
                'filetype',
                color = { bg = evblush.color0, fg = evblush.color4 }
            }
        },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = { 'filename' },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { 'location' },
        lualine_z = {}
    },
    tabline = { },
    extensions = { nvimtree_extension },
}

require ("telescope").setup {
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
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
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
