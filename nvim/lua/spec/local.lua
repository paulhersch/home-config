return {
    {
        "colors",
        dev = true,
        priority = 1000,
        name = "colors",
        lazy = false,
        opts = {
            theme = "light"
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
            { "bb", function() require('bffrmgr').open() end, noremap = true }
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
