--[[

Custom statusline, personal use only. I do not recommend
using any of this, i do not know what i am doing

--]]

local modules = require("statusline.modules")
local utf8 = utf8 or require("utf8")
local concat = table.concat
local a = vim.api
local o = vim.opt
local fn = vim.fn
local g = vim.g

local P = {}
local M = {}

-- format every character as char with overline
-- for some reason the statusline shits itself when i try to
-- concat strings with overlines
-- they also look funny
M.overlineify = function(in_str)
    local ret = ""
    -- not how the spec describes how this is supposed
    -- to work but if it works it works
    for _, char in utf8.codes(in_str) do
        ---@diagnostic disable-next-line: param-type-mismatch
        local codepoint = utf8.codepoint(char)
        ret = ret .. utf8.char(codepoint, 9620)
    end
    return ret
end

-- initial state
P.active = function(buf)
    return {
        "%#StatusLine#",
        modules.mode(),
        "%#StatusLine# ",
        modules.fileinfo(buf),
        modules.file_edited(buf),
        "%=",
        modules.lsp_info(),
        " %#StatusLine#",
        modules.git_branch(),
        " "
    }
end

P.inactive = function(buf)
    return {
        "%#StatusLine#   ",
        modules.file_edited(buf),
        modules.fileinfo(buf)
    }
end

P.special_lines = {
    toggleterm = "%#StatusLineTerminalSymbol#   %#StatusLine# term ",
    NvimTree = "%#StatusLineFileexplorerSymbol#   %#StatusLine# files ",
    TelescopePrompt = "%#StatusLineFileexplorerSymbol#   %#StatusLine# telescope ",
    lazy = "%#StatusLinePackagemanagerSymbol#   %#StatusLine# lazy ",
    dashboard = "%#StatusLineFileexplorerSymbol#   %#StatusLine# dash ",
    bffrmgr = "%#StatusLineFileexplorerSymbol#   %#StatusLine# buffers ",
    aerial = "%#StatusLineFileexplorerSymbol#   %#StatusLine# symbols ",
}
-- mappings
P.special_lines.terminal = P.special_lines.toggleterm
P.special_lines["neo-tree"] = P.special_lines.NvimTree

M.get = function()
    local win = g.statusline_winid
    -- check if buf in win has special class for overrides
    local buf = a.nvim_win_get_buf(win)
    local ft = a.nvim_buf_get_option(buf, 'filetype')

    local replacement = P.special_lines[ft]
    if replacement then
        return replacement
    end

    if win == a.nvim_get_current_win() then
        return concat(P.active(buf))
    end
    return concat(P.inactive(buf))
end

M.setup = function()
    o.laststatus = 3
    o.statusline = "%!v:lua.require('statusline').get()"
end

return M
