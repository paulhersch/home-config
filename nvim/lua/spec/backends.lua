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
        event = "VeryLazy",
        config = function()
            require("netman")
        end
    },
    {
        'romgrk/fzy-lua-native',
        build = ":!make all"
    },
    {
        "jim-at-jibba/micropython.nvim",
        dependencies = {
            "akinsho/toggleterm.nvim",
            "stevearc/dressing.nvim"
        },
        event = "VeryLazy"
    },
    {
        'Shatur/neovim-session-manager',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        lazy = false,
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
                autosave_only_in_session = true,
                max_path_length = 80,
            })
        end,
        keys = {
            { "fs", "<cmd>silent! SessionManager load_session<cr>" },
            { "ds", "<cmd>silent! SessionManager delete_session<cr>" }
        }
    },
    -- {
    --     'gaborvecsei/usage-tracker.nvim',
    --     event = 'VeryLazy',
    --     opts = {
    --         keep_eventlog_days = 90,
    --         cleanup_freq_days = 14,
    --         inactivity_check_freq_in_sec = 10,
    --     }
    -- }
}
