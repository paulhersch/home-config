local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local nvimtree = require "plugins.confs.nvimtree"
local barbar = require "plugins.confs.barbar"
local gitsigns = require "plugins.confs.gitsigns"
--local lualine = require "plugins.confs.lualine"
local lspc = require "plugins.confs.lspconfs"
local cmp = require "plugins.confs.cmp"
local telescope = require "plugins.confs.telescope"
local dashboard = require "plugins.confs.dashboard"
local dap = require "plugins.confs.dap"
local comment = require "plugins.confs.comment"

require"lazy".setup({
    nvimtree,
    barbar,
    gitsigns,
    --lualine,
    lspc,
    cmp,
    telescope,
    dashboard,
    dap,
    comment,
    {
        dir = '~/.config/nvim/lua/azul',
        name = "colors",
        lazy = false,
        priority = 1000,
        config = function()
            require("azul").setup{}
        end
    },
    {
        dir = '~/.config/nvim/lua/statusline',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'colors'
        },
        name = "statusline",
        lazy = false,
        config = function ()
            require("statusline")
        end
    },
    {
        'direnv/direnv.vim',
        lazy = false,
        init = function ()
            local g = vim.g
            g.direnv_auto = 0
            g.direnv_silent_load = 1
        end,
        config = function ()
            local a = vim.api
            local augroup = a.nvim_create_augroup("DirenvLoadAucmds", {clear=true})
            a.nvim_create_autocmd("User", {
                pattern = "DirenvLoaded",
                group = augroup,
                callback = function ()
                    vim.notify({"Direnv Loaded"}, vim.log.levels.INFO, {title = "direnv.vim"})
                end
            })
            a.nvim_create_autocmd("User", {
                pattern = "SessionLoadPost",
                group = augroup,
                command = ":DirenvExport"
            })
        end
    },
    {
        "phaazon/hop.nvim",
        lazy = true,
        branch = "v2",
        config = function ()
            require("hop").setup { keys = 'etovxqpdygfblzhckisuran' }
        end,
        keys = {
            { "h", "<cmd>HopWord<cr>", noremap = true, mode = {"n", "x"}}
        }
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        lazy = true,
        --hacky way of lazy loading telscope ui-select
        init = function()
            vim.ui.select = function (...)
                require("telescope").load_extension("ui-select")
                vim.ui.select(...)
            end
        end
    },
    {
        'rcarriga/nvim-notify',
        dependencies = {
		    'nvim-lua/plenary.nvim',
        },
        lazy = true,
        init = function()
            vim.notify = function(...)
                require("notify")
                vim.notify(...)
            end
            vim.api.nvim_echo = function(...)
                require("notify")
                vim.api.nvim_echo(...)
            end
        end,
        config = function ()
            local notif = require("notify")
            notif.setup({
                render = "default",
                stages = "slide",
                timeout = 3500
            })
            vim.notify = notif
            -- redirect echo to use notify, doesnt work with builtin vim cmd rn
            vim.api.nvim_echo = function(chunks, history, opts)
                local notif_text = ""
                for _, chunk in pairs(chunks) do
                    notif_text = notif_text .. chunk[1]
                end
                notif.notify(notif_text, "info", {
                    title = "Echo Message",
                    hide_from_history = not history
                })
            end
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "BufEnter",
        config = function()
            require("nvim-autopairs").setup{}
        end
    },
    {
        'Shatur/neovim-session-manager',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        --event = 'VimEnter'
        cmd = "SessionManager",
        config = function ()
            local Path = require('plenary.path')
            require('session_manager').setup ({
                sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
                path_replacer = '__',
                colon_replacer = '++',
                autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
                autosave_last_session = true,
                autosave_ignore_not_normal = true,
                autosave_ignore_dirs = {},
                autosave_ignore_filetypes = {
                    'gitcommit',
                    'NvimTree',
                    'toggleterm',
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
    {
        'lukas-reineke/indent-blankline.nvim',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        event = "BufEnter",
        config = function()
            require("indent_blankline").setup {
                space_char_blankline = " ",
                show_current_context = true,
            }
        end
    },
    {
        'NvChad/nvim-colorizer.lua',
        ft = { "css", "lua" },
        config = function ()
            require 'colorizer'.setup({})
        end
    },
    {
        'glepnir/lspsaga.nvim',
        branch = 'main',
        lazy = true,
        config = function ()
            require('lspsaga').setup{
                diagnostic_header = { "✋", "👆", "👉", "🤏" },
                symbol_in_winbar = {
                    enable = false,
                    separator = '  '
                },
                lightbulb = {
                    enable = true,
                    enable_in_insert = false,
                    virtual_text = false
                },
            }
        end,
        keys = {
            { "ca", "<cmd>Lspsaga code_action <CR>" },
            { "gr", "<cmd>Lspsaga rename <CR>" },
            { "<C-R>", "<cmd>Lspsaga rename <CR>", mode = "i" },
            { "gd", "<cmd>Lspsaga peek_definition <CR>" },
            { "D", "<cmd>Lspsaga hover_doc <CR>" },
            { "<C-D>", "<cmd>Lspsaga diagnostic_jump_next <CR>", mode = {"i", "n"}}
        }
    },
    {
        'akinsho/toggleterm.nvim',
        config = function ()
            local colors = require("azul.core").get_colors()
            require("toggleterm").setup {
                autochdir = true,
                direction = 'float',
                float_opts = {
                    border = 'single'
                },
                highlights = {
                    FloatBorder = {
                        guifg=colors.contrast,
                        guibg=colors.contrast
                    }
                }
            }
        end,
        keys = {
            { "tt", "<cmd>ToggleTerm<CR>" },
            { "<C-T>", "<cmd>ToggleTerm<CR>", mode = "t" }
        }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'tree-sitter/tree-sitter',
        },
        event = "BufEnter",
        build = function()
            require("nvim-treesitter").install.update()
        end,
        config = function()
            require("nvim-treesitter.configs").setup {
                sync_install = false,
                ensure_installed = "all",
                indent = {
                    enable = true
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                }
            }
        end
    },
    {
        'j-hui/fidget.nvim',
        event = "LspAttach",
        config = function ()
            require('fidget').setup{
                text = {
                    spinner = {"", "", "", "", "", ""}
                }
            }
        end
    },
    {
        'stevearc/aerial.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter'
        },
        config = function ()
            require('aerial').setup{}
        end,
        keys = {
            { "<Space>a", "<cmd>AerialToggle<cr>" }
        }
    },
    {
        'folke/trouble.nvim',
        dependencies = 'folke/lsp-colors.nvim',
        config = function()
            local colors = require("azul.core").get_colors()
            require("lsp-colors").setup({
                Error = colors.color1,
                Warning = colors.color3,
                Information = colors.color4,
                Hint = colors.color6
            })
            require("trouble").setup{}
            vim.diagnostic.config({
                virtual_text = false
            })
        end,
        keys = {
            { "<Space>t", "<cmd>TroubleToggle<cr>" }
        }
    }
}, {
        change_detection = {
            enabled = true,
            notify = true
        }
    })
