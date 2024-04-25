--[[

Custom statusline, personal use only. I do not recommend
using any of this, i do not know what i am doing

--]]

local modules = require("winstatabline.modules")
-- local utf8 = utf8 or require("utf8")
local concat = table.concat
local a = vim.api
local o = vim.opt
local g = vim.g

local P = {}
local M = {}

-- format every character as char with overline
-- for some reason the statusline shits itself when i try to
-- concat strings with overlines
-- they also look funny
-- M.overlineify = function(in_str)
--     local ret = ""
--     -- not how the spec describes how this is supposed
--     -- to work but if it works it works
--     for _, char in utf8.codes(in_str) do
--         ---@diagnostic disable-next-line: param-type-mismatch
--         local codepoint = utf8.codepoint(char)
--         ret = ret .. utf8.char(codepoint, 9620)
--     end
--     return ret
-- end

-- initial state
-- P.active = function(buf)
--     return {
--         modules.mode(),
--         modules.lsp_info(),
--     }
-- end
--
-- P.inactive = function(buf)
--     return {
--         modules.fileinfo(buf)
--     }
-- end

-- P.special_lines = {
--     toggleterm = "%#StatusLineTerminalSymbol#   %#StatusLine# term ",
--     NvimTree = "%#StatusLineFileexplorerSymbol#   %#StatusLine# files ",
--     TelescopePrompt = "%#StatusLineFileexplorerSymbol#   %#StatusLine# telescope ",
--     lazy = "%#StatusLinePackagemanagerSymbol#   %#StatusLine# lazy ",
--     dashboard = "%#StatusLineFileexplorerSymbol#   %#StatusLine# dash ",
--     bffrmgr = "%#StatusLineFileexplorerSymbol#   %#StatusLine# buffers ",
--     aerial = "%#StatusLineFileexplorerSymbol#   %#StatusLine# symbols ",
-- }
-- -- mappings
-- P.special_lines.terminal = P.special_lines.toggleterm
-- P.special_lines["neo-tree"] = P.special_lines.NvimTree

P.statusline = function()
    return concat({
        modules.mode(),
        "%=",
        modules.diagnostics(),
        modules.running_lsps(),
        modules.git_branch(),
        " "
    })
end

P.winbar = function()
    local win = g.statusline_winid
    local buf = a.nvim_win_get_buf(win)

    return concat({
        "%#WinBarNC#%=%#WinBar# ",
        modules.fileinfo(buf),
        " %#WinBarNC#%=",
    })
end

M.setup = function()
    _G.statusline = P.statusline
    _G.winbar = P.winbar
    o.laststatus = 3
    o.cmdheight = 0
    o.showcmd = false
    o.ruler = false
    o.showmode = false

    o.statusline = "%!v:lua.statusline()"
    o.winbar = "%!v:lua.winbar()"

    local aug = a.nvim_create_augroup("winstatabline", { clear = true })
end

return M
