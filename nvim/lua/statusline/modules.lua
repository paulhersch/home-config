local devicons = require("nvim-web-devicons")
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
}

m.mode = function()
    local current_mode = a.nvim_get_mode().mode
    if modes[current_mode] ~= nil then
        return string.format("%%#%s#%s", modes[current_mode][2]," ")
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

m.lsp_info = function()
    update_lsp()
    local e, w, i = err_cnt(), warn_cnt(), inf_cnt()
    local e_str = e > 0 and ("%#StatusLineDiagnosticError#" .. "   " .. e) or ""
    local w_str = w > 0 and ("%#StatusLineDiagnosticWarn#" .. "   " .. w) or ""
    local i_str = i > 0 and ("%#StatusLineDiagnosticInfo#" .. "   " .. i) or ""
    return e_str .. w_str .. i_str
end

-- the ww depends on one of my keybinds
-- _G.__feedww = function ()
--     vim.api.nvim_input('ww')
-- end

m.file_edited = function ()
    local edited = fn.getbufinfo(a.nvim_get_current_buf())[1].changed == 1 and "%2@v:w@ %T " or ""
    return "%#StatusLineFileModified#" .. edited
end

-- this requires the colorscheme to be loaded first
local statuslinehl = a.nvim_get_hl_by_name("StatusLine", true)
for _, dat in pairs(devicons.get_icons()) do
    a.nvim_set_hl(0, "StatusLineDevIcon" .. dat.name, {
        bg = string.format("#%06x",statuslinehl["background"]),
        fg = dat.color
    })
end
-- hacky workaround: devicons set hl groups with DevIcon<defname>
-- so above i set hl groups like this with the StatusLine prefix
-- and then i can use the hl names from devicons directly in the line
m.fileinfo = function()
    local fname = (fn.expand "%" == "" and "unnamed") or fn.expand "%:t"
    local icon, icon_hl = devicons.get_icon(fname)
    icon = icon and "%#StatusLine" .. icon_hl .. "#" .. icon .. "  " or ""
    return icon .. "%#StatusLineFileName#" .. string.upper(fname)
end

m.git_status = function ()
    local git = require("git")
end

return m
