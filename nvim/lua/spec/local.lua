return {
    {
        dir = '~/.config/nvim/lua/color',
        priority = 1000,
        name = "colors",
        lazy = false,
        config = function()
            require("color").setup {
                theme = "light"
            }
        end,
    },
    {
        dir = '~/.config/nvim/lua/winstatabline',
        dependencies = {
            'colors'
        },
        event = "UIEnter",
        config = function()
            require("winstatabline").setup()
        end,
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
            { "bb", function() require('bffrmgr').open() end, noremap = true }
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
}
