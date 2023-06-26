local modules = require("statusline.modules")
local concat = table.concat
local a = vim.api
local o = vim.opt
local fn = vim.fn

-- function _G.statusline()
--     return statusline
-- end
-- o.statusline = "%!v:lua.statusline()"
o.laststatus = 3

-- NO UNICODE ESCAPE SUPPORT IN LUAJIT :(((((
-- format every character as char with overline
-- local function overlineify(str)
--     local ret = ""
--     for i=1,string.len(str) do
--         ret = ret .. string.sub(str,i,i) .. "̅̅̅\u80\uBE"
--     end
--     return ret
-- end

-- initial state
local default_line = {
    "%#Normal#",
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

local extra_buf_type_lines = {
    toggleterm = "%#StatusLineTerminalSymbol#   %#StatusLine# TERMINAL ", -- %#StatusLineNC#",
    NvimTree = "%#StatusLineFileexplorerSymbol#   %#StatusLine# FILES ", --%#StatusLineNC#",
    TelescopePrompt = "%#StatusLineFileexplorerSymbol#   %#StatusLine# TELESCOPE ", --%#StatusLineNC#",
    lazy = "%#StatusLinePackagemanagerSymbol#   %#StatusLine# LAZY ", --%#StatusLineNC#",
    dashboard = "%#StatusLineFileexplorerSymbol#   %#StatusLine# DASHBOARD ",-- %#StatusLineNC#",
    bffrmgr = "%#StatusLineFileexplorerSymbol#   %#StatusLine# BUFFERS ",-- %#StatusLineNC#",
    aerial = "%#StatusLineFileexplorerSymbol#   %#StatusLine# SYMBOLS ",-- %#StatusLineNC#"
}

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


local function update_line()
    local buf_type = fn.getbufvar(a.nvim_get_current_buf(), '&filetype')
    if extra_buf_type_lines[buf_type] then
        o.statusline = extra_buf_type_lines[buf_type]
    else
        o.statusline = concat(default_line)
    end
end

-- update individual modules
a.nvim_create_autocmd({"DiagnosticChanged"}, {
    callback = function ()
        default_line[6] = modules.lsp_info()
        update_line()
    end
})

a.nvim_create_autocmd({"FileChangedShellPost", "TextChangedI", "TextChanged", "BufWritePost", "BufEnter"}, {
    callback = function ()
        default_line[4] = modules.file_edited()
        update_line()
    end
})

a.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
    callback = function ()
        default_line[5] = modules.fileinfo()
        default_line[9] = modules.git_branch()
        update_line()
    end
})

a.nvim_create_autocmd("ModeChanged", {
    callback = function ()
        default_line[2] = modules.mode()
        update_line()
    end
})

-- local function get()
--     local buf_type = fn.getbufvar(a.nvim_get_current_buf(), '&filetype')
--     if extra_buf_type_lines[buf_type] then
--         return extra_buf_type_lines[buf_type]
--     end
--     return concat(default_line)
-- end

-- return {
--     get = get
-- }
