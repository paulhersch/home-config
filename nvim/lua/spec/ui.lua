return {
    {
        "JoosepAlviste/palenightfall.nvim",
        event = "VeryLazy"
    },
    {
        'sindrets/diffview.nvim',
        lazy = false,
        opts = {
            view = {
                merge_tool = {
                    layout = "diff3_mixed"
                }
            }
        }
    },
    {
        'rcarriga/nvim-notify',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        lazy = true,
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.notify = function(...)
                require("notify")
                vim.notify(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.api.nvim_echo = function(...)
                require("notify")
                vim.api.nvim_echo(...)
            end
        end,
        config = function()
            local notif = require("notify")
            notif.setup({
                render = "default",
                stages = "slide",
                timeout = 3500
            })
            vim.notify = notif
            -- redirect echo to use notify, doesnt work with builtin vim cmd rn
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.api.nvim_echo = function(chunks, history, _)
                local notif_text = ""
                for _, chunk in pairs(chunks) do
                    if not chunk[1] then
                        vim.api.nvim_echo({ { "Did you try to put a string in a table?" } }, false, {})
                    end
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
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        opts = {
            signs = false,
        },
        keys = {
            { "<Space>t", function() require("telescope").extensions["todo-comments"].todo() end }
        }
    },
    {
        "luukvbaal/statuscol.nvim",
        event = "UIEnter",
        config = function()
            -- fold settings, only relevant with this plugin
            vim.opt.foldcolumn = "1"
            _G.custom_foldtext = function()
                local lstart, lend = vim.v.foldstart, vim.v.foldend
                local bufnr = vim.api.nvim_get_current_buf()
                local sline = vim.api.nvim_buf_get_lines(bufnr, lstart - 1, lstart, false)
                local eline = vim.api.nvim_buf_get_lines(bufnr, lend - 1, lend, false)
                -- remove whitespace at begin of string
                local eline_removed_ws, _ = string.gsub(eline[1], "^[%s]*", "")
                return sline[1] .. " ... " .. eline_removed_ws .. "    " .. lend - lstart
            end
            vim.opt.foldtext = "v:lua.custom_foldtext()"

            -- actual plugin settings
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                -- configuration goes here, for example:
                segments = {
                    { text = { "%s " },            click = "v:lua.ScSa" },
                    { text = { "%l " } },
                    { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                    { text = { " " } }
                },
                ft_ignore = { "bffrmgr" },
                bt_ignore = { "nofile" }
            })
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        name = "gitsigns",
        event = "VeryLazy",
        config = function()
            local gs = require("gitsigns")
            gs.setup()
        end,
        keys = {
            { "gb", function() require("gitsigns").toggle_current_line_blame() end },
            { "gh", function() require("gitsigns").preview_hunk() end },
            { "ga", function() require("gitsigns").stage_hunk() end },
            { "gu", function() require("gitsigns").undo_stage_hunk() end }
        }
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        event = "VeryLazy",
        main = "ibl",
        opts = {
            indent = {
                char = "¦",
                smart_indent_cap = true
            },
            whitespace = {
                remove_blankline_trail = true,
            },
            scope = {
                char = "│",
                enabled = true,
                show_start = false,
                show_end = false,
            },
            exclude = {
                filetypes = {
                    "bffrmgr",
                    "dashboard"
                }
            }
        }
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        lazy = true,
        --hacky way of lazy loading telscope ui-select
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("telescope").load_extension("ui-select")
                vim.ui.select(...)
            end
        end
    },
    {
        'liangxianzhe/floating-input.nvim',
        lazy = true,
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(opts, confirm)
                require("floating-input").input(opts, confirm, { border = 'single' })
            end
        end
    },
    {
        'glepnir/dashboard-nvim',
        branch = 'master',
        event = "UIEnter",
        config = function()
            require "dashboard".setup({
                theme = 'doom',
                hide = {
                    statusline = true,
                    tabline = true,
                    winbar = true
                },
                config = {
                    center = {
                        {
                            icon = '   ',
                            desc = 'Open Zettelkasten               ',
                            action = 'cd ~/Dokumente/Uni/zk | Neotree toggle source=zk'
                        },
                        {
                            icon = '   ',
                            desc = 'Sessions                      ',
                            key = 'fs',
                            action = "SessionManager load_session"
                        },
                        {
                            icon = '   ',
                            desc = 'Open Tree                    ',
                            action = 'Neotree toggle',
                            key = 'SPC f'
                        },
                        {
                            icon = '   ',
                            desc = 'Find file in cwd                ',
                            action = 'Telescope find_files',
                            key = 'ff'
                        },
                        {
                            icon = '   ',
                            desc = 'Live Grep in cwd                ',
                            action = 'Telescope live_grep',
                            key = 'gf'
                        },
                    },
                    header = {
                        [[       ,                              ]],
                        [[       \`-._           __             ]],
                        [[        \\  \-..____,.'  `.           ]],
                        [[         :  )       :      :\         ]],
                        [[          ;'        '   ;  | :        ]],
                        [[          )..      .. .:.`.; :        ]],
                        [[         /::...  .:::...   ` ;        ]],
                        [[         `:o>   /\o_>        : `.     ]],
                        [[        `-`.__ ;   __..--- /:.   \    ]],
                        [[        === \_/   ;=====_.':.     ;   ]],
                        [[         ,/'`--'...`--....        ;   ]],
                        [[              ;                    ;  ]],
                        [[          . '                       ; ]],
                        [[        .'     ..     ,      .       ;]],
                        [[       :       ::..  /      ;::.     |]],
                        [[      /      `.;::.  |       ;:..    ;]],
                        [[     :         |:.   :       ;:.    ; ]],
                        [[     :         ::     ;:..   |.    ;  ]],
                        [[      :       :;      :::....|     |  ]],
                        [[      /\     ,/ \      ;:::::;     ;  ]],
                        [[    .:. \:..|    :     ; '.--|     ;  ]],
                        [[   ::.  :''  `-.,,;     ;'   ;     ;  ]],
                        [[.-'. _.'\      / `;      \,__:      \ ]],
                        [[`---'    `----'   ;      /    \,.,,,/ ]],
                        [[                   `----`             ]]
                    }
                }
            })
        end
    },
    {
        'stevearc/oil.nvim',
        opts = {
            default_file_explorer = true,
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
            }
        }
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        lazy = true,
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            -- external sources
            "miversen33/netman.nvim",
            {
                -- fix for neotree api changes weren't merged (repo dead?)
                "idanarye/neo-tree-zk.nvim",
                branch = "fix-modified_buffers_changes-to-opened_buffers_changed"
            },
        },
        cmd = { "Neotree" },
        keys = {
            { "<Space>f", "<cmd>Neotree toggle position=float source=last<CR>" }
        },
        config = function()
            require("neo-tree").setup({
                sources = {
                    "netman.ui.neo-tree",
                    "filesystem",
                    "git_status",
                    "zk"
                },
                close_if_last_window = true,
                add_blank_line_at_top = true,
                hide_root_node = true,
                enable_git_status = true,
                enable_diagnostics = true,
                use_popups_for_input = false,
                source_selector = {
                    winbar = true,
                    tabs_layout = "equal",
                    content_layout = "center",
                    sources = {
                        {
                            source = "filesystem",
                            display_name = " "
                        },
                        {
                            source = "git_status",
                            display_name = " "
                        },
                        {
                            source = "remote",
                            display_name = " "
                        },
                        {
                            source = "zk",
                            display_name = " "
                        }
                    },
                    -- this gives the tabline a padded look (vert split is colored by neotree via hl)
                    separator = { left = " ", right = "" },
                    separator_active = { left = " ", right = "" },
                    show_separator_on_edge = true,
                    highlight_separator = "NeoTreeTabSeparator",
                    highlight_separator_active = "NeoTreeTabSeparator",
                },
                default_component_configs = {
                    indent = {
                        padding = 2,
                        expander_collapsed = "",
                        expander_expanded = "",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "",
                    },
                    modified = {
                        symbol = ""
                    },
                    name = {
                        use_git_status_colors = false,
                        highlight_opened_files = true,
                    },
                    git_status = {
                        symbols = {
                            -- Change type
                            added     = "",
                            modified  = "",
                            deleted   = " ",
                            renamed   = " ",
                            -- Status type
                            untracked = " ",
                            ignored   = " ",
                            unstaged  = " ",
                            staged    = " ",
                            conflict  = " ",
                        },
                        align = "left"
                    },
                },
                filesystem = {
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        show_hidden_count = false,
                        use_libuv_file_watcher = true,
                    }
                },
            })
        end
    },
    {
        'NvChad/nvim-colorizer.lua',
        config = function()
            require 'colorizer'.setup({
                user_default_options = {
                    mode = "virtualtext",
                    virtualtext = "██"
                }
            })
        end,
        keys = {
            { "<Space>c", function()
                local c = require "colorizer"
                if c.is_buffer_attached(0) then
                    c.detach_from_buffer(0)
                else
                    c.attach_to_buffer(0)
                end
            end }
        }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'tree-sitter/tree-sitter',
        },
        build = function()
            require("nvim-treesitter").install.update()
        end,
        event = "VeryLazy",
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
                },
                incremental_selection = {
                    enable = true
                }
            }

            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldmethod = "expr"
            -- should keep folds open while still having the identifiers in signcolumn
            vim.opt.foldlevel = 50
            vim.opt.foldenable = true

            -- update folds when Insert is left, they sometimes appear in the wrong places
            vim.api.nvim_create_autocmd({ "InsertLeave" }, {
                callback = function()
                    vim.opt.foldmethod = "expr"
                end,
                desc = "InsertLeave treesitter foldexpr update"
            })
        end
    },
    {
        "ziontee113/syntax-tree-surfer",
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {},
        keys = {
            { "<S-Left>",  '<cmd>STSSelectParentNode<cr>',      mode = "x" },
            { "<S-Right>", '<cmd>STSSelectChildNode<cr>',       mode = "x" },
            { "<S-Up>",    '<cmd>STSSelectPrevSiblingNode<cr>', mode = "x" },
            { "<S-Down>",  '<cmd>STSSelectNextSiblingNode<cr>', mode = "x" },
            { "sv",        '<cmd>STSSelectCurrentNode<cr>' }
        }
    }
}
