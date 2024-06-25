local a = vim.api
local fn = vim.fn
local util = require("winstatabline.modules.util")

local M = {}

M.dirname = function()
    local dir = fn.getcwd()
    local home = os.getenv("HOME") or ""
    local dir_str = string.gsub(dir, home, "~")

    return "%#TabLineDir# " .. dir_str .. " %#TabLineFill#"
end

M.tablist = function()
    local ret_str = ""
    local tabs = a.nvim_list_tabpages()
    for index, tab in ipairs(tabs) do
        if a.nvim_tabpage_is_valid(tab) then
            local selected = tab == a.nvim_get_current_tabpage()

            local win = a.nvim_tabpage_get_win(tab)
            local buf = a.nvim_win_get_buf(win)
            local name, _ = util.get_t_of_buf(buf)

            -- sorry to everyone who has to decipher this nightmare
            ret_str = ret_str .. string.format(
                "%%#%s#  %%%iT%s%%T %%#%s#%%%iX %%X ",
                selected and "TabLineSel" or "TabLine",
                index,
                name,
                selected and "TabLineSelCloseTabLabel" or "TabLineCloseTabLabel",
                index
            )
        end
    end
    return ret_str .. "%#TabLineFill#"
end

return M
