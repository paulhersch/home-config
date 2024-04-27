local a = vim.api

local M = {}

M.get_t_of_buf = function(buf)
    local fname = a.nvim_buf_get_name(buf)
    local status, result = pcall(string.match, fname, "[^/]+$")
    if status then return result end
    return fname
end

return M
