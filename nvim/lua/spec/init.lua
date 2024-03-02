return {
    {
        dir = '~/.config/nvim/lua/color',
        priority = 1000,
        name = "colors",
        lazy = false,
        config = function()
            require("color").setup {
                dark = false
            }
        end,
    },
    {
        dir = '~/.config/nvim/lua/statusline',
        dependencies = {
            'uga-rosa/utf8.nvim',
            'colors'
        },
        name = "statusline",
        lazy = true,
        config = function ()
            require("statusline").setup()
        end,
        event = "UIEnter"
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
                char = "│",
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
        "luukvbaal/statuscol.nvim", config = function()
            -- fold settings, only relevant with this plugin
            vim.opt.foldcolumn = "1"
            _G.custom_foldtext = function ()
                local lstart, lend = vim.v.foldstart, vim.v.foldend
                local bufnr = vim.api.nvim_get_current_buf()
                local sline = vim.api.nvim_buf_get_lines(bufnr, lstart-1, lstart, false)
                local eline = vim.api.nvim_buf_get_lines(bufnr, lend-1, lend, false)
                -- remove whitespace at begin of string
                local eline_removed_ws, _ = string.gsub(eline[1], "^[%s]*", "")
                return sline[1] .. " ... " .. eline_removed_ws .. "    " .. lend - lstart
            end
            vim.opt.foldtext = "v:lua.custom_foldtext()"

            -- actual plugin settings
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                -- configuration goes here, for example:
                -- relculright = true,
                segments = {
                    { text = { "%s " }, click = "v:lua.ScSa" },
                    { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                    { text = { " %l" } }
                },
                ft_ignore = { "bffrmgr" },
                bt_ignore = { "nofile" }
            })
        end,
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
            --remove diagnostics at end of line
            vim.diagnostic.config({
                virtual_text = false
            })
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
}
