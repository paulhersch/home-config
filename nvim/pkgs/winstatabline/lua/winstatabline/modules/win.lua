local fn = vim.fn
local a = vim.api
local util = require("winstatabline.modules.util")

local M = {}

M.fileinfo = function(buf)
    local file = a.nvim_buf_get_name(buf)

    local fname = util.get_trailing(file)
    local edited = fn.getbufinfo(buf)[1].changed == 1
    local perms = fn.getfperm(file)

    return table.concat {
        "%#WinBarFileName#",
        fname,
        string.format(
            '  %%#WinBarFileStat#%s:%s',
            edited and '+' or '-',
            string.sub(perms, 1, 3)
        )
    }
end

return M
