local gears = require "gears"
local json = require "rapidjson"
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack
local pack = table.pack or function (...)
    return {...}
end
local settings_path = gears.filesystem.get_cache_dir() .. "settings.json"

local settings_changed = false

local M = { }
-- private data
local P = {
    change_callbacks = {},
    settings_changed = false,
    settings = {}
}

--- init settings with default values
--- @param defaults table the table of default settings, has to contain every setting used
M.set_defaults = function (defaults)
    P.settings = defaults
end

--- load settings from disk, overwrite defaults
M.load = function ()
    local loaded = {}
    if gears.filesystem.file_readable(settings_path) then
        loaded = json.load(settings_path)
    end
    gears.table.crush(P.settings, loaded)
end

--- save options to disk
M.save = function ()
    if settings_changed then
        json.dump(P.settings, settings_path)
    end
end

---get setting by key
---@param key string the key of the settings that should be read
---@return any
M.get = function (key)
    local ret = P.settings
    for _, subkey in ipairs(gears.string.split(key, ".")) do
        ret = ret[subkey]
    end
    if ret ~= nil then
        return ret
    end

    gears.debug.print_error(string.format("setting %s does not exist!", key))
end

---set a setting by key, if the option isn't part of the settings it will be ignored
---@param key string
---@param value any
M.set = function (key, value)
    --i dont exactly know why, but it works
    --not sure wether i could leave out the whole "one key before val" stuff, because not sure
    --if lua just passes around references
    local keys = gears.string.split(key, ".")
    local ret = P.settings
    for _, subkey in ipairs(pack(unpack(keys, 1, #keys-1))) do
        ret = ret[subkey]
        if type(ret) ~= "table" then
            gears.debug.print_error("a setting that does not exist has been requested to be changed")
            return
        end
    end

    if type(ret[keys[#keys]]) == type(value) then
        ret[keys[#keys]] = value
        settings_changed = true
        -- call subscribed callbacks
        for _, func in ipairs(P.change_callbacks[key]) do
            func(value)
        end
    else
        gears.debug.print_error(string.format(
            "the types of the value \"%s\" and settings key \"%s\" do not match",
            value or "(bool)",
            key
        ))
    end
end

--- subscribe to a value in the settings changing
---@param key string the setting identified via its key string
---@param func function executed function, gets new value as first argument
M.on_value_changed = function (key, func)
    -- check if there is a value for key
    -- return is not captured as we only care about whether an error is thrown
    local success, _ = xpcall(M.get, function()
        gears.debug.print_error(string.format(
            "encountered error finding setting \"%s\" to connect to: %s",
            key,
            debug.traceback
        ))
    end, key)

    if not success then
        return
    end
    -- if no callbacks registered, no table exists for key
    if not P.change_callbacks[key] then
        P.change_callbacks[key] = {}
    end
    table.insert(P.change_callbacks[key], func)
end

return M
