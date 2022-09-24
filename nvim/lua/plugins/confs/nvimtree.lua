return {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    as = 'nvim-tree',
    setup = function()
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
    end
}
