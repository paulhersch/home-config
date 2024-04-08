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
        return string.format("%%#%s#%s", modes[current_mode][2],"▋")
    end
end

local lsp_count = { 0, 0, 0, 0 }

a.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
        lsp_count = { 0, 0, 0, 0 }
        local diagnostics = vim.diagnostic.get(0)
        for _, diagnostic in ipairs(diagnostics) do
            if vim.startswith(vim.diagnostic.get_namespace(diagnostic.namespace).name, 'vim.lsp') then
                lsp_count[diagnostic.severity] = lsp_count[diagnostic.severity] + 1
            end
        end
    end,
    desc = "update diagnostics bar info"
})

-- local signs = {}
-- for _, level in pairs({"Error", "Warn", "Info"}) do
--     signs[level] = vim.fn.sign_getdefined("DiagnosticSign" .. level)[1].text
-- end

m.lsp_info = function()
    local info_string = ""
    for i, level in ipairs({"Error", "Warn", "Info"}) do
        local count = lsp_count[i]
        if count > 0 then
            info_string = info_string .. string.format(
                "%%#StatusLineDiagnostic%s#%d ", level, count
            )
        end
    end
    return info_string
end

m.fileinfo = function(buf)
    local fname = a.nvim_buf_get_name(buf)
    -- match word before str end that doesnt contain / (filename only)
    local status, result = pcall(string.match, fname, "[^/]+$")

    local edited = fn.getbufinfo(buf)[1].changed == 1
    local perms = fn.getfperm(fname)

    return table.concat {
        "%#StatusLineFileName#",
        (status and result or fname),
        string.format(
            '  %%#StatusLineFileModified#%s:%s',
            edited and '+' or '-',
            string.sub(perms, 1, 3)
        )
    }
end

m.git_branch = function ()
    local branch = fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    return "%#StatusLineGitBranch#" .. branch
end

return m
