local modules = require("statusline.modules")
local utf8 = utf8 or require("utf8")
local concat = table.concat
local a = vim.api
local o = vim.opt
local fn = vim.fn

local P = {}
local M = {}

o.laststatus = 3

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
P.default_line = {
    "%#StatusLine#",
    modules.mode(),
    "%#StatusLine# ",
    modules.file_edited(),
    modules.fileinfo(),
    modules.lsp_info(),
    "%=",
    "%#StatusLine#",
    modules.git_branch(),
    " "
}

P.extra_buf_type_lines = {
    toggleterm = "%#StatusLineTerminalSymbol#   %#StatusLine# TERMINAL ", -- %#StatusLineNC#",
    NvimTree = "%#StatusLineFileexplorerSymbol#   %#StatusLine# FILES ", --%#StatusLineNC#",
    TelescopePrompt = "%#StatusLineFileexplorerSymbol#   %#StatusLine# TELESCOPE ", --%#StatusLineNC#",
    lazy = "%#StatusLinePackagemanagerSymbol#   %#StatusLine# LAZY ", --%#StatusLineNC#",
    dashboard = "%#StatusLineFileexplorerSymbol#   %#StatusLine# DASHBOARD ",-- %#StatusLineNC#",
    bffrmgr = "%#StatusLineFileexplorerSymbol#   %#StatusLine# BUFFERS ",-- %#StatusLineNC#",
    aerial = "%#StatusLineFileexplorerSymbol#   %#StatusLine# SYMBOLS ",-- %#StatusLineNC#"
}
-- mappings
P.extra_buf_type_lines.terminal = P.extra_buf_type_lines.toggleterm
P.extra_buf_type_lines["neo-tree"] = P.extra_buf_type_lines.NvimTree

-----
-- the idea of this bit is, that UI wants to update a little more often than the line
-- needs to, so instead of just having a function that runs all the function calls again
-- the modules will replace their old states in the table represantation of the line
-- when they need to
-----

-- default update events
-- {"WinEnter", "BufEnter", "SessionLoadPost", "FileChangedShellPost", "VimResized", "Filetype", "CursorMoved", "CursorMovedI"}

-- technically it would also be possible to remove aucmds whenever the buffer is changed to
-- something like telescope, but the cost of registering aucmds is pretty high compared to just ignoring
-- like 3 updates while being in this buffer

P.update_line = function()
    local buf_type = fn.getbufvar(a.nvim_get_current_buf(), '&filetype')
    if P.extra_buf_type_lines[buf_type] then
        o.statusline = P.extra_buf_type_lines[buf_type]
    else
        o.statusline = concat(P.default_line)
    end
end

-- autogroup
-- if module is reloaded the autocmds will be reloaded as well
P.autogroup = a.nvim_create_augroup("StatuslineAG", {clear = true})

-- update individual modules
a.nvim_create_autocmd({"DiagnosticChanged"}, {
    group = P.autogroup,
    callback = function ()
        P.default_line[6] = modules.lsp_info()
        P.update_line()
    end
})

a.nvim_create_autocmd({"FileChangedShellPost", "TextChangedI", "TextChanged", "BufWritePost", "BufEnter"}, {
    group = P.autogroup,
    callback = function ()
        P.default_line[4] = modules.file_edited()
        P.update_line()
    end
})

a.nvim_create_autocmd({"BufEnter", "BufLeave", "WinEnter", "WinLeave"}, {
    group = P.autogroup,
    callback = function ()
        P.default_line[5] = modules.fileinfo()
        P.default_line[9] = modules.git_branch()
        P.update_line()
    end
})

a.nvim_create_autocmd("ModeChanged", {
    group = P.autogroup,
    callback = function ()
        P.default_line[2] = modules.mode()
        P.update_line()
    end
})

return M
