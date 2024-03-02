local a = vim.api
local fn = vim.fn

local m = {}

local modes = {
    ["n"] = {"NORMAL", "StatusLineModeNormal" },
    ["no"] = {"NORMAL", "StatusLineModeNormal"},
    ["v"] = {"VISUAL", "StatusLineModeVisual"},
    ["V"] = {"VISUAL LINE", "StatusLineModeVisual"},
    [""] = {"VISUAL BLOCK", "StatusLineModeVisual"},
    ["s"] = {"SELECT", "StatusLineModeVisual"},
    ["S"] = {"SELECT LINE", "StatusLineModeVisual"},
    [""] = {"SELECT BLOCK", "StatusLineModeVisual"},
    ["i"] = {"INSERT", "StatusLineModeInsert"},
    ["ic"] = {"INSERT", "StatusLineModeInsert"},
    ["R"] = {"REPLACE", "StatusLineModeReplace"},
    ["Rv"] = {"VISUAL REPLACE", "StatusLineModeReplace"},
    ["c"] = {"COMMAND", "StatusLineModeCmd"},
    ["cv"] = {"VIM EX", "StatusLineModeCmd"},
    ["ce"] = {"EX", "StatusLineModeCmd"},
    ["r"] = {"PROMPT", "StatusLineModeCmd"},
    ["rm"] = {"MOAR", "StatusLineModeCmd"},
    ["r?"] = {"CONFIRM", "StatusLineModeCmd"},
    ["!"] = {"SHELL", "StatusLineModeTerminal"},
    ["t"] = {"TERMINAL", "StatusLineModeTerminal"},
    ["nt"] = {"TERMINAL", "StatusLineModeTerminal"},
}

m.mode = function()
    local current_mode = a.nvim_get_mode().mode
    if modes[current_mode] ~= nil then
        return string.format("%%#%s#%s", modes[current_mode][2],"  ")
    end
end

local lsp_count = { 0, 0, 0, 0 }
local function err_cnt()
    return lsp_count[vim.diagnostic.severity.ERROR]
end
local function warn_cnt()
    return lsp_count[vim.diagnostic.severity.WARN]
end
local function inf_cnt()
    return lsp_count[vim.diagnostic.severity.INFO]
end
local function update_lsp()
    lsp_count = { 0, 0, 0, 0 }
    local diagnostics = vim.diagnostic.get(0)
    for _, diagnostic in ipairs(diagnostics) do
        if vim.startswith(vim.diagnostic.get_namespace(diagnostic.namespace).name, 'vim.lsp') then
            lsp_count[diagnostic.severity] = lsp_count[diagnostic.severity] + 1
        end
    end
end

a.nvim_create_autocmd("DiagnosticChanged", {
    callback = update_lsp,
    desc = "update diagnostics bar info"
})

m.lsp_info = function()
    local e, w, i = err_cnt(), warn_cnt(), inf_cnt()
    local e_str = e > 0 and ("%#StatusLineDiagnosticError#" .. "   " .. e) or ""
    local w_str = w > 0 and ("%#StatusLineDiagnosticWarn#" .. "   " .. w) or ""
    local i_str = i > 0 and ("%#StatusLineDiagnosticInfo#" .. "   " .. i) or ""
    return e_str .. w_str .. i_str
end

m.file_edited = function (buf)
    local edited = fn.getbufinfo(buf)[1].changed == 1
    if edited then
        return "%#StatusLineFileModified#  "
    end
    return ""
end

m.fileinfo = function(buf)
    local fname = a.nvim_buf_get_name(buf)
    local status, result = pcall(string.match, fname, "[%w%.]+$")
    -- match word before str end that doesnt contain / (filename only)
    return "%#StatusLineFileName#" .. string.upper(status and result or fname)
end

m.git_branch = function ()
    local branch = fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch ~= "" then
        return " " .. branch
    else
        return ""
    end
end

return m
