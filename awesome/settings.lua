local gears = require "gears"
local json = require "rapidjson"
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack
local pack = table.pack or function (...)
    return {...}
end
local settings_path = gears.filesystem.get_cache_dir() .. "settings.json"

-- the rice's default settings
-- will be overwritten by M.load
local settings = {
    notifications = {
        dnd = false,
        silent = false
    }
}

local settings_changed = false

local M = { }

--- load settings from disk
M.load = function ()
    local loaded = {}
    if gears.filesystem.file_readable(settings_path) then
        loaded = json.load(settings_path)
    end
    gears.table.crush(settings, loaded)
end

--- save options to disk
M.save = function ()
    if settings_changed then
        json.dump(settings, settings_path)
    end
end

---get setting by key
---@param key string the key of the settings that should be read
---@return any
M.get = function (key)
    local ret = settings
    for _, subkey in ipairs(gears.string.split(key, ".")) do
        ret = ret[subkey]
    end
    return ret
end

---set a setting by key, if the option isn't part of the settings it will be ignored
---@param key string
---@param value any
M.set = function (key, value)
    --i dont exactly know why, but it works
    --not sure wether i could leave out the whole "one key before val" stuff, because not sure
    --if lua just passes around references
    local keys = gears.string.split(key, ".")
    local ret = settings
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
    else
        gears.debug.print_error("the types of the value " .. value or "(bool)" .. " and settings key " .. key .. " do not match")
    end
end

return M
