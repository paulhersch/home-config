return {
    {
        dir = '~/.config/nvim/lua/azul',
        priority = 1000,
        name = "azul",
        lazy = false,
        config = function()
            require("azul").setup{
                nvim_tree = {
                    contrast = true
                },
                dark = false
            }
        end,
    },
    {
        dir = '~/.config/nvim/lua/statusline',
        dependencies = {
            'uga-rosa/utf8.nvim',
            'azul'
        },
        name = "statusline",
        lazy = true,
        config = function ()
            require("statusline")
        end,
        init = function()
            vim.api.nvim_create_autocmd({"UIEnter"}, {
                callback = function ()
                    require("statusline")
                end
            })
        end
    },
    {
        dir = '~/.config/nvim/lua/bffrmgr',
        lazy = false,
        config = function()
            require("bffrmgr").setup({
                s = 7
            })
        end,
        keys = {
            { "bb", "<cmd>lua require('bffrmgr').open()<cr>", noremap=true }
        }
    },
    {
        dir = '~/.config/nvim/lua/evaluator',
        lazy = false,
        config = function()
            require("evaluator").setup({
                evalkey = "<C-x><C-e>"
            })
        end,
    },
    {
        'zk-org/zk-nvim',
        lazy = false,
        config = function()
            require("zk").setup{
                picker = "select",
                lsp = {
                    auto_attach = { enabled = false }
                }
            }
        end
    },
    {
        'frabjous/knap',
        keys = {
            { "sp", function() require("knap").toggle_autopreviewing() end }
        },
        config = function ()
            local settings = {
                delay = 500,
                texoutputext = "pdf",
                textopdfbufferasstdin = true,
                textopdf = "lualatex --synctex=1 --halt-on-error --jobname \"$(basename -s .pdf %outputfile%)\"",
                textopdfviewerlaunch = "zathura --synctex-editor-command 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"' %outputfile%",
                textopdfviewerrefresh = "none",
                textopdfforwardjump = "zathura --synctex-forward=%line%:%column%:%srcfile% %outputfile%"
            }
            vim.g.knap_settings = settings
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
                    vim.notify("Direnv Loaded", vim.log.levels.INFO, {title = "direnv.vim"})
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
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function (...)
                require("telescope").load_extension("ui-select")
                vim.ui.select(...)
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
    -- {
    --     'Shatur/neovim-session-manager',
    --     dependencies = {
    --         'nvim-lua/plenary.nvim'
    --     },
    --     cmd = "SessionManager",
    --     config = function ()
    --         local Path = require('plenary.path')
    --         require('session_manager').setup ({
    --             sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
    --             path_replacer = '__',
    --             colon_replacer = '++',
    --             autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    --             autosave_last_session = true,
    --             autosave_ignore_not_normal = true,
    --             autosave_ignore_dirs = {},
    --             autosave_ignore_filetypes = {
    --                 'gitcommit',
    --                 'NvimTree',
    --                 'toggleterm',
    --             },
    --             autosave_only_in_session = false,
    --             max_path_length = 80,
    --         })
    --     end,
    --     keys = {
    --         { "fs", "<cmd>SessionManager load_session<cr>" },
    --         { "ds", "<cmd>SessionManager delete_session<cr>" }
    --     }
    -- },
    {
        "miversen33/netman.nvim",
        lazy = false,
        config = function ()
            require("netman")
        end
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        event = "BufEnter",
        main = "ibl",
        opts = {
            indent = {
                -- i dont want a marker on the first indent level
                -- this is the dirtiest of the hacks
                -- if there are any more indents than that needed at any
                -- time, please sign up for the nuthouse
                char = { "", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│", "│" },
                smart_indent_cap = true
            },
            whitespace = {
                remove_blankline_trail = true,
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
            },
            exclude = { filetypes = {
                "bffrmgr",
                "dashboard"
            }}
        }
    },
    {
        'NvChad/nvim-colorizer.lua',
        lazy = false,
        config = function ()
            require 'colorizer'.setup({})
        end
    },
    {
        'glepnir/lspsaga.nvim',
        branch = 'main',
        lazy = true,
        event = "LspAttach",
        config = function ()
            require('lspsaga').setup{
                diagnostic_header = { "✋", "👆", "👉", "🤏" },
                symbol_in_winbar = {
                    enable = true,
                    separator = '  ',
                    show_file = false,
                },
                lightbulb = {
                    enable = false,
                    enable_in_insert = false,
                    virtual_text = false
                },
                ui = {
                    border = "solid"
                }
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
        'https://git.sr.ht/%7Ewhynothugo/lsp_lines.nvim',
        lazy = true,
        event = "LspAttach",
        name = "lsp_lines",
        config = function()
            require("lsp_lines").setup()
        end
    },
    {
        'akinsho/toggleterm.nvim',
        config = function ()
            require("toggleterm").setup {
                autochdir = true,
                direction = 'float',
                float_opts = {
                    border = 'single'
                },
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
        tag = "legacy",
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
            require("trouble").setup{}
            vim.diagnostic.config({
                virtual_text = false
            })
        end,
        keys = {
            { "<Space>t", "<cmd>TroubleToggle<cr>" }
        }
    }
}
