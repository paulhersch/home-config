return {
    {
        'zk-org/zk-nvim',
        lazy = true,
        config = function()
            require("zk").setup {
                picker = "select",
                lsp = {
                    auto_attach = { enabled = true }
                }
            }
        end
    },
    {
        "miversen33/netman.nvim",
        lazy = true,
        config = function()
            require("netman")
        end
    },
    {
        'GCBallesteros/jupytext.nvim',
        event = "VeryLazy",
        opts = {
            custom_language_formatting = {
                python = {
                    extension = "md",
                    style = "markdown",
                    force_ft = "markdown", -- you can set whatever filetype you want here
                },
            }
        }
    },
    {
        'Olical/conjure',
        event = "VeryLazy"
    },
    {
        'Shatur/neovim-session-manager',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        cmd = "SessionManager",
        config = function()
            local Path = require('plenary.path')
            require('session_manager').setup({
                sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
                path_replacer = '__',
                colon_replacer = '++',
                autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
                autosave_last_session = true,
                autosave_ignore_not_normal = true,
                autosave_ignore_dirs = {},
                autosave_ignore_filetypes = {
                    'gitcommit',
                },
                autosave_ignore_buftypes = {
                    'nofile',
                    'terminal'
                },
                autosave_only_in_session = false,
                max_path_length = 80,
            })
        end,
        keys = {
            { "fs", "<cmd>SessionManager load_session<cr>" },
            { "ds", "<cmd>SessionManager delete_session<cr>" }
        }
    },
}
