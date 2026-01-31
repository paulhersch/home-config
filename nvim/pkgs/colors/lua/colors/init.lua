-- Collection of colorschemes i use(d) or experiment with
-- every scheme needs colors 0-23:
-- white, red, green, yellow, blue, purple, cyan, black
-- 0-7: fg colors
-- 8-15: bright fg colors
-- 16-23: pastel/bg colors (only used for backgrounds)
-- if the theme is dark/needs to use the bg to be visible for 16-23, add the
-- name to the list P.dark
--
-- also needed: 4 backgrounds (kind of legacy naming, lol)
-- background (bg0)
-- background_dark (bg1)
-- inactive_tabs (bg2)
-- contrast (bg3)
--
-- foreground (fg0)
--
-- and the special use case colors:
-- cursor (cursor color)
-- cursorline (fg but lighter, for line numbers)
-- comment (exclusively for comment strings and maybe statusline components)

local M = {}
local P = {
    current_theme = nil
}

--- @return table
function M.list_themes()
    local themes = {}
    for name, _ in pairs(require("colors.themes")) do
        table.insert(themes, name)
    end
    return themes
end

--- @return table
function M.get_colors(theme)
    -- if dark theme bg use bg for fg with colors as bg,
    -- otherwise fg
    local colors = require("colors.themes")[theme]()
    for _, t in ipairs({ "azul", "radium" }) do
        if theme == t then
            colors.fg_for_color_bg = colors.background
            return colors
        end
    end
    colors.fg_for_color_bg = colors.foreground
    return colors
end

function M.set_theme(theme)
    -- if P.current_theme and P.current_theme == theme then return end

    local success, f = pcall(require, "colors.cache." .. theme)
    if success then
        P.current_theme = theme
        f()
        return
    end

    local found = false
    for _, t in pairs(M.list_themes()) do
        if t == theme then
            found = true
            break
        end
    end

    if not found then
        vim.notify(string.format("theme %s does not exist", theme))
    else
        vim.notify(
            string.format(
                "theme %s not cached, you can always rebuild the theme cache with"
                .. "\n```lua\n"
                .. "require('colors.compiler').build_cache()\n"
                .. "```\n"
                .. "will rebuild the cache now, as the theme exists",
                theme
            )
        )
        require("colors.compiler").build_cache()
        require("colors.cache." .. theme)()
        P.current_theme = theme
    end
    -- local hl = vim.api.nvim_set_hl
    -- for group, properties in pairs(
    --     require "colors.config".config(
    --         M.get_colors(theme)
    --     )
    -- ) do
    --     hl(0, group, properties)
    -- end
end

---@class Color.setupOpts
---@field theme "light"|"mud"|"azul"|"radium" the theme
---@param opts Color.setupOpts
-- defaults:
-- {
--      theme = "light"
-- }
-- you need to set the background option to either dark or light
-- before using this function or else neovim will load its default theme
-- after this one

-- function M.setup(opts)
--
--     local defaults = {
--         theme = "light"
--     }
--
--     opts = vim.tbl_extend("keep", opts, defaults)
--     M.set_theme(opts.theme)
-- end

local function on_choice(item)
    if item then
        M.set_theme(item)
    end
end

-- Pick one of the themes in here using vim.ui.select
M.pick_theme = function()
    local theme_names = M.list_themes()
    table.sort(theme_names)
    vim.ui.select(theme_names, { prompt = "Select Colorscheme" }, on_choice)
end

M.get_current_theme_colors = function()
    if P.current_theme ~= nil then
        return M.get_colors(P.current_theme)
    end

    vim.notify("Couldnt fetch current theme, no theme set")
    return nil
end

return M
