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
        "winstatabline",
        dev = true,
        dependencies = {
            'colors',
            "uga-rosa/utf8.nvim"
        },
        event = "UIEnter",
        opts = {}
    },
    {
        "bffrmgr",
        dev = true,
        lazy = false,
        config = function()
            require("bffrmgr").setup({
                s = 7
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
