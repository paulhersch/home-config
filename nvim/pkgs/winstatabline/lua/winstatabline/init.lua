--[[

Custom statusline, personal use only. I do not recommend
using any of this, even though i might know what i am doing

--]]

local statusmod = require("winstatabline.modules.status")
local tabmod = require("winstatabline.modules.tab")

local concat = table.concat
local a = vim.api
local o = vim.opt

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

---@class Component
---@field timeout? integer timeout for polling
---@field events? string | string[] update events passed to create_autocmd if function is passed as first arg
---@field async? boolean if the function should be wrapped in an async wrapper thing
---@field use_initial? boolean if the initial value should be set with the function, defaults to true
---@field name? string name of the component, if not set no usable notification can be generated!

-- create a line
-- if for a component, events and timeout are given only events is used
---@param line_name string name of the line, e.g. statusline
---@param components string[]|Component[] list of components in the line
---@param clear? boolean clears autogroup
P.line = function(line_name, components, clear)
    -- autogroup things
    if not P._au_group or clear then
        P._au_group = a.nvim_create_augroup("winstatabline", { clear = true })
    end

    -- line object
    local this = {
        -- private data (cached strings)
        _P = {},
        -- timers
        _timers = {}
    }

    for index, comp in ipairs(components) do
        if type(comp) == "string" then
            this._P[index] = comp
        elseif type(comp) == "table" then
            comp = vim.tbl_extend("force", {
                use_initial = true,
                async = false
            }, comp)

            if not comp.events and not comp.timeout then
                vim.notify(
                    string.format("Component %s needs event or timeout, because it is a function",
                        comp.name or tostring(comp[1]))
                )
                goto continue
            end

            -- initial string
            if not comp.use_initial then
                this._P[index] = ""
            else
                this._P[index] = comp[1]()
            end

            -- connect to events or do timeout stuff (ugly)
            if comp.events then
                a.nvim_create_autocmd(comp.events, {
                    callback = function()
                        this[index] = comp[1]()
                    end,
                    group = P._au_group
                })
            elseif comp.timeout then
                -- dont run multiple timers with same timeouts, make them all run at once at least
                local timer = tostring(comp.timeout)
                local wrapped = function()
                    -- get value outside of main loop and only transfer
                    -- set the value inside the main vim loop
                    local val = comp[1]()
                    vim.schedule_wrap(function()
                        this[index] = val
                    end)()
                end
                -- create timer obj if it doesn't exist, otherwise just add the wrapped
                -- callback given in the args
                if this._timers[timer] then
                    this._timers[timer].uv_timer:stop()
                    table.insert(this._timers[timer].callbacks, 1, wrapped)
                else
                    this._timers[timer] = {
                        callbacks = { wrapped },
                        uv_timer = vim.uv.new_timer()
                    }
                end
                -- timer has to be restarted each time, because callback data changed
                -- and the callback isn't passed as reference but as object
                this._timers[timer].uv_timer:start(0, comp.timeout, function()
                    for _, func in ipairs(this._timers[timer].callbacks) do
                        func()
                    end
                end)
            end
        end
        ::continue::
    end

    this = setmetatable(
        this,
        {
            __call = function(self)
                o[line_name] = tostring(self)
            end,
            __newindex = function(self, k, v)
                self._P[k] = v
                self()
            end,
            __index = function(self, k)
                return self._P[k]
            end,
            __tostring = function(self)
                return concat(self._P)
            end
        }
    )

    this()
    return this
end

P.setup_tabline = function(clear)
    P.tabline = P.line(
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
        },
        clear
    )
end

P.setup_statusline = function(clear)
    P.statusline = P.line(
        "statusline", {
            {
                statusmod.mode,
                events = "ModeChanged"
            },
            {
                statusmod.fileinfo,
                events = {
                    "BufEnter",
                    "BufWinEnter",
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
        },
        clear
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
    P.setup_statusline(true)
    P.setup_tabline(false)
end

return M
