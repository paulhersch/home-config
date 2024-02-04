return {
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
    config = function ()
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
                    vim.api.nvim_echo({{"Did you try to put a string in a table?"}}, false, {})
                end
                notif_text = notif_text .. chunk[1]
            end
            notif.notify(notif_text, "info", {
                title = "Echo Message",
                hide_from_history = not history
            })
        end
    end
}
