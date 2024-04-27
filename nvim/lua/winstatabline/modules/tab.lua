local a = vim.api
local util = require("winstatabline.modules.util")

local M = {}

M.tablist = function()
    local ret_str = ""
    local tabs = a.nvim_list_tabpages()
    for index, tab in ipairs(tabs) do
        if a.nvim_tabpage_is_valid(tab) then
            local win = a.nvim_tabpage_get_win(tab)
            local buf = a.nvim_win_get_buf(win)
            local name = util.get_t_of_buf(buf)
            local selected = tab == a.nvim_get_current_tabpage()

            -- sorry to everyone who has to decipher this nightmare
            ret_str = ret_str .. string.format(
                "%%#%s#  %%%iT%s%%T %%#%s#%%%iX %%X %%#TabLineFill# ",
                selected and "TabLineSel" or "TabLine",
                index,
                name,
                selected and "TabLineSelCloseTabLabel" or "TabLineCloseTabLabel",
                index
            )
        end
    end
    return ret_str
end

return M
