local M = {}

---@return string
local function serialize_lua_obj(obj)
    local return_string = ""
    local obj_type = type(obj)
    if obj_type == "table" then
        return_string = return_string .. "{"
        for index, item in pairs(obj) do
            return_string = return_string .. "[\"" .. index .. "\"]=" .. serialize_lua_obj(item) .. ","
        end
        return return_string .. "}"
    elseif obj_type == "string" then
        return "\"" .. obj .. "\""
    elseif obj_type == "number" then
        return tostring(obj)
    elseif obj_type == "boolean" then
        return obj and "true" or "false"
    elseif obj_type == "nil" then
        return ""
    else
        error("can only serialize tables, strings, numbers and booleans")
    end
end

M.build_cache = function()
    -- all those require statements are ugly but i need to avoid circular
    -- imports
    local cache_dir = vim.fn.stdpath("data") .. "/site/lua/colors/cache"
    -- create dir if not existing already
    vim.fn.mkdir(cache_dir, "p")

    -- for all themes
    for _, theme in pairs(require("colors").list_themes()) do
        -- load scheme def
        local hl_groups = require("colors.config").config(require("colors").get_colors(theme))
        local file_contents = { "local hl = vim.api.nvim_set_hl", "local function apply()" }

        for group, hl_def in pairs(hl_groups) do
            table.insert(
                file_contents,
                -- create vim.api.nvim_set_hl calls
                string.format("hl(0, '%s', %s)", group, serialize_lua_obj(hl_def))
            )
        end

        table.insert(file_contents, "end")
        table.insert(file_contents, "return apply")

        vim.fn.writefile(file_contents, string.format("%s/%s.lua", cache_dir, theme))
    end
end

return M
