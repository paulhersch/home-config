return {
    {
        "colors",
        dev = true,
        -- priority = 1000,
        name = "colors",
        lazy = false,
        config = function()
            vim.opt.termguicolors = true
            require "colors".set_theme("light")
        end,
        keys = {
            { "<space>C", function() require "colors".pick_theme() end },
            { "<space>cr", function()
                require "colors.compiler".build_cache()
                vim.notify("Colorscheme cache rebuilt :)")
            end }
        }
    },
    {
        "clanker",
        dev = true,
        dependencies = {
            "plenary.nvim"
        },
        event = "VeryLazy",
        opts = {}
    },
    {
        "winstatabline",
        dev = true,
        dependencies = {
            'colors',
            -- "uga-rosa/utf8.nvim" tried to overline items, didn't go well
        },
        event = "UIEnter",
        config = function()
            local statusmod = require("winstatabline.modules.status")
            local tabmod = require("winstatabline.modules.tab")
            local line = require("winstatabline.line")
            local o = vim.opt

            -- important options!
            o.laststatus = 3
            o.showtabline = 0
            o.cmdheight = 1
            o.showcmd = false
            o.ruler = false
            o.showmode = false

            -- simple tabline, didnt really need it, as i can also just put tabs in the statusline lol
            -- line(
            --     "tabline", {
            --         {
            --             tabmod.dirname,
            --             events = "DirChanged"
            --         },
            --         {
            --             tabmod.tablist,
            --             events = "BufEnter"
            --         },
            --         "%#TabLineFill#%=%#TabLineCloseLabel#%999X %X"
            --     }, {}
            -- )

            -- statusline and tabline crossover bastard
            line(
                "statusline", {
                    {
                        statusmod.mode,
                        events = "ModeChanged"
                    },
                    {
                        tabmod.tablist,
                        events = line.default_events
                    },
                    -- "%#StatusLineFileName#%t %#StatusLineFileStat#%m%r",
                    "%=",
                    -- {
                    --     vim.schedule(function()
                    --         if package.loaded["micropython_nvim"] and require("micropython_nvim").exists() then
                    --             return require("micropython_nvim").statusline()
                    --         end
                    --         return ""
                    --     end),
                    --     timeout = 1000
                    -- },
                    {
                        statusmod.diagnostics,
                        events = "DiagnosticChanged"
                    },
                    {
                        statusmod.running_lsps,
                        timeout = 5000
                    },
                    {
                        statusmod.git_branch,
                        events = { "BufEnter", "DirChanged" }, -- how to fire directly after loading a session?
                        use_initial = false,
                    },
                    "  "
                }, { hidden_ft = { "alpha" }, padding = 2 }
            )
        end
    },
    {
        "bffrmgr",
        dev = true,
        lazy = false,
        config = function()
            require("bffrmgr").setup({
                max_bufs = 7
            })
        end,
        keys = {
            { "bb", function() require('bffrmgr').open() end, noremap = true, silent = true }
        }
    },
    {
        "presenter",
        dev = true,
        lazy = false,
        opts = {}
    }
    -- {
    --     'evaluator',
    --     dev = true,
    --     lazy = false,
    --     config = function()
    --         require("evaluator").setup({
    --             evalkey = "<C-x><C-e>"
    --         })
    --     end,
    -- },
}
