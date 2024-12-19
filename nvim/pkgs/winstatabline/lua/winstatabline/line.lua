local a = vim.api
local o = vim.o

local concat = table.concat

local M, P = {}, {}

---@class LineOpts
---@field hidden_ft string[] filetypes, for which the line should be hidden (aucmds will still be executed!)
---@field hidden_bt string[] buftype, for which the line should be hidden (aucmds will still be executed!)
---@field padding number number of padding_chars between each component, defaults to 0
---@field padding_char string the padding char, defaults to whitespace
local default_line_opts = {
    hidden_ft = {},
    hidden_bt = {},
    padding_char = " ",
    padding = 0
}

---@class LineComponent
---@field timeout? integer timeout for polling
---@field events? string | string[] update events passed to create_autocmd if function is passed as first arg
---@field async? boolean if the function should be wrapped in an async wrapper thing
---@field use_initial? boolean if the initial value should be set with the function, defaults to true
---@field name? string name of the component, if not set no usable notification can be generated!

-- create a line
-- if for a component, events and timeout are given only events is used
---@param line_name string name of the line, e.g. statusline
---@param components string[]|LineComponent[] list of components in the line
---@param opts LineOpts? options
---@return LineClass
M.line = function(line_name, components, opts)
    -- line object
    ---@class LineClass
    ---@field _P string[] cached strings of components
    ---@field _timers any[] UV timers used by line
    ---@field _au_group any augroup_id used for autocmds of this line
    ---@field _opts LineOpts options
    local this = {
        -- private data (cached strings)
        _P = {},
        -- timers
        _timers = {},
        _au_group = nil,
        _opts = vim.tbl_extend("force", default_line_opts, opts or {})
    }

    -- autogroup things
    this._au_group = a.nvim_create_augroup("winstatabline_" .. line_name, { clear = true })

    -- precalc padding string
    this._padding_str = "%#StatusLine#" .. string.rep(this._opts.padding_char, this._opts.padding)

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

            -- connect to events or do timeout stuff (ugly, but works pretty well?)
            if comp.events then
                a.nvim_create_autocmd(comp.events, {
                    callback = function()
                        this[index] = comp[1]()
                    end,
                    group = this._au_group
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
            -- this usually happens, when the bar receives one event
            -- which makes it update -> use it for ft detection
            ---@param self LineClass
            __call = function(self)
                if #self._opts.hidden_ft > 0 then
                    local buf_ft = a.nvim_get_option_value("filetype", { buf = 0 })
                    for _, ft in pairs(self._opts.hidden_ft) do
                        if ft == buf_ft then
                            o[line_name] = "%#StatusLineNC#"
                            return
                        end
                    end
                end
                if #self._opts.hidden_bt > 0 then
                    local buf_bt = a.nvim_get_option_value("buftype", { buf = 0 })
                    for _, bt in pairs(self._opts.hidden_bt) do
                        if bt == buf_bt then
                            o[line_name] = "%#StatusLineNC#"
                            return
                        end
                    end
                end
                o[line_name] = tostring(self)
            end,
            ---@param self LineClass
            __newindex = function(self, k, v)
                self._P[k] = v
                self()
            end,
            ---@param self LineClass
            __index = function(self, k)
                return self._P[k]
            end,
            ---@param self LineClass
            __tostring = function(self)
                return concat(self._P, self._padding_str)
            end
        }
    )

    this()
    return this
end

return setmetatable(M, {
    __call = function(self, ...) return self.line(...) end
})
