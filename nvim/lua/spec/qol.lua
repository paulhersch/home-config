return {
    {
        'direnv/direnv.vim',
        lazy = false,
        priority = 1000,
        init = function()
            local g = vim.g
            g.direnv_auto = 0
            g.direnv_silent_load = 1
        end,
        config = function()
            local a = vim.api
            local augroup = a.nvim_create_augroup("DirenvLoadAucmds", { clear = true })
            a.nvim_create_autocmd("User", {
                pattern = "DirenvLoaded",
                group = augroup,
                callback = function()
                    vim.notify("Direnv Loaded", vim.log.levels.INFO, { title = "direnv.vim" })
                end
            })
            a.nvim_create_autocmd("DirChanged", {
                group = augroup,
                command = ":DirenvExport"
            })
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end
    },
    {
        'nvzone/typr',
        dependencies = "nvzone/volt",
        cmd = { "Typr", "TyprStats" },
        opts = {}
    },
    {
        'akinsho/toggleterm.nvim',
        opts = {
            autochdir = true,
            direction = 'float',
            float_opts = {
                border = 'single'
            },
            highlights = {
                Normal = { link = "ToggleTermNormal" },
                NormalFloat = { link = "ToggleTermNormal" },
                FloatBorder = { link = "FloatBorder" }
            }
        },
        keys = {
            { "tt",    "<cmd>ToggleTerm<CR>", silent = true },
            { "<C-T>", "<cmd>ToggleTerm<CR>", mode = "t",   silent = true }
        }
    },
    -- {
    --     "nvzone/floaterm",
    --     dependencies = "nvzone/volt",
    --     opts = {
    --         border = false,
    --         mappings = {
    --             sidebar = function(buf)
    --                 vim.keymap.set({ "n" }, "<C-Down>", function()
    --                     require("floaterm.api").cycle_term_bufs("next")
    --                 end, { buffer = buf })
    --                 vim.keymap.set({ "n" }, "<C-Up>", function()
    --                     require("floaterm.api").cycle_term_bufs("prev")
    --                 end, { buffer = buf })
    --             end
    --         }
    --     },
    --     cmd = "FloatermToggle",
    --     keys = {
    --         { "tt",    "<cmd>FloatermToggle<CR>", silent = true },
    --         { "<C-T>", "<cmd>FloatermToggle<CR>", mode = "t",   silent = true }
    --     }
    -- },
    {
        'nvim-telescope/telescope.nvim',
        lazy = true,
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-fzy-native.nvim'
        },
        cmd = { "Telescope" },
        config = function()
            local t = require("telescope")
            t.setup {
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = "> ",
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
                    path_display = { "truncate" },
                    winblend = 0,
                    border = {},
                    color_devicons = true,
                    set_env = { ["COLORTERM"] = "truecolor" },
                    preview = {
                        filetype_hook = function(filepath, _, _)
                            local matches = vim.tbl_filter(function(ending)
                                return filepath:match(ending)
                            end, {
                                "*.out"
                            })
                            return #matches == 0
                        end,
                        -- mime_hook = function(path, buf, opts)
                        --     local is_image = function(path)
                        --         local image_extensions = { 'png', 'jpg' } -- Supported image formats
                        --         local split_path = vim.split(filepath:lower(), '.', { plain = true })
                        --         local extension = split_path[#split_path]
                        --         return vim.tbl_contains(image_extensions, extension)
                        --     end
                        --
                        --     if (is_image(path)) then
                        --         local img = require("magick").load_image(path)
                        --         local stdout = vim.uv.new_tty(1, false)
                        --         if not stdout then
                        --             return
                        --         end
                        --
                        --         img:set_format("sixel")
                        --         stdout:write({
                        --             "\x1B[s\x1B[",
                        --             img:get_blob()
                        --         })
                        --     end
                        -- end
                    }
                },
            }
            t.load_extension("notify")
            t.load_extension("fzy_native")
        end,
        keys = {
            { "gf", function() require("telescope.builtin").live_grep() end },
            { "ff", function() require("telescope.builtin").find_files({ hidden = true }) end },
            { "gs", function() require("telescope.builtin").git_status() end },
            { "gt", function() require("telescope.builtin").lsp_references() end },
            { "fr", function() require("telescope.builtin").resume() end }
        }
    },
    {
        'lervag/vimtex',
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "zathura"
        end
    },
    -- {
    --     'frabjous/knap',
    --     lazy = true,
    --     keys = {
    --         { "sp", function() require("knap").toggle_autopreviewing() end }
    --     },
    --     config = function()
    --         local settings = {
    --             delay = 2000,
    --             texoutputext = "pdf",
    --             textopdfbufferasstdin = true,
    --             textopdf = "lualatex --synctex=1 --halt-on-error --jobname \"$(basename -s .pdf %outputfile%)\"",
    --             textopdfviewerlaunch =
    --             "zathura --synctex-editor-command 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"' %outputfile%",
    --             textopdfviewerrefresh = "none",
    --             textopdfforwardjump = "zathura --synctex-forward=%line%:%column%:%srcfile% %outputfile%"
    --         }
    --         vim.g.knap_settings = settings
    --     end
    -- },
    {
        'numToStr/Comment.nvim',
        event = "VeryLazy",
        opts = {
            mappings = { basic = true, extra = false },
            opleader = {
                line = "<leader>c",
                block = "<leader>cb"
            },
        }
    },
}
