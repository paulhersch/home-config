return {
    -- lazy fucks up the install of hsluv-lua so i have to resort to
    -- using the luarocks plugin thing
    -- {
    --     "hsluv/hsluv-lua",
    --     name = "hsluv",
    --     lazy = false
    -- },
    {
        "colors",
        dev = true,
        priority = 1000,
        name = "colors",
        lazy = false,
        config = function()
            vim.opt.termguicolors = true
            require "colors".set_theme("light")
        end,
        keys = {
            { "<space>C", function() require "colors".pick_theme() end }
        }
    },
    {
        "winstatabline",
        dev = true,
        dependencies = {
            'colors'
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
