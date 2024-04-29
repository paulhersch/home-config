local a = vim.api

local M = {}

-- get the last part of a filename (like a.lua)
M.get_trailing = function(fname)
    local status, result = pcall(string.match, fname, "[^/]+$")
    if status then return result end
    return fname
end

M.get_t_of_buf = function(buf)
    local fname = a.nvim_buf_get_name(buf)
    return M.get_trailing(fname)
end

return M
