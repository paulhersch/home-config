--[[

Custom statusline, personal use only. I do not recommend
using any of this, i do not know what i am doing

--]]

local statusmod = require("winstatabline.modules.status")
local tabmod = require("winstatabline.modules.tab")
local winmod = require("winstatabline.modules.win")

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

P.create_linemeta = function(o_id)
    return {
        __call = function(self)
            return concat(self._P)
        end,
        __newindex = function(self, k, v)
            local p_id = self._keys[k]
            if p_id then
                self._P[p_id] = v
                o[o_id] = concat(self._P)
            end
        end
    }
end

P.statusline = setmetatable({
    _P = {
        statusmod.mode(),
        "%=",
        "", -- diagnostics
        "", -- lsps
        "", -- branch
        " "
    },
    _keys = {
        mode = 1, diagnostics = 3, lsps = 4, branch = 5
    }
}, P.create_linemeta("statusline"))

P.tabline = setmetatable({
    _P = {
        -- "%#TabLineNvimString# NeoVIM " .. tostring(vim.version()) .. " %#TabLineFill# ",
        tabmod.dirname(), -- dir
        tabmod.tablist(), -- tabs
        "%#TabLineFill#%=%#TabLineCloseLabel#%999X %X"
    },
    _keys = {
        dir = 1, tabs = 2
    }
}, P.create_linemeta("tabline"))

P.setup_statusline = function(augroup_id)
    a.nvim_create_autocmd({ "DiagnosticChanged" }, {
        group = augroup_id,
        callback = function()
            P.statusline.diagnostics = statusmod.diagnostics()
        end
    })

    a.nvim_create_autocmd({ "ModeChanged" }, {
        group = augroup_id,
        callback = function()
            P.statusline.mode = statusmod.mode()
        end
    })

    a.nvim_create_autocmd({ "BufRead" }, {
        group = augroup_id,
        callback = function()
            P.statusline.branch = statusmod.git_branch()
        end
    })

    a.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
        group = augroup_id,
        callback = function()
            P.statusline.lsps = statusmod.running_lsps()
        end
    })
    o.statusline = P.statusline()
end

P.setup_tabline = function(augroup_id)
    -- TextChanged for * thingy
    -- BufEnter for focus change, Wipeout for popups
    -- WritePost for after write (duh), Filetype for replacement lines
    a.nvim_create_autocmd({ "BufEnter", "BufWipeout", "BufWritePost", "TextChangedI", "TextChanged", "FileType" }, {
        group = augroup_id,
        callback = function()
            P.tabline.tabs = tabmod.tablist()
        end
    })

    a.nvim_create_autocmd("DirChanged", {
        group = augroup_id,
        callback = function()
            P.tabline.dir = tabmod.dirname()
        end
    })
    o.tabline = P.tabline()
end

P.winbar = function()
    local win = g.statusline_winid
    local buf = a.nvim_win_get_buf(win)
    return concat({
        "%#WinBarNC#%=%#WinBar# ",
        winmod.fileinfo(buf),
        " %#WinBarNC#%=",
    })
end

M.setup = function()
    -- settings
    o.showtabline = 2
    o.laststatus = 3
    o.cmdheight = 0
    o.showcmd = false
    o.ruler = false
    o.showmode = false

    -- setup
    local aug = a.nvim_create_augroup("winstatabline", { clear = true })
    P.setup_statusline(aug)
    P.setup_tabline(aug)

    -- _G.winbar = P.winbar
    -- o.winbar = "%!v:lua.winbar()"
end

return M
