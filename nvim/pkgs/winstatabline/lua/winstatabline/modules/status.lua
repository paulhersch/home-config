local fn = vim.fn
local a = vim.api
---@diagnostic disable-next-line: undefined-global
local concat = concat or table.concat
local util = require("winstatabline.modules.util")

local M = {}
local P = {}

P.modes = {
    ["n"] = { "NORMAL", "StatusLineModeNormal" },
    ["no"] = { "NORMAL", "StatusLineModeNormal" },
    ["v"] = { "VISUAL", "StatusLineModeVisual" },
    ["V"] = { "VISUAL LINE", "StatusLineModeVisual" },
    [""] = { "VISUAL BLOCK", "StatusLineModeVisual" },
    ["s"] = { "SELECT", "StatusLineModeVisual" },
    ["S"] = { "SELECT LINE", "StatusLineModeVisual" },
    [""] = { "SELECT BLOCK", "StatusLineModeVisual" },
    ["i"] = { "INSERT", "StatusLineModeInsert" },
    ["ic"] = { "INSERT", "StatusLineModeInsert" },
    ["R"] = { "REPLACE", "StatusLineModeReplace" },
    ["Rv"] = { "VISUAL REPLACE", "StatusLineModeReplace" },
    ["c"] = { "COMMAND", "StatusLineModeCmd" },
    ["cv"] = { "VIM EX", "StatusLineModeCmd" },
    ["ce"] = { "EX", "StatusLineModeCmd" },
    ["r"] = { "PROMPT", "StatusLineModeCmd" },
    ["rm"] = { "MOAR", "StatusLineModeCmd" },
    ["r?"] = { "CONFIRM", "StatusLineModeCmd" },
    ["!"] = { "SHELL", "StatusLineModeTerminal" },
    ["t"] = { "TERMINAL", "StatusLineModeTerminal" },
    ["nt"] = { "TERMINAL", "StatusLineModeTerminal" },
}

P.diagnostic_count = { 0, 0, 0, 0 }

a.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
        P.diagnostic_count = { 0, 0, 0, 0 }
        local diagnostics = vim.diagnostic.get(0)
        for _, diagnostic in ipairs(diagnostics) do
            if vim.startswith(vim.diagnostic.get_namespace(diagnostic.namespace).name, 'vim.lsp') then
                P.diagnostic_count[diagnostic.severity] = P.diagnostic_count[diagnostic.severity] + 1
            end
        end
    end,
    desc = "update diagnostics bar info"
})

P.signs = {
    Error = " ",
    Warn = " ",
    Info = " "
}

M.git_branch = function()
    local success, branch = pcall(a.nvim_buf_get_var, 0, "gitsigns_head")
    if not success then return "" end
    return string.format("%%#StatusLineGitBranch#  %s", branch)
end

M.running_lsps = function()
    if #vim.lsp.get_clients() == 0 then
        return ""
    end
    local lsps = {}
    local active_clients = vim.lsp.get_clients()
    for _, lsp in pairs(active_clients) do
        table.insert(lsps, lsp.name)
    end
    return "%#StatusLineLSPServers#  " .. concat(lsps, ", ") .. "%#StatusLine#"
end

M.diagnostics = function()
    local info_string = ""
    for i, level in ipairs({ "Error", "Warn", "Info" }) do
        local count = P.diagnostic_count[i]
        if count > 0 then
            info_string = info_string .. string.format(
                "%%#StatusLineDiagnostic%s#%s %d ", level, P.signs[level], count
            )
        end
    end
    return info_string
end

M.mode = function()
    local current_mode = a.nvim_get_mode().mode
    if P.modes[current_mode] ~= nil then
        local color_indicator = string.format("%%#%s# %s ", P.modes[current_mode][2], P.modes[current_mode][1])
        -- local text_desc = current_mode == "n" and "" or (
        --     string.format("%%#StatusLineModeText# -- %s --", P.modes[current_mode][1])
        -- )
        return color_indicator -- .. text_desc
    end
end

M.fileinfo_for_buf = function(buf)
    local fname, used_replacement = util.get_t_of_buf(buf)

    -- the filename could be nil in some random cases (opening telescope immediately
    -- after opening neovim), so we need to make sure its NOT nil, as we cant do the
    -- stuff later as well
    if not fname then return { "", "" } end

    if used_replacement then
        return { fname, "" }
    end

    local edited = fn.getbufinfo(buf)[1].changed == 1

    return {
        fname, string.format(
        '%s:%s',
        edited and '+' or '-',
        string.sub(fn.getfperm(a.nvim_buf_get_name(buf)), 1, 6))
    }
end

M.fileinfo = function()
    local finfo = M.fileinfo_for_buf(a.nvim_get_current_buf())
    return table.concat {
        " %#StatusLine#",
        finfo[1],
        ' %%#StatusLineFileStat#',
        finfo[2]
    }
end

return M
