return {
    {
        'direnv/direnv.vim',
        lazy = false,
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
            a.nvim_create_autocmd("User", {
                pattern = "SessionLoadPost",
                group = augroup,
                command = ":DirenvExport"
            })
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "BufEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end
    },
    {
        'akinsho/toggleterm.nvim',
        lazy = true,
        config = function()
            require("toggleterm").setup {
                autochdir = true,
                direction = 'float',
                float_opts = {
                    border = 'single'
                },
            }
        end,
        keys = {
            { "tt",    "<cmd>ToggleTerm<CR>" },
            { "<C-T>", "<cmd>ToggleTerm<CR>", mode = "t" }
        }
    },
    {
        'frabjous/knap',
        lazy = true,
        keys = {
            { "sp", function() require("knap").toggle_autopreviewing() end }
        },
        config = function()
            local settings = {
                delay = 2000,
                texoutputext = "pdf",
                textopdfbufferasstdin = true,
                textopdf = "lualatex --synctex=1 --halt-on-error --jobname \"$(basename -s .pdf %outputfile%)\"",
                textopdfviewerlaunch =
                "zathura --synctex-editor-command 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"' %outputfile%",
                textopdfviewerrefresh = "none",
                textopdfforwardjump = "zathura --synctex-forward=%line%:%column%:%srcfile% %outputfile%"
            }
            vim.g.knap_settings = settings
        end
    },
    {
        'numToStr/Comment.nvim',
        event = "VeryLazy",
        config = function()
            require("Comment").setup({
                mappings = { basic = true, extra = false },
                opleader = {
                    line = "c"
                },
            })
        end,
    },
}
