local a = vim.api
local fn = vim.fn

local P = {}
local M = {}

P.buftype_name_replacements = {
    terminal = "terminal",
}

P.filetype_name_replacements = {
    ['neo-tree'] = "neotree",
    aerial = "aerial",
    ['aerial-nav'] = "aerial",
    dashboard = "dashboard",
    TelescopePrompt = "telescope",
    alpha = "dashboard",
}

-- get the last part of a filename (like a.lua)
M.get_trailing = function(fname)
    local status, result = pcall(string.match, fname, "[^/]+$")
    if status then return result end
    return fname
end

M.get_f = function(fname)
    local cwd = fn.getcwd()
    local status, result = pcall(string.gsub, fname, cwd .. "/", "")
    if status then return result end
    return fname
end

M.get_t_of_buf = function(buf, trim)
    local ft = a.nvim_get_option_value('filetype', { buf = buf })
    local bt = a.nvim_get_option_value('buftype', { buf = buf })

    if P.buftype_name_replacements[bt] then
        return P.buftype_name_replacements[bt], true
    end
    if P.filetype_name_replacements[ft] then
        return P.filetype_name_replacements[ft], true
    end

    -- %f
    local fname = a.nvim_buf_get_name(buf)
    if trim then
        return M.get_trailing(fname), false
    else
        return M.get_f(fname), false
    end
end

return M
