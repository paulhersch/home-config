--[[

Custom statusline, personal use only. I do not recommend
using any of this, even though i might know what i am doing

--]]

local o = vim.o

local statusmod = require("winstatabline.modules.status")
local tabmod = require("winstatabline.modules.tab")
local line = require("winstatabline.line")

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

P.setup_tabline = function()
    P.tabline = line(
        "tabline", {
            {
                tabmod.dirname,
                events = "DirChanged"
            },
            {
                tabmod.tablist,
                events = "BufEnter"
            },
            "%#TabLineFill#%=%#TabLineCloseLabel#%999X %X"
        }, {}
    )
end

P.setup_statusline = function()
    P.statusline = line(
        "statusline", {
            {
                statusmod.mode,
                events = "ModeChanged"
            },
            {
                statusmod.fileinfo,
                events = {
                    "BufEnter",
                    "BufWipeout",
                    "WinNew",
                    "TextChangedI",
                    "TextChanged",
                    "BufWritePost"
                },
                use_initial = false
            },
            "%=",
            {
                statusmod.diagnostics,
                events = "DiagnosticChanged"
            },
            {
                statusmod.running_lsps,
                timeout = 5000
            },
            {
                statusmod.git_branch,
                events = { "BufEnter", "DirChanged" },
                use_initial = false,
            }
        }, { hidden_ft = { "alpha" } }
    )
end

M.setup = function()
    -- settings
    o.laststatus = 3
    o.cmdheight = 0
    o.showcmd = false
    o.ruler = false
    o.showmode = false

    -- setup
    P.setup_statusline()
    P.setup_tabline()
end

return M
