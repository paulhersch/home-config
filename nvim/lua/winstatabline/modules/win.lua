local fn = vim.fn
local util = require("winstatabline.modules.util")

local M = {}

M.fileinfo = function(buf)
    local fname = util.get_t_of_buf(buf)
    local edited = fn.getbufinfo(buf)[1].changed == 1
    local perms = fn.getfperm(fname)

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
