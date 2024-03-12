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
    -- {
    --     dir = '~/.config/nvim/lua/dash',
    --     dependencies = {
    --         --'ahmedkhalf/project.nvim',
    --         --'nvim-lua/plenary.nvim'
    --     },
    --     lazy = false,
    --     config = function ()
    --         require("dash").setup()
    --     end
    -- }
}
