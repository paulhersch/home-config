------
-- PERISTENT STORAGE FOR LOCAL SETTINGS INDEPENDENT OF THE CONFIG
--
-- usage (if you want to use it yourself):
-- local settings = require "settings"
-- settings.set_defaults {...} -- sets default
-- settings.load()             -- loads settings.json from cache dir
--
-- settings.get(key)           -- fetch value of key
-- settings.set(key, value)    -- set value of key and call registeres callbacks
-- settings.register_callback(key, func) -- register callback to be called when key changes
-- settings.save()             -- save the changed settings on disk, wont save if nothing changed
--
-- the save function can easily be connected to awesomes exit signal, so that settings
-- are always written to disk when awesome is reloaded/exits
--
-- When the settings are loaded the nested tables get unnested and can be reached by the
-- string representation of their search path, so indexes
-- {
--   setting = {
--     value1 = ...
--     value2 = ...
--   }
-- }
-- will be internally transformed to
-- {
--   ['setting.value1']
--   ['setting.value2']
-- }
-- which is precisely what the key on get and set will be
-- you can always load the "settings.json" file, but IT WILL OVERWRITE the current settings
------

local gears = require "gears"
local json = require "rapidjson"
local table = table
local settings_path = gears.filesystem.get_cache_dir() .. "settings.json"

local M = { }
-- private data
local P = {
    change_callbacks = {},
    settings_changed = false,
    settings = {},
    -- create a map from a nested table, value at foo.bar.bat will be indexed by
    -- foo['bar.bat'].value, as the callbacks that should be called on change for each
    -- value also exist
    map_from_table = function (tbl)
        local map = {}

        -- recursively run over table and create hashes
        local function rec_table(pre, t)
            for key, value in pairs(t) do
                local full_key = (pre and (pre .. ".") or "") .. key
                if type(value) == "table" then
                    rec_table(full_key, value)
                else
                    map[full_key] = {
                        value = value,
                        callbacks = {}
                    }
                end
            end
        end
        rec_table(nil, tbl)

        return map
    end,
    -- we dont need the callbacks in the nested table (version to save settings to disk)
    table_from_map = function (map)
        local tbl = {}
        for key, entry in pairs(map) do
            local keysplit = gears.string.split(key, ".")
            local current = tbl
            for i=1, #keysplit-1 do
                -- if we dont have an existing subtable create it
                local next_key = keysplit[i]
                if not current[next_key] then
                    current[next_key] = {}
                end
                current = current[next_key]
            end
            -- last part of the key is the variable name
            current[keysplit[#keysplit]] = entry.value
        end
        return tbl
    end
}

--- init settings with default values
--- @param defaults table the table of default settings, has to contain every setting used
M.set_defaults = function (defaults)
    P.settings = P.map_from_table(defaults)
end

--- load settings from disk, overwrite defaults
M.load = function ()
    local loaded = {}
    if gears.filesystem.file_readable(settings_path) then
        loaded = json.load(settings_path)
    end
    gears.table.crush(P.settings, P.map_from_table(loaded))
end

--- save options to disk, skip if no changes have been made
M.save = function ()
    if P.settings_changed then
        xpcall(
            json.dump,
            function ()
                gears.debug.print_error("couldn't save changed settings to disk, does the folder ~/.cache/awesome exist?")
            end,
            P.table_from_map(P.settings),
            settings_path
        )
    end
end

---get setting by key
---@param key string the key of the settings that should be read
---@return any
M.get = function (key)
    if P.settings[key] then
        return P.settings[key].value
    end

    gears.debug.print_error(string.format("setting %s does not exist!", key))
end

---set a setting by key, if the option isn't part of the settings it will be ignored
---@param key string
---@param value any
M.set = function (key, value)
    if not P.settings[key] then
        gears.debug.print_error("a setting that does not exist has been requested to be changed")
        return
    end
    local entry = P.settings[key]

    if not type(entry.value) == type(value) then
        gears.debug.print_error(string.format(
            "the types of the value \"%s\" and settings key \"%s\" do not match",
            value or "(bool)",
            key))
        return
    end

    entry.value = value
    -- execute callbacks
    for _, func in pairs(entry.callbacks) do
        func(value)
    end
    P.settings_changed = true
end

--- subscribe to a value in the settings changing
---@param key string the setting identified via its key string
---@param func function executed function, gets new value as first argument
M.register_callback = function (key, func)
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
    table.insert(P.settings[key].callbacks, func)
end

return M
